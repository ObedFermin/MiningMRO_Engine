/* ======================================================================================
   PROYECTO   : Mining MRO Analytics Engine
   MODULO     : 03_views
   OBJETO     : core.v_sap_mm_mro_forensic
   ESTANDAR   : ANSI SQL / T-SQL 2022
   DESCRIPCION: Cuantificación de stock bloqueado en control de calidad (SPEME)
                valorizado al precio promedio de contrato.
   ====================================================================================== */

CREATE OR ALTER VIEW core.v_sap_mm_mro_forensic
AS
WITH cte_precios_referencia AS (
    -- Obtener valor de reposición promedio por repuesto sin posiciones borradas
    SELECT 
        matnr,
        MAX(txz01) AS descripcion_repuesto,
        AVG(netpr) AS precio_promedio_contrato_usd
    FROM stg.EKPO
    WHERE loekz IS NULL
    GROUP BY matnr
)
SELECT 
    m.matnr AS codigo_repuesto,
    ref.descripcion_repuesto,
    m.werks AS faena,
    m.lgort AS almacen,
    m.labst AS stock_libre_utilizacion,
    m.speme AS stock_bloqueado_calidad,
    CAST(ref.precio_promedio_contrato_usd AS DECIMAL(18,2)) AS precio_unitario_usd,
    CAST(m.labst * ref.precio_promedio_contrato_usd AS DECIMAL(18,2)) AS valor_stock_libre_usd,
    CAST(m.speme * ref.precio_promedio_contrato_usd AS DECIMAL(18,2)) AS capital_inmovilizado_speme_usd,
    CASE 
        WHEN m.speme > 0 THEN 'BLOQUEO_CONTROL_CALIDAD'
        ELSE 'DISPONIBLE_OPERACIONES'
    END AS estado_almacen
FROM stg.MARD m
LEFT JOIN cte_precios_referencia ref ON ref.matnr = m.matnr;