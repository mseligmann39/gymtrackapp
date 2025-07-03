import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'routines_list_screen.dart';
import 'history_screen.dart';
import 'profile_screen.dart'; // Importamos la nueva pantalla de perfil

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  // --- CAMBIO AQUÍ ---
  // Actualizamos la lista de pantallas para incluir el perfil
  static const List<Widget> _widgetOptions = <Widget>[
    HomeScreen(),
    RoutinesListScreen(isSelectionMode: true),
    HistoryScreen(),
    ProfileScreen(), // Reemplazamos StatsScreen con ProfileScreen
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        // --- CAMBIO AQUÍ ---
        // Actualizamos los items de la barra de navegación
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Inicio',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.play_circle_outline),
            activeIcon: Icon(Icons.play_circle),
            label: 'Entrenar',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history_outlined),
            activeIcon: Icon(Icons.history),
            label: 'Historial',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline), // Icono de perfil
            activeIcon: Icon(Icons.person),
            label: 'Perfil', // Etiqueta de perfil
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
      ),
    );
  }
}
