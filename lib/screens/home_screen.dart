import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart'; // IMPORTANTE: Nueva importación
import 'exercise_list_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  // El método para cerrar sesión no cambia, sigue necesitando la instancia de FirebaseAuth.
  void _signOut(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    // No necesitamos un pushReplacement aquí, porque el AuthStateHandler
    // se encargará de reconstruir y mostrar la pantalla de Login automáticamente.
    // Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
    //   MaterialPageRoute(builder: (context) => LoginScreen()),
    //   (route) => false,
    // );
    // De hecho, con Provider, a menudo no necesitamos hacer nada después de signOut.
    // El cambio de estado del usuario (a null) hará que el AuthStateHandler
    // nos redirija solo.
  }

  @override
  Widget build(BuildContext context) {
    // --- CAMBIO ---
    // Obtenemos el usuario del Provider. Es más limpio y eficiente.
    final user = context.watch<User?>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('GimFit - Inicio'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _signOut(context),
            tooltip: 'Cerrar sesión',
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                // Usamos el objeto 'user' que obtuvimos del Provider.
                '¡Bienvenido, ${user?.email ?? 'Usuario'}!',
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              const Text(
                '¿Qué entrenamos hoy?',
                style: TextStyle(fontSize: 20),
              ),
              // Aquí en el futuro mostraremos la rutina del día.
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const ExerciseListScreen()),
          );
        },
        label: const Text('Ejercicios'),
        icon: const Icon(Icons.fitness_center),
        tooltip: 'Ver Mis Ejercicios',
      ),
    );
  }
}