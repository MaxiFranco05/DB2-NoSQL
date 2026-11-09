# Consigna 3.b — Plan de Mantenimiento (Integración con la Unidad 6)

**Asignatura:** Base de Datos II — Tecnicatura Universitaria en Programación  
**Proyecto:** Food Store  
**Equipo:** Máximo Franco, Andrés Novello y Octavio Fiore  

---

Como extensión directa del plan de contingencia y recuperación ante desastres de la Unidad 6 (`informe_u6.md`), se definen los tres procedimientos operativos que incorporan las tablets y el ecosistema multi-motor:

### 1. ¿Qué se respalda y cómo se prueba la restauración?
- **En el servidor (PostgreSQL y MongoDB):** Se respalda diariamente la fuente de verdad en PostgreSQL mediante `pg_dump -Fc` (`backups/foodstore_YYYYMMDD_HHMMSS.dump`) junto con el archivado continuo de WAL, y la colección documental en MongoDB mediante `mongodump`. En las tablets (SQLite), antes de cada cierre de turno o resincronización en la feria se realiza una copia consistente del archivo `movil/foodstore_movil.db` usando `.backup` (o `VACUUM INTO 'backup_tablet.db'`) para resguardar los borradores pendientes.  
- **Prueba de restauración:** Tal como se ejecutó en la Unidad 6 (RTO medido de `6,95 s`), el dump de PostgreSQL se restaura periódicamente en una base aislada de prueba (`foodstore_restore_test` con `pg_restore --no-owner --no-privileges`) y se verifica que los conteos de filas (`categoria`, `usuario`, `producto`, `pedido`, `detalle_pedido`) coincidan al 100% con `EXCEPT` (`0 filas` de diferencia) y que no existan precios ni stocks negativos.

### 2. Si se restaura un respaldo viejo de PostgreSQL, ¿qué hacen las tablets?
- Si el servidor central sufre un incidente y debe restaurarse a un punto en el tiempo anterior (perdiendo los cambios ocurridos dentro de la ventana del RPO), las tablets **descartan inmediatamente su `producto_cache` local** (ya que sus precios vistos, stocks o altas/bajas posteriores al backup restaurado quedaron desfasados respecto al estado real reconstruido en el servidor) y descargan una **nueva instantánea completa (`v_snapshot_movil` → `servidor_snapshot.csv`)**.  
- A continuación, las solicitudes de borradores que habían sido armadas o enviadas después del timestamp del backup restaurado se vuelven a contrastar con el semáforo contra la nueva instantánea del servidor para revalidar precios, disponibilidad y stock antes de intentar confirmarlas, evitando dar por sentadas ventas que el servidor restaurado no conoce.

### 3. ¿Cada cuánto y quién revisa las solicitudes en `CONFLICTO` o `RECHAZADO`?
- **En tiempo de atención en el food truck (revisión inmediata):** El **operador de la tablet (cajero/vendedor de la feria)** revisa las solicitudes en `CONFLICTO` o `RECHAZADO` **en cada reconexión o lote de sincronización** (cada 5 a 15 minutos o al recuperar señal): ante un `CONFLICTO` de precio (Caso C2), consulta al cliente en el mostrador si acepta el nuevo importe vigente para actualizar el borrador y emitir una nueva `solicitud_uuid`; ante un `RECHAZADO` por falta de stock (C3) o baja lógica (C4), ofrece un producto alternativo o cancela el borrador.  
- **Al cierre de la jornada (auditoría operativa):** El **administrador de datos (`admin_datos` / supervisor de turno)** revisa al finalizar cada día de feria el listado consolidado de filas en `cola_sync` que quedaron en `CONFLICTO` o `RECHAZADO` sin resolver, con el fin de detectar productos con quiebres recurrentes de stock o desfasajes frecuentes de precios antes de abrir la jornada siguiente.
