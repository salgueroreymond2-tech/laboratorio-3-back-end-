# Casos de Prueba y Resultados Esperados — Agente de Aduana n8n & Supabase

- **Proyecto:** Laboratorio #3: Sistema de inventario para una aduana: base de datos relacional y agente de IA con n8n
- **Autor:** Reymond Salguero
- **Fecha:** Octubre de 2026
- **Entorno de Datos:** Supabase (Motor PostgreSQL 18) | Esquema: `aduana`
- **Estado de Resultados:** *Valores calculados analíticamente sobre el conjunto de datos determinista de 02_datos.sql (pendientes de contraste contra ejecución en vivo por parte del usuario).*

---

## 1. Matriz de Pruebas de Negocio (8 Consultas)

A continuación se detallan las 8 pruebas operativas asociadas a las consultas analíticas del sistema, especificando la pregunta formulada al agente n8n en el chat, la herramienta invocada, el SQL de contraste y la salida exacta derivada de la carga de datos.

---

### Prueba 1: Declaraciones de Importación en Octubre de 2026
- **Pregunta del Usuario:** «¿Cuáles declaraciones aduaneras bajo régimen de importación se tramitaron en el mes de octubre de 2026?»
- **Herramienta n8n Esperada:** `consultar_importaciones_octubre`
- **Parámetros:** Ninguno (rango semiabierto fijo `[2026-10-01, 2026-11-01)` y `regimen = 'Importacion'`).
- **SQL de Referencia:** Consulta 1 de `03_consultas.sql`.
- **Columnas de Salida:** `numero_dua`, `fecha_declaracion`, `importador`, `agente_aduanal`, `regimen`, `estado_operativo`, `moneda`.
- **Resultado Esperado (10 registros):**

| numero_dua | fecha_declaracion | importador | agente_aduanal | regimen | estado_operativo | moneda |
| :--- | :---: | :--- | :--- | :---: | :---: | :---: |
| DUA-2026-0001 | 2026-10-01 | Importadora Tecnológica del Valle S.A. | Carlos Alberto Morales Solano | Importacion | Liberada | USD |
| DUA-2026-0002 | 2026-10-03 | Distribuidora Médica Global S.A. | Mariana Patricia Soto Chaves | Importacion | En Inspeccion | USD |
| DUA-2026-0003 | 2026-10-04 | Importadora Tecnológica del Valle S.A. | Jorge Eduardo Ramírez Vargas | Importacion | Retenida | USD |
| DUA-2026-0004 | 2026-10-05 | Pacific Logistics Imports LLC | Ana Lorena Brenes Castro | Importacion | Liberada | USD |
| DUA-2026-0005 | 2026-10-06 | Agroquímicos y Semillas del Caribe S.A. | Roberto Carlos Navarro Umaña | Importacion | En Inspeccion | USD |
| DUA-2026-0007 | 2026-10-08 | ElectroHogar y Climatización S.A. | Esteban Gabriel Rojas Monge | Importacion | Retenida | USD |
| DUA-2026-0009 | 2026-10-10 | Iberia Electrónica Industrial S.L. | Mauricio Andrés Cordero Vega | Importacion | En Inspeccion | USD |
| DUA-2026-0010 | 2026-10-12 | Textiles y Modas de Centroamérica S.A. | Daniela Paola Guzmán Herrera | Importacion | Liberada | USD |
| DUA-2026-0011 | 2026-10-15 | Bavaria Industrial Solutions GmbH | Fernando José Campos Barquero | Importacion | En Inspeccion | USD |
| DUA-2026-0014 | 2026-10-22 | Consorcio Automotriz Central S.A. | Gabriela Isabel Zúñiga Arias | Importacion | En Inspeccion | USD |

---

### Prueba 2: Mercancías con Origen China, Declaración Retenida y Existencias en Bodega
- **Pregunta del Usuario:** «¿Cuáles mercancías de origen China corresponden a declaraciones retenidas y mantienen stock físico en bodega?»
- **Herramienta n8n Esperada:** `consultar_mercancia_china_retenida`
- **Criterio Relacional:** `producto.id_pais_origen = (SELECT id_pais FROM aduana.pais WHERE nombre = 'China')`, `declaracion_aduanera.estado = 'Retenida'`, `inventario_bodega.cantidad_almacenada > 0.00` y `fecha_salida IS NULL`.
- **Columnas de Salida:** `numero_dua`, `estado_declaracion`, `producto`, `sku`, `pais_origen_mercancia`, `cantidad_almacenada`, `unidad_medida`, `nombre_bodega`, `ubicacion_estante`.
- **Resultado Esperado (5 registros):**

| numero_dua | estado_declaracion | producto | sku | pais_origen | cantidad_almacenada | unidad | nombre_bodega | ubicacion_estante |
| :--- | :---: | :--- | :--- | :---: | :---: | :---: | :--- | :---: |
| DUA-2026-0003 | Retenida | Laptop Gamer Pro Titan X | SKU-LAP-CN01 | China | 80.00 | unidades | Bodega Fiscal Central Santamaría | EST-C01-N3 |
| DUA-2026-0003 | Retenida | Monitor Curvo UltraWide 34" | SKU-MON-CN02 | China | 60.00 | unidades | Bodega Fiscal Central Santamaría | EST-C01-N4 |
| DUA-2026-0007 | Retenida | Monitor Curvo UltraWide 34" | SKU-MON-CN02 | China | 120.00 | unidades | Bodega Fiscal Central Santamaría | EST-A04-N1 |
| DUA-2026-0007 | Retenida | Aire Acondicionado Split 24000 BTU | SKU-AC-CN07 | China | 50.00 | unidades | Bodega Fiscal Central Santamaría | EST-A04-N2 |
| DUA-2026-0008 | Retenida | Inversor Solar On-Grid 5kW | SKU-INV-CN09 | China | 40.00 | unidades | Bodega Fiscal Central Santamaría | EST-D01-N1 |

---

### Prueba 3: País o Países con Mayor Número de Contenedores (Procedencia)
- **Pregunta del Usuario:** «¿Cuál es el país de procedencia que ha enviado el mayor número de contenedores?»
- **Herramienta n8n Esperada:** `consultar_pais_mas_contenedores`
- **Criterio Relacional:** Agrupación por `contenedor.id_pais_procedencia` con `DENSE_RANK() OVER (ORDER BY COUNT(*) DESC)`.
- **Columnas de Salida:** `ranking_posicion`, `pais_procedencia`, `codigo_iso_alfa2`, `total_contenedores`.
- **Resultado Esperado (Empate estricto en la primera posición):**

| ranking_posicion | pais_procedencia | codigo_iso_alfa2 | total_contenedores |
| :---: | :--- | :---: | :---: |
| **1** | **China** | **CN** | **4** |
| **1** | **Estados Unidos** | **US** | **4** |

*Nota Crítica de Evaluación:* El agente **debe informar ambos países en empate** (China y EE. UU. con 4 unidades cada uno). Un agente que reporte únicamente uno de los dos falla la directiva de preservación de empates.

---

### Prueba 4: Importador o Importadores con Mayor Valor Declarado Total
- **Pregunta del Usuario:** «¿Cuál empresa importadora registra el mayor valor económico acumulado en sus declaraciones aduaneras?»
- **Herramienta n8n Esperada:** `consultar_importador_mayor_valor`
- **Criterio Relacional:** Agregación `SUM(detalle.cantidad * detalle.valor_unitario)` en USD con `DENSE_RANK()`.
- **Columnas de Salida:** `ranking_valor`, `identificacion_tributaria`, `razon_social`, `pais_importador`, `total_valor_declarado_usd`, `total_declaraciones_tramitadas`.
- **Resultado Esperado (Primer lugar absoluto):**

| ranking_valor | identificacion_tributaria | razon_social | pais_importador | total_valor_declarado_usd | total_declaraciones |
| :---: | :--- | :--- | :--- | :---: | :---: |
| **1** | **3-101-456789** | **Consorcio Automotriz Central S.A.** | **Costa Rica** | **$451,200.00 USD** | **2** |

*Desglose de Auditoría:* DUA-2026-0006 ($285,000.00) + DUA-2026-0014 ($166,200.00) = $451,200.00 USD.

---

### Prueba 5: Inspecciones con Observaciones Técnicas y Funcionario Responsable
- **Pregunta del Usuario:** «¿Qué inspecciones aduaneras cuentan con observaciones y quién fue el funcionario responsable?»
- **Herramienta n8n Esperada:** `consultar_inspecciones_observaciones`
- **Criterio Relacional:** `inspeccion` $\to$ `funcionario` con filtro `TRIM(observaciones) <> ''`.
- **Columnas de Salida:** `numero_acta`, `numero_dua`, `fecha_inspeccion`, `tipo_inspeccion`, `resultado`, `funcionario_responsable`, `puesto_cargo`, `area_adscripcion`, `observaciones`.
- **Resultado Esperado (15 actas registradas, orden cronológico descendente):**
  - Muestra actas desde `ACTA-INSP-2026-0015` (2026-10-26) hasta `ACTA-INSP-2026-0001` (2026-10-01).
  - Incluye dictámenes de retención preventiva como el acta `ACTA-INSP-2026-0003` (Inspector Lic. Kenneth Guzmán Monge sobre DUA-2026-0003 por discrepancia de número de serie y valor en laptops) y `ACTA-INSP-2026-0007` (retención preventiva por presunta subvaluación en monitores y aires acondicionados).

---

### Prueba 6: Existencias Físicas por Bodega, Producto y Unidad de Medida
- **Pregunta del Usuario:** «¿Cuál es el resumen de existencias en bodega por producto y unidad de medida?»
- **Herramienta n8n Esperada:** `consultar_existencias_bodega`
- **Criterio Relacional:** Agrupación por `(bodega, producto, unidad_medida)` para no sumar magnitudes dimensionalmente incompatibles.
- **Columnas de Salida:** `nombre_bodega`, `codigo_bodega`, `producto`, `sku`, `total_existencia`, `unidad_medida`, `posiciones_estante_ocupadas`.
- **Resultado Esperado (Muestreo de consolidación):**
  - **Bodega Fiscal Central Santamaría (`BOD-FISC-01`):**
    - Monitor Curvo UltraWide 34" (`SKU-MON-CN02`): **180.00 unidades** (ocupando 2 posiciones de estantería: 60 de DUA-0003 + 120 de DUA-0007).
    - Laptop Gamer Pro Titan X (`SKU-LAP-CN01`): **80.00 unidades** (1 posición).
    - Aire Acondicionado Split 24000 BTU (`SKU-AC-CN07`): **50.00 unidades** (1 posición).
    - Inversor Solar On-Grid 5kW (`SKU-INV-CN09`): **40.00 unidades** (1 posición).
  - **Bodega Frigorífica Caldera (`BOD-REFR-02`):**
    - Amoxicilina 500mg Genérico (`SKU-MED-CO05`): **800.00 cajas** (1 posición).
  - **Bodega General de Cargas Moín (`BOD-GENE-03`):**
    - Café Oro Grano Especialidad Tarrazú (`SKU-CAF-CR15`): **8,000.00 kilogramos** (2 posiciones: 5,000 kg + 3,000 kg).

---

### Prueba 7: Importadores que Superan Umbral de $100,000 USD
- **Pregunta del Usuario:** «¿Cuáles empresas importadoras acumulan un valor total superior a cien mil dólares en declaraciones?»
- **Herramienta n8n Esperada:** `consultar_importadores_umbral`
- **Criterio Relacional:** Cláusula `HAVING SUM(cantidad * valor_unitario) > 100000.00`.
- **Columnas de Salida:** `identificacion_tributaria`, `razon_social`, `cantidad_declaraciones`, `valor_total_acumulado_usd`.
- **Resultado Esperado (Exactamente 3 empresas superan el umbral):**

| identificacion_tributaria | razon_social | cantidad_declaraciones | valor_total_acumulado_usd |
| :--- | :--- | :---: | :---: |
| 3-101-456789 | Consorcio Automotriz Central S.A. | 2 | $451,200.00 USD |
| 3-101-123456 | Importadora Tecnológica del Valle S.A. | 2 | $213,600.00 USD |
| 3-101-234567 | Distribuidora Médica Global S.A. | 1 | $130,000.00 USD |

---

### Prueba 8: Declaraciones con Mayor Permanencia y Stock Activo
- **Pregunta del Usuario:** «¿Cuáles son las declaraciones con mayor tiempo de estadía que aún mantienen mercancía almacenada al 31 de octubre de 2026?»
- **Herramienta n8n Esperada:** `consultar_declaraciones_permanencia`
- **Criterio Relacional:** Fecha de corte `2026-10-31 23:59:59-06`, filtro de stock activo (`cantidad_almacenada > 0` y `fecha_salida IS NULL`), cálculo en días por diferencia de epoch.
- **Columnas de Salida:** `numero_dua`, `regimen`, `estado_declaracion`, `importador`, `fecha_ingreso_recinto`, `fecha_corte_evaluacion`, `dias_permanencia_recinto`, `cantidad_total_almacenada`.
- **Resultado Esperado (Top 5 con mayor permanencia):**

| numero_dua | regimen | estado | importador | fecha_ingreso | dias_permanencia | stock_activo |
| :--- | :---: | :---: | :--- | :---: | :---: | :---: |
| **DUA-2026-0008** | Deposito | Retenida | Comercializadora Azteca del Sur S.A. de C.V. | 2026-10-02 06:15:00-06 | **29.74 días** | 40.00 unidades |
| **DUA-2026-0002** | Importacion | En Inspeccion | Distribuidora Médica Global S.A. | 2026-10-03 09:15:00-06 | **28.61 días** | 5.00 unidades |
| **DUA-2026-0003** | Importacion | Retenida | Importadora Tecnológica del Valle S.A. | 2026-10-04 10:00:00-06 | **27.58 días** | 140.00 unidades |
| **DUA-2026-0005** | Importacion | En Inspeccion | Agroquímicos y Semillas del Caribe S.A. | 2026-10-06 11:45:00-06 | **25.51 días** | 800.00 cajas |
| **DUA-2026-0007** | Importacion | Retenida | ElectroHogar y Climatización S.A. | 2026-10-08 07:30:00-06 | **23.69 días** | 170.00 unidades |
