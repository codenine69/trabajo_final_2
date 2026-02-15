import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:votacionesappg14/features/tactical/domain/entities/exercise_config.dart';
import 'package:votacionesappg14/features/tactical/domain/entities/training_process.dart';
import 'package:votacionesappg14/features/tactical/domain/entities/training_session.dart';

/// Servicio para interactuar con Firestore
class ServicioFirestore {
  final FirebaseFirestore _firestore;

  ServicioFirestore({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  // === USUARIOS ===

  /// Obtiene el proceso activo de un usuario
  Future<String?> obtenerProcesoActivo(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      if (!doc.exists) return null;
      return doc.data()?['active_process_id'] as String?;
    } catch (e) {
      throw Exception('Error al obtener proceso activo: $e');
    }
  }

  /// Actualiza el proceso activo de un usuario
  Future<void> actualizarProcesoActivo(String userId, String processId) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'active_process_id': processId,
      });
    } catch (e) {
      throw Exception('Error al actualizar proceso activo: $e');
    }
  }

  /// Obtiene los datos del usuario
  Future<Map<String, dynamic>?> obtenerDatosUsuario(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      if (!doc.exists) return null;
      return doc.data();
    } catch (e) {
      throw Exception('Error al obtener datos de usuario: $e');
    }
  }

  // === PROCESOS DE ENTRENAMIENTO ===

  /// Obtiene todos los procesos de entrenamiento
  Future<List<ProcesoEntrenamiento>> obtenerProcesos() async {
    try {
      final snapshot = await _firestore.collection('training_processes').get();
      return snapshot.docs
          .map((doc) => ProcesoEntrenamiento.fromFirestore(doc.id, doc.data()))
          .toList();
    } catch (e) {
      throw Exception('Error al obtener procesos: $e');
    }
  }

  /// Filtra procesos por tipo de usuario
  Future<List<ProcesoEntrenamiento>> obtenerProcesosPorTipo({
    required String tipoUsuario,
    String? subtipoUsuario,
  }) async {
    try {
      Query query = _firestore
          .collection('training_processes')
          .where('target_type', isEqualTo: tipoUsuario);

      if (subtipoUsuario != null) {
        query = query.where('target_subtype', isEqualTo: subtipoUsuario);
      }

      final snapshot = await query.get();
      return snapshot.docs
          .map(
            (doc) => ProcesoEntrenamiento.fromFirestore(
              doc.id,
              doc.data() as Map<String, dynamic>,
            ),
          )
          .toList();
    } catch (e) {
      throw Exception('Error al filtrar procesos: $e');
    }
  }

  // === EJERCICIOS ===

  /// Obtiene los ejercicios de un proceso
  Future<List<ConfiguracionEjercicio>> obtenerEjercicios(
    String processId,
  ) async {
    try {
      final snapshot = await _firestore
          .collection('training_processes')
          .doc(processId)
          .collection('exercises')
          .get();

      return snapshot.docs
          .map(
            (doc) => ConfiguracionEjercicio.fromFirestore(doc.id, doc.data()),
          )
          .toList();
    } catch (e) {
      throw Exception('Error al obtener ejercicios: $e');
    }
  }

  /// Obtiene un ejercicio específico
  Future<ConfiguracionEjercicio?> obtenerEjercicio(
    String processId,
    String exerciseId,
  ) async {
    try {
      final doc = await _firestore
          .collection('training_processes')
          .doc(processId)
          .collection('exercises')
          .doc(exerciseId)
          .get();

      if (!doc.exists) return null;

      return ConfiguracionEjercicio.fromFirestore(doc.id, doc.data()!);
    } catch (e) {
      throw Exception('Error al obtener ejercicio: $e');
    }
  }

  // === SESIONES DE ENTRENAMIENTO ===

  /// Guarda una sesión de entrenamiento
  Future<String> guardarSesionEntrenamiento(SesionEntrenamiento sesion) async {
    try {
      final docRef = await _firestore
          .collection('training_sessions')
          .add(sesion.toMap());
      return docRef.id;
    } catch (e) {
      throw Exception('Error al guardar sesión: $e');
    }
  }

  /// Obtiene el historial de sesiones de un usuario
  Future<List<Map<String, dynamic>>> obtenerHistorialSesiones(
    String userId,
  ) async {
    try {
      final snapshot = await _firestore
          .collection('training_sessions')
          .where('user_id', isEqualTo: userId)
          .orderBy('timestamp', descending: true)
          .get();

      return snapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      throw Exception('Error al obtener historial: $e');
    }
  }
}
