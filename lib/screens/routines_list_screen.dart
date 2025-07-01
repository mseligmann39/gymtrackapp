import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/routine.dart';
import '../models/exercise.dart';
import '../services/routine_service.dart';
import '../services/exercise_service.dart';
import '../providers/workout_provider.dart';
import 'create_edit_routine_screen.dart';
import 'active_workout_screen.dart';

class RoutinesListScreen extends StatefulWidget {
  const RoutinesListScreen({super.key});

  @override
  State<RoutinesListScreen> createState() => _RoutinesListScreenState();
}

class _RoutinesListScreenState extends State<RoutinesListScreen> {
  final RoutineService _routineService = RoutineService();
  final ExerciseService _exerciseService = ExerciseService();
  
  // Estado para mostrar un loader al iniciar una rutina
  String? _startingRoutineId;

  // Navega a la pantalla de creación/edición
  void _editRoutine(Routine? routine) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CreateEditRoutineScreen(routineToEdit: routine),
      ),
    );
  }

  // Lógica para iniciar el entrenamiento
  Future<void> _startWorkout(Routine routine) async {
    if (routine.exerciseIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Esta rutina no tiene ejercicios.')),
      );
      return;
    }
    
    setState(() => _startingRoutineId = routine.id);

    try {
      // 1. Obtenemos todos los ejercicios del usuario
      final allExercises = await _exerciseService.getExercises();

      // 2. Filtramos para quedarnos solo con los que están en la rutina
      final routineExercises = allExercises
          .where((exercise) => routine.exerciseIds.contains(exercise.id))
          .toList();

      // (Opcional) Mantener el orden de la rutina si es importante
      routineExercises.sort((a, b) => 
        routine.exerciseIds.indexOf(a.id).compareTo(routine.exerciseIds.indexOf(b.id))
      );
      
      if (!mounted) return;

      // 3. Navegamos a la pantalla de entrenamiento
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => ChangeNotifierProvider(
            create: (context) => WorkoutProvider(routineExercises: routineExercises),
            child: const ActiveWorkoutScreen(),
          ),
        ),
      );

    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al iniciar la rutina: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _startingRoutineId = null);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<User?>();

    if (user == null) {
      return const Scaffold(body: Center(child: Text("Inicia sesión.")));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Mis Rutinas')),
      body: StreamBuilder<List<Routine>>(
        stream: _routineService.getRoutinesStream(user.uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Aún no has creado ninguna rutina.'));
          }

          final routines = snapshot.data!;
          return ListView.builder(
            itemCount: routines.length,
            itemBuilder: (context, index) {
              final routine = routines[index];
              final isLoading = _startingRoutineId == routine.id;

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  leading: isLoading 
                      ? const CircularProgressIndicator()
                      : const Icon(Icons.play_circle_outline, color: Colors.deepPurple, size: 40),
                  title: Text(routine.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('${routine.exerciseIds.length} ejercicios'),
                  trailing: IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () => _editRoutine(routine),
                  ),
                  onTap: isLoading ? null : () => _startWorkout(routine),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _editRoutine(null),
        child: const Icon(Icons.add),
        tooltip: 'Crear Rutina',
      ),
    );
  }
}
