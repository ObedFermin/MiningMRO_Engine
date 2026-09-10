SET NOCOUNT ON;

-- 1. CREACIÓN DE FIXTURES AISLADOS EN MEMORIA
DROP TABLE IF EXISTS #Test_EKKO;
DROP TABLE IF EXISTS #Test_EKPO;
DROP TABLE IF EXISTS #Test_EKBE;

CREATE TABLE #Test_EKKO (
    ebeln VARCHAR(20) PRIMARY KEY,
    bukrs VARCHAR(10), lifnr VARCHAR(50), aedat DATE, ekorg VARCHAR(10)
);

CREATE TABLE #Test_EKPO (
    ebeln VARCHAR(20), ebelp INT, matnr VARCHAR(50), txz01 VARCHAR(100),
    werks VARCHAR(10), lgort VARCHAR(10), menge DECIMAL(12,2), meins VARCHAR(10),
    netpr DECIMAL(18,2), peinh INT, loekz CHAR(1), wepos CHAR(1), repos CHAR(1),
    PRIMARY KEY (ebeln, ebelp)
);

CREATE TABLE #Test_EKBE (
    ebeln VARCHAR(20), ebelp INT, belnr VARCHAR(20), gjahr SMALLINT,
    buzei INT, vgabe TINYINT, bewtp CHAR(1), bwart VARCHAR(10),
    budat DATE, menge DECIMAL(12,2), wrbtr DECIMAL(18,2), shkzg CHAR(1),
    PRIMARY KEY (ebeln, ebelp, belnr, gjahr, buzei)
);

-- 2. INYECCIÓN DE CASOS DE PRUEBA (GROUND TRUTH)
-- Caso 1: Match Conforme (10 und @ $100 -> MIGO 10 -> MIRO 10)
INSERT INTO #Test_EKKO VALUES ('TEST_01', '1000', 'PROV_KOMATSU', '2026-08-01', 'MIN1');
INSERT INTO #Test_EKPO VALUES ('TEST_01', 10, 'PERNO-GR8', 'Perno Estructural Grado 8', 'F001', 'B001', 10.0, 'C/U', 100.0, 1, NULL, 'X', 'X');
INSERT INTO #Test_EKBE VALUES ('TEST_01', 10, '5001', 2026, 1, 1, 'E', '101', '2026-08-05', 10.0, 1000.0, 'S');
INSERT INTO #Test_EKBE VALUES ('TEST_01', 10, '6001', 2026, 1, 2, 'R', NULL,  '2026-08-10', 10.0, 1000.0, 'S');

-- Caso 2: Sobreprecio MARC (Pactado $100, Facturado $120 -> Fuga $100 USD)
INSERT INTO #Test_EKKO VALUES ('TEST_02', '1000', 'PROV_CUMMINS', '2026-08-01', 'MIN1');
INSERT INTO #Test_EKPO VALUES ('TEST_02', 10, 'FILT-830E', 'Filtro Hidraulico 830E', 'F001', 'B001', 5.0, 'C/U', 100.0, 1, NULL, 'X', 'X');
INSERT INTO #Test_EKBE VALUES ('TEST_02', 10, '5002', 2026, 1, 1, 'E', '101', '2026-08-05', 5.0, 500.0, 'S');
INSERT INTO #Test_EKBE VALUES ('TEST_02', 10, '6002', 2026, 1, 2, 'R', NULL,  '2026-08-10', 5.0, 600.0, 'S');

-- Caso 3: Factura sin Recepción Física (MIGO ausente en almacén)
INSERT INTO #Test_EKKO VALUES ('TEST_03', '1000', 'PROV_WARMAN', '2026-08-01', 'MIN1');
INSERT INTO #Test_EKPO VALUES ('TEST_03', 10, 'BOMB-W200', 'Impulsor Bomba Warman', 'F001', 'B001', 1.0, 'C/U', 5000.0, 1, NULL, 'X', 'X');
INSERT INTO #Test_EKBE VALUES ('TEST_03', 10, '6003', 2026, 1, 2, 'R', NULL,  '2026-08-10', 1.0, 5000.0, 'S');

-- Caso 4: Reversa Física en Bodega (Mov 101 + 102 netea a 0 -> Detecta Reversa)
INSERT INTO #Test_EKKO VALUES ('TEST_04', '1000', 'PROV_CAT', '2026-08-01', 'MIN1');
INSERT INTO #Test_EKPO VALUES ('TEST_04', 10, 'CIL-7495', 'Cilindro Hidraulico Pala', 'F001', 'B001', 2.0, 'C/U', 10000.0, 1, NULL, 'X', 'X');
INSERT INTO #Test_EKBE VALUES ('TEST_04', 10, '5004', 2026, 1, 1, 'E', '101', '2026-08-05', 2.0, 20000.0, 'S');
INSERT INTO #Test_EKBE VALUES ('TEST_04', 10, '5005', 2026, 2, 1, 'E', '102', '2026-08-06', 2.0, 20000.0, 'H'); -- Reversa física
INSERT INTO #Test_EKBE VALUES ('TEST_04', 10, '6004', 2026, 1, 2, 'R', NULL,  '2026-08-10', 2.0, 20000.0, 'S');

-- Caso 5: Posición Borrada lógicamente en ERP (loekz = 'X')
INSERT INTO #Test_EKKO VALUES ('TEST_05', '1000', 'PROV_LIEBHERR', '2026-08-01', 'MIN1');
INSERT INTO #Test_EKPO VALUES ('TEST_05', 10, 'ZAP-7495', 'Zapata Oruga Pala', 'F001', 'B001', 10.0, 'C/U', 2000.0, 1, 'X', 'X', 'X');

-- 3. EJECUCIÓN DEL MOTOR DE AUDITORÍA SOBRE LOS FIXTURES
;WITH cte_migo_test AS (
    SELECT 
        ebeln, ebelp,
        SUM(CASE WHEN shkzg = 'S' THEN menge ELSE -menge END) AS rec_neta,
        SUM(CASE WHEN shkzg = 'S' THEN wrbtr ELSE -wrbtr END) AS rec_monto,
        SUM(CASE WHEN bwart = '102' THEN 1 ELSE 0 END) AS conteo_reversas
    FROM #Test_EKBE WHERE vgabe = 1 GROUP BY ebeln, ebelp
),
cte_miro_test AS (
    SELECT 
        ebeln, ebelp,
        SUM(CASE WHEN shkzg = 'S' THEN menge ELSE -menge END) AS fact_neta,
        SUM(CASE WHEN shkzg = 'S' THEN wrbtr ELSE -wrbtr END) AS fact_monto,
        SUM(CASE WHEN shkzg = 'H' THEN 1 ELSE 0 END) AS conteo_nc
    FROM #Test_EKBE WHERE vgabe = 2 GROUP BY ebeln, ebelp
),
cte_salida_evaluada AS (
    SELECT 
        p.ebeln,
        p.ebelp,
        COALESCE(migo.rec_neta, 0.00) AS rec_neta,
        COALESCE(miro.fact_neta, 0.00) AS fact_neta,
        CAST(CASE 
            WHEN COALESCE(miro.fact_neta, 0) > 0 AND (miro.fact_monto / miro.fact_neta) > p.netpr
            THEN miro.fact_monto - (p.netpr * miro.fact_neta)
            ELSE 0.00 
        END AS DECIMAL(18,2)) AS fuga_maverick,
        COALESCE(migo.conteo_reversas, 0) + COALESCE(miro.conteo_nc, 0) AS total_reversas,
        CASE 
            WHEN (COALESCE(migo.conteo_reversas, 0) + COALESCE(miro.conteo_nc, 0)) > 0 
            THEN 'HISTORIAL_CON_REVERSAS' ELSE 'FLUJO_LIMPIO' 
        END AS friccion_evaluada,
        CASE 
            WHEN COALESCE(migo.rec_neta, 0) = 0 AND COALESCE(miro.fact_neta, 0) > 0 THEN 'FACTURA_SIN_RECEPCION'
            WHEN COALESCE(miro.fact_neta, 0) > 0 AND (miro.fact_monto / miro.fact_neta) > (p.netpr + 0.01) THEN 'DESCALCE_PRECIO_MAVERICK'
            WHEN COALESCE(miro.fact_neta, 0) > COALESCE(migo.rec_neta, 0) THEN 'DESCALCE_CANTIDAD'
            WHEN COALESCE(migo.rec_neta, 0) < p.menge AND COALESCE(migo.rec_neta, 0) > 0 THEN 'ENTREGA_PARCIAL'
            WHEN COALESCE(migo.rec_neta, 0) = 0 AND COALESCE(miro.fact_neta, 0) = 0 THEN 'PENDIENTE_RECEPCION'
            ELSE 'CONFORME_3WAY'
        END AS estado_evaluado
    FROM #Test_EKPO p
    LEFT JOIN cte_migo_test migo ON migo.ebeln = p.ebeln AND migo.ebelp = p.ebelp
    LEFT JOIN cte_miro_test miro ON miro.ebeln = p.ebeln AND miro.ebelp = p.ebelp
    WHERE p.loekz IS NULL
),
-- 4. MATRIZ DE RESPUESTAS ESPERADAS (GROUND TRUTH INCLUYENDO EXCLUSIÓN LOEKZ)
cte_ground_truth AS (
    SELECT 'TEST_01' AS ebeln, 10.0 AS rec_exp, 10.0 AS fact_exp, 0.00 AS fuga_exp, 'CONFORME_3WAY' AS estado_exp, 'FLUJO_LIMPIO' AS friccion_exp UNION ALL
    SELECT 'TEST_02', 5.0,  5.0,  100.00,  'DESCALCE_PRECIO_MAVERICK', 'FLUJO_LIMPIO' UNION ALL
    SELECT 'TEST_03', 0.0,  1.0,  0.00,    'FACTURA_SIN_RECEPCION',    'FLUJO_LIMPIO' UNION ALL
    SELECT 'TEST_04', 0.0,  2.0,  0.00,    'FACTURA_SIN_RECEPCION',    'HISTORIAL_CON_REVERSAS'
)
-- 5. ASSERT DEL BANCO DE PRUEBAS
SELECT 
    gt.ebeln AS Caso_Prueba,
    CASE 
        WHEN res.ebeln IS NULL THEN 'FAIL: Registro descartado indebidamente'
        WHEN res.rec_neta <> gt.rec_exp THEN 'FAIL: Error en neteo de recepcion'
        WHEN res.fact_neta <> gt.fact_exp THEN 'FAIL: Error en neteo de factura'
        WHEN res.fuga_maverick <> gt.fuga_exp THEN 'FAIL: Error en calculo Maverick'
        WHEN res.estado_evaluado <> gt.estado_exp THEN 'FAIL: Estado incorrecto (' + res.estado_evaluado + ')'
        WHEN res.friccion_evaluada <> gt.friccion_exp THEN 'FAIL: Error en clasificacion de friccion'
        ELSE 'PASS'
    END AS Resultado_Unit_Test,
    res.estado_evaluado AS Estado_Calculado,
    res.friccion_evaluada AS Friccion_Calculada,
    res.fuga_maverick AS Fuga_USD
FROM cte_ground_truth gt
LEFT JOIN cte_salida_evaluada res ON res.ebeln = gt.ebeln

UNION ALL

-- Aserción específica de que TEST_05 (loekz = 'X') fue excluido
SELECT 
    'TEST_05_LOEKZ' AS Caso_Prueba,
    CASE 
        WHEN EXISTS (SELECT 1 FROM cte_salida_evaluada WHERE ebeln = 'TEST_05') 
        THEN 'FAIL: Registro anulado no fue filtrado' 
        ELSE 'PASS' 
    END AS Resultado_Unit_Test,
    'EXCLUIDO_FILTRO_ERP' AS Estado_Calculado,
    'SIN_FRICCION' AS Friccion_Calculada,
    0.00 AS Fuga_USD;