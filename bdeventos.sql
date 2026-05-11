-- =============================================================
--  BASE DE DATOS: EMPRESA DE EVENTOS
--  Archivo : bdeventos.sql
--  Motor   : MySQL 8.0+
--  Creado  : 2026
-- =============================================================

CREATE DATABASE IF NOT EXISTS bdeventos
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

USE bdeventos;

-- -------------------------------------------------------------
-- 1. VENUE  (debe existir antes que EVENTO y ESPACIO)
-- -------------------------------------------------------------
CREATE TABLE venue (
    id_venue        INT             NOT NULL AUTO_INCREMENT,
    nombre          VARCHAR(150)    NOT NULL,
    direccion       VARCHAR(250)    NOT NULL,
    ciudad          VARCHAR(100)    NOT NULL,
    pais            VARCHAR(80)     NOT NULL DEFAULT 'México',
    capacidad_max   INT             NOT NULL,
    telefono        VARCHAR(20),
    email           VARCHAR(120),
    CONSTRAINT pk_venue PRIMARY KEY (id_venue)
) ENGINE=InnoDB;

-- -------------------------------------------------------------
-- 2. ESPACIO  (sala, auditorio, área dentro del venue)
-- -------------------------------------------------------------
CREATE TABLE espacio (
    id_espacio      INT             NOT NULL AUTO_INCREMENT,
    nombre          VARCHAR(100)    NOT NULL,
    tipo            ENUM('auditorio','sala','patio','lobby','otro') NOT NULL DEFAULT 'sala',
    capacidad       INT             NOT NULL,
    equipamiento    TEXT,
    id_venue        INT             NOT NULL,
    CONSTRAINT pk_espacio   PRIMARY KEY (id_espacio),
    CONSTRAINT fk_esp_venue FOREIGN KEY (id_venue)
        REFERENCES venue (id_venue)
        ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB;

-- -------------------------------------------------------------
-- 3. EVENTO
-- -------------------------------------------------------------
CREATE TABLE evento (
    id_evento       INT             NOT NULL AUTO_INCREMENT,
    nombre          VARCHAR(150)    NOT NULL,
    descripcion     TEXT,
    tipo            ENUM('conferencia','congreso','taller','seminario','feria','otro') NOT NULL,
    fecha_inicio    DATE            NOT NULL,
    fecha_fin       DATE            NOT NULL,
    capacidad_max   INT             NOT NULL,
    estado          ENUM('planeado','activo','cancelado','finalizado') NOT NULL DEFAULT 'planeado',
    id_venue        INT             NOT NULL,
    CONSTRAINT pk_evento    PRIMARY KEY (id_evento),
    CONSTRAINT fk_ev_venue  FOREIGN KEY (id_venue)
        REFERENCES venue (id_venue)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT chk_fechas   CHECK (fecha_fin >= fecha_inicio)
) ENGINE=InnoDB;

-- -------------------------------------------------------------
-- 4. SESION  (bloque / charla / taller dentro del evento)
-- -------------------------------------------------------------
CREATE TABLE sesion (
    id_sesion       INT             NOT NULL AUTO_INCREMENT,
    titulo          VARCHAR(200)    NOT NULL,
    descripcion     TEXT,
    hora_inicio     DATETIME        NOT NULL,
    hora_fin        DATETIME        NOT NULL,
    modalidad       ENUM('presencial','virtual','hibrida') NOT NULL DEFAULT 'presencial',
    id_evento       INT             NOT NULL,
    id_espacio      INT             NOT NULL,
    CONSTRAINT pk_sesion        PRIMARY KEY (id_sesion),
    CONSTRAINT fk_ses_evento    FOREIGN KEY (id_evento)
        REFERENCES evento (id_evento)
        ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT fk_ses_espacio   FOREIGN KEY (id_espacio)
        REFERENCES espacio (id_espacio)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT chk_horas        CHECK (hora_fin > hora_inicio)
) ENGINE=InnoDB;

-- -------------------------------------------------------------
-- 5. CLIENTE  (asistente / comprador de ticket)
-- -------------------------------------------------------------
CREATE TABLE cliente (
    id_cliente      INT             NOT NULL AUTO_INCREMENT,
    nombre          VARCHAR(100)    NOT NULL,
    email           VARCHAR(120)    NOT NULL,
    telefono        VARCHAR(20),
    empresa         VARCHAR(120),
    ciudad          VARCHAR(100),
    fecha_registro  DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT pk_cliente   PRIMARY KEY (id_cliente),
    CONSTRAINT uq_cli_email UNIQUE (email)
) ENGINE=InnoDB;

-- -------------------------------------------------------------
-- 6. INSCRIPCION  (cliente se registra a un evento)
-- -------------------------------------------------------------
CREATE TABLE inscripcion (
    id_inscripcion      INT             NOT NULL AUTO_INCREMENT,
    fecha_inscripcion   DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
    tipo_ticket         ENUM('general','vip','ponente','staff','cortesia') NOT NULL DEFAULT 'general',
    monto               DECIMAL(10,2)   NOT NULL DEFAULT 0.00,
    estado              ENUM('pendiente','confirmada','cancelada') NOT NULL DEFAULT 'pendiente',
    id_cliente          INT             NOT NULL,
    id_evento           INT             NOT NULL,
    CONSTRAINT pk_inscripcion   PRIMARY KEY (id_inscripcion),
    CONSTRAINT fk_ins_cliente   FOREIGN KEY (id_cliente)
        REFERENCES cliente (id_cliente)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_ins_evento    FOREIGN KEY (id_evento)
        REFERENCES evento (id_evento)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT uq_ins           UNIQUE (id_cliente, id_evento)
) ENGINE=InnoDB;

-- -------------------------------------------------------------
-- 7. PAGO  (transacción ligada a una inscripción)
-- -------------------------------------------------------------
CREATE TABLE pago (
    id_pago         INT             NOT NULL AUTO_INCREMENT,
    fecha_pago      DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
    metodo          ENUM('tarjeta','transferencia','efectivo','paypal','otro') NOT NULL,
    monto           DECIMAL(10,2)   NOT NULL,
    moneda          CHAR(3)         NOT NULL DEFAULT 'MXN',
    referencia      VARCHAR(100),
    estado          ENUM('completado','rechazado','reembolsado','pendiente') NOT NULL DEFAULT 'pendiente',
    id_inscripcion  INT             NOT NULL,
    CONSTRAINT pk_pago          PRIMARY KEY (id_pago),
    CONSTRAINT fk_pago_insc     FOREIGN KEY (id_inscripcion)
        REFERENCES inscripcion (id_inscripcion)
        ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB;

-- -------------------------------------------------------------
-- 8. PONENTE  (expositor / speaker)
-- -------------------------------------------------------------
CREATE TABLE ponente (
    id_ponente      INT             NOT NULL AUTO_INCREMENT,
    nombre          VARCHAR(100)    NOT NULL,
    email           VARCHAR(120)    NOT NULL,
    telefono        VARCHAR(20),
    especialidad    VARCHAR(150),
    bio             TEXT,
    url_foto        VARCHAR(250),
    CONSTRAINT pk_ponente   PRIMARY KEY (id_ponente),
    CONSTRAINT uq_pon_email UNIQUE (email)
) ENGINE=InnoDB;

-- -------------------------------------------------------------
-- 9. STAFF  (personal operativo)
-- -------------------------------------------------------------
CREATE TABLE staff (
    id_staff        INT             NOT NULL AUTO_INCREMENT,
    nombre          VARCHAR(100)    NOT NULL,
    rol             ENUM('coordinador','logistica','registro','seguridad','audiovisual','otro') NOT NULL,
    email           VARCHAR(120)    NOT NULL,
    telefono        VARCHAR(20),
    disponibilidad  TEXT,
    CONSTRAINT pk_staff     PRIMARY KEY (id_staff),
    CONSTRAINT uq_stf_email UNIQUE (email)
) ENGINE=InnoDB;

-- -------------------------------------------------------------
-- 10. PROVEEDOR  (empresa externa de servicios)
-- -------------------------------------------------------------
CREATE TABLE proveedor (
    id_proveedor    INT             NOT NULL AUTO_INCREMENT,
    nombre          VARCHAR(150)    NOT NULL,
    tipo_servicio   ENUM('catering','audiovisual','seguridad','limpieza','decoracion','transporte','otro') NOT NULL,
    contacto        VARCHAR(100),
    telefono        VARCHAR(20),
    email           VARCHAR(120),
    costo_estimado  DECIMAL(12,2),
    contrato_url    VARCHAR(250),
    CONSTRAINT pk_proveedor PRIMARY KEY (id_proveedor)
) ENGINE=InnoDB;

-- =============================================================
--  TABLAS DE RELACION  (muchos a muchos)
-- =============================================================

-- -------------------------------------------------------------
-- R1. SESION_PONENTE  (una sesión puede tener varios ponentes)
-- -------------------------------------------------------------
CREATE TABLE sesion_ponente (
    id_sesion       INT     NOT NULL,
    id_ponente      INT     NOT NULL,
    orden           TINYINT NOT NULL DEFAULT 1 COMMENT 'Orden de presentación',
    CONSTRAINT pk_ses_pon   PRIMARY KEY (id_sesion, id_ponente),
    CONSTRAINT fk_sp_sesion FOREIGN KEY (id_sesion)
        REFERENCES sesion (id_sesion)
        ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT fk_sp_ponente FOREIGN KEY (id_ponente)
        REFERENCES ponente (id_ponente)
        ON UPDATE CASCADE ON DELETE CASCADE
) ENGINE=InnoDB;

-- -------------------------------------------------------------
-- R2. EVENTO_STAFF  (staff asignado por evento)
-- -------------------------------------------------------------
CREATE TABLE evento_staff (
    id_evento       INT             NOT NULL,
    id_staff        INT             NOT NULL,
    fecha_asignacion DATE           NOT NULL DEFAULT (CURDATE()),
    notas           VARCHAR(250),
    CONSTRAINT pk_ev_stf    PRIMARY KEY (id_evento, id_staff),
    CONSTRAINT fk_es_evento FOREIGN KEY (id_evento)
        REFERENCES evento (id_evento)
        ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT fk_es_staff  FOREIGN KEY (id_staff)
        REFERENCES staff (id_staff)
        ON UPDATE CASCADE ON DELETE CASCADE
) ENGINE=InnoDB;

-- -------------------------------------------------------------
-- R3. EVENTO_PROVEEDOR  (proveedores contratados por evento)
-- -------------------------------------------------------------
CREATE TABLE evento_proveedor (
    id_evento           INT             NOT NULL,
    id_proveedor        INT             NOT NULL,
    fecha_contratacion  DATE            NOT NULL DEFAULT (CURDATE()),
    costo_acordado      DECIMAL(12,2),
    estado_contrato     ENUM('cotizado','firmado','finalizado','cancelado') NOT NULL DEFAULT 'cotizado',
    CONSTRAINT pk_ev_prov   PRIMARY KEY (id_evento, id_proveedor),
    CONSTRAINT fk_ep_evento FOREIGN KEY (id_evento)
        REFERENCES evento (id_evento)
        ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT fk_ep_prov   FOREIGN KEY (id_proveedor)
        REFERENCES proveedor (id_proveedor)
        ON UPDATE CASCADE ON DELETE CASCADE
) ENGINE=InnoDB;

-- =============================================================
--  INDICES ADICIONALES  (mejoran consultas frecuentes)
-- =============================================================
CREATE INDEX idx_evento_fecha    ON evento      (fecha_inicio, fecha_fin);
CREATE INDEX idx_evento_estado   ON evento      (estado);
CREATE INDEX idx_sesion_evento   ON sesion      (id_evento);
CREATE INDEX idx_insc_cliente    ON inscripcion (id_cliente);
CREATE INDEX idx_insc_evento     ON inscripcion (id_evento);
CREATE INDEX idx_insc_estado     ON inscripcion (estado);
CREATE INDEX idx_pago_insc       ON pago        (id_inscripcion);
CREATE INDEX idx_pago_estado     ON pago        (estado);

-- =============================================================
--  DATOS DE PRUEBA (seed básico)
-- =============================================================

INSERT INTO venue (nombre, direccion, ciudad, pais, capacidad_max, telefono, email) VALUES
('Centro de Convenciones Norte', 'Av. Tecnológico 1500', 'Monterrey', 'México', 3000, '8181234567', 'info@ccnorte.mx'),
('Hotel Gran Plaza', 'Blvd. Independencia 200', 'Ciudad Juárez', 'México', 800, '6561234567', 'eventos@granplaza.mx');

INSERT INTO espacio (nombre, tipo, capacidad, equipamiento, id_venue) VALUES
('Auditorio Principal', 'auditorio', 1500, 'Proyector 4K, sistema de sonido, streaming', 1),
('Sala A', 'sala', 200, 'Proyector, pizarrón, videoconferencia', 1),
('Sala B', 'sala', 200, 'Proyector, pizarrón', 1),
('Salón Imperial', 'auditorio', 600, 'Proyector, micrófono inalámbrico', 2);

INSERT INTO evento (nombre, tipo, fecha_inicio, fecha_fin, capacidad_max, estado, id_venue) VALUES
('TechSummit 2026', 'conferencia', '2026-09-15', '2026-09-17', 1200, 'planeado', 1),
('Taller de Innovación Empresarial', 'taller', '2026-10-05', '2026-10-05', 80, 'planeado', 2);

INSERT INTO ponente (nombre, email, especialidad, bio) VALUES
('Dra. Laura Méndez', 'laura.mendez@ejemplo.mx', 'Inteligencia Artificial', 'Investigadora con 15 años en ML aplicado a negocios.'),
('Ing. Carlos Vega', 'carlos.vega@ejemplo.mx', 'Ciberseguridad', 'Consultor de seguridad para empresas Fortune 500.'),
('Mtra. Ana Torres', 'ana.torres@ejemplo.mx', 'Gestión de Proyectos', 'PMP certificada, 12 años liderando equipos ágiles.');

INSERT INTO sesion (titulo, hora_inicio, hora_fin, modalidad, id_evento, id_espacio) VALUES
('IA Generativa en los Negocios', '2026-09-15 09:00:00', '2026-09-15 10:30:00', 'presencial', 1, 1),
('Ciberseguridad para PYMEs',    '2026-09-15 11:00:00', '2026-09-15 12:30:00', 'presencial', 1, 2),
('Metodologías Ágiles en la Práctica', '2026-10-05 10:00:00', '2026-10-05 13:00:00', 'presencial', 2, 4);

INSERT INTO sesion_ponente (id_sesion, id_ponente, orden) VALUES
(1, 1, 1),
(2, 2, 1),
(3, 3, 1);

INSERT INTO cliente (nombre, email, telefono, empresa, ciudad) VALUES
('Roberto Sánchez', 'roberto.sanchez@empresa.mx', '6561119900', 'Grupo Industrial Norte', 'Ciudad Juárez'),
('María Fernanda López', 'mflopez@startup.io', '8181234000', 'StartupIO', 'Monterrey'),
('Jorge Ibarra', 'j.ibarra@correo.mx', '6143456789', NULL, 'Chihuahua');

INSERT INTO inscripcion (tipo_ticket, monto, estado, id_cliente, id_evento) VALUES
('vip',     2500.00, 'confirmada', 1, 1),
('general', 1200.00, 'confirmada', 2, 1),
('general',  800.00, 'pendiente',  3, 2);

INSERT INTO pago (metodo, monto, moneda, referencia, estado, id_inscripcion) VALUES
('tarjeta',      2500.00, 'MXN', 'TXN-20260901-001', 'completado', 1),
('transferencia',1200.00, 'MXN', 'TXN-20260902-045', 'completado', 2);

INSERT INTO staff (nombre, rol, email, telefono) VALUES
('Pedro Ramírez', 'coordinador', 'pedro.r@empresa.mx', '8181000001'),
('Sofía Castillo', 'registro',   'sofia.c@empresa.mx', '8181000002'),
('Luis Morales',  'logistica',   'luis.m@empresa.mx',  '8181000003');

INSERT INTO evento_staff (id_evento, id_staff) VALUES
(1, 1), (1, 2), (1, 3),
(2, 1), (2, 2);

INSERT INTO proveedor (nombre, tipo_servicio, contacto, telefono, email, costo_estimado) VALUES
('Catering Deluxe SA', 'catering',    'Marco Juárez', '8186540001', 'marco@cateringdeluxe.mx', 45000.00),
('AudioPro Eventos',   'audiovisual', 'Sandra Gil',   '8186540002', 'sandra@audiopro.mx',       28000.00);

INSERT INTO evento_proveedor (id_evento, id_proveedor, costo_acordado, estado_contrato) VALUES
(1, 1, 45000.00, 'firmado'),
(1, 2, 28000.00, 'firmado'),
(2, 1, 12000.00, 'cotizado');

-- =============================================================
--  FIN DEL SCRIPT
-- =============================================================
