import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart'; // IMPORTANTE: Nueva importación

import 'screens/welcome_screen.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Esta parte no cambia.
  await Firebase.initializeApp(
    // tus opciones de firebase_options.dart irán aquí si las especificas
  );
  runApp(const GimFitApp());
}

class GimFitApp extends StatelessWidget {
  const GimFitApp({super.key});

  @override
  Widget build(BuildContext context) {
    // --- CAMBIO PRINCIPAL ---
    // Envolvemos toda la app en un MultiProvider.
    // Esto nos permitirá "proveer" diferentes piezas de estado.
    return MultiProvider(
      providers: [
        // NUEVO: Este es nuestro primer "enchufe".
        // StreamProvider escucha el stream de authStateChanges y expone
        // el objeto User? más reciente a todos los widgets descendientes.
        StreamProvider<User?>.value(
          value: FirebaseAuth.instance.authStateChanges(),
          initialData: null,
        ),
      ],

      // En main.dart, dentro de tu widget GimFitApp
      child: MaterialApp(
        title: 'GimFit',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
          appBarTheme: const AppBarTheme(
            elevation: 2,
            backgroundColor: Colors.white,
            foregroundColor: Colors.black87,
          ),
          // --- CORRECCIÓN DEFINITIVA ---
          // 1. Cambiamos el nombre a CardThemeData
          // 2. Quitamos 'const' para asegurar la compatibilidad
          cardTheme: CardThemeData(
            elevation: 1,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        home: const AuthStateHandler(),
      ),
    );
  }
}

class AuthStateHandler extends StatelessWidget {
  const AuthStateHandler({super.key});

  @override
  Widget build(BuildContext context) {
    // --- CÓDIGO SIMPLIFICADO ---
    // Ya no necesitamos un StreamBuilder aquí.
    // Simplemente "consumimos" el usuario que nuestro StreamProvider ya nos da.
    // context.watch<User?>() se suscribe a los cambios del usuario.
    final user = context.watch<User?>();

    if (user != null) {
      // Si hay usuario logueado, va a home.
      return const HomeScreen();
    } else {
      // Si no hay usuario, va a welcome/login.
      return const WelcomeScreen();
    }
  }
}
