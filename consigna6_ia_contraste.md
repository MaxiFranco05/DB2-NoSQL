# Evaluación de Tecnología e IA (TP 7 - Consignas 6 y 7)

**Asignatura:** Bases de Datos II — Tecnicatura Universitaria en Programación  
**Proyecto:** Food Store  
**Equipo:** Máximo Franco, Andrés Novello y Octavio Fiore  
**Repositorio Relacional Central:** [https://github.com/MaxiFranco05/DB2](https://github.com/MaxiFranco05/DB2)

---

## 1. Prompt Formulado para la Comparativa de IA (Consigna 6)

> *"Compara técnicamente PostgreSQL y MongoDB para el almacenamiento y consulta de pedidos en una aplicación gastronómica (Food Store). Considera que el modelo relacional actual utiliza 4 tablas (pedido, detalle_pedido, usuario, producto), que el acceso más frecuente es la recuperación de pedidos completos para despacho y auditoría, y que es imperativo conservar la coherencia transaccional de cantidades y precios históricos."*

---

## 2. Contraste de Afirmaciones Técnicas de la IA (Consigna 7)

### Afirmación 1 de la IA:
> *"MongoDB no soporta transacciones ACID y no garantiza consistencia en operaciones multi-documento."*

* **Contraste con Documentación Oficial:** **Falsa / Desactualizada.** La [documentación oficial de MongoDB (Multi-Document Transactions)](https://www.mongodb.com/docs/manual/core/transactions/) documenta soporte completo para transacciones ACID multi-documento desde la versión 4.0/4.2 mediante `session.startTransaction()`.
* **Laboratorio / Análisis Crítico:** Si bien el soporte técnico existe, las transacciones multi-documento en bases distribuidas introducen mayor sobrecarga y latencia. En nuestro caso de Food Store demostramos que el **embedding** hace innecesarias las transacciones multi-documento para la gestión de pedidos, puesto que la orden y todas sus líneas se crean, actualizan y leen de forma atómica a nivel de un **único documento**.

---

### Afirmación 2 de la IA:
> *"El embedding duplica datos innecesariamente y desperdicia almacenamiento frente a tablas normalizadas."*

* **Contraste con Documentación Oficial:** **Conceptualmente errónea.** La [guía oficial de diseño de datos de MongoDB (Embedded Data Models)](https://www.mongodb.com/docs/manual/core/data-model-design/#embedded-data-models) prescribe el embedding para entidades con fuerte cohesión semántica y relaciones "uno a pocos".
* **Laboratorio / Análisis Crítico:** La IA confunde redundancia inútil con **inmutabilidad histórica**. Guardar el nombre y el precio unitario dentro del pedido no es un desperdicio: es un requerimiento contable crítico. Si el producto `243882` cambia de precio mañana en el catálogo, el pedido cerrado hoy debe conservar los \$3.628,43 facturados. El embedding garantiza el aislamiento del histórico frente a mutaciones futuras en el catálogo maestro.

---

## 3. Conclusión Técnica Final (Consigna 7 — Límite: 200 palabras)

La evaluación comparativa entre PostgreSQL y MongoDB para el subconjunto de pedidos de Food Store demostró que la elección del motor debe fundamentarse en el patrón de acceso y los requisitos de consistencia, descartando dogmas tecnológicos.

Para la gestión operativa de pedidos completos, **MongoDB con modelo embebido presenta ventajas técnicas determinantes**: al almacenar cliente, líneas y totales en un único documento, elimina los costosos `JOIN` relacionales, resolviendo las consultas de despacho y lectura de tickets con lecturas atómicas de disco en complejidad $O(1)$.

Sin embargo, para la gestión del catálogo maestro, inventario concorrente de stock y la contabilidad global, **PostgreSQL resulta insustituible** gracias a su motor relacional ACID estricto, triggers automáticos y constraints declarativos que impiden sobreventas o anomalías lógicas.

Por lo tanto, la solución arquitectónica óptima para Food Store es un esquema de **persistencia políglota**: mantener a PostgreSQL como la fuente de la verdad (*Source of Truth*) transaccional para usuarios, productos y stock, y replicar o sincronizar asincrónicamente los pedidos finalizados hacia MongoDB para alimentar de forma ultra-rápida y escalable los paneles de despacho, consultas de clientes e histórico de compras.
*(169 palabras)*
