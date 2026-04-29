from app.database import get_connection


def validate_provider_for_contract(cloud_provider_id: int,
                                   contains_sensitive_data: bool) -> dict:
    """
    Returns {"valid": bool, "message": str, "provider": dict|None}
    """
    conn = get_connection()
    try:
        cursor = conn.cursor(dictionary=True)
        cursor.execute(
            "SELECT * FROM cloud_providers WHERE id = %s",
            (cloud_provider_id,),
        )
        provider = cursor.fetchone()
    finally:
        try:
            cursor.close()
            conn.close()
        except Exception:
            pass

    if not provider:
        return {
            "valid": False,
            "message": f"Proveedor {cloud_provider_id} no encontrado",
            "provider": None,
        }

    if not provider["is_active"]:
        return {
            "valid": False,
            "message": f"El proveedor '{provider['name']}' no está activo",
            "provider": provider,
        }

    if contains_sensitive_data:
        if not provider["allows_sensitive_data"]:
            return {
                "valid": False,
                "message": (
                    f"El proveedor '{provider['name']}' no permite datos sensibles"
                ),
                "provider": provider,
            }
        if provider["location_type"] != "DENTRO_PAIS":
            return {
                "valid": False,
                "message": (
                    f"El proveedor '{provider['name']}' debe estar dentro del país "
                    "para contratos con datos sensibles"
                ),
                "provider": provider,
            }

    return {"valid": True, "message": "Proveedor válido", "provider": provider}
