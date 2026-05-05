import logging
from app.database import get_connection

logger = logging.getLogger(__name__)


def create_log(user_id: int, contract_id, action_type: str, description: str = "") -> None:
    """Insert an audit log entry for a contract or provider validation action."""
    try:
        conn = get_connection()
        cursor = conn.cursor()
        cursor.execute(
            """
            INSERT INTO audit_logs (user_id, contract_id, action_type, description)
            VALUES (%s, %s, %s, %s)
            """,
            (user_id, contract_id, action_type, description),
        )
        conn.commit()
    except Exception as exc:
        logger.error("audit_service.create_log error: %s", exc)
    finally:
        try:
            cursor.close()
            conn.close()
        except Exception:
            pass
