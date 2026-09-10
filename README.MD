# Mining MRO Analytics Platform ⛏️📊
## Motor Forense Transaccional SAP MM y Reportería Semántica en Business Intelligence IBCS

[![SQL Server](https://img.shields.io/badge/Database-SQL%20Server%202022-CC292B?logo=microsoftsqlserver&logoColor=white)](#)
[![Power BI](https://img.shields.io/badge/Front--End-Power%20BI%20Desktop-F2C811?logo=powerbi&logoColor=black)](#)
[![Standard](https://img.shields.io/badge/Standard-ANSI%20SQL%20%7C%20DAX%20%7C%20IBCS-blue)](#)
[![SAP Module](https://img.shields.io/badge/Domain-SAP%20MM%20(Procurement%20%26%20Inventory)-007DB8?logo=sap)](#)
[![Architecture](https://img.shields.io/badge/Architecture-3--Tier%20Engine%20%2B%20Semantic%20Model-success)](#)
[![Test Suite](https://img.shields.io/badge/Unit%20Tests-100%25%20PASS-brightgreen)](#)

---

## 1. Resumen Ejecutivo & Impacto Financiero

En las operaciones de minería de rajo abierto y procesamiento de mineral (equipos de extracción CAEX, palas electromecánicas y molienda SAG), el aprovisionamiento MRO (*Maintenance, Repair, and Operations*) concentra riesgos críticos de fuga de caja y desabastecimiento operativo.

Esta plataforma integra un **backend relacional de auditoría forense en T-SQL** conectado a una **capa de visualización ejecutiva en Power BI estandarizada bajo norma IBCS** para el control de *3-Way Match*, precios marco y capital inmovilizado.

<p align="center">
  <img src="reports/dashboard_preview.png" alt="Dashboard Ejecutivo Auditoría Forense MRO" width="95%">
</p>

### Hallazgos Forenses Cuantificados (Corte Operacional Consolidado):
* **USD 9,87M en Fuga Financiera Directa (Maverick Spend):** Compras ejecutadas por fuera de los acuerdos corporativos marco (*Master Agreement / MARC*).
* **USD 3,46M en Capital Inmovilizado (SPEME):** Componentes críticos retenidos bajo bloqueo de calidad en pañoles y bodegas operativas, restringiendo el capital de trabajo.
* **69,55% de Cumplimiento 3-Way Match:** Exposición operacional severa donde ~30% de las órdenes de compra presentan descalces entre Órdenes (PO), Recepción física (GR) y Factura (IR).
* **USD 39,39M de Exposición Global por Inconsistencias:** Monto comprometido en transacciones con anomalías de datos, facturas huérfanas o reversas en patio.
* **Concentración de Riesgo (Pareto):** El **74,5%** de toda la fuga económica ($7,35M USD) se concentra en solo 3 componentes: Bomba Hidráulica Liebherr R9800 (`LIEB-BOMB-R9800`), Cilindro Hidráulico Pala CAT 7495 (`PALA-CYL-CAT7495`) y Revestimiento Molino SAG (`MOLINO-REV-SAG`).
  
<p align="center">
  <img src="docs/img/audit_metrics.png" alt="Resumen Financiero y Auditoría MRO" width="90%">
</p>

---

## 2. Arquitectura de la Solución End-to-End

```text
mro-forensic-analytics/
├── SQL/
│   ├── 00_init/               --> Creación de BD y concurrencia no bloqueante (RCSI)
│   ├── 01_ddl_tables/         --> Tablas staging tipadas según diccionario SAP MM (EKKO, EKPO, EKBE, MARD)
│   ├── 02_ingestion/          --> Carga transaccional masiva y validaciones volumétricas
│   ├── 03_views/              --> Neteo MIGO/MIRO, lógica 3-Way Match y anomalías de datos
│   ├── 04_stored_procedures/  --> Procedimiento transaccional ACID con bloques TRY...CATCH para logging
│   ├── 05_indexes/            --> Índices Non-Clustered y Covering Indexes para acelerar lecturas
│   └── 06_tests/              --> Test Harness fiduciario unitario con fixtures en memoria
├── bi/
│   ├── pbix/                  --> Archivo maestro Power BI (Mro_mining.pbix)
│   └── dax/                   --> Medidas DAX de auditoría documentadas en texto plano
├── docs/
│   ├── SPEC.md                --> Especificación técnica y catálogo de reglas de auditoría
│   └── img/                   --> Evidencias de planes de ejecución y pruebas unitarias
├── reports/
│   ├── Mro_mining.pdf         --> Entregable ejecutivo consolidado de 1 página
│   └── dashboard_preview.png  --> Captura del dashboard en alta resolución
└── README.md
```

### Linaje de Datos: De SAP MM a la Decisión Gerencial

```mermaid
graph TD
    subgraph SAP_ERP ["1. Ingestión ERP (SAP MM)"]
        EKKO["stg.EKKO<br/>(Cabecera de OC)"]
        EKPO["stg.EKPO<br/>(Posiciones & Precios MARC)"]
        EKBE["stg.EKBE<br/>(Historial MIGO 101/102 & MIRO)"]
        MARD["stg.MARD<br/>(Saldos Almacén & SPEME)"]
    end

    subgraph CORE_SQL ["2. Motor Forense T-SQL (Core Layer)"]
        V3WAY["core.v_mro_3waymatch<br/>• Neteo MIGO vs MIRO (shkzg)<br/>• Control Maverick Buying<br/>• Flag Fricción Operacional"]
        VFORENSIC["core.v_sap_mm_mro_forensic<br/>• Capital Retenido en Control Calidad"]
        VANOMALIES["core.v_mro_data_quality_anomalies.sql<br/>• Facturas sin MIGO<br/>• Descarte lógico (loekz = 'X')"]
    end

    subgraph AUDIT_LAYER ["3. Trazabilidad & Logs ACID"]
        PROC["audit.sp_insert_mro_audit_log"]
        TABLE_LOG[("audit.tb_log_anomalias_mro")]
    end

    subgraph BI_SEMANTIC ["4. Capa Semántica & Consumo (Power BI)"]
        MODEL["Modelo Constelación Dimensional<br/>(Dim_Repuesto, Dim_Faena, Dim_Calendario)"]
        DAX["Métricas DAX de Exposición Financiera"]
        UI["Panel Ejecutivo IBCS<br/>(Executive Slate & Navy Palette)"]
    end

    EKKO --> V3WAY
    EKPO --> V3WAY
    EKBE --> V3WAY
    EKPO --> VFORENSIC
    MARD --> VFORENSIC
    V3WAY --> VANOMALIES
    VANOMALIES --> PROC
    PROC --> TABLE_LOG

    V3WAY --> MODEL
    VFORENSIC --> MODEL
    VANOMALIES --> MODEL
    MODEL --> DAX
    DAX --> UI

    classDef erp fill:#1f2937,stroke:#3b82f6,stroke-width:1px,color:#fff;
    classDef core fill:#111827,stroke:#10b981,stroke-width:1px,color:#fff;
    classDef audit fill:#31102f,stroke:#ec4899,stroke-width:1px,color:#fff;
    classDef bi fill:#3b2a05,stroke:#f59e0b,stroke-width:1px,color:#fff;
    class EKKO,EKPO,EKBE,MARD erp;
    class V3WAY,VFORENSIC,VANOMALIES core;
    class PROC,TABLE_LOG audit;
    class MODEL,DAX,UI bi;
```

---

## 3. Lógica Transaccional de Negocio (Backend)

### Neteo Transaccional MIGO/MIRO y Detección de Fricción
Para prevenir falsos positivos provocados por devoluciones o reversas de faena en bodega, las CTEs agregan los apuntes contables evaluando la naturaleza Debe/Haber (`shkzg`):
* **Entrada de Mercancías (`vgabe = 1`):** Recepción física (`101` / Cargo `S`) neta contra anulaciones de patio (`102` / Abono `H`).
* **Recepción de Facturas (`vgabe = 2`):** Facturas (`MIRO` / Cargo `S`) netas contra notas de crédito (`H`).
* **Flag de Fricción Operacional:** Si la transacción requirió reversas pero netea a balance cero, se cataloga como `HISTORIAL_CON_REVERSAS` para auditoría de proveedores y almacenes.

### Regla Forense 3-Way Match

El motor clasifica el estado de cada posición evaluando las transacciones bajo la siguiente jerarquía:

```text
SI Cantidad_MIGO = 0 Y Cantidad_MIRO > 0       -> 'FACTURA_SIN_RECEPCION'
SI P.U._MIRO > (P.U._Contrato + 0.01)          -> 'DESCALCE_PRECIO_MAVERICK'
SI Cantidad_MIRO > Cantidad_MIGO               -> 'DESCALCE_CANTIDAD'
SI Cantidad_MIGO < Cantidad_PO Y MIGO > 0     -> 'ENTREGA_PARCIAL'
EN CUALQUIER OTRO CASO                         -> 'CONFORME_3WAY'
```


---

## 4. Modelado Semántico y Métricas DAX (Power BI)

El modelo semántico consume las vistas optimizadas de SQL Server mediante relaciones de 1 a varios unidireccionales:

### 4.1. Fuga Maverick Acumulada (USD)
Calcula el sobrecosto real pagado por encima del contrato marco pactado:
```dax
Fuga Maverick USD = 
SUM(core_v_mro_3waymatch[fuga_maverick_usd])
```

### 4.2. Capital Inmovilizado en Control de Calidad (SPEME)
Valorización del inventario paralizado por inspecciones técnicas al costo promedio de contrato:
```dax
Capital Inmovilizado USD = 
SUM(core_v_sap_mm_mro_forensic[capital_inmovilizado_speme_usd])
```

### 4.3. Tasa de Cumplimiento 3-Way Match (%)
Proporción de transacciones de compra conformes sin desviaciones de precio, cantidad ni recepción:
```dax
% Cumplimiento 3WayMatch = 
DIVIDE(
    CALCULATE(
        COUNTROWS(core_v_mro_3waymatch),
        core_v_mro_3waymatch[estado_3way] = "CONFORME_3WAY"
    ),
    COUNTROWS(core_v_mro_3waymatch),
    0
)
```

### 4.4. Impacto Total por Anomalías (USD)
Exposición consolidada por riesgos de gobierno de datos, borrados lógicos y facturas sin recepción:
```dax
Impacto Anomalias USD = 
SUM(core_v_mro_calidad_datos_anomalias[impacto_financiero_usd])
```

---

### 5. Diseño Ejecutivo & Estándares IBCS

El panel analítico sigue las directrices del International Business Communication Standards (IBCS):

* **Paleta Corporativa Executive Slate & Navy:** Estructurada en base a Azul Marino Oscuro (`#0F172A`) para cabeceras y texto principal, Gris Pizarra (`#64748B`) para etiquetas secundarias y Gris Suave (`#F4F5F7`) para el fondo del lienzo.
* **Uso Semafórico Funcional:** Degradado lineal de 3 puntos aplicado a la columna de Fuga Maverick: neutro en blanco (`#FFFFFF`), advertencia intermedia en rosa suave (`#FECACA`) y alerta crítica en rojo estándar (`#DC2626`), reservando la saturación alta exclusivamente para desvíos presupuestarios severos.
* **Reducción de Ruido Visual:** Tarjetas KPI flotantes con esquinas redondeadas (8 px), sombras suaves y márgenes homogéneos para garantizar legibilidad ejecutiva inmediata.

---

## 6. Rendimiento, Indexación y Pruebas Fiduciarias

* **Aislamiento Snapshot (RCSI):** Base configurada con `READ_COMMITTED_SNAPSHOT ON` para permitir lecturas sin bloqueos de concurrencia durante cargas operativas.
* **Índices de Cobertura (Covering Indexes):**
  * `IX_stg_ekbe_3way_performance`: Elimina *Key Lookups* en las CTEs de agregación MIGO/MIRO sobre `stg.EKBE`.
  * `IX_stg_ekpo_active_lookup`: Permite resolver el filtrado de registros borrados (`loekz`) mediante *Index Seek*.
  * `IX_stg_mard_speme_quality`: Acelera la segmentación del inventario bloqueado en calidad (`speme`).
* **Test Harness Fiduciario:** Suite unitaria en memoria (`06_tests/01_test_harness_3way_fixtures.sql`) con 5 casos de prueba deterministas (Match Conforme, Sobreprecio, Factura Huérfana, Reversa Física y Borrado Lógico) con certificación **100% PASS**.

<p align="center">
  <img src="docs/img/execution_plan.png" alt="Plan de Ejecución Real sin Key Lookups" width="90%">
</p>

---

## 7. Instrucciones de Despliegue Local

1. Clonar el repositorio:
   ```bash
   git clone [https://github.com/ObedFermin/MiningMRO_Engine.git](https://github.com/ObedFermin/MiningMRO_Engine.git)
   ```
2. Ejecutar los scripts SQL en orden secuencial en **SQL Server Management Studio (SSMS)**:
   * `SQL/00_init/01_create_database.sql`
   * `SQL/00_init/02_create_schemas.sql`
   * `SQL/01_ddl_tables/` (tablas `stg` y `audit`)
   * `SQL/02_ingestion/01_bulk_insert_sap_data.sql`
   * `SQL/03_views/` (vistas `core`)
   * `SQL/04_stored_procedures/`
   * `SQL/05_indexes/`
3. Certificar el motor ejecutando `SQL/06_tests/01_test_harness_3way_fixtures.sql`.
4. Abrir el archivo `bi/pbix/Mro_mining.pbix` en Power BI Desktop, actualizar la conexión a la base `Bunker_MRO` de tu instancia local y explorar el reporte interactivo.