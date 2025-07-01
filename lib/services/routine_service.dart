import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/routine.dart';

class RoutineService {
  final CollectionReference _routinesCollection =
      FirebaseFirestore.instance.collection('routines');

  // Obtener todas las rutinas de un usuario en tiempo real
  Stream<List<Routine>> getRoutinesStream(String userId) {
    return _routinesCollection
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => Routine.fromFirestore(doc)).toList();
    });
  }

  // Añadir una nueva rutina
  Future<void> addRoutine(Routine routine) {
    return _routinesCollection.add(routine.toMap());
  }

  // Actualizar una rutina existente
  Future<void> updateRoutine(Routine routine) {
    if (routine.id == null) {
      throw Exception("El ID de la rutina no puede ser nulo para actualizar");
    }
    return _routinesCollection.doc(routine.id).update(routine.toMap());
  }

  // Eliminar una rutina
  Future<void> deleteRoutine(String routineId) {
    return _routinesCollection.doc(routineId).delete();
  }
}
