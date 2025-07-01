import 'package:flutter/material.dart';
import '../models/exercise.dart';
import '../services/exercise_service.dart';
import 'add_exercise_screen.dart';
import 'edit_exercise_screen.dart';
import 'active_workout_screen.dart';
import 'package:provider/provider.dart';
import '../providers/workout_provider.dart';

class ExerciseListScreen extends StatefulWidget {
  const ExerciseListScreen({super.key});

  @override
  State<ExerciseListScreen> createState() => _ExerciseListScreenState();
}

class _ExerciseListScreenState extends State<ExerciseListScreen> {
  // Ya no necesitamos un Future, el StreamBuilder se encargará de todo.
  final ExerciseService _exerciseService = ExerciseService();

  // ELIMINADO: Ya no necesitamos initState, _loadExercises, ni _refresh. ¡Código más limpio!

  void _deleteExercise(String id) async {
    // Mostramos un diálogo de confirmación para una mejor UX.
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
      // ELIMINADO: La llamada a _refresh() ya no es necesaria.
    }
  }

  void _editExercise(Exercise exercise) {
    // La navegación a la pantalla de edición no necesita cambios.
    // El StreamBuilder se encargará de reflejar la actualización al volver.
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => EditExerciseScreen(exercise: exercise),
      ),
    );
  }

  void _navigateToAddScreen() {
    // Navegamos y ya está. No necesitamos esperar (`await`) ni refrescar.
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const AddExerciseScreen()),
    );
  }

  // En lib/screens/exercise_list_screen.dart

// ... (El resto del archivo no cambia)

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
                  Text('Toca un ejercicio para iniciar una rutina', style: TextStyle(color: Colors.grey)),
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
                  title: Text(ex.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(ex.muscleGroup),
                  // --- CAMBIO AQUÍ ---
                  // Añadimos la acción onTap para iniciar el entrenamiento.
                 onTap: () {
  // --- CAMBIO AQUÍ ---
  Navigator.of(context).push(
    MaterialPageRoute(
      // Envolvemos la pantalla de entrenamiento con el Provider
      builder: (_) => ChangeNotifierProvider(
        // Creamos una NUEVA instancia del provider cada vez que empezamos un entrenamiento
        create: (context) => WorkoutProvider(startingExercise: ex),
        // El hijo es nuestra pantalla, que ahora tendrá acceso al Provider
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

