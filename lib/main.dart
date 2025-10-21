import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart'; // Import Firebase
import 'firebase_options.dart'; // Import generated Firebase options
import 'screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Ensure binding is initialized
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform, // Use generated options
  );
  runApp(const QuickTaskApp());
}

class QuickTaskApp extends StatelessWidget {
  const QuickTaskApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'QuickTask',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const SplashScreen(), // Keep your existing splash screen
    );
  }
}