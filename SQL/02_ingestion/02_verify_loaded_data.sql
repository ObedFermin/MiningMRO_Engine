/* ======================================================================================
   PROYECTO   : Mining MRO Analytics Engine
   MODULO     : 02_ingestion
   OBJETO     : 02_verify_loaded_data.sql
   ESTANDAR   : ANSI SQL / T-SQL 2022
   DESCRIPCION: Certificación de integridad de carga volumétrica en tablas staging SAP MM.
   ====================================================================================== */

USE Bunker_MRO;

SELECT 
    'stg.EKKO' AS Objeto_SAP, 
    COUNT(*) AS Total_Registros, 
    'Cabeceras de OC' AS Descripcion
FROM stg.EKKO
UNION ALL
SELECT 
    'stg.EKPO', 
    COUNT(*), 
    'Posiciones / Repuestos Solicitados'
FROM stg.EKPO
UNION ALL
SELECT 
    'stg.EKBE', 
    COUNT(*), 
    'Movimientos MIGO/MIRO'
FROM stg.EKBE
UNION ALL
SELECT 
    'stg.MARD', 
    COUNT(*), 
    'Saldos de Bodega / SPEME'
FROM stg.MARD;