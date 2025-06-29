import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/exercise.dart';

class ExerciseService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  CollectionReference get _exerciseCollection {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('Usuario no autenticado');
    }
    return FirebaseFirestore.instance
      .collection('users')
      .doc(user.uid)
      .collection('exercises');
  }

  Future<void> addExercise(Exercise exercise) async {
    await _exerciseCollection.add(exercise.toMap());
  }

  Future<List<Exercise>> getExercises() async {
    QuerySnapshot snapshot = await _exerciseCollection.get();
    return snapshot.docs.map((doc) {
      return Exercise.fromMap(doc.data() as Map<String, dynamic>, doc.id);
    }).toList();
  }

  Future<void> updateExercise(Exercise exercise) async {
    await _exerciseCollection.doc(exercise.id).update(exercise.toMap());
  }

  Future<void> deleteExercise(String id) async {
    await _exerciseCollection.doc(id).delete();
  }
}
