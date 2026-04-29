-- LegalContracts - Datos iniciales (seed)
-- Se ejecuta después de init.sql.
-- Poblar con datos mínimos para desarrollo y pruebas.

USE legalcontracts_db;

-- -------------------------------------------------------
-- Usuario administrador inicial
-- Contraseña debe almacenarse con hash bcrypt
-- -------------------------------------------------------
-- INSERT INTO usuarios (nombre, correo, password_hash, rol, activo)
-- VALUES ('Admin Sistema', 'admin@legalcontracts.local', '<bcrypt_hash>', 'ADMIN', 1);

-- -------------------------------------------------------
-- Proveedores de nube (catálogo local)
-- -------------------------------------------------------
-- INSERT INTO proveedores_nube (nombre, descripcion, activo) VALUES
-- ('AWS', 'Amazon Web Services (simulado)', 1),
-- ('Azure', 'Microsoft Azure (simulado)', 1),
-- ('GCP', 'Google Cloud Platform (simulado)', 1);

-- -------------------------------------------------------
-- Configuración inicial del sistema
-- -------------------------------------------------------
-- INSERT INTO configuracion_sistema (clave, valor) VALUES
-- ('app_nombre', 'LegalContracts'),
-- ('app_version', '1.0.0');
