-- ============================================================================
-- PROYECTO: Laboratorio #3 - Sistema de Inventario para una Aduana
-- AUTOR: Reymond Salguero
-- FECHA: Octubre de 2026
-- PLATAFORMA: Supabase | MOTOR: PostgreSQL 18
-- ARCHIVO: 05_seguridad_n8n.sql
-- DESCRIPCIÓN: Script administrativo para configurar el principio de mínimo
--              privilegio del agente n8n en el SQL Editor de Supabase.
--              Crea el rol agente_n8n_readonly, restringe permisos, habilita RLS,
--              aplica defensas en profundidad (timeout y solo lectura) y
--              valida permisos de lectura y rechazo de escritura.
-- ============================================================================

-- ============================================================================
-- 1. CREACIÓN DEL ROL DE LECTURA (LOGIN SIN PRIVILEGIOS ADMINISTRATIVOS)
-- ============================================================================
-- NOTA IMPORTANTE: Reemplace '<CONTRASENA_SEGURA_CONFIGURABLE>' por una
-- contraseña segura en su entorno real antes de ejecutar en SQL Editor.
DO $$
BEGIN
    IF NOT EXISTS (SELECT FROM pg_roles WHERE rolname = 'agente_n8n_readonly') THEN
        CREATE ROLE agente_n8n_readonly WITH 
            LOGIN 
            PASSWORD '<CONTRASENA_SEGURA_CONFIGURABLE>'
            NOSUPERUSER 
            NOCREATEDB 
            NOCREATEROLE 
            NOINHERIT 
            NOREPLICATION 
            NOBYPASSRLS;
        RAISE NOTICE 'Rol agente_n8n_readonly creado exitosamente.';
    ELSE
        -- Si ya existe, se asegura de revocar cualquier capacidad administrativa
        ALTER ROLE agente_n8n_readonly WITH 
            NOSUPERUSER 
            NOCREATEDB 
            NOCREATEROLE 
            NOINHERIT 
            NOREPLICATION 
            NOBYPASSRLS;
        RAISE NOTICE 'Rol agente_n8n_readonly existente verificado y saneado.';
    END IF;
END $$;

-- ============================================================================
-- 2. ASIGNACIÓN ESTRICTA DE PRIVILEGIOS SQL (MÍNIMO PRIVILEGIO)
-- ============================================================================
-- Permitir conexión a la base de datos operativa 'postgres'
GRANT CONNECT ON DATABASE postgres TO agente_n8n_readonly;

-- Permitir resolución de nombres y acceso al esquema aduana (USAGE únicamente)
GRANT USAGE ON SCHEMA aduana TO agente_n8n_readonly;

-- Revocar cualquier permiso residual público en el esquema aduana
REVOKE ALL ON SCHEMA aduana FROM PUBLIC;
REVOKE ALL ON ALL TABLES IN SCHEMA aduana FROM PUBLIC;

-- Conceder SELECT exclusivamente sobre las tablas del esquema aduana
GRANT SELECT ON ALL TABLES IN SCHEMA aduana TO agente_n8n_readonly;

-- No conceder escritura (INSERT, UPDATE, DELETE, TRUNCATE), ni DDL (CREATE), ni secuencias.

-- ============================================================================
-- 3. PRIVILEGIOS POR DEFECTO PARA FUTURAS TABLAS (ALTER DEFAULT PRIVILEGES)
-- ============================================================================
-- En Supabase, las tablas creadas desde el SQL Editor o migraciones pertenecen
-- habitualmente al rol 'postgres'. Esta instrucción garantiza que cualquier tabla
-- futura creada bajo ese propietario herede automáticamente solo permisos SELECT.
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA aduana
    GRANT SELECT ON TABLES TO agente_n8n_readonly;

-- ============================================================================
-- 4. SEGURIDAD A NIVEL DE FILA (ROW LEVEL SECURITY - RLS)
-- ============================================================================
-- Habilitar RLS en todas las tablas del esquema aduana
ALTER TABLE aduana.pais ENABLE ROW LEVEL SECURITY;
ALTER TABLE aduana.importador ENABLE ROW LEVEL SECURITY;
ALTER TABLE aduana.agente_aduanal ENABLE ROW LEVEL SECURITY;
ALTER TABLE aduana.categoria_arancelaria ENABLE ROW LEVEL SECURITY;
ALTER TABLE aduana.producto ENABLE ROW LEVEL SECURITY;
ALTER TABLE aduana.contenedor ENABLE ROW LEVEL SECURITY;
ALTER TABLE aduana.ficha_contenedor ENABLE ROW LEVEL SECURITY;
ALTER TABLE aduana.declaracion_aduanera ENABLE ROW LEVEL SECURITY;
ALTER TABLE aduana.detalle_declaracion ENABLE ROW LEVEL SECURITY;
ALTER TABLE aduana.bodega ENABLE ROW LEVEL SECURITY;
ALTER TABLE aduana.inventario_bodega ENABLE ROW LEVEL SECURITY;
ALTER TABLE aduana.funcionario ENABLE ROW LEVEL SECURITY;
ALTER TABLE aduana.inspeccion ENABLE ROW LEVEL SECURITY;

-- Forzar RLS para garantizar que ninguna sesión no-superuser omita las políticas
ALTER TABLE aduana.pais FORCE ROW LEVEL SECURITY;
ALTER TABLE aduana.importador FORCE ROW LEVEL SECURITY;
ALTER TABLE aduana.agente_aduanal FORCE ROW LEVEL SECURITY;
ALTER TABLE aduana.categoria_arancelaria FORCE ROW LEVEL SECURITY;
ALTER TABLE aduana.producto FORCE ROW LEVEL SECURITY;
ALTER TABLE aduana.contenedor FORCE ROW LEVEL SECURITY;
ALTER TABLE aduana.ficha_contenedor FORCE ROW LEVEL SECURITY;
ALTER TABLE aduana.declaracion_aduanera FORCE ROW LEVEL SECURITY;
ALTER TABLE aduana.detalle_declaracion FORCE ROW LEVEL SECURITY;
ALTER TABLE aduana.bodega FORCE ROW LEVEL SECURITY;
ALTER TABLE aduana.inventario_bodega FORCE ROW LEVEL SECURITY;
ALTER TABLE aduana.funcionario FORCE ROW LEVEL SECURITY;
ALTER TABLE aduana.inspeccion FORCE ROW LEVEL SECURITY;

-- Crear políticas SELECT explícitas para el rol agente_n8n_readonly
-- (Alcance de consulta requerido por el agente aduanero)
DO $$
DECLARE
    tbl text;
    tablas text[] := ARRAY[
        'pais', 'importador', 'agente_aduanal', 'categoria_arancelaria', 
        'producto', 'contenedor', 'ficha_contenedor', 'declaracion_aduanera', 
        'detalle_declaracion', 'bodega', 'inventario_bodega', 'funcionario', 'inspeccion'
    ];
BEGIN
    FOREACH tbl IN ARRAY tablas LOOP
        EXECUTE format('DROP POLICY IF EXISTS p_select_agente ON aduana.%I', tbl);
        EXECUTE format('CREATE POLICY p_select_agente ON aduana.%I FOR SELECT TO agente_n8n_readonly USING (true)', tbl);
    END LOOP;
    RAISE NOTICE 'Políticas RLS SELECT aplicadas exitosamente para agente_n8n_readonly.';
END $$;

-- ============================================================================
-- 5. DEFENSAS EN PROFUNDIDAD COMPLEMENTARIAS
-- ============================================================================
-- Restringir timeout de consultas a 15 segundos para evitar denegación de servicio o bloqueos
ALTER ROLE agente_n8n_readonly SET statement_timeout = '15s';

-- Configurar modo de transacción de solo lectura por defecto para la sesión
ALTER ROLE agente_n8n_readonly SET default_transaction_read_only = 'on';

-- ============================================================================
-- 6. PRUEBA DE IDENTIDAD Y PERMISOS DEL ROL (VERIFICACIÓN CONTROLADA)
-- ============================================================================
DO $$
BEGIN
    -- Cambiar temporalmente a la identidad del rol del agente
    SET LOCAL ROLE agente_n8n_readonly;

    -- Comprobación 1: SELECT debe ser permitido
    PERFORM count(*) FROM aduana.pais;
    RAISE NOTICE 'Verificación 1 SUPERADA: SELECT permitido para agente_n8n_readonly.';

    -- Comprobación 2: UPDATE debe ser rechazado
    BEGIN
        UPDATE aduana.pais SET nombre = 'Intento No Autorizado' WHERE id_pais = 1;
        RAISE EXCEPTION 'Fallo de seguridad: Se permitió UPDATE a agente_n8n_readonly';
    EXCEPTION 
        WHEN insufficient_privilege THEN
            RAISE NOTICE 'Verificación 2 SUPERADA: UPDATE rechazado por privilegios insuficientes.';
        WHEN read_only_sql_transaction THEN
            RAISE NOTICE 'Verificación 2 SUPERADA: UPDATE rechazado por transacción en solo lectura.';
    END;

    -- Comprobación 3: INSERT debe ser rechazado
    BEGIN
        INSERT INTO aduana.pais (codigo_iso_alfa2, nombre) VALUES ('XX', 'Pais Invalido');
        RAISE EXCEPTION 'Fallo de seguridad: Se permitió INSERT a agente_n8n_readonly';
    EXCEPTION 
        WHEN insufficient_privilege THEN
            RAISE NOTICE 'Verificación 3 SUPERADA: INSERT rechazado por privilegios insuficientes.';
        WHEN read_only_sql_transaction THEN
            RAISE NOTICE 'Verificación 3 SUPERADA: INSERT rechazado por transacción en solo lectura.';
    END;

    -- Restaurar identidad
    RESET ROLE;
    RAISE NOTICE 'Prueba de identidad finalizada: Rol agente_n8n_readonly verificado y protegido.';
END $$;
