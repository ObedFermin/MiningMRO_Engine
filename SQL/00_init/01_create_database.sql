/* ======================================================================================
   PROYECTO: Mining MRO Analytics Engine
   MODULO  : 00_init / 01_create_database.sql
   DESCRIP : Creación de BD Bunker_MRO y configuración de aislamiento RCSI para faena.
   ====================================================================================== */

IF NOT EXISTS (SELECT 1 FROM sys.databases WHERE name = 'Bunker_MRO')
    CREATE DATABASE Bunker_MRO;

-- Configuración de aislamiento RCSI (Read Committed Snapshot Isolation)
-- Evita bloqueos de lectura cuando Power BI extraiga datos mientras la base se actualiza
IF EXISTS (SELECT 1 FROM sys.databases WHERE name = 'Bunker_MRO' AND is_read_committed_snapshot_on = 0)
    EXEC('ALTER DATABASE Bunker_MRO SET READ_COMMITTED_SNAPSHOT ON WITH ROLLBACK IMMEDIATE;');
