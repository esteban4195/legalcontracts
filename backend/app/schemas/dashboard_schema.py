from pydantic import BaseModel
from typing import List
from datetime import datetime

class RecentContract(BaseModel):
    id: int
    title: str
    status: str
    provider: str
    created_at: datetime

class MonthlyCount(BaseModel):
    month: int
    total: int

class RecentActivity(BaseModel):
    action_type: str
    description: str
    user_name: str
    contract_title: str
    created_at: datetime

class DashboardSummary(BaseModel):
    total_contracts: int
    draft_contracts: int
    signed_contracts: int
    validated_contracts: int
    active_users: int
    active_cloud_providers: int
    recent_contracts: List[RecentContract]
    contracts_by_month: List[MonthlyCount]
    recent_activity: List[RecentActivity]
