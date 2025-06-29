import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'screens/welcome_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const GymTrackApp());
}

class GymTrackApp extends StatelessWidget {
  const GymTrackApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GymTrack',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
      ),
      home: const WelcomeScreen(),
    );
  }
}
