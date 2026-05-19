from pydantic import BaseModel
from typing import Optional
from datetime import datetime


class AuditLogOut(BaseModel):
    id: int
    created_at: datetime
    action_type: str
    contract_id: Optional[int] = None
    user_id: int
    user_name: str
    description: str