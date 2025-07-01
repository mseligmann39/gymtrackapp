// lib/models/workout_session.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'logged_exercise.dart';

class WorkoutSession {
  final String? id; // El ID del documento de Firestore
  final DateTime date;
  final List<LoggedExercise> exercises;
  final String userId;

  WorkoutSession({
    this.id,
    required this.date,
    required this.exercises,
    required this.userId,
  });

  Map<String, dynamic> toMap() {
    return {
      'date': Timestamp.fromDate(date), // Usamos el Timestamp de Firestore
      'exercises': exercises.map((ex) => ex.toMap()).toList(),
      'userId': userId,
    };
  }

  factory WorkoutSession.fromMap(Map<String, dynamic> map, String documentId) {
    return WorkoutSession(
      id: documentId,
      date: (map['date'] as Timestamp).toDate(),
      exercises: (map['exercises'] as List<dynamic>)
          .map((exMap) => LoggedExercise.fromMap(exMap as Map<String, dynamic>))
          .toList(),
      userId: map['userId'] as String,
    );
  }
}