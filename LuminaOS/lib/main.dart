import 'package:flutter/material.dart';
import 'package:luminaos/screens/Login_screen.dart';

void main() {
  // Configuración global para deshabilitar animaciones de Syncfusion
  WidgetsFlutterBinding.ensureInitialized();
  
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
        primaryColor: Color(0xFF7775E2),
        scaffoldBackgroundColor: Colors.white,
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: const BorderSide(color: Colors.grey), // borde gris claro
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Color(0xFF6C63FF)),
            borderRadius: BorderRadius.circular(15),
          ),
          labelStyle: const TextStyle(color: Colors.black87), // color de texto en labels
          hintStyle: const TextStyle(color: Colors.grey), // hint text (ej: "ingrese usuario")
        ),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Colors.black87),
          bodyMedium: TextStyle(color: Colors.black87),
          titleLarge: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
          labelLarge: TextStyle(color: Colors.black87),
        ),

      ),
      home: const LoginScreen(),
    );
  }
}
