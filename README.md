# Laboratorio #3: Sistema de Inventario para una Aduana
## Base de Datos Relacional (PostgreSQL en Supabase), Agente de IA en n8n e Interfaz Web

- **Autor:** Reymond Salguero
- **Curso:** Bases de Datos
- **Fecha:** Octubre de 2026
- **Plataforma de Base de Datos:** Supabase (AWS us-east-1)
- **Motor Relacional:** PostgreSQL 18
- **Plataforma de Automatización:** n8n (Community / Self-Hosted)
- **Modelo de Lenguaje:** DeepSeek Chat / OpenAI
- **Repositorio Oficial:** [https://github.com/salgueroreymond2-tech/laboratorio-3-back-end-](https://github.com/salgueroreymond2-tech/laboratorio-3-back-end-)

---

## 1. Descripción General del Proyecto

Este laboratorio implementa un sistema integral de trazabilidad, fiscalización y control de inventarios aduaneros para la administración tributaria. La solución se compone de:

1. **Esquema Relacional en PostgreSQL (`aduana`):** 13 tablas normalizadas con integridad referencial estricta, restricciones cuantitativas (CHECK), llaves foráneas, índices optimizados y control jerárquico de fiscalización.
2. **Conjunto Determinista de Datos:** 205 registros reales contextualizados en octubre de 2026, cubriendo declaraciones (DUA), contenedores, importadores, agentes aduanales, inventarios en bodegas y actas de inspección.
3. **Seguridad y Mínimo Privilegio:** Usuario de solo lectura (`usuario_consulta_aduana` / `agente_n8n_readonly`) con políticas RLS y bloqueo de operaciones destructivas (`INSERT`, `UPDATE`, `DELETE`, `DROP`).
4. **Agente de Inteligencia Artificial en n8n (5 Nodos):** Arquitectura limpia requerida por la guía de cátedra con Chat Trigger, AI Agent, DeepSeek Chat Model, Simple Memory (Window Buffer) y Herramienta Dinámica Postgres (`Consultar_BD_Aduana`).
5. **Interfaz Web Interactiva:** Aplicación web moderna con chat en tiempo real (`http://localhost:8080`) conectada directamente con n8n, donde cada consulta queda registrada con trazabilidad completa en el historial de **Executions** de n8n.

---

## 2. Estructura Modular del Repositorio

El proyecto se encuentra estrictamente modularizado en la raíz del repositorio para garantizar orden, trazabilidad y facilidad de evaluación:

```text
laboratorio-3-back-end-/
├── investigacion/
│   └── Investigacion_Laboratorio3_Supabase.pdf # Base conceptual formal (6 páginas + referencias APA 7)
├── modelo/
│   ├── aduana.dbml                             # Contrato del esquema en DBML (válido para dbdiagram.io)
│   ├── aduana.drawio                           # Diagrama Entidad-Relación visual editable
│   ├── diccionario_datos.md                    # Especificación exhaustiva de las 13 tablas, columnas y tipos
│   └── reglas_negocio.md                       # Cardinalidades, trazabilidad geográfica y reglas aduaneras
├── sql/
│   ├── 00_reinicio_destructivo_opcional.sql    # Script manual de limpieza total (DROP SCHEMA aduana CASCADE)
│   ├── 01_estructura.sql                       # DDL completo (esquema, 13 tablas, llaves, restricciones e índices)
│   ├── 02_datos.sql                            # DML determinista (205 filas y sincronización de secuencias)
│   ├── 03_consultas.sql                        # 8 consultas de negocio con CTE, agregados, HAVING y DENSE_RANK
│   ├── 04_validaciones.sql                     # Auditoría de filas, huérfanos, balance y pruebas de restricciones
│   ├── 05_seguridad_n8n.sql                    # Configuración del rol de solo lectura con mínimo privilegio y RLS
│   ├── laboratorio3_completo.sql               # Script consolidado (estructura + datos + consultas + validaciones)
│   └── laboratorio3_supabase_public.sql        # Versión adaptada para el esquema public en Supabase
├── n8n/
│   ├── workflow_aduana_supabase.json           # Workflow oficial importable en n8n (5 nodos de la guía de cátedra)
│   ├── system_prompt.md                        # Directivas del agente de IA, esquema exacto y reglas de consulta
│   └── README.md                               # Guía técnica de nodos, importación y configuración
├── pruebas/
│   ├── casos_y_resultados_esperados.md         # Preguntas exactas, SQL y tablas de resultados esperados calculados
│   ├── pruebas_workflow.md                     # Guía paso a paso de pruebas del agente y validaciones
│   └── verificacion_tecnica.md                 # Pruebas de contención de permisos e inyección de prompts
├── web/
│   ├── index.html                              # Interfaz web interactiva del sistema de inventario aduanero
│   ├── server.py                               # Servidor HTTP proxy que registra cada consulta en n8n
│   └── run_n8n.bat                             # Script lanzador con bypass SSL para n8n local
├── README.md                                   # Guía maestra de despliegue, configuración y arquitectura
└── .gitignore                                  # Configuración de exclusiones de Git
```

---

## 3. Guía de Ejecución Rápida

### Paso 1: Base de Datos en Supabase
1. Abra el **SQL Editor** en su proyecto de [Supabase Dashboard](https://supabase.com/dashboard).
2. Ejecute el script [`sql/laboratorio3_completo.sql`](sql/laboratorio3_completo.sql) para crear las 13 tablas en el esquema `aduana`, insertar los 205 registros y validar las pruebas de integridad.
3. Ejecute el script [`sql/05_seguridad_n8n.sql`](sql/05_seguridad_n8n.sql) para habilitar el rol de solo lectura.

### Paso 2: Flujo del Agente en n8n
1. Inicie n8n ejecutando el script `web/run_n8n.bat` (o `n8n start` con TLS deshabilitado para evitar conflictos con certificados autofirmados).
2. Abra `http://localhost:5678` en su navegador.
3. Importe el archivo [`n8n/workflow_aduana_supabase.json`](n8n/workflow_aduana_supabase.json).
4. Verifique la conexión de los 5 nodos:
   - **Chat Trigger** (`aduana-lab3-chat-webhook/chat`)
   - **AI Agent** (Orquestador central con prompt de aduanas)
   - **DeepSeek Chat Model** (o OpenAI)
   - **Simple Memory** (Window Buffer Memory de 6 turnos)
   - **Consultar_BD_Aduana** (Herramienta Postgres con credenciales de Supabase)
5. Asegúrese de que el switch **Active** en la esquina superior derecha esté en verde.

### Paso 3: Servidor y Aplicación Web
1. Desde la carpeta `web/`, ejecute:
   ```bash
   python server.py
   ```
2. Abra su navegador en: **`http://localhost:8080`**.
3. Realice sus consultas en lenguaje natural o presione los botones de acceso rápido.
4. Abra **`http://localhost:5678/workflow/VDPl5zFTlpR9jPJ9/executions`**: verá cómo cada consulta formulada en la web queda registrada en tiempo real en n8n con estado `success`, mostrando el árbol de ejecución, la sentencia SQL generada y los datos devueltos por PostgreSQL.

---

## 4. Preguntas Oficiales de Evaluación y Resultados Esperados

| # | Pregunta en Lenguaje Natural | Tabla / Entidad Consultada | Resumen del Resultado Esperado |
|---|---|---|---|
| **1** | *"¿Cuáles declaraciones de importación se registraron en octubre de 2026?"* | `declaracion_aduanera` | 8 DUAs con régimen de Importación entre `2026-10-01` y `2026-10-31`. |
| **2** | *"¿Qué mercancías de China están retenidas en bodega y su ubicación?"* | `inventario_bodega` + `declaracion_aduanera` + `producto` + `pais` | 5 ítems retenidos (Laptops, Monitores, Aires, Inversores) por un total de 350 unidades en Bodega Central Santamaría. |
| **3** | *"¿Cuál es el país de procedencia con mayor número de contenedores?"* | `contenedor` + `pais` | Empate en 1er lugar entre China (3 contenedores) y Estados Unidos (3 contenedores). |
| **4** | *"¿Cuál es la empresa importadora con mayor valor acumulado en USD?"* | `importador` + `detalle_declaracion` | Importadores líderes con desglose detallado de valor CIF en dólares. |
| **5** | *"Muéstrame las inspecciones con observaciones y su funcionario responsable."* | `inspeccion` + `funcionario` + `declaracion_aduanera` | 4 actas técnicas con observaciones registradas y nombre/cargo del inspector. |
| **6** | *"¿Cuáles son las bodegas registradas y su capacidad en metros cúbicos?"* | `bodega` | 15 bodegas activas (Fiscales, Generales, Frigoríficas y Peligrosas) con 54,100 m³ totales. |

---

## 5. Solución de Problemas Frecuentes

- **Error de certificado SSL en Postgres de n8n:**  
  Supabase utiliza certificados intermedios. En la credencial de Postgres dentro de n8n, active la casilla `allowUnauthorizedCerts: true`, o inicie n8n con `NODE_TLS_REJECT_UNAUTHORIZED=0` (incluido en `web/run_n8n.bat`).
- **Consultas no se registran en n8n:**  
  Verifique que el workflow esté activado (interruptor en verde en n8n) y que `server.py` apunte al endpoint `http://localhost:5678/webhook/aduana-lab3-chat-webhook/chat`.
