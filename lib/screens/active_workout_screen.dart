import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../providers/workout_provider.dart';

class ActiveWorkoutScreen extends StatefulWidget {
  const ActiveWorkoutScreen({super.key});

  @override
  State<ActiveWorkoutScreen> createState() => _ActiveWorkoutScreenState();
}

class _ActiveWorkoutScreenState extends State<ActiveWorkoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _repsController = TextEditingController();
  final _weightController = TextEditingController();
  bool _isFinishing = false;

  @override
  void dispose() {
    _repsController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  void _addSet(WorkoutProvider provider) {
    if (_formKey.currentState?.validate() ?? false) {
      final reps = int.tryParse(_repsController.text) ?? 0;
      final weight = double.tryParse(_weightController.text) ?? 0.0;
      provider.addSet(reps, weight);
      _repsController.clear();
      _weightController.clear();
      FocusScope.of(context).unfocus();
    }
  }

  Future<void> _finishWorkout(WorkoutProvider provider) async {
    final user = context.read<User?>();
    if (user == null) return;
    setState(() => _isFinishing = true);
    try {
      await provider.finishWorkout(user.uid);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('¡Entrenamiento guardado con éxito!')),
      );
      Navigator.of(context).pop();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al guardar: $e')),
      );
    } finally {
      if (mounted) setState(() => _isFinishing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<WorkoutProvider>();
    final currentExercise = provider.currentExercise;
    // Obtenemos la lista de series del ejercicio actual
    final sets = provider.loggedExercises.last.sets;

    return Scaffold(
      appBar: AppBar(
        title: Text('${provider.currentExerciseNumber}/${provider.totalExercises} - ${currentExercise.name}'),
        actions: [
          if (_isFinishing)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
            )
          else
            // El botón de finalizar ahora es un icono
            IconButton(
              icon: const Icon(Icons.check_circle),
              onPressed: () => _finishWorkout(provider),
              tooltip: 'Finalizar Entrenamiento',
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
              // ... (Campos de texto y botón de añadir serie no cambian)
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
              Text('Series Completadas', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              if (sets.isEmpty)
                const Center(child: Padding(
                  padding: EdgeInsets.all(24.0),
                  child: Text('Aún no has añadido ninguna serie.'),
                ))
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: sets.length,
                  itemBuilder: (context, index) {
                    final set = sets[index];
                    return Card(
                      child: ListTile(
                        leading: CircleAvatar(child: Text('${index + 1}')),
                        title: Text('${set.reps} reps', style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text('${set.weight} kg'),
                      ),
                    );
                  },
                ),
              const SizedBox(height: 24),
              
              // --- BOTÓN PARA SIGUIENTE EJERCICIO ---
              // Solo se muestra si no es el último ejercicio
              if (!provider.isLastExercise)
                OutlinedButton.icon(
                  onPressed: () => provider.nextExercise(),
                  icon: const Icon(Icons.skip_next_rounded),
                  label: const Text('Siguiente Ejercicio'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                )
            ],
          ),
        ),
      ),
    );
  }
}
