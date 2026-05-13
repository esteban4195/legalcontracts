from pydantic import BaseModel, field_validator
from typing import Optional, List
from datetime import datetime
from enum import Enum


class ContractStatus(str, Enum):
    BORRADOR = "BORRADOR"
    FIRMADO = "FIRMADO"
    VALIDADO = "VALIDADO"


class RoleInContract(str, Enum):
    CLIENTE = "CLIENTE"
    PROVEEDOR = "PROVEEDOR"
    TESTIGO = "TESTIGO"


class ParticipantIn(BaseModel):
    user_id: int
    role_in_contract: RoleInContract


class ContractCreate(BaseModel):
    title: str
    content: str
    contains_sensitive_data: bool = False
    cloud_provider_id: int
    participants: List[ParticipantIn]

    @field_validator('title')
    @classmethod
    def title_not_empty(cls, v):
        if not v or not v.strip():
            raise ValueError('title es requerido')
        return v.strip()

    @field_validator('content')
    @classmethod
    def content_not_empty(cls, v):
        if not v or not v.strip():
            raise ValueError('content es requerido')
        return v.strip()

    @field_validator('participants')
    @classmethod
    def min_two_participants(cls, v):
        if len(v) < 2:
            raise ValueError('Se requieren mínimo 2 participantes')
        ids = [p.user_id for p in v]
        if len(ids) != len(set(ids)):
            raise ValueError('Los participantes deben ser distintos')
        return v


class SignRequest(BaseModel):
    signature_image_base64: str

    @field_validator('signature_image_base64')
    @classmethod
    def signature_not_empty(cls, v):
        if not v or not v.strip():
            raise ValueError('La firma no puede estar vacía')
        return v.strip()


class ContractUpdate(BaseModel):
    title: Optional[str] = None
    content: Optional[str] = None
    contains_sensitive_data: Optional[bool] = None
    cloud_provider_id: Optional[int] = None
    participants: Optional[List[ParticipantIn]] = None

    @field_validator('participants')
    @classmethod
    def min_two_participants(cls, v):
        if v is not None:
            if len(v) < 2:
                raise ValueError('Se requieren mínimo 2 participantes')
            ids = [p.user_id for p in v]
            if len(ids) != len(set(ids)):
                raise ValueError('Los participantes deben ser distintos')
        return v
