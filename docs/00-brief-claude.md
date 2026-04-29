# LegalContracts - Brief maestro para Claude

## Objetivo

Crear una aplicación web local universitaria llamada LegalContracts para gestionar contratos digitales con firma simulada, validación de proveedor de nube, auditoría y blockchain simulada.

## Stack obligatorio

- Frontend: Ionic + Angular
- Backend: Python + FastAPI
- Base de datos: MySQL 8
- Ejecución local: Docker + Docker Compose
- Consultas SQL directas, sin ORM
- Autenticación con JWT
- Diseño visual basado en los mockups ubicados en docs/mockups

## Regla principal

No implementar todo de una vez.

Primero se debe crear la estructura completa del repositorio, documentación, agentes de Claude y tareas delegables para el equipo.

## Carpetas de referencia visual

Los mockups oficiales están en:

docs/mockups

La nota de aprobación está en:

docs/mockups-aprobados.txt

## Alcance funcional

El sistema debe permitir:

- Login con correo y contraseña
- Dashboard
- Gestión de contratos
- Crear contrato
- Editar contrato
- Ver detalle de contrato
- Firmar contrato
- Validar contrato
- Ver blockchain del contrato
- Ver auditoría
- Gestionar usuarios
- Gestionar proveedores de nube
- Ver configuración del sistema

## Reglas clave

- La firma es simulada, no legal ni criptográfica real.
- La blockchain es simulada en MySQL, no blockchain real.
- Los proveedores de nube son catálogo local, no integraciones reales.
- No usar API keys de proveedores reales.
- No usar almacenamiento real en nube.
- No usar React, Vue, Tailwind ni ORM.
- No inventar funcionalidades fuera del alcance.

## Roles del sistema

- ADMIN
- USUARIO
- AUDITOR

## Roles dentro de un contrato

- CLIENTE
- PROVEEDOR
- TESTIGO

No usar ROL_FIRMANTE ni ROL_OBSERVADOR aunque aparezcan en algún mockup.

## Estados del contrato

- BORRADOR
- FIRMADO
- VALIDADO

## Próxima tarea para Claude

Crear la estructura completa del repositorio, Docker, documentación inicial, agentes y tareas delegables.