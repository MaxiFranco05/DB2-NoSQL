# Food Store — Repositorio NoSQL y Persistencia Móvil (TP 7 y TP 8)

**Asignatura:** Bases de Datos II — Tecnicatura Universitaria en Programación  
**Proyecto:** Food Store  
**Comisión:** C3 · **Docente:** Prof. Sergio Neira  
**Equipo de Trabajo:**
* **Máximo Franco**
* **Andrés Novello**
* **Octavio Fiore**

---

## 📑 Informe Técnico Integrador — Segunda Entrega (Unidades 4 a 8)

El informe técnico unificado que acredita el cumplimiento de los **14 objetivos** de la entrega integrando la capa relacional, documental y móvil se encuentra disponible en:
* 📄 **Versión PDF:** [`informe_tecnico_segunda_entrega.pdf`](informe_tecnico_segunda_entrega.pdf)
* 📝 **Versión Markdown:** [`informe_tecnico_segunda_entrega.md`](informe_tecnico_segunda_entrega.md)

---

## 🔗 Ecosistema de Repositorios

* 🏛️ **Repositorio Principal (PostgreSQL / Relacional - Unidades 1 a 6):**  
  [https://github.com/MaxiFranco05/DB2](https://github.com/MaxiFranco05/DB2)  
  *Contiene el esquema canónico relacional, roles, índices, particionamiento, concurrencia, vistas materializadas, backups y auditoría.*

* 🍃📱 **Repositorio NoSQL & Móvil (MongoDB & SQLite - Unidades 7 y 8):**  
  [https://github.com/MaxiFranco05/DB2-NoSQL](https://github.com/MaxiFranco05/DB2-NoSQL)  
  *Contiene la migración documental a MongoDB (TP 7) y la capa móvil desconectada con SQLite (TP 8).*

---

## 📁 Estructura del Repositorio

```text
DB2-NoSQL/
├── informe_tecnico_segunda_entrega.pdf # Informe técnico integrador oficial (Unidades 4 a 8)
├── informe_u7.pdf                   # Informe ejecutivo completo de la Unidad 7 compilado en PDF
├── modelo_documental.md             # Consignas 1, 2 y 3: Justificación de embedding vs referencing y esquema BSON
├── consigna5_tabla_comparativa.md   # Consigna 5: Tabla comparativa de paridad PostgreSQL vs MongoDB
├── consigna6_ia_contraste.md        # Consignas 6 y 7: Code review con IA y conclusión de 169 palabras
├── consultas_mongodb.js             # Consignas 4 y 5: Script en mongosh con carga de 5 pedidos y consultas Q-M1 a Q-M4
├── consultas_postgresql.sql         # Consigna 5: Consultas equivalentes en PostgreSQL (Q-PG1 y Q-PG2)
├── prueba_indice_unico_ia.js        # Consigna 7: Prueba de laboratorio sobre recomendación de índice único
├── evidencias/
│   ├── salida_migracion_mongodb.txt     # Salida real de mongosh ejecutando consultas_mongodb.js
│   ├── salida_consultas_postgresql.txt  # Salida real de psql ejecutando consultas_postgresql.sql
│   └── salida_prueba_indice_unico_ia.txt# Salida real del test de índice único y rechazo de duplicado
└── food-store/                      # UNIDAD 8: Persistencia móvil desconectada (SQLite)
    ├── README.md                    # Documentación y guía de reproducción de la Unidad 8
    ├── movil/                       # DDL SQLite STRICT, semáforo, casos y base de datos
    ├── postgresql/                  # Vista de instantánea v_snapshot_movil y casos de servidor
    ├── docs/                        # Consignas 1a, 2c, 3a, 3b, 3c, DUIA y Bitácora
    ├── evidencias/                  # Logs de ejecución en SQLite y PostgreSQL
    └── .kiro/                       # Especificaciones SDD (requirements, design, tasks)
```

---

## 🍃 Unidad 7: NoSQL y Nuevas Formas de Almacenamiento (MongoDB)

### 1. Resumen Técnico
Se migró un subconjunto representativo de 5 pedidos operacionales (`756504` a `756508`) del cliente `80584` desde **PostgreSQL 17** hacia **MongoDB 7+**.
* **Estrategia de Modelado:** Se implementó un esquema **híbrido centrado en el pedido**. Las líneas de detalle (`items`) y los datos de contacto del cliente se embeben directamente en el documento para garantizar lecturas en una sola operación atómica sin `JOIN`.
* **Inmutabilidad y Auditoría:** Los precios unitarios históricos (`precio_unitario_historico`) quedan congelados en el array embebido, preservando la exactitud contable sin depender de mutaciones futuras en el catálogo.

### 2. Ejecución y Reproducción en MongoDB
```bash
# 1. Ejecutar migración y consultas documentales (Q-M1 a Q-M4)
mongosh foodstore_nosql consultas_mongodb.js

# 2. Ejecutar consultas relacionales equivalentes en PostgreSQL (Q-PG1 y Q-PG2)
psql -d foodstore -f consultas_postgresql.sql

# 3. Ejecutar prueba de laboratorio de índice único sugerido por IA
mongosh foodstore_nosql prueba_indice_unico_ia.js
```

---

## 📱 Unidad 8: Persistencia Móvil y Sincronización Desconectada (SQLite)

La carpeta [`food-store/`](food-store/) contiene la solución completa de persistencia desconectada para food trucks y ferias:
* **SQLite en modo `STRICT`** y dinero almacenado en **centavos enteros (`INTEGER`)**.
* Algoritmo de resolución local (**Semáforo**) que clasifica borradores en `SIMULADO_APROBADO`, `CONFLICTO` o `RECHAZADO`.
* Aislamiento estricto bajo el principio **"El móvil propone, el servidor dispone"** (0 ventas o alteraciones de inventario en PostgreSQL sin sincronización formal previa).

Para más detalles e instrucciones de ejecución, consulte el [README de la Unidad 8](food-store/README.md).
