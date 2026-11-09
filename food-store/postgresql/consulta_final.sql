-- ============================================================================
-- consulta_final.sql
-- 
-- Asignatura: Bases de Datos II - Tecnicatura Universitaria en Programación
-- Proyecto: Food Store - Unidad 8: Verificación de Aislamiento "Móvil Propone, Servidor Dispone"
-- Motor: PostgreSQL 16+
-- ============================================================================

-- Verificación en servidor central:
-- Ningún borrador marcado localmente en la tablet como 'SIMULADO_APROBADO'
-- debe haber impactado las tablas operativas de PostgreSQL directamente.

SELECT COUNT(*) AS pedidos_nuevos_en_servidor
FROM pedido
WHERE fecha >= '2026-11-05 18:00:00';

-- Resultado esperado: 0 filas / pedidos creados.
-- Demuestra que la base de datos de producción permanece intacta hasta que
-- un proceso formal de sincronización e ingesta procese la cola y descuente stock.
