/* ======================================================================================
   PROYECTO   : Mining MRO Analytics Engine
   MODULO     : 03_views
   OBJETO     : core.v_mro_calidad_datos_anomalias
   ESTANDAR   : ANSI SQL / T-SQL 2022
   DESCRIPCION: Aislamiento y catalogación de anomalías de calidad de datos ERP / TI
                y riesgos de control interno (borrados, descalces, facturas huérfanas).
   ====================================================================================== */

CREATE OR ALTER VIEW core.v_mro_calidad_datos_anomalias
AS
WITH cte_migo AS (
    SELECT 
        ebeln,
        ebelp,
        SUM(CASE WHEN shkzg = 'S' THEN menge ELSE -menge END) AS cantidad_recibida_neta
    FROM stg.EKBE
    WHERE vgabe = 1
    GROUP BY ebeln, ebelp
),
cte_miro AS (
    SELECT 
        ebeln,
        ebelp,
        SUM(CASE WHEN shkzg = 'S' THEN menge ELSE -menge END) AS cantidad_facturada_neta,
        SUM(CASE WHEN shkzg = 'S' THEN wrbtr ELSE -wrbtr END) AS monto_facturado_usd
    FROM stg.EKBE
    WHERE vgabe = 2
    GROUP BY ebeln, ebelp
)
-- 1. Anomalías de TI / ERP: Registros borrados lógicamente que no deben sumar a presupuesto
SELECT 
    p.ebeln AS orden_compra,
    p.ebelp AS posicion,
    k.lifnr AS proveedor,
    p.matnr AS codigo_repuesto,
    p.txz01 AS descripcion_repuesto,
    p.werks AS faena,
    'BORRADO_LOGICO_SAP' AS categoria_anomalia,
    'TI_DATA_GOVERNANCE' AS fuente_origen,
    CAST(p.menge * p.netpr AS DECIMAL(18,2)) AS impacto_financiero_usd,
    'Posición anulada en SAP (loekz=X); excluida de compromisos presupuestarios' AS detalle_tecnico
FROM stg.EKPO p
INNER JOIN stg.EKKO k ON k.ebeln = p.ebeln
WHERE p.loekz = 'X'

UNION ALL

-- 2. Anomalías Contables Críticas: Facturas sin respaldo de recepción física (MIGO ausente)
SELECT 
    p.ebeln AS orden_compra,
    p.ebelp AS posicion,
    k.lifnr AS proveedor,
    p.matnr AS codigo_repuesto,
    p.txz01 AS descripcion_repuesto,
    p.werks AS faena,
    'FACTURA_SIN_RECEPCION' AS categoria_anomalia,
    'FINANZAS_CUENTAS_POR_PAGAR' AS fuente_origen,
    CAST(miro.monto_facturado_usd AS DECIMAL(18,2)) AS impacto_financiero_usd,
    'Factura ingresada en MIRO sin ingreso físico de repuestos en bodega (vgabe=1 ausente)' AS detalle_tecnico
FROM stg.EKPO p
INNER JOIN stg.EKKO k ON k.ebeln = p.ebeln
INNER JOIN cte_miro miro ON miro.ebeln = p.ebeln AND miro.ebelp = p.ebelp
LEFT JOIN cte_migo migo ON migo.ebeln = p.ebeln AND migo.ebelp = p.ebelp
WHERE p.loekz IS NULL 
  AND COALESCE(migo.cantidad_recibida_neta, 0) = 0

UNION ALL

-- 3. Anomalías de Sobreprecio: Desviación frente al contrato marco MARC
SELECT 
    p.ebeln AS orden_compra,
    p.ebelp AS posicion,
    k.lifnr AS proveedor,
    p.matnr AS codigo_repuesto,
    p.txz01 AS descripcion_repuesto,
    p.werks AS faena,
    'MAVERICK_BUYING' AS categoria_anomalia,
    'PROCUREMENT_DESVIO_CONTRATO' AS fuente_origen,
    CAST(miro.monto_facturado_usd - (p.netpr * miro.cantidad_facturada_neta) AS DECIMAL(18,2)) AS impacto_financiero_usd,
    'Precio unitario facturado excede el precio unitario pactado en contrato' AS detalle_tecnico
FROM stg.EKPO p
INNER JOIN stg.EKKO k ON k.ebeln = p.ebeln
INNER JOIN cte_miro miro ON miro.ebeln = p.ebeln AND miro.ebelp = p.ebelp
WHERE p.loekz IS NULL 
  AND COALESCE(miro.cantidad_facturada_neta, 0) > 0 
  AND (miro.monto_facturado_usd / miro.cantidad_facturada_neta) > (p.netpr + 0.01);