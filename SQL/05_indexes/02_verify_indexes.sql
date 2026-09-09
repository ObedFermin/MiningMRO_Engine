/* ======================================================================================
   PROYECTO   : Mining MRO Analytics Engine
   MODULO     : 05_indexes
   OBJETO     : 02_verify_indexes.sql
   ESTANDAR   : ANSI SQL / T-SQL 2022
   DESCRIPCION: Auditoría y certificación de índices activos en el motor relacional.
   ====================================================================================== */

SELECT 
    s.name AS Esquema,
    t.name AS Tabla,
    i.name AS Nombre_Indice,
    i.type_desc AS Tipo_Indice,
    i.is_primary_key AS Es_PK
FROM sys.indexes i
INNER JOIN sys.tables t ON t.object_id = i.object_id
INNER JOIN sys.schemas s ON s.schema_id = t.schema_id
WHERE s.name IN ('stg', 'audit')
  AND i.name IS NOT NULL
ORDER BY s.name, t.name, i.type_desc;