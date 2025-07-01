// lib/screens/history_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart'; // Para formatear fechas

import '../models/workout_session.dart';
import '../services/workout_service.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<User?>();
    final workoutService = WorkoutService();

    if (user == null) {
      return const Scaffold(
        body: Center(child: Text("Inicia sesión para ver tu historial.")),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Historial de Entrenamientos'),
      ),
      body: StreamBuilder<List<WorkoutSession>>(
        stream: workoutService.getWorkoutHistoryStream(user.uid),
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
                  Icon(Icons.history_toggle_off, size: 80, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('Aún no tienes entrenamientos', style: TextStyle(fontSize: 18)),
                  Text('¡Completa tu primera sesión para verla aquí!', style: TextStyle(color: Colors.grey)),
                ],
              )
            );
          }

          final sessions = snapshot.data!;
          return ListView.builder(
            itemCount: sessions.length,
            itemBuilder: (context, index) {
              final session = sessions[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  leading: const Icon(Icons.event_note, color: Colors.deepPurple),
                  title: Text(
                    // Formateamos la fecha para que sea legible, ej: "Lunes, 24 de junio"
                    DateFormat.yMMMMEEEEd('es_ES').format(session.date),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text('${session.exercises.length} ejercicios completados'),
                  // Podríamos añadir onTap para ver los detalles de la sesión
                ),
              );
            },
          );
        },
      ),
    );
  }
}