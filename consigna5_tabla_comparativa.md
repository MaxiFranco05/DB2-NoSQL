# Tabla Comparativa de Verificación (TP 7 - Consigna 5)

**Asignatura:** Bases de Datos II — Tecnicatura Universitaria en Programación  
**Proyecto:** Food Store  
**Equipo:** Máximo Franco, Andrés Novello y Octavio Fiore  
**Repositorio Relacional Central:** [https://github.com/MaxiFranco05/DB2](https://github.com/MaxiFranco05/DB2)

---

## 1. Consultas Equivalentes Contrastadas

* **Filtro por Estado (`CONFIRMADO`):**
  * **MongoDB (Q-M2):** `db.pedidos.find({ estado: "CONFIRMADO" }, { pedido_id_origen: 1, estado: 1, fecha: 1, total: 1, _id: 0 });`
  * **PostgreSQL (Q-PG1):** `SELECT p.id, p.estado, p.fecha, SUM(dp.subtotal) AS total FROM pedido p JOIN detalle_pedido dp ON dp.pedido_id = p.id WHERE p.id IN (756504, 756505, 756506, 756507, 756508) AND p.estado = 'CONFIRMADO' GROUP BY p.id, p.estado, p.fecha ORDER BY p.id;`

* **Filtro por Producto Embebido (`producto_id_origen = 243882`):**
  * **MongoDB (Q-M3):** `db.pedidos.find({ "items.producto_id_origen": 243882 }, { pedido_id_origen: 1, estado: 1, "items.$": 1, _id: 0 });`
  * **PostgreSQL (Q-PG2):** `SELECT DISTINCT p.id, p.estado, dp.producto_id, dp.cantidad, dp.precio_unitario, dp.subtotal FROM pedido p JOIN detalle_pedido dp ON dp.pedido_id = p.id WHERE p.id IN (756504, 756505, 756506, 756507, 756508) AND dp.producto_id = 243882 ORDER BY p.id;`

---

## 2. Tabla Comparativa Oficial

| Consulta | Cantidad en PostgreSQL | Cantidad en MongoDB | ¿Coinciden los IDs? | Identificadores de Pedidos Recuperados |
| :--- | :---: | :---: | :---: | :--- |
| **Estado seleccionado (`CONFIRMADO`)** | **2** | **2** | **Sí ✅** | `[756505, 756508]` |
| **Producto seleccionado (`243882`)** | **4** | **4** | **Sí ✅** | `[756505, 756506, 756507, 756508]` |

---

## 3. Análisis de Paridad y Validación Empírica

* **Cardinalidad e Identificadores:** La prueba de diferencia simétrica de conjuntos (`EXCEPT` bidireccional) arrojó **0 filas de discrepancia**. Ambos motores recuperan exactamente los mismos conjuntos de órdenes de compra.
* **Integridad de Precios:** El precio unitario histórico para el producto `243882` en PostgreSQL (`$3628.43`) es exactamente idéntico al persistido en los subdocumentos de MongoDB.
