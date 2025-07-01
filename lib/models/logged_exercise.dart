// lib/models/logged_exercise.dart

import 'workout_set.dart';

class LoggedExercise {
  final String exerciseId; // Referencia al ID del ejercicio original
  final String exerciseName;
  final List<WorkoutSet> sets;

  LoggedExercise({
    required this.exerciseId,
    required this.exerciseName,
    required this.sets,
  });

  Map<String, dynamic> toMap() {
    return {
      'exerciseId': exerciseId,
      'exerciseName': exerciseName,
      'sets': sets.map((set) => set.toMap()).toList(),
    };
  }

  factory LoggedExercise.fromMap(Map<String, dynamic> map) {
    return LoggedExercise(
      exerciseId: map['exerciseId'] as String,
      exerciseName: map['exerciseName'] as String,
      sets: (map['sets'] as List<dynamic>)
          .map((setMap) => WorkoutSet.fromMap(setMap as Map<String, dynamic>))
          .toList(),
    );
  }
}