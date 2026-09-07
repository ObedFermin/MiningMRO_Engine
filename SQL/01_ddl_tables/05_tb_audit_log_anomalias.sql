/* ======================================================================================
   PROYECTO   : Mining MRO Analytics Engine
   MODULO     : 01_ddl_tables
   OBJETO     : 05_tb_audit_log_anomalias.sql
   ESTANDAR   : ANSI SQL / T-SQL 2022
   DESCRIPCION: Tabla de persistencia para trazabilidad de descalces y fugas financieras.
   ====================================================================================== */

USE Bunker_MRO;

DROP TABLE IF EXISTS audit.tb_log_anomalias_mro;

CREATE TABLE audit.tb_log_anomalias_mro (
    id_anomalia     INT IDENTITY(1,1) NOT NULL,
    ebeln           VARCHAR(20)       NOT NULL,  -- Orden de compra auditada
    ebelp           INT               NOT NULL,  -- Posición auditada
    tipo_descalce   VARCHAR(50)       NOT NULL,  -- MAVERICK_BUYING, QUANTITY_MISMATCH, etc.
    fuga_usd        DECIMAL(18,2)     NOT NULL,  -- Impacto financiero calculado en USD
    fecha_deteccion DATETIME2(0)      NOT NULL DEFAULT SYSDATETIME(),
    estado_revision VARCHAR(20)       NOT NULL DEFAULT 'PENDIENTE',
    CONSTRAINT PK_audit_log_anomalias PRIMARY KEY CLUSTERED (id_anomalia)
);