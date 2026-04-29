SET NAMES utf8mb4;
SET character_set_client = utf8mb4;
SET character_set_connection = utf8mb4;
SET character_set_results = utf8mb4;

USE legalcontracts_db;

-- -------------------------------------------------------
-- Usuarios demo
-- Todos usan la contraseña: 12345678
-- Hashes generados con bcrypt, cost factor 12
-- -------------------------------------------------------
INSERT INTO users (name, email, password_hash, system_role, is_active) VALUES
(
  'Admin Demo',
  'admin@demo.com',
  -- bcrypt hash de: 12345678
  '$2b$12$1nznw7OVUzBh3Uc6tGFtIOFyI1OOJpElPf/WMdqdM/uvTvp41GIg.',
  'ADMIN',
  TRUE
),
(
  'Juan Pérez',
  'juan@demo.com',
  -- bcrypt hash de: 12345678
  '$2b$12$1nznw7OVUzBh3Uc6tGFtIOFyI1OOJpElPf/WMdqdM/uvTvp41GIg.',
  'USUARIO',
  TRUE
),
(
  'Ana Gómez',
  'ana@demo.com',
  -- bcrypt hash de: 12345678
  '$2b$12$1nznw7OVUzBh3Uc6tGFtIOFyI1OOJpElPf/WMdqdM/uvTvp41GIg.',
  'USUARIO',
  TRUE
),
(
  'Auditor Demo',
  'auditor@demo.com',
  -- bcrypt hash de: 12345678
  '$2b$12$1nznw7OVUzBh3Uc6tGFtIOFyI1OOJpElPf/WMdqdM/uvTvp41GIg.',
  'AUDITOR',
  TRUE
);

-- -------------------------------------------------------
-- Proveedores de nube (catálogo local, sin integraciones reales)
-- -------------------------------------------------------
INSERT INTO cloud_providers (name, region, country, allows_sensitive_data, location_type, is_active) VALUES
(
  'Azure Colombia',
  'Colombia',
  'Colombia',
  TRUE,
  'DENTRO_PAIS',
  TRUE
),
(
  'AWS USA',
  'us-east-1',
  'Estados Unidos',
  FALSE,
  'FUERA_PAIS',
  TRUE
),
(
  'Google Cloud Brasil',
  'southamerica-east1',
  'Brasil',
  TRUE,
  'FUERA_PAIS',
  TRUE
),
(
  'Nube Local Colombia',
  'Bogotá',
  'Colombia',
  TRUE,
  'DENTRO_PAIS',
  TRUE
);
