from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from app.routes import health
from app.routes import auth
from app.routes import users
from app.routes import cloud_providers
from app.routes import contracts
from app.routes import audit
from app.routes import dashboard

app = FastAPI(
    title="LegalContracts API",
    description="Backend para gestión de contratos digitales con firma simulada",
    version="1.0.0",
    swagger_ui_parameters={"persistAuthorization": True},
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=[
        "http://localhost:8100",
        "http://127.0.0.1:8100",
    ],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(health.router)
app.include_router(auth.router)
app.include_router(users.router)
app.include_router(cloud_providers.router)
app.include_router(contracts.router)
app.include_router(audit.router)
app.include_router(dashboard.router)
