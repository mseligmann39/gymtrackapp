import 'package:flutter/material.dart';
import 'routines_list_screen.dart';
import 'exercise_list_screen.dart';

class ManagementScreen extends StatelessWidget {
  const ManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión'),
      ),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.assignment_outlined),
            title: const Text('Gestionar Mis Rutinas'),
            subtitle: const Text('Crear, editar y reordenar tus planes'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // Navega a la lista de rutinas en MODO GESTIÓN
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const RoutinesListScreen()),
              );
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.fitness_center_outlined),
            title: const Text('Gestionar Mis Ejercicios'),
            subtitle: const Text('Añadir o editar ejercicios de tu biblioteca'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // Navega a la lista de ejercicios
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const ExerciseListScreen()),
              );
            },
          ),
        ],
      ),
    );
  }
}
