/* ======================================================================================
   PROYECTO   : Mining MRO Analytics Engine
   MODULO     : 01_ddl_tables
   OBJETO     : stg.MARD
   ESTANDAR   : ANSI SQL / T-SQL 2022
   DESCRIPCION: Datos de inventario por material, centro logístico y estado de calidad.
   ====================================================================================== */

USE Bunker_MRO;

DROP TABLE IF EXISTS stg.MARD;

CREATE TABLE stg.MARD (
    matnr VARCHAR(50)   NOT NULL,    -- Código del repuesto / componente crítico
    werks VARCHAR(10)   NOT NULL,    -- Centro logístico / Faena
    lgort VARCHAR(10)   NOT NULL,    -- Almacén específico
    labst DECIMAL(12,2) NOT NULL,    -- Stock valorizado de libre utilización
    speme DECIMAL(12,2) NOT NULL,    -- Stock bloqueado en control de calidad (SPEME)
    CONSTRAINT PK_stg_mard PRIMARY KEY CLUSTERED (matnr, werks, lgort)
);