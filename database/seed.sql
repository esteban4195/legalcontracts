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

-- -------------------------------------------------------
-- Contratos demo (40 contratos, enero–mayo 2026)
-- Participantes: usuario 1 (CLIENTE) y usuario 2 o 3 (PROVEEDOR)
-- Estados distribuidos: BORRADOR, FIRMADO, VALIDADO
-- -------------------------------------------------------

INSERT INTO contracts (id, title, content, status, contains_sensitive_data, created_by_user_id, cloud_provider_id, created_at, updated_at) VALUES
(2,  'Contrato de Servicios TI',            'Prestación de servicios de infraestructura TI.',         'VALIDADO', 0, 1, 1, '2026-01-05 09:00:00', '2026-01-10 11:00:00'),
(3,  'Acuerdo de Confidencialidad',          'NDA entre las partes para proyectos conjuntos.',          'VALIDADO', 1, 1, 2, '2026-01-12 10:00:00', '2026-01-18 14:00:00'),
(4,  'Contrato de Consultoría',              'Servicios de consultoría estratégica.',                   'FIRMADO',  0, 1, 3, '2026-01-20 08:30:00', '2026-01-22 09:00:00'),
(5,  'Licencia de Software',                 'Licencia de uso de plataforma SaaS.',                     'BORRADOR', 0, 1, 4, '2026-01-25 11:00:00', '2026-01-25 11:00:00'),
(6,  'Contrato de Mantenimiento',            'Mantenimiento preventivo y correctivo de sistemas.',      'VALIDADO', 0, 2, 1, '2026-01-28 15:00:00', '2026-02-03 10:00:00'),
(7,  'Acuerdo de Nivel de Servicio',         'SLA para plataforma de pagos.',                           'BORRADOR', 1, 2, 2, '2026-02-02 09:00:00', '2026-02-02 09:00:00'),
(8,  'Contrato de Desarrollo Web',           'Desarrollo de portal corporativo.',                       'FIRMADO',  0, 1, 3, '2026-02-06 10:00:00', '2026-02-08 12:00:00'),
(9,  'Contrato de Outsourcing',              'Tercerización de procesos administrativos.',              'VALIDADO', 1, 1, 4, '2026-02-10 08:00:00', '2026-02-15 16:00:00'),
(10, 'Acuerdo Marco de Servicios',           'Marco general para servicios profesionales.',             'BORRADOR', 0, 2, 1, '2026-02-14 11:00:00', '2026-02-14 11:00:00'),
(11, 'Contrato de Soporte Técnico',          'Soporte técnico especializado nivel 2 y 3.',              'FIRMADO',  0, 1, 2, '2026-02-18 09:30:00', '2026-02-20 10:00:00'),
(12, 'Contrato de Almacenamiento Cloud',     'Almacenamiento de datos en nube privada.',                'VALIDADO', 1, 1, 3, '2026-02-22 14:00:00', '2026-02-27 11:00:00'),
(13, 'Contrato de Auditoría Externa',        'Auditoría de sistemas y procesos internos.',              'BORRADOR', 0, 2, 4, '2026-02-25 10:00:00', '2026-02-25 10:00:00'),
(14, 'Contrato de Integración API',          'Integración de APIs con sistemas legacy.',                'FIRMADO',  0, 1, 1, '2026-03-03 09:00:00', '2026-03-05 14:00:00'),
(15, 'Acuerdo de Transferencia de Datos',    'Transferencia internacional de datos personales.',        'VALIDADO', 1, 1, 2, '2026-03-07 11:00:00', '2026-03-12 15:00:00'),
(16, 'Contrato de Capacitación',             'Programa de formación en ciberseguridad.',                'BORRADOR', 0, 2, 3, '2026-03-10 08:00:00', '2026-03-10 08:00:00'),
(17, 'Contrato de Migración Cloud',          'Migración de infraestructura on-premise a nube.',         'FIRMADO',  1, 1, 4, '2026-03-14 10:00:00', '2026-03-16 12:00:00'),
(18, 'Contrato de Backup y Recuperación',    'Servicio de respaldo y recuperación ante desastres.',     'VALIDADO', 0, 1, 1, '2026-03-18 09:00:00', '2026-03-24 10:00:00'),
(19, 'Contrato de Seguridad Perimetral',     'Implementación de firewall y monitoreo de red.',          'BORRADOR', 1, 2, 2, '2026-03-20 11:00:00', '2026-03-20 11:00:00'),
(20, 'Acuerdo de Co-Desarrollo',             'Desarrollo conjunto de módulo de inteligencia artificial.','FIRMADO', 0, 1, 3, '2026-03-24 08:30:00', '2026-03-26 09:00:00'),
(21, 'Contrato de Análisis de Datos',        'Análisis avanzado de datos para toma de decisiones.',    'VALIDADO', 1, 1, 4, '2026-03-27 10:00:00', '2026-04-02 14:00:00'),
(22, 'Contrato de Monitoreo 24/7',           'Monitoreo continuo de infraestructura crítica.',          'BORRADOR', 0, 2, 1, '2026-04-01 09:00:00', '2026-04-01 09:00:00'),
(23, 'Contrato de Gestión de Identidades',   'Implementación de solución IAM corporativa.',             'FIRMADO',  1, 1, 2, '2026-04-04 11:00:00', '2026-04-06 13:00:00'),
(24, 'Acuerdo de Pruebas de Penetración',    'Ethical hacking y reporte de vulnerabilidades.',          'VALIDADO', 0, 1, 3, '2026-04-07 08:00:00', '2026-04-11 16:00:00'),
(25, 'Contrato de DevOps Gestionado',        'Gestión de pipelines CI/CD y despliegues.',               'BORRADOR', 0, 2, 4, '2026-04-10 10:00:00', '2026-04-10 10:00:00'),
(26, 'Contrato de Virtualización',           'Virtualización de servidores físicos.',                   'FIRMADO',  0, 1, 1, '2026-04-14 09:30:00', '2026-04-16 11:00:00'),
(27, 'Contrato de Mensajería Empresarial',   'Plataforma de comunicaciones unificadas.',                'VALIDADO', 0, 1, 2, '2026-04-17 11:00:00', '2026-04-22 14:00:00'),
(28, 'Acuerdo de Gestión de Incidentes',     'Protocolo de respuesta ante incidentes de seguridad.',   'BORRADOR', 1, 2, 3, '2026-04-21 08:00:00', '2026-04-21 08:00:00'),
(29, 'Contrato de Recuperación de Datos',    'Recuperación forense de datos perdidos.',                 'FIRMADO',  1, 1, 4, '2026-04-24 10:00:00', '2026-04-26 12:00:00'),
(30, 'Contrato de Automatización RPA',       'Automatización de procesos con RPA.',                     'VALIDADO', 0, 1, 1, '2026-04-28 09:00:00', '2026-05-02 10:00:00'),
(31, 'Acuerdo de Licenciamiento Masivo',     'Licenciamiento de suite ofimática para 500 usuarios.',   'BORRADOR', 0, 2, 2, '2026-05-02 11:00:00', '2026-05-02 11:00:00'),
(32, 'Contrato de Red WAN',                  'Gestión de red de área amplia entre sedes.',              'FIRMADO',  0, 1, 3, '2026-05-04 09:00:00', '2026-05-06 11:00:00'),
(33, 'Contrato de Cumplimiento Normativo',   'Asesoría en cumplimiento de regulaciones de datos.',     'VALIDADO', 1, 1, 4, '2026-05-05 08:30:00', '2026-05-09 14:00:00'),
(34, 'Contrato de Hosting Dedicado',         'Servidor dedicado para plataforma de e-commerce.',       'BORRADOR', 0, 2, 1, '2026-05-06 10:00:00', '2026-05-06 10:00:00'),
(35, 'Acuerdo de Teletrabajo Seguro',        'Infraestructura VPN y acceso remoto seguro.',             'FIRMADO',  0, 1, 2, '2026-05-07 09:00:00', '2026-05-08 12:00:00'),
(36, 'Contrato de Digitalización',           'Digitalización de archivo físico institucional.',         'VALIDADO', 0, 1, 3, '2026-05-08 11:00:00', '2026-05-09 15:00:00'),
(37, 'Contrato de BI y Reportería',          'Implementación de tableros de inteligencia de negocio.',  'BORRADOR', 0, 2, 4, '2026-05-09 08:00:00', '2026-05-09 08:00:00'),
(38, 'Contrato de Gestión Documental',       'Sistema de gestión electrónica de documentos.',           'FIRMADO',  1, 1, 1, '2026-05-09 10:00:00', '2026-05-10 13:00:00'),
(39, 'Acuerdo de Continuidad de Negocio',    'Plan de continuidad y recuperación ante desastres.',     'BORRADOR', 0, 2, 2, '2026-05-10 09:00:00', '2026-05-10 09:00:00'),
(40, 'Contrato de IoT Industrial',           'Conectividad y gestión de dispositivos IoT.',             'FIRMADO',  0, 1, 3, '2026-05-10 11:00:00', '2026-05-11 14:00:00'),
(41, 'Contrato de Blockchain Privada',       'Implementación de red blockchain privada.',               'BORRADOR', 1, 1, 4, '2026-05-10 14:00:00', '2026-05-10 14:00:00');

-- -------------------------------------------------------
-- Participantes: cada contrato tiene usuario 1 (CLIENTE) y usuario 2 o 3 (PROVEEDOR)
-- Contratos FIRMADO y VALIDADO tienen has_signed = 1
-- -------------------------------------------------------

INSERT INTO contract_participants (contract_id, user_id, role_in_contract, has_signed, signed_at, created_at, updated_at) VALUES
-- Contrato 2 VALIDADO
(2,  1, 'CLIENTE',   1, '2026-01-08 10:00:00', '2026-01-05 09:00:00', '2026-01-08 10:00:00'),
(2,  2, 'PROVEEDOR', 1, '2026-01-09 11:00:00', '2026-01-05 09:00:00', '2026-01-09 11:00:00'),
-- Contrato 3 VALIDADO
(3,  1, 'CLIENTE',   1, '2026-01-15 10:00:00', '2026-01-12 10:00:00', '2026-01-15 10:00:00'),
(3,  3, 'PROVEEDOR', 1, '2026-01-16 14:00:00', '2026-01-12 10:00:00', '2026-01-16 14:00:00'),
-- Contrato 4 FIRMADO
(4,  1, 'CLIENTE',   1, '2026-01-21 09:00:00', '2026-01-20 08:30:00', '2026-01-21 09:00:00'),
(4,  2, 'PROVEEDOR', 1, '2026-01-22 09:00:00', '2026-01-20 08:30:00', '2026-01-22 09:00:00'),
-- Contrato 5 BORRADOR
(5,  1, 'CLIENTE',   0, NULL, '2026-01-25 11:00:00', '2026-01-25 11:00:00'),
(5,  2, 'PROVEEDOR', 0, NULL, '2026-01-25 11:00:00', '2026-01-25 11:00:00'),
-- Contrato 6 VALIDADO
(6,  2, 'CLIENTE',   1, '2026-01-30 09:00:00', '2026-01-28 15:00:00', '2026-01-30 09:00:00'),
(6,  3, 'PROVEEDOR', 1, '2026-01-31 10:00:00', '2026-01-28 15:00:00', '2026-01-31 10:00:00'),
-- Contrato 7 BORRADOR
(7,  2, 'CLIENTE',   0, NULL, '2026-02-02 09:00:00', '2026-02-02 09:00:00'),
(7,  3, 'PROVEEDOR', 0, NULL, '2026-02-02 09:00:00', '2026-02-02 09:00:00'),
-- Contrato 8 FIRMADO
(8,  1, 'CLIENTE',   1, '2026-02-07 10:00:00', '2026-02-06 10:00:00', '2026-02-07 10:00:00'),
(8,  3, 'PROVEEDOR', 1, '2026-02-08 12:00:00', '2026-02-06 10:00:00', '2026-02-08 12:00:00'),
-- Contrato 9 VALIDADO
(9,  1, 'CLIENTE',   1, '2026-02-12 08:00:00', '2026-02-10 08:00:00', '2026-02-12 08:00:00'),
(9,  2, 'PROVEEDOR', 1, '2026-02-13 10:00:00', '2026-02-10 08:00:00', '2026-02-13 10:00:00'),
-- Contrato 10 BORRADOR
(10, 2, 'CLIENTE',   0, NULL, '2026-02-14 11:00:00', '2026-02-14 11:00:00'),
(10, 3, 'PROVEEDOR', 0, NULL, '2026-02-14 11:00:00', '2026-02-14 11:00:00'),
-- Contrato 11 FIRMADO
(11, 1, 'CLIENTE',   1, '2026-02-19 09:30:00', '2026-02-18 09:30:00', '2026-02-19 09:30:00'),
(11, 2, 'PROVEEDOR', 1, '2026-02-20 10:00:00', '2026-02-18 09:30:00', '2026-02-20 10:00:00'),
-- Contrato 12 VALIDADO
(12, 1, 'CLIENTE',   1, '2026-02-24 14:00:00', '2026-02-22 14:00:00', '2026-02-24 14:00:00'),
(12, 3, 'PROVEEDOR', 1, '2026-02-25 11:00:00', '2026-02-22 14:00:00', '2026-02-25 11:00:00'),
-- Contrato 13 BORRADOR
(13, 2, 'CLIENTE',   0, NULL, '2026-02-25 10:00:00', '2026-02-25 10:00:00'),
(13, 3, 'PROVEEDOR', 0, NULL, '2026-02-25 10:00:00', '2026-02-25 10:00:00'),
-- Contrato 14 FIRMADO
(14, 1, 'CLIENTE',   1, '2026-03-04 09:00:00', '2026-03-03 09:00:00', '2026-03-04 09:00:00'),
(14, 2, 'PROVEEDOR', 1, '2026-03-05 14:00:00', '2026-03-03 09:00:00', '2026-03-05 14:00:00'),
-- Contrato 15 VALIDADO
(15, 1, 'CLIENTE',   1, '2026-03-09 11:00:00', '2026-03-07 11:00:00', '2026-03-09 11:00:00'),
(15, 3, 'PROVEEDOR', 1, '2026-03-10 15:00:00', '2026-03-07 11:00:00', '2026-03-10 15:00:00'),
-- Contrato 16 BORRADOR
(16, 2, 'CLIENTE',   0, NULL, '2026-03-10 08:00:00', '2026-03-10 08:00:00'),
(16, 3, 'PROVEEDOR', 0, NULL, '2026-03-10 08:00:00', '2026-03-10 08:00:00'),
-- Contrato 17 FIRMADO
(17, 1, 'CLIENTE',   1, '2026-03-15 10:00:00', '2026-03-14 10:00:00', '2026-03-15 10:00:00'),
(17, 2, 'PROVEEDOR', 1, '2026-03-16 12:00:00', '2026-03-14 10:00:00', '2026-03-16 12:00:00'),
-- Contrato 18 VALIDADO
(18, 1, 'CLIENTE',   1, '2026-03-20 09:00:00', '2026-03-18 09:00:00', '2026-03-20 09:00:00'),
(18, 2, 'PROVEEDOR', 1, '2026-03-22 10:00:00', '2026-03-18 09:00:00', '2026-03-22 10:00:00'),
-- Contrato 19 BORRADOR
(19, 2, 'CLIENTE',   0, NULL, '2026-03-20 11:00:00', '2026-03-20 11:00:00'),
(19, 3, 'PROVEEDOR', 0, NULL, '2026-03-20 11:00:00', '2026-03-20 11:00:00'),
-- Contrato 20 FIRMADO
(20, 1, 'CLIENTE',   1, '2026-03-25 08:30:00', '2026-03-24 08:30:00', '2026-03-25 08:30:00'),
(20, 3, 'PROVEEDOR', 1, '2026-03-26 09:00:00', '2026-03-24 08:30:00', '2026-03-26 09:00:00'),
-- Contrato 21 VALIDADO
(21, 1, 'CLIENTE',   1, '2026-03-29 10:00:00', '2026-03-27 10:00:00', '2026-03-29 10:00:00'),
(21, 2, 'PROVEEDOR', 1, '2026-03-30 14:00:00', '2026-03-27 10:00:00', '2026-03-30 14:00:00'),
-- Contrato 22 BORRADOR
(22, 2, 'CLIENTE',   0, NULL, '2026-04-01 09:00:00', '2026-04-01 09:00:00'),
(22, 3, 'PROVEEDOR', 0, NULL, '2026-04-01 09:00:00', '2026-04-01 09:00:00'),
-- Contrato 23 FIRMADO
(23, 1, 'CLIENTE',   1, '2026-04-05 11:00:00', '2026-04-04 11:00:00', '2026-04-05 11:00:00'),
(23, 2, 'PROVEEDOR', 1, '2026-04-06 13:00:00', '2026-04-04 11:00:00', '2026-04-06 13:00:00'),
-- Contrato 24 VALIDADO
(24, 1, 'CLIENTE',   1, '2026-04-09 08:00:00', '2026-04-07 08:00:00', '2026-04-09 08:00:00'),
(24, 3, 'PROVEEDOR', 1, '2026-04-10 16:00:00', '2026-04-07 08:00:00', '2026-04-10 16:00:00'),
-- Contrato 25 BORRADOR
(25, 2, 'CLIENTE',   0, NULL, '2026-04-10 10:00:00', '2026-04-10 10:00:00'),
(25, 3, 'PROVEEDOR', 0, NULL, '2026-04-10 10:00:00', '2026-04-10 10:00:00'),
-- Contrato 26 FIRMADO
(26, 1, 'CLIENTE',   1, '2026-04-15 09:30:00', '2026-04-14 09:30:00', '2026-04-15 09:30:00'),
(26, 2, 'PROVEEDOR', 1, '2026-04-16 11:00:00', '2026-04-14 09:30:00', '2026-04-16 11:00:00'),
-- Contrato 27 VALIDADO
(27, 1, 'CLIENTE',   1, '2026-04-19 11:00:00', '2026-04-17 11:00:00', '2026-04-19 11:00:00'),
(27, 2, 'PROVEEDOR', 1, '2026-04-20 14:00:00', '2026-04-17 11:00:00', '2026-04-20 14:00:00'),
-- Contrato 28 BORRADOR
(28, 2, 'CLIENTE',   0, NULL, '2026-04-21 08:00:00', '2026-04-21 08:00:00'),
(28, 3, 'PROVEEDOR', 0, NULL, '2026-04-21 08:00:00', '2026-04-21 08:00:00'),
-- Contrato 29 FIRMADO
(29, 1, 'CLIENTE',   1, '2026-04-25 10:00:00', '2026-04-24 10:00:00', '2026-04-25 10:00:00'),
(29, 3, 'PROVEEDOR', 1, '2026-04-26 12:00:00', '2026-04-24 10:00:00', '2026-04-26 12:00:00'),
-- Contrato 30 VALIDADO
(30, 1, 'CLIENTE',   1, '2026-04-30 09:00:00', '2026-04-28 09:00:00', '2026-04-30 09:00:00'),
(30, 2, 'PROVEEDOR', 1, '2026-05-01 10:00:00', '2026-04-28 09:00:00', '2026-05-01 10:00:00'),
-- Contrato 31 BORRADOR
(31, 2, 'CLIENTE',   0, NULL, '2026-05-02 11:00:00', '2026-05-02 11:00:00'),
(31, 3, 'PROVEEDOR', 0, NULL, '2026-05-02 11:00:00', '2026-05-02 11:00:00'),
-- Contrato 32 FIRMADO
(32, 1, 'CLIENTE',   1, '2026-05-05 09:00:00', '2026-05-04 09:00:00', '2026-05-05 09:00:00'),
(32, 2, 'PROVEEDOR', 1, '2026-05-06 11:00:00', '2026-05-04 09:00:00', '2026-05-06 11:00:00'),
-- Contrato 33 VALIDADO
(33, 1, 'CLIENTE',   1, '2026-05-07 08:30:00', '2026-05-05 08:30:00', '2026-05-07 08:30:00'),
(33, 3, 'PROVEEDOR', 1, '2026-05-08 14:00:00', '2026-05-05 08:30:00', '2026-05-08 14:00:00'),
-- Contrato 34 BORRADOR
(34, 2, 'CLIENTE',   0, NULL, '2026-05-06 10:00:00', '2026-05-06 10:00:00'),
(34, 3, 'PROVEEDOR', 0, NULL, '2026-05-06 10:00:00', '2026-05-06 10:00:00'),
-- Contrato 35 FIRMADO
(35, 1, 'CLIENTE',   1, '2026-05-08 09:00:00', '2026-05-07 09:00:00', '2026-05-08 09:00:00'),
(35, 2, 'PROVEEDOR', 1, '2026-05-08 12:00:00', '2026-05-07 09:00:00', '2026-05-08 12:00:00'),
-- Contrato 36 VALIDADO
(36, 1, 'CLIENTE',   1, '2026-05-09 11:00:00', '2026-05-08 11:00:00', '2026-05-09 11:00:00'),
(36, 2, 'PROVEEDOR', 1, '2026-05-09 15:00:00', '2026-05-08 11:00:00', '2026-05-09 15:00:00'),
-- Contrato 37 BORRADOR
(37, 2, 'CLIENTE',   0, NULL, '2026-05-09 08:00:00', '2026-05-09 08:00:00'),
(37, 3, 'PROVEEDOR', 0, NULL, '2026-05-09 08:00:00', '2026-05-09 08:00:00'),
-- Contrato 38 FIRMADO
(38, 1, 'CLIENTE',   1, '2026-05-10 10:00:00', '2026-05-09 10:00:00', '2026-05-10 10:00:00'),
(38, 3, 'PROVEEDOR', 1, '2026-05-10 13:00:00', '2026-05-09 10:00:00', '2026-05-10 13:00:00'),
-- Contrato 39 BORRADOR
(39, 2, 'CLIENTE',   0, NULL, '2026-05-10 09:00:00', '2026-05-10 09:00:00'),
(39, 3, 'PROVEEDOR', 0, NULL, '2026-05-10 09:00:00', '2026-05-10 09:00:00'),
-- Contrato 40 FIRMADO
(40, 1, 'CLIENTE',   1, '2026-05-11 11:00:00', '2026-05-10 11:00:00', '2026-05-11 11:00:00'),
(40, 2, 'PROVEEDOR', 1, '2026-05-11 14:00:00', '2026-05-10 11:00:00', '2026-05-11 14:00:00'),
-- Contrato 41 BORRADOR
(41, 1, 'CLIENTE',   0, NULL, '2026-05-10 14:00:00', '2026-05-10 14:00:00'),
(41, 2, 'PROVEEDOR', 0, NULL, '2026-05-10 14:00:00', '2026-05-10 14:00:00');

-- -------------------------------------------------------
-- Blockchain blocks: GENESIS para todos, FIRMA para firmados y validados, VALIDACION para validados
-- -------------------------------------------------------

INSERT INTO blockchain_blocks (contract_id, block_number, event_type, data_json, hash, previous_hash, created_by_user_id, created_at) VALUES
-- Contrato 2 VALIDADO
(2,  1, 'GENESIS',    '{"action":"creacion"}',    SHA2(CONCAT('2-1-GENESIS',   UNIX_TIMESTAMP('2026-01-05 09:00:00')), 256), NULL,                                                                     1, '2026-01-05 09:00:00'),
(2,  2, 'FIRMA',      '{"action":"firma","user":1}', SHA2(CONCAT('2-2-FIRMA',  UNIX_TIMESTAMP('2026-01-08 10:00:00')), 256), SHA2(CONCAT('2-1-GENESIS',UNIX_TIMESTAMP('2026-01-05 09:00:00')), 256),  1, '2026-01-08 10:00:00'),
(2,  3, 'FIRMA',      '{"action":"firma","user":2}', SHA2(CONCAT('2-3-FIRMA',  UNIX_TIMESTAMP('2026-01-09 11:00:00')), 256), SHA2(CONCAT('2-2-FIRMA',  UNIX_TIMESTAMP('2026-01-08 10:00:00')), 256),  2, '2026-01-09 11:00:00'),
(2,  4, 'VALIDACION', '{"action":"validacion"}',  SHA2(CONCAT('2-4-VALIDACION',UNIX_TIMESTAMP('2026-01-10 11:00:00')), 256), SHA2(CONCAT('2-3-FIRMA',  UNIX_TIMESTAMP('2026-01-09 11:00:00')), 256),  1, '2026-01-10 11:00:00'),
-- Contrato 3 VALIDADO
(3,  1, 'GENESIS',    '{"action":"creacion"}',    SHA2(CONCAT('3-1-GENESIS',   UNIX_TIMESTAMP('2026-01-12 10:00:00')), 256), NULL,                                                                     1, '2026-01-12 10:00:00'),
(3,  2, 'FIRMA',      '{"action":"firma","user":1}', SHA2(CONCAT('3-2-FIRMA',  UNIX_TIMESTAMP('2026-01-15 10:00:00')), 256), SHA2(CONCAT('3-1-GENESIS',UNIX_TIMESTAMP('2026-01-12 10:00:00')), 256),  1, '2026-01-15 10:00:00'),
(3,  3, 'FIRMA',      '{"action":"firma","user":3}', SHA2(CONCAT('3-3-FIRMA',  UNIX_TIMESTAMP('2026-01-16 14:00:00')), 256), SHA2(CONCAT('3-2-FIRMA',  UNIX_TIMESTAMP('2026-01-15 10:00:00')), 256),  3, '2026-01-16 14:00:00'),
(3,  4, 'VALIDACION', '{"action":"validacion"}',  SHA2(CONCAT('3-4-VALIDACION',UNIX_TIMESTAMP('2026-01-18 14:00:00')), 256), SHA2(CONCAT('3-3-FIRMA',  UNIX_TIMESTAMP('2026-01-16 14:00:00')), 256),  1, '2026-01-18 14:00:00'),
-- Contrato 4 FIRMADO
(4,  1, 'GENESIS',    '{"action":"creacion"}',    SHA2(CONCAT('4-1-GENESIS',   UNIX_TIMESTAMP('2026-01-20 08:30:00')), 256), NULL,                                                                     1, '2026-01-20 08:30:00'),
(4,  2, 'FIRMA',      '{"action":"firma","user":1}', SHA2(CONCAT('4-2-FIRMA',  UNIX_TIMESTAMP('2026-01-21 09:00:00')), 256), SHA2(CONCAT('4-1-GENESIS',UNIX_TIMESTAMP('2026-01-20 08:30:00')), 256),  1, '2026-01-21 09:00:00'),
(4,  3, 'FIRMA',      '{"action":"firma","user":2}', SHA2(CONCAT('4-3-FIRMA',  UNIX_TIMESTAMP('2026-01-22 09:00:00')), 256), SHA2(CONCAT('4-2-FIRMA',  UNIX_TIMESTAMP('2026-01-21 09:00:00')), 256),  2, '2026-01-22 09:00:00'),
-- Contrato 5 BORRADOR
(5,  1, 'GENESIS',    '{"action":"creacion"}',    SHA2(CONCAT('5-1-GENESIS',   UNIX_TIMESTAMP('2026-01-25 11:00:00')), 256), NULL,                                                                     1, '2026-01-25 11:00:00'),
-- Contrato 6 VALIDADO
(6,  1, 'GENESIS',    '{"action":"creacion"}',    SHA2(CONCAT('6-1-GENESIS',   UNIX_TIMESTAMP('2026-01-28 15:00:00')), 256), NULL,                                                                     2, '2026-01-28 15:00:00'),
(6,  2, 'FIRMA',      '{"action":"firma","user":2}', SHA2(CONCAT('6-2-FIRMA',  UNIX_TIMESTAMP('2026-01-30 09:00:00')), 256), SHA2(CONCAT('6-1-GENESIS',UNIX_TIMESTAMP('2026-01-28 15:00:00')), 256),  2, '2026-01-30 09:00:00'),
(6,  3, 'FIRMA',      '{"action":"firma","user":3}', SHA2(CONCAT('6-3-FIRMA',  UNIX_TIMESTAMP('2026-01-31 10:00:00')), 256), SHA2(CONCAT('6-2-FIRMA',  UNIX_TIMESTAMP('2026-01-30 09:00:00')), 256),  3, '2026-01-31 10:00:00'),
(6,  4, 'VALIDACION', '{"action":"validacion"}',  SHA2(CONCAT('6-4-VALIDACION',UNIX_TIMESTAMP('2026-02-03 10:00:00')), 256), SHA2(CONCAT('6-3-FIRMA',  UNIX_TIMESTAMP('2026-01-31 10:00:00')), 256),  1, '2026-02-03 10:00:00'),
-- Contrato 7 BORRADOR
(7,  1, 'GENESIS',    '{"action":"creacion"}',    SHA2(CONCAT('7-1-GENESIS',   UNIX_TIMESTAMP('2026-02-02 09:00:00')), 256), NULL,                                                                     2, '2026-02-02 09:00:00'),
-- Contrato 8 FIRMADO
(8,  1, 'GENESIS',    '{"action":"creacion"}',    SHA2(CONCAT('8-1-GENESIS',   UNIX_TIMESTAMP('2026-02-06 10:00:00')), 256), NULL,                                                                     1, '2026-02-06 10:00:00'),
(8,  2, 'FIRMA',      '{"action":"firma","user":1}', SHA2(CONCAT('8-2-FIRMA',  UNIX_TIMESTAMP('2026-02-07 10:00:00')), 256), SHA2(CONCAT('8-1-GENESIS',UNIX_TIMESTAMP('2026-02-06 10:00:00')), 256),  1, '2026-02-07 10:00:00'),
(8,  3, 'FIRMA',      '{"action":"firma","user":3}', SHA2(CONCAT('8-3-FIRMA',  UNIX_TIMESTAMP('2026-02-08 12:00:00')), 256), SHA2(CONCAT('8-2-FIRMA',  UNIX_TIMESTAMP('2026-02-07 10:00:00')), 256),  3, '2026-02-08 12:00:00'),
-- Contrato 9 VALIDADO
(9,  1, 'GENESIS',    '{"action":"creacion"}',    SHA2(CONCAT('9-1-GENESIS',   UNIX_TIMESTAMP('2026-02-10 08:00:00')), 256), NULL,                                                                     1, '2026-02-10 08:00:00'),
(9,  2, 'FIRMA',      '{"action":"firma","user":1}', SHA2(CONCAT('9-2-FIRMA',  UNIX_TIMESTAMP('2026-02-12 08:00:00')), 256), SHA2(CONCAT('9-1-GENESIS',UNIX_TIMESTAMP('2026-02-10 08:00:00')), 256),  1, '2026-02-12 08:00:00'),
(9,  3, 'FIRMA',      '{"action":"firma","user":2}', SHA2(CONCAT('9-3-FIRMA',  UNIX_TIMESTAMP('2026-02-13 10:00:00')), 256), SHA2(CONCAT('9-2-FIRMA',  UNIX_TIMESTAMP('2026-02-12 08:00:00')), 256),  2, '2026-02-13 10:00:00'),
(9,  4, 'VALIDACION', '{"action":"validacion"}',  SHA2(CONCAT('9-4-VALIDACION',UNIX_TIMESTAMP('2026-02-15 16:00:00')), 256), SHA2(CONCAT('9-3-FIRMA',  UNIX_TIMESTAMP('2026-02-13 10:00:00')), 256),  1, '2026-02-15 16:00:00'),
-- Contrato 10 BORRADOR
(10, 1, 'GENESIS',    '{"action":"creacion"}',    SHA2(CONCAT('10-1-GENESIS',  UNIX_TIMESTAMP('2026-02-14 11:00:00')), 256), NULL,                                                                     2, '2026-02-14 11:00:00'),
-- Contrato 11 FIRMADO
(11, 1, 'GENESIS',    '{"action":"creacion"}',    SHA2(CONCAT('11-1-GENESIS',  UNIX_TIMESTAMP('2026-02-18 09:30:00')), 256), NULL,                                                                     1, '2026-02-18 09:30:00'),
(11, 2, 'FIRMA',      '{"action":"firma","user":1}', SHA2(CONCAT('11-2-FIRMA', UNIX_TIMESTAMP('2026-02-19 09:30:00')), 256), SHA2(CONCAT('11-1-GENESIS',UNIX_TIMESTAMP('2026-02-18 09:30:00')), 256), 1, '2026-02-19 09:30:00'),
(11, 3, 'FIRMA',      '{"action":"firma","user":2}', SHA2(CONCAT('11-3-FIRMA', UNIX_TIMESTAMP('2026-02-20 10:00:00')), 256), SHA2(CONCAT('11-2-FIRMA', UNIX_TIMESTAMP('2026-02-19 09:30:00')), 256),  2, '2026-02-20 10:00:00'),
-- Contrato 12 VALIDADO
(12, 1, 'GENESIS',    '{"action":"creacion"}',    SHA2(CONCAT('12-1-GENESIS',  UNIX_TIMESTAMP('2026-02-22 14:00:00')), 256), NULL,                                                                     1, '2026-02-22 14:00:00'),
(12, 2, 'FIRMA',      '{"action":"firma","user":1}', SHA2(CONCAT('12-2-FIRMA', UNIX_TIMESTAMP('2026-02-24 14:00:00')), 256), SHA2(CONCAT('12-1-GENESIS',UNIX_TIMESTAMP('2026-02-22 14:00:00')), 256), 1, '2026-02-24 14:00:00'),
(12, 3, 'FIRMA',      '{"action":"firma","user":3}', SHA2(CONCAT('12-3-FIRMA', UNIX_TIMESTAMP('2026-02-25 11:00:00')), 256), SHA2(CONCAT('12-2-FIRMA', UNIX_TIMESTAMP('2026-02-24 14:00:00')), 256),  3, '2026-02-25 11:00:00'),
(12, 4, 'VALIDACION', '{"action":"validacion"}',  SHA2(CONCAT('12-4-VALIDACION',UNIX_TIMESTAMP('2026-02-27 11:00:00')), 256), SHA2(CONCAT('12-3-FIRMA', UNIX_TIMESTAMP('2026-02-25 11:00:00')), 256), 1, '2026-02-27 11:00:00'),
-- Contrato 13 BORRADOR
(13, 1, 'GENESIS',    '{"action":"creacion"}',    SHA2(CONCAT('13-1-GENESIS',  UNIX_TIMESTAMP('2026-02-25 10:00:00')), 256), NULL,                                                                     2, '2026-02-25 10:00:00'),
-- Contrato 14 FIRMADO
(14, 1, 'GENESIS',    '{"action":"creacion"}',    SHA2(CONCAT('14-1-GENESIS',  UNIX_TIMESTAMP('2026-03-03 09:00:00')), 256), NULL,                                                                     1, '2026-03-03 09:00:00'),
(14, 2, 'FIRMA',      '{"action":"firma","user":1}', SHA2(CONCAT('14-2-FIRMA', UNIX_TIMESTAMP('2026-03-04 09:00:00')), 256), SHA2(CONCAT('14-1-GENESIS',UNIX_TIMESTAMP('2026-03-03 09:00:00')), 256), 1, '2026-03-04 09:00:00'),
(14, 3, 'FIRMA',      '{"action":"firma","user":2}', SHA2(CONCAT('14-3-FIRMA', UNIX_TIMESTAMP('2026-03-05 14:00:00')), 256), SHA2(CONCAT('14-2-FIRMA', UNIX_TIMESTAMP('2026-03-04 09:00:00')), 256),  2, '2026-03-05 14:00:00'),
-- Contrato 15 VALIDADO
(15, 1, 'GENESIS',    '{"action":"creacion"}',    SHA2(CONCAT('15-1-GENESIS',  UNIX_TIMESTAMP('2026-03-07 11:00:00')), 256), NULL,                                                                     1, '2026-03-07 11:00:00'),
(15, 2, 'FIRMA',      '{"action":"firma","user":1}', SHA2(CONCAT('15-2-FIRMA', UNIX_TIMESTAMP('2026-03-09 11:00:00')), 256), SHA2(CONCAT('15-1-GENESIS',UNIX_TIMESTAMP('2026-03-07 11:00:00')), 256), 1, '2026-03-09 11:00:00'),
(15, 3, 'FIRMA',      '{"action":"firma","user":3}', SHA2(CONCAT('15-3-FIRMA', UNIX_TIMESTAMP('2026-03-10 15:00:00')), 256), SHA2(CONCAT('15-2-FIRMA', UNIX_TIMESTAMP('2026-03-09 11:00:00')), 256),  3, '2026-03-10 15:00:00'),
(15, 4, 'VALIDACION', '{"action":"validacion"}',  SHA2(CONCAT('15-4-VALIDACION',UNIX_TIMESTAMP('2026-03-12 15:00:00')), 256), SHA2(CONCAT('15-3-FIRMA', UNIX_TIMESTAMP('2026-03-10 15:00:00')), 256), 1, '2026-03-12 15:00:00'),
-- Contrato 16 BORRADOR
(16, 1, 'GENESIS',    '{"action":"creacion"}',    SHA2(CONCAT('16-1-GENESIS',  UNIX_TIMESTAMP('2026-03-10 08:00:00')), 256), NULL,                                                                     2, '2026-03-10 08:00:00'),
-- Contrato 17 FIRMADO
(17, 1, 'GENESIS',    '{"action":"creacion"}',    SHA2(CONCAT('17-1-GENESIS',  UNIX_TIMESTAMP('2026-03-14 10:00:00')), 256), NULL,                                                                     1, '2026-03-14 10:00:00'),
(17, 2, 'FIRMA',      '{"action":"firma","user":1}', SHA2(CONCAT('17-2-FIRMA', UNIX_TIMESTAMP('2026-03-15 10:00:00')), 256), SHA2(CONCAT('17-1-GENESIS',UNIX_TIMESTAMP('2026-03-14 10:00:00')), 256), 1, '2026-03-15 10:00:00'),
(17, 3, 'FIRMA',      '{"action":"firma","user":2}', SHA2(CONCAT('17-3-FIRMA', UNIX_TIMESTAMP('2026-03-16 12:00:00')), 256), SHA2(CONCAT('17-2-FIRMA', UNIX_TIMESTAMP('2026-03-15 10:00:00')), 256),  2, '2026-03-16 12:00:00'),
-- Contrato 18 VALIDADO
(18, 1, 'GENESIS',    '{"action":"creacion"}',    SHA2(CONCAT('18-1-GENESIS',  UNIX_TIMESTAMP('2026-03-18 09:00:00')), 256), NULL,                                                                     1, '2026-03-18 09:00:00'),
(18, 2, 'FIRMA',      '{"action":"firma","user":1}', SHA2(CONCAT('18-2-FIRMA', UNIX_TIMESTAMP('2026-03-20 09:00:00')), 256), SHA2(CONCAT('18-1-GENESIS',UNIX_TIMESTAMP('2026-03-18 09:00:00')), 256), 1, '2026-03-20 09:00:00'),
(18, 3, 'FIRMA',      '{"action":"firma","user":2}', SHA2(CONCAT('18-3-FIRMA', UNIX_TIMESTAMP('2026-03-22 10:00:00')), 256), SHA2(CONCAT('18-2-FIRMA', UNIX_TIMESTAMP('2026-03-20 09:00:00')), 256),  2, '2026-03-22 10:00:00'),
(18, 4, 'VALIDACION', '{"action":"validacion"}',  SHA2(CONCAT('18-4-VALIDACION',UNIX_TIMESTAMP('2026-03-24 10:00:00')), 256), SHA2(CONCAT('18-3-FIRMA', UNIX_TIMESTAMP('2026-03-22 10:00:00')), 256), 1, '2026-03-24 10:00:00'),
-- Contrato 19 BORRADOR
(19, 1, 'GENESIS',    '{"action":"creacion"}',    SHA2(CONCAT('19-1-GENESIS',  UNIX_TIMESTAMP('2026-03-20 11:00:00')), 256), NULL,                                                                     2, '2026-03-20 11:00:00'),
-- Contrato 20 FIRMADO
(20, 1, 'GENESIS',    '{"action":"creacion"}',    SHA2(CONCAT('20-1-GENESIS',  UNIX_TIMESTAMP('2026-03-24 08:30:00')), 256), NULL,                                                                     1, '2026-03-24 08:30:00'),
(20, 2, 'FIRMA',      '{"action":"firma","user":1}', SHA2(CONCAT('20-2-FIRMA', UNIX_TIMESTAMP('2026-03-25 08:30:00')), 256), SHA2(CONCAT('20-1-GENESIS',UNIX_TIMESTAMP('2026-03-24 08:30:00')), 256), 1, '2026-03-25 08:30:00'),
(20, 3, 'FIRMA',      '{"action":"firma","user":3}', SHA2(CONCAT('20-3-FIRMA', UNIX_TIMESTAMP('2026-03-26 09:00:00')), 256), SHA2(CONCAT('20-2-FIRMA', UNIX_TIMESTAMP('2026-03-25 08:30:00')), 256),  3, '2026-03-26 09:00:00'),
-- Contrato 21 VALIDADO
(21, 1, 'GENESIS',    '{"action":"creacion"}',    SHA2(CONCAT('21-1-GENESIS',  UNIX_TIMESTAMP('2026-03-27 10:00:00')), 256), NULL,                                                                     1, '2026-03-27 10:00:00'),
(21, 2, 'FIRMA',      '{"action":"firma","user":1}', SHA2(CONCAT('21-2-FIRMA', UNIX_TIMESTAMP('2026-03-29 10:00:00')), 256), SHA2(CONCAT('21-1-GENESIS',UNIX_TIMESTAMP('2026-03-27 10:00:00')), 256), 1, '2026-03-29 10:00:00'),
(21, 3, 'FIRMA',      '{"action":"firma","user":2}', SHA2(CONCAT('21-3-FIRMA', UNIX_TIMESTAMP('2026-03-30 14:00:00')), 256), SHA2(CONCAT('21-2-FIRMA', UNIX_TIMESTAMP('2026-03-29 10:00:00')), 256),  2, '2026-03-30 14:00:00'),
(21, 4, 'VALIDACION', '{"action":"validacion"}',  SHA2(CONCAT('21-4-VALIDACION',UNIX_TIMESTAMP('2026-04-02 14:00:00')), 256), SHA2(CONCAT('21-3-FIRMA', UNIX_TIMESTAMP('2026-03-30 14:00:00')), 256), 1, '2026-04-02 14:00:00'),
-- Contrato 22 BORRADOR
(22, 1, 'GENESIS',    '{"action":"creacion"}',    SHA2(CONCAT('22-1-GENESIS',  UNIX_TIMESTAMP('2026-04-01 09:00:00')), 256), NULL,                                                                     2, '2026-04-01 09:00:00'),
-- Contrato 23 FIRMADO
(23, 1, 'GENESIS',    '{"action":"creacion"}',    SHA2(CONCAT('23-1-GENESIS',  UNIX_TIMESTAMP('2026-04-04 11:00:00')), 256), NULL,                                                                     1, '2026-04-04 11:00:00'),
(23, 2, 'FIRMA',      '{"action":"firma","user":1}', SHA2(CONCAT('23-2-FIRMA', UNIX_TIMESTAMP('2026-04-05 11:00:00')), 256), SHA2(CONCAT('23-1-GENESIS',UNIX_TIMESTAMP('2026-04-04 11:00:00')), 256), 1, '2026-04-05 11:00:00'),
(23, 3, 'FIRMA',      '{"action":"firma","user":2}', SHA2(CONCAT('23-3-FIRMA', UNIX_TIMESTAMP('2026-04-06 13:00:00')), 256), SHA2(CONCAT('23-2-FIRMA', UNIX_TIMESTAMP('2026-04-05 11:00:00')), 256),  2, '2026-04-06 13:00:00'),
-- Contrato 24 VALIDADO
(24, 1, 'GENESIS',    '{"action":"creacion"}',    SHA2(CONCAT('24-1-GENESIS',  UNIX_TIMESTAMP('2026-04-07 08:00:00')), 256), NULL,                                                                     1, '2026-04-07 08:00:00'),
(24, 2, 'FIRMA',      '{"action":"firma","user":1}', SHA2(CONCAT('24-2-FIRMA', UNIX_TIMESTAMP('2026-04-09 08:00:00')), 256), SHA2(CONCAT('24-1-GENESIS',UNIX_TIMESTAMP('2026-04-07 08:00:00')), 256), 1, '2026-04-09 08:00:00'),
(24, 3, 'FIRMA',      '{"action":"firma","user":3}', SHA2(CONCAT('24-3-FIRMA', UNIX_TIMESTAMP('2026-04-10 16:00:00')), 256), SHA2(CONCAT('24-2-FIRMA', UNIX_TIMESTAMP('2026-04-09 08:00:00')), 256),  3, '2026-04-10 16:00:00'),
(24, 4, 'VALIDACION', '{"action":"validacion"}',  SHA2(CONCAT('24-4-VALIDACION',UNIX_TIMESTAMP('2026-04-11 16:00:00')), 256), SHA2(CONCAT('24-3-FIRMA', UNIX_TIMESTAMP('2026-04-10 16:00:00')), 256), 1, '2026-04-11 16:00:00'),
-- Contrato 25 BORRADOR
(25, 1, 'GENESIS',    '{"action":"creacion"}',    SHA2(CONCAT('25-1-GENESIS',  UNIX_TIMESTAMP('2026-04-10 10:00:00')), 256), NULL,                                                                     2, '2026-04-10 10:00:00'),
-- Contrato 26 FIRMADO
(26, 1, 'GENESIS',    '{"action":"creacion"}',    SHA2(CONCAT('26-1-GENESIS',  UNIX_TIMESTAMP('2026-04-14 09:30:00')), 256), NULL,                                                                     1, '2026-04-14 09:30:00'),
(26, 2, 'FIRMA',      '{"action":"firma","user":1}', SHA2(CONCAT('26-2-FIRMA', UNIX_TIMESTAMP('2026-04-15 09:30:00')), 256), SHA2(CONCAT('26-1-GENESIS',UNIX_TIMESTAMP('2026-04-14 09:30:00')), 256), 1, '2026-04-15 09:30:00'),
(26, 3, 'FIRMA',      '{"action":"firma","user":2}', SHA2(CONCAT('26-3-FIRMA', UNIX_TIMESTAMP('2026-04-16 11:00:00')), 256), SHA2(CONCAT('26-2-FIRMA', UNIX_TIMESTAMP('2026-04-15 09:30:00')), 256),  2, '2026-04-16 11:00:00'),
-- Contrato 27 VALIDADO
(27, 1, 'GENESIS',    '{"action":"creacion"}',    SHA2(CONCAT('27-1-GENESIS',  UNIX_TIMESTAMP('2026-04-17 11:00:00')), 256), NULL,                                                                     1, '2026-04-17 11:00:00'),
(27, 2, 'FIRMA',      '{"action":"firma","user":1}', SHA2(CONCAT('27-2-FIRMA', UNIX_TIMESTAMP('2026-04-19 11:00:00')), 256), SHA2(CONCAT('27-1-GENESIS',UNIX_TIMESTAMP('2026-04-17 11:00:00')), 256), 1, '2026-04-19 11:00:00'),
(27, 3, 'FIRMA',      '{"action":"firma","user":2}', SHA2(CONCAT('27-3-FIRMA', UNIX_TIMESTAMP('2026-04-20 14:00:00')), 256), SHA2(CONCAT('27-2-FIRMA', UNIX_TIMESTAMP('2026-04-19 11:00:00')), 256),  2, '2026-04-20 14:00:00'),
(27, 4, 'VALIDACION', '{"action":"validacion"}',  SHA2(CONCAT('27-4-VALIDACION',UNIX_TIMESTAMP('2026-04-22 14:00:00')), 256), SHA2(CONCAT('27-3-FIRMA', UNIX_TIMESTAMP('2026-04-20 14:00:00')), 256), 1, '2026-04-22 14:00:00'),
-- Contrato 28 BORRADOR
(28, 1, 'GENESIS',    '{"action":"creacion"}',    SHA2(CONCAT('28-1-GENESIS',  UNIX_TIMESTAMP('2026-04-21 08:00:00')), 256), NULL,                                                                     2, '2026-04-21 08:00:00'),
-- Contrato 29 FIRMADO
(29, 1, 'GENESIS',    '{"action":"creacion"}',    SHA2(CONCAT('29-1-GENESIS',  UNIX_TIMESTAMP('2026-04-24 10:00:00')), 256), NULL,                                                                     1, '2026-04-24 10:00:00'),
(29, 2, 'FIRMA',      '{"action":"firma","user":1}', SHA2(CONCAT('29-2-FIRMA', UNIX_TIMESTAMP('2026-04-25 10:00:00')), 256), SHA2(CONCAT('29-1-GENESIS',UNIX_TIMESTAMP('2026-04-24 10:00:00')), 256), 1, '2026-04-25 10:00:00'),
(29, 3, 'FIRMA',      '{"action":"firma","user":3}', SHA2(CONCAT('29-3-FIRMA', UNIX_TIMESTAMP('2026-04-26 12:00:00')), 256), SHA2(CONCAT('29-2-FIRMA', UNIX_TIMESTAMP('2026-04-25 10:00:00')), 256),  3, '2026-04-26 12:00:00'),
-- Contrato 30 VALIDADO
(30, 1, 'GENESIS',    '{"action":"creacion"}',    SHA2(CONCAT('30-1-GENESIS',  UNIX_TIMESTAMP('2026-04-28 09:00:00')), 256), NULL,                                                                     1, '2026-04-28 09:00:00'),
(30, 2, 'FIRMA',      '{"action":"firma","user":1}', SHA2(CONCAT('30-2-FIRMA', UNIX_TIMESTAMP('2026-04-30 09:00:00')), 256), SHA2(CONCAT('30-1-GENESIS',UNIX_TIMESTAMP('2026-04-28 09:00:00')), 256), 1, '2026-04-30 09:00:00'),
(30, 3, 'FIRMA',      '{"action":"firma","user":2}', SHA2(CONCAT('30-3-FIRMA', UNIX_TIMESTAMP('2026-05-01 10:00:00')), 256), SHA2(CONCAT('30-2-FIRMA', UNIX_TIMESTAMP('2026-04-30 09:00:00')), 256),  2, '2026-05-01 10:00:00'),
(30, 4, 'VALIDACION', '{"action":"validacion"}',  SHA2(CONCAT('30-4-VALIDACION',UNIX_TIMESTAMP('2026-05-02 10:00:00')), 256), SHA2(CONCAT('30-3-FIRMA', UNIX_TIMESTAMP('2026-05-01 10:00:00')), 256), 1, '2026-05-02 10:00:00'),
-- Contrato 31 BORRADOR
(31, 1, 'GENESIS',    '{"action":"creacion"}',    SHA2(CONCAT('31-1-GENESIS',  UNIX_TIMESTAMP('2026-05-02 11:00:00')), 256), NULL,                                                                     2, '2026-05-02 11:00:00'),
-- Contrato 32 FIRMADO
(32, 1, 'GENESIS',    '{"action":"creacion"}',    SHA2(CONCAT('32-1-GENESIS',  UNIX_TIMESTAMP('2026-05-04 09:00:00')), 256), NULL,                                                                     1, '2026-05-04 09:00:00'),
(32, 2, 'FIRMA',      '{"action":"firma","user":1}', SHA2(CONCAT('32-2-FIRMA', UNIX_TIMESTAMP('2026-05-05 09:00:00')), 256), SHA2(CONCAT('32-1-GENESIS',UNIX_TIMESTAMP('2026-05-04 09:00:00')), 256), 1, '2026-05-05 09:00:00'),
(32, 3, 'FIRMA',      '{"action":"firma","user":2}', SHA2(CONCAT('32-3-FIRMA', UNIX_TIMESTAMP('2026-05-06 11:00:00')), 256), SHA2(CONCAT('32-2-FIRMA', UNIX_TIMESTAMP('2026-05-05 09:00:00')), 256),  2, '2026-05-06 11:00:00'),
-- Contrato 33 VALIDADO
(33, 1, 'GENESIS',    '{"action":"creacion"}',    SHA2(CONCAT('33-1-GENESIS',  UNIX_TIMESTAMP('2026-05-05 08:30:00')), 256), NULL,                                                                     1, '2026-05-05 08:30:00'),
(33, 2, 'FIRMA',      '{"action":"firma","user":1}', SHA2(CONCAT('33-2-FIRMA', UNIX_TIMESTAMP('2026-05-07 08:30:00')), 256), SHA2(CONCAT('33-1-GENESIS',UNIX_TIMESTAMP('2026-05-05 08:30:00')), 256), 1, '2026-05-07 08:30:00'),
(33, 3, 'FIRMA',      '{"action":"firma","user":3}', SHA2(CONCAT('33-3-FIRMA', UNIX_TIMESTAMP('2026-05-08 14:00:00')), 256), SHA2(CONCAT('33-2-FIRMA', UNIX_TIMESTAMP('2026-05-07 08:30:00')), 256),  3, '2026-05-08 14:00:00'),
(33, 4, 'VALIDACION', '{"action":"validacion"}',  SHA2(CONCAT('33-4-VALIDACION',UNIX_TIMESTAMP('2026-05-09 14:00:00')), 256), SHA2(CONCAT('33-3-FIRMA', UNIX_TIMESTAMP('2026-05-08 14:00:00')), 256), 1, '2026-05-09 14:00:00'),
-- Contrato 34 BORRADOR
(34, 1, 'GENESIS',    '{"action":"creacion"}',    SHA2(CONCAT('34-1-GENESIS',  UNIX_TIMESTAMP('2026-05-06 10:00:00')), 256), NULL,                                                                     2, '2026-05-06 10:00:00'),
-- Contrato 35 FIRMADO
(35, 1, 'GENESIS',    '{"action":"creacion"}',    SHA2(CONCAT('35-1-GENESIS',  UNIX_TIMESTAMP('2026-05-07 09:00:00')), 256), NULL,                                                                     1, '2026-05-07 09:00:00'),
(35, 2, 'FIRMA',      '{"action":"firma","user":1}', SHA2(CONCAT('35-2-FIRMA', UNIX_TIMESTAMP('2026-05-08 09:00:00')), 256), SHA2(CONCAT('35-1-GENESIS',UNIX_TIMESTAMP('2026-05-07 09:00:00')), 256), 1, '2026-05-08 09:00:00'),
(35, 3, 'FIRMA',      '{"action":"firma","user":2}', SHA2(CONCAT('35-3-FIRMA', UNIX_TIMESTAMP('2026-05-08 12:00:00')), 256), SHA2(CONCAT('35-2-FIRMA', UNIX_TIMESTAMP('2026-05-08 09:00:00')), 256),  2, '2026-05-08 12:00:00'),
-- Contrato 36 VALIDADO
(36, 1, 'GENESIS',    '{"action":"creacion"}',    SHA2(CONCAT('36-1-GENESIS',  UNIX_TIMESTAMP('2026-05-08 11:00:00')), 256), NULL,                                                                     1, '2026-05-08 11:00:00'),
(36, 2, 'FIRMA',      '{"action":"firma","user":1}', SHA2(CONCAT('36-2-FIRMA', UNIX_TIMESTAMP('2026-05-09 11:00:00')), 256), SHA2(CONCAT('36-1-GENESIS',UNIX_TIMESTAMP('2026-05-08 11:00:00')), 256), 1, '2026-05-09 11:00:00'),
(36, 3, 'FIRMA',      '{"action":"firma","user":2}', SHA2(CONCAT('36-3-FIRMA', UNIX_TIMESTAMP('2026-05-09 15:00:00')), 256), SHA2(CONCAT('36-2-FIRMA', UNIX_TIMESTAMP('2026-05-09 11:00:00')), 256),  2, '2026-05-09 15:00:00'),
(36, 4, 'VALIDACION', '{"action":"validacion"}',  SHA2(CONCAT('36-4-VALIDACION',UNIX_TIMESTAMP('2026-05-09 15:00:00')), 256), SHA2(CONCAT('36-3-FIRMA', UNIX_TIMESTAMP('2026-05-09 15:00:00')), 256), 1, '2026-05-09 15:00:00'),
-- Contrato 37 BORRADOR
(37, 1, 'GENESIS',    '{"action":"creacion"}',    SHA2(CONCAT('37-1-GENESIS',  UNIX_TIMESTAMP('2026-05-09 08:00:00')), 256), NULL,                                                                     2, '2026-05-09 08:00:00'),
-- Contrato 38 FIRMADO
(38, 1, 'GENESIS',    '{"action":"creacion"}',    SHA2(CONCAT('38-1-GENESIS',  UNIX_TIMESTAMP('2026-05-09 10:00:00')), 256), NULL,                                                                     1, '2026-05-09 10:00:00'),
(38, 2, 'FIRMA',      '{"action":"firma","user":1}', SHA2(CONCAT('38-2-FIRMA', UNIX_TIMESTAMP('2026-05-10 10:00:00')), 256), SHA2(CONCAT('38-1-GENESIS',UNIX_TIMESTAMP('2026-05-09 10:00:00')), 256), 1, '2026-05-10 10:00:00'),
(38, 3, 'FIRMA',      '{"action":"firma","user":3}', SHA2(CONCAT('38-3-FIRMA', UNIX_TIMESTAMP('2026-05-10 13:00:00')), 256), SHA2(CONCAT('38-2-FIRMA', UNIX_TIMESTAMP('2026-05-10 10:00:00')), 256),  3, '2026-05-10 13:00:00'),
-- Contrato 39 BORRADOR
(39, 1, 'GENESIS',    '{"action":"creacion"}',    SHA2(CONCAT('39-1-GENESIS',  UNIX_TIMESTAMP('2026-05-10 09:00:00')), 256), NULL,                                                                     2, '2026-05-10 09:00:00'),
-- Contrato 40 FIRMADO
(40, 1, 'GENESIS',    '{"action":"creacion"}',    SHA2(CONCAT('40-1-GENESIS',  UNIX_TIMESTAMP('2026-05-10 11:00:00')), 256), NULL,                                                                     1, '2026-05-10 11:00:00'),
(40, 2, 'FIRMA',      '{"action":"firma","user":1}', SHA2(CONCAT('40-2-FIRMA', UNIX_TIMESTAMP('2026-05-11 11:00:00')), 256), SHA2(CONCAT('40-1-GENESIS',UNIX_TIMESTAMP('2026-05-10 11:00:00')), 256), 1, '2026-05-11 11:00:00'),
(40, 3, 'FIRMA',      '{"action":"firma","user":2}', SHA2(CONCAT('40-3-FIRMA', UNIX_TIMESTAMP('2026-05-11 14:00:00')), 256), SHA2(CONCAT('40-2-FIRMA', UNIX_TIMESTAMP('2026-05-11 11:00:00')), 256),  2, '2026-05-11 14:00:00'),
-- Contrato 41 BORRADOR
(41, 1, 'GENESIS',    '{"action":"creacion"}',    SHA2(CONCAT('41-1-GENESIS',  UNIX_TIMESTAMP('2026-05-10 14:00:00')), 256), NULL,                                                                     1, '2026-05-10 14:00:00');

-- -------------------------------------------------------
-- Audit logs: CREACION_CONTRATO y AGREGAR_PARTICIPANTE para todos
-- FIRMA para firmados y validados, VALIDACION para validados
-- -------------------------------------------------------

INSERT INTO audit_logs (user_id, contract_id, action_type, description, created_at) VALUES
(1, 2,  'CREACION_CONTRATO',    'Contrato de Servicios TI',         '2026-01-05 09:00:00'),
(1, 2,  'AGREGAR_PARTICIPANTE', '1',                                '2026-01-05 09:00:00'),
(2, 2,  'AGREGAR_PARTICIPANTE', '2',                                '2026-01-05 09:00:00'),
(1, 2,  'FIRMA',                '1',                                '2026-01-08 10:00:00'),
(2, 2,  'FIRMA',                '2',                                '2026-01-09 11:00:00'),
(1, 2,  'VALIDACION',           '1',                                '2026-01-10 11:00:00'),
(1, 3,  'CREACION_CONTRATO',    'Acuerdo de Confidencialidad',      '2026-01-12 10:00:00'),
(1, 3,  'AGREGAR_PARTICIPANTE', '1',                                '2026-01-12 10:00:00'),
(3, 3,  'AGREGAR_PARTICIPANTE', '3',                                '2026-01-12 10:00:00'),
(1, 3,  'FIRMA',                '1',                                '2026-01-15 10:00:00'),
(3, 3,  'FIRMA',                '3',                                '2026-01-16 14:00:00'),
(1, 3,  'VALIDACION',           '1',                                '2026-01-18 14:00:00'),
(1, 4,  'CREACION_CONTRATO',    'Contrato de Consultoría',          '2026-01-20 08:30:00'),
(1, 4,  'AGREGAR_PARTICIPANTE', '1',                                '2026-01-20 08:30:00'),
(2, 4,  'AGREGAR_PARTICIPANTE', '2',                                '2026-01-20 08:30:00'),
(1, 4,  'FIRMA',                '1',                                '2026-01-21 09:00:00'),
(2, 4,  'FIRMA',                '2',                                '2026-01-22 09:00:00'),
(1, 5,  'CREACION_CONTRATO',    'Licencia de Software',             '2026-01-25 11:00:00'),
(1, 5,  'AGREGAR_PARTICIPANTE', '1',                                '2026-01-25 11:00:00'),
(2, 5,  'AGREGAR_PARTICIPANTE', '2',                                '2026-01-25 11:00:00'),
(2, 6,  'CREACION_CONTRATO',    'Contrato de Mantenimiento',        '2026-01-28 15:00:00'),
(2, 6,  'AGREGAR_PARTICIPANTE', '2',                                '2026-01-28 15:00:00'),
(3, 6,  'AGREGAR_PARTICIPANTE', '3',                                '2026-01-28 15:00:00'),
(2, 6,  'FIRMA',                '2',                                '2026-01-30 09:00:00'),
(3, 6,  'FIRMA',                '3',                                '2026-01-31 10:00:00'),
(1, 6,  'VALIDACION',           '1',                                '2026-02-03 10:00:00'),
(2, 7,  'CREACION_CONTRATO',    'Acuerdo de Nivel de Servicio',     '2026-02-02 09:00:00'),
(2, 7,  'AGREGAR_PARTICIPANTE', '2',                                '2026-02-02 09:00:00'),
(3, 7,  'AGREGAR_PARTICIPANTE', '3',                                '2026-02-02 09:00:00'),
(1, 8,  'CREACION_CONTRATO',    'Contrato de Desarrollo Web',       '2026-02-06 10:00:00'),
(1, 8,  'AGREGAR_PARTICIPANTE', '1',                                '2026-02-06 10:00:00'),
(3, 8,  'AGREGAR_PARTICIPANTE', '3',                                '2026-02-06 10:00:00'),
(1, 8,  'FIRMA',                '1',                                '2026-02-07 10:00:00'),
(3, 8,  'FIRMA',                '3',                                '2026-02-08 12:00:00'),
(1, 9,  'CREACION_CONTRATO',    'Contrato de Outsourcing',          '2026-02-10 08:00:00'),
(1, 9,  'AGREGAR_PARTICIPANTE', '1',                                '2026-02-10 08:00:00'),
(2, 9,  'AGREGAR_PARTICIPANTE', '2',                                '2026-02-10 08:00:00'),
(1, 9,  'FIRMA',                '1',                                '2026-02-12 08:00:00'),
(2, 9,  'FIRMA',                '2',                                '2026-02-13 10:00:00'),
(1, 9,  'VALIDACION',           '1',                                '2026-02-15 16:00:00'),
(2, 10, 'CREACION_CONTRATO',    'Acuerdo Marco de Servicios',       '2026-02-14 11:00:00'),
(2, 10, 'AGREGAR_PARTICIPANTE', '2',                                '2026-02-14 11:00:00'),
(3, 10, 'AGREGAR_PARTICIPANTE', '3',                                '2026-02-14 11:00:00'),
(1, 11, 'CREACION_CONTRATO',    'Contrato de Soporte Técnico',      '2026-02-18 09:30:00'),
(1, 11, 'AGREGAR_PARTICIPANTE', '1',                                '2026-02-18 09:30:00'),
(2, 11, 'AGREGAR_PARTICIPANTE', '2',                                '2026-02-18 09:30:00'),
(1, 11, 'FIRMA',                '1',                                '2026-02-19 09:30:00'),
(2, 11, 'FIRMA',                '2',                                '2026-02-20 10:00:00'),
(1, 12, 'CREACION_CONTRATO',    'Contrato de Almacenamiento Cloud', '2026-02-22 14:00:00'),
(1, 12, 'AGREGAR_PARTICIPANTE', '1',                                '2026-02-22 14:00:00'),
(3, 12, 'AGREGAR_PARTICIPANTE', '3',                                '2026-02-22 14:00:00'),
(1, 12, 'FIRMA',                '1',                                '2026-02-24 14:00:00'),
(3, 12, 'FIRMA',                '3',                                '2026-02-25 11:00:00'),
(1, 12, 'VALIDACION',           '1',                                '2026-02-27 11:00:00'),
(2, 13, 'CREACION_CONTRATO',    'Contrato de Auditoría Externa',    '2026-02-25 10:00:00'),
(2, 13, 'AGREGAR_PARTICIPANTE', '2',                                '2026-02-25 10:00:00'),
(3, 13, 'AGREGAR_PARTICIPANTE', '3',                                '2026-02-25 10:00:00'),
(1, 14, 'CREACION_CONTRATO',    'Contrato de Integración API',      '2026-03-03 09:00:00'),
(1, 14, 'AGREGAR_PARTICIPANTE', '1',                                '2026-03-03 09:00:00'),
(2, 14, 'AGREGAR_PARTICIPANTE', '2',                                '2026-03-03 09:00:00'),
(1, 14, 'FIRMA',                '1',                                '2026-03-04 09:00:00'),
(2, 14, 'FIRMA',                '2',                                '2026-03-05 14:00:00'),
(1, 15, 'CREACION_CONTRATO',    'Acuerdo de Transferencia de Datos','2026-03-07 11:00:00'),
(1, 15, 'AGREGAR_PARTICIPANTE', '1',                                '2026-03-07 11:00:00'),
(3, 15, 'AGREGAR_PARTICIPANTE', '3',                                '2026-03-07 11:00:00'),
(1, 15, 'FIRMA',                '1',                                '2026-03-09 11:00:00'),
(3, 15, 'FIRMA',                '3',                                '2026-03-10 15:00:00'),
(1, 15, 'VALIDACION',           '1',                                '2026-03-12 15:00:00'),
(2, 16, 'CREACION_CONTRATO',    'Contrato de Capacitación',         '2026-03-10 08:00:00'),
(2, 16, 'AGREGAR_PARTICIPANTE', '2',                                '2026-03-10 08:00:00'),
(3, 16, 'AGREGAR_PARTICIPANTE', '3',                                '2026-03-10 08:00:00'),
(1, 17, 'CREACION_CONTRATO',    'Contrato de Migración Cloud',      '2026-03-14 10:00:00'),
(1, 17, 'AGREGAR_PARTICIPANTE', '1',                                '2026-03-14 10:00:00'),
(2, 17, 'AGREGAR_PARTICIPANTE', '2',                                '2026-03-14 10:00:00'),
(1, 17, 'FIRMA',                '1',                                '2026-03-15 10:00:00'),
(2, 17, 'FIRMA',                '2',                                '2026-03-16 12:00:00'),
(1, 18, 'CREACION_CONTRATO',    'Contrato de Backup y Recuperación','2026-03-18 09:00:00'),
(1, 18, 'AGREGAR_PARTICIPANTE', '1',                                '2026-03-18 09:00:00'),
(2, 18, 'AGREGAR_PARTICIPANTE', '2',                                '2026-03-18 09:00:00'),
(1, 18, 'FIRMA',                '1',                                '2026-03-20 09:00:00'),
(2, 18, 'FIRMA',                '2',                                '2026-03-22 10:00:00'),
(1, 18, 'VALIDACION',           '1',                                '2026-03-24 10:00:00'),
(2, 19, 'CREACION_CONTRATO',    'Contrato de Seguridad Perimetral', '2026-03-20 11:00:00'),
(2, 19, 'AGREGAR_PARTICIPANTE', '2',                                '2026-03-20 11:00:00'),
(3, 19, 'AGREGAR_PARTICIPANTE', '3',                                '2026-03-20 11:00:00'),
(1, 20, 'CREACION_CONTRATO',    'Acuerdo de Co-Desarrollo',         '2026-03-24 08:30:00'),
(1, 20, 'AGREGAR_PARTICIPANTE', '1',                                '2026-03-24 08:30:00'),
(3, 20, 'AGREGAR_PARTICIPANTE', '3',                                '2026-03-24 08:30:00'),
(1, 20, 'FIRMA',                '1',                                '2026-03-25 08:30:00'),
(3, 20, 'FIRMA',                '3',                                '2026-03-26 09:00:00'),
(1, 21, 'CREACION_CONTRATO',    'Contrato de Análisis de Datos',    '2026-03-27 10:00:00'),
(1, 21, 'AGREGAR_PARTICIPANTE', '1',                                '2026-03-27 10:00:00'),
(2, 21, 'AGREGAR_PARTICIPANTE', '2',                                '2026-03-27 10:00:00'),
(1, 21, 'FIRMA',                '1',                                '2026-03-29 10:00:00'),
(2, 21, 'FIRMA',                '2',                                '2026-03-30 14:00:00'),
(1, 21, 'VALIDACION',           '1',                                '2026-04-02 14:00:00'),
(2, 22, 'CREACION_CONTRATO',    'Contrato de Monitoreo 24/7',       '2026-04-01 09:00:00'),
(2, 22, 'AGREGAR_PARTICIPANTE', '2',                                '2026-04-01 09:00:00'),
(3, 22, 'AGREGAR_PARTICIPANTE', '3',                                '2026-04-01 09:00:00'),
(1, 23, 'CREACION_CONTRATO',    'Contrato de Gestión de Identidades','2026-04-04 11:00:00'),
(1, 23, 'AGREGAR_PARTICIPANTE', '1',                                '2026-04-04 11:00:00'),
(2, 23, 'AGREGAR_PARTICIPANTE', '2',                                '2026-04-04 11:00:00'),
(1, 23, 'FIRMA',                '1',                                '2026-04-05 11:00:00'),
(2, 23, 'FIRMA',                '2',                                '2026-04-06 13:00:00'),
(1, 24, 'CREACION_CONTRATO',    'Acuerdo de Pruebas de Penetración','2026-04-07 08:00:00'),
(1, 24, 'AGREGAR_PARTICIPANTE', '1',                                '2026-04-07 08:00:00'),
(3, 24, 'AGREGAR_PARTICIPANTE', '3',                                '2026-04-07 08:00:00'),
(1, 24, 'FIRMA',                '1',                                '2026-04-09 08:00:00'),
(3, 24, 'FIRMA',                '3',                                '2026-04-10 16:00:00'),
(1, 24, 'VALIDACION',           '1',                                '2026-04-11 16:00:00'),
(2, 25, 'CREACION_CONTRATO',    'Contrato de DevOps Gestionado',    '2026-04-10 10:00:00'),
(2, 25, 'AGREGAR_PARTICIPANTE', '2',                                '2026-04-10 10:00:00'),
(3, 25, 'AGREGAR_PARTICIPANTE', '3',                                '2026-04-10 10:00:00'),
(1, 26, 'CREACION_CONTRATO',    'Contrato de Virtualización',       '2026-04-14 09:30:00'),
(1, 26, 'AGREGAR_PARTICIPANTE', '1',                                '2026-04-14 09:30:00'),
(2, 26, 'AGREGAR_PARTICIPANTE', '2',                                '2026-04-14 09:30:00'),
(1, 26, 'FIRMA',                '1',                                '2026-04-15 09:30:00'),
(2, 26, 'FIRMA',                '2',                                '2026-04-16 11:00:00'),
(1, 27, 'CREACION_CONTRATO',    'Contrato de Mensajería Empresarial','2026-04-17 11:00:00'),
(1, 27, 'AGREGAR_PARTICIPANTE', '1',                                '2026-04-17 11:00:00'),
(2, 27, 'AGREGAR_PARTICIPANTE', '2',                                '2026-04-17 11:00:00'),
(1, 27, 'FIRMA',                '1',                                '2026-04-19 11:00:00'),
(2, 27, 'FIRMA',                '2',                                '2026-04-20 14:00:00'),
(1, 27, 'VALIDACION',           '1',                                '2026-04-22 14:00:00'),
(2, 28, 'CREACION_CONTRATO',    'Acuerdo de Gestión de Incidentes', '2026-04-21 08:00:00'),
(2, 28, 'AGREGAR_PARTICIPANTE', '2',                                '2026-04-21 08:00:00'),
(3, 28, 'AGREGAR_PARTICIPANTE', '3',                                '2026-04-21 08:00:00'),
(1, 29, 'CREACION_CONTRATO',    'Contrato de Recuperación de Datos','2026-04-24 10:00:00'),
(1, 29, 'AGREGAR_PARTICIPANTE', '1',                                '2026-04-24 10:00:00'),
(3, 29, 'AGREGAR_PARTICIPANTE', '3',                                '2026-04-24 10:00:00'),
(1, 29, 'FIRMA',                '1',                                '2026-04-25 10:00:00'),
(3, 29, 'FIRMA',                '3',                                '2026-04-26 12:00:00'),
(1, 30, 'CREACION_CONTRATO',    'Contrato de Automatización RPA',   '2026-04-28 09:00:00'),
(1, 30, 'AGREGAR_PARTICIPANTE', '1',                                '2026-04-28 09:00:00'),
(2, 30, 'AGREGAR_PARTICIPANTE', '2',                                '2026-04-28 09:00:00'),
(1, 30, 'FIRMA',                '1',                                '2026-04-30 09:00:00'),
(2, 30, 'FIRMA',                '2',                                '2026-05-01 10:00:00'),
(1, 30, 'VALIDACION',           '1',                                '2026-05-02 10:00:00'),
(2, 31, 'CREACION_CONTRATO',    'Acuerdo de Licenciamiento Masivo', '2026-05-02 11:00:00'),
(2, 31, 'AGREGAR_PARTICIPANTE', '2',                                '2026-05-02 11:00:00'),
(3, 31, 'AGREGAR_PARTICIPANTE', '3',                                '2026-05-02 11:00:00'),
(1, 32, 'CREACION_CONTRATO',    'Contrato de Red WAN',              '2026-05-04 09:00:00'),
(1, 32, 'AGREGAR_PARTICIPANTE', '1',                                '2026-05-04 09:00:00'),
(2, 32, 'AGREGAR_PARTICIPANTE', '2',                                '2026-05-04 09:00:00'),
(1, 32, 'FIRMA',                '1',                                '2026-05-05 09:00:00'),
(2, 32, 'FIRMA',                '2',                                '2026-05-06 11:00:00'),
(1, 33, 'CREACION_CONTRATO',    'Contrato de Cumplimiento Normativo','2026-05-05 08:30:00'),
(1, 33, 'AGREGAR_PARTICIPANTE', '1',                                '2026-05-05 08:30:00'),
(3, 33, 'AGREGAR_PARTICIPANTE', '3',                                '2026-05-05 08:30:00'),
(1, 33, 'FIRMA',                '1',                                '2026-05-07 08:30:00'),
(3, 33, 'FIRMA',                '3',                                '2026-05-08 14:00:00'),
(1, 33, 'VALIDACION',           '1',                                '2026-05-09 14:00:00'),
(2, 34, 'CREACION_CONTRATO',    'Contrato de Hosting Dedicado',     '2026-05-06 10:00:00'),
(2, 34, 'AGREGAR_PARTICIPANTE', '2',                                '2026-05-06 10:00:00'),
(3, 34, 'AGREGAR_PARTICIPANTE', '3',                                '2026-05-06 10:00:00'),
(1, 35, 'CREACION_CONTRATO',    'Acuerdo de Teletrabajo Seguro',    '2026-05-07 09:00:00'),
(1, 35, 'AGREGAR_PARTICIPANTE', '1',                                '2026-05-07 09:00:00'),
(2, 35, 'AGREGAR_PARTICIPANTE', '2',                                '2026-05-07 09:00:00'),
(1, 35, 'FIRMA',                '1',                                '2026-05-08 09:00:00'),
(2, 35, 'FIRMA',                '2',                                '2026-05-08 12:00:00'),
(1, 36, 'CREACION_CONTRATO',    'Contrato de Digitalización',       '2026-05-08 11:00:00'),
(1, 36, 'AGREGAR_PARTICIPANTE', '1',                                '2026-05-08 11:00:00'),
(2, 36, 'AGREGAR_PARTICIPANTE', '2',                                '2026-05-08 11:00:00'),
(1, 36, 'FIRMA',                '1',                                '2026-05-09 11:00:00'),
(2, 36, 'FIRMA',                '2',                                '2026-05-09 15:00:00'),
(1, 36, 'VALIDACION',           '1',                                '2026-05-09 15:00:00'),
(2, 37, 'CREACION_CONTRATO',    'Contrato de BI y Reportería',      '2026-05-09 08:00:00'),
(2, 37, 'AGREGAR_PARTICIPANTE', '2',                                '2026-05-09 08:00:00'),
(3, 37, 'AGREGAR_PARTICIPANTE', '3',                                '2026-05-09 08:00:00'),
(1, 38, 'CREACION_CONTRATO',    'Contrato de Gestión Documental',   '2026-05-09 10:00:00'),
(1, 38, 'AGREGAR_PARTICIPANTE', '1',                                '2026-05-09 10:00:00'),
(3, 38, 'AGREGAR_PARTICIPANTE', '3',                                '2026-05-09 10:00:00'),
(1, 38, 'FIRMA',                '1',                                '2026-05-10 10:00:00'),
(3, 38, 'FIRMA',                '3',                                '2026-05-10 13:00:00'),
(2, 39, 'CREACION_CONTRATO',    'Acuerdo de Continuidad de Negocio','2026-05-10 09:00:00'),
(2, 39, 'AGREGAR_PARTICIPANTE', '2',                                '2026-05-10 09:00:00'),
(3, 39, 'AGREGAR_PARTICIPANTE', '3',                                '2026-05-10 09:00:00'),
(1, 40, 'CREACION_CONTRATO',    'Contrato de IoT Industrial',       '2026-05-10 11:00:00'),
(1, 40, 'AGREGAR_PARTICIPANTE', '1',                                '2026-05-10 11:00:00'),
(2, 40, 'AGREGAR_PARTICIPANTE', '2',                                '2026-05-10 11:00:00'),
(1, 40, 'FIRMA',                '1',                                '2026-05-11 11:00:00'),
(2, 40, 'FIRMA',                '2',                                '2026-05-11 14:00:00'),
(1, 41, 'CREACION_CONTRATO',    'Contrato de Blockchain Privada',   '2026-05-10 14:00:00'),
(1, 41, 'AGREGAR_PARTICIPANTE', '1',                                '2026-05-10 14:00:00'),
(2, 41, 'AGREGAR_PARTICIPANTE', '2',                                '2026-05-10 14:00:00');
