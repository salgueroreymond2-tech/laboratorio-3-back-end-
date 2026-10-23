-- ============================================================================
-- PROYECTO: Laboratorio #3 - Sistema de Inventario para una Aduana
-- AUTOR: Reymond Salguero
-- FECHA: Octubre de 2026
-- PLATAFORMA: Supabase | MOTOR: PostgreSQL 18
-- ARCHIVO: 00_reinicio_destructivo_opcional.sql
-- DESCRIPCIÓN: Script administrativo de limpieza opcional para reiniciar
--              el esquema aduana desde cero en el SQL Editor de Supabase.
-- ============================================================================
-- ADVERTENCIA CRÍTICA:
-- Este script es de uso EXCLUSIVAMENTE MANUAL Y ADMINISTRATIVO.
-- Borrará irreversiblemente todas las tablas, datos, restricciones e índices
-- del esquema 'aduana'. NUNCA debe ejecutarse de forma automática ni sobre
-- bases de datos de producción con datos reales no respaldados.
-- ============================================================================

-- Eliminar el esquema aduana y todos sus objetos dependientes (CASCADE)
DROP SCHEMA IF EXISTS aduana CASCADE;

-- Confirmación visual en el editor SQL
DO $$
BEGIN
    RAISE NOTICE 'El esquema aduana ha sido eliminado exitosamente. Puede proceder con 01_estructura.sql.';
END $$;
