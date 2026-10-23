# Sistema de Inventario Aduanero: n8n & Supabase Data API

Esta solución implementa el **Laboratorio #3: Sistema de inventario para una aduana** utilizando la **Data API nativa de Supabase** (`n8n-nodes-base.supabase`) y un **AI Agent** orquestador conectado a **8 subworkflows deterministas** en JavaScript.

No requiere conexión directa por puerto 5432, ni pooler, ni contraseña maestra de PostgreSQL: utiliza exclusivamente la URL de tu proyecto Supabase y tu API Key de servicio ya registrada en n8n.

---

## 1. Arquitectura de la Solución

```
                                  ┌─────────────────────────────────────┐
                                  │       Chat Trigger (Webhook)        │
                                  └──────────────────┬──────────────────┘
                                                     │ main
                                                     ▼
┌───────────────────────────┐         ┌─────────────────────────────────┐         ┌───────────────────────────┐
│    DeepSeek Chat Model    │────────>│            AI Agent             │<────────│       Simple Memory       │
│ ('DeepSeek account 11')   │         │          (Orquestador)          │         │    (Ventana: 6 turnos)    │
└───────────────────────────┘         └──────────────┬──────────────────┘         └───────────────────────────┘
                                                     │ ai_tool
      ┌──────────────────────────────────────────────┴──────────────────────────────────────────────┐
      │                                                                                             │
      ├─► consultar_importaciones_periodo          ──► [Subworkflow 01] ──► Supabase + Code en JS  │
      ├─► consultar_mercancia_retenida_por_origen  ──► [Subworkflow 02] ──► Supabase + Code en JS  │
      ├─► consultar_pais_con_mas_contenedores      ──► [Subworkflow 03] ──► Supabase + DENSE_RANK  │
      ├─► consultar_importador_mayor_valor         ──► [Subworkflow 04] ──► Supabase + DENSE_RANK  │
      ├─► consultar_inspecciones_con_observaciones ──► [Subworkflow 05] ──► Supabase + Filtro trim │
      ├─► consultar_stock_por_bodega               ──► [Subworkflow 06] ──► Supabase + Agrupación  │
      ├─► consultar_importadores_por_umbral        ──► [Subworkflow 07] ──► Supabase + HAVING en JS│
      └─► consultar_permanencia_en_bodega          ──► [Subworkflow 08] ──► Supabase + Días fecha  │
```

### Principio de Funcionamiento de los Subworkflows:
Cada herramienta se ejecuta mediante un subworkflow especializado:
1. **Trigger:** `Execute Workflow Trigger` recibe los parámetros opcionales del agente (fechas, país, umbral, bodega).
2. **Nodos Supabase:** Nodos nativos `n8n-nodes-base.supabase` leen las tablas estructuradas mediante la Data API (operación `getAll`).
3. **Nodo Code (JavaScript):** Realiza de forma determinista los cruces relacionales (JOINs en memoria), filtrados, agrupaciones y cálculos de ranking (`DENSE_RANK`), devolviendo un JSON limpio y formateado al agente.

---

## 2. Paso Previo Indispensable en Supabase: Crear Tablas y Datos

Supabase expone por defecto en su Data API las tablas alojadas en el esquema `public`. Para cargar las 13 tablas relacionales y los 205 registros deterministas:

1. Ingresa a tu dashboard de Supabase:  
   👉 [https://supabase.com/dashboard/project/ilywnswaosjdehtlmbwv/sql](https://supabase.com/dashboard/project/ilywnswaosjdehtlmbwv/sql)
2. Abre un nuevo editor SQL (**New Query**).
3. Copia el contenido completo del archivo:  
   📄 [laboratorio3_aduana/sql/laboratorio3_supabase_public.sql](file:///c:/Users/HP8D8/OneDrive/Desktop/Ray/Laboratorio%203%20backend/laboratorio3_aduana/sql/laboratorio3_supabase_public.sql)
4. Pégalo en el SQL Editor y presiona **Run**.
5. Las 13 tablas (`declaracion_aduanera`, `inventario_bodega`, `producto`, `pais`, etc.) quedarán creadas con sus claves foráneas e índices, cargando los 205 registros de prueba y quedando expuestas inmediatamente en tu Data API.

---

## 3. Estado de los Flujos en n8n (¡Ya Pre-Registrados!)

Para tu máxima comodidad, **los 9 flujos de trabajo ya fueron inyectados directamente en tu base de datos local de n8n** (`database.sqlite`) vinculados a tu proyecto personal:

| Identificador n8n | Nombre del Flujo en tu n8n | Archivo JSON de Respaldo |
| :--- | :--- | :--- |
| `WFAduanaSupabase` | **Laboratorio #3 - Sistema de Inventario Aduanero (Supabase Data API)** | [n8n/workflow_aduana_supabase.json](file:///c:/Users/HP8D8/OneDrive/Desktop/Ray/Laboratorio%203%20backend/laboratorio3_aduana/n8n/workflow_aduana_supabase.json) |
| `SWF01AduanaImpP` | Subworkflow 01 - Importaciones Periodo | [subworkflows/subworkflow_01_importaciones_periodo.json](file:///c:/Users/HP8D8/OneDrive/Desktop/Ray/Laboratorio%203%20backend/laboratorio3_aduana/n8n/subworkflows/subworkflow_01_importaciones_periodo.json) |
| `SWF02AduanaMercC` | Subworkflow 02 - Mercancia China Retenida | [subworkflows/subworkflow_02_mercancia_china_retenida.json](file:///c:/Users/HP8D8/OneDrive/Desktop/Ray/Laboratorio%203%20backend/laboratorio3_aduana/n8n/subworkflows/subworkflow_02_mercancia_china_retenida.json) |
| `SWF03AduanaPaisC` | Subworkflow 03 - Pais con Mas Contenedores | [subworkflows/subworkflow_03_pais_mas_contenedores.json](file:///c:/Users/HP8D8/OneDrive/Desktop/Ray/Laboratorio%203%20backend/laboratorio3_aduana/n8n/subworkflows/subworkflow_03_pais_mas_contenedores.json) |
| `SWF04AduanaImpVal` | Subworkflow 04 - Importador Mayor Valor | [subworkflows/subworkflow_04_importador_mayor_valor.json](file:///c:/Users/HP8D8/OneDrive/Desktop/Ray/Laboratorio%203%20backend/laboratorio3_aduana/n8n/subworkflows/subworkflow_04_importador_mayor_valor.json) |
| `SWF05AduanaInspOb` | Subworkflow 05 - Inspecciones con Observaciones | [subworkflows/subworkflow_05_inspecciones_observaciones.json](file:///c:/Users/HP8D8/OneDrive/Desktop/Ray/Laboratorio%203%20backend/laboratorio3_aduana/n8n/subworkflows/subworkflow_05_inspecciones_observaciones.json) |
| `SWF06AduanaStkBod` | Subworkflow 06 - Stock por Bodega | [subworkflows/subworkflow_06_stock_por_bodega.json](file:///c:/Users/HP8D8/OneDrive/Desktop/Ray/Laboratorio%203%20backend/laboratorio3_aduana/n8n/subworkflows/subworkflow_06_stock_por_bodega.json) |
| `SWF07AduanaImpUmb` | Subworkflow 07 - Importadores sobre Umbral | [subworkflows/subworkflow_07_importadores_umbral.json](file:///c:/Users/HP8D8/OneDrive/Desktop/Ray/Laboratorio%203%20backend/laboratorio3_aduana/n8n/subworkflows/subworkflow_07_importadores_umbral.json) |
| `SWF08AduanaPermBo` | Subworkflow 08 - Permanencia en Bodega | [subworkflows/subworkflow_08_permanencia_bodega.json](file:///c:/Users/HP8D8/OneDrive/Desktop/Ray/Laboratorio%203%20backend/laboratorio3_aduana/n8n/subworkflows/subworkflow_08_permanencia_bodega.json) |

### Cómo abrirlos en n8n:
1. Abre o recarga tu pestaña de n8n en el navegador (`http://localhost:5678`).
2. Ve a la pestaña **Workflows**.
3. Verás listados todos los subworkflows y el flujo principal **Laboratorio #3 - Sistema de Inventario Aduanero**.
4. Haz clic en el flujo principal: verás los 12 nodos conectados sin marcas rojas (tu credencial existente `DeepSeek account 11` y `Supabase account` ya están enlazadas).

---

## 4. Batería de Pruebas de Chat Interactivo

Abre el chat en la parte inferior del flujo principal y prueba las consultas oficiales documentadas en [pruebas_workflow.md](file:///c:/Users/HP8D8/OneDrive/Desktop/Ray/Laboratorio%203%20backend/laboratorio3_aduana/pruebas/pruebas_workflow.md):

1. **Importaciones Octubre 2026:**
   * Pregunta: *"¿Cuáles declaraciones de importación se tramitaron en el mes de octubre de 2026?"*
   * Resultado esperado: 8 DUAs (desde `DUA-2026-000101` hasta `DUA-2026-000114`).
2. **Mercancía China Retenida:**
   * Pregunta: *"Indícame qué mercancías de China están retenidas en bodega y su stock."*
   * Resultado esperado: Microcontroladores ESP32 (1,000 unidades) y Transformadores (15 unidades) en Bodega Central.
3. **País con más contenedores:**
   * Pregunta: *"¿Cuál es el país de procedencia con mayor número de contenedores?"*
   * Resultado esperado: Empate en 1er lugar entre China (3) y Estados Unidos (3).
4. **Importador con mayor valor:**
   * Pregunta: *"¿Cuál es la empresa importadora con mayor valor acumulado declarado?"*
   * Resultado esperado: Empate en 1er lugar entre Comercializadora Global del Valle y Distribuidora Mayorista del Este ($88,500.00 USD).
5. **Inspecciones con observaciones:**
   * Pregunta: *"Muéstrame las inspecciones con observaciones y su funcionario responsable."*
   * Resultado esperado: 4 actas técnicas con observaciones detalladas.
6. **Stock por bodega:**
   * Pregunta: *"¿Cuáles son las existencias físicas activas almacenadas por bodega?"*
   * Resultado esperado: 13 agrupaciones activas en Bodega Central, Refrigerada y Químicos.
7. **Importadores sobre umbral:**
   * Pregunta: *"Lista los importadores que superan los $100,000 USD."*
   * Resultado esperado: 0 importadores (informa que el máximo es $88,500.00 USD sin simular datos).
8. **Permanencia en bodega:**
   * Pregunta: *"¿Cuáles declaraciones tienen mayor tiempo de permanencia al 31 de octubre de 2026?"*
   * Resultado esperado: `DUA-2026-000101` con 33.71 días y `DUA-2026-000102` con 31.71 días.
