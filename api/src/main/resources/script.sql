DROP DATABASE IF EXISTS geoadopt;
CREATE DATABASE geoadopt
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_spanish_ci;
USE geoadopt;

-- -----------------------------------------------------
-- USUARIO
-- -----------------------------------------------------
CREATE TABLE usuario (
  id_usuario     INT UNSIGNED  NOT NULL AUTO_INCREMENT,
  nombre         VARCHAR(100)  NOT NULL,
  email          VARCHAR(150)  NOT NULL,
  password_hash  VARCHAR(255)  NOT NULL,
  telefono       VARCHAR(20)   NULL,
  rol            ENUM('USUARIO','REFUGIO','ADMIN') NOT NULL DEFAULT 'USUARIO',
  CONSTRAINT pk_usuario PRIMARY KEY (id_usuario),
  CONSTRAINT uq_usuario_email UNIQUE (email)
) ENGINE = InnoDB;

-- -----------------------------------------------------
-- REFUGIO
-- -----------------------------------------------------
CREATE TABLE refugio (
  id_refugio     INT UNSIGNED  NOT NULL AUTO_INCREMENT,
  id_usuario     INT UNSIGNED  NOT NULL,
  nombre         VARCHAR(150)  NOT NULL,
  cif            VARCHAR(9)    NOT NULL,
  direccion      VARCHAR(255)  NOT NULL,
  ubicacion      VARCHAR(100)  NULL,
  capacidad_max  INT UNSIGNED  NOT NULL,
  verificado     BOOLEAN       NOT NULL DEFAULT FALSE,
  CONSTRAINT pk_refugio PRIMARY KEY (id_refugio),
  CONSTRAINT uq_refugio_usuario UNIQUE (id_usuario),
  CONSTRAINT uq_refugio_cif UNIQUE (cif),
  CONSTRAINT chk_refugio_capacidad CHECK (capacidad_max > 0),
  CONSTRAINT fk_refugio_usuario FOREIGN KEY (id_usuario)
    REFERENCES usuario (id_usuario)
    ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE = InnoDB;

-- -----------------------------------------------------
-- REPORTE
-- -----------------------------------------------------
CREATE TABLE reporte (
  id_reporte   INT UNSIGNED  NOT NULL AUTO_INCREMENT,
  id_usuario   INT UNSIGNED  NOT NULL,
  id_refugio   INT UNSIGNED  NULL,
  especie      VARCHAR(50)   NOT NULL,
  descripcion  TEXT          NULL,
  ubicacion    VARCHAR(100)  NOT NULL,
  estado       ENUM('PENDIENTE','ASIGNADO','RESCATADO','CERRADO')
               NOT NULL DEFAULT 'PENDIENTE',
  fecha        DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT pk_reporte PRIMARY KEY (id_reporte),
  CONSTRAINT fk_reporte_usuario FOREIGN KEY (id_usuario)
    REFERENCES usuario (id_usuario)
    ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT fk_reporte_refugio FOREIGN KEY (id_refugio)
    REFERENCES refugio (id_refugio)
    ON UPDATE CASCADE ON DELETE SET NULL
) ENGINE = InnoDB;

-- -----------------------------------------------------
-- ANIMAL
-- -----------------------------------------------------
CREATE TABLE animal (
  id_animal     INT UNSIGNED  NOT NULL AUTO_INCREMENT,
  id_refugio    INT UNSIGNED  NOT NULL,
  id_reporte    INT UNSIGNED  NULL,
  nombre        VARCHAR(100)  NULL,
  especie       VARCHAR(50)   NOT NULL,
  sexo          ENUM('MACHO','HEMBRA','DESCONOCIDO') NOT NULL DEFAULT 'DESCONOCIDO',
  edad_aprox    VARCHAR(30)   NULL,
  tamano        ENUM('PEQUENO','MEDIANO','GRANDE') NULL,
  estado_salud  VARCHAR(255)  NULL,
  vacunado      BOOLEAN       NOT NULL DEFAULT FALSE,
  estado        ENUM('DISPONIBLE','EN_PROCESO','ADOPTADO')
                NOT NULL DEFAULT 'DISPONIBLE',
  CONSTRAINT pk_animal PRIMARY KEY (id_animal),
  CONSTRAINT uq_animal_reporte UNIQUE (id_reporte),
  CONSTRAINT fk_animal_refugio FOREIGN KEY (id_refugio)
    REFERENCES refugio (id_refugio)
    ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT fk_animal_reporte FOREIGN KEY (id_reporte)
    REFERENCES reporte (id_reporte)
    ON UPDATE CASCADE ON DELETE SET NULL
) ENGINE = InnoDB;

-- -----------------------------------------------------
-- FOTO
-- -----------------------------------------------------
CREATE TABLE foto (
  id_foto     INT UNSIGNED  NOT NULL AUTO_INCREMENT,
  id_reporte  INT UNSIGNED  NULL,
  id_animal   INT UNSIGNED  NULL,
  url         VARCHAR(500)  NOT NULL,
  CONSTRAINT pk_foto PRIMARY KEY (id_foto),
  CONSTRAINT chk_foto_pertenece CHECK (id_reporte IS NOT NULL OR id_animal IS NOT NULL),
  CONSTRAINT fk_foto_reporte FOREIGN KEY (id_reporte)
    REFERENCES reporte (id_reporte)
    ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT fk_foto_animal FOREIGN KEY (id_animal)
    REFERENCES animal (id_animal)
    ON UPDATE CASCADE ON DELETE CASCADE
) ENGINE = InnoDB;

-- -----------------------------------------------------
-- SOLICITUD_ADOPCION
-- -----------------------------------------------------
CREATE TABLE solicitud_adopcion (
  id_solicitud  INT UNSIGNED  NOT NULL AUTO_INCREMENT,
  id_usuario    INT UNSIGNED  NOT NULL,
  id_animal     INT UNSIGNED  NOT NULL,
  vivienda      VARCHAR(100)  NOT NULL,
  experiencia   TEXT          NULL,
  familia       VARCHAR(255)  NULL,
  estado        ENUM('PENDIENTE','APROBADA','RECHAZADA')
                NOT NULL DEFAULT 'PENDIENTE',
  fecha         DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT pk_solicitud PRIMARY KEY (id_solicitud),
  CONSTRAINT uq_solicitud_usuario_animal UNIQUE (id_usuario, id_animal),
  CONSTRAINT fk_solicitud_usuario FOREIGN KEY (id_usuario)
    REFERENCES usuario (id_usuario)
    ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT fk_solicitud_animal FOREIGN KEY (id_animal)
    REFERENCES animal (id_animal)
    ON UPDATE CASCADE ON DELETE CASCADE
) ENGINE = InnoDB;

-- -----------------------------------------------------
-- Índices para las FK más consultadas
-- -----------------------------------------------------
CREATE INDEX idx_reporte_usuario   ON reporte (id_usuario);
CREATE INDEX idx_reporte_refugio   ON reporte (id_refugio);
CREATE INDEX idx_animal_refugio    ON animal (id_refugio);
CREATE INDEX idx_animal_estado     ON animal (estado);
CREATE INDEX idx_foto_reporte      ON foto (id_reporte);
CREATE INDEX idx_foto_animal       ON foto (id_animal);
CREATE INDEX idx_solicitud_animal  ON solicitud_adopcion (id_animal);