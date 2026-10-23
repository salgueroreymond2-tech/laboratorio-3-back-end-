-- ============================================================================
-- PROYECTO: Laboratorio #3 - Sistema de Inventario para una Aduana
-- AUTOR: Reymond Salguero
-- FECHA: Octubre de 2026
-- PLATAFORMA: Supabase | MOTOR: PostgreSQL 18
-- ARCHIVO: 03_consultas.sql
-- DESCRIPCIÓN: Ocho consultas analíticas de negocio en dialecto PostgreSQL.
--              Implementan JOIN, WHERE, GROUP BY, HAVING, ORDER BY, agregados,
--              CTE y funciones de ventana (DENSE_RANK) preservando empates.
-- ============================================================================

SET search_path TO aduana, public;

-- ----------------------------------------------------------------------------
-- CONSULTA 1: Declaraciones de importación en octubre de 2026
-- PREGUNTA: ¿Cuáles son las declaraciones bajo régimen de importación registradas
--           durante el mes de octubre de 2026, indicando su importador y agente?
-- RANGO TEMPORAL: Intervalo semiabierto [2026-10-01, 2026-11-01)
-- COLUMNAS: numero_dua, fecha_declaracion, razon_social, agente_aduanal,
--           regimen, estado, moneda.
-- ----------------------------------------------------------------------------
SELECT 
    d.numero_dua,
    d.fecha_declaracion,
    imp.razon_social AS importador,
    age.nombre_completo AS agente_aduanal,
    d.regimen,
    d.estado AS estado_operativo,
    d.moneda
FROM aduana.declaracion_aduanera d
INNER JOIN aduana.importador imp ON d.id_importador = imp.id_importador
INNER JOIN aduana.agente_aduanal age ON d.id_agente_aduanal = age.id_agente_aduanal
WHERE d.regimen = 'Importacion'
  AND d.fecha_declaracion >= DATE '2026-10-01'
  AND d.fecha_declaracion < DATE '2026-11-01'
ORDER BY d.fecha_declaracion ASC, d.numero_dua ASC;


-- ----------------------------------------------------------------------------
-- CONSULTA 2: Mercancías con origen China, declaración retenida y stock en bodega
-- PREGUNTA: ¿Qué mercancías fabricadas en China están asociadas a declaraciones
--           retenidas y cuentan con existencias físicas positivas en bodega?
-- CRITERIO CLAVE: Se utiliza producto.id_pais_origen (origen de manufactura),
--                 declaracion.estado = 'Retenida' e inventario_bodega > 0 activo.
-- COLUMNAS: numero_dua, estado_declaracion, producto, sku, pais_origen,
--           cantidad_almacenada, unidad_medida, bodega, ubicacion_estante.
-- ----------------------------------------------------------------------------
SELECT 
    d.numero_dua,
    d.estado AS estado_declaracion,
    p.nombre_comercial AS producto,
    p.codigo_sku AS sku,
    porigen.nombre AS pais_origen_mercancia,
    ib.cantidad_almacenada,
    ib.unidad_medida,
    b.nombre AS nombre_bodega,
    ib.ubicacion_estante
FROM aduana.inventario_bodega ib
INNER JOIN aduana.declaracion_aduanera d ON ib.id_declaracion = d.id_declaracion
INNER JOIN aduana.producto p ON ib.id_producto = p.id_producto
INNER JOIN aduana.pais porigen ON p.id_pais_origen = porigen.id_pais
INNER JOIN aduana.bodega b ON ib.id_bodega = b.id_bodega
WHERE porigen.nombre = 'China'
  AND d.estado = 'Retenida'
  AND ib.cantidad_almacenada > 0.00
  AND ib.fecha_salida IS NULL
ORDER BY d.numero_dua ASC, p.nombre_comercial ASC;


-- ----------------------------------------------------------------------------
-- CONSULTA 3: País o países con mayor número de contenedores (procedencia)
-- PREGUNTA: ¿Cuál es el país o países de procedencia con el mayor número de
--           contenedores arribados, preservando empates en la primera posición?
-- CRITERIO CLAVE: contenedor.id_pais_procedencia. Se emplea CTE y DENSE_RANK()
--                 para no descartar países empatados en el primer lugar.
-- COLUMNAS: ranking_posicion, pais_procedencia, codigo_iso_alfa2, total_contenedores.
-- ----------------------------------------------------------------------------
WITH conteo_contenedores AS (
    SELECT 
        p.id_pais,
        p.codigo_iso_alfa2,
        p.nombre AS pais_procedencia,
        COUNT(c.id_contenedor) AS total_contenedores,
        DENSE_RANK() OVER (ORDER BY COUNT(c.id_contenedor) DESC) AS ranking_posicion
    FROM aduana.pais p
    INNER JOIN aduana.contenedor c ON p.id_pais = c.id_pais_procedencia
    GROUP BY p.id_pais, p.codigo_iso_alfa2, p.nombre
)
SELECT 
    ranking_posicion,
    pais_procedencia,
    codigo_iso_alfa2,
    total_contenedores
FROM conteo_contenedores
WHERE ranking_posicion = 1
ORDER BY pais_procedencia ASC;


-- ----------------------------------------------------------------------------
-- CONSULTA 4: Importador o importadores con mayor valor total declarado
-- PREGUNTA: ¿Cuál es el importador (o importadores en empate) con mayor valor
--           económico declarado, calculado de forma agregada y consistente?
-- CRITERIO CLAVE: SUM(detalle.cantidad * detalle.valor_unitario) en USD.
--                 DENSE_RANK() garantiza la inclusión íntegra de empates.
-- COLUMNAS: ranking_valor, identificacion_tributaria, razon_social,
--           pais_importador, total_valor_declarado_usd, total_declaraciones.
-- ----------------------------------------------------------------------------
WITH valor_declarado_importadores AS (
    SELECT 
        imp.id_importador,
        imp.identificacion_tributaria,
        imp.razon_social,
        p.nombre AS pais_importador,
        SUM(det.cantidad * det.valor_unitario) AS total_valor_declarado_usd,
        COUNT(DISTINCT d.id_declaracion) AS total_declaraciones_tramitadas,
        DENSE_RANK() OVER (ORDER BY SUM(det.cantidad * det.valor_unitario) DESC) AS ranking_valor
    FROM aduana.importador imp
    INNER JOIN aduana.pais p ON imp.id_pais = p.id_pais
    INNER JOIN aduana.declaracion_aduanera d ON imp.id_importador = d.id_importador
    INNER JOIN aduana.detalle_declaracion det ON d.id_declaracion = det.id_declaracion
    GROUP BY imp.id_importador, imp.identificacion_tributaria, imp.razon_social, p.nombre
)
SELECT 
    ranking_valor,
    identificacion_tributaria,
    razon_social,
    pais_importador,
    total_valor_declarado_usd,
    total_declaraciones_tramitadas
FROM valor_declarado_importadores
WHERE ranking_valor = 1
ORDER BY razon_social ASC;


-- ----------------------------------------------------------------------------
-- CONSULTA 5: Inspecciones con observaciones no vacías y funcionario responsable
-- PREGUNTA: ¿Cuáles inspecciones aduaneras poseen observaciones técnicas registradas
--           y cuál es el funcionario responsable que firmó el dictamen?
-- CRITERIO CLAVE: TRIM(inspeccion.observaciones) <> '' y enlace a aduana.funcionario.
-- COLUMNAS: numero_acta, numero_dua, fecha_inspeccion, tipo_inspeccion,
--           resultado, funcionario_responsable, puesto_cargo, observaciones.
-- ----------------------------------------------------------------------------
SELECT 
    insp.numero_acta,
    d.numero_dua,
    insp.fecha_inspeccion,
    insp.tipo_inspeccion,
    insp.resultado,
    f.nombre_completo AS funcionario_responsable,
    f.puesto_cargo,
    f.area_adscripcion,
    insp.observaciones
FROM aduana.inspeccion insp
INNER JOIN aduana.funcionario f ON insp.id_funcionario = f.id_funcionario
INNER JOIN aduana.declaracion_aduanera d ON insp.id_declaracion = d.id_declaracion
WHERE trim(insp.observaciones) <> ''
ORDER BY insp.fecha_inspeccion DESC;


-- ----------------------------------------------------------------------------
-- CONSULTA 6: Existencias por bodega, producto y unidad de medida
-- PREGUNTA: ¿Cuál es el stock consolidado almacenado por cada bodega y producto,
--           agrupando estrictamente por unidad de medida para no mezclar magnitudes?
-- CRITERIO CLAVE: Group by (bodega, producto, unidad_medida), filtrando stock > 0.
-- COLUMNAS: nombre_bodega, codigo_bodega, nombre_comercial, codigo_sku,
--           total_existencia, unidad_medida, posiciones_estante_ocupadas.
-- ----------------------------------------------------------------------------
SELECT 
    b.nombre AS nombre_bodega,
    b.codigo_bodega,
    p.nombre_comercial AS producto,
    p.codigo_sku AS sku,
    SUM(ib.cantidad_almacenada) AS total_existencia,
    ib.unidad_medida,
    COUNT(ib.id_inventario) AS posiciones_estante_ocupadas
FROM aduana.inventario_bodega ib
INNER JOIN aduana.bodega b ON ib.id_bodega = b.id_bodega
INNER JOIN aduana.producto p ON ib.id_producto = p.id_producto
WHERE ib.cantidad_almacenada > 0.00
  AND ib.fecha_salida IS NULL
GROUP BY b.id_bodega, b.nombre, b.codigo_bodega, p.id_producto, p.nombre_comercial, p.codigo_sku, ib.unidad_medida
ORDER BY b.nombre ASC, p.nombre_comercial ASC, ib.unidad_medida ASC;


-- ----------------------------------------------------------------------------
-- CONSULTA 7: Importadores que superan un umbral explícito de valor total
-- PREGUNTA: ¿Cuáles importadores acumulan un valor total declarado superior a
--           $100,000.00 USD en sus operaciones aduaneras?
-- CRITERIO CLAVE: GROUP BY con cláusula HAVING SUM(cantidad * valor_unitario) > 100000.00.
-- COLUMNAS: identificacion_tributaria, razon_social, cantidad_declaraciones,
--           valor_total_acumulado_usd.
-- ----------------------------------------------------------------------------
SELECT 
    imp.identificacion_tributaria,
    imp.razon_social,
    COUNT(DISTINCT d.id_declaracion) AS cantidad_declaraciones,
    SUM(det.cantidad * det.valor_unitario) AS valor_total_acumulado_usd
FROM aduana.importador imp
INNER JOIN aduana.declaracion_aduanera d ON imp.id_importador = d.id_importador
INNER JOIN aduana.detalle_declaracion det ON d.id_declaracion = det.id_declaracion
GROUP BY imp.id_importador, imp.identificacion_tributaria, imp.razon_social
HAVING SUM(det.cantidad * det.valor_unitario) > 100000.00
ORDER BY valor_total_acumulado_usd DESC;


-- ----------------------------------------------------------------------------
-- CONSULTA 8: Declaraciones con más tiempo de permanencia y mercancía aún almacenada
-- PREGUNTA: ¿Cuáles son las declaraciones aduaneras con mayor tiempo de estadía en
--           el recinto aduanero a la fecha de corte fija de octubre de 2026,
--           conservando aún existencias físicas almacenadas en bodega?
-- CRITERIO CLAVE: Fecha de corte fija TIMESTAMPTZ '2026-10-31 23:59:59-06',
--                 mercancía activa en inventario (cantidad > 0 y fecha_salida IS NULL),
--                 cálculo de días exactos mediante EXTRACT(EPOCH...).
-- COLUMNAS: numero_dua, regimen, estado_declaracion, importador,
--           fecha_ingreso_recinto, fecha_corte_evaluacion, dias_permanencia,
--           cantidad_total_almacenada.
-- ----------------------------------------------------------------------------
WITH stock_activo_por_dua AS (
    SELECT 
        id_declaracion,
        SUM(cantidad_almacenada) AS cantidad_total_almacenada,
        COUNT(DISTINCT id_bodega) AS bodegas_involucradas
    FROM aduana.inventario_bodega
    WHERE cantidad_almacenada > 0.00 
      AND fecha_salida IS NULL
    GROUP BY id_declaracion
)
SELECT 
    d.numero_dua,
    d.regimen,
    d.estado AS estado_declaracion,
    imp.razon_social AS importador,
    d.fecha_ingreso_recinto,
    TIMESTAMPTZ '2026-10-31 23:59:59-06' AS fecha_corte_evaluacion,
    ROUND(EXTRACT(EPOCH FROM (TIMESTAMPTZ '2026-10-31 23:59:59-06' - d.fecha_ingreso_recinto)) / 86400.0, 2) AS dias_permanencia_recinto,
    sa.cantidad_total_almacenada,
    sa.bodegas_involucradas
FROM aduana.declaracion_aduanera d
INNER JOIN stock_activo_por_dua sa ON d.id_declaracion = sa.id_declaracion
INNER JOIN aduana.importador imp ON d.id_importador = imp.id_importador
ORDER BY dias_permanencia_recinto DESC, d.numero_dua ASC;
