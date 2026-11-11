# Food Store — TP N.° 8: Persistencia Móvil y Sincronización Desconectada (SQLite)

**Asignatura:** Bases de Datos II — Tecnicatura Universitaria en Programación  
**Comisión:** C3 · Prof. Sergio Neira  
**Equipo de Trabajo:** Máximo Franco, Andrés Novello y Octavio Fiore  
**Ecosistema de Repositorios:**
* Repositorio Central (PostgreSQL): [github.com/MaxiFranco05/DB2](https://github.com/MaxiFranco05/DB2)
* Repositorio NoSQL & Móvil (MongoDB & SQLite): [github.com/MaxiFranco05/DB2-NoSQL](https://github.com/MaxiFranco05/DB2-NoSQL)

---

## 1. Descripción del Problema y Arquitectura
Food Store opera puntos de venta móviles (food trucks y stands de feria) donde la conectividad a Internet no está garantizada. Para asegurar la continuidad operativa del negocio:
* La tablet opera de forma **100% autónoma y offline** utilizando **SQLite 3.37+ con modo `STRICT`**.
* Almacena una copia de catálogo local (`producto_cache`) recibida mediante una instantánea (`servidor_snapshot.csv`) con marca temporal (`fecha_copia`) generada en el servidor central (**PostgreSQL**).
* Para evitar errores de precisión de punto flotante, todos los montos monetarios se expresan en **centavos enteros (`INTEGER`)**.
* Regla de Oro de la Arquitectura: **"El móvil propone, el servidor dispone"**. Los pedidos generados offline se guardan como borradores locales (`pedido_borrador`, `item_borrador`) y se encolan para sincronización (`cola_sync`). Aunque el semáforo local marque `SIMULADO_APROBADO`, **nunca es una venta firme ni descuenta stock en PostgreSQL** hasta que la transacción se envía y confirma en el servidor.

---

## 2. Guía de Reproducción Paso a Paso desde Cero

Para reproducir la base de la tablet y la simulación completa sin ambigüedades:

```bash
# Paso 1: Generar la instantánea en PostgreSQL con fecha_copia
psql -d foodstore -f postgresql/10_snapshot_catalogo.sql

# Paso 2: Inicializar el esquema SQLite en modo STRICT con 5 tablas
sqlite3 movil/foodstore_movil.db < movil/schema_sqlite.sql

# Paso 3: Importar el CSV hacia snapshot_servidor y poblar producto_cache
sqlite3 movil/foodstore_movil.db <<EOF
.mode csv
.import movil/servidor_snapshot.csv snapshot_servidor
EOF
sqlite3 movil/foodstore_movil.db < movil/import_snapshot.sql

# Paso 4: Simular eventos en PostgreSQL (actualizar precio prod 1 a $4500 y desactivar prod 3)
psql -d foodstore -f postgresql/casos_servidor.sql

# Paso 5: Correr la batería de simulación completa (C2 a C6) de forma 100% automatizada
sqlite3 movil/foodstore_movil.db < movil/casos_simulacion.sql

# Paso 6: Verificar aislamiento en PostgreSQL (0 pedidos creados en central)
psql -d foodstore -f postgresql/consulta_final.sql
```

---

## 3. Matriz de Estados del Semáforo

| Caso | Evento Simulado | Estado Inicial | Acción de Resolución | Estado Final |
| :--- | :--- | :---: | :--- | :---: |
| **C2** | Cambio de precio en servidor ($4214,51 → $4500,00) | `CONFLICTO` | Cliente acepta el nuevo importe; se actualiza borrador y encola req-uuid-c2-0002 | `SIMULADO_APROBADO` |
| **C3** | Solicitud de 50 unidades sobre 36 en stock | `RECHAZADO` | Quiebre de stock insalvable; se avisa al cliente | `RECHAZADO` |
| **C4** | Producto 3 dado de baja lógica (`activo = false`) | `RECHAZADO` | Se conserva lápida en `producto_cache` (`disponible = 0`, `eliminado = 1`) | `RECHAZADO` |
| **C5** | Producto sin alteraciones de precio ni stock | `SIMULADO_APROBADO` | Prefactibilidad verificada | `SIMULADO_APROBADO` |
| **C6** | Reenvío de solicitud con UUID idéntico | Error `UNIQUE` | Idempotencia garantizada por clave primaria | Protegido |

---

## 4. Guión de Defensa Oral

* **Máximo Franco:** Arquitectura general, separación de responsabilidades y la regla de oro: *"el móvil propone, el servidor dispone"*.
* **Andrés Novello:** Seguridad, roles de mínimo privilegio, plan de mantenimiento y tiempo de recuperación ante desastres (RTO: 6,95 s).
* **Octavio Fiore:** Implementación de la tablet: modo `STRICT`, centavos enteros, semáforo jerárquico (Rechazo > Conflicto > Aprobado) y deduplicación por UUID.
