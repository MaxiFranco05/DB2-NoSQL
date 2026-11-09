# Bitácora de Desarrollo con IA — TP Unidad 8 (Food Store Móvil Offline)

**Asignatura:** Base de Datos II — Tecnicatura Universitaria en Programación  
**Proyecto:** Food Store  
**Equipo:** Máximo Franco, Andrés Novello y Octavio Fiore  
**Ecosistema:** PostgreSQL (Servidor) | MongoDB (Documental) | SQLite (Tablet Offline)  

---

## 1. Contexto y Objetivos del TP 8
El objetivo central de la Unidad 8 consiste en dotar a *Food Store* de una arquitectura de persistencia desconectada para puntos de venta móviles (food trucks y ferias al aire libre sin conexión garantizada).
Para ello, se diseñó e implementó:
- Esquema local en SQLite con modo `STRICT` y almacenamiento de dinero en centavos enteros (`INTEGER`).
- Mecanismo de instantánea de catálogo (`v_snapshot_movil` en PostgreSQL -> `servidor_snapshot.csv` -> `snapshot_servidor` en SQLite).
- Lógica de sincronización offline con semáforo (`semaforo.sql`): `SIMULADO_APROBADO`, `CONFLICTO` y `RECHAZADO`.
- Principio rector: **"El móvil propone, el servidor dispone"** (la tablet nunca inserta pedidos en PostgreSQL ni descuenta stock directamente).

---

## 2. Decisiones Técnicas Clave
1. **Modo STRICT en SQLite:** Se adoptó la sintaxis estricta de SQLite 3.37+ para evitar que la flexibilidad de tipos nativa de SQLite inserte cadenas de texto en columnas numéricas o desvirtúe los cálculos de precios.
2. **Precios en Centavos Enteros:** Se multiplicaron todos los precios por 100 (`ROUND(precio * 100)::INTEGER`) para trabajar con aritmética entera exacta, eliminando inconsistencias por redondeo IEEE 754 de punto flotante.
3. **Idempotencia de Sincronización:** Cada intento de transmisión utiliza un UUID único (`solicitud_uuid TEXT PRIMARY KEY`). Si la red se cae y el móvil reintenta, el servidor detecta la clave única y no re-procesa la venta.
4. **Manejo de Bajas Lógicas (Lápidas):** Al eliminarse un producto en el servidor (`activo = false`), la tablet no elimina la fila física de `producto_cache` para no romper las claves foráneas de borradores previos, sino que marca `eliminado = 1` y `disponible = 0`.

---

## 3. Resumen de Ejecución de Casos de Simulación
- **C1 (Consulta de Catálogo):** Muestra únicamente productos con `disponible = 1`, `eliminado = 0` y `stock > 0`.
- **C2 (Cambio de Precio):** Detecta desfasaje de precio respecto al visto en la feria (`CONFLICTO`). Al actualizarse con el consentimiento del cliente, pasa a `SIMULADO_APROBADO`.
- **C3 (Quiebre de Stock):** Borrador por 50 unidades sobre 36 disponibles -> `RECHAZADO`.
- **C4 (Producto Inactivo):** Producto 3 dado de baja lógica en el servidor -> `RECHAZADO`.
- **C5 (Sin Cambios):** Coincidencia de precio, stock y estado -> `SIMULADO_APROBADO`.
- **C6 (Reintento con Mismo UUID):** Dispara `UNIQUE constraint failed`, protegiendo al sistema contra doble facturación.

---

## 4. Auditoría y Code Review con IA
Conforme al protocolo de la cátedra, se utilizó OpenCode (Agente Plan) para auditar los scripts del proyecto (PostgreSQL, MongoDB y SQLite). Los hallazgos y decisiones se documentaron en `docs/3c_code_review_ia.md` y en la DUIA oficial.
