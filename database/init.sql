-- LegalContracts - Inicialización de base de datos
-- Este archivo se ejecuta automáticamente al levantar el contenedor MySQL.
-- La implementación completa de tablas se realizará por módulo.

CREATE DATABASE IF NOT EXISTS legalcontracts_db
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

USE legalcontracts_db;

-- -------------------------------------------------------
-- Tabla: usuarios
-- Roles: ADMIN, USUARIO, AUDITOR
-- -------------------------------------------------------
-- CREATE TABLE usuarios ( ... );

-- -------------------------------------------------------
-- Tabla: contratos
-- Estados: BORRADOR, FIRMADO, VALIDADO
-- -------------------------------------------------------
-- CREATE TABLE contratos ( ... );

-- -------------------------------------------------------
-- Tabla: participantes_contrato
-- Roles en contrato: CLIENTE, PROVEEDOR, TESTIGO
-- NOTA: NO usar ROL_FIRMANTE ni ROL_OBSERVADOR
-- -------------------------------------------------------
-- CREATE TABLE participantes_contrato ( ... );

-- -------------------------------------------------------
-- Tabla: firmas (simuladas, no criptográficas reales)
-- -------------------------------------------------------
-- CREATE TABLE firmas ( ... );

-- -------------------------------------------------------
-- Tabla: blockchain_simulada
-- Implementada en MySQL, no blockchain real
-- -------------------------------------------------------
-- CREATE TABLE blockchain_simulada ( ... );

-- -------------------------------------------------------
-- Tabla: auditoria
-- -------------------------------------------------------
-- CREATE TABLE auditoria ( ... );

-- -------------------------------------------------------
-- Tabla: proveedores_nube
-- Catálogo local, sin integraciones reales
-- -------------------------------------------------------
-- CREATE TABLE proveedores_nube ( ... );

-- -------------------------------------------------------
-- Tabla: configuracion_sistema
-- -------------------------------------------------------
-- CREATE TABLE configuracion_sistema ( ... );
