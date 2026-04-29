import json
import logging
from datetime import datetime, timezone
from typing import Optional

from fastapi import HTTPException, status

from app.database import get_connection
from app.schemas.contract_schema import ContractCreate, ContractUpdate
from app.services import audit_service, blockchain_service
from app.services.cloud_provider_validation_service import validate_provider_for_contract

logger = logging.getLogger(__name__)


# ---------------------------------------------------------------------------
# Internal helpers
# ---------------------------------------------------------------------------

def _fetch_contract_detail(contract_id: int, conn) -> Optional[dict]:
    """
    Fetch a full contract record joined with creator and cloud provider info.
    Uses the supplied connection (caller manages lifecycle).
    """
    cursor = conn.cursor(dictionary=True)
    try:
        cursor.execute(
            """
            SELECT
                c.id,
                c.title,
                c.content,
                c.status,
                c.contains_sensitive_data,
                c.created_at,
                c.updated_at,
                c.created_by_user_id,
                u.name  AS created_by_name,
                u.email AS created_by_email,
                c.cloud_provider_id,
                cp.name AS cloud_provider_name,
                cp.region AS cloud_provider_region,
                cp.country AS cloud_provider_country,
                cp.location_type AS cloud_provider_location_type,
                cp.allows_sensitive_data AS cloud_provider_allows_sensitive_data,
                cp.is_active AS cloud_provider_is_active
            FROM contracts c
            JOIN users u         ON u.id  = c.created_by_user_id
            JOIN cloud_providers cp ON cp.id = c.cloud_provider_id
            WHERE c.id = %s
            """,
            (contract_id,),
        )
        row = cursor.fetchone()
    finally:
        cursor.close()

    if not row:
        return None

    # Participants
    cursor2 = conn.cursor(dictionary=True)
    try:
        cursor2.execute(
            """
            SELECT
                cp.id,
                cp.user_id,
                cp.role_in_contract,
                cp.has_signed,
                cp.signed_at,
                u.name  AS user_name,
                u.email AS user_email,
                u.system_role AS user_system_role
            FROM contract_participants cp
            JOIN users u ON u.id = cp.user_id
            WHERE cp.contract_id = %s
            ORDER BY cp.id ASC
            """,
            (contract_id,),
        )
        participants = cursor2.fetchall()
    finally:
        cursor2.close()

    # Blockchain blocks
    cursor3 = conn.cursor(dictionary=True)
    try:
        cursor3.execute(
            """
            SELECT
                id,
                block_number,
                event_type,
                data_json,
                previous_hash,
                hash,
                created_by_user_id,
                created_at
            FROM blockchain_blocks
            WHERE contract_id = %s
            ORDER BY block_number ASC
            """,
            (contract_id,),
        )
        blocks = cursor3.fetchall()
    finally:
        cursor3.close()

    return {
        "id": row["id"],
        "title": row["title"],
        "content": row["content"],
        "status": row["status"],
        "contains_sensitive_data": bool(row["contains_sensitive_data"]),
        "created_at": row["created_at"],
        "updated_at": row["updated_at"],
        "created_by": {
            "id": row["created_by_user_id"],
            "name": row["created_by_name"],
            "email": row["created_by_email"],
        },
        "cloud_provider": {
            "id": row["cloud_provider_id"],
            "name": row["cloud_provider_name"],
            "region": row["cloud_provider_region"],
            "country": row["cloud_provider_country"],
            "location_type": row["cloud_provider_location_type"],
            "allows_sensitive_data": bool(row["cloud_provider_allows_sensitive_data"]),
            "is_active": bool(row["cloud_provider_is_active"]),
        },
        "participants": [
            {
                "id": p["id"],
                "user_id": p["user_id"],
                "user_name": p["user_name"],
                "user_email": p["user_email"],
                "user_system_role": p["user_system_role"],
                "role_in_contract": p["role_in_contract"],
                "has_signed": bool(p["has_signed"]),
                "signed_at": p["signed_at"],
            }
            for p in participants
        ],
        "blockchain_blocks": [
            {
                "id": b["id"],
                "block_number": b["block_number"],
                "event_type": b["event_type"],
                "data_json": b["data_json"],
                "previous_hash": b["previous_hash"],
                "hash": b["hash"],
                "created_by_user_id": b["created_by_user_id"],
                "created_at": b["created_at"],
            }
            for b in blocks
        ],
    }


def _fetch_contract_detail_fresh(contract_id: int) -> dict:
    """Open a new connection and fetch full contract detail. Used post-commit."""
    conn = get_connection()
    try:
        return _fetch_contract_detail(contract_id, conn)
    finally:
        conn.close()


def _require_contract_exists(contract_id: int, conn) -> dict:
    """Return contract detail or raise 404."""
    detail = _fetch_contract_detail(contract_id, conn)
    if detail is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Contrato {contract_id} no encontrado",
        )
    return detail


def _user_can_see_contract(contract: dict, current_user: dict, conn) -> bool:
    """
    ADMIN/AUDITOR can see any contract.
    USUARIO must be creator or participant.
    """
    role = current_user["system_role"]
    if role in ("ADMIN", "AUDITOR"):
        return True
    user_id = current_user["id"]
    if contract["created_by"]["id"] == user_id:
        return True
    # Check participants table directly for safety
    cursor = conn.cursor(dictionary=True)
    try:
        cursor.execute(
            "SELECT id FROM contract_participants WHERE contract_id = %s AND user_id = %s",
            (contract["id"], user_id),
        )
        row = cursor.fetchone()
    finally:
        cursor.close()
    return row is not None


# ---------------------------------------------------------------------------
# Public service functions
# ---------------------------------------------------------------------------

def get_contracts(current_user: dict, filters: dict) -> list:
    """
    Return a list of contracts with summary fields.
    ADMIN/AUDITOR: see all.
    USUARIO: only contracts where they are creator or participant.
    Optional filters: status, title (LIKE), cloud_provider_id.
    """
    role = current_user["system_role"]
    user_id = current_user["id"]

    query = """
        SELECT
            c.id,
            c.title,
            c.status,
            c.contains_sensitive_data,
            c.created_at,
            c.created_by_user_id,
            u.name  AS created_by_name,
            c.cloud_provider_id,
            cp.name AS cloud_provider_name,
            COUNT(DISTINCT par.id)                          AS total_participants,
            SUM(CASE WHEN par.has_signed = TRUE THEN 1 ELSE 0 END) AS signed_participants
        FROM contracts c
        JOIN users u         ON u.id  = c.created_by_user_id
        JOIN cloud_providers cp ON cp.id = c.cloud_provider_id
        LEFT JOIN contract_participants par ON par.contract_id = c.id
        WHERE 1=1
    """
    params: list = []

    if role == "USUARIO":
        query += """
            AND (
                c.created_by_user_id = %s
                OR EXISTS (
                    SELECT 1 FROM contract_participants cp2
                    WHERE cp2.contract_id = c.id AND cp2.user_id = %s
                )
            )
        """
        params.extend([user_id, user_id])

    if filters.get("status"):
        query += " AND c.status = %s"
        params.append(filters["status"])

    if filters.get("title"):
        query += " AND c.title LIKE %s"
        params.append(f"%{filters['title']}%")

    if filters.get("cloud_provider_id"):
        query += " AND c.cloud_provider_id = %s"
        params.append(filters["cloud_provider_id"])

    query += " GROUP BY c.id ORDER BY c.id DESC"

    conn = get_connection()
    try:
        cursor = conn.cursor(dictionary=True)
        cursor.execute(query, params)
        rows = cursor.fetchall()
    finally:
        cursor.close()
        conn.close()

    result = []
    for row in rows:
        result.append({
            "id": row["id"],
            "title": row["title"],
            "status": row["status"],
            "contains_sensitive_data": bool(row["contains_sensitive_data"]),
            "created_at": row["created_at"],
            "created_by": {
                "id": row["created_by_user_id"],
                "name": row["created_by_name"],
            },
            "cloud_provider": {
                "id": row["cloud_provider_id"],
                "name": row["cloud_provider_name"],
            },
            "total_participants": int(row["total_participants"] or 0),
            "signed_participants": int(row["signed_participants"] or 0),
        })
    return result


def get_contract_detail(contract_id: int, current_user: dict) -> dict:
    """
    Return full contract detail.
    404 if not found.
    USUARIO: 403 unless creator or participant.
    """
    conn = get_connection()
    try:
        contract = _require_contract_exists(contract_id, conn)

        if not _user_can_see_contract(contract, current_user, conn):
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="No tiene permiso para ver este contrato",
            )

        return contract
    finally:
        conn.close()


def create_contract(data: ContractCreate, current_user: dict) -> dict:
    """
    Create a new contract.
    AUDITOR: 403.
    Validates cloud provider, validates participants exist and are active.
    Inserts contract + participants in one transaction.
    Fires audit logs and genesis blockchain block after commit.
    """
    role = current_user["system_role"]
    user_id = current_user["id"]

    if role == "AUDITOR":
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="AUDITOR no puede crear contratos",
        )

    # Validate cloud provider
    validation = validate_provider_for_contract(
        data.cloud_provider_id, data.contains_sensitive_data
    )
    if not validation["valid"]:
        audit_service.create_log(
            user_id, None, "ERROR_VALIDACION_PROVEEDOR", validation["message"]
        )
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=validation["message"],
        )

    # Validate all participant users exist and are active
    conn = get_connection()
    try:
        cursor = conn.cursor(dictionary=True)
        for p in data.participants:
            cursor.execute(
                "SELECT id, name, is_active FROM users WHERE id = %s",
                (p.user_id,),
            )
            user_row = cursor.fetchone()
            if not user_row:
                raise HTTPException(
                    status_code=status.HTTP_400_BAD_REQUEST,
                    detail=f"Usuario {p.user_id} no encontrado",
                )
            if not user_row["is_active"]:
                raise HTTPException(
                    status_code=status.HTTP_400_BAD_REQUEST,
                    detail=f"Usuario {p.user_id} no está activo",
                )
    finally:
        cursor.close()
        conn.close()

    # Write transaction
    conn = get_connection()
    try:
        conn.start_transaction()
        cursor = conn.cursor(dictionary=True)

        # 1. Insert contract
        cursor.execute(
            """
            INSERT INTO contracts
                (title, content, contains_sensitive_data, cloud_provider_id,
                 status, created_by_user_id)
            VALUES (%s, %s, %s, %s, 'BORRADOR', %s)
            """,
            (
                data.title,
                data.content,
                data.contains_sensitive_data,
                data.cloud_provider_id,
                user_id,
            ),
        )
        contract_id = cursor.lastrowid

        # 2. Insert participants
        for p in data.participants:
            cursor.execute(
                """
                INSERT INTO contract_participants
                    (contract_id, user_id, role_in_contract)
                VALUES (%s, %s, %s)
                """,
                (contract_id, p.user_id, p.role_in_contract.value),
            )

        conn.commit()
        cursor.close()

        # Fetch full detail (reuses same conn after commit)
        contract = _fetch_contract_detail(contract_id, conn)

    except HTTPException:
        conn.rollback()
        raise
    except Exception as exc:
        conn.rollback()
        logger.error("create_contract transaction error: %s", exc)
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Error al crear el contrato",
        )
    finally:
        conn.close()

    # Post-commit: audit logs (use their own connections)
    audit_service.create_log(user_id, contract_id, "CREACION_CONTRATO", data.title)
    for p in data.participants:
        audit_service.create_log(
            user_id, contract_id, "AGREGAR_PARTICIPANTE", str(p.user_id)
        )

    # Genesis blockchain block (own connection)
    genesis_data = json.dumps({
        "title": data.title,
        "participants": [
            {"user_id": p.user_id, "role_in_contract": p.role_in_contract.value}
            for p in data.participants
        ],
    })
    blockchain_service.create_block(contract_id, "GENESIS", genesis_data, user_id)

    return contract


def update_contract(contract_id: int, data: ContractUpdate, current_user: dict) -> dict:
    """
    Update an existing contract (BORRADOR only).
    AUDITOR: 403.
    Only ADMIN or creator can edit.
    No participant may have already signed.
    Re-validates provider if relevant fields change.
    """
    role = current_user["system_role"]
    user_id = current_user["id"]

    if role == "AUDITOR":
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="AUDITOR no puede editar contratos",
        )

    conn = get_connection()
    try:
        contract = _require_contract_exists(contract_id, conn)

        # Permission check: only ADMIN or creator
        if role != "ADMIN" and contract["created_by"]["id"] != user_id:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="Solo el creador o ADMIN puede editar este contrato",
            )

        # Status check
        if contract["status"] != "BORRADOR":
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Solo se pueden editar contratos en estado BORRADOR",
            )

        # No participant must have signed
        if any(p["has_signed"] for p in contract["participants"]):
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="No se puede editar un contrato que ya tiene participantes que han firmado",
            )

        # Determine effective values for provider validation
        effective_provider_id = (
            data.cloud_provider_id
            if data.cloud_provider_id is not None
            else contract["cloud_provider"]["id"]
        )
        effective_sensitive = (
            data.contains_sensitive_data
            if data.contains_sensitive_data is not None
            else contract["contains_sensitive_data"]
        )

        # Re-validate provider if either field changed
        provider_changed = (
            data.cloud_provider_id is not None
            or data.contains_sensitive_data is not None
        )
        if provider_changed:
            validation = validate_provider_for_contract(
                effective_provider_id, effective_sensitive
            )
            if not validation["valid"]:
                raise HTTPException(
                    status_code=status.HTTP_400_BAD_REQUEST,
                    detail=validation["message"],
                )

        # Validate new participants if provided
        if data.participants is not None:
            cursor_v = conn.cursor(dictionary=True)
            try:
                for p in data.participants:
                    cursor_v.execute(
                        "SELECT id, is_active FROM users WHERE id = %s", (p.user_id,)
                    )
                    user_row = cursor_v.fetchone()
                    if not user_row:
                        raise HTTPException(
                            status_code=status.HTTP_400_BAD_REQUEST,
                            detail=f"Usuario {p.user_id} no encontrado",
                        )
                    if not user_row["is_active"]:
                        raise HTTPException(
                            status_code=status.HTTP_400_BAD_REQUEST,
                            detail=f"Usuario {p.user_id} no está activo",
                        )
            finally:
                cursor_v.close()

        # Compute participant diff for audit BEFORE transaction
        old_participant_ids = {p["user_id"] for p in contract["participants"]}
        new_participant_ids = (
            {p.user_id for p in data.participants}
            if data.participants is not None
            else None
        )

        # Close the implicit read transaction before starting the write transaction
        conn.commit()
        conn.start_transaction()
        cursor = conn.cursor(dictionary=True)
        try:
            # Build dynamic SET clause
            fields: list = []
            params: list = []

            if data.title is not None:
                fields.append("title = %s")
                params.append(data.title)

            if data.content is not None:
                fields.append("content = %s")
                params.append(data.content)

            if data.contains_sensitive_data is not None:
                fields.append("contains_sensitive_data = %s")
                params.append(data.contains_sensitive_data)

            if data.cloud_provider_id is not None:
                fields.append("cloud_provider_id = %s")
                params.append(data.cloud_provider_id)

            if fields:
                params.append(contract_id)
                cursor.execute(
                    f"UPDATE contracts SET {', '.join(fields)} WHERE id = %s",
                    params,
                )

            # Update participants if provided
            added_ids: set = set()
            removed_ids: set = set()
            if data.participants is not None:
                added_ids = new_participant_ids - old_participant_ids
                removed_ids = old_participant_ids - new_participant_ids

                cursor.execute(
                    "DELETE FROM contract_participants WHERE contract_id = %s",
                    (contract_id,),
                )
                for p in data.participants:
                    cursor.execute(
                        """
                        INSERT INTO contract_participants
                            (contract_id, user_id, role_in_contract)
                        VALUES (%s, %s, %s)
                        """,
                        (contract_id, p.user_id, p.role_in_contract.value),
                    )

            conn.commit()
            cursor.close()

            # Refresh detail
            updated_contract = _fetch_contract_detail(contract_id, conn)

        except HTTPException:
            conn.rollback()
            raise
        except Exception as exc:
            conn.rollback()
            logger.error("update_contract transaction error: %s", exc)
            raise HTTPException(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                detail="Error al actualizar el contrato",
            )

    finally:
        conn.close()

    # Post-commit audit logs
    audit_service.create_log(user_id, contract_id, "EDICION_CONTRATO", contract["title"])
    for uid in added_ids:
        audit_service.create_log(user_id, contract_id, "AGREGAR_PARTICIPANTE", str(uid))
    for uid in removed_ids:
        audit_service.create_log(user_id, contract_id, "ELIMINAR_PARTICIPANTE", str(uid))

    return updated_contract


def sign_contract(contract_id: int, current_user: dict) -> dict:
    """
    Sign a contract as participant.
    AUDITOR: 403.
    User must be participant.
    Status must be BORRADOR.
    User must not have already signed.
    Re-validates that the provider is still active.
    If all participants have signed, transitions to FIRMADO.
    """
    role = current_user["system_role"]
    user_id = current_user["id"]

    if role == "AUDITOR":
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="AUDITOR no puede firmar contratos",
        )

    conn = get_connection()
    try:
        contract = _require_contract_exists(contract_id, conn)

        # User must be a participant
        participant = next(
            (p for p in contract["participants"] if p["user_id"] == user_id), None
        )
        if participant is None:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="No es participante de este contrato",
            )

        # Status must be BORRADOR
        if contract["status"] != "BORRADOR":
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Solo se pueden firmar contratos en estado BORRADOR",
            )

        # Must not have already signed
        if participant["has_signed"]:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Ya ha firmado este contrato",
            )

        # Re-validate provider is still active
        validation = validate_provider_for_contract(
            contract["cloud_provider"]["id"], contract["contains_sensitive_data"]
        )
        if not validation["valid"]:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail=validation["message"],
            )

        now_str = datetime.now(timezone.utc).strftime("%Y-%m-%d %H:%M:%S")

        # Close the implicit read transaction before starting the write transaction
        conn.commit()
        conn.start_transaction()
        cursor = conn.cursor(dictionary=True)
        try:
            # Mark participant as signed
            cursor.execute(
                """
                UPDATE contract_participants
                SET has_signed = TRUE, signed_at = %s
                WHERE contract_id = %s AND user_id = %s
                """,
                (now_str, contract_id, user_id),
            )

            # Check if all participants have now signed
            cursor.execute(
                """
                SELECT COUNT(*) AS total,
                       SUM(CASE WHEN has_signed = TRUE THEN 1 ELSE 0 END) AS signed_count
                FROM contract_participants
                WHERE contract_id = %s
                """,
                (contract_id,),
            )
            counts = cursor.fetchone()
            all_signed = int(counts["signed_count"] or 0) == int(counts["total"] or 0)

            if all_signed:
                cursor.execute(
                    "UPDATE contracts SET status = 'FIRMADO' WHERE id = %s",
                    (contract_id,),
                )

            conn.commit()
            cursor.close()

        except HTTPException:
            conn.rollback()
            raise
        except Exception as exc:
            conn.rollback()
            logger.error("sign_contract transaction error: %s", exc)
            raise HTTPException(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                detail="Error al firmar el contrato",
            )

    finally:
        conn.close()

    # Post-commit: audit log and blockchain block
    audit_service.create_log(user_id, contract_id, "FIRMA", str(user_id))
    sign_data = json.dumps({"user_id": user_id, "signed_at": now_str})
    blockchain_service.create_block(contract_id, "FIRMA", sign_data, user_id)

    # Fetch after blockchain block is written so the response includes it
    return _fetch_contract_detail_fresh(contract_id)


def validate_contract(contract_id: int, current_user: dict) -> dict:
    """
    Validate a contract (transition FIRMADO → VALIDADO).
    AUDITOR: 403.
    Only ADMIN or creator can validate.
    Status must be FIRMADO.
    All participants must have has_signed=True.
    """
    role = current_user["system_role"]
    user_id = current_user["id"]

    if role == "AUDITOR":
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="AUDITOR no puede validar contratos",
        )

    conn = get_connection()
    try:
        contract = _require_contract_exists(contract_id, conn)

        # Only ADMIN or creator
        if role != "ADMIN" and contract["created_by"]["id"] != user_id:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="Solo el creador o ADMIN puede validar este contrato",
            )

        # Status must be FIRMADO
        if contract["status"] != "FIRMADO":
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Solo se pueden validar contratos en estado FIRMADO",
            )

        # All participants must have signed
        unsigned = [p for p in contract["participants"] if not p["has_signed"]]
        if unsigned:
            unsigned_ids = [p["user_id"] for p in unsigned]
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail=f"Los siguientes participantes no han firmado: {unsigned_ids}",
            )

        now_str = datetime.now(timezone.utc).strftime("%Y-%m-%d %H:%M:%S")

        # Close the implicit read transaction before starting the write transaction
        conn.commit()
        conn.start_transaction()
        cursor = conn.cursor(dictionary=True)
        try:
            cursor.execute(
                "UPDATE contracts SET status = 'VALIDADO' WHERE id = %s",
                (contract_id,),
            )
            conn.commit()
            cursor.close()

        except HTTPException:
            conn.rollback()
            raise
        except Exception as exc:
            conn.rollback()
            logger.error("validate_contract transaction error: %s", exc)
            raise HTTPException(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                detail="Error al validar el contrato",
            )

    finally:
        conn.close()

    # Post-commit: audit log and blockchain block
    audit_service.create_log(user_id, contract_id, "VALIDACION", str(contract_id))
    validation_data = json.dumps({
        "contract_id": contract_id,
        "validated_by": user_id,
        "validated_at": now_str,
    })
    blockchain_service.create_block(contract_id, "VALIDACION", validation_data, user_id)

    # Fetch after blockchain block is written so the response includes it
    return _fetch_contract_detail_fresh(contract_id)
