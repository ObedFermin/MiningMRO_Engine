/* ======================================================================================
   PROYECTO   : Mining MRO Analytics Engine
   MODULO     : 01_ddl_tables
   OBJETO     : 03_tb_stg_ekbe.sql
   ESTANDAR   : ANSI SQL / T-SQL 2022
   DESCRIPCION: Historial transaccional de movimientos de mercancía (MIGO) y facturas (MIRO).
   ====================================================================================== */

USE Bunker_MRO;

DROP TABLE IF EXISTS stg.EKBE;

CREATE TABLE stg.EKBE (
    ebeln VARCHAR(20)   NOT NULL,    -- Documento de compras
    ebelp INT           NOT NULL,    -- Posición del documento
    belnr VARCHAR(20)   NOT NULL,    -- Folio contable (Guía de recepción o Factura)
    gjahr SMALLINT      NOT NULL,    -- Ejercicio contable / Año fiscal
    buzei INT           NOT NULL,    -- Apunte contable / Línea de movimiento
    vgabe TINYINT       NOT NULL,    -- Operación: 1 = Recepción física, 2 = Facturación
    bewtp CHAR(1)       NOT NULL,    -- Tipo de historial: E = Entrada, R = Factura
    bwart VARCHAR(10)   NULL,        -- Clase movimiento almacén (101=Entrada, 102=Reversa)
    budat DATE          NOT NULL,    -- Fecha de contabilización de la transacción
    menge DECIMAL(12,2) NOT NULL,    -- Cantidad movida o facturada en el evento
    wrbtr DECIMAL(18,2) NOT NULL,    -- Importe total facturado o valorizado en USD
    shkzg CHAR(1)       NOT NULL,    -- Código contable Debe/Haber (S = Cargo, H = Abono)
    CONSTRAINT PK_stg_ekbe PRIMARY KEY CLUSTERED (ebeln, ebelp, belnr, gjahr, buzei)
);