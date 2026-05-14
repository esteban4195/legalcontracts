from pydantic import BaseModel
from typing import Optional
from datetime import datetime


class AuditLogOut(BaseModel):
    id: int
    fecha_hora: datetime
    action_type: str
    contract_id: Optional[int] = None
    user_id: int
    user_name: str
    description: Optional[str] = None