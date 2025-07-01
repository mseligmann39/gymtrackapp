// lib/screens/home_screen.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';

import 'exercise_list_screen.dart';
import 'history_screen.dart'; // Importamos la nueva pantalla

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _signOut(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<User?>();

    return Scaffold(
      // Un fondo sutil para darle un toque más premium
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('GimFit', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _signOut(context),
            tooltip: 'Cerrar sesión',
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // --- Saludo al usuario ---
          Text(
            '¡Hola,',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          Text(
            user?.displayName ?? user?.email ?? 'Campeón/a',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple,
                ),
          ),
          const SizedBox(height: 24),

          // --- Tarjeta de Acción Principal: Iniciar Entrenamiento ---
          _buildActionCard(
            context: context,
            title: 'Iniciar Entrenamiento',
            subtitle: 'Elige un ejercicio y empieza a registrar',
            icon: Icons.play_circle_fill,
            color: Colors.deepPurple,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const ExerciseListScreen()),
              );
            },
          ),
          const SizedBox(height: 16),

          // --- Tarjetas de Acciones Secundarias ---
          Row(
            children: [
              // --- Tarjeta para ver el Historial ---
              Expanded(
                child: _buildActionCard(
                  context: context,
                  title: 'Historial',
                  subtitle: 'Revisa tus sesiones pasadas',
                  icon: Icons.history,
                  color: Colors.orange,
                  onTap: () {
                    // Navegamos a la nueva pantalla de historial
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const HistoryScreen()),
                    );
                  },
                ),
              ),
              const SizedBox(width: 16),
              // --- Tarjeta para gestionar Ejercicios ---
              Expanded(
                child: _buildActionCard(
                  context: context,
                  title: 'Ejercicios',
                  subtitle: 'Crea y edita tus movimientos',
                  icon: Icons.fitness_center,
                  color: Colors.blue,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const ExerciseListScreen()),
                    );
                  },
                ),
              ),
            ],
          ),
          // Aquí podríamos añadir más tarjetas en el futuro:
          // - "Mi Plan Semanal"
          // - "Estadísticas de Progreso"
        ],
      ),
    );
  }

  // --- Widget reutilizable para crear las tarjetas ---
  Widget _buildActionCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      clipBehavior: Clip.antiAlias, // Para que el InkWell no se salga de los bordes redondeados
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [color.withOpacity(0.8), color],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, size: 40, color: Colors.white),
              const SizedBox(height: 16),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(color: Colors.white.withOpacity(0.9)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}