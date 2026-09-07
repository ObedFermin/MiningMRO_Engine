/* ======================================================================================
   PROYECTO   : Mining MRO Analytics Engine
   MODULO     : 01_ddl_tables
   OBJETO     : 01_tb_stg_ekko.sql
   ESTANDAR   : ANSI SQL / T-SQL 2022
   DESCRIPCION: Tabla de staging para cabeceras de documentos de compras SAP MM.
   ====================================================================================== */

USE Bunker_MRO;

DROP TABLE IF EXISTS stg.EKKO;

CREATE TABLE stg.EKKO (
    ebeln VARCHAR(20) NOT NULL,      -- Número de Orden de Compra (Purchasing Document)
    bukrs VARCHAR(10) NOT NULL,      -- Sociedad / Entidad legal (Company Code)
    lifnr VARCHAR(50) NOT NULL,      -- Identificador de Proveedor OEM / Contratista
    aedat DATE        NOT NULL,      -- Fecha de creación / emisión del documento
    ekorg VARCHAR(10) NOT NULL,      -- Organización de compras minera
    CONSTRAINT PK_stg_ekko PRIMARY KEY CLUSTERED (ebeln)
);
