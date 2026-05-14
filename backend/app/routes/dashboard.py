from fastapi import APIRouter, Depends, HTTPException, status
from app.auth.dependencies import get_current_user
from app.database import get_connection
from app.schemas.dashboard_schema import DashboardSummary, RecentContract, MonthlyCount, RecentActivity

router = APIRouter(prefix="/dashboard", tags=["dashboard"])
@router.get("/summary", response_model=DashboardSummary)
def get_dashboard_summary(current_user: dict = Depends(get_current_user)):
    role = current_user["system_role"]
    user_id = current_user["id"]
    is_usuario = role == "USUARIO"

    # Subquery para filtrar contratos visibles según el rol
    user_filter = """
        AND (
            c.created_by_user_id = %(uid)s
            OR EXISTS (
                SELECT 1 FROM contract_participants cp
                WHERE cp.contract_id = c.id AND cp.user_id = %(uid)s
            )
        )
    """ if is_usuario else ""

    conn = None
    cursor = None
    try:
        conn = get_connection()
        cursor = conn.cursor(dictionary=True)
        cursor.execute(f"""
            SELECT
                COUNT(*) as total_contracts,
                SUM(CASE WHEN c.status = 'BORRADOR'  THEN 1 ELSE 0 END) as draft_contracts,
                SUM(CASE WHEN c.status = 'FIRMADO'   THEN 1 ELSE 0 END) as signed_contracts,
                SUM(CASE WHEN c.status = 'VALIDADO'  THEN 1 ELSE 0 END) as validated_contracts,
                (SELECT COUNT(*) FROM users WHERE is_active = TRUE) as active_users,
                (SELECT COUNT(*) FROM cloud_providers WHERE is_active = TRUE) as active_cloud_providers
            FROM contracts c
            WHERE 1=1 {user_filter}
        """, {"uid": user_id})
        metrics = cursor.fetchone()

        cursor.execute(f"""
            SELECT c.id, c.title, c.status, c.created_at,
                   COALESCE(prov.name, '—') as provider
            FROM contracts c
            LEFT JOIN cloud_providers prov ON c.cloud_provider_id = prov.id
            WHERE 1=1 {user_filter}
            ORDER BY c.created_at DESC
            LIMIT 5
        """, {"uid": user_id})
        recent_rows = cursor.fetchall()

        cursor.execute(f"""
            SELECT MONTH(c.created_at) as month, COUNT(*) as total
            FROM contracts c
            WHERE YEAR(c.created_at) = YEAR(NOW()) {user_filter}
            GROUP BY MONTH(c.created_at)
            ORDER BY month
        """, {"uid": user_id})
        monthly_rows = cursor.fetchall()

        cursor.execute(f"""
            SELECT al.action_type, al.description, al.created_at,
                   COALESCE(u.name, 'Sistema') as user_name,
                   COALESCE(c.title, '-') as contract_title
            FROM audit_logs al
            LEFT JOIN users u ON al.user_id = u.id
            LEFT JOIN contracts c ON al.contract_id = c.id
            WHERE 1=1 {'AND al.user_id = %(uid)s' if is_usuario else ''}
            ORDER BY al.created_at DESC
            LIMIT 7
        """, {"uid": user_id})
        activity_rows = cursor.fetchall()

        return DashboardSummary(
            total_contracts=metrics.get("total_contracts") or 0,
            draft_contracts=metrics.get("draft_contracts") or 0,
            signed_contracts=metrics.get("signed_contracts") or 0,
            validated_contracts=metrics.get("validated_contracts") or 0,
            active_users=metrics.get("active_users") or 0,
            active_cloud_providers=metrics.get("active_cloud_providers") or 0,
            recent_contracts=[
                RecentContract(
                    id=r["id"],
                    title=r["title"],
                    status=r["status"],
                    provider=r["provider"],
                    created_at=r["created_at"]
                ) for r in recent_rows
            ],
            contracts_by_month=[
                MonthlyCount(month=r["month"], total=r["total"])
                for r in monthly_rows
            ],
            recent_activity=[
                RecentActivity(
                    action_type=r["action_type"],
                    description=r["description"],
                    user_name=r["user_name"],
                    contract_title=r["contract_title"],
                    created_at=r["created_at"]
                ) for r in activity_rows
            ]
        )
    finally:
        if cursor:
            cursor.close()
        if conn:
            conn.close()