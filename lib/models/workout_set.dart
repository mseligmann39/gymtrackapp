// lib/models/workout_set.dart

class WorkoutSet {
  final int reps;
  final double weight;
  final DateTime timestamp; // Guardamos cuándo se hizo la serie

  WorkoutSet({
    required this.reps,
    required this.weight,
    required this.timestamp,
  });

  // Métodos para convertir a/desde un mapa (para Firestore)
  Map<String, dynamic> toMap() {
    return {
      'reps': reps,
      'weight': weight,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory WorkoutSet.fromMap(Map<String, dynamic> map) {
    return WorkoutSet(
      reps: map['reps'] as int,
      weight: map['weight'] as double,
      timestamp: DateTime.parse(map['timestamp'] as String),
    );
  }
}