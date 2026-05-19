from typing import Optional
from datetime import date
from fastapi import APIRouter, Depends, HTTPException, Query, status
from app.auth.dependencies import get_current_user
from app.schemas.audit_schema import AuditLogOut
from app.database import get_connection

router = APIRouter(prefix="/audit-logs", tags=["Audit"])


@router.get(
    "",
    response_model=list[AuditLogOut],
    status_code=status.HTTP_200_OK,
    summary="Listar logs de auditoría",
    description=(
        "Retorna todos los logs de auditoría del sistema. "
        "Solo ADMIN y AUDITOR pueden ver los logs. "
        "USUARIO recibe 403. "
        "Acepta filtros opcionales: action_type, user_id, contract_id, date_from y date_to."
    ),
)
def list_audit_logs(
    action_type: Optional[str] = Query(None, description="Filtrar por tipo de acción"),
    contract_id: Optional[int] = Query(None, description="Filtrar por contrato"),
    user_id: Optional[int] = Query(None, description="Filtrar por usuario"),
    date_from: Optional[date] = Query(None, description="Fecha inicio (YYYY-MM-DD)"),
    date_to: Optional[date] = Query(None, description="Fecha fin (YYYY-MM-DD)"),
    current_user: dict = Depends(get_current_user),
):
    if current_user["system_role"] == "USUARIO":
        raise HTTPException(status_code=403, detail="No tienes permiso para ver los logs")

    conn = get_connection()
    cursor = conn.cursor(dictionary=True)

    query = """
        SELECT 
            al.id,
            al.created_at,
            al.action_type,
            al.contract_id,
            al.user_id,
            u.name AS user_name,
            al.description
        FROM audit_logs al
        JOIN users u ON al.user_id = u.id
        WHERE 1=1
    """
    params = []

    if action_type:
        query += " AND al.action_type = %s"
        params.append(action_type)

    if contract_id:
        query += " AND al.contract_id = %s"
        params.append(contract_id)

    if user_id:
        query += " AND al.user_id = %s"
        params.append(user_id)

    if date_from:
        query += " AND al.created_at >= %s"
        params.append(date_from)

    if date_to:
        query += " AND al.created_at <= %s"
        params.append(date_to)

    query += " ORDER BY al.created_at DESC"

    try:
        cursor.execute(query, params)
        logs = cursor.fetchall()
    finally:
        cursor.close()
        conn.close()

    return logs