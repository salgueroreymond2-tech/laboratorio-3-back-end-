# Diccionario de Datos — Sistema de Inventario Aduanero

- **Proyecto:** Laboratorio #3: Sistema de inventario para una aduana: base de datos relacional y agente de IA con n8n
- **Autor:** Reymond Salguero
- **Fecha:** Octubre de 2026
- **Plataforma:** Supabase
- **Motor de Base de Datos:** PostgreSQL 18
- **Esquema:** `aduana`

---

## Índice de Tablas

1. [`aduana.pais`](#1-aduanapais) — Catálogo de países
2. [`aduana.importador`](#2-aduanaimportador) — Empresas y personas importadoras
3. [`aduana.agente_aduanal`](#3-aduanaagente_aduanal) — Auxiliares aduaneros autorizados
4. [`aduana.categoria_arancelaria`](#4-aduanacategoria_arancelaria) — Subpartidas del Sistema Armonizado
5. [`aduana.producto`](#5-aduanaproducto) — Catálogo de mercancías y origen de fabricación
6. [`aduana.contenedor`](#6-aduanacontenedor) — Unidades intermodales y país de procedencia
7. [`aduana.ficha_contenedor`](#7-aduanaficha_contenedor) — Ficha técnica y precinto aduanero (Relación 1:1)
8. [`aduana.declaracion_aduanera`](#8-aduanadeclaracion_aduanera) — Cabeceras de DUA
9. [`aduana.detalle_declaracion`](#9-aduanadetalle_declaracion) — Líneas de mercancía declarada
10. [`aduana.bodega`](#10-aduanabodega) — Instalaciones de almacenamiento fiscal
11. [`aduana.inventario_bodega`](#11-aduanainventario_bodega) — Existencias físicas por línea de DUA
12. [`aduana.funcionario`](#12-aduanafuncionario) — Personal aduanero y jerarquía supervisora
13. [`aduana.inspeccion`](#13-aduanainspeccion) — Actas de aforo físico y documental

---

## Especificación Detallada de Entidades

### 1. `aduana.pais`
Catálogo de países normalizado. Permite desacoplar y contrastar de manera inequívoca: (a) el país de constitución del importador, (b) el país de fabricación del producto (ej. China) y (c) el país de procedencia/embarque del contenedor.

| Columna | Tipo PostgreSQL | PK | FK | Nulable | Valor por Defecto | Restricciones / Reglas | Descripción Funcional |
| :--- | :--- | :---: | :---: | :---: | :--- | :--- | :--- |
| `id_pais` | `INTEGER` | Sí | No | No | `GENERATED ALWAYS AS IDENTITY` | Llave primaria | Identificador secuencial único del país. |
| `codigo_iso_alfa2` | `VARCHAR(2)` | No | No | No | *Ninguno* | `UNIQUE`, `CHECK (length(codigo_iso_alfa2) = 2 AND codigo_iso_alfa2 = upper(codigo_iso_alfa2))` | Código estándar ISO 3166-1 alfa-2 (ej. CR, CN, US). |
| `nombre` | `VARCHAR(100)` | No | No | No | *Ninguno* | `UNIQUE` | Nombre común del país en español. |
| `activo` | `BOOLEAN` | No | No | No | `TRUE` | *Ninguno* | Bandera lógica de vigencia del país. |

---

### 2. `aduana.importador`
Empresas jurídicas o personas físicas registradas ante la aduana para internar o exportar mercancías.

| Columna | Tipo PostgreSQL | PK | FK | Nulable | Valor por Defecto | Restricciones / Reglas | Descripción Funcional |
| :--- | :--- | :---: | :---: | :---: | :--- | :--- | :--- |
| `id_importador` | `INTEGER` | Sí | No | No | `GENERATED ALWAYS AS IDENTITY` | Llave primaria | Identificador único del importador. |
| `id_pais` | `INTEGER` | No | Sí | No | *Ninguno* | `REFERENCES aduana.pais(id_pais) ON DELETE RESTRICT` | País de domicilio legal o constitución. |
| `identificacion_tributaria` | `VARCHAR(20)` | No | No | No | *Ninguno* | `UNIQUE`, `CHECK (trim(identificacion_tributaria) <> '')` | Identificación fiscal única (cédula jurídica o NIF). |
| `razon_social` | `VARCHAR(150)` | No | No | No | *Ninguno* | `CHECK (trim(razon_social) <> '')` | Nombre legal o razón social de la entidad. |
| `correo_contacto` | `VARCHAR(100)` | No | No | No | *Ninguno* | `CHECK (position('@' IN correo_contacto) > 1)` | Correo electrónico corporativo. |
| `telefono_contacto` | `VARCHAR(25)` | No | No | No | *Ninguno* | *Ninguno* | Teléfono oficial de notificaciones. |
| `direccion_fiscal` | `TEXT` | No | No | No | *Ninguno* | `CHECK (trim(direccion_fiscal) <> '')` | Domicilio fiscal declarado. |
| `activo` | `BOOLEAN` | No | No | No | `TRUE` | *Ninguno* | Estado operativo del importador. |

---

### 3. `aduana.agente_aduanal`
Auxiliar autorizado de la función pública aduanera que tramita y valida el despacho aduanero en representación del declarante (Ley General de Aduanas N.º 7557).

| Columna | Tipo PostgreSQL | PK | FK | Nulable | Valor por Defecto | Restricciones / Reglas | Descripción Funcional |
| :--- | :--- | :---: | :---: | :---: | :--- | :--- | :--- |
| `id_agente_aduanal` | `INTEGER` | Sí | No | No | `GENERATED ALWAYS AS IDENTITY` | Llave primaria | Identificador único del agente aduanal. |
| `numero_licencia` | `VARCHAR(20)` | No | No | No | *Ninguno* | `UNIQUE`, `CHECK (trim(numero_licencia) <> '')` | Número oficial de acreditación aduanera. |
| `nombre_completo` | `VARCHAR(150)` | No | No | No | *Ninguno* | `CHECK (trim(nombre_completo) <> '')` | Nombre y apellidos del profesional autorizado. |
| `correo` | `VARCHAR(100)` | No | No | No | *Ninguno* | `CHECK (position('@' IN correo) > 1)` | Correo electrónico de contacto aduanero. |
| `telefono` | `VARCHAR(25)` | No | No | No | *Ninguno* | *Ninguno* | Teléfono oficial del despacho aduanero. |
| `activo` | `BOOLEAN` | No | No | No | `TRUE` | *Ninguno* | Estado de la licencia aduanera. |

---

### 4. `aduana.categoria_arancelaria`
Clasificación arancelaria conforme al Sistema Armonizado de Designación y Codificación de Mercancías (SA de la OMA).

| Columna | Tipo PostgreSQL | PK | FK | Nulable | Valor por Defecto | Restricciones / Reglas | Descripción Funcional |
| :--- | :--- | :---: | :---: | :---: | :--- | :--- | :--- |
| `id_categoria` | `INTEGER` | Sí | No | No | `GENERATED ALWAYS AS IDENTITY` | Llave primaria | Identificador único de la categoría. |
| `codigo_capitulo` | `VARCHAR(2)` | No | No | No | *Ninguno* | `CHECK (length(codigo_capitulo) = 2)` | Dos primeros dígitos (capítulo arancelario, ej. '84'). |
| `codigo_partida` | `VARCHAR(4)` | No | No | No | *Ninguno* | `CHECK (length(codigo_partida) = 4)` | Cuatro dígitos (partida arancelaria, ej. '8471'). |
| `codigo_subpartida` | `VARCHAR(6)` | No | No | No | *Ninguno* | `UNIQUE`, `CHECK (length(codigo_subpartida) = 6)` | Seis dígitos de subpartida internacional (ej. '847130'). Conserva ceros iniciales como texto. |
| `descripcion` | `TEXT` | No | No | No | *Ninguno* | `CHECK (trim(descripcion) <> '')` | Descripción oficial de la subpartida. |
| `arancel_base_porcentaje` | `NUMERIC(5,2)` | No | No | No | *Ninguno* | `CHECK (arancel_base_porcentaje >= 0 AND arancel_base_porcentaje <= 100)` | Tasa arancelaria base académica de referencia (0.00% a 100.00%). |

---

### 5. `aduana.producto`
Catálogo de mercancías susceptibles de despacho aduanero.

| Columna | Tipo PostgreSQL | PK | FK | Nulable | Valor por Defecto | Restricciones / Reglas | Descripción Funcional |
| :--- | :--- | :---: | :---: | :---: | :--- | :--- | :--- |
| `id_producto` | `INTEGER` | Sí | No | No | `GENERATED ALWAYS AS IDENTITY` | Llave primaria | Identificador único de la mercancía. |
| `id_categoria` | `INTEGER` | No | Sí | No | *Ninguno* | `REFERENCES aduana.categoria_arancelaria(id_categoria) ON DELETE RESTRICT` | Subpartida arancelaria correspondiente. |
| `id_pais_origen` | `INTEGER` | No | Sí | No | *Ninguno* | `REFERENCES aduana.pais(id_pais) ON DELETE RESTRICT` | **País de fabricación/origen del bien.** Responde a consultas como «mercancías de China». |
| `codigo_sku` | `VARCHAR(30)` | No | No | No | *Ninguno* | `UNIQUE`, `CHECK (trim(codigo_sku) <> '')` | Código SKU o código de barras de catálogo. |
| `nombre_comercial` | `VARCHAR(150)` | No | No | No | *Ninguno* | `CHECK (trim(nombre_comercial) <> '')` | Nombre comercial del producto. |
| `descripcion` | `TEXT` | No | No | No | *Ninguno* | *Ninguno* | Descripción técnica del producto. |
| `unidad_medida` | `VARCHAR(20)` | No | No | No | *Ninguno* | `CHECK (unidad_medida IN ('unidades', 'kilogramos', 'litros', 'cajas'))` | Unidad de medida dimensional estándar. |
| `activo` | `BOOLEAN` | No | No | No | `TRUE` | *Ninguno* | Estado del producto en catálogo. |

---

### 6. `aduana.contenedor`
Unidades intermodales de transporte de carga estandarizadas (ISO 6346).

| Columna | Tipo PostgreSQL | PK | FK | Nulable | Valor por Defecto | Restricciones / Reglas | Descripción Funcional |
| :--- | :--- | :---: | :---: | :---: | :--- | :--- | :--- |
| `id_contenedor` | `INTEGER` | Sí | No | No | `GENERATED ALWAYS AS IDENTITY` | Llave primaria | Identificador secuencial interno. |
| `id_pais_procedencia` | `INTEGER` | No | Sí | No | *Ninguno* | `REFERENCES aduana.pais(id_pais) ON DELETE RESTRICT` | **País de procedencia física del contenedor.** Responde a «país con más contenedores». |
| `numero_sigla` | `VARCHAR(11)` | No | No | No | *Ninguno* | `UNIQUE`, `CHECK (length(numero_sigla) = 11)` | Código internacional BIC (ej. 'MSKU1234567'). |
| `tipo_dimension` | `VARCHAR(20)` | No | No | No | *Ninguno* | `CHECK (tipo_dimension IN ('20GP', '40GP', '40HC', '45HC', '20RF', '40RF'))` | Tamaño y propósito estandarizado. |
| `tara_kg` | `NUMERIC(10,2)` | No | No | No | *Ninguno* | `CHECK (tara_kg > 0)` | Peso en vacío del contenedor en kg. |
| `capacidad_max_kg` | `NUMERIC(10,2)` | No | No | No | *Ninguno* | `CHECK (capacidad_max_kg > tara_kg)` | Carga máxima neta admisible en kg. |
| `estado_operativo` | `VARCHAR(25)` | No | No | No | *Ninguno* | `CHECK (estado_operativo IN ('En Transito', 'En Puerto', 'En Inspeccion', 'En Bodega', 'Despachado'))` | Ubicación y estado logístico del equipo. |

---

### 7. `aduana.ficha_contenedor`
Entidad 13: Ficha técnica y precinto de seguridad aduanera. Modela una **relación 1:1 estricta** con `contenedor`. Su llave primaria es a la vez llave foránea hacia `contenedor.id_contenedor`.

| Columna | Tipo PostgreSQL | PK | FK | Nulable | Valor por Defecto | Restricciones / Reglas | Descripción Funcional |
| :--- | :--- | :---: | :---: | :---: | :--- | :--- | :--- |
| `id_contenedor` | `INTEGER` | Sí | Sí | No | *Ninguno* | `REFERENCES aduana.contenedor(id_contenedor) ON DELETE RESTRICT` | PK y FK simultánea (garantiza unicidad 1:1 estricta). |
| `numero_marchamo_aduana` | `VARCHAR(30)` | No | No | No | *Ninguno* | `UNIQUE`, `CHECK (trim(numero_marchamo_aduana) <> '')` | Número de precinto o sello de alta seguridad aduanera. |
| `temperatura_controlada_c` | `NUMERIC(5,2)` | No | No | Sí | `NULL` | *Ninguno* | Grados Celsius registrados para contenedores reefer. |
| `humedad_relativa_porc` | `NUMERIC(5,2)` | No | No | Sí | `NULL` | `CHECK (humedad_relativa_porc IS NULL OR (humedad_relativa_porc >= 0 AND humedad_relativa_porc <= 100))` | Porcentaje de humedad en contenedores de atmósfera controlada. |
| `observacion_inspeccion_fisica` | `TEXT` | No | No | Sí | `NULL` | *Ninguno* | Notas sobre el estado físico de precintos o estructura. |
| `fecha_emision_ficha` | `TIMESTAMPTZ` | No | No | No | `CURRENT_TIMESTAMP` | *Ninguno* | Fecha y hora de generación de la ficha aduanera. |

---

### 8. `aduana.declaracion_aduanera`
Cabecera del Documento Único Aduanero (DUA). Registra la transacción aduanera, el régimen al que se somete y el estado operativo del trámite.

| Columna | Tipo PostgreSQL | PK | FK | Nulable | Valor por Defecto | Restricciones / Reglas | Descripción Funcional |
| :--- | :--- | :---: | :---: | :---: | :--- | :--- | :--- |
| `id_declaracion` | `INTEGER` | Sí | No | No | `GENERATED ALWAYS AS IDENTITY` | Llave primaria | Identificador único de la declaración. |
| `id_importador` | `INTEGER` | No | Sí | No | *Ninguno* | `REFERENCES aduana.importador(id_importador) ON DELETE RESTRICT` | Declarante o consignatario de la carga. |
| `id_agente_aduanal` | `INTEGER` | No | Sí | No | *Ninguno* | `REFERENCES aduana.agente_aduanal(id_agente_aduanal) ON DELETE RESTRICT` | Auxiliar aduanero que refrenda el trámite. |
| `id_contenedor` | `INTEGER` | No | Sí | No | *Ninguno* | `REFERENCES aduana.contenedor(id_contenedor) ON DELETE RESTRICT` | Contenedor principal asociado al DUA. |
| `numero_dua` | `VARCHAR(20)` | No | No | No | *Ninguno* | `UNIQUE`, `CHECK (numero_dua ~ '^DUA-2026-[0-9]{4}$')` | Identificador didáctico en formato `DUA-2026-XXXX`. |
| `regimen` | `VARCHAR(25)` | No | No | No | *Ninguno* | `CHECK (regimen IN ('Importacion', 'Exportacion', 'Transito', 'Deposito'))` | Régimen aduanero solicitado. |
| `estado` | `VARCHAR(25)` | No | No | No | *Ninguno* | `CHECK (estado IN ('Retenida', 'Liberada', 'En Inspeccion'))` | Estado de control aduanero del DUA. |
| `fecha_declaracion` | `DATE` | No | No | No | *Ninguno* | *Ninguno* | Fecha de registro (utilizada en consulta 1). |
| `fecha_ingreso_recinto` | `TIMESTAMPTZ` | No | No | No | *Ninguno* | *Ninguno* | Momento exacto de arribo al recinto para cálculo de permanencia. |
| `moneda` | `VARCHAR(3)` | No | No | No | `'USD'` | `CHECK (moneda = 'USD')` | Moneda de liquidación uniforme para evitar sesgos de tipo de cambio. |

---

### 9. `aduana.detalle_declaracion`
Líneas de mercancía declaradas en cada DUA. Resuelve la relación N:M entre `declaracion_aduanera` y `producto`. El valor total declarado no se almacena como total redundante en la cabecera, sino que se liquida como `SUM(cantidad * valor_unitario)`.

| Columna | Tipo PostgreSQL | PK | FK | Nulable | Valor por Defecto | Restricciones / Reglas | Descripción Funcional |
| :--- | :--- | :---: | :---: | :---: | :--- | :--- | :--- |
| `id_declaracion` | `INTEGER` | Sí | Sí | No | *Ninguno* | `REFERENCES aduana.declaracion_aduanera(id_declaracion) ON DELETE RESTRICT` | Declaración a la que pertenece la línea. |
| `numero_linea` | `INTEGER` | Sí | No | No | *Ninguno* | `CHECK (numero_linea > 0)` | Número secuencial de línea (1, 2, 3...) dentro del DUA. |
| `id_producto` | `INTEGER` | No | Sí | No | *Ninguno* | `REFERENCES aduana.producto(id_producto) ON DELETE RESTRICT` | Producto importado. Puede repetirse en diferentes líneas. |
| `cantidad` | `NUMERIC(12,2)` | No | No | No | *Ninguno* | `CHECK (cantidad > 0)` | Cantidad declarada (estrictamente positiva). |
| `unidad_medida` | `VARCHAR(20)` | No | No | No | *Ninguno* | `CHECK (unidad_medida IN ('unidades', 'kilogramos', 'litros', 'cajas'))` | Unidad de medida declarada. |
| `valor_unitario` | `NUMERIC(14,2)` | No | No | No | *Ninguno* | `CHECK (valor_unitario >= 0)` | Precio aduanero unitario en USD. |
| `tasa_arancelaria_porc` | `NUMERIC(5,2)` | No | No | No | *Ninguno* | `CHECK (tasa_arancelaria_porc >= 0 AND tasa_arancelaria_porc <= 100)` | Tasa arancelaria específica aplicada a la línea. |
| `descripcion_arancelaria` | `TEXT` | No | No | No | *Ninguno* | `CHECK (trim(descripcion_arancelaria) <> '')` | Glosa descriptiva de la mercancía amparada en la línea. |

*Nota de Llave Primaria Compuesta:* `PRIMARY KEY (id_declaracion, numero_linea)`.

---

### 10. `aduana.bodega`
Instalaciones y recintos de almacenamiento aduanero bajo jurisdicción fiscal.

| Columna | Tipo PostgreSQL | PK | FK | Nulable | Valor por Defecto | Restricciones / Reglas | Descripción Funcional |
| :--- | :--- | :---: | :---: | :---: | :--- | :--- | :--- |
| `id_bodega` | `INTEGER` | Sí | No | No | `GENERATED ALWAYS AS IDENTITY` | Llave primaria | Identificador único de la bodega. |
| `codigo_bodega` | `VARCHAR(15)` | No | No | No | *Ninguno* | `UNIQUE`, `CHECK (trim(codigo_bodega) <> '')` | Código de recinto (ej. 'BOD-FISCAL-01'). |
| `nombre` | `VARCHAR(100)` | No | No | No | *Ninguno* | `CHECK (trim(nombre) <> '')` | Nombre de la instalación. |
| `tipo_bodega` | `VARCHAR(30)` | No | No | No | *Ninguno* | `CHECK (tipo_bodega IN ('Fiscal', 'Refrigerada', 'General', 'Mercancias Peligrosas'))` | Naturaleza operativa de la bodega. |
| `ubicacion_recinto` | `VARCHAR(150)` | No | No | No | *Ninguno* | *Ninguno* | Ubicación física dentro del puerto o aduana. |
| `capacidad_volumen_m3` | `NUMERIC(10,2)` | No | No | No | *Ninguno* | `CHECK (capacidad_volumen_m3 > 0)` | Volumen máximo útil en $m^3$. |
| `activo` | `BOOLEAN` | No | No | No | `TRUE` | *Ninguno* | Estado de operación de la bodega. |

---

### 11. `aduana.inventario_bodega`
Existencias físicas almacenadas con **trazabilidad granular hacia la línea exacta del DUA** (`id_declaracion, numero_linea`) y la bodega. Permite saber si el stock custodiado pertenece a una declaración retenida o liberada.

| Columna | Tipo PostgreSQL | PK | FK | Nulable | Valor por Defecto | Restricciones / Reglas | Descripción Funcional |
| :--- | :--- | :---: | :---: | :---: | :--- | :--- | :--- |
| `id_inventario` | `INTEGER` | Sí | No | No | `GENERATED ALWAYS AS IDENTITY` | Llave primaria | Identificador del registro de inventario. |
| `id_bodega` | `INTEGER` | No | Sí | No | *Ninguno* | `REFERENCES aduana.bodega(id_bodega) ON DELETE RESTRICT` | Bodega física donde está depositada la carga. |
| `id_declaracion` | `INTEGER` | No | Sí | No | *Ninguno* | Llave foránea compuesta | Parte 1 de FK a `detalle_declaracion`. |
| `numero_linea` | `INTEGER` | No | Sí | No | *Ninguno* | Llave foránea compuesta | Parte 2 de FK a `detalle_declaracion`. |
| `id_producto` | `INTEGER` | No | Sí | No | *Ninguno* | `REFERENCES aduana.producto(id_producto) ON DELETE RESTRICT` | Producto amparado (para simplificar uniones analíticas). |
| `ubicacion_estante` | `VARCHAR(30)` | No | No | No | *Ninguno* | `CHECK (trim(ubicacion_estante) <> '')` | Posición física en estantería (ej. 'EST-A1-N2'). |
| `cantidad_almacenada` | `NUMERIC(12,2)` | No | No | No | *Ninguno* | `CHECK (cantidad_almacenada >= 0)` | Existencia física disponible (no negativa). |
| `unidad_medida` | `VARCHAR(20)` | No | No | No | *Ninguno* | `CHECK (unidad_medida IN ('unidades', 'kilogramos', 'litros', 'cajas'))` | Unidad de la cantidad física almacenada. |
| `fecha_ingreso` | `TIMESTAMPTZ` | No | No | No | `CURRENT_TIMESTAMP` | *Ninguno* | Momento de ingreso a la bodega. |
| `fecha_salida` | `TIMESTAMPTZ` | No | No | Sí | `NULL` | `CHECK (fecha_salida IS NULL OR fecha_salida >= fecha_ingreso)` | Momento de despacho (salida no anterior al ingreso). |

*Restricciones Clave:*
- `FOREIGN KEY (id_declaracion, numero_linea) REFERENCES aduana.detalle_declaracion(id_declaracion, numero_linea) ON DELETE RESTRICT`
- `UNIQUE (id_bodega, id_declaracion, numero_linea)`: Garantiza que una misma línea declarada no tenga duplicados dentro de una misma bodega física.

---

### 12. `aduana.funcionario`
Cuerpo de inspectores y jefaturas de la administración aduanera. Implementa una **relación reflexiva/recursiva** (`id_supervisor`) para modelar la jerarquía institucional.

| Columna | Tipo PostgreSQL | PK | FK | Nulable | Valor por Defecto | Restricciones / Reglas | Descripción Funcional |
| :--- | :--- | :---: | :---: | :---: | :--- | :--- | :--- |
| `id_funcionario` | `INTEGER` | Sí | No | No | `GENERATED ALWAYS AS IDENTITY` | Llave primaria | Identificador único del funcionario. |
| `id_supervisor` | `INTEGER` | No | Sí | Sí | `NULL` | `REFERENCES aduana.funcionario(id_funcionario) ON DELETE SET NULL` | Identificador de su jefatura directa (NULL para la jefatura superior). |
| `numero_empleado` | `VARCHAR(20)` | No | No | No | *Ninguno* | `UNIQUE`, `CHECK (trim(numero_empleado) <> '')` | Matrícula o código de empleado público. |
| `nombre_completo` | `VARCHAR(150)` | No | No | No | *Ninguno* | `CHECK (trim(nombre_completo) <> '')` | Nombre y apellidos del funcionario. |
| `puesto_cargo` | `VARCHAR(100)` | No | No | No | *Ninguno* | `CHECK (trim(puesto_cargo) <> '')` | Denominación del puesto oficial. |
| `area_adscripcion` | `VARCHAR(100)` | No | No | No | *Ninguno* | `CHECK (trim(area_adscripcion) <> '')` | Departamento o división aduanera. |
| `correo_institucional` | `VARCHAR(100)` | No | No | No | *Ninguno* | `UNIQUE`, `CHECK (position('@' IN correo_institucional) > 1)` | Correo oficial asignado. |
| `activo` | `BOOLEAN` | No | No | No | `TRUE` | *Ninguno* | Estado laboral del funcionario. |

*Restricción de Integridad Jerárquica:*
- `CHECK (id_supervisor IS NULL OR id_supervisor <> id_funcionario)`: Impide la autosupervisión inmediata directa.

---

### 13. `aduana.inspeccion`
Diligencias y actas de reconocimiento físico, aforo documental o inspección no intrusiva efectuadas por funcionarios aduaneros sobre las declaraciones.

| Columna | Tipo PostgreSQL | PK | FK | Nulable | Valor por Defecto | Restricciones / Reglas | Descripción Funcional |
| :--- | :--- | :---: | :---: | :---: | :--- | :--- | :--- |
| `id_inspeccion` | `INTEGER` | Sí | No | No | `GENERATED ALWAYS AS IDENTITY` | Llave primaria | Identificador único de la inspección. |
| `id_declaracion` | `INTEGER` | No | Sí | No | *Ninguno* | `REFERENCES aduana.declaracion_aduanera(id_declaracion) ON DELETE RESTRICT` | DUA sometido a proceso de aforo. |
| `id_funcionario` | `INTEGER` | No | Sí | No | *Ninguno* | `REFERENCES aduana.funcionario(id_funcionario) ON DELETE RESTRICT` | Inspector responsable que firma el acta. |
| `numero_acta` | `VARCHAR(30)` | No | No | No | *Ninguno* | `UNIQUE`, `CHECK (trim(numero_acta) <> '')` | Código oficial del acta de inspección. |
| `tipo_inspeccion` | `VARCHAR(25)` | No | No | No | *Ninguno* | `CHECK (tipo_inspeccion IN ('Fisica', 'Documental', 'Escaner No Intrusivo'))` | Modalidad de aforo efectuada. |
| `fecha_inspeccion` | `TIMESTAMPTZ` | No | No | No | `CURRENT_TIMESTAMP` | *Ninguno* | Momento del acto de inspección. |
| `resultado` | `VARCHAR(25)` | No | No | No | *Ninguno* | `CHECK (resultado IN ('Conforme', 'Discrepancia Arancelaria', 'Retencion Preventiva', 'Comiso'))` | Dictamen final del aforo. |
| `observaciones` | `TEXT` | No | No | No | *Ninguno* | `CHECK (trim(observaciones) <> '')` | Hallazgos detallados de la inspección (consulta 5). |
| `dictamen_firmado` | `BOOLEAN` | No | No | No | `TRUE` | *Ninguno* | Validez formal del acta de aforo. |
