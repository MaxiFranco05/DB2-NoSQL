| **Campo** | **Completar** |
| :--- | :--- |
| **Herramienta** | Kiro (SDD) & Antigravity |
| **Spec o prompt utilizado** | `.kiro/specs/tp8-tablet/requirements.md` y `design.md`: *"Diseñar el esquema local SQLite con modo STRICT, tablas producto_cache, snapshot_servidor, pedido_borrador, item_borrador y cola_sync para funcionamiento offline."* |
| **Qué generó** | Script DDL `schema_sqlite.sql` con tablas estructuradas bajo tipos canónicos INTEGER/TEXT, claves primarias compuestas y precios en centavos enteros para evitar imprecisiones de punto flotante. |
| **Qué se aceptó** | 100% de la arquitectura relacional y el uso de tipos en centavos enteros (`precio_centavos`). |
| **Qué se modificó o descartó, y por qué** | Se descartó almacenar montos en formato REAL / FLOAT por riesgo de truncamiento de decimales en cálculos financieros; se forzó el uso estricto de INTEGER para centavos. |
| **Verificación realizada** | ✅ Creación exitosa en SQLite 3.37+ con `PRAGMA foreign_keys = ON;`.<br>✅ Validación de tipos con `INSERT` invistiendo tipos erróneos, arrojando excepción esperada de restricción de tipo `STRICT`. |

| **Campo** | **Completar** |
| :--- | :--- |
| **Herramienta** | Antigravity |
| **Spec o prompt utilizado** | `.kiro/specs/tp8-tablet/tasks.md`: *"Implementar semaforo.sql para contrastar cola_sync contra snapshot_servidor y clasificar en SIMULADO_APROBADO, CONFLICTO o RECHAZADO de forma idempotente."* |
| **Qué generó** | Script transaccional `semaforo.sql` con resolución de estados mediante `UPDATE cola_sync` condicional evaluando disponibilidad, stock y precio. |
| **Qué se aceptó** | 95% de la lógica de evaluación y el aislamiento por lote de sincronización. |
| **Qué se modificó o descartó, y por qué** | 1. Se modificó la regla de cambio de precio para clasificar en `CONFLICTO` (amarillo) en lugar de rechazarlo de plano, permitiendo al operador renegociar con el cliente.<br>2. Se acotó la ejecución a `WHERE estado = 'PENDIENTE'` para asegurar idempotencia total ante reintentos. |
| **Verificación realizada** | ✅ Pruebas automatizadas en `pruebas_sqlite.sql` verificando que C2 clasifique en CONFLICTO, C3 en RECHAZADO, C4 en RECHAZADO y C5 en SIMULADO_APROBADO.<br>✅ Verificación en PostgreSQL mediante `consulta_final.sql`: 0 pedidos insertados y 0 alteraciones de stock en la base central (aislamiento total "móvil propone, servidor dispone"). |

| **Campo** | **Completar** |
| :--- | :--- |
| **Herramienta** | OpenCode (Agente: Plan) |
| **Spec o prompt utilizado** | Consigna 3.c: *"Auditoría integral y code review de scripts de PostgreSQL, MongoDB y SQLite."* |
| **Qué generó** | Matriz de 3 hallazgos técnicos (roles con contraseñas en texto plano, validación de esquemas en MongoDB, y carrera de stock en PostgreSQL). |
| **Qué se aceptó** | 66% de las propuestas (aceptados roles seguros y esquema de MongoDB; descartado el trigger de actualización de stock). |
| **Qué se modificó o descartó, y por qué** | Se descartó modificar el trigger de stock en PostgreSQL para no alterar la compatibilidad con los scripts de carga masiva de la cátedra ni falsear mediciones de benchmark. |
| **Verificación realizada** | ✅ Revisión metodológica del informe de code review y validación cruzada con la rúbrica de la cátedra. |
