// lib/services/workout_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/workout_session.dart';

class WorkoutService {
  // Referencia a una nueva colección de nivel superior para guardar las sesiones
  final CollectionReference _sessionsCollection =
      FirebaseFirestore.instance.collection('workout_sessions');

  Future<void> saveWorkoutSession(WorkoutSession session) async {
    try {
      await _sessionsCollection.add(session.toMap());
    } catch (e) {
      // Es una buena práctica imprimir errores para depuración
      print('Error al guardar la sesión de entrenamiento: $e');
      rethrow; // Vuelve a lanzar el error para que la UI pueda manejarlo si es necesario
    }
  }
  // En lib/services/workout_service.dart

// ... (El método saveWorkoutSession se queda igual)

  // --- NUEVO MÉTODO ---
  // Obtiene un stream de todas las sesiones de un usuario, ordenadas por fecha.
  Stream<List<WorkoutSession>> getWorkoutHistoryStream(String userId) {
    return _sessionsCollection
        .where('userId', isEqualTo: userId) // Filtramos para obtener solo las del usuario actual
        .orderBy('date', descending: true) // Las más nuevas primero
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return WorkoutSession.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    });
  }
}

