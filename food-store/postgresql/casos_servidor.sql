-- ============================================================================
-- casos_servidor.sql
-- 
-- Asignatura: Bases de Datos II - Tecnicatura Universitaria en Programación
-- Proyecto: Food Store - Unidad 8: Simulación de Eventos en Servidor Central
-- Motor: PostgreSQL 16+
-- ============================================================================

-- Simulación de eventos en PostgreSQL mientras la tablet opera desconectada:
-- 1. Actualización de precio en Producto 1 (de 4214.51 a 4500.00)
UPDATE producto 
SET precio = 4500.00 
WHERE id = 1;

-- 2. Baja lógica de Producto 3 (cambio de activo a FALSE)
UPDATE producto 
SET activo = FALSE 
WHERE id = 3;

-- 3. Regeneración de la instantánea con los cambios aplicados
\copy (SELECT * FROM v_snapshot_movil) TO 'movil/servidor_snapshot.csv' CSV HEADER
