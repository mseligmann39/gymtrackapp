// lib/providers/workout_provider.dart

import 'package:flutter/material.dart';
import '../models/exercise.dart';
import '../models/logged_exercise.dart';
import '../models/workout_set.dart';
import '../models/workout_session.dart';
import '../services/workout_service.dart'; // Crearemos este servicio a continuación

class WorkoutProvider with ChangeNotifier {
  final WorkoutService _workoutService = WorkoutService();

  // Estado del entrenamiento actual
  DateTime _startTime; // Para saber cuándo empezó la sesión
  final List<LoggedExercise> _loggedExercises = []; // Lista de ejercicios completados en la sesión
  Exercise _currentExercise; // El ejercicio que se está haciendo ahora

  // Getters públicos para que la UI pueda leer el estado
  Exercise get currentExercise => _currentExercise;
  List<LoggedExercise> get loggedExercises => _loggedExercises;

  // Constructor: se llama cuando se inicia el entrenamiento
  WorkoutProvider({required Exercise startingExercise})
      : _currentExercise = startingExercise,
        _startTime = DateTime.now() {
    // Preparamos el primer ejercicio para registrarlo
    _startNewExercise(startingExercise);
  }

  // Prepara un nuevo ejercicio para empezar a registrarle series
  void _startNewExercise(Exercise exercise) {
    _currentExercise = exercise;
    // Añadimos un LoggedExercise vacío a la lista, listo para recibir series
    _loggedExercises.add(
      LoggedExercise(
        exerciseId: exercise.id,
        exerciseName: exercise.name,
        sets: [], // La lista de series empieza vacía
      ),
    );
    notifyListeners(); // Notifica a la UI que el ejercicio actual ha cambiado
  }

  // --- MÉTODOS PRINCIPALES QUE LA UI LLAMARÁ ---

  // 1. Añadir una nueva serie al ejercicio actual
  void addSet(int reps, double weight) {
    if (_loggedExercises.isEmpty) return;

    final newSet = WorkoutSet(
      reps: reps,
      weight: weight,
      timestamp: DateTime.now(),
    );

    // Añadimos la nueva serie al último ejercicio de la lista (el actual)
    _loggedExercises.last.sets.add(newSet);

    // Notificamos a los widgets que escuchan para que se redibujen
    notifyListeners();
  }

  // 2. Finalizar y guardar el entrenamiento
  Future<void> finishWorkout(String userId) async {
    if (_loggedExercises.isEmpty || _loggedExercises.every((e) => e.sets.isEmpty)) {
      // No guardar si no se hizo ningún ejercicio
      return;
    }

    final session = WorkoutSession(
      userId: userId,
      date: _startTime,
      // Filtramos por si algún ejercicio se quedó sin series
      exercises: _loggedExercises.where((e) => e.sets.isNotEmpty).toList(),
    );

    await _workoutService.saveWorkoutSession(session);
  }
}