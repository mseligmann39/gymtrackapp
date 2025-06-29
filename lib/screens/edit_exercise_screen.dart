import 'package:flutter/material.dart';
import '../models/exercise.dart';
import '../services/exercise_service.dart';

class EditExerciseScreen extends StatefulWidget {
  final Exercise exercise;

  const EditExerciseScreen({super.key, required this.exercise});

  @override
  State<EditExerciseScreen> createState() => _EditExerciseScreenState();
}

class _EditExerciseScreenState extends State<EditExerciseScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _muscleGroupController;

  final ExerciseService _exerciseService = ExerciseService();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.exercise.name);
    _descriptionController = TextEditingController(text: widget.exercise.description);
    _muscleGroupController = TextEditingController(text: widget.exercise.muscleGroup);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _muscleGroupController.dispose();
    super.dispose();
  }

  Future<void> _saveExercise() async {
    if (_formKey.currentState!.validate()) {
      final updatedExercise = Exercise(
        id: widget.exercise.id,
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        muscleGroup: _muscleGroupController.text.trim(),
      );

      try {
        await _exerciseService.updateExercise(updatedExercise);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ejercicio actualizado')),
        );
        Navigator.of(context).pop(true); // devuelve true para refrescar lista
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al actualizar: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Ejercicio'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Nombre'),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Ingrese nombre' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Descripción'),
                maxLines: 3,
                validator: (value) =>
                    value == null || value.isEmpty ? 'Ingrese descripción' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _muscleGroupController,
                decoration: const InputDecoration(labelText: 'Grupo muscular'),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Ingrese grupo muscular' : null,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _saveExercise,
                child: const Text('Guardar Cambios'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
