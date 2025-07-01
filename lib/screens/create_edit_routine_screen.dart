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
  
  final Set<String> _selectedExerciseIds = {};
  
  List<Exercise> _availableExercises = [];
  bool _isLoading = true;
  bool _isSaving = false;

  final RoutineService _routineService = RoutineService();
  final ExerciseService _exerciseService = ExerciseService();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.routineToEdit?.name ?? '');
    if (widget.routineToEdit != null) {
      _selectedExerciseIds.addAll(widget.routineToEdit!.exerciseIds);
    }
    _loadAvailableExercises();
  }

  Future<void> _loadAvailableExercises() async {
    try {
      final exercises = await _exerciseService.getExercises();
      if(mounted) {
        setState(() {
          _availableExercises = exercises;
          _isLoading = false;
        });
      }
    } catch (e) {
      if(mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar ejercicios: $e')),
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
    if (_selectedExerciseIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Debes seleccionar al menos un ejercicio.')),
      );
      return;
    }

    final user = context.read<User?>();
    if (user == null) return;

    setState(() => _isSaving = true);

    try {
      final routine = Routine(
        id: widget.routineToEdit?.id,
        name: _nameController.text.trim(),
        exerciseIds: _selectedExerciseIds.toList(),
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
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al guardar la rutina: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.routineToEdit != null;
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Editar Rutina' : 'Crear Rutina'),
        actions: [
          if (_isSaving)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)),
            )
          else
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: _saveRoutine,
              tooltip: 'Guardar Rutina',
            )
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
                      decoration: const InputDecoration(
                        labelText: 'Nombre de la Rutina',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) => (value == null || value.isEmpty) ? 'El nombre es obligatorio' : null,
                    ),
                  ),
                  const Divider(height: 1),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                    child: Text('Selecciona los ejercicios:', style: Theme.of(context).textTheme.titleMedium),
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: _availableExercises.length,
                      itemBuilder: (context, index) {
                        final exercise = _availableExercises[index];
                        final isSelected = _selectedExerciseIds.contains(exercise.id);
                        return CheckboxListTile(
                          title: Text(exercise.name),
                          subtitle: Text(exercise.muscleGroup),
                          value: isSelected,
                          onChanged: (bool? value) {
                            setState(() {
                              if (value == true) {
                                _selectedExerciseIds.add(exercise.id);
                              } else {
                                _selectedExerciseIds.remove(exercise.id);
                              }
                            });
                          },
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
