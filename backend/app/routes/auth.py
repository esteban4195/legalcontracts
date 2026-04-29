from fastapi import APIRouter, Depends, HTTPException, status

from app.auth.dependencies import get_current_user
from app.auth.jwt_handler import create_access_token
from app.auth.password_handler import verify_password
from app.database import get_connection
from app.schemas.auth_schema import (
    LoginRequest,
    LoginResponse,
    LogoutResponse,
    UserPublic,
)

router = APIRouter(prefix="/auth", tags=["auth"])


@router.post("/login", response_model=LoginResponse)
def login(body: LoginRequest):
    conn = get_connection()
    try:
        cursor = conn.cursor(dictionary=True)
        cursor.execute(
            "SELECT id, name, email, password_hash, system_role, is_active "
            "FROM users WHERE email = %s",
            (body.email,),
        )
        user = cursor.fetchone()
    finally:
        cursor.close()
        conn.close()

    if not user:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Credenciales incorrectas")

    if not user["is_active"]:
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Usuario inactivo")

    if not verify_password(body.password, user["password_hash"]):
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Credenciales incorrectas")

    token = create_access_token({"sub": str(user["id"])})

    return LoginResponse(
        access_token=token,
        user=UserPublic(
            id=user["id"],
            name=user["name"],
            email=user["email"],
            system_role=user["system_role"],
        ),
    )


@router.get("/me", response_model=UserPublic)
def me(current_user: dict = Depends(get_current_user)):
    return UserPublic(**current_user)


@router.post("/logout", response_model=LogoutResponse)
def logout(_: dict = Depends(get_current_user)):
    return LogoutResponse(message="Sesión cerrada correctamente")
