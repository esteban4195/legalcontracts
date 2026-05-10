from fastapi import APIRouter, Depends, HTTPException, status
from app.auth.dependencies import get_current_user
from app.database import get_connection
from app.schemas.dashboard_schema import Dashboard_Summary

router = APIRouter(prefix="/dashboard", tags=["dashboard"])

@router.get("/summary", response_model=Dashboard_Summary)
def get_dashboard_summary(current_user: dict = Depends(get_current_user)):
    conn = get_connection()
    try:
        cursor = conn.cursor(dictionary=True)
        cursor.execute("""
            SELECT 
                (SELECT COUNT(*) FROM contracts) as total_contracts,
                (SELECT COUNT(*) FROM contracts WHERE status = 'draft') as draft_contracts,
                (SELECT COUNT(*) FROM contracts WHERE status = 'signed') as signed_contracts,
                (SELECT COUNT(*) FROM contracts WHERE status = 'validated') as validated_contracts,
                (SELECT COUNT(*) FROM users WHERE is_active = TRUE) as active_users,
                (SELECT COUNT(*) FROM cloud_providers WHERE is_active = TRUE) as active_cloud_providers
        """)
        metrics = cursor.fetchone()

        cursor.execute("""
            SELECT id, title, status, created_at
            FROM contracts
            ORDER BY created_at DESC
            LIMIT 5
        """)
        recent_rows = cursor.fetchall()
        
        return Dashboard_Summary(
            total_contracts=metrics.get("total_contracts") or 0,
            draft_contracts=metrics.get("draft_contracts") or 0,
            signed_contracts=metrics.get("signed_contracts") or 0,
            validated_contracts=metrics.get("validated_contracts") or 0,
            active_users=metrics.get("active_users") or 0,
            active_cloud_providers=metrics.get("active_cloud_providers") or 0,
            recent_contracts=[
                {
                    "id": r["id"],
                    "title": r["title"],
                    "status": r["status"],
                    "created_at": r["created_at"]
                } for r in recent_rows
            ]
        )
    finally:
        cursor.close()
        conn.close()