-- ============================================================================
-- 10_snapshot_catalogo.sql
-- 
-- Asignatura: Bases de Datos II - Tecnicatura Universitaria en Programación
-- Proyecto: Food Store - Unidad 8: Base de Datos Móvil Desconectada (SQLite)
-- Motor: PostgreSQL 16+ (Servidor Central)
-- ============================================================================

-- Vista de catálogo para alimentar el snapshot de las tablets offline
CREATE OR REPLACE VIEW v_snapshot_movil AS
SELECT
    p.id,
    p.nombre,
    ROUND(p.precio * 100)::INTEGER AS precio_centavos,
    p.stock,
    (p.activo AND p.stock > 0) AS disponible,
    (NOT p.activo) AS eliminado
FROM producto p
ORDER BY p.id;

-- Comando para exportar el catálogo a CSV y transferir a la tablet
\copy (SELECT * FROM v_snapshot_movil) TO 'movil/servidor_snapshot.csv' CSV HEADER
