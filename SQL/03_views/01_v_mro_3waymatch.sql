/* ======================================================================================
   PROYECTO   : Mining MRO Analytics Engine
   MODULO     : 03_views
   OBJETO     : core.v_mro_3waymatch
   ESTANDAR   : ANSI SQL / T-SQL 2022
   DESCRIPCION: Matriz de neteo transaccional SAP MM (101 vs 102 / MIGO vs MIRO)
                y control de sobreprecios (Maverick Buying) en repuestos MRO.
   ====================================================================================== */

CREATE OR ALTER VIEW core.v_mro_3waymatch
AS
WITH cte_migo AS (
    -- Balanceo de entradas físicas (101/S) contra cancelaciones contables (102/H)
    SELECT 
        ebeln,
        ebelp,
        SUM(CASE WHEN shkzg = 'S' THEN menge ELSE -menge END) AS cantidad_recibida_neta,
        SUM(CASE WHEN shkzg = 'S' THEN wrbtr ELSE -wrbtr END) AS monto_recibido_usd
    FROM stg.EKBE
    WHERE vgabe = 1
    GROUP BY ebeln, ebelp
),
cte_miro AS (
    -- Balanceo de facturas procesadas en MIRO
    SELECT 
        ebeln,
        ebelp,
        SUM(CASE WHEN shkzg = 'S' THEN menge ELSE -menge END) AS cantidad_facturada_neta,
        SUM(CASE WHEN shkzg = 'S' THEN wrbtr ELSE -wrbtr END) AS monto_facturado_usd
    FROM stg.EKBE
    WHERE vgabe = 2
    GROUP BY ebeln, ebelp
)
SELECT 
    p.ebeln AS orden_compra,
    p.ebelp AS posicion,
    k.lifnr AS proveedor,
    k.aedat AS fecha_oc,
    p.werks AS faena,
    p.lgort AS almacen,
    p.matnr AS codigo_repuesto,
    p.txz01 AS descripcion_repuesto,
    p.menge AS cantidad_solicitada,
    p.meins AS unidad_medida,
    p.netpr AS precio_unitario_contrato,
    COALESCE(migo.cantidad_recibida_neta, 0.00) AS cantidad_recibida_neta,
    COALESCE(miro.cantidad_facturada_neta, 0.00) AS cantidad_facturada_neta,
    COALESCE(miro.monto_facturado_usd, 0.00) AS monto_facturado_usd,
    CAST(
        CASE 
            WHEN COALESCE(miro.cantidad_facturada_neta, 0) > 0 
            THEN miro.monto_facturado_usd / miro.cantidad_facturada_neta 
            ELSE 0.00 
        END AS DECIMAL(18,2)
    ) AS precio_unitario_facturado,
    CAST(
        CASE 
            WHEN COALESCE(miro.cantidad_facturada_neta, 0) > 0 
            THEN (miro.monto_facturado_usd / miro.cantidad_facturada_neta) - p.netpr
            ELSE 0.00 
        END AS DECIMAL(18,2)
    ) AS desvio_precio_unitario_usd,
    CAST(
        CASE 
            WHEN COALESCE(miro.cantidad_facturada_neta, 0) > 0 
                 AND (miro.monto_facturado_usd / miro.cantidad_facturada_neta) > p.netpr
            THEN miro.monto_facturado_usd - (p.netpr * miro.cantidad_facturada_neta)
            ELSE 0.00 
        END AS DECIMAL(18,2)
    ) AS fuga_maverick_usd,
    CASE 
        WHEN COALESCE(migo.cantidad_recibida_neta, 0) = 0 AND COALESCE(miro.cantidad_facturada_neta, 0) > 0 
            THEN 'FACTURA_SIN_RECEPCION'
        WHEN COALESCE(miro.cantidad_facturada_neta, 0) > 0 
             AND (miro.monto_facturado_usd / miro.cantidad_facturada_neta) > (p.netpr + 0.01)
            THEN 'DESCALCE_PRECIO_MAVERICK'
        WHEN COALESCE(miro.cantidad_facturada_neta, 0) > COALESCE(migo.cantidad_recibida_neta, 0) 
            THEN 'DESCALCE_CANTIDAD'
        WHEN COALESCE(migo.cantidad_recibida_neta, 0) < p.menge 
            THEN 'ENTREGA_PARCIAL'
        ELSE 'CONFORME_3WAY'
    END AS estado_3way
FROM stg.EKPO p
INNER JOIN stg.EKKO k ON k.ebeln = p.ebeln
LEFT JOIN cte_migo migo ON migo.ebeln = p.ebeln AND migo.ebelp = p.ebelp
LEFT JOIN cte_miro miro ON miro.ebeln = p.ebeln AND miro.ebelp = p.ebelp
WHERE p.loekz IS NULL;