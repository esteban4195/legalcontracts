# LegalContracts

Aplicación web universitaria para gestión de contratos digitales con firma simulada, auditoría y blockchain simulada.

## Stack

| Capa | Tecnología |
|------|-----------|
| Frontend | Ionic + Angular 17 |
| Backend | Python + FastAPI |
| Base de datos | MySQL 8 |
| Infraestructura | Docker + Docker Compose |
| Autenticación | JWT |
| ORM | Ninguno — SQL directo |

## Estructura de carpetas

```
legalcontracts/
├── backend/                  # API FastAPI
│   └── app/
│       ├── auth/             # JWT y autenticación
│       ├── routes/           # Endpoints por módulo
│       ├── schemas/          # Modelos Pydantic (request/response)
│       ├── services/         # Lógica de negocio
│       └── utils/            # Utilidades compartidas
├── frontend/                 # App Ionic + Angular
│   └── src/app/
│       ├── guards/           # Guards de ruta (auth)
│       ├── interceptors/     # HTTP interceptors (token)
│       ├── layouts/          # Layouts compartidos
│       ├── pages/            # Páginas por módulo
│       └── services/         # Servicios HTTP
├── database/
│   ├── init.sql              # Creación de tablas
│   └── seed.sql              # Datos iniciales
├── docs/
│   ├── mockups/              # Mockups aprobados (PNG)
│   ├── mockups-aprobados.txt # Lista oficial de mockups
│   └── 00-brief-claude.md   # Brief maestro del proyecto
├── .claude/
│   ├── agents/               # Agentes Claude por área
│   └── tasks/                # Tareas delegables por módulo
├── docker-compose.yml
├── .env.example
└── .gitignore
```

## Cómo correr con Docker

1. Copia el archivo de variables de entorno:
   ```bash
   cp .env.example .env
   ```

2. Levanta todos los servicios:
   ```bash
   docker compose up --build
   ```

3. Para detener:
   ```bash
   docker compose down
   ```

4. Para detener y borrar la base de datos:
   ```bash
   docker compose down -v
   ```

## URLs locales

| Servicio | URL |
|----------|-----|
| Frontend | http://localhost:8100 |
| Backend API | http://localhost:8000 |
| Swagger / Docs | http://localhost:8000/docs |
| phpMyAdmin | http://localhost:8080 |

## Reglas principales del proyecto

- La firma es simulada (botón de confirmación), no firma digital legal real.
- La blockchain es simulada en MySQL, no blockchain real.
- Los proveedores de nube son catálogo local, sin API keys ni integraciones reales.
- No usar React, Vue, Tailwind ni ORM.
- Roles de sistema: `ADMIN`, `USUARIO`, `AUDITOR`.
- Roles en contrato: `CLIENTE`, `PROVEEDOR`, `TESTIGO`. Nunca `ROL_FIRMANTE` ni `ROL_OBSERVADOR`.
- Estados de contrato: `BORRADOR` → `FIRMADO` → `VALIDADO`.
- No inventar funcionalidades fuera del alcance definido en `docs/00-brief-claude.md`.

## Módulos funcionales

1. Login
2. Dashboard
3. Gestión de contratos (lista, crear, editar, detalle)
4. Firma de contrato (simulada)
5. Validación de contrato
6. Blockchain del contrato (simulada)
7. Auditoría
8. Gestión de usuarios
9. Gestión de proveedores de nube
10. Configuración del sistema
