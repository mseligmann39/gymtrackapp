// lib/screens/active_workout_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Para obtener el userId

import '../providers/workout_provider.dart';
import '../models/workout_set.dart';

class ActiveWorkoutScreen extends StatefulWidget {
  // Ya no necesita recibir el ejercicio, lo tomará del Provider
  const ActiveWorkoutScreen({super.key});

  @override
  State<ActiveWorkoutScreen> createState() => _ActiveWorkoutScreenState();
}

class _ActiveWorkoutScreenState extends State<ActiveWorkoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _repsController = TextEditingController();
  final _weightController = TextEditingController();
  bool _isFinishing = false; // Para mostrar un loader al guardar

  @override
  void dispose() {
    _repsController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  void _addSet(WorkoutProvider provider) {
    // Validamos que los campos no estén vacíos
    if (_formKey.currentState?.validate() ?? false) {
      final reps = int.tryParse(_repsController.text) ?? 0;
      final weight = double.tryParse(_weightController.text) ?? 0.0;

      // Llamamos al método del provider para que maneje la lógica
      provider.addSet(reps, weight);

      // Limpiamos los campos y quitamos el foco para la siguiente serie
      _repsController.clear();
      _weightController.clear();
      FocusScope.of(context).unfocus();
    }
  }

  Future<void> _finishWorkout(WorkoutProvider provider) async {
    final user = context.read<User?>();
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error: No se pudo identificar al usuario.')),
      );
      return;
    }

    setState(() => _isFinishing = true);

    try {
      await provider.finishWorkout(user.uid);
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('¡Entrenamiento guardado con éxito!')),
      );
      Navigator.of(context).pop(); // Volvemos a la lista de ejercicios
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al guardar: $e')),
      );
    } finally {
      if(mounted) {
        setState(() => _isFinishing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Usamos context.watch para que la UI se reconstruya cuando cambie el estado
    final provider = context.watch<WorkoutProvider>();
    final currentExercise = provider.currentExercise;
    // Obtenemos la lista de series del ejercicio actual
    final sets = provider.loggedExercises.last.sets;

    return Scaffold(
      appBar: AppBar(
        title: Text(currentExercise.name),
        actions: [
          // Mostramos un loader o el botón de finalizar
          if (_isFinishing)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
            )
          else
            TextButton(
              onPressed: () => _finishWorkout(provider),
              child: const Text('FINALIZAR'),
            )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // --- Entradas para Reps y Peso ---
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _repsController,
                      decoration: const InputDecoration(labelText: 'Reps', border: OutlineInputBorder()),
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      validator: (value) => (value == null || value.isEmpty) ? 'Req.' : null,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _weightController,
                      decoration: const InputDecoration(labelText: 'Peso (kg)', border: OutlineInputBorder()),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      validator: (value) => (value == null || value.isEmpty) ? 'Req.' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // --- Botón para Añadir Serie ---
              ElevatedButton.icon(
                onPressed: () => _addSet(provider),
                icon: const Icon(Icons.add),
                label: const Text('Añadir Serie'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  textStyle: const TextStyle(fontSize: 16),
                ),
              ),
              const SizedBox(height: 24),
              const Divider(),

              // --- Lista de Series Agregadas ---
              Text('Series Completadas', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              if (sets.isEmpty)
                const Center(child: Padding(
                  padding: EdgeInsets.all(24.0),
                  child: Text('Aún no has añadido ninguna serie.'),
                ))
              else
                // Usamos un ListView para mostrar las series dinámicamente
                ListView.builder(
                  shrinkWrap: true, // Para que el ListView no ocupe toda la pantalla
                  physics: const NeverScrollableScrollPhysics(), // Para que no haga scroll por sí mismo
                  itemCount: sets.length,
                  itemBuilder: (context, index) {
                    final set = sets[index];
                    return Card(
                      child: ListTile(
                        leading: CircleAvatar(child: Text('${index + 1}')),
                        title: Text('${set.reps} reps', style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text('${set.weight} kg'),
                        // Aquí podríamos añadir un botón para eliminar la serie
                      ),
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}