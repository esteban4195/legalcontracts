SET NAMES utf8mb4;
SET character_set_client = utf8mb4;
SET character_set_connection = utf8mb4;
SET character_set_results = utf8mb4;

CREATE DATABASE IF NOT EXISTS legalcontracts_db
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

USE legalcontracts_db;

-- -------------------------------------------------------
-- users
-- system_role: ADMIN | USUARIO | AUDITOR
-- -------------------------------------------------------
CREATE TABLE IF NOT EXISTS users (
  id              INT AUTO_INCREMENT PRIMARY KEY,
  name            VARCHAR(120)  NOT NULL,
  email           VARCHAR(160)  NOT NULL UNIQUE,
  password_hash   VARCHAR(255)  NOT NULL,
  system_role     ENUM('ADMIN','USUARIO','AUDITOR') NOT NULL,
  is_active       BOOLEAN       NOT NULL DEFAULT TRUE,
  created_at      TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at      TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- -------------------------------------------------------
-- cloud_providers
-- location_type: DENTRO_PAIS | FUERA_PAIS
-- -------------------------------------------------------
CREATE TABLE IF NOT EXISTS cloud_providers (
  id                    INT AUTO_INCREMENT PRIMARY KEY,
  name                  VARCHAR(120)  NOT NULL,
  region                VARCHAR(120)  NOT NULL,
  country               VARCHAR(120)  NOT NULL,
  allows_sensitive_data BOOLEAN       NOT NULL DEFAULT FALSE,
  location_type         ENUM('DENTRO_PAIS','FUERA_PAIS') NOT NULL,
  is_active             BOOLEAN       NOT NULL DEFAULT TRUE,
  created_at            TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at            TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- -------------------------------------------------------
-- contracts
-- status: BORRADOR → FIRMADO → VALIDADO (avance unidireccional)
-- -------------------------------------------------------
CREATE TABLE IF NOT EXISTS contracts (
  id                      INT AUTO_INCREMENT PRIMARY KEY,
  title                   VARCHAR(180)  NOT NULL,
  content                 TEXT          NOT NULL,
  status                  ENUM('BORRADOR','FIRMADO','VALIDADO') NOT NULL DEFAULT 'BORRADOR',
  contains_sensitive_data BOOLEAN       NOT NULL DEFAULT FALSE,
  created_by_user_id      INT           NOT NULL,
  cloud_provider_id       INT           NOT NULL,
  created_at              TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at              TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

  CONSTRAINT fk_contracts_user
    FOREIGN KEY (created_by_user_id) REFERENCES users(id),
  CONSTRAINT fk_contracts_provider
    FOREIGN KEY (cloud_provider_id) REFERENCES cloud_providers(id),

  INDEX idx_contracts_created_by  (created_by_user_id),
  INDEX idx_contracts_provider    (cloud_provider_id),
  INDEX idx_contracts_status      (status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- -------------------------------------------------------
-- contract_participants
-- role_in_contract: CLIENTE | PROVEEDOR | TESTIGO
-- Un usuario no puede repetirse en el mismo contrato (UNIQUE)
-- -------------------------------------------------------
CREATE TABLE IF NOT EXISTS contract_participants (
  id                INT AUTO_INCREMENT PRIMARY KEY,
  contract_id       INT           NOT NULL,
  user_id           INT           NOT NULL,
  role_in_contract  ENUM('CLIENTE','PROVEEDOR','TESTIGO') NOT NULL,
  has_signed        BOOLEAN       NOT NULL DEFAULT FALSE,
  signed_at         TIMESTAMP     NULL,
  created_at        TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at        TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

  CONSTRAINT fk_participants_contract
    FOREIGN KEY (contract_id) REFERENCES contracts(id),
  CONSTRAINT fk_participants_user
    FOREIGN KEY (user_id) REFERENCES users(id),

  -- Un usuario solo puede participar una vez por contrato
  UNIQUE KEY uq_participant_per_contract (contract_id, user_id),

  INDEX idx_participants_contract (contract_id),
  INDEX idx_participants_user     (user_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- -------------------------------------------------------
-- audit_logs
-- Registro inmutable de acciones funcionales del sistema
-- Solo registra eventos de contratos y validación de proveedores
-- -------------------------------------------------------
CREATE TABLE IF NOT EXISTS audit_logs (
  id           INT AUTO_INCREMENT PRIMARY KEY,
  user_id      INT  NULL,
  contract_id  INT  NULL,
  action_type  ENUM(
    'CREACION_CONTRATO',
    'AGREGAR_PARTICIPANTE',
    'ELIMINAR_PARTICIPANTE',
    'EDICION_CONTRATO',
    'FIRMA',
    'VALIDACION',
    'ERROR_VALIDACION_PROVEEDOR'
  ) NOT NULL,
  description  TEXT          NOT NULL,
  created_at   TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP,

  CONSTRAINT fk_audit_user
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE SET NULL,
  CONSTRAINT fk_audit_contract
    FOREIGN KEY (contract_id) REFERENCES contracts(id) ON DELETE SET NULL,

  INDEX idx_audit_user        (user_id),
  INDEX idx_audit_contract    (contract_id),
  INDEX idx_audit_action_type (action_type),
  INDEX idx_audit_created_at  (created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- -------------------------------------------------------
-- blockchain_blocks
-- Blockchain simulada en MySQL (no blockchain real)
-- Cada bloque encadena su hash con el hash del bloque anterior
-- block_number es único por contrato
-- -------------------------------------------------------
CREATE TABLE IF NOT EXISTS blockchain_blocks (
  id                  INT AUTO_INCREMENT PRIMARY KEY,
  contract_id         INT           NOT NULL,
  block_number        INT           NOT NULL,
  event_type          ENUM('GENESIS','FIRMA','VALIDACION') NOT NULL,
  data_json           JSON          NOT NULL,
  previous_hash       VARCHAR(64)   NULL,
  hash                VARCHAR(64)   NOT NULL,
  created_by_user_id  INT           NOT NULL,
  created_at          TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP,

  CONSTRAINT fk_blockchain_contract
    FOREIGN KEY (contract_id) REFERENCES contracts(id),
  CONSTRAINT fk_blockchain_user
    FOREIGN KEY (created_by_user_id) REFERENCES users(id),

  -- block_number único dentro de cada contrato
  UNIQUE KEY uq_block_per_contract (contract_id, block_number),

  INDEX idx_blockchain_contract (contract_id),
  INDEX idx_blockchain_hash     (hash)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
