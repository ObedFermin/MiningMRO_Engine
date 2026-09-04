/* ======================================================================================
   PROYECTO   : Mining MRO Analytics Engine
   MODULO     : 01_ddl_tables
   OBJETO     : 06_verify_tables_pk.sql
   ESTANDAR   : ANSI SQL / T-SQL 2022
   DESCRIPCION: Auditoría de integridad de objetos DDL y claves primarias (PK).
   ====================================================================================== */

USE Bunker_MRO;

SELECT 
    s.name AS Esquema,
    t.name AS Tabla,
    kc.name AS Restriccion_PK,
    t.create_date AS Fecha_Creacion
FROM sys.tables t
INNER JOIN sys.schemas s ON s.schema_id = t.schema_id
LEFT JOIN sys.key_constraints kc ON kc.parent_object_id = t.object_id AND kc.type = 'PK'
WHERE s.name IN ('stg', 'audit')
ORDER BY s.name, t.name;