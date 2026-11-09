# Food Store — TP N.° 8: Persistencia Móvil y Sincronización Desconectada (SQLite)

**Asignatura:** Bases de Datos II — Tecnicatura Universitaria en Programación  
**Equipo de Trabajo:** Máximo Franco, Andrés Novello y Octavio Fiore  
**Ecosistema de Repositorios:**
* Repositorio Central (PostgreSQL): [github.com/MaxiFranco05/DB2](https://github.com/MaxiFranco05/DB2)
* Repositorio NoSQL & Móvil (MongoDB & SQLite): [github.com/MaxiFranco05/DB2-NoSQL](https://github.com/MaxiFranco05/DB2-NoSQL)

---

## 1. Descripción del Problema y Arquitectura
Food Store opera puntos de venta móviles (food trucks y stands de feria) donde la conectividad a Internet no está garantizada. Para asegurar la continuidad operativa del negocio:
* La tablet opera de forma **100% autónoma y offline** utilizando **SQLite 3.37+ con modo `STRICT`**.
* Almacena una copia de catálogo local (`producto_cache`) recibida mediante una instantánea (`servidor_snapshot.csv`) generada en el servidor central (**PostgreSQL**).
* Para evitar errores de precisión de punto flotante, todos los montos monetarios se expresan en **centavos enteros (`INTEGER`)**.
* Regla de Oro de la Arquitectura: **"El móvil propone, el servidor dispone"**. Los pedidos generados offline se guardan como borradores locales (`pedido_borrador`, `item_borrador`) y se encolan para sincronización (`cola_sync`). Aunque el semáforo local marque `SIMULADO_APROBADO`, **nunca es una venta firme ni descuenta stock en PostgreSQL** hasta que la transacción se envía y confirma en el servidor.

---

## 2. Estructura de Directorios

```text
food-store/
├── movil/
│   ├── schema_sqlite.sql      # DDL estricto de SQLite (tablas producto_cache, borradores, cola_sync)
│   ├── semaforo.sql           # Algoritmo de validación local (SIMULADO_APROBADO, CONFLICTO, RECHAZADO)
│   ├── casos_simulacion.sql   # Batería de pruebas de simulación offline (C2 a C6)
│   ├── pruebas_sqlite.sql     # Pruebas de atomicidad, rollback, integridad referencial y STRICT
│   ├── servidor_snapshot.csv  # Instantánea de catálogo exportada desde PostgreSQL
│   └── foodstore_movil.db     # Base de datos SQLite compilada y poblada
├── postgresql/
│   ├── 10_snapshot_catalogo.sql  # Vista v_snapshot_movil y comando \copy a CSV
│   ├── casos_servidor.sql        # Simulación de cambios en PostgreSQL (precio prod 1 y baja prod 3)
│   └── consulta_final.sql        # Verificación de aislamiento (0 pedidos creados en central)
├── docs/
│   ├── 1a_datos_que_viajan.md    # Consigna 1.a: Matriz de datos que viajan y justificación de seguridad
│   ├── 2c_casos_y_3a_mapa.md     # Consignas 2.c y 3.a: Casos C2-C6 y Mapa de los 3 motores
│   ├── 3b_plan_mantenimiento.md  # Consigna 3.b: Plan de contingencia, RPO/RTO y resolución de conflictos
│   ├── 3c_code_review_ia.md      # Consigna 3.c: Code review asistido por OpenCode (Plan)
│   ├── DUIA.md                   # Declaración de Uso de IA con formato canónico estricto
│   └── bitacora_ia.md            # Bitácora detallada de decisiones arquitectónicas y diseño
├── evidencias/
│   ├── salida_casos_c2_c6_sqlite.txt         # Log de ejecución de casos C2 a C6 en SQLite
│   ├── salida_casos_servidor_postgresql.txt  # Log de cambios y consulta_final en PostgreSQL
│   └── salida_pruebas_sqlite.txt             # Log de pruebas de atomicidad, rollback y CASCADE
└── .kiro/specs/tp8-tablet/
    ├── requirements.md  # Especificación formal de requisitos
    ├── design.md        # Diseño arquitectónico y flujos
    └── tasks.md         # Checklist de tareas e implementación
```

---

## 3. Guía de Reproducción Paso a Paso

### Paso 1: Generar la instantánea en PostgreSQL
```bash
# Conectarse a PostgreSQL en el servidor y crear la vista de catálogo
psql -d foodstore -f postgresql/10_snapshot_catalogo.sql
```

### Paso 2: Inicializar la base SQLite en la tablet
```bash
# Crear el esquema local con modo STRICT
sqlite3 movil/foodstore_movil.db < movil/schema_sqlite.sql

# Importar el snapshot a la tabla snapshot_servidor y poblar producto_cache
sqlite3 movil/foodstore_movil.db <<EOF
.mode csv
.import movil/servidor_snapshot.csv snapshot_servidor
INSERT OR REPLACE INTO producto_cache (id, nombre, precio_centavos, stock_visto, disponible, eliminado, fecha_copia)
SELECT id, nombre, precio_centavos, stock, disponible, eliminado, datetime('now')
FROM snapshot_servidor;
EOF
```

### Paso 3: Simular eventos en el servidor central
```bash
# En PostgreSQL: actualizar precio del producto 1 y dar baja lógica al producto 3
psql -d foodstore -f postgresql/casos_servidor.sql
```

### Paso 4: Ejecutar la batería de pruebas y semáforo en SQLite
```bash
# Correr los casos de simulación C2 a C6 y evaluar estados en cola_sync
sqlite3 movil/foodstore_movil.db < movil/casos_simulacion.sql
sqlite3 movil/foodstore_movil.db < movil/semaforo.sql
```

### Paso 5: Verificar aislamiento en PostgreSQL
```bash
# Confirmar que 0 pedidos no autorizados impactaron el servidor central
psql -d foodstore -f postgresql/consulta_final.sql
```

---

## 4. Matriz de Estados del Semáforo

| Caso | Evento Simulado | Estado Inicial | Acción de Resolución | Estado Final |
| :--- | :--- | :---: | :--- | :---: |
| **C2** | Cambio de precio en servidor ($4214,51 → $4500,00) | `CONFLICTO` | Cliente acepta el nuevo importe; se actualiza borrador | `SIMULADO_APROBADO` |
| **C3** | Solicitud de 50 unidades sobre 36 en stock | `RECHAZADO` | Quiebre de stock insalvable; se avisa al cliente | `RECHAZADO` |
| **C4** | Producto 3 dado de baja lógica (`activo = false`) | `RECHAZADO` | Se conserva lápida en `producto_cache` y se oculta | `RECHAZADO` |
| **C5** | Producto sin alteraciones de precio ni stock | `SIMULADO_APROBADO` | Prefactibilidad verificada | `SIMULADO_APROBADO` |
| **C6** | Reenvío de solicitud con UUID idéntico | Error `UNIQUE` | Idempotencia garantizada por clave primaria | Protegido |
