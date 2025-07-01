import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/routine.dart';
import '../models/exercise.dart';
import '../services/routine_service.dart';
import '../services/exercise_service.dart';

class CreateEditRoutineScreen extends StatefulWidget {
  final Routine? routineToEdit;

  const CreateEditRoutineScreen({super.key, this.routineToEdit});

  @override
  State<CreateEditRoutineScreen> createState() => _CreateEditRoutineScreenState();
}

class _CreateEditRoutineScreenState extends State<CreateEditRoutineScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  
  // Lista de los ejercicios seleccionados para la rutina (esta será reordenable)
  List<Exercise> _selectedExercises = [];
  
  // Lista de todos los ejercicios disponibles para el usuario
  List<Exercise> _availableExercises = [];
  bool _isLoading = true;
  bool _isSaving = false;

  final RoutineService _routineService = RoutineService();
  final ExerciseService _exerciseService = ExerciseService();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.routineToEdit?.name ?? '');
    _loadData();
  }

  // Carga todos los ejercicios y configura la lista de seleccionados si estamos editando
  Future<void> _loadData() async {
    try {
      final allExercises = await _exerciseService.getExercises();
      if (mounted) {
        setState(() {
          _availableExercises = allExercises;
          // Si estamos editando, poblamos la lista de seleccionados en el orden correcto
          if (widget.routineToEdit != null) {
            _selectedExercises = widget.routineToEdit!.exerciseIds.map((id) {
              return allExercises.firstWhere((ex) => ex.id == id, orElse: () => Exercise(id: '', name: 'Ejercicio no encontrado', description: '', muscleGroup: ''));
            }).where((ex) => ex.id.isNotEmpty).toList();
          }
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar datos: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _saveRoutine() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedExercises.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Debes añadir al menos un ejercicio a la rutina.')),
      );
      return;
    }

    final user = context.read<User?>();
    if (user == null) return;

    setState(() => _isSaving = true);

    try {
      // Creamos la rutina con la lista de IDs en el nuevo orden
      final routine = Routine(
        id: widget.routineToEdit?.id,
        name: _nameController.text.trim(),
        exerciseIds: _selectedExercises.map((ex) => ex.id).toList(), // ¡El orden se preserva aquí!
        userId: user.uid,
      );

      if (widget.routineToEdit == null) {
        await _routineService.addRoutine(routine);
      } else {
        await _routineService.updateRoutine(routine);
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Rutina guardada con éxito.')),
      );
      Navigator.of(context).pop();

    } catch (e) {
      // Manejo de errores
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.routineToEdit != null;
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Editar Rutina' : 'Crear Rutina'),
        actions: [
          if (_isSaving) const Padding(padding: EdgeInsets.all(16.0), child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)))
          else IconButton(icon: const Icon(Icons.save), onPressed: _saveRoutine, tooltip: 'Guardar Rutina')
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(labelText: 'Nombre de la Rutina', border: OutlineInputBorder()),
                      validator: (value) => (value == null || value.isEmpty) ? 'El nombre es obligatorio' : null,
                    ),
                  ),
                  const Divider(height: 1),
                  
                  // --- NUEVA SECCIÓN REORDENABLE ---
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text('Ejercicios en la rutina (arrastra para ordenar):', style: Theme.of(context).textTheme.titleMedium),
                  ),
                  Expanded(
                    // Usamos ReorderableListView para permitir arrastrar y soltar
                    child: ReorderableListView.builder(
                      itemCount: _selectedExercises.length,
                      itemBuilder: (context, index) {
                        final exercise = _selectedExercises[index];
                        return Card(
                          key: ValueKey(exercise.id), // La key es crucial para que funcione
                          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                          child: ListTile(
                            title: Text(exercise.name),
                            // El icono para iniciar el arrastre
                            leading: ReorderableDragStartListener(
                              index: index,
                              child: const Icon(Icons.drag_handle),
                            ),
                            // Botón para quitar el ejercicio de la rutina
                            trailing: IconButton(
                              icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
                              onPressed: () {
                                setState(() {
                                  _selectedExercises.removeAt(index);
                                });
                              },
                            ),
                          ),
                        );
                      },
                      // La función que se llama cuando el usuario suelta un elemento
                      onReorder: (int oldIndex, int newIndex) {
                        setState(() {
                          if (oldIndex < newIndex) {
                            newIndex -= 1;
                          }
                          final Exercise item = _selectedExercises.removeAt(oldIndex);
                          _selectedExercises.insert(newIndex, item);
                        });
                      },
                    ),
                  ),
                  
                  const Divider(height: 1),
                  // --- SECCIÓN PARA AÑADIR MÁS EJERCICIOS ---
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text('Añadir ejercicios disponibles:', style: Theme.of(context).textTheme.titleMedium),
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: _availableExercises.length,
                      itemBuilder: (context, index) {
                        final exercise = _availableExercises[index];
                        // Solo mostramos los ejercicios que NO están ya en la rutina
                        if (_selectedExercises.any((e) => e.id == exercise.id)) {
                          return const SizedBox.shrink(); // No mostrar si ya está seleccionado
                        }
                        return ListTile(
                          title: Text(exercise.name),
                          subtitle: Text(exercise.muscleGroup),
                          trailing: IconButton(
                            icon: const Icon(Icons.add_circle_outline, color: Colors.green),
                            onPressed: () {
                              setState(() {
                                _selectedExercises.add(exercise);
                              });
                            },
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
