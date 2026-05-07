from typing import Optional

from fastapi import APIRouter, Depends, Query, status

from app.auth.dependencies import get_current_user
from app.schemas.contract_schema import ContractCreate, ContractUpdate, SignRequest
from app.services import contract_service

router = APIRouter(prefix="/contracts", tags=["Contracts"])


# ---------------------------------------------------------------------------
# GET /contracts
# ---------------------------------------------------------------------------

@router.get(
    "",
    status_code=status.HTTP_200_OK,
    summary="Listar contratos",
    description=(
        "Retorna la lista de contratos. "
        "ADMIN y AUDITOR ven todos; USUARIO solo ve los contratos en los que "
        "es creador o participante. "
        "Acepta filtros opcionales: status, title (búsqueda parcial) y cloud_provider_id."
    ),
)
def list_contracts(
    contract_status: Optional[str] = Query(
        None,
        alias="status",
        description="Filtrar por estado: BORRADOR | FIRMADO | VALIDADO",
    ),
    title: Optional[str] = Query(None, description="Búsqueda parcial por título"),
    cloud_provider_id: Optional[int] = Query(None, description="Filtrar por proveedor de nube"),
    current_user: dict = Depends(get_current_user),
):
    filters = {
        "status": contract_status,
        "title": title,
        "cloud_provider_id": cloud_provider_id,
    }
    return contract_service.get_contracts(current_user, filters)


# ---------------------------------------------------------------------------
# GET /contracts/{id}
# ---------------------------------------------------------------------------

@router.get(
    "/{contract_id}",
    status_code=status.HTTP_200_OK,
    summary="Obtener detalle de contrato",
    description=(
        "Retorna el detalle completo de un contrato: datos del contrato, "
        "creador, proveedor de nube, participantes (con estado de firma) y "
        "bloques de la blockchain simulada. "
        "USUARIO recibe 403 si no es creador ni participante."
    ),
)
def get_contract(
    contract_id: int,
    current_user: dict = Depends(get_current_user),
):
    return contract_service.get_contract_detail(contract_id, current_user)


# ---------------------------------------------------------------------------
# POST /contracts
# ---------------------------------------------------------------------------

@router.post(
    "",
    status_code=status.HTTP_201_CREATED,
    summary="Crear contrato",
    description=(
        "Crea un nuevo contrato en estado BORRADOR. "
        "Requiere al menos 2 participantes distintos. "
        "Valida que el proveedor de nube sea compatible con los datos del contrato. "
        "Solo ADMIN puede crear contratos."
    ),
)
def create_contract(
    body: ContractCreate,
    current_user: dict = Depends(get_current_user),
):
    return contract_service.create_contract(body, current_user)


# ---------------------------------------------------------------------------
# PUT /contracts/{id}
# ---------------------------------------------------------------------------

@router.put(
    "/{contract_id}",
    status_code=status.HTTP_200_OK,
    summary="Actualizar contrato",
    description=(
        "Actualiza un contrato existente. "
        "Solo contratos en estado BORRADOR pueden editarse. "
        "Ningún participante puede haber firmado. "
        "Solo el creador o un ADMIN pueden editar. "
        "AUDITOR no puede editar contratos."
    ),
)
def update_contract(
    contract_id: int,
    body: ContractUpdate,
    current_user: dict = Depends(get_current_user),
):
    return contract_service.update_contract(contract_id, body, current_user)


# ---------------------------------------------------------------------------
# POST /contracts/{id}/sign
# ---------------------------------------------------------------------------

@router.post(
    "/{contract_id}/sign",
    status_code=status.HTTP_200_OK,
    summary="Firmar contrato",
    description=(
        "El usuario autenticado firma el contrato como participante, guardando su firma. "
        "Solo contratos en estado BORRADOR pueden ser firmados. "
        "Cuando todos los participantes han firmado, el contrato pasa a FIRMADO. "
        "AUDITOR no puede firmar contratos."
    ),
)
def sign_contract(
    contract_id: int,
    body: SignRequest,
    current_user: dict = Depends(get_current_user),
):
    return contract_service.sign_contract(contract_id, body, current_user)


@router.put(
    "/{contract_id}/sign",
    status_code=status.HTTP_200_OK,
    summary="Actualizar firma",
    description=(
        "Reemplaza la imagen de firma del usuario en un contrato ya firmado. "
        "Solo permitido mientras el contrato NO esté en estado VALIDADO. "
        "AUDITOR no puede modificar firmas."
    ),
)
def update_signature(
    contract_id: int,
    body: SignRequest,
    current_user: dict = Depends(get_current_user),
):
    return contract_service.update_signature(contract_id, body, current_user)


# ---------------------------------------------------------------------------
# POST /contracts/{id}/validate
# ---------------------------------------------------------------------------

@router.post(
    "/{contract_id}/validate",
    status_code=status.HTTP_200_OK,
    summary="Validar contrato",
    description=(
        "Transiciona un contrato de FIRMADO a VALIDADO. "
        "Todos los participantes deben haber firmado. "
        "Solo el creador o un ADMIN pueden validar. "
        "AUDITOR no puede validar contratos."
    ),
)
def validate_contract(
    contract_id: int,
    current_user: dict = Depends(get_current_user),
):
    return contract_service.validate_contract(contract_id, current_user)
