import 'package:flutter/material.dart';
import '../models/exercise.dart';
import '../models/logged_exercise.dart';
import '../models/workout_set.dart';
import '../models/workout_session.dart';
import '../services/workout_service.dart';

class WorkoutProvider with ChangeNotifier {
  final WorkoutService _workoutService = WorkoutService();

  // --- NUEVO ESTADO ---
  final List<Exercise> _routineExercises; // La lista completa de ejercicios de la rutina
  int _currentExerciseIndex = 0; // El índice del ejercicio que estamos haciendo

  // Estado que ya teníamos
  DateTime _startTime;
  final List<LoggedExercise> _loggedExercises = [];

  // --- GETTERS ACTUALIZADOS ---
  // El ejercicio actual ahora se obtiene de la lista usando el índice
  Exercise get currentExercise => _routineExercises[_currentExerciseIndex];
  int get currentExerciseNumber => _currentExerciseIndex + 1;
  int get totalExercises => _routineExercises.length;
  bool get isLastExercise => _currentExerciseIndex == _routineExercises.length - 1;
  List<LoggedExercise> get loggedExercises => _loggedExercises;

  // El constructor ahora acepta una LISTA de ejercicios
  WorkoutProvider({required List<Exercise> routineExercises})
      : _routineExercises = routineExercises,
        _startTime = DateTime.now() {
    // Si la lista no está vacía, preparamos el primer ejercicio
    if (_routineExercises.isNotEmpty) {
      _startNewLoggedExercise();
    }
  }

  // Prepara un LoggedExercise vacío para el ejercicio actual
  void _startNewLoggedExercise() {
    _loggedExercises.add(
      LoggedExercise(
        exerciseId: currentExercise.id,
        exerciseName: currentExercise.name,
        sets: [],
      ),
    );
    notifyListeners();
  }

  // --- MÉTODO NUEVO ---
  // Pasa al siguiente ejercicio de la rutina
  void nextExercise() {
    if (!isLastExercise) {
      _currentExerciseIndex++;
      _startNewLoggedExercise(); // Prepara el nuevo ejercicio para registrar series
      notifyListeners();
    }
  }

  // La lógica para añadir una serie no cambia, siempre la añade al último
  // LoggedExercise de la lista (que es el actual)
  void addSet(int reps, double weight) {
    if (_loggedExercises.isEmpty) return;
    final newSet = WorkoutSet(
      reps: reps,
      weight: weight,
      timestamp: DateTime.now(),
    );
    _loggedExercises.last.sets.add(newSet);
    notifyListeners();
  }

  // La lógica para finalizar el entrenamiento tampoco cambia
  Future<void> finishWorkout(String userId) async {
    if (_loggedExercises.isEmpty || _loggedExercises.every((e) => e.sets.isEmpty)) {
      return;
    }
    final session = WorkoutSession(
      userId: userId,
      date: _startTime,
      exercises: _loggedExercises.where((e) => e.sets.isNotEmpty).toList(),
    );
    await _workoutService.saveWorkoutSession(session);
  }
}
