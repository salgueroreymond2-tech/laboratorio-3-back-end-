-- ============================================================================
-- PROYECTO: Laboratorio #3 - Sistema de Inventario para una Aduana
-- AUTOR: Reymond Salguero
-- FECHA: Octubre de 2026
-- PLATAFORMA: Supabase | MOTOR: PostgreSQL 18
-- ARCHIVO: 02_datos.sql
-- DESCRIPCIÓN: Inserción de datos deterministas (mínimo 15 registros por tabla,
--              totalizando 205 registros en las 13 tablas) con coherencia temporal
--              en octubre de 2026 y sincronización final de secuencias.
-- ============================================================================

SET search_path TO aduana, public;

-- ----------------------------------------------------------------------------
-- 1. TABLA: aduana.pais (15 registros)
-- ----------------------------------------------------------------------------
INSERT INTO aduana.pais (id_pais, codigo_iso_alfa2, nombre, activo) VALUES
(1,  'CR', 'Costa Rica', true),
(2,  'CN', 'China', true),
(3,  'US', 'Estados Unidos', true),
(4,  'DE', 'Alemania', true),
(5,  'JP', 'Japón', true),
(6,  'MX', 'México', true),
(7,  'BR', 'Brasil', true),
(8,  'ES', 'España', true),
(9,  'KR', 'Corea del Sur', true),
(10, 'VN', 'Vietnam', true),
(11, 'IN', 'India', true),
(12, 'IT', 'Italia', true),
(13, 'CO', 'Colombia', true),
(14, 'PA', 'Panamá', true),
(15, 'CL', 'Chile', true);

-- ----------------------------------------------------------------------------
-- 2. TABLA: aduana.importador (15 registros)
-- ----------------------------------------------------------------------------
INSERT INTO aduana.importador (id_importador, id_pais, identificacion_tributaria, razon_social, correo_contacto, telefono_contacto, direccion_fiscal, activo) VALUES
(1,  1,  '3-101-123456', 'Importadora Tecnológica del Valle S.A.', 'adquisiciones@tecnovalle.cr', '+506 2200-1111', 'San José, Oficentro La Sabana, Torre 2', true),
(2,  1,  '3-101-234567', 'Distribuidora Médica Global S.A.', 'importaciones@medglobal.cr', '+506 2200-2222', 'San José, Rohrmoser, 500m Norte de Plaza Mayor', true),
(3,  3,  'US-EIN-987654', 'Pacific Logistics Imports LLC', 'operations@pacificimports.com', '+1 305-555-0199', '1200 Brickell Ave, Miami, FL 33131', true),
(4,  1,  '3-101-345678', 'Agroquímicos y Semillas del Caribe S.A.', 'logistica@agrocaribe.cr', '+506 2799-3333', 'Limón Centro, 200m Este del Muelle Nacional', true),
(5,  6,  'MX-RFC-567890', 'Comercializadora Azteca del Sur S.A. de C.V.', 'comercio@aztecadelsur.mx', '+52 55-5555-8888', 'Av. Insurgentes Sur 1602, Ciudad de México', true),
(6,  1,  '3-101-456789', 'Consorcio Automotriz Central S.A.', 'aduanas@automotrizcentral.cr', '+506 2440-4444', 'Alajuela, Radial Francisco J. Orlich', true),
(7,  8,  'ES-NIF-A12345', 'Iberia Electrónica Industrial S.L.', 'export@iberiaelectronica.es', '+34 91-555-4321', 'Calle Serrano 45, Madrid', true),
(8,  1,  '3-101-567890', 'Textiles y Modas de Centroamérica S.A.', 'compras@textilesca.cr', '+506 2222-5555', 'Heredia, Zona Franca Metropolitana', true),
(9,  4,  'DE-HRB-789012', 'Bavaria Industrial Solutions GmbH', 'logistics@bavariaindustrial.de', '+49 89-555-7777', 'Industriestrasse 12, München', true),
(10, 1,  '3-101-678901', 'ElectroHogar y Climatización S.A.', 'import@electrohogar.cr', '+506 2290-6666', 'San José, Pavas Industrial', true),
(11, 5,  'JP-HOJIN-1234', 'Nippon Solar Components Co. Ltd.', 'trade@nipponsolar.co.jp', '+81 3-5555-3333', 'Chiyoda-ku, Marunouchi 1-1, Tokyo', true),
(12, 14, 'PA-RUC-890123', 'Zona Libre Transatlántica Inc.', 'aduanas@zltransatlantica.pa', '+507 441-8888', 'Zona Libre de Colón, Manzana 14', true),
(13, 1,  '3-101-789012', 'Cafés y Granos de Especialidad S.A.', 'exportaciones@cafegranos.cr', '+506 2544-7777', 'Cartago, Tarrazú', true),
(14, 7,  'BR-CNPJ-34567', 'Amazonia Maquinaria Pesada Ltda.', 'operacoes@amazoniamac.br', '+55 11-5555-1212', 'Av. Paulista 1000, São Paulo', true),
(15, 1,  '3-101-890123', 'Alimentos Procesados Santa Fe S.A.', 'suministros@alimentosfe.cr', '+506 2433-8888', 'Puntarenas, Barranca', true);

-- ----------------------------------------------------------------------------
-- 3. TABLA: aduana.agente_aduanal (15 registros)
-- ----------------------------------------------------------------------------
INSERT INTO aduana.agente_aduanal (id_agente_aduanal, numero_licencia, nombre_completo, correo, telefono, activo) VALUES
(1,  'LIC-ADU-2026-001', 'Carlos Alberto Morales Solano', 'cmorales@agenteaduana.cr', '+506 8801-1111', true),
(2,  'LIC-ADU-2026-002', 'Mariana Patricia Soto Chaves', 'msoto@agenteaduana.cr', '+506 8802-2222', true),
(3,  'LIC-ADU-2026-003', 'Jorge Eduardo Ramírez Vargas', 'jramirez@agenteaduana.cr', '+506 8803-3333', true),
(4,  'LIC-ADU-2026-004', 'Ana Lorena Brenes Castro', 'abrenes@agenteaduana.cr', '+506 8804-4444', true),
(5,  'LIC-ADU-2026-005', 'Roberto Carlos Navarro Umaña', 'rnavarro@agenteaduana.cr', '+506 8805-5555', true),
(6,  'LIC-ADU-2026-006', 'Lucía Fernanda Jiménez Quesada', 'ljimenez@agenteaduana.cr', '+506 8806-6666', true),
(7,  'LIC-ADU-2026-007', 'Esteban Gabriel Rojas Monge', 'erojas@agenteaduana.cr', '+506 8807-7777', true),
(8,  'LIC-ADU-2026-008', 'Valeria Eugenia Delgado Solís', 'vdelgado@agenteaduana.cr', '+506 8808-8888', true),
(9,  'LIC-ADU-2026-009', 'Mauricio Andrés Cordero Vega', 'mcordero@agenteaduana.cr', '+506 8809-9999', true),
(10, 'LIC-ADU-2026-010', 'Daniela Paola Guzmán Herrera', 'dguzman@agenteaduana.cr', '+506 8810-0000', true),
(11, 'LIC-ADU-2026-011', 'Fernando José Campos Barquero', 'fcampos@agenteaduana.cr', '+506 8811-1111', true),
(12, 'LIC-ADU-2026-012', 'Silvia María Araya Fallas', 'saraya@agenteaduana.cr', '+506 8812-2222', true),
(13, 'LIC-ADU-2026-013', 'Álvaro Manuel Céspedes Mora', 'acespedes@agenteaduana.cr', '+506 8813-3333', true),
(14, 'LIC-ADU-2026-014', 'Gabriela Isabel Zúñiga Arias', 'gzuniga@agenteaduana.cr', '+506 8814-4444', true),
(15, 'LIC-ADU-2026-015', 'Diego Alonso Miranda Villalobos', 'dmiranda@agenteaduana.cr', '+506 8815-5555', true);

-- ----------------------------------------------------------------------------
-- 4. TABLA: aduana.categoria_arancelaria (15 registros)
-- ----------------------------------------------------------------------------
INSERT INTO aduana.categoria_arancelaria (id_categoria, codigo_capitulo, codigo_partida, codigo_subpartida, descripcion, arancel_base_porcentaje) VALUES
(1,  '84', '8471', '847130', 'Máquinas automáticas para procesamiento de datos, portátiles (computadoras portátiles)', 0.00),
(2,  '85', '8528', '852852', 'Monitores aptos para conectarse a máquinas automáticas de procesamiento de datos', 5.00),
(3,  '85', '8517', '851762', 'Aparatos para conmutación o encaminamiento de paquetes (routers, conmutadores)', 0.00),
(4,  '90', '9018', '901890', 'Instrumentos y aparatos de medicina o veterinaria (ecógrafos, electrocardiógrafos)', 0.00),
(5,  '30', '3004', '300490', 'Medicamentos constituidos por productos mezclados o sin mezclar en dosis terapéuticas', 0.00),
(6,  '87', '8703', '870323', 'Vehículos automóviles híbridos para transporte de personas, cilindrada entre 1500 y 3000 cm3', 15.00),
(7,  '84', '8415', '841510', 'Aparatos de climatización tipo split de pared o techo', 10.00),
(8,  '84', '8418', '841821', 'Refrigeradores domésticos de compresión', 12.00),
(9,  '85', '8504', '850440', 'Convertidores estáticos (inversores de potencia para energía solar)', 0.00),
(10, '85', '8525', '852589', 'Cámaras de televisión y videocámaras de seguridad digital', 8.00),
(11, '85', '8518', '851830', 'Auriculares y auriculares combinados con micrófono', 10.00),
(12, '84', '8473', '847330', 'Partes y accesorios de máquinas de procesamiento de datos (memorias y módulos SSD)', 0.00),
(13, '94', '9403', '940360', 'Mobiliario de madera de los tipos utilizados en oficinas ejecutivas', 14.00),
(14, '61', '6109', '610910', 'Camisetas de punto confeccionadas con fibra de algodón', 15.00),
(15, '09', '0901', '090111', 'Café sin tostar, sin descafeinar, grano verde para exportación', 5.00);

-- ----------------------------------------------------------------------------
-- 5. TABLA: aduana.producto (15 registros)
-- Nótese: Productos con id_pais_origen = 2 (China) para resolver Consulta 2.
-- ----------------------------------------------------------------------------
INSERT INTO aduana.producto (id_producto, id_categoria, id_pais_origen, codigo_sku, nombre_comercial, descripcion, unidad_medida, activo) VALUES
(1,  1,  2, 'SKU-LAP-CN01', 'Laptop Gamer Pro Titan X', 'Portátil Intel Core i9, 32GB RAM, 1TB SSD pantalla 16 pulg', 'unidades', true),
(2,  2,  2, 'SKU-MON-CN02', 'Monitor Curvo UltraWide 34"', 'Panel IPS 144Hz resolución 3440x1440 conexión USB-C', 'unidades', true),
(3,  3,  3, 'SKU-ROU-US03', 'Router Empresarial Gigabit C9200', 'Enrutador redundante para centros de datos 48 puertos', 'unidades', true),
(4,  4,  4, 'SKU-ECO-DE04', 'Ecógrafo Doppler Clínico 4D', 'Sistema médico avanzado de diagnóstico ultrasónico', 'unidades', true),
(5,  5,  13,'SKU-MED-CO05', 'Amoxicilina 500mg Genérico', 'Cajas hospitalarias con 100 cápsulas selladas', 'cajas', true),
(6,  6,  5, 'SKU-AUT-JP06', 'Vehículo Sedán Híbrido 2.0L', 'Automóvil de pasajeros tracción delantera modelo 2026', 'unidades', true),
(7,  7,  2, 'SKU-AC-CN07',  'Aire Acondicionado Split 24000 BTU', 'Unidad climatizadora Inverter bajo consumo energético', 'unidades', true),
(8,  8,  6, 'SKU-REF-MX08', 'Refrigerador No Frost 400L', 'Refrigerador doméstico acero cepillado dispensador agua', 'unidades', true),
(9,  9,  2, 'SKU-INV-CN09', 'Inversor Solar On-Grid 5kW', 'Convertidor fotovoltaico conexión a red certificación IEC', 'unidades', true),
(10, 10, 9, 'SKU-CAM-KR10', 'Cámara Domo IP 4K Antivandálica', 'Cámara de vigilancia exterior sensor infrarrojo 30m', 'unidades', true),
(11, 11, 10,'SKU-AUD-VN11', 'Auriculares Noise Cancelling Pro', 'Audífonos inalámbricos Bluetooth con cancelación activa', 'unidades', true),
(12, 12, 2, 'SKU-SSD-CN12', 'Disco Sólido NVMe PCIe 2TB', 'Unidad M.2 2280 lectura 7000 MB/s para servidores', 'unidades', true),
(13, 13, 8, 'SKU-MUE-ES13', 'Escritorio Ergonómico de Roble', 'Mesa de despacho ajustable en altura estructura metálica', 'unidades', true),
(14, 14, 11,'SKU-TEX-IN14', 'Lote de Camisetas Algodón Pima', 'Cajas con 50 prendas textiles lisas cuello redondo', 'cajas', true),
(15, 15, 1, 'SKU-CAF-CR15', 'Café Oro Grano Especialidad Tarrazú', 'Saco de 69kg grano verde calidad estricta altura (SHB)', 'kilogramos', true);

-- ----------------------------------------------------------------------------
-- 6. TABLA: aduana.contenedor (15 registros)
-- Nótese: Distribución con EMPATE en el máximo para procedencia (Consulta 3):
-- China (id_pais_procedencia = 2): 4 contenedores (IDs 1, 2, 3, 4)
-- Estados Unidos (id_pais_procedencia = 3): 4 contenedores (IDs 5, 6, 7, 8)
-- ----------------------------------------------------------------------------
INSERT INTO aduana.contenedor (id_contenedor, id_pais_procedencia, numero_sigla, tipo_dimension, tara_kg, capacidad_max_kg, estado_operativo) VALUES
(1,  2, 'MSKU1001011', '40HC', 3900.00, 28600.00, 'En Bodega'),
(2,  2, 'MSKU1002022', '40HC', 3880.00, 28620.00, 'En Bodega'),
(3,  2, 'COSU2003033', '20GP', 2250.00, 21750.00, 'En Inspeccion'),
(4,  2, 'COSU2004044', '40GP', 3700.00, 26780.00, 'En Puerto'),
(5,  3, 'CMAU3005055', '40HC', 3950.00, 28550.00, 'En Puerto'),
(6,  3, 'CMAU3006066', '40RF', 4480.00, 29520.00, 'En Bodega'),
(7,  3, 'ONEU4007077', '20GP', 2200.00, 21800.00, 'En Transito'),
(8,  3, 'ONEU4008088', '40HC', 3920.00, 28580.00, 'Despachado'),
(9,  4, 'HLCU5009099', '40HC', 3890.00, 28610.00, 'En Inspeccion'),
(10, 4, 'HLCU5010100', '20GP', 2230.00, 21770.00, 'En Bodega'),
(11, 5, 'NYKU6011111', '40HC', 3910.00, 28590.00, 'Despachado'),
(12, 5, 'NYKU6012122', '45HC', 4200.00, 29800.00, 'En Puerto'),
(13, 6, 'TGHU7013133', '40GP', 3720.00, 26760.00, 'En Bodega'),
(14, 8, 'SUDU8014144', '20GP', 2240.00, 21760.00, 'En Puerto'),
(15, 1, 'CRXU9015155', '40HC', 3870.00, 28630.00, 'Despachado');

-- ----------------------------------------------------------------------------
-- 7. TABLA: aduana.ficha_contenedor (15 registros)
-- Relación 1:1 estricta: id_contenedor es PK y FK a aduana.contenedor.
-- ----------------------------------------------------------------------------
INSERT INTO aduana.ficha_contenedor (id_contenedor, numero_marchamo_aduana, temperatura_controlada_c, humedad_relativa_porc, observacion_inspeccion_fisica, fecha_emision_ficha) VALUES
(1,  'MARCH-CR-2026-0001', NULL,  NULL,  'Precinto intacto perno de alta seguridad ISO 17712', '2026-10-02 08:00:00-06'),
(2,  'MARCH-CR-2026-0002', NULL,  NULL,  'Marchamo verificado sin indicios de manipulación', '2026-10-03 09:30:00-06'),
(3,  'MARCH-CR-2026-0003', NULL,  NULL,  'Precinto colocado en muelle de origen verificado', '2026-10-04 11:15:00-06'),
(4,  'MARCH-CR-2026-0004', NULL,  NULL,  'Marchamo metálico serializado conforme', '2026-10-05 14:00:00-06'),
(5,  'MARCH-CR-2026-0005', NULL,  NULL,  'Sellos de seguridad autorizados por naviera', '2026-10-06 10:20:00-06'),
(6,  'MARCH-CR-2026-0006', 4.50,  85.00, 'Contenedor refrigerado cadena de frío operativa', '2026-10-07 13:45:00-06'),
(7,  'MARCH-CR-2026-0007', NULL,  NULL,  'Precinto satelital electrónico activo', '2026-10-08 07:50:00-06'),
(8,  'MARCH-CR-2026-0008', NULL,  NULL,  'Marchamo retirado tras autorización de levante', '2026-10-09 16:10:00-06'),
(9,  'MARCH-CR-2026-0009', NULL,  NULL,  'Precinto de seguridad en proceso de aforo físico', '2026-10-10 10:00:00-06'),
(10, 'MARCH-CR-2026-0010', NULL,  NULL,  'Perno de seguridad fiscal colocado en aduana', '2026-10-11 11:40:00-06'),
(11, 'MARCH-CR-2026-0011', NULL,  NULL,  'Marchamo verificado previo a retiro del muelle', '2026-10-12 15:30:00-06'),
(12, 'MARCH-CR-2026-0012', NULL,  NULL,  'Sellos concordantes con manifiesto de carga marítimo', '2026-10-13 09:15:00-06'),
(13, 'MARCH-CR-2026-0013', NULL,  NULL,  'Precinto de cable acerado en compuerta trasera', '2026-10-14 14:50:00-06'),
(14, 'MARCH-CR-2026-0014', NULL,  NULL,  'Marchamo aduanero tipo botella en regla', '2026-10-15 08:35:00-06'),
(15, 'MARCH-CR-2026-0015', NULL,  NULL,  'Precinto de exportación nacional colocado en planta', '2026-10-16 12:00:00-06');

-- ----------------------------------------------------------------------------
-- 8. TABLA: aduana.declaracion_aduanera (15 registros)
-- Fechas registradas en octubre de 2026.
-- Regímenes: 'Importacion' (10 DUAs), 'Exportacion' (2 DUAs), 'Transito' (1 DUA), 'Deposito' (2 DUAs).
-- Estados: 'Retenida', 'Liberada', 'En Inspeccion'.
-- ----------------------------------------------------------------------------
INSERT INTO aduana.declaracion_aduanera (id_declaracion, id_importador, id_agente_aduanal, id_contenedor, numero_dua, regimen, estado, fecha_declaracion, fecha_ingreso_recinto, moneda) VALUES
(1,  1,  1,  1,  'DUA-2026-0001', 'Importacion', 'Liberada',      DATE '2026-10-01', '2026-10-01 08:30:00-06', 'USD'),
(2,  2,  2,  9,  'DUA-2026-0002', 'Importacion', 'En Inspeccion', DATE '2026-10-03', '2026-10-03 09:15:00-06', 'USD'),
(3,  1,  3,  2,  'DUA-2026-0003', 'Importacion', 'Retenida',      DATE '2026-10-04', '2026-10-04 10:00:00-06', 'USD'), -- Mercancía China retenida en bodega (Consulta 2)
(4,  3,  4,  5,  'DUA-2026-0004', 'Importacion', 'Liberada',      DATE '2026-10-05', '2026-10-05 14:20:00-06', 'USD'),
(5,  4,  5,  6,  'DUA-2026-0005', 'Importacion', 'En Inspeccion', DATE '2026-10-06', '2026-10-06 11:45:00-06', 'USD'),
(6,  6,  6,  11, 'DUA-2026-0006', 'Exportacion', 'Liberada',      DATE '2026-10-07', '2026-10-07 16:00:00-06', 'USD'),
(7,  10, 7,  3,  'DUA-2026-0007', 'Importacion', 'Retenida',      DATE '2026-10-08', '2026-10-08 07:30:00-06', 'USD'), -- Mercancía China retenida en bodega (Consulta 2)
(8,  5,  8,  4,  'DUA-2026-0008', 'Deposito',    'Retenida',      DATE '2026-10-02', '2026-10-02 06:15:00-06', 'USD'), -- Larga permanencia (Consulta 8)
(9,  7,  9,  7,  'DUA-2026-0009', 'Importacion', 'En Inspeccion', DATE '2026-10-10', '2026-10-10 13:10:00-06', 'USD'),
(10, 8,  10, 8,  'DUA-2026-0010', 'Importacion', 'Liberada',      DATE '2026-10-12', '2026-10-12 15:40:00-06', 'USD'),
(11, 9,  11, 10, 'DUA-2026-0011', 'Importacion', 'En Inspeccion', DATE '2026-10-15', '2026-10-15 09:50:00-06', 'USD'),
(12, 12, 12, 12, 'DUA-2026-0012', 'Transito',    'Liberada',      DATE '2026-10-18', '2026-10-18 10:25:00-06', 'USD'),
(13, 11, 13, 13, 'DUA-2026-0013', 'Deposito',    'En Inspeccion', DATE '2026-10-20', '2026-10-20 12:00:00-06', 'USD'),
(14, 6,  14, 14, 'DUA-2026-0014', 'Importacion', 'En Inspeccion', DATE '2026-10-22', '2026-10-22 14:15:00-06', 'USD'),
(15, 13, 15, 15, 'DUA-2026-0015', 'Exportacion', 'Liberada',      DATE '2026-10-25', '2026-10-25 11:00:00-06', 'USD');

-- ----------------------------------------------------------------------------
-- 9. TABLA: aduana.detalle_declaracion (20 registros en total)
-- PK compuesta (id_declaracion, numero_linea). Permite múltiples líneas por DUA.
-- Valores unitarios en USD.
-- ----------------------------------------------------------------------------
INSERT INTO aduana.detalle_declaracion (id_declaracion, numero_linea, id_producto, cantidad, unidad_medida, valor_unitario, tasa_arancelaria_porc, descripcion_arancelaria) VALUES
(1,  1, 1,   100.00, 'unidades',   950.00, 0.00,  'Laptops Gamer Core i9 portátiles para oficina técnica'),
(1,  2, 12,  200.00, 'unidades',   120.00, 0.00,  'Módulos SSD 2TB M.2 PCIe Gen 4'),
(2,  1, 4,   5.00,   'unidades', 26000.00, 0.00,  'Ecógrafos Doppler 4D para diagnóstico hospitalario'),
(3,  1, 1,   80.00,  'unidades',   920.00, 0.00,  'Laptops Gamer Pro Titan X lote origen Shenzhen'),
(3,  2, 2,   60.00,  'unidades',   350.00, 5.00,  'Monitores Curvos 34 pulgadas UltraWide'),
(4,  1, 3,   15.00,  'unidades',  4200.00, 0.00,  'Routers empresariales Gigabit C9200 redundantes'),
(5,  1, 5,   800.00, 'cajas',      110.00, 0.00,  'Cajas de Amoxicilina 500mg 100 cápsulas'),
(6,  1, 6,   10.00,  'unidades', 28500.00, 15.00, 'Vehículos híbridos sedán 2.0L modelo 2026'),
(7,  1, 2,   120.00, 'unidades',   340.00, 5.00,  'Monitores Curvos UltraWide 34 pulgadas 144Hz'),
(7,  2, 7,   50.00,  'unidades',   620.00, 10.00, 'Aires acondicionados split inverter 24000 BTU'),
(8,  1, 9,   40.00,  'unidades',   850.00, 0.00,  'Inversores solares 5kW conexión a red trifásica'),
(9,  1, 13,  75.00,  'unidades',   450.00, 14.00, 'Escritorios ergonómicos de roble para oficina'),
(10, 1, 14,  300.00, 'cajas',      280.00, 15.00, 'Cajas de camisetas algodón Pima de punto'),
(11, 1, 10,  90.00,  'unidades',   210.00, 8.00,  'Cámaras domo IP 4K con sensor infrarrojo'),
(12, 1, 11,  250.00, 'unidades',    85.00, 10.00, 'Auriculares inalámbricos con cancelación activa'),
(13, 1, 9,   30.00,  'unidades',   870.00, 0.00,  'Inversores fotovoltaicos en depósito aduanero'),
(14, 1, 6,   5.00,   'unidades', 29000.00, 15.00, 'Vehículos híbridos sedán entrega especial'),
(14, 2, 8,   40.00,  'unidades',   530.00, 12.00, 'Refrigeradores domésticos No Frost 400L'),
(15, 1, 15, 5000.00, 'kilogramos',    7.50, 5.00,  'Café especialidad grano verde Tarrazú para exportación'),
(15, 2, 15, 3000.00, 'kilogramos',    8.20, 5.00,  'Café especialidad microlote grano verde selección');

-- ----------------------------------------------------------------------------
-- 10. TABLA: aduana.bodega (15 registros)
-- Recintos fiscales, frigoríficos, generales y especializados.
-- ----------------------------------------------------------------------------
INSERT INTO aduana.bodega (id_bodega, codigo_bodega, nombre, tipo_bodega, ubicacion_recinto, capacidad_volumen_m3, activo) VALUES
(1,  'BOD-FISC-01', 'Bodega Fiscal Central Santamaría', 'Fiscal', 'Patio Fiscal Aeropuerto Juan Santamaría', 5000.00, true),
(2,  'BOD-REFR-02', 'Bodega Frigorífica Caldera', 'Refrigerada', 'Terminal de Contenedores Puerto Caldera', 2500.00, true),
(3,  'BOD-GENE-03', 'Bodega General de Cargas Moín', 'General', 'Terminal APM Terminals Moín Limón', 8000.00, true),
(4,  'BOD-PELI-04', 'Bodega de Materiales Especiales', 'Mercancias Peligrosas', 'Sector Químico Zona Logística', 1500.00, true),
(5,  'BOD-FISC-05', 'Bodega Fiscal Peñas Blancas', 'Fiscal', 'Puesto Fronterizo Norte Peñas Blancas', 3000.00, true),
(6,  'BOD-FISC-06', 'Bodega Fiscal Paso Canoas', 'Fiscal', 'Puesto Fronterizo Sur Paso Canoas', 3000.00, true),
(7,  'BOD-REFR-07', 'Bodega Frigorífica Limón Terminal', 'Refrigerada', 'Muelle Alemán Puerto Limón', 2200.00, true),
(8,  'BOD-GENE-08', 'Bodega Central de Tránsito La Uruca', 'General', 'Parque Industrial La Uruca San José', 6000.00, true),
(9,  'BOD-FISC-09', 'Bodega de Decomisos y Custodia Fiscal', 'Fiscal', 'Recinto Central Dirección General Aduanas', 2000.00, true),
(10, 'BOD-GENE-10', 'Bodega Courier y Envíos Rápidos', 'General', 'Aeropuerto Juan Santamaría Alajuela', 1800.00, true),
(11, 'BOD-FISC-11', 'Bodega Fiscal El Coyol', 'Fiscal', 'Parque Logístico Coyol Alajuela', 7500.00, true),
(12, 'BOD-REFR-12', 'Bodega Frigorífica San José Carga', 'Refrigerada', 'Terminal de Carga Aérea SJO', 1400.00, true),
(13, 'BOD-PELI-13', 'Depósito Aduanero Químicos Cartago', 'Mercancias Peligrosas', 'Zona Industrial Cartago', 2100.00, true),
(14, 'BOD-GENE-14', 'Bodega Logística del Pacífico', 'General', 'Sector Muelle Puntarenas', 4500.00, true),
(15, 'BOD-FISC-15', 'Bodega Fiscal Almacenadora del Este', 'Fiscal', 'Curridabat San José', 3600.00, true);

-- ----------------------------------------------------------------------------
-- 11. TABLA: aduana.inventario_bodega (20 registros)
-- Trazabilidad a (id_declaracion, numero_linea) y bodega.
-- Casos clave:
-- - Registro 3: DUA-2026-0003, línea 1 (Laptops, China), Bodega 1, cantidad 80, activa (Consulta 2).
-- - Registro 7: DUA-2026-0007, línea 1 (Monitores, China), Bodega 1, cantidad 120, activa (Consulta 2).
-- - Registro 8: DUA-2026-0008, línea 1 (Inversores, China), Bodega 1, cantidad 40, activa desde 2026-10-02 (Consulta 8: mayor permanencia).
-- ----------------------------------------------------------------------------
INSERT INTO aduana.inventario_bodega (id_inventario, id_bodega, id_declaracion, numero_linea, id_producto, ubicacion_estante, cantidad_almacenada, unidad_medida, fecha_ingreso, fecha_salida) VALUES
(1,  1,  1,  1, 1,   'EST-A01-N1',   0.00, 'unidades',   '2026-10-01 09:00:00-06', '2026-10-03 14:00:00-06'), -- Despachado
(2,  1,  1,  2, 12,  'EST-A01-N2',   0.00, 'unidades',   '2026-10-01 09:15:00-06', '2026-10-03 14:30:00-06'), -- Despachado
(3,  1,  3,  1, 1,   'EST-C01-N3',  80.00, 'unidades',   '2026-10-04 10:30:00-06', NULL),                    -- China retenida en bodega (Consulta 2)
(4,  1,  3,  2, 2,   'EST-C01-N4',  60.00, 'unidades',   '2026-10-04 10:45:00-06', NULL),                    -- China retenida en bodega (Consulta 2)
(5,  2,  5,  1, 5,   'EST-R02-N1', 800.00, 'cajas',      '2026-10-06 12:15:00-06', NULL),
(6,  3,  4,  1, 3,   'EST-G03-N1',   0.00, 'unidades',   '2026-10-05 15:00:00-06', '2026-10-07 10:00:00-06'), -- Despachado
(7,  1,  7,  1, 2,   'EST-A04-N1', 120.00, 'unidades',   '2026-10-08 08:00:00-06', NULL),                    -- China retenida en bodega (Consulta 2)
(8,  1,  8,  1, 9,   'EST-D01-N1',  40.00, 'unidades',   '2026-10-02 07:00:00-06', NULL),                    -- China retenida en bodega (Consulta 2 y 8)
(9,  11, 2,  1, 4,   'EST-M05-N1',   5.00, 'unidades',   '2026-10-03 10:00:00-06', NULL),
(10, 8,  9,  1, 13,  'EST-T06-N2',  75.00, 'unidades',   '2026-10-10 14:00:00-06', NULL),
(11, 8,  10, 1, 14,  'EST-T07-N1',   0.00, 'cajas',      '2026-10-12 16:30:00-06', '2026-10-15 11:20:00-06'), -- Despachado
(12, 11, 11, 1, 10,  'EST-M06-N2',  90.00, 'unidades',   '2026-10-15 10:30:00-06', NULL),
(13, 8,  12, 1, 11,  'EST-T08-N1',   0.00, 'unidades',   '2026-10-18 11:00:00-06', '2026-10-19 16:00:00-06'), -- Despachado
(14, 11, 13, 1, 9,   'EST-M07-N1',  30.00, 'unidades',   '2026-10-20 12:45:00-06', NULL),
(15, 11, 14, 1, 6,   'EST-M08-N1',   5.00, 'unidades',   '2026-10-22 15:00:00-06', NULL),
(16, 11, 14, 2, 8,   'EST-M08-N2',  40.00, 'unidades',   '2026-10-22 15:15:00-06', NULL),
(17, 3,  15, 1, 15,  'EST-G04-N1',5000.00, 'kilogramos', '2026-10-25 11:30:00-06', NULL),
(18, 3,  15, 2, 15,  'EST-G04-N2',3000.00, 'kilogramos', '2026-10-25 11:45:00-06', NULL),
(19, 1,  7,  2, 7,   'EST-A04-N2',  50.00, 'unidades',   '2026-10-08 08:30:00-06', NULL),                    -- China retenida en bodega (Consulta 2)
(20, 14, 6,  1, 6,   'EST-P01-N1',   0.00, 'unidades',   '2026-10-07 16:45:00-06', '2026-10-09 17:00:00-06'); -- Despachado

-- ----------------------------------------------------------------------------
-- 12. TABLA: aduana.funcionario (15 registros)
-- Jerarquía recursiva limpia:
-- id_funcionario = 1 es Director General (id_supervisor IS NULL).
-- Demás funcionarios reportan a sus jefes respectivos sin autosupervisión ni ciclos.
-- ----------------------------------------------------------------------------
INSERT INTO aduana.funcionario (id_funcionario, id_supervisor, numero_empleado, nombre_completo, puesto_cargo, area_adscripcion, correo_institucional, activo) VALUES
(1,  NULL, 'EMP-2026-001', 'Lic. Rodrigo Chaves Montero', 'Director General de Aduanas', 'Dirección General de Aduanas', 'rchaves@hacienda.go.cr', true),
(2,  1,    'EMP-2026-002', 'Ing. Silvia Elena Castro Fallas', 'Jefa del Departamento Técnico Aduanero', 'División Técnica', 'scastro@hacienda.go.cr', true),
(3,  1,    'EMP-2026-003', 'Lic. Marco Vinicio Mora Vega', 'Jefe de Operaciones y Fiscalización', 'División Operativa', 'mmora@hacienda.go.cr', true),
(4,  2,    'EMP-2026-004', 'Licda. Patricia María Solano Quirós', 'Coordinadora de Aforo y Clasificación', 'División Técnica', 'psolano@hacienda.go.cr', true),
(5,  2,    'EMP-2026-005', 'Ing. Gerardo Alonso Soto Blanco', 'Supervisor de Valoración Aduanera', 'División Técnica', 'gsoto@hacienda.go.cr', true),
(6,  3,    'EMP-2026-006', 'Lic. Andrés Felipe Cordero Ruiz', 'Supervisor de Reconocimiento Físico', 'División Operativa', 'acordero@hacienda.go.cr', true),
(7,  3,    'EMP-2026-007', 'Licda. Mónica Beatriz Quesada Vargas', 'Supervisora de Control No Intrusivo', 'División Operativa', 'mquesada@hacienda.go.cr', true),
(8,  4,    'EMP-2026-008', 'Lic. Kenneth David Guzmán Monge', 'Inspector de Aforo Físico', 'Aduana Central Santamaría', 'kguzman@hacienda.go.cr', true),
(9,  4,    'EMP-2026-009', 'Licda. Jessica Rocío Rojas Benavides', 'Inspectora de Aforo Documental', 'Aduana Central Santamaría', 'jrojas@hacienda.go.cr', true),
(10, 5,    'EMP-2026-010', 'Ing. Javier Esteban Delgado Umaña', 'Inspector de Valor y Tributos', 'Aduana Puerto Caldera', 'jdelgado@hacienda.go.cr', true),
(11, 5,    'EMP-2026-011', 'Licda. Karen Natalia Calvo Miranda', 'Inspectora de Clasificación Arancelaria', 'Aduana Puerto Caldera', 'kcalvo@hacienda.go.cr', true),
(12, 6,    'EMP-2026-012', 'Lic. Bryan Alexander Campos Núñez', 'Inspector de Muelle y Patios', 'Aduana de Limón', 'bcampos@hacienda.go.cr', true),
(13, 6,    'EMP-2026-013', 'Licda. Katherine Vanessa Arias Jiménez', 'Inspectora de Reconocimiento Físico', 'Aduana de Limón', 'karias@hacienda.go.cr', true),
(14, 7,    'EMP-2026-014', 'Ing. Ronald Gabriel Zúñiga Solís', 'Operador Especialista Escáner Portuario', 'Puesto Fronterizo Peñas Blancas', 'rzuniga@hacienda.go.cr', true),
(15, 7,    'EMP-2026-015', 'Licda. Stephanie Paola Méndez Fonseca', 'Analista de Imágenes No Intrusivas', 'Aduana Central Santamaría', 'smendez@hacienda.go.cr', true);

-- ----------------------------------------------------------------------------
-- 13. TABLA: aduana.inspeccion (15 registros)
-- Actas formales de reconocimiento con observaciones técnicas explícitas (Consulta 5).
-- ----------------------------------------------------------------------------
INSERT INTO aduana.inspeccion (id_inspeccion, id_declaracion, id_funcionario, numero_acta, tipo_inspeccion, fecha_inspeccion, resultado, observaciones, dictamen_firmado) VALUES
(1,  1,  8,  'ACTA-INSP-2026-0001', 'Documental',           '2026-10-01 11:30:00-06', 'Conforme',                 'Revisión documental de factura comercial y certificados de origen conforme sin inconsistencias', true),
(2,  2,  9,  'ACTA-INSP-2026-0002', 'Fisica',               '2026-10-03 14:00:00-06', 'Conforme',                 'Aforo físico de ecógrafos de diagnóstico. Seriales y empaques estériles coinciden con DUA', true),
(3,  3,  8,  'ACTA-INSP-2026-0003', 'Fisica',               '2026-10-04 15:30:00-06', 'Retencion Preventiva',     'Se detecta discrepancia en número de serie y valor declarado de laptops. Se ordena retención para peritaje técnico', true),
(4,  4,  10, 'ACTA-INSP-2026-0004', 'Escaner No Intrusivo', '2026-10-05 16:15:00-06', 'Conforme',                 'Escaneo de contenedor sin densidades sospechosas ni carga no declarada', true),
(5,  5,  11, 'ACTA-INSP-2026-0005', 'Fisica',               '2026-10-06 14:00:00-06', 'Conforme',                 'Muestreo farmacéutico de amoxicilina con autorización de Ministerio de Salud al día', true),
(6,  6,  12, 'ACTA-INSP-2026-0006', 'Documental',           '2026-10-07 17:00:00-06', 'Conforme',                 'Comprobación de títulos de propiedad de automotores y manifiesto de exportación marítima', true),
(7,  7,  8,  'ACTA-INSP-2026-0007', 'Fisica',               '2026-10-08 11:00:00-06', 'Retencion Preventiva',     'Presunta subvaluación en monitores y aires acondicionados originarios de China. Se levanta acta de retención preventiva', true),
(8,  8,  10, 'ACTA-INSP-2026-0008', 'Documental',           '2026-10-09 10:30:00-06', 'Discrepancia Arancelaria', 'Se constata subpartida declarada incorrecta para convertidores estáticos de energía. Requiere reliquidación', true),
(9,  9,  13, 'ACTA-INSP-2026-0009', 'Fisica',               '2026-10-11 11:20:00-06', 'Conforme',                 'Reconocimiento físico de mobiliario de oficina de roble. Cantidad y cubicaje conforme', true),
(10, 10, 12, 'ACTA-INSP-2026-0010', 'Escaner No Intrusivo', '2026-10-13 14:40:00-06', 'Conforme',                 'Contenedor escaneado sin anomalías de densidad de carga textil', true),
(11, 11, 14, 'ACTA-INSP-2026-0011', 'Fisica',               '2026-10-16 11:15:00-06', 'Discrepancia Arancelaria', 'Divergencia entre especificaciones de cámaras de seguridad y partida de equipos de telecomunicación', true),
(12, 12, 15, 'ACTA-INSP-2026-0012', 'Documental',           '2026-10-18 13:00:00-06', 'Conforme',                 'Tránsito internacional autorizado con precinto electrónico satelital operativo', true),
(13, 13, 9,  'ACTA-INSP-2026-0013', 'Fisica',               '2026-10-21 15:30:00-06', 'Conforme',                 'Verificación de ingreso a depósito fiscal de inversores fotovoltaicos', true),
(14, 14, 8,  'ACTA-INSP-2026-0014', 'Fisica',               '2026-10-23 10:00:00-06', 'Conforme',                 'Revisión física de números de chasis de vehículos y seriales de refrigeradores conforme', true),
(15, 15, 12, 'ACTA-INSP-2026-0015', 'Fisica',               '2026-10-26 14:30:00-06', 'Conforme',                 'Certificación fitosanitaria de café verde de exportación y pesaje de sacos en regla', true);

-- ============================================================================
-- SINCRONIZACIÓN DE SECUENCIAS E IDENTIDADES
-- Garantiza que futuras inserciones manuales continúen desde el ID máximo
-- ============================================================================
SELECT setval(pg_get_serial_sequence('aduana.pais', 'id_pais'), coalesce(max(id_pais), 1)) FROM aduana.pais;
SELECT setval(pg_get_serial_sequence('aduana.importador', 'id_importador'), coalesce(max(id_importador), 1)) FROM aduana.importador;
SELECT setval(pg_get_serial_sequence('aduana.agente_aduanal', 'id_agente_aduanal'), coalesce(max(id_agente_aduanal), 1)) FROM aduana.agente_aduanal;
SELECT setval(pg_get_serial_sequence('aduana.categoria_arancelaria', 'id_categoria'), coalesce(max(id_categoria), 1)) FROM aduana.categoria_arancelaria;
SELECT setval(pg_get_serial_sequence('aduana.producto', 'id_producto'), coalesce(max(id_producto), 1)) FROM aduana.producto;
SELECT setval(pg_get_serial_sequence('aduana.contenedor', 'id_contenedor'), coalesce(max(id_contenedor), 1)) FROM aduana.contenedor;
SELECT setval(pg_get_serial_sequence('aduana.declaracion_aduanera', 'id_declaracion'), coalesce(max(id_declaracion), 1)) FROM aduana.declaracion_aduanera;
SELECT setval(pg_get_serial_sequence('aduana.bodega', 'id_bodega'), coalesce(max(id_bodega), 1)) FROM aduana.bodega;
SELECT setval(pg_get_serial_sequence('aduana.inventario_bodega', 'id_inventario'), coalesce(max(id_inventario), 1)) FROM aduana.inventario_bodega;
SELECT setval(pg_get_serial_sequence('aduana.funcionario', 'id_funcionario'), coalesce(max(id_funcionario), 1)) FROM aduana.funcionario;
SELECT setval(pg_get_serial_sequence('aduana.inspeccion', 'id_inspeccion'), coalesce(max(id_inspeccion), 1)) FROM aduana.inspeccion;
