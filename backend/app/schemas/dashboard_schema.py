from pydantic import BaseModel
from typing import List

class Recent_Contract(BaseModel):
    id: int
    title: str
    status: str
    created_at: str  

class Dashboard_Summary(BaseModel):
    total_contracts: int
    draft_contracts: int
    signed_contracts: int
    validated_contracts: int
    active_users: int
    active_cloud_providers: int
    recent_contracts: List[Recent_Contract]
    