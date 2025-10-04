import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';

void main() {
  runApp(QuickTaskApp());
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
      home: SplashScreen(),
    );
  }
}