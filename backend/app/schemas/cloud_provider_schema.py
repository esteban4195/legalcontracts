from typing import Literal, Optional

from pydantic import BaseModel


class CloudProviderPublic(BaseModel):
    id: int
    name: str
    region: str
    country: str
    allows_sensitive_data: bool
    location_type: str
    is_active: bool


class CloudProviderCreateRequest(BaseModel):
    name: str
    region: str
    country: str
    allows_sensitive_data: bool
    location_type: Literal["DENTRO_PAIS", "FUERA_PAIS"]


class CloudProviderUpdateRequest(BaseModel):
    name: Optional[str] = None
    region: Optional[str] = None
    country: Optional[str] = None
    allows_sensitive_data: Optional[bool] = None
    location_type: Optional[Literal["DENTRO_PAIS", "FUERA_PAIS"]] = None


class ToggleActiveResponse(BaseModel):
    id: int
    is_active: bool
    message: str
