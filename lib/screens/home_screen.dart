import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login_screen.dart';
import 'add_exercise_screen.dart';
import 'exercise_list_screen.dart';
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _signOut(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.of(
      context,
    ).pushReplacement(MaterialPageRoute(builder: (_) => const LoginScreen()));
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      
      floatingActionButton: FloatingActionButton(
  onPressed: () {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const ExerciseListScreen()),
    );
  },
  child: const Icon(Icons.fitness_center),
  tooltip: 'Ver Ejercicios',
),
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
        child: Text(
          '¡Bienvenido, ${user?.email ?? 'Usuario'}!',
          style: const TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
