# Modelo Documental y Migración (TP 7 - Consignas 1, 2 y 3)

**Asignatura:** Bases de Datos II — Tecnicatura Universitaria en Programación  
**Proyecto:** Food Store  
**Equipo:** Máximo Franco, Andrés Novello y Octavio Fiore  
**Repositorio Relacional Central:** [https://github.com/MaxiFranco05/DB2](https://github.com/MaxiFranco05/DB2)  
**Motor Origen:** PostgreSQL 17+ | **Motor Destino:** MongoDB 7+ (`mongosh`)

---

## 1. Mapeo Relacional a Documental (Consigna 1)

En PostgreSQL, el dominio de pedidos se encuentra normalizado en 4 tablas relacionales:
* `pedido` (PK: `id`, fecha, estado, forma_pago, FK `usuario_id`)
* `detalle_pedido` (PK compuesta: `pedido_id`, `producto_id`, cantidad, precio_unitario, subtotal)
* `usuario` (PK: `id`, nombre, apellido, mail, celular, contrasena)
* `producto` (PK: `id`, nombre, descripcion, precio, stock, activo)

Para MongoDB, se diseñó la colección **`pedidos`** (en la base de datos `foodstore_nosql`) bajo un esquema de **embedding jerárquico** en 3 niveles:
1. **Campos raíz:** Metadatos transaccionales principales: `pedido_id_origen` (PK relacional conservada para trazabilidad), `fecha` (ISODate), `estado`, `forma_pago` y `total` precalculado.
2. **Objeto embebido `cliente`:** Atributos indispensables de contacto (`usuario_id_origen`, `nombre_completo` y `mail`). **Regla de seguridad:** Se excluyó tajantemente la columna `contrasena` de PostgreSQL, resguardando la privacidad y cumpliendo con el principio de mínimo privilegio.
3. **Arreglo de subdocumentos `items`:** Cada elemento almacena `producto_id_origen`, `nombre`, `cantidad`, `precio_unitario_historico` y `subtotal`.

### Esquema JSON/BSON Canónico:
```json
{
  "_id": ObjectId("..."),
  "pedido_id_origen": 756505,
  "fecha": ISODate("2026-06-08T03:00:00Z"),
  "estado": "CONFIRMADO",
  "forma_pago": "TARJETA",
  "total": 16307.74,
  "cliente": {
    "usuario_id_origen": 80584,
    "nombre_completo": "Usuario584 Apellido584",
    "mail": "usuario584@test.com"
  },
  "items": [
    {
      "producto_id_origen": 243882,
      "nombre": "Producto 43882",
      "cantidad": 2,
      "precio_unitario_historico": 3628.43,
      "subtotal": 7256.86
    },
    {
      "producto_id_origen": 236648,
      "nombre": "Producto 36648",
      "cantidad": 3,
      "precio_unitario_historico": 1552.64,
      "subtotal": 4657.92
    },
    {
      "producto_id_origen": 220320,
      "nombre": "Producto 20320",
      "cantidad": 3,
      "precio_unitario_historico": 706.00,
      "subtotal": 2118.00
    },
    {
      "producto_id_origen": 221809,
      "nombre": "Producto 21809",
      "cantidad": 4,
      "precio_unitario_historico": 568.74,
      "subtotal": 2274.96
    }
  ]
}
```

---

## 2. Migración Efectuada (Consigna 2)

Se seleccionó una muestra real de 5 pedidos de producción (`756504`, `756505`, `756506`, `756507` y `756508`), asociados al cliente `80584`. La migración se implementó mediante el script `consultas_mongodb.js` utilizando `insertMany()` de forma idempotente (con limpieza previa de la muestra) asegurando que los precios históricos queden inmutables.

---

## 3. Reglas de Integridad y Justificación de Diseño (Consigna 3)

### Reglas de Integridad Preservadas:
1. **RI-M1 (Congelamiento de precios históricos y consistencia matemática):**  
   En PostgreSQL, el trigger `trg_03_calcular_subtotal` congela el precio al momento de la inserción. En MongoDB, la migración aseguró que `precio_unitario_historico` contenga el valor histórico del pedido y no el precio vigente actual en `producto`. Asimismo, se mantiene la relación matemática:
   $$\text{subtotal} = \text{cantidad} \times \text{precio\_unitario\_historico}$$
   $$\text{total} = \sum \text{subtotal}$$
2. **RI-M2 (Atomicidad y no vaciedad de líneas):**  
   Ningún documento de pedido puede existir sin líneas asociadas ($\text{len(items)} \ge 1$). En MongoDB se persisten el pedido y sus ítems de forma atómica en un único documento.

### Justificación de Embedding frente a Referencing:
* **Principio de Localidad de Datos:** *"Data that is accessed together should be stored together"*. La lectura más frecuente en un restaurante/comercio de comidas es recuperar la comanda o el ticket completo para despacho o cliente. El embedding resuelve esto en un **único acceso a disco en $O(1)$**, eliminando los costosos `JOIN` de PostgreSQL o `$lookup` de MongoDB.
* **Inmutabilidad de la Facturación:** El precio de los productos y su denominación en el catálogo sufren variaciones con el tiempo. Si se referenciara a una colección de productos, actualizar un precio distorsionaría la contabilidad histórica de pedidos cerrados. El embedding garantiza la inmutabilidad de la fotografía de venta.
