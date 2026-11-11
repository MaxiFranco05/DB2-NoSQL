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

## 🎤 Guión de Defensa Oral (Presentación ante la Cátedra)

| Rol / Integrante | Eje Temático a Defender | Conceptos Clave y Respuestas a Preguntas Típicas |
| :--- | :--- | :--- |
| **Máximo Franco** | **Arquitectura Global y Ecosistema Multi-Motor** | • Explica la coexistencia de los tres motores y la separación de responsabilidades.<br>• Defiende la regla de oro: *"El móvil propone, el servidor dispone"*.<br>• Justifica la refactorización a FNBC en logística (U4) para eliminar anomalías de actualización de responsables de depósito, y la desnormalización controlada con triggers. |
| **Andrés Novello** | **Seguridad, Mantenimiento y Recuperación ante Desastres** | • Defiende el esquema RBAC de 6 roles bajo mínimo privilegio (U5) y cómo se contuvo el simulacro de acceso indebido de `app_web` (`GRANT` y `DROP TABLE` denegados).<br>• Expone el simulacro de desastre (U6): **RTO medido de 6,95 segundos** (frente a SLA < 300 s) y RPO de 332 s con 100% de paridad.<br>• Explica por qué se descartó `VACUUM FULL` (bloqueo exclusivo) en favor de `VACUUM ANALYZE`. |
| **Octavio Fiore** | **Persistencia Móvil (SQLite) y Almacén NoSQL (MongoDB)** | • Demuestra la base de la tablet (U8): modo `STRICT`, dinero en centavos enteros (`INTEGER`) para evitar redondeos IEEE 754, y el snapshot con `fecha_copia`.<br>• Explica el orden del semáforo: **Rechazo (stock/baja lógica) > Conflicto de precio (C2) > Aprobado**.<br>• Defiende el modelo documental en MongoDB (U7): importes en `Decimal128` (`NumberDecimal`), validador `$jsonSchema` e inmutabilidad de precios embebidos. |

---

## 🛠️ Guía de Reproducción de la Tablet desde Cero (Paso a Paso)

```bash
# 1. Exportar la instantánea desde PostgreSQL con fecha_copia
psql -d foodstore -f food-store/postgresql/10_snapshot_catalogo.sql

# 2. Inicializar la base SQLite en modo STRICT con sus 5 tablas
sqlite3 food-store/movil/foodstore_movil.db < food-store/movil/schema_sqlite.sql

# 3. Importar el CSV hacia snapshot_servidor y poblar producto_cache
sqlite3 food-store/movil/foodstore_movil.db <<EOF
.mode csv
.import food-store/movil/servidor_snapshot.csv snapshot_servidor
EOF
sqlite3 food-store/movil/foodstore_movil.db < food-store/movil/import_snapshot.sql

# 4. Ejecutar la batería de simulación completa (C2 a C6) de forma 100% automatizada
sqlite3 food-store/movil/foodstore_movil.db < food-store/movil/casos_simulacion.sql

# 5. Comprobar el aislamiento en PostgreSQL (0 pedidos nuevos creados en central)
psql -d foodstore -f food-store/postgresql/consulta_final.sql
```

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
├── consultas_mongodb.js             # Consignas 4 y 5: Script con Decimal128, validador $jsonSchema y Q-M1 a Q-M4
├── consultas_postgresql.sql         # Consigna 5: Consultas equivalentes en PostgreSQL (Q-PG1 y Q-PG2)
├── prueba_indice_unico_ia.js        # Consigna 7: Prueba de laboratorio sobre recomendación de índice único
├── evidencias/
│   ├── salida_migracion_mongodb.txt     # Salida real con Decimal128 y validador
│   ├── salida_consultas_postgresql.txt  # Salida real de psql ejecutando consultas_postgresql.sql
│   └── salida_prueba_indice_unico_ia.txt# Salida real del test de índice único y rechazo de duplicado
└── food-store/                      # UNIDAD 8: Persistencia móvil desconectada (SQLite)
    ├── README.md                    # Documentación y guía de reproducción de la Unidad 8
    ├── movil/                       # DDL SQLite STRICT, semáforo, casos, importación y base de datos
    ├── postgresql/                  # Vista con fecha_copia, casos_servidor y consulta_final
    ├── docs/                        # Consignas 1a, 2c, 3a, 3b, 3c (code review con comprobaciones), DUIA y Bitácora
    ├── evidencias/                  # Logs reales de ejecución en SQLite y PostgreSQL
    └── .kiro/                       # Especificaciones SDD alineadas a centavos y prioridades
```
