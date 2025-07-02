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
  // NUEVO: Parámetro para definir el modo de la pantalla
  final bool isSelectionMode;

  const RoutinesListScreen({super.key, this.isSelectionMode = false});

  @override
  State<RoutinesListScreen> createState() => _RoutinesListScreenState();
}

class _RoutinesListScreenState extends State<RoutinesListScreen> {
  final RoutineService _routineService = RoutineService();
  final ExerciseService _exerciseService = ExerciseService();
  
  // Estado para mostrar un loader al iniciar una rutina
  String? _startingRoutineId;

  // Navega a la pantalla de edición (solo en modo gestión)
  void _manageRoutine(Routine? routine) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CreateEditRoutineScreen(routineToEdit: routine),
      ),
    );
  }

  // Lógica para iniciar el entrenamiento (solo en modo selección)
  Future<void> _startWorkout(Routine routine) async {
    if (routine.exerciseIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Esta rutina no tiene ejercicios.')),
      );
      return;
    }
    
    setState(() => _startingRoutineId = routine.id);

    try {
      final allExercises = await _exerciseService.getExercises();
      final routineExercises = allExercises
          .where((exercise) => routine.exerciseIds.contains(exercise.id))
          .toList();

      // Mantener el orden de la rutina
      routineExercises.sort((a, b) => 
        routine.exerciseIds.indexOf(a.id).compareTo(routine.exerciseIds.indexOf(b.id))
      );
      
      if (!mounted) return;

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
      appBar: AppBar(
        // El título cambia según el modo
        title: Text(widget.isSelectionMode ? 'Seleccionar Rutina' : 'Mis Rutinas'),
      ),
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
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.list_alt_rounded, size: 80, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    widget.isSelectionMode 
                      ? 'No tienes rutinas para iniciar.' 
                      : 'Aún no has creado ninguna rutina.', 
                    style: TextStyle(fontSize: 18)
                  ),
                  if (!widget.isSelectionMode)
                    const Text('Usa el botón + para crear tu primer plan.', style: TextStyle(color: Colors.grey)),
                ],
              ),
            );
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
                      : Icon(
                          // El icono cambia según el modo
                          widget.isSelectionMode ? Icons.play_circle_outline : Icons.assignment_outlined,
                          color: widget.isSelectionMode ? Colors.deepPurple : Colors.green,
                          size: 40
                        ),
                  title: Text(routine.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('${routine.exerciseIds.length} ejercicios'),
                  // El botón de la derecha cambia según el modo
                  trailing: widget.isSelectionMode
                      ? null // Sin botón en modo selección
                      : IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () => _manageRoutine(routine),
                        ),
                  onTap: isLoading
                      ? null
                      // La acción de tocar depende del modo
                      : () => widget.isSelectionMode
                          ? _startWorkout(routine)
                          : _manageRoutine(routine),
                ),
              );
            },
          );
        },
      ),
      // El botón flotante solo aparece en modo gestión
      floatingActionButton: widget.isSelectionMode
          ? null
          : FloatingActionButton(
              onPressed: () => _manageRoutine(null),
              child: const Icon(Icons.add),
              tooltip: 'Crear Rutina',
            ),
    );
  }
}
