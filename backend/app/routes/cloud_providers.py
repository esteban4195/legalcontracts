from typing import List, Optional

from fastapi import APIRouter, Depends, HTTPException, Query, status

from app.auth.dependencies import get_current_user
from app.database import get_connection
from app.schemas.cloud_provider_schema import (
    CloudProviderCreateRequest,
    CloudProviderPublic,
    CloudProviderUpdateRequest,
    ToggleActiveResponse,
)

router = APIRouter(prefix="/cloud-providers", tags=["cloud-providers"])


def _require_admin(current_user: dict) -> None:
    if current_user["system_role"] != "ADMIN":
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Solo ADMIN puede realizar esta acción")


def _fetch_by_id(provider_id: int) -> Optional[dict]:
    conn = get_connection()
    try:
        cursor = conn.cursor(dictionary=True)
        cursor.execute(
            "SELECT id, name, region, country, allows_sensitive_data, location_type, is_active "
            "FROM cloud_providers WHERE id = %s",
            (provider_id,),
        )
        return cursor.fetchone()
    finally:
        cursor.close()
        conn.close()


# ---------------------------------------------------------------------------
# GET /cloud-providers
# ---------------------------------------------------------------------------

@router.get("", response_model=List[CloudProviderPublic])
def list_providers(
    is_active: Optional[bool] = Query(None, description="Filtrar por estado activo"),
    location_type: Optional[str] = Query(None, description="DENTRO_PAIS o FUERA_PAIS"),
    allows_sensitive_data: Optional[bool] = Query(None, description="Filtrar por permiso de datos sensibles"),
    current_user: dict = Depends(get_current_user),
):
    query = (
        "SELECT id, name, region, country, allows_sensitive_data, location_type, is_active "
        "FROM cloud_providers WHERE 1=1"
    )
    params: list = []

    if is_active is not None:
        query += " AND is_active = %s"
        params.append(is_active)

    if location_type is not None:
        query += " AND location_type = %s"
        params.append(location_type)

    if allows_sensitive_data is not None:
        query += " AND allows_sensitive_data = %s"
        params.append(allows_sensitive_data)

    query += " ORDER BY id ASC"

    conn = get_connection()
    try:
        cursor = conn.cursor(dictionary=True)
        cursor.execute(query, params)
        rows = cursor.fetchall()
    finally:
        cursor.close()
        conn.close()

    return [CloudProviderPublic(**r) for r in rows]


# ---------------------------------------------------------------------------
# GET /cloud-providers/{id}
# ---------------------------------------------------------------------------

@router.get("/{provider_id}", response_model=CloudProviderPublic)
def get_provider(provider_id: int, current_user: dict = Depends(get_current_user)):
    provider = _fetch_by_id(provider_id)
    if not provider:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Proveedor no encontrado")
    return CloudProviderPublic(**provider)


# ---------------------------------------------------------------------------
# POST /cloud-providers
# ---------------------------------------------------------------------------

@router.post("", response_model=CloudProviderPublic, status_code=status.HTTP_201_CREATED)
def create_provider(body: CloudProviderCreateRequest, current_user: dict = Depends(get_current_user)):
    _require_admin(current_user)

    conn = get_connection()
    try:
        cursor = conn.cursor(dictionary=True)

        cursor.execute("SELECT id FROM cloud_providers WHERE name = %s", (body.name,))
        if cursor.fetchone():
            raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Ya existe un proveedor con ese nombre")

        cursor.execute(
            "INSERT INTO cloud_providers (name, region, country, allows_sensitive_data, location_type, is_active) "
            "VALUES (%s, %s, %s, %s, %s, TRUE)",
            (body.name, body.region, body.country, body.allows_sensitive_data, body.location_type),
        )
        conn.commit()
        new_id = cursor.lastrowid

        cursor.execute(
            "SELECT id, name, region, country, allows_sensitive_data, location_type, is_active "
            "FROM cloud_providers WHERE id = %s",
            (new_id,),
        )
        created = cursor.fetchone()
    finally:
        cursor.close()
        conn.close()

    return CloudProviderPublic(**created)


# ---------------------------------------------------------------------------
# PUT /cloud-providers/{id}
# ---------------------------------------------------------------------------

@router.put("/{provider_id}", response_model=CloudProviderPublic)
def update_provider(provider_id: int, body: CloudProviderUpdateRequest, current_user: dict = Depends(get_current_user)):
    _require_admin(current_user)

    provider = _fetch_by_id(provider_id)
    if not provider:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Proveedor no encontrado")

    fields: list = []
    params: list = []

    if body.name is not None:
        conn = get_connection()
        try:
            cursor = conn.cursor(dictionary=True)
            cursor.execute(
                "SELECT id FROM cloud_providers WHERE name = %s AND id != %s",
                (body.name, provider_id),
            )
            if cursor.fetchone():
                raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Ya existe un proveedor con ese nombre")
        finally:
            cursor.close()
            conn.close()
        fields.append("name = %s")
        params.append(body.name)

    if body.region is not None:
        fields.append("region = %s")
        params.append(body.region)

    if body.country is not None:
        fields.append("country = %s")
        params.append(body.country)

    if body.allows_sensitive_data is not None:
        fields.append("allows_sensitive_data = %s")
        params.append(body.allows_sensitive_data)

    if body.location_type is not None:
        fields.append("location_type = %s")
        params.append(body.location_type)

    if not fields:
        return CloudProviderPublic(**provider)

    params.append(provider_id)
    conn = get_connection()
    try:
        cursor = conn.cursor(dictionary=True)
        cursor.execute(f"UPDATE cloud_providers SET {', '.join(fields)} WHERE id = %s", params)
        conn.commit()
        cursor.execute(
            "SELECT id, name, region, country, allows_sensitive_data, location_type, is_active "
            "FROM cloud_providers WHERE id = %s",
            (provider_id,),
        )
        updated = cursor.fetchone()
    finally:
        cursor.close()
        conn.close()

    return CloudProviderPublic(**updated)


# ---------------------------------------------------------------------------
# PATCH /cloud-providers/{id}/toggle-active
# ---------------------------------------------------------------------------

@router.patch("/{provider_id}/toggle-active", response_model=ToggleActiveResponse)
def toggle_active(provider_id: int, current_user: dict = Depends(get_current_user)):
    _require_admin(current_user)

    provider = _fetch_by_id(provider_id)
    if not provider:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Proveedor no encontrado")

    new_state = not provider["is_active"]

    conn = get_connection()
    try:
        cursor = conn.cursor()
        cursor.execute("UPDATE cloud_providers SET is_active = %s WHERE id = %s", (new_state, provider_id))
        conn.commit()
    finally:
        cursor.close()
        conn.close()

    action = "activado" if new_state else "desactivado"
    return ToggleActiveResponse(id=provider_id, is_active=new_state, message=f"Proveedor {action} correctamente")
