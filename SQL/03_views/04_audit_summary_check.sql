/* ======================================================================================
   PROYECTO   : Mining MRO Analytics Engine
   MODULO     : 03_views
   OBJETO     : 04_audit_summary_check.sql
   ESTANDAR   : ANSI SQL / T-SQL 2022
   DESCRIPCION: Script de validación ejecutiva para auditar los resultados de las 3 vistas.
   ====================================================================================== */

USE Bunker_MRO;

-- 1. Matriz 3-Way Match y Detección de Maverick Buying
SELECT 
    estado_3way,
    COUNT(*) AS Total_Lineas,
    CAST(SUM(monto_facturado_usd) AS DECIMAL(18,2)) AS Total_Facturado_USD,
    CAST(SUM(fuga_maverick_usd) AS DECIMAL(18,2)) AS Fuga_Maverick_USD
FROM core.v_mro_3waymatch
GROUP BY estado_3way
ORDER BY Fuga_Maverick_USD DESC;

-- 2. Capital Inmovilizado en Control de Calidad (SPEME)
SELECT 
    COUNT(*) AS Almacenes_Con_Bloqueo,
    SUM(stock_bloqueado_calidad) AS Unidades_Bloqueadas,
    CAST(SUM(capital_inmovilizado_speme_usd) AS DECIMAL(18,2)) AS Capital_Inmovilizado_SPEME_USD
FROM core.v_sap_mm_mro_forensic
WHERE stock_bloqueado_calidad > 0;

-- 3. Resumen Ejecutivo de Gobierno de Datos y Riesgo Financiero
SELECT 
    categoria_anomalia,
    fuente_origen,
    COUNT(*) AS Casos_Detectados,
    CAST(SUM(impacto_financiero_usd) AS DECIMAL(18,2)) AS Total_Riesgo_Financiero_USD
FROM core.v_mro_calidad_datos_anomalias
GROUP BY categoria_anomalia, fuente_origen
ORDER BY Total_Riesgo_Financiero_USD DESC;