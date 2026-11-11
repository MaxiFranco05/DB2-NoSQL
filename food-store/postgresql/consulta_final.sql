-- ============================================================================
-- consulta_final.sql
-- 
-- Asignatura: Bases de Datos II - Tecnicatura Universitaria en Programación
-- Proyecto: Food Store - Unidad 8: Verificación de Aislamiento "Móvil Propone, Servidor Dispone"
-- Motor: PostgreSQL 16+
-- ============================================================================

-- 1. Verificación en servidor central:
-- Ningún borrador marcado localmente en la tablet como 'SIMULADO_APROBADO'
-- impacta en las tablas operativas de PostgreSQL sin sincronización formal.
SELECT COUNT(*) AS pedidos_nuevos_en_servidor
FROM pedido
WHERE fecha >= '2026-11-05 18:00:00';
-- Resultado esperado: 0 filas / pedidos creados.

-- 2. Verificación del estado real del catálogo en PostgreSQL tras casos_servidor.sql:
-- Demuestra que el Producto 1 tiene su nuevo precio oficial ($4500.00), el Producto 3
-- está dado de baja lógica (activo = false), y ningún stock fue descontado por la tablet.
SELECT id, nombre, precio, stock, activo
FROM producto
WHERE id IN (1, 2, 3, 4)
ORDER BY id;
-- Resultado esperado:
--  id |   nombre   | precio  | stock | activo 
-- ----+------------+---------+-------+--------
--   1 | Producto 1 | 4500.00 |   184 | t
--   2 | Producto 2 |  766.89 |    36 | t
--   3 | Producto 3 | 3289.26 |   199 | f
--   4 | Producto 4 |  630.36 |   154 | t
