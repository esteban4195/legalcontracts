from pydantic import BaseModel
from typing import List

class RecentContract(BaseModel):
    id: int
    title: str
    status: str
    created_at: str  

class DashboardSummary(BaseModel):
    total_contracts: int
    draft_contracts: int
    signed_contracts: int
    validated_contracts: int
    active_users: int
    active_cloud_providers: int
    recent_contracts: List[RecentContract]
    