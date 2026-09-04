/* ======================================================================================
   PROYECTO   : Mining MRO Analytics Engine
   MODULO     : 05_indexes
   OBJETO     : 01_idx_mro_performance.sql
   ESTANDAR   : ANSI SQL / T-SQL 2022
   DESCRIPCION: Creación de índices Non-Clustered y Covering Indexes para acelerar 
                los cruces de 3-Way Match y la auditoría de inventario SPEME.
   ====================================================================================== */

USE Bunker_MRO;

-- 1. Optimización en Historial Transaccional (EKBE)
-- Acelera la agregación de las CTEs migo y miro filtradas por vgabe y shkzg
DROP INDEX IF EXISTS IX_stg_ekbe_3way_performance ON stg.EKBE;

CREATE NONCLUSTERED INDEX IX_stg_ekbe_3way_performance
ON stg.EKBE (ebeln, ebelp, vgabe)
INCLUDE (menge, wrbtr, shkzg);

-- 2. Optimización en Posiciones de Pedido (EKPO)
-- Acelera el JOIN principal y el filtrado de registros borrados lógicamente (loekz)
DROP INDEX IF EXISTS IX_stg_ekpo_active_lookup ON stg.EKPO;

CREATE NONCLUSTERED INDEX IX_stg_ekpo_active_lookup
ON stg.EKPO (loekz, ebeln, ebelp)
INCLUDE (matnr, txz01, werks, lgort, menge, meins, netpr);

-- 3. Optimización en Inventario de Almacén (MARD)
-- Acelera la detección de stock retenido en control de calidad (speme)
DROP INDEX IF EXISTS IX_stg_mard_speme_quality ON stg.MARD;

CREATE NONCLUSTERED INDEX IX_stg_mard_speme_quality
ON stg.MARD (speme)
INCLUDE (matnr, werks, lgort, labst);