# Modelo de base de datos — LegalContracts

Motor: MySQL 8 · Charset: utf8mb4 · Collation: utf8mb4_unicode_ci

---

## Tablas

### 1. `users`

Usuarios del sistema. El acceso a módulos depende de `system_role`.

| Campo | Tipo | Notas |
|-------|------|-------|
| id | INT PK AI | |
| name | VARCHAR(120) | |
| email | VARCHAR(160) UNIQUE | Usado como username de login |
| password_hash | VARCHAR(255) | bcrypt, nunca texto plano |
| system_role | ENUM | `ADMIN` `USUARIO` `AUDITOR` |
| is_active | BOOLEAN | FALSE = soft delete, no puede hacer login |
| created_at | TIMESTAMP | |
| updated_at | TIMESTAMP | Se actualiza automáticamente |

---

### 2. `cloud_providers`

Catálogo local de proveedores de nube. Sin integraciones reales ni API keys.

| Campo | Tipo | Notas |
|-------|------|-------|
| id | INT PK AI | |
| name | VARCHAR(120) | Nombre del proveedor |
| region | VARCHAR(120) | Región o datacenter |
| country | VARCHAR(120) | País de ubicación |
| allows_sensitive_data | BOOLEAN | Si cumple requisitos para datos sensibles |
| location_type | ENUM | `DENTRO_PAIS` `FUERA_PAIS` |
| is_active | BOOLEAN | Visible en el catálogo |
| created_at / updated_at | TIMESTAMP | |

**Regla de negocio:** Si un contrato tiene `contains_sensitive_data = TRUE` y el proveedor seleccionado tiene `allows_sensitive_data = FALSE`, el sistema debe emitir una alerta (ver mockup `07-alerta-proveedor.png`). El evento se registra en `audit_logs` como `ERROR_VALIDACION_PROVEEDOR`.

---

### 3. `contracts`

Contrato digital. Flujo de estado unidireccional: `BORRADOR → FIRMADO → VALIDADO`.

| Campo | Tipo | Notas |
|-------|------|-------|
| id | INT PK AI | |
| title | VARCHAR(180) | |
| content | TEXT | Cuerpo del contrato |
| status | ENUM | `BORRADOR` `FIRMADO` `VALIDADO` |
| contains_sensitive_data | BOOLEAN | Activa validación de proveedor |
| created_by_user_id | INT FK → users | |
| cloud_provider_id | INT FK → cloud_providers | |
| created_at / updated_at | TIMESTAMP | |

**Reglas:**
- Solo se puede editar en estado `BORRADOR`.
- La firma cambia el estado a `FIRMADO`.
- La validación cambia el estado a `VALIDADO`.
- El estado nunca retrocede.

---

### 4. `contract_participants`

Participantes de cada contrato. Un usuario no puede estar dos veces en el mismo contrato.

| Campo | Tipo | Notas |
|-------|------|-------|
| id | INT PK AI | |
| contract_id | INT FK → contracts | |
| user_id | INT FK → users | |
| role_in_contract | ENUM | `CLIENTE` `PROVEEDOR` `TESTIGO` |
| has_signed | BOOLEAN | TRUE cuando firmó |
| signed_at | TIMESTAMP NULL | Fecha/hora de firma simulada |
| created_at / updated_at | TIMESTAMP | |

**Restricción:** `UNIQUE (contract_id, user_id)` — un usuario solo puede tener un rol por contrato.

**Roles válidos únicamente:** `CLIENTE`, `PROVEEDOR`, `TESTIGO`. Nunca `ROL_FIRMANTE` ni `ROL_OBSERVADOR`.

---

### 5. `audit_logs`

Log inmutable de acciones del sistema. Solo escritura; sin endpoint de borrado.

| Campo | Tipo | Notas |
|-------|------|-------|
| id | INT PK AI | |
| user_id | INT FK NULL → users | NULL en acciones sin sesión |
| contract_id | INT FK NULL → contracts | NULL en acciones que no aplican |
| action_type | ENUM | Ver valores abajo |
| description | TEXT | Detalle legible de la acción |
| created_at | TIMESTAMP | Sin `updated_at` (registro inmutable) |

**Valores de `action_type`:**

| Valor | Cuándo se registra |
|-------|--------------------|
| `CREACION_CONTRATO` | Al crear un contrato |
| `AGREGAR_PARTICIPANTE` | Al añadir un participante |
| `ELIMINAR_PARTICIPANTE` | Al quitar un participante |
| `EDICION_CONTRATO` | Al editar un contrato en BORRADOR |
| `FIRMA` | Al firmar un contrato |
| `VALIDACION` | Al validar un contrato |
| `ERROR_VALIDACION_PROVEEDOR` | Cuando el proveedor no admite datos sensibles |
| `LOGIN` | Login exitoso o fallido |
| `LOGOUT` | Cierre de sesión |

**Acceso:** solo roles `ADMIN` y `AUDITOR`.

---

### 6. `blockchain_blocks`

Blockchain simulada en MySQL. No es blockchain real. Encadena hashes SHA-256.

| Campo | Tipo | Notas |
|-------|------|-------|
| id | INT PK AI | |
| contract_id | INT FK → contracts | |
| block_number | INT | Secuencial por contrato, empieza en 1 |
| event_type | ENUM | `GENESIS` `FIRMA` `VALIDACION` |
| data_json | JSON | Datos del evento serializado |
| previous_hash | VARCHAR(64) NULL | NULL solo en bloque GENESIS |
| hash | VARCHAR(64) | SHA-256 de `(previous_hash + event_type + data_json + created_at)` |
| created_by_user_id | INT FK → users | |
| created_at | TIMESTAMP | Sin `updated_at` (inmutable) |

**Restricciones:**
- `UNIQUE (contract_id, block_number)` — numeración sin huecos por contrato.
- `INDEX (hash)` — para verificación rápida de integridad.
- Los bloques no se editan ni eliminan.

**Secuencia por contrato:**
1. Bloque `GENESIS` al crear el contrato (`block_number = 1`, `previous_hash = NULL`).
2. Bloque `FIRMA` al firmar (`block_number = 2`).
3. Bloque `VALIDACION` al validar (`block_number = 3`).

---

## Diagrama de relaciones

```
users ─────────────────────────────────────────────────────────┐
  │                                                             │
  │ created_by_user_id                                          │ created_by_user_id
  ▼                                                             ▼
contracts ──────────────────────── blockchain_blocks
  │   │
  │   │ cloud_provider_id
  │   ▼
  │ cloud_providers
  │
  ├──► contract_participants ◄── users (user_id)
  │
  └──► audit_logs ◄── users (user_id)
```

---

## ENUMs por tabla

| Tabla | Campo | Valores |
|-------|-------|---------|
| users | system_role | `ADMIN` `USUARIO` `AUDITOR` |
| cloud_providers | location_type | `DENTRO_PAIS` `FUERA_PAIS` |
| contracts | status | `BORRADOR` `FIRMADO` `VALIDADO` |
| contract_participants | role_in_contract | `CLIENTE` `PROVEEDOR` `TESTIGO` |
| audit_logs | action_type | 9 valores (ver sección 5) |
| blockchain_blocks | event_type | `GENESIS` `FIRMA` `VALIDACION` |

---

## Reglas de integridad

1. Las contraseñas se almacenan únicamente como hash bcrypt. Nunca texto plano.
2. El borrado de usuarios es lógico (`is_active = FALSE`). Nunca físico.
3. Los proveedores de nube son catálogo local. Sin API keys ni almacenamiento real.
4. Los roles de participante son solo `CLIENTE`, `PROVEEDOR`, `TESTIGO`. Nunca `ROL_FIRMANTE` ni `ROL_OBSERVADOR`.
5. El estado de un contrato solo avanza: `BORRADOR → FIRMADO → VALIDADO`. Nunca retrocede.
6. `audit_logs` y `blockchain_blocks` son inmutables. No se editan ni eliminan.
7. Un usuario no puede tener más de un rol en el mismo contrato (`UNIQUE contract_id, user_id`).
8. El `block_number` dentro de un contrato es secuencial sin huecos (`UNIQUE contract_id, block_number`).
