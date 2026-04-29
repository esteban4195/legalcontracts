from typing import Literal, Optional

from pydantic import BaseModel, EmailStr


VALID_ROLES = ("ADMIN", "USUARIO", "AUDITOR")


class UserPublicDetail(BaseModel):
    id: int
    name: str
    email: str
    system_role: str
    is_active: bool


class UserCreateRequest(BaseModel):
    name: str
    email: EmailStr
    password: str
    system_role: Literal["ADMIN", "USUARIO", "AUDITOR"]


class UserUpdateRequest(BaseModel):
    name: Optional[str] = None
    email: Optional[EmailStr] = None
    system_role: Optional[Literal["ADMIN", "USUARIO", "AUDITOR"]] = None


class ToggleActiveResponse(BaseModel):
    id: int
    is_active: bool
    message: str
