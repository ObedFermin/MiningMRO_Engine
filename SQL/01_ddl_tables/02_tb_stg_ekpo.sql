/* ======================================================================================
   PROYECTO   : Mining MRO Analytics Engine
   MODULO     : 01_ddl_tables
   OBJETO     : stg.EKPO
   ESTANDAR   : ANSI SQL / T-SQL 2022
   DESCRIPCION: Tabla de staging para posiciones y especificación de repuestos MRO.
   ====================================================================================== */

USE Bunker_MRO;

DROP TABLE IF EXISTS stg.EKPO;

CREATE TABLE stg.EKPO (
    ebeln VARCHAR(20)   NOT NULL,    -- Documento de compras padre
    ebelp INT           NOT NULL,    -- Posición de línea (Item Number)
    matnr VARCHAR(50)   NOT NULL,    -- Número de material / componente CAEX/Pala
    txz01 VARCHAR(100)  NOT NULL,    -- Texto descriptivo del activo o servicio
    werks VARCHAR(10)   NOT NULL,    -- Centro logístico / Faena operativa (Plant)
    lgort VARCHAR(10)   NOT NULL,    -- Almacén / Bodega de destino (Storage Location)
    menge DECIMAL(12,2) NOT NULL,    -- Cantidad total solicitada
    meins VARCHAR(10)   NOT NULL,    -- Unidad de medida base (ej. C/U, KG)
    netpr DECIMAL(18,2) NOT NULL,    -- Precio unitario pactado según contrato MARC
    peinh INT           NOT NULL,    -- Precio unitario base / factor de escala
    loekz CHAR(1)       NULL,        -- Indicador de borrado contable (X = Anulado)
    wepos CHAR(1)       NOT NULL,    -- Flag de recepción física esperada
    repos CHAR(1)       NOT NULL,    -- Flag de recepción de factura esperada
    CONSTRAINT PK_stg_ekpo PRIMARY KEY CLUSTERED (ebeln, ebelp)
);