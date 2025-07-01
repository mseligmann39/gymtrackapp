import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/routine.dart';
import '../services/routine_service.dart';
// Importamos la pantalla de creación/edición
import 'create_edit_routine_screen.dart';

class RoutinesListScreen extends StatelessWidget {
  const RoutinesListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<User?>();
    final routineService = RoutineService();

    if (user == null) {
      return const Scaffold(
        body: Center(child: Text("Inicia sesión para ver tus rutinas.")),
      );
    }

    // Función centralizada para navegar a la pantalla de creación/edición
    void _navigate(Routine? routine) {
      Navigator.of(context).push(
        MaterialPageRoute(
          // Le pasamos la rutina a editar, o null si es una nueva
          builder: (_) => CreateEditRoutineScreen(routineToEdit: routine),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Rutinas'),
      ),
      body: StreamBuilder<List<Routine>>(
        // El StreamBuilder escucha en tiempo real las rutinas del usuario
        stream: routineService.getRoutinesStream(user.uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error al cargar rutinas: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.list_alt_rounded, size: 80, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('Aún no has creado ninguna rutina.', style: TextStyle(fontSize: 18)),
                  Text('Usa el botón + para crear tu primer plan.', style: TextStyle(color: Colors.grey)),
                ],
              ),
            );
          }

          final routines = snapshot.data!;
          return ListView.builder(
            itemCount: routines.length,
            itemBuilder: (context, index) {
              final routine = routines[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  leading: const Icon(Icons.assignment_outlined, color: Colors.green, size: 30),
                  title: Text(routine.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('${routine.exerciseIds.length} ejercicios'),
                  trailing: const Icon(Icons.edit),
                  // Al tocar, navegamos a la pantalla de edición pasándole la rutina
                  onTap: () => _navigate(routine),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        // Al pulsar, navegamos a la pantalla de creación sin pasarle ninguna rutina (null)
        onPressed: () => _navigate(null),
        child: const Icon(Icons.add),
        tooltip: 'Crear Rutina',
      ),
    );
  }
}
