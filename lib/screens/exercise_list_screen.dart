import 'package:flutter/material.dart';
import '../models/exercise.dart';
import '../services/exercise_service.dart';
import 'add_exercise_screen.dart';
import 'edit_exercise_screen.dart';
class ExerciseListScreen extends StatefulWidget {
  const ExerciseListScreen({super.key});

  @override
  State<ExerciseListScreen> createState() => _ExerciseListScreenState();
}

class _ExerciseListScreenState extends State<ExerciseListScreen> {
  final ExerciseService _exerciseService = ExerciseService();
  late Future<List<Exercise>> _exercisesFuture;

  @override
  void initState() {
    super.initState();
    _loadExercises();
  }

  void _loadExercises() {
    _exercisesFuture = _exerciseService.getExercises();
  }

  void _refresh() {
    setState(() {
      _loadExercises();
    });
  }

  void _deleteExercise(String id) async {
    await _exerciseService.deleteExercise(id);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Ejercicio eliminado')),
    );
    _refresh();
  }

  void _editExercise(Exercise exercise) async {
  final result = await Navigator.of(context).push(
    MaterialPageRoute(
      builder: (_) => EditExerciseScreen(exercise: exercise),
    ),
  );

  if (result == true) {
    _refresh();
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lista de Ejercicios'),
      ),
      body: FutureBuilder<List<Exercise>>(
        future: _exercisesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No hay ejercicios'));
          } else {
            final exercises = snapshot.data!;
            return ListView.builder(
              itemCount: exercises.length,
              itemBuilder: (context, index) {
                final ex = exercises[index];
                return ListTile(
                  title: Text(ex.name),
                  subtitle: Text(ex.muscleGroup),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () => _editExercise(ex),
                        tooltip: 'Editar',
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => _deleteExercise(ex.id),
                        tooltip: 'Eliminar',
                      ),
                    ],
                  ),
                );
              },
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // Navegar a agregar ejercicio y luego recargar la lista
          await Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const AddExerciseScreen()),
          );
          _refresh();
        },
        child: const Icon(Icons.add),
        tooltip: 'Agregar Ejercicio',
      ),
    );
  }
}
