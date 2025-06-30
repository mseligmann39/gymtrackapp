import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/exercise.dart';

class ExerciseService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Tu getter para la colección sigue siendo perfecto.
  CollectionReference get _exerciseCollection {
    final user = _auth.currentUser;
    if (user == null) {
      // Usar un error más específico es una buena práctica.
      throw AuthException('Usuario no autenticado. No se puede acceder a los ejercicios.');
    }
    return FirebaseFirestore.instance
      .collection('users')
      .doc(user.uid)
      .collection('exercises');
  }

  // Tu método para obtener los ejercicios una vez (lo conservamos por si acaso).
  Future<List<Exercise>> getExercises() async {
    final snapshot = await _exerciseCollection.get();
    return snapshot.docs.map((doc) {
      return Exercise.fromMap(doc.data() as Map<String, dynamic>, doc.id);
    }).toList();
  }

  // --- NUEVO MÉTODO ---
  // Este método devuelve un "chorro" (Stream) de datos.
  // Firestore nos notificará automáticamente cada vez que haya un cambio.
  Stream<List<Exercise>> getExercisesStream() {
    return _exerciseCollection.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return Exercise.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    });
  }
  
  // Los métodos de escritura no cambian.
  Future<void> addExercise(Exercise exercise) async {
    await _exerciseCollection.add(exercise.toMap());
  }

  Future<void> updateExercise(Exercise exercise) async {
    await _exerciseCollection.doc(exercise.id).update(exercise.toMap());
  }

  Future<void> deleteExercise(String id) async {
    await _exerciseCollection.doc(id).delete();
  }
}

// Clase de excepción personalizada para mayor claridad.
class AuthException implements Exception {
  final String message;
  AuthException(this.message);

  @override
  String toString() => message;
}