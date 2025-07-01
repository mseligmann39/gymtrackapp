import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';

// Importaciones para localización
import 'package:flutter_localizations/flutter_localizations.dart';

import 'screens/welcome_screen.dart';
import 'screens/home_screen.dart';
import 'firebase_options.dart'; // Asegúrate de que este import sea correcto

void main() async {
  // Asegura que los bindings de Flutter estén inicializados
  WidgetsFlutterBinding.ensureInitialized();
  // Inicializa Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  // Corre la aplicación
  runApp(const GimFitApp());
}

class GimFitApp extends StatelessWidget {
  const GimFitApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Envolvemos la app en MultiProvider para gestionar el estado
    return MultiProvider(
      providers: [
        // Este provider escucha los cambios de autenticación de Firebase
        StreamProvider<User?>.value(
          value: FirebaseAuth.instance.authStateChanges(),
          initialData: null,
        ),
      ],
      // El hijo del provider es nuestra aplicación principal
      child: MaterialApp(
        title: 'GimFit',
        debugShowCheckedModeBanner: false,

        // --- CONFIGURACIÓN DE TEMA ---
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
          appBarTheme: const AppBarTheme(
            elevation: 2,
            backgroundColor: Colors.white,
            foregroundColor: Colors.black87,
          ),
          cardTheme: CardThemeData(
            elevation: 1,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),

        // --- CONFIGURACIÓN DE LOCALIZACIÓN (AQUÍ ES DONDE VA) ---
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('en', ''), // Inglés
          Locale('es', ''), // Español
        ],
        locale: const Locale('es'), // Opcional: Forzar el idioma a español

        // La pantalla de inicio es manejada por nuestro AuthStateHandler
        home: const AuthStateHandler(),
      ),
    );
  }
}

// Este widget decide qué pantalla mostrar basado en el estado de autenticación
class AuthStateHandler extends StatelessWidget {
  const AuthStateHandler({super.key});

  @override
  Widget build(BuildContext context) {
    // Escuchamos el estado del usuario provisto por nuestro StreamProvider
    final user = context.watch<User?>();

    // Si hay un usuario, mostramos la HomeScreen
    if (user != null) {
      return const HomeScreen();
    } 
    // Si no, mostramos la WelcomeScreen para que inicie sesión o se registre
    else {
      return const WelcomeScreen();
    }
  }
}
