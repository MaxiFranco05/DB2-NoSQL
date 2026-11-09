/**
 * prueba_indice_unico_ia.js
 * 
 * Asignatura: Bases de Datos II - Tecnicatura Universitaria en Programación
 * Proyecto: Food Store - Unidad 7 (Consigna 7: Prueba de laboratorio sobre recomendación de IA)
 * Equipo: Máximo Franco, Andrés Novello y Octavio Fiore
 * Motor: MongoDB 7+ (mongosh)
 * 
 * Objetivo: Evaluar empíricamente la propuesta del Code Review de IA que sugería
 *           crear un índice único sobre 'pedido_id_origen' para asegurar la integridad
 *           referencial del identificador relacional y un índice sobre 'estado' para Q-M2.
 */

db = db.getSiblingDB("foodstore_nosql");

print("\n==========================================================================");
print("  LABORATORIO IA: EVALUACIÓN DE ÍNDICE ÚNICO E ÍNDICES SECUNDARIOS");
print("==========================================================================\n");

// 1. Crear índice único sobre pedido_id_origen para evitar duplicados en la migración
print("1. Creando índice único sobre 'pedido_id_origen'...");
const resIndiceUnico = db.pedidos.createIndex({ pedido_id_origen: 1 }, { unique: true });
print("Resultado:", JSON.stringify(resIndiceUnico));

// 2. Crear índice sobre 'estado' para acelerar filtros de despacho (Q-M2)
print("\n2. Creando índice secundario sobre 'estado'...");
const resIndiceEstado = db.pedidos.createIndex({ estado: 1 });
print("Resultado:", JSON.stringify(resIndiceEstado));

// 3. Crear índice multikey sobre 'items.producto_id_origen' para acelerar Q-M3
print("\n3. Creando índice multikey sobre 'items.producto_id_origen'...");
const resIndiceItems = db.pedidos.createIndex({ "items.producto_id_origen": 1 });
print("Resultado:", JSON.stringify(resIndiceItems));

// 4. Listar los índices generados en la colección
print("\n4. Índices activos en la colección 'pedidos':");
const indices = db.pedidos.getIndexes();
printjson(indices);

// 5. Prueba de laboratorio: Intentar insertar un documento con pedido_id_origen duplicado
print("\n5. Prueba de rechazo de duplicado (Índice Único)...");
try {
  db.pedidos.insertOne({
    pedido_id_origen: 756505, // Ya existe en la muestra
    fecha: new Date(),
    estado: "PENDIENTE",
    total: 1000.00,
    items: []
  });
  print("❌ Error: Se permitió insertar un pedido_id_origen duplicado.");
} catch (error) {
  print("✅ Rechazo verificado con éxito (E11000 duplicate key error):");
  print(`   Código de error: ${error.code} - ${error.message.split("dup key")[0]}`);
}

print("\n==========================================================================");
print("  FIN DE PRUEBA DE LABORATORIO");
print("==========================================================================\n");
