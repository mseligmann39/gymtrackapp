import 'package:flutter/material.dart';
import '../models/exercise.dart';
import '../services/exercise_service.dart';

class AddExerciseScreen extends StatefulWidget {
  const AddExerciseScreen({super.key});

  @override
  State<AddExerciseScreen> createState() => _AddExerciseScreenState();
}

class _AddExerciseScreenState extends State<AddExerciseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _muscleGroupController = TextEditingController();

  final ExerciseService _exerciseService = ExerciseService();

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _muscleGroupController.dispose();
    super.dispose();
  }

  void _saveExercise() async {
    if (_formKey.currentState!.validate()) {
      final exercise = Exercise(
        id: '', // Firestore asigna el id
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        muscleGroup: _muscleGroupController.text.trim(),
      );

      await _exerciseService.addExercise(exercise);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ejercicio agregado')),
      );

      Navigator.of(context).pop(); // Regresar a la pantalla anterior
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Agregar Ejercicio'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Nombre'),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Ingresa el nombre' : null,
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Descripción'),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Ingresa la descripción' : null,
              ),
              TextFormField(
                controller: _muscleGroupController,
                decoration: const InputDecoration(labelText: 'Grupo muscular'),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Ingresa el grupo muscular' : null,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveExercise,
                child: const Text('Guardar'),
              )
            ],
          ),
        ),
      ),
    );
  }
}
