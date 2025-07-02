import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';

import 'exercise_list_screen.dart';
import 'history_screen.dart';
import 'routines_list_screen.dart';
import 'stats_screen.dart'; // <-- AÑADE ESTA IMPORTACIÓN

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _signOut(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<User?>();

    return Scaffold(
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
          // ... (Saludo y tarjeta de Iniciar Entrenamiento)
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
          _buildActionCard(
            context: context,
            title: 'Iniciar Entrenamiento',
            subtitle: 'Elige una rutina para empezar',
            icon: Icons.play_circle_fill,
            color: Colors.deepPurple,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const RoutinesListScreen(isSelectionMode: true)),
              );
            },
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              // ... (Tarjetas de Historial y Ejercicios)
              Expanded(
                child: _buildActionCard(
                  context: context,
                  title: 'Historial',
                  subtitle: 'Revisa tus sesiones pasadas',
                  icon: Icons.history,
                  color: Colors.orange,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const HistoryScreen()),
                    );
                  },
                ),
              ),
              const SizedBox(width: 16),
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
          const SizedBox(height: 16),
          _buildActionCard(
            context: context,
            title: 'Mis Rutinas',
            subtitle: 'Crea y edita tus planes',
            icon: Icons.assignment,
            color: Colors.green,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const RoutinesListScreen()),
              );
            },
          ),
          const SizedBox(height: 16),
          
          // --- NUEVA TARJETA DE ESTADÍSTICAS ---
          _buildActionCard(
            context: context,
            title: 'Mi Progreso',
            subtitle: 'Visualiza tus estadísticas',
            icon: Icons.bar_chart,
            color: Colors.redAccent,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const StatsScreen()),
              );
            },
          ),
        ],
      ),
    );
  }

  // ... (El método _buildActionCard no cambia)
  Widget _buildActionCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      clipBehavior: Clip.antiAlias,
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
