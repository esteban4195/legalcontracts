import hashlib
import json
import logging
from datetime import datetime, timezone
from app.database import get_connection

logger = logging.getLogger(__name__)


def _compute_hash(contract_id: int, block_number: int, event_type: str,
                  data_json: str, previous_hash, created_at: str) -> str:
    payload = json.dumps({
        "contract_id": contract_id,
        "block_number": block_number,
        "event_type": event_type,
        "data_json": data_json,
        "previous_hash": previous_hash,
        "created_at": created_at,
    }, sort_keys=True)
    return hashlib.sha256(payload.encode("utf-8")).hexdigest()


def create_block(contract_id: int, event_type: str, data_json: str,
                 created_by_user_id: int, conn=None) -> dict:
    """
    Insert a new blockchain block for the given contract.
    If conn is supplied the caller owns the transaction; otherwise a new
    connection is opened and committed here.
    """
    own_conn = conn is None
    if own_conn:
        conn = get_connection()

    try:
        cursor = conn.cursor(dictionary=True)

        # Determine block_number and previous_hash
        cursor.execute(
            """
            SELECT block_number, hash
            FROM blockchain_blocks
            WHERE contract_id = %s
            ORDER BY block_number DESC
            LIMIT 1
            """,
            (contract_id,),
        )
        last = cursor.fetchone()
        block_number = (last["block_number"] + 1) if last else 1
        previous_hash = last["hash"] if last else None

        created_at = datetime.now(timezone.utc).strftime("%Y-%m-%d %H:%M:%S")
        block_hash = _compute_hash(
            contract_id, block_number, event_type, data_json, previous_hash, created_at
        )

        cursor.execute(
            """
            INSERT INTO blockchain_blocks
                (contract_id, block_number, event_type, data_json,
                 previous_hash, hash, created_by_user_id, created_at)
            VALUES (%s, %s, %s, %s, %s, %s, %s, %s)
            """,
            (contract_id, block_number, event_type, data_json,
             previous_hash, block_hash, created_by_user_id, created_at),
        )

        if own_conn:
            conn.commit()

        block = {
            "block_number": block_number,
            "event_type": event_type,
            "data_json": data_json,
            "previous_hash": previous_hash,
            "hash": block_hash,
            "created_at": created_at,
        }
        return block

    finally:
        try:
            cursor.close()
        except Exception:
            pass
        if own_conn:
            try:
                conn.close()
            except Exception:
                pass


def verify_contract_chain(contract_id: int) -> dict:
    """
    Re-compute the hash of every block and verify the chain integrity.
    Returns {"valid": bool, "blocks": int, "broken_at": block_number|None}
    """
    conn = get_connection()
    try:
        cursor = conn.cursor(dictionary=True)
        cursor.execute(
            """
            SELECT block_number, event_type, data_json, previous_hash, hash,
                   created_at
            FROM blockchain_blocks
            WHERE contract_id = %s
            ORDER BY block_number ASC
            """,
            (contract_id,),
        )
        blocks = cursor.fetchall()

        if not blocks:
            return {"valid": True, "blocks": 0, "broken_at": None}

        for block in blocks:
            expected = _compute_hash(
                contract_id,
                block["block_number"],
                block["event_type"],
                block["data_json"],
                block["previous_hash"],
                str(block["created_at"]),
            )
            if expected != block["hash"]:
                return {
                    "valid": False,
                    "blocks": len(blocks),
                    "broken_at": block["block_number"],
                }

        return {"valid": True, "blocks": len(blocks), "broken_at": None}

    finally:
        try:
            cursor.close()
            conn.close()
        except Exception:
            pass
