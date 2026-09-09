/* ======================================================================================
   PROYECTO   : Mining MRO Analytics Engine
   MODULO     : 03_views
   OBJETO     : 04_audit_summary_check.sql
   ESTANDAR   : ANSI SQL / T-SQL 2022
   DESCRIPCION: Script de validación ejecutiva y auditoría forense para certificar
                los resultados consolidados de las vistas core.
   ====================================================================================== */

-- 1. Matriz 3-Way Match, Control de Sobreprecios y Estado de Flujo
SELECT 
    estado_3way,
    COUNT(*) AS Total_Lineas,
    CAST(SUM(monto_facturado_usd) AS DECIMAL(18,2)) AS Total_Facturado_USD,
    CAST(SUM(fuga_maverick_usd) AS DECIMAL(18,2)) AS Fuga_Maverick_USD
FROM core.v_mro_3waymatch
GROUP BY estado_3way
ORDER BY Fuga_Maverick_USD DESC;

-- 2. Auditoría Forense de Fricción Operacional (Reversas 102 y Notas de Crédito)
SELECT 
    flag_friccion_operacional,
    COUNT(*) AS Total_Lineas_Auditadas,
    SUM(total_eventos_anulacion) AS Total_Eventos_Reversas,
    CAST(SUM(monto_facturado_usd) AS DECIMAL(18,2)) AS Monto_Comprometido_USD,
    CAST(SUM(fuga_maverick_usd) AS DECIMAL(18,2)) AS Fuga_Maverick_Asociada_USD
FROM core.v_mro_3waymatch
GROUP BY flag_friccion_operacional
ORDER BY Total_Eventos_Reversas DESC;

-- 3. Top Proveedores con Mayor Reincidencia de Reversas Operativas
SELECT TOP 5
    proveedor,
    COUNT(*) AS Total_Lineas,
    SUM(total_eventos_anulacion) AS Total_Reversas_Detectadas,
    CAST(SUM(fuga_maverick_usd) AS DECIMAL(18,2)) AS Fuga_Maverick_USD
FROM core.v_mro_3waymatch
WHERE flag_friccion_operacional = 'HISTORIAL_CON_REVERSAS'
GROUP BY proveedor
ORDER BY Total_Reversas_Detectadas DESC;

-- 4. Capital Inmovilizado en Control de Calidad (SPEME)
SELECT 
    COUNT(*) AS Almacenes_Con_Bloqueo,
    SUM(stock_bloqueado_calidad) AS Unidades_Bloqueadas,
    CAST(SUM(capital_inmovilizado_speme_usd) AS DECIMAL(18,2)) AS Capital_Inmovilizado_SPEME_USD
FROM core.v_sap_mm_mro_forensic
WHERE stock_bloqueado_calidad > 0;

-- 5. Resumen Ejecutivo de Gobierno de Datos y Riesgo Financiero
SELECT 
    categoria_anomalia,
    fuente_origen,
    COUNT(*) AS Casos_Detectados,
    CAST(SUM(impacto_financiero_usd) AS DECIMAL(18,2)) AS Total_Riesgo_Financiero_USD
FROM core.v_mro_calidad_datos_anomalias
GROUP BY categoria_anomalia, fuente_origen
ORDER BY Total_Riesgo_Financiero_USD DESC;
