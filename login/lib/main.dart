import 'package:flutter/material.dart';
import 'package:login/screens/Login_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Lumina',
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: const Color(0xFFF3B83C),
        scaffoldBackgroundColor: Color(0xFF14171C),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Color(0xFFF3B83C)),
            borderRadius: BorderRadius.circular(15),
          ),
          labelStyle: const TextStyle(color: Colors.white), // color de texto en labels
          hintStyle: const TextStyle(color: Colors.white70), // hint text (ej: "ingrese usuario")
        ),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Colors.white),
          bodyMedium: TextStyle(color: Colors.white),
          titleLarge: TextStyle(color: Colors.white),
          labelLarge: TextStyle(color: Colors.white),
        ),
      ),
      home: const LoginScreen(),
    );
  }
}
