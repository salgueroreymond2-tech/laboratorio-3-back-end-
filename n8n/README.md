# Flujo de n8n - Sistema de Inventario Aduanero (Laboratorio #3)

Este directorio contiene la definición oficial del flujo de trabajo de Inteligencia Artificial para el **Laboratorio #3: Sistema de inventario para una aduana**.

El flujo implementa la arquitectura limpia de 5 nodos requerida en la guía de cátedra, permitiendo recibir preguntas en lenguaje natural, consultar la base de datos PostgreSQL en Supabase y responder con datos verídicos y actualizados.

---

## 1. Arquitectura de 5 Nodos en n8n

```
                               ┌────────────────────────────────────────┐
                               │         1. Chat Trigger (Nodo)         │
                               │  Ruta: aduana-lab3-chat-webhook/chat   │
                               └───────────────────┬────────────────────┘
                                                   │ main
                                                   ▼
┌────────────────────────────┐          ┌───────────────────────┐          ┌────────────────────────────┐
│ 3. DeepSeek / OpenAI Model │─────────>│      2. AI Agent      │<─────────│   4. Simple Memory (Nodo)  │
│    (Puerto ai_language)    │          │  (Orquestador Central)│          │     (Puerto ai_memory)     │
└────────────────────────────┘          └──────────┬────────────┘          └────────────────────────────┘
                                                   │ ai_tool
                                                   ▼
                                        ┌───────────────────────┐
                                        │ 5. Consultar_BD_Aduana│
                                        │   (Herramienta SQL)   │
                                        └───────────────────────┘
                                                   │
                                                   ▼
                                        [Supabase PostgreSQL]
                                        (Esquema: aduana)
```

### Detalle de cada nodo:
1. **Chat Trigger**: Abre el canal de comunicación donde el usuario formula su consulta (mediante interfaz web o chat canvas).
2. **AI Agent**: El cerebro del flujo. Interpreta la intención del usuario, formula sentencias SQL `SELECT` precisas contra el esquema `aduana` y genera la respuesta final.
3. **Chat Model (DeepSeek / OpenAI)**: Modelo de lenguaje de alta precisión (`deepseek-chat` o `gpt-4o-mini`) que proporciona el razonamiento analítico.
4. **Memoria (Simple Memory - Window Buffer Memory)**: Almacena el historial conversacional (`contextWindowLength: 6`) vinculado por `sessionId`, permitiendo recordar el hilo de la conversación.
5. **Herramienta de base de datos (Postgres Tool - Consultar_BD_Aduana)**: Ejecuta las consultas SQL de solo lectura (`SELECT`) de forma dinámica sobre la base de datos de aduanas en Supabase.

---

## 2. Archivos del Módulo

- `workflow_aduana_supabase.json`: Archivo JSON oficial del flujo, listo para importar directamente en cualquier instancia de n8n.
- `system_prompt.md`: Especificación completa del prompt de sistema, reglas estrictas de seguridad (SELECT only) y el diccionario de columnas de las 13 tablas relacionales.
- `README.md`: Esta guía técnica de referencia.

---

## 3. Instrucciones de Importación en n8n

1. En tu instancia de n8n (`http://localhost:5678`), haz clic en el menú superior derecho (`...`) y selecciona **Import from File**.
2. Selecciona el archivo `n8n/workflow_aduana_supabase.json`.
3. Asigna tus credenciales en los nodos:
   - **DeepSeek Chat Model**: Credencial de API DeepSeek o cuenta OpenAI.
   - **Consultar_BD_Aduana**: Credencial de conexión PostgreSQL (Host de Supabase, puerto 5432, base de datos `postgres`, SSL activo).
4. Activa el interruptor **Active** (publicado) en la esquina superior derecha.
5. Todas las preguntas que se hagan desde la interfaz web (`http://localhost:8080`) o desde el chat de n8n quedarán automáticamente registradas en la pestaña **Executions** del flujo.
