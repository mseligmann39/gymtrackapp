// En tu archivo main.dart

// ... (El resto de las importaciones y la clase GimFitApp no cambian)
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'screens/welcome_screen.dart';
// Importamos la nueva pantalla principal
import 'screens/main_screen.dart'; 
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const GimFitApp());
}

class GimFitApp extends StatelessWidget {
  const GimFitApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        StreamProvider<User?>.value(
          value: FirebaseAuth.instance.authStateChanges(),
          initialData: null,
        ),
      ],
      child: MaterialApp(
        title: 'GimFit',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('en', ''),
          Locale('es', ''),
        ],
        locale: const Locale('es'),
        home: const AuthStateHandler(),
      ),
    );
  }
}


// --- WIDGET ACTUALIZADO ---
class AuthStateHandler extends StatelessWidget {
  const AuthStateHandler({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<User?>();

    if (user != null) {
      // Si hay usuario, vamos a la nueva pantalla con navegación
      return const MainScreen();
    } else {
      // Si no, a la pantalla de bienvenida
      return const WelcomeScreen();
    }
  }
}
