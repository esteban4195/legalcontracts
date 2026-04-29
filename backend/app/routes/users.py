from typing import List, Optional

import bcrypt
from fastapi import APIRouter, Depends, HTTPException, Query, status

from app.auth.dependencies import get_current_user
from app.database import get_connection
from app.schemas.user_schema import (
    ToggleActiveResponse,
    UserCreateRequest,
    UserPublicDetail,
    UserUpdateRequest,
)

router = APIRouter(prefix="/users", tags=["users"])


def _require_admin(current_user: dict) -> None:
    if current_user["system_role"] != "ADMIN":
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Solo ADMIN puede realizar esta acción")


def _fetch_user_by_id(user_id: int) -> Optional[dict]:
    conn = get_connection()
    try:
        cursor = conn.cursor(dictionary=True)
        cursor.execute(
            "SELECT id, name, email, system_role, is_active FROM users WHERE id = %s",
            (user_id,),
        )
        return cursor.fetchone()
    finally:
        cursor.close()
        conn.close()


# ---------------------------------------------------------------------------
# GET /users
# ---------------------------------------------------------------------------

@router.get("", response_model=List[UserPublicDetail])
def list_users(
    system_role: Optional[str] = Query(None, description="Filtrar por rol: ADMIN, USUARIO, AUDITOR"),
    is_active: Optional[bool] = Query(None, description="Filtrar por estado activo"),
    current_user: dict = Depends(get_current_user),
):
    role = current_user["system_role"]

    # USUARIO solo puede verse a sí mismo
    if role == "USUARIO":
        return [UserPublicDetail(**current_user)]

    # ADMIN y AUDITOR ven todos, con filtros opcionales
    query = "SELECT id, name, email, system_role, is_active FROM users WHERE 1=1"
    params: list = []

    if system_role is not None:
        query += " AND system_role = %s"
        params.append(system_role)

    if is_active is not None:
        query += " AND is_active = %s"
        params.append(is_active)

    query += " ORDER BY id ASC"

    conn = get_connection()
    try:
        cursor = conn.cursor(dictionary=True)
        cursor.execute(query, params)
        rows = cursor.fetchall()
    finally:
        cursor.close()
        conn.close()

    return [UserPublicDetail(**r) for r in rows]


# ---------------------------------------------------------------------------
# GET /users/{id}
# ---------------------------------------------------------------------------

@router.get("/{user_id}", response_model=UserPublicDetail)
def get_user(user_id: int, current_user: dict = Depends(get_current_user)):
    role = current_user["system_role"]

    # USUARIO solo puede consultar su propio perfil
    if role == "USUARIO" and current_user["id"] != user_id:
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="No tiene permiso para ver este usuario")

    user = _fetch_user_by_id(user_id)
    if not user:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Usuario no encontrado")

    return UserPublicDetail(**user)


# ---------------------------------------------------------------------------
# POST /users
# ---------------------------------------------------------------------------

@router.post("", response_model=UserPublicDetail, status_code=status.HTTP_201_CREATED)
def create_user(body: UserCreateRequest, current_user: dict = Depends(get_current_user)):
    _require_admin(current_user)

    password_hash = bcrypt.hashpw(body.password.encode("utf-8"), bcrypt.gensalt()).decode("utf-8")

    conn = get_connection()
    try:
        cursor = conn.cursor(dictionary=True)

        cursor.execute("SELECT id FROM users WHERE email = %s", (body.email,))
        if cursor.fetchone():
            raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="El email ya está registrado")

        cursor.execute(
            "INSERT INTO users (name, email, password_hash, system_role, is_active) VALUES (%s, %s, %s, %s, TRUE)",
            (body.name, body.email, password_hash, body.system_role),
        )
        conn.commit()
        new_id = cursor.lastrowid

        cursor.execute(
            "SELECT id, name, email, system_role, is_active FROM users WHERE id = %s",
            (new_id,),
        )
        created = cursor.fetchone()
    finally:
        cursor.close()
        conn.close()

    return UserPublicDetail(**created)


# ---------------------------------------------------------------------------
# PUT /users/{id}
# ---------------------------------------------------------------------------

@router.put("/{user_id}", response_model=UserPublicDetail)
def update_user(user_id: int, body: UserUpdateRequest, current_user: dict = Depends(get_current_user)):
    _require_admin(current_user)

    user = _fetch_user_by_id(user_id)
    if not user:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Usuario no encontrado")

    # Construir SET dinámico solo con campos enviados
    fields: list = []
    params: list = []

    if body.name is not None:
        fields.append("name = %s")
        params.append(body.name)

    if body.email is not None:
        conn = get_connection()
        try:
            cursor = conn.cursor(dictionary=True)
            cursor.execute("SELECT id FROM users WHERE email = %s AND id != %s", (body.email, user_id))
            if cursor.fetchone():
                raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="El email ya está en uso")
        finally:
            cursor.close()
            conn.close()
        fields.append("email = %s")
        params.append(body.email)

    if body.system_role is not None:
        fields.append("system_role = %s")
        params.append(body.system_role)

    if not fields:
        # Nada que actualizar: devolver usuario sin tocar la BD
        return UserPublicDetail(**user)

    params.append(user_id)
    conn = get_connection()
    try:
        cursor = conn.cursor(dictionary=True)
        cursor.execute(f"UPDATE users SET {', '.join(fields)} WHERE id = %s", params)
        conn.commit()
        cursor.execute(
            "SELECT id, name, email, system_role, is_active FROM users WHERE id = %s",
            (user_id,),
        )
        updated = cursor.fetchone()
    finally:
        cursor.close()
        conn.close()

    return UserPublicDetail(**updated)


# ---------------------------------------------------------------------------
# PATCH /users/{id}/toggle-active
# ---------------------------------------------------------------------------

@router.patch("/{user_id}/toggle-active", response_model=ToggleActiveResponse)
def toggle_active(user_id: int, current_user: dict = Depends(get_current_user)):
    _require_admin(current_user)

    if current_user["id"] == user_id:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Un ADMIN no puede desactivarse a sí mismo",
        )

    user = _fetch_user_by_id(user_id)
    if not user:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Usuario no encontrado")

    new_state = not user["is_active"]

    conn = get_connection()
    try:
        cursor = conn.cursor()
        cursor.execute("UPDATE users SET is_active = %s WHERE id = %s", (new_state, user_id))
        conn.commit()
    finally:
        cursor.close()
        conn.close()

    action = "activado" if new_state else "desactivado"
    return ToggleActiveResponse(
        id=user_id,
        is_active=new_state,
        message=f"Usuario {action} correctamente",
    )
