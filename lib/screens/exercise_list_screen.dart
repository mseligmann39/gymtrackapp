import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Necesitamos Provider
import '../models/exercise.dart';
import '../services/exercise_service.dart';
import '../providers/workout_provider.dart'; // Y el WorkoutProvider
import 'add_exercise_screen.dart';
import 'edit_exercise_screen.dart';
import 'active_workout_screen.dart'; // Y la pantalla de entrenamiento

class ExerciseListScreen extends StatefulWidget {
  const ExerciseListScreen({super.key});

  @override
  State<ExerciseListScreen> createState() => _ExerciseListScreenState();
}

class _ExerciseListScreenState extends State<ExerciseListScreen> {
  final ExerciseService _exerciseService = ExerciseService();

  void _deleteExercise(String id) async {
    final bool? shouldDelete = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: const Text('¿Estás seguro de que quieres eliminar este ejercicio?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
    
    if (shouldDelete == true) {
      await _exerciseService.deleteExercise(id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ejercicio eliminado')),
      );
    }
  }

  void _editExercise(Exercise exercise) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => EditExerciseScreen(exercise: exercise),
      ),
    );
  }

  void _navigateToAddScreen() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const AddExerciseScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Ejercicios'),
      ),
      body: StreamBuilder<List<Exercise>>(
        stream: _exerciseService.getExercisesStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.list_alt_rounded, size: 80, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('Aún no tienes ejercicios', style: TextStyle(fontSize: 18)),
                  Text('Toca un ejercicio para iniciar una rutina rápida', style: TextStyle(color: Colors.grey)),
                  Text('o añade uno nuevo con el botón +', style: TextStyle(color: Colors.grey)),
                ],
              )
            );
          }

          final exercises = snapshot.data!;
          return ListView.builder(
            itemCount: exercises.length,
            itemBuilder: (context, index) {
              final ex = exercises[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                child: ListTile(
                  leading: const Icon(Icons.fitness_center_outlined, color: Colors.blue, size: 30),
                  title: Text(ex.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(ex.muscleGroup),
                  // --- CORRECCIÓN PRINCIPAL AQUÍ ---
                  // Al tocar un ejercicio, iniciamos un entrenamiento con una rutina de 1 solo elemento.
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        // Envolvemos la pantalla de entrenamiento con el Provider
                        builder: (_) => ChangeNotifierProvider(
                          // Creamos el WorkoutProvider pasándole una lista que SOLO contiene el ejercicio tocado
                          create: (context) => WorkoutProvider(routineExercises: [ex]),
                          child: const ActiveWorkoutScreen(),
                        ),
                      ),
                    );
                  },
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blueGrey),
                        onPressed: () => _editExercise(ex),
                        tooltip: 'Editar',
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.redAccent),
                        onPressed: () => _deleteExercise(ex.id),
                        tooltip: 'Eliminar',
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAddScreen,
        tooltip: 'Agregar Ejercicio',
        child: const Icon(Icons.add),
      ),
    );
  }
}
