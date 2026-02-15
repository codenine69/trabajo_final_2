import 'package:cloud_firestore/cloud_firestore.dart';

/// Script para poblar Firestore con datos iniciales de PNP y Ejército
class DatosSemilla {
  final FirebaseFirestore _firestore;

  DatosSemilla({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Ejecuta la carga de todos los datos semilla
  Future<void> ejecutar() async {
    await _crearProcesoPNP2026();
    await _crearProcesoEjercito2026();
    print('✅ Datos semilla cargados correctamente');
  }

  /// Crea el proceso de Admisión PNP 2026
  Future<void> _crearProcesoPNP2026() async {
    final procesoRef = await _firestore.collection('training_processes').add({
      'institution': 'PNP',
      'name': 'Admisión EESTP PNP 2026',
      'target_type': 'POSTULANTE',
      'target_subtype': null,
    });

    // Ejercicio: 1000m Planos
    await procesoRef.collection('exercises').add({
      'name': '1000m Planos',
      'unit': 'SECONDS',
      'goal': 'MIN',
      'scoring_table_male': [
        {'min': 0, 'max': 208, 'score': 20.0},
        {'min': 209, 'max': 211, 'score': 19.0},
        {'min': 212, 'max': 214, 'score': 18.0},
        {'min': 215, 'max': 217, 'score': 17.0},
        {'min': 218, 'max': 220, 'score': 16.0},
        {'min': 221, 'max': 223, 'score': 15.0},
        {'min': 224, 'max': 226, 'score': 14.0},
        {'min': 227, 'max': 229, 'score': 13.0},
        {'min': 230, 'max': 232, 'score': 12.0},
        {'min': 233, 'max': 235, 'score': 11.0},
      ],
      'scoring_table_female': [
        {'min': 0, 'max': 246, 'score': 20.0},
        {'min': 247, 'max': 249, 'score': 19.0},
        {'min': 250, 'max': 252, 'score': 18.0},
        {'min': 253, 'max': 255, 'score': 17.0},
        {'min': 256, 'max': 258, 'score': 16.0},
        {'min': 259, 'max': 261, 'score': 15.0},
        {'min': 262, 'max': 264, 'score': 14.0},
        {'min': 265, 'max': 267, 'score': 13.0},
        {'min': 268, 'max': 270, 'score': 12.0},
        {'min': 271, 'max': 273, 'score': 11.0},
      ],
    });

    print('✅ Proceso PNP 2026 creado con ID: ${procesoRef.id}');
  }

  /// Crea el proceso de Admisión Ejército 2026
  Future<void> _crearProcesoEjercito2026() async {
    final procesoRef = await _firestore.collection('training_processes').add({
      'institution': 'ARMY',
      'name': 'Admisión Ejército del Perú 2026',
      'target_type': 'POSTULANTE',
      'target_subtype': null,
    });

    // Ejercicio: 1500m Carrera
    await procesoRef.collection('exercises').add({
      'name': '1500m Carrera',
      'unit': 'SECONDS',
      'goal': 'MIN',
      'scoring_table_male': [
        {'min': 0, 'max': 290, 'score': 20.0},
        {'min': 291, 'max': 296, 'score': 19.8},
        {'min': 297, 'max': 302, 'score': 19.6},
        {'min': 303, 'max': 308, 'score': 19.4},
        {'min': 309, 'max': 314, 'score': 19.2},
        {'min': 315, 'max': 320, 'score': 19.0},
        {'min': 321, 'max': 326, 'score': 18.8},
        {'min': 327, 'max': 332, 'score': 18.6},
        {'min': 333, 'max': 338, 'score': 18.4},
        {'min': 339, 'max': 344, 'score': 18.2},
        {'min': 345, 'max': 350, 'score': 18.0},
        {'min': 351, 'max': 354, 'score': 17.0},
        {'min': 355, 'max': 357, 'score': 16.0},
        {'min': 358, 'max': 359, 'score': 14.0},
        {'min': 360, 'max': 360, 'score': 12.0},
      ],
      'scoring_table_female': [
        {'min': 0, 'max': 360, 'score': 20.0},
        {'min': 361, 'max': 366, 'score': 19.8},
        {'min': 367, 'max': 372, 'score': 19.6},
        {'min': 373, 'max': 378, 'score': 19.4},
        {'min': 379, 'max': 384, 'score': 19.2},
        {'min': 385, 'max': 390, 'score': 19.0},
        {'min': 391, 'max': 396, 'score': 18.8},
        {'min': 397, 'max': 402, 'score': 18.6},
        {'min': 403, 'max': 408, 'score': 18.4},
        {'min': 409, 'max': 414, 'score': 18.2},
        {'min': 415, 'max': 420, 'score': 18.0},
        {'min': 421, 'max': 426, 'score': 16.0},
        {'min': 427, 'max': 432, 'score': 14.0},
        {'min': 433, 'max': 438, 'score': 12.0},
      ],
    });

    print('✅ Proceso Ejército 2026 creado con ID: ${procesoRef.id}');
  }

  /// Limpia todos los datos de prueba (útil para desarrollo)
  Future<void> limpiarDatos() async {
    final batch = _firestore.batch();

    // Eliminar procesos
    final procesos = await _firestore.collection('training_processes').get();
    for (var doc in procesos.docs) {
      // Eliminar ejercicios de cada proceso
      final ejercicios = await doc.reference.collection('exercises').get();
      for (var ejercicio in ejercicios.docs) {
        batch.delete(ejercicio.reference);
      }
      batch.delete(doc.reference);
    }

    // Eliminar sesiones
    final sesiones = await _firestore.collection('training_sessions').get();
    for (var doc in sesiones.docs) {
      batch.delete(doc.reference);
    }

    await batch.commit();
    print('🗑️ Datos limpiados correctamente');
  }
}
