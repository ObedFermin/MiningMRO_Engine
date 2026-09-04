/* ======================================================================================
   PROYECTO: Mining MRO Analytics Engine
   MODULO  : 00_init / 02_create_schemas.sql
   DESCRIP : Creación defensiva de esquemas arquitectónicos: stg, core y audit.
   ====================================================================================== */

USE Bunker_MRO;

-- Esquema stg: Tablas crudas y staging de SAP MM (EKKO, EKPO, EKBE, MARD)
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'stg')
    EXEC('CREATE SCHEMA stg');

-- Esquema core: Vistas de negocio, neteo transaccional y consumo para Power BI
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'core')
    EXEC('CREATE SCHEMA core');

-- Esquema audit: Tablas de logs, trazabilidad de excepciones y procedimientos de control
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'audit')
    EXEC('CREATE SCHEMA audit');

-- Bloque de verificación
SELECT 
    s.name AS Esquema, 
    dp.name AS Propietario
FROM sys.schemas s
INNER JOIN sys.database_principals dp ON dp.principal_id = s.principal_id
WHERE s.name IN ('stg', 'core', 'audit');