# Laboratorio #3: Sistema de Inventario para una Aduana
## Base de Datos Relacional (PostgreSQL en Supabase) y Agente de IA con n8n

- **Autor:** Reymond Salguero
- **Curso:** Bases de Datos
- **Fecha:** Octubre de 2026
- **Plataforma de Base de Datos:** Supabase
- **Motor Relacional:** PostgreSQL 18
- **Plataforma de Automatización:** n8n (Community / Cloud)

---

## 1. Descripción General del Proyecto

Este laboratorio implementa un sistema integral de control aduanero y trazabilidad de inventarios para la administración fiscal. La solución consta de:
1. **Un esquema relacional en PostgreSQL (`aduana`)** compuesto por 13 entidades normalizadas con integridad referencial estricta, restricciones cuantitativas, control jerárquico y desacoplamiento analítico de orígenes geográficos.
2. **Un conjunto de datos de prueba determinista** con 205 registros reales y académicos contextualizados en octubre de 2026.
3. **Un rol de consulta de mínimo privilegio (`agente_n8n_readonly`)** con Row Level Security (RLS) habilitado y medidas complementarias de defensa en profundidad.
4. **Un agente de Inteligencia Artificial en n8n** equipado con modelo de lenguaje (OpenAI), memoria conversacional amortiguada por sesión y ocho (8) herramientas nativas de PostgreSQL con consultas parametrizadas para auditoría aduanera.

---

## 2. Estructura de Entregables del Repositorio

```text
laboratorio3_aduana/
├── README.md                                   # Guía completa de despliegue, configuración y resolución de problemas
├── investigacion/
│   └── Investigacion_Laboratorio3_Supabase.pdf # Base conceptual formal (6 páginas de contenido + portada + referencias APA 7)
├── modelo/
│   ├── aduana.dbml                             # Contrato del esquema en DBML (válido para dbdiagram.io)
│   ├── diccionario_datos.md                    # Especificación exhaustiva de 13 tablas, columnas, tipos y restricciones
│   └── reglas_negocio.md                       # Cardinalidades, trazabilidad geográfica, control de ciclos y régimen vs estado
├── sql/
│   ├── 00_reinicio_destructivo_opcional.sql    # Script manual de limpieza total (DROP SCHEMA aduana CASCADE)
│   ├── 01_estructura.sql                       # DDL completo (esquema, tablas, llaves, restricciones e índices)
│   ├── 02_datos.sql                            # DML determinista (205 filas y sincronización de secuencias)
│   ├── 03_consultas.sql                        # 8 consultas de negocio con CTE, agregados, HAVING y DENSE_RANK
│   ├── 04_validaciones.sql                     # Auditoría de filas, huérfanos, balance y pruebas de restricciones
│   ├── 05_seguridad_n8n.sql                    # Configuración del rol agente_n8n_readonly con mínimo privilegio y RLS
│   └── laboratorio3_completo.sql               # Script consolidado (estructura + datos + consultas + validaciones)
├── n8n/
│   ├── workflow_aduana_supabase.json           # Workflow importable en n8n (12 nodos, sin secretos quemados)
│   └── system_prompt.md                        # Directivas del agente de IA, manejo de empates y seguridad
└── pruebas/
    ├── casos_y_resultados_esperados.md         # Preguntas exactas, SQL y tablas de resultados esperados calculados
    └── verificacion_tecnica.md                 # Pruebas de contención de permisos, inyección de prompts y capturas
```

---

## 3. Guía de Ejecución Paso a Paso

### Paso 1: Creación del Esquema y Carga de Datos en Supabase
1. Inicie sesión en [Supabase Dashboard](https://supabase.com/dashboard) y seleccione su proyecto.
2. Diríjase a la sección **SQL Editor** en la barra lateral izquierda.
3. Abra y pegue el contenido de [`sql/laboratorio3_completo.sql`](file:///c:/Users/HP8D8/OneDrive/Desktop/Ray/Laboratorio%203%20backend/laboratorio3_aduana/sql/laboratorio3_completo.sql).
4. Presione **Run**. Verifique que:
   - Se cree el esquema `aduana` y las 13 tablas con sus índices.
   - Se inserten los 205 registros de prueba.
   - Se ejecuten las 8 consultas de negocio retornando resultados.
   - El bloque final de validación reporte que todas las pruebas fueron superadas.

### Paso 2: Creación del Rol de Seguridad para n8n
1. En el mismo **SQL Editor** de Supabase, abra el archivo [`sql/05_seguridad_n8n.sql`](file:///c:/Users/HP8D8/OneDrive/Desktop/Ray/Laboratorio%203%20backend/laboratorio3_aduana/sql/05_seguridad_n8n.sql).
2. **Edite la línea de contraseña:** Reemplace `<CONTRASENA_SEGURA_CONFIGURABLE>` por una clave privada y robusta.
3. Presione **Run**.
4. Este script:
   - Crea el rol `agente_n8n_readonly` sin privilegios de superusuario ni escritura.
   - Concede `USAGE` en `aduana` y `SELECT` en sus tablas.
   - Activa y fuerza `ROW LEVEL SECURITY (RLS)` con políticas de lectura.
   - Configura `statement_timeout = '15s'` y `default_transaction_read_only = 'on'`.
   - Ejecuta un bloque de prueba interna que confirma que las operaciones `UPDATE` e `INSERT` son rechazadas.

### Paso 3: Obtención de Parámetros de Conexión en Supabase
1. En Supabase, haga clic en el botón superior **Connect**.
2. Seleccione la pestaña **Session pooler** (o **Direct connection** si su red dispone de conectividad IPv6 directa):
   - **Host:** Se muestra en Connect (ej. `aws-0-[region].pooler.supabase.com`).
   - **Port:** `5432`.
   - **Database:** `postgres`.
   - **User:**
     - Para **Session pooler:** `agente_n8n_readonly.[PROJECT_REF]` (donde `[PROJECT_REF]` es el identificador único de 20 caracteres de su proyecto).
     - Para **Direct connection:** `agente_n8n_readonly`.
   - **Password:** La contraseña configurada en el Paso 2.
   - **SSL:** Requerido (`SSL: true` / TLS habilitado).
3. **ADVERTENCIA:** Jamás use una API Key de Supabase (`anon`, `publishable` o `service_role`) como contraseña de PostgreSQL. La contraseña requerida es la clave SQL del rol `agente_n8n_readonly`.

### Paso 4: Importación y Configuración del Workflow en n8n
1. Abra su instancia de **n8n**.
2. En el menú de workflows, haga clic en los tres puntos (`...`) superiores y seleccione **Import from File**.
3. Seleccione el archivo [`n8n/workflow_aduana_supabase.json`](file:///c:/Users/HP8D8/OneDrive/Desktop/Ray/Laboratorio%203%20backend/laboratorio3_aduana/n8n/workflow_aduana_supabase.json).
4. El lienzo cargará el agente con 12 nodos conectados:
   - **Chat Trigger** conectado a **AI Agent**.
   - **OpenAI Chat Model** conectado a puerto `ai_languageModel`.
   - **Window Buffer Memory** conectado a puerto `ai_memory`.
   - **8 Herramientas Postgres** conectadas a puerto `ai_tool`.

### Paso 5: Asignación de Credenciales en n8n
1. **Credencial de OpenAI:**
   - Haga doble clic sobre el nodo **OpenAI Chat Model**.
   - En la sección **Credential to connect with**, seleccione **Create New Credential** (o asigne una existente). Ingrese su API Key de OpenAI.
2. **Credencial de Postgres:**
   - Haga doble clic sobre cualquiera de las 8 herramientas Postgres (ej. **Tool: Importaciones Octubre**).
   - En **Credential to connect with**, seleccione **Create New Credential**.
   - Complete los campos con los datos obtenidos en el Paso 3:
     - **Host:** Su host del pooler o conexión directa de Supabase.
     - **Database:** `postgres`.
     - **User:** `agente_n8n_readonly.[PROJECT_REF]` (o `agente_n8n_readonly`).
     - **Password:** Su contraseña del rol.
     - **Port:** `5432`.
     - **SSL:** Activado (`require` o `authorized`).
   - Haga clic en **Save** y luego en **Test Connection**. Al ver el indicador verde de conexión exitosa, asigne esta misma credencial a las otras 7 herramientas.

### Paso 6: Prueba Operativa del Agente
1. Haga clic en el botón inferior **Chat** del nodo **Chat Trigger**.
2. Formule una a una las ocho preguntas de prueba detalladas en [`pruebas/casos_y_resultados_esperados.md`](file:///c:/Users/HP8D8/OneDrive/Desktop/Ray/Laboratorio%203%20backend/laboratorio3_aduana/pruebas/casos_y_resultados_esperados.md).
3. Verifique que el agente invoque la herramienta correspondiente y devuelva los resultados exactos esperados.

---

## 4. Guía de Solución de Problemas Frecuentes (Troubleshooting)

### Error 1: Fallo de Certificado SSL / TLS
- **Síntoma:** Error `self signed certificate in certificate chain` o `SSL connection error`.
- **Causa:** El cliente de n8n no reconoce la autoridad certificadora intermedia de Supabase o requiere TLS 1.3.
- **Solución:**
  - En la credencial de Postgres en n8n, verifique que la opción **SSL** esté en `require` o `allow unauthorized certs` si se trata de un entorno local de prueba sin el bundle CA del sistema operativo instalado.
  - Asegúrese de que el puerto sea `5432` y no `6543` (a menos que use Transaction mode en pooler con soporte SSL explícito).

### Error 2: Resolución DNS o Redes Solo IPv4 (`ENOTFOUND` o `EAI_AGAIN`)
- **Síntoma:** Error al conectar con el host directo `db.[PROJECT_REF].supabase.co`.
- **Causa:** Muchas conexiones de internet residenciales o corporativas no disponen de enrutamiento IPv6. La conexión directa de Supabase requiere IPv6 nativo.
- **Solución:**
  - Cambie al **Session Pooler** de Supabase (puerto `5432`, host `aws-0-[region].pooler.supabase.com`).
  - Recuerde modificar el usuario a la sintaxis: `agente_n8n_readonly.[PROJECT_REF]`.

### Error 3: Error de Autenticación (`password authentication failed for user`)
- **Síntoma:** Error `FATAL: password authentication failed for user "agente_n8n_readonly"`.
- **Causa:** Contraseña incorrecta o confusión entre API keys de Supabase y credenciales SQL.
- **Solución:**
  - Verifique que esté usando la contraseña asignada en `CREATE ROLE agente_n8n_readonly WITH PASSWORD '...'`.
  - Si olvidó la contraseña, ejecute en SQL Editor:
    ```sql
    ALTER ROLE agente_n8n_readonly WITH PASSWORD 'NuevaClaveSegura2026!';
    ```
  - Al usar el pooler, no olvide incluir el sufijo `.[PROJECT_REF]` en el usuario.

### Error 4: Permisos Insuficientes (`permission denied for schema aduana`)
- **Síntoma:** La herramienta de n8n arroja `ERROR: permission denied for schema aduana` o `table ...`.
- **Causa:** No se concedió `USAGE` sobre el esquema o `SELECT` sobre las tablas.
- **Solución:**
  - Ejecute nuevamente en SQL Editor:
    ```sql
    GRANT USAGE ON SCHEMA aduana TO agente_n8n_readonly;
    GRANT SELECT ON ALL TABLES IN SCHEMA aduana TO agente_n8n_readonly;
    ```

### Error 5: Tablas Retornan Cero Filas por Políticas RLS
- **Síntoma:** La consulta no da error pero retorna una lista vacía `[]`, a pesar de que hay datos.
- **Causa:** Se habilitó `ROW LEVEL SECURITY` sin crear la política de lectura para `agente_n8n_readonly`.
- **Solución:**
  - Verifique que la política exista con:
    ```sql
    CREATE POLICY p_select_agente ON aduana.pais FOR SELECT TO agente_n8n_readonly USING (true);
    ```
  - Repita para cada tabla o re-ejecute la sección 4 de [`sql/05_seguridad_n8n.sql`](file:///c:/Users/HP8D8/OneDrive/Desktop/Ray/Laboratorio%203%20backend/laboratorio3_aduana/sql/05_seguridad_n8n.sql).

### Error 6: Fuga de Memoria o Historial Contaminado entre Usuarios
- **Síntoma:** El agente recuerda datos de un usuario previo en una nueva conversación.
- **Causa:** Uso de una clave fija en `sessionKey` de la memoria.
- **Solución:**
  - Verifique que en el nodo **Window Buffer Memory** el campo `sessionKey` contenga la expresión dinámica: `={{ $json.sessionId }}`. Esto asegura un buzón de memoria aislado por cada sesión de chat abierta.
  - Recuerde que `Simple Memory` no es apta para *Queue Mode* en clústeres distribuidos; en entornos de producción distribuidos utilice Redis Memory.

### Error 7: Bucle Infinito o Límite de Iteraciones Excedido (`Max iterations reached`)
- **Síntoma:** El nodo AI Agent se detiene tras 5 o 10 iteraciones sin responder.
- **Causa:** Descripciones ambiguas de las herramientas o herramientas que retornan demasiadas columnas confusas.
- **Solución:**
  - Cada una de las 8 herramientas cuenta con descripciones precisas y consultas con alias limpios (`consultar_importaciones_octubre`, etc.).
  - En el nodo **AI Agent**, mantenga el parámetro `maxIterations: 5` para evitar consumo innecesario de tokens.

---

## 5. Declaración de Limitaciones del Entorno

1. **Alojamiento Remoto:** La ejecución real de los scripts SQL y la conexión de red dependen de las credenciales privadas y la instancia de Supabase administrada por el usuario.
2. **Dialecto y Compatibilidad:** Todo el código ha sido verificado sintácticamente para PostgreSQL 18. Para comprobar la versión de su servidor remoto, ejecute:
   ```sql
   SELECT version();
   ```
3. **Carácter Didáctico:** Los números de identificación fiscal, empresas, marchamos aduaneros y códigos DUA (`DUA-2026-XXXX`) son ficticios y formulados con fines académicos bajo el marco legal de Costa Rica (Ley N.º 7557).
