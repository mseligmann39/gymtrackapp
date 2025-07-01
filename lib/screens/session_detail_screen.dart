import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/workout_session.dart';

class SessionDetailScreen extends StatelessWidget {
  // La pantalla recibe la sesión de entrenamiento que queremos mostrar
  final WorkoutSession session;

  const SessionDetailScreen({super.key, required this.session});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // El título de la pantalla será la fecha del entrenamiento
        title: Text(DateFormat.yMMMMEEEEd('es_ES').format(session.date)),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        // Creamos una tarjeta por cada ejercicio en la sesión
        itemCount: session.exercises.length,
        itemBuilder: (context, index) {
          final loggedExercise = session.exercises[index];
          return Card(
            elevation: 2,
            margin: const EdgeInsets.only(bottom: 16.0),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Nombre del ejercicio
                  Text(
                    loggedExercise.exerciseName,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                  ),
                  const Divider(height: 20, thickness: 1),
                  
                  // Creamos una lista de las series para este ejercicio
                  ListView.builder(
                    shrinkWrap: true, // Importante para anidar ListViews
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: loggedExercise.sets.length,
                    itemBuilder: (context, setIndex) {
                      final set = loggedExercise.sets[setIndex];
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: CircleAvatar(
                          backgroundColor: Colors.grey[200],
                          child: Text(
                            '${setIndex + 1}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        title: Text(
                          '${set.reps} repeticiones',
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                        trailing: Text(
                          '${set.weight} kg',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
