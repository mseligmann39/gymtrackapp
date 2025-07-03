import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'stats_screen.dart';
import 'edit_profile_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Usamos context.watch para que la pantalla se redibuje si el perfil cambia
    final user = context.watch<User?>();

    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('Usuario no encontrado.')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Perfil'),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 20.0),
        children: <Widget>[
          CircleAvatar(
            radius: 50,
            backgroundColor: Colors.grey.shade300,
            backgroundImage: user.photoURL != null ? NetworkImage(user.photoURL!) : null,
            child: user.photoURL == null
                ? Icon(Icons.person, size: 50, color: Colors.grey.shade800)
                : null,
          ),
          const SizedBox(height: 10),
          Center(
            child: Text(
              user.displayName ?? 'Sin nombre',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          Center(
            child: Text(
              user.email ?? '',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey),
            ),
          ),
          const SizedBox(height: 30),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.edit_outlined),
            title: const Text('Editar Perfil'),
            subtitle: const Text('Cambiar nombre o foto'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const EditProfileScreen()),
              );
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.bar_chart_outlined),
            title: const Text('Ver mi Progreso'),
            subtitle: const Text('Estadísticas y gráficos de rendimiento'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const StatsScreen()),
              );
            },
          ),
          const Divider(),
        ],
      ),
    );
  }
}
