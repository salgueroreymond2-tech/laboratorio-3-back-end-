-- ============================================================================
-- PROYECTO: Laboratorio #3 - Sistema de Inventario para una Aduana
-- AUTOR: Reymond Salguero
-- FECHA: Octubre de 2026
-- PLATAFORMA: Supabase | MOTOR: PostgreSQL 18
-- ARCHIVO: 04_validaciones.sql
-- DESCRIPCIÓN: Consultas de auditoría de integridad, conteo de filas, detección
--              de huérfanos/duplicados, balance de existencias y pruebas
--              negativas de restricciones mediante bloques DO protegidos.
-- ============================================================================

SET search_path TO aduana, public;

-- ----------------------------------------------------------------------------
-- 1. CONTEO DE FILAS POR TABLA (Comprobación de mínimo 15 filas)
-- ----------------------------------------------------------------------------
SELECT 'aduana.pais' AS tabla, COUNT(*) AS total_filas, CASE WHEN COUNT(*) >= 15 THEN 'CUMPLE (>=15)' ELSE 'FALLA' END AS estado_requisito FROM aduana.pais
UNION ALL
SELECT 'aduana.importador', COUNT(*), CASE WHEN COUNT(*) >= 15 THEN 'CUMPLE (>=15)' ELSE 'FALLA' END FROM aduana.importador
UNION ALL
SELECT 'aduana.agente_aduanal', COUNT(*), CASE WHEN COUNT(*) >= 15 THEN 'CUMPLE (>=15)' ELSE 'FALLA' END FROM aduana.agente_aduanal
UNION ALL
SELECT 'aduana.categoria_arancelaria', COUNT(*), CASE WHEN COUNT(*) >= 15 THEN 'CUMPLE (>=15)' ELSE 'FALLA' END FROM aduana.categoria_arancelaria
UNION ALL
SELECT 'aduana.producto', COUNT(*), CASE WHEN COUNT(*) >= 15 THEN 'CUMPLE (>=15)' ELSE 'FALLA' END FROM aduana.producto
UNION ALL
SELECT 'aduana.contenedor', COUNT(*), CASE WHEN COUNT(*) >= 15 THEN 'CUMPLE (>=15)' ELSE 'FALLA' END FROM aduana.contenedor
UNION ALL
SELECT 'aduana.ficha_contenedor', COUNT(*), CASE WHEN COUNT(*) >= 15 THEN 'CUMPLE (>=15)' ELSE 'FALLA' END FROM aduana.ficha_contenedor
UNION ALL
SELECT 'aduana.declaracion_aduanera', COUNT(*), CASE WHEN COUNT(*) >= 15 THEN 'CUMPLE (>=15)' ELSE 'FALLA' END FROM aduana.declaracion_aduanera
UNION ALL
SELECT 'aduana.detalle_declaracion', COUNT(*), CASE WHEN COUNT(*) >= 15 THEN 'CUMPLE (>=15)' ELSE 'FALLA' END FROM aduana.detalle_declaracion
UNION ALL
SELECT 'aduana.bodega', COUNT(*), CASE WHEN COUNT(*) >= 15 THEN 'CUMPLE (>=15)' ELSE 'FALLA' END FROM aduana.bodega
UNION ALL
SELECT 'aduana.inventario_bodega', COUNT(*), CASE WHEN COUNT(*) >= 15 THEN 'CUMPLE (>=15)' ELSE 'FALLA' END FROM aduana.inventario_bodega
UNION ALL
SELECT 'aduana.funcionario', COUNT(*), CASE WHEN COUNT(*) >= 15 THEN 'CUMPLE (>=15)' ELSE 'FALLA' END FROM aduana.funcionario
UNION ALL
SELECT 'aduana.inspeccion', COUNT(*), CASE WHEN COUNT(*) >= 15 THEN 'CUMPLE (>=15)' ELSE 'FALLA' END FROM aduana.inspeccion
ORDER BY tabla ASC;


-- ----------------------------------------------------------------------------
-- 2. DETECCIÓN DE REGISTROS HUÉRFANOS (Verificación de Integridad Referencial)
-- Todos los conteos deben resultar exactamente 0.
-- ----------------------------------------------------------------------------
SELECT 'Huerfanos en importador -> pais' AS prueba, COUNT(*) AS registros_invalidos
FROM aduana.importador imp LEFT JOIN aduana.pais p ON imp.id_pais = p.id_pais WHERE p.id_pais IS NULL
UNION ALL
SELECT 'Huerfanos en producto -> categoria', COUNT(*)
FROM aduana.producto pr LEFT JOIN aduana.categoria_arancelaria c ON pr.id_categoria = c.id_categoria WHERE c.id_categoria IS NULL
UNION ALL
SELECT 'Huerfanos en producto -> pais_origen', COUNT(*)
FROM aduana.producto pr LEFT JOIN aduana.pais p ON pr.id_pais_origen = p.id_pais WHERE p.id_pais IS NULL
UNION ALL
SELECT 'Huerfanos en contenedor -> pais_procedencia', COUNT(*)
FROM aduana.contenedor c LEFT JOIN aduana.pais p ON c.id_pais_procedencia = p.id_pais WHERE p.id_pais IS NULL
UNION ALL
SELECT 'Huerfanos en ficha_contenedor -> contenedor', COUNT(*)
FROM aduana.ficha_contenedor f LEFT JOIN aduana.contenedor c ON f.id_contenedor = c.id_contenedor WHERE c.id_contenedor IS NULL
UNION ALL
SELECT 'Huerfanos en declaracion -> importador', COUNT(*)
FROM aduana.declaracion_aduanera d LEFT JOIN aduana.importador i ON d.id_importador = i.id_importador WHERE i.id_importador IS NULL
UNION ALL
SELECT 'Huerfanos en declaracion -> agente_aduanal', COUNT(*)
FROM aduana.declaracion_aduanera d LEFT JOIN aduana.agente_aduanal a ON d.id_agente_aduanal = a.id_agente_aduanal WHERE a.id_agente_aduanal IS NULL
UNION ALL
SELECT 'Huerfanos en declaracion -> contenedor', COUNT(*)
FROM aduana.declaracion_aduanera d LEFT JOIN aduana.contenedor c ON d.id_contenedor = c.id_contenedor WHERE c.id_contenedor IS NULL
UNION ALL
SELECT 'Huerfanos en detalle_declaracion -> declaracion', COUNT(*)
FROM aduana.detalle_declaracion det LEFT JOIN aduana.declaracion_aduanera d ON det.id_declaracion = d.id_declaracion WHERE d.id_declaracion IS NULL
UNION ALL
SELECT 'Huerfanos en inventario_bodega -> detalle_declaracion', COUNT(*)
FROM aduana.inventario_bodega inv 
LEFT JOIN aduana.detalle_declaracion det ON inv.id_declaracion = det.id_declaracion AND inv.numero_linea = det.numero_linea 
WHERE det.id_declaracion IS NULL
UNION ALL
SELECT 'Huerfanos en funcionario -> supervisor (excluyendo raiz NULL)', COUNT(*)
FROM aduana.funcionario f LEFT JOIN aduana.funcionario sup ON f.id_supervisor = sup.id_funcionario 
WHERE f.id_supervisor IS NOT NULL AND sup.id_funcionario IS NULL
UNION ALL
SELECT 'Huerfanos en inspeccion -> declaracion', COUNT(*)
FROM aduana.inspeccion ins LEFT JOIN aduana.declaracion_aduanera d ON ins.id_declaracion = d.id_declaracion WHERE d.id_declaracion IS NULL
UNION ALL
SELECT 'Huerfanos en inspeccion -> funcionario', COUNT(*)
FROM aduana.inspeccion ins LEFT JOIN aduana.funcionario f ON ins.id_funcionario = f.id_funcionario WHERE f.id_funcionario IS NULL;


-- ----------------------------------------------------------------------------
-- 3. DETECCIÓN DE DUPLICADOS EN CAMPOS UNIQUE
-- Todos los conteos deben resultar exactamente 0.
-- ----------------------------------------------------------------------------
SELECT 'Duplicados en pais.codigo_iso_alfa2' AS verificacion, COUNT(*) - COUNT(DISTINCT codigo_iso_alfa2) AS repetidos FROM aduana.pais
UNION ALL
SELECT 'Duplicados en importador.identificacion_tributaria', COUNT(*) - COUNT(DISTINCT identificacion_tributaria) FROM aduana.importador
UNION ALL
SELECT 'Duplicados en agente_aduanal.numero_licencia', COUNT(*) - COUNT(DISTINCT numero_licencia) FROM aduana.agente_aduanal
UNION ALL
SELECT 'Duplicados en categoria_arancelaria.codigo_subpartida', COUNT(*) - COUNT(DISTINCT codigo_subpartida) FROM aduana.categoria_arancelaria
UNION ALL
SELECT 'Duplicados en producto.codigo_sku', COUNT(*) - COUNT(DISTINCT codigo_sku) FROM aduana.producto
UNION ALL
SELECT 'Duplicados en contenedor.numero_sigla', COUNT(*) - COUNT(DISTINCT numero_sigla) FROM aduana.contenedor
UNION ALL
SELECT 'Duplicados en ficha_contenedor.numero_marchamo_aduana', COUNT(*) - COUNT(DISTINCT numero_marchamo_aduana) FROM aduana.ficha_contenedor
UNION ALL
SELECT 'Duplicados en declaracion_aduanera.numero_dua', COUNT(*) - COUNT(DISTINCT numero_dua) FROM aduana.declaracion_aduanera
UNION ALL
SELECT 'Duplicados en bodega.codigo_bodega', COUNT(*) - COUNT(DISTINCT codigo_bodega) FROM aduana.bodega
UNION ALL
SELECT 'Duplicados en funcionario.numero_empleado', COUNT(*) - COUNT(DISTINCT numero_empleado) FROM aduana.funcionario
UNION ALL
SELECT 'Duplicados en funcionario.correo_institucional', COUNT(*) - COUNT(DISTINCT correo_institucional) FROM aduana.funcionario
UNION ALL
SELECT 'Duplicados en inspeccion.numero_acta', COUNT(*) - COUNT(DISTINCT numero_acta) FROM aduana.inspeccion;


-- ----------------------------------------------------------------------------
-- 4. VALIDACIÓN DE VALORES INVÁLIDOS Y RESTRICCIONES DE NEGOCIO
-- Todos los conteos deben resultar exactamente 0.
-- ----------------------------------------------------------------------------
SELECT 'Detalle con cantidad <= 0' AS prueba_dominio, COUNT(*) AS fallas
FROM aduana.detalle_declaracion WHERE cantidad <= 0.00
UNION ALL
SELECT 'Detalle con valor_unitario < 0', COUNT(*)
FROM aduana.detalle_declaracion WHERE valor_unitario < 0.00
UNION ALL
SELECT 'Inventario con cantidad_almacenada < 0', COUNT(*)
FROM aduana.inventario_bodega WHERE cantidad_almacenada < 0.00
UNION ALL
SELECT 'Inventario con fecha_salida anterior a fecha_ingreso', COUNT(*)
FROM aduana.inventario_bodega WHERE fecha_salida IS NOT NULL AND fecha_salida < fecha_ingreso
UNION ALL
SELECT 'Autosupervision en funcionario (id_supervisor = id_funcionario)', COUNT(*)
FROM aduana.funcionario WHERE id_supervisor IS NOT NULL AND id_supervisor = id_funcionario
UNION ALL
SELECT 'DUA con formato invalido (distinto de DUA-2026-XXXX)', COUNT(*)
FROM aduana.declaracion_aduanera WHERE numero_dua !~ '^DUA-2026-[0-9]{4}$'
UNION ALL
SELECT 'Inspecciones con observaciones vacias o en blanco', COUNT(*)
FROM aduana.inspeccion WHERE trim(observaciones) = '';


-- ----------------------------------------------------------------------------
-- 5. COMPROBACIÓN DE COHERENCIA DE EXISTENCIAS VS CANTIDADES DECLARADAS
-- Comprueba que la suma de existencias almacenadas para una línea de DUA
-- no supere la cantidad originalmente declarada en el detalle del DUA.
-- ----------------------------------------------------------------------------
SELECT 
    d.numero_dua,
    det.numero_linea,
    p.nombre_comercial,
    det.cantidad AS cantidad_declarada,
    COALESCE(SUM(inv.cantidad_almacenada), 0.00) AS total_en_bodegas,
    det.unidad_medida,
    CASE 
        WHEN COALESCE(SUM(inv.cantidad_almacenada), 0.00) <= det.cantidad THEN 'COHERENTE'
        ELSE 'DESAJUSTE: SOBREEXISTENCIA'
    END AS estado_balance
FROM aduana.detalle_declaracion det
INNER JOIN aduana.declaracion_aduanera d ON det.id_declaracion = d.id_declaracion
INNER JOIN aduana.producto p ON det.id_producto = p.id_producto
LEFT JOIN aduana.inventario_bodega inv 
    ON det.id_declaracion = inv.id_declaracion AND det.numero_linea = inv.numero_linea
GROUP BY d.numero_dua, det.numero_linea, p.nombre_comercial, det.cantidad, det.unidad_medida
ORDER BY d.numero_dua ASC, det.numero_linea ASC;


-- ----------------------------------------------------------------------------
-- 6. PRUEBAS NEGATIVAS DE RESTRICCIONES (BLOQUES TRANSACCIONALES PROTEGIDOS)
-- Se ejecutan intentos deliberados de violación de restricciones CHECK, FK y UNIQUE.
-- Cada prueba captura la excepción esperada y revierte los cambios, demostrando
-- que el esquema rechaza entradas anómalas sin corromper los datos existentes.
-- ----------------------------------------------------------------------------

DO $$
BEGIN
    -- Prueba Negativa 1: Intentar registrar un régimen aduanero no permitido
    BEGIN
        INSERT INTO aduana.declaracion_aduanera 
            (id_importador, id_agente_aduanal, id_contenedor, numero_dua, regimen, estado, fecha_declaracion, fecha_ingreso_recinto)
        VALUES 
            (1, 1, 1, 'DUA-2026-9999', 'RegimenInvalido', 'Liberada', CURRENT_DATE, CURRENT_TIMESTAMP);
        RAISE EXCEPTION 'Fallo de prueba: Se permitió un régimen aduanero inválido';
    EXCEPTION WHEN check_violation THEN
        RAISE NOTICE 'Prueba Negativa 1 SUPERADA: El motor rechazó correctamente el régimen inválido (check_declaracion_regimen).';
    END;

    -- Prueba Negativa 2: Intentar registrar autosupervisión directa en funcionario
    BEGIN
        INSERT INTO aduana.funcionario 
            (id_funcionario, id_supervisor, numero_empleado, nombre_completo, puesto_cargo, area_adscripcion, correo_institucional)
        VALUES 
            (999, 999, 'EMP-2026-999', 'Funcionario Auto-Supervisado', 'Inspector', 'Operativa', 'autosup@hacienda.go.cr');
        RAISE EXCEPTION 'Fallo de prueba: Se permitió la autosupervisión';
    EXCEPTION WHEN check_violation THEN
        RAISE NOTICE 'Prueba Negativa 2 SUPERADA: El motor rechazó correctamente la autosupervisión (check_no_autosupervision).';
    END;

    -- Prueba Negativa 3: Intentar registrar cantidad menor o igual a cero en detalle_declaracion
    BEGIN
        INSERT INTO aduana.detalle_declaracion 
            (id_declaracion, numero_linea, id_producto, cantidad, unidad_medida, valor_unitario, tasa_arancelaria_porc, descripcion_arancelaria)
        VALUES 
            (1, 99, 1, 0.00, 'unidades', 500.00, 0.00, 'Línea con cantidad inválida');
        RAISE EXCEPTION 'Fallo de prueba: Se permitió cantidad <= 0 en detalle';
    EXCEPTION WHEN check_violation THEN
        RAISE NOTICE 'Prueba Negativa 3 SUPERADA: El motor rechazó correctamente la cantidad cero/negativa (check_detalle_cantidad_pos).';
    END;

    -- Prueba Negativa 4: Intentar registrar una declaración asociada a un importador inexistente (FK)
    BEGIN
        INSERT INTO aduana.declaracion_aduanera 
            (id_importador, id_agente_aduanal, id_contenedor, numero_dua, regimen, estado, fecha_declaracion, fecha_ingreso_recinto)
        VALUES 
            (999999, 1, 1, 'DUA-2026-9998', 'Importacion', 'Liberada', CURRENT_DATE, CURRENT_TIMESTAMP);
        RAISE EXCEPTION 'Fallo de prueba: Se permitió una FK huérfana de importador';
    EXCEPTION WHEN foreign_key_violation THEN
        RAISE NOTICE 'Prueba Negativa 4 SUPERADA: El motor rechazó correctamente la referencia a importador inexistente (fk_declaracion_importador).';
    END;

    -- Prueba Negativa 5: Intentar duplicar un marchamo de aduana en ficha_contenedor (UNIQUE)
    BEGIN
        INSERT INTO aduana.ficha_contenedor 
            (id_contenedor, numero_marchamo_aduana, observacion_inspeccion_fisica)
        VALUES 
            (15, 'MARCH-CR-2026-0001', 'Intento de duplicación de marchamo ya asignado al contenedor 1');
        RAISE EXCEPTION 'Fallo de prueba: Se permitió marchamo aduanero duplicado';
    EXCEPTION WHEN unique_violation THEN
        RAISE NOTICE 'Prueba Negativa 5 SUPERADA: El motor rechazó correctamente el marchamo duplicado (uq_ficha_marchamo).';
    END;

    RAISE NOTICE 'Todas las pruebas negativas de restricciones han sido evaluadas satisfactoriamente.';
END $$;
