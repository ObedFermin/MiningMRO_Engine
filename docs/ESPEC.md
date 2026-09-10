# Especificación Funcional y Técnica (SPEC)
## Mining MRO Analytics Platform
### Motor Forense Transaccional SAP MM y Reportería Semántica en Business Intelligence IBCS

### 1. Alcance y Contexto Operativo

El sistema audita el aprovisionamiento, facturación y almacenamiento de repuestos para faenas mineras continuas (flotas de camiones de extracción de alto tonelaje CAEX, palas electromecánicas y chancado/molienda). El objetivo es reconciliar los flujos de materiales con los flujos financieros registrados en los módulos SAP MM y SAP FI.

---

### 2. Definición de Tablas Staging del ERP (SAP MM)

| Objeto Staging | Tabla SAP Equivalente | Granularidad | Clave Primaria (PK) |
|---|---|---|---|
| `stg.EKKO` | `EKKO` (Cabecera Pedido) | 1 fila por Orden de Compra | `ebeln` |
| `stg.EKPO` | `EKPO` (Posición Pedido) | 1 fila por ítem/repuesto solicitado | `(ebeln, ebelp)` |
| `stg.EKBE` | `EKBE` (Historial Transaccional) | 1 fila por evento MIGO/MIRO | `(ebeln, ebelp, belnr, gjahr, buzei)` |
| `stg.MARD` | `MARD` (Datos de Almacén) | 1 fila por material, centro y almacén | `(matnr, werks, lgort)` |

---

### 3. Especificación de Reglas de Auditoría Forense

#### 3.1. Reconciliación Transaccional MIGO / MIRO
Dado que los almacenes registran anulaciones por recepción defectuosa (movimiento 102) y el área contable emite notas de crédito (apuntes `H`), toda agregación evalúa:
$$\text{Cantidad Recibida Neta} = \sum_{\text{vgabe}=1} \left( \begin{cases} \text{menge} & \text{si } \text{shkzg} = \text{'S'} \\ -\text{menge} & \text{si } \text{shkzg} = \text{'H'} \end{cases} \right)$$
$$\text{Cantidad Facturada Neta} = \sum_{\text{vgabe}=2} \left( \begin{cases} \text{menge} & \text{si } \text{shkzg} = \text{'S'} \\ -\text{menge} & \text{si } \text{shkzg} = \text{'H'} \end{cases} \right)$$

#### 3.2. Fuga Financiera por Maverick Buying (Compras no autorizadas/fuera de contrato)
Aplica cuando el precio unitario promedio efectivamente facturado en MIRO sobrepasa el precio unitario acordado en la orden de compra basada en contrato marco (`netpr`):
$$\text{Fuga Maverick} = \max\left(0, \text{Monto Facturado} - (\text{netpr} \times \text{Cantidad Facturada Neta})\right)$$

#### 3.3. Capital Retenido en Control de Calidad (SPEME)
Cuantifica el costo de oportunidad del stock almacenado en estado bloqueado (`speme > 0`):
$$\text{Capital Inmovilizado} = \text{speme} \times \text{Precio Promedio Contrato}$$

---

### 4. Arquitectura de Visualización en Power BI

* **Modelo Dimensional:** Esquema de constelación de hechos (Fact Constellation) donde las dimensiones maestras (`Dim_Repuesto`, `Dim_Faena`, `Dim_Calendario`) filtran con cardinalidad 1 a varios a las vistas del esquema `core`.
* **Normativa IBCS:**
  * No se utilizan fondos saturados ni gráficos 3D.
  * Los filtros interactivos se reducen a tipografía pequeña (10 pt) en cabecera.
  * La matriz forense utiliza diseño tabular directo con alineación numérica a la derecha y formato moneda con dos decimales.