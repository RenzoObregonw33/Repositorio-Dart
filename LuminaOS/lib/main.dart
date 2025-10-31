import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart'; // ← Para iOS
import 'dart:io'; // ← Para detectar plataforma
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
    // 🎯 DETECCIÓN AUTOMÁTICA DE PLATAFORMA
    if (Platform.isIOS) {
      return _buildIOSApp(); // 🍎 Estilo iOS nativo
    } else {
      return _buildAndroidApp(); // 🤖 Estilo Android Material
    }
  }

  // 🍎 Configuración para iOS (NUEVA) - SOLO MODO CLARO
  Widget _buildIOSApp() {
    return CupertinoApp(
      debugShowCheckedModeBanner: false,
      title: 'Lumina',
      theme: CupertinoThemeData(
        primaryColor: Color(0xFF7775E2),
        brightness: Brightness.light, // ← SOLO modo claro
        scaffoldBackgroundColor: CupertinoColors.systemBackground,
        textTheme: CupertinoTextThemeData(primaryColor: Color(0xFF7775E2)),
      ),
      // ✅ AGREGAR: Localizaciones para que funcionen los TextField
      localizationsDelegates: [
        DefaultMaterialLocalizations.delegate,
        DefaultCupertinoLocalizations.delegate,
        DefaultWidgetsLocalizations.delegate,
      ],
      supportedLocales: [const Locale('es', 'ES'), const Locale('en', 'US')],
      home: const LoginScreen(),
    );
  }

  // 🤖 Tu configuración actual para Android (SIN CAMBIOS)
  Widget _buildAndroidApp() {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Lumina',
      theme: ThemeData(
        primaryColor: Color(0xFF7775E2),
        scaffoldBackgroundColor: Colors.white,
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: const BorderSide(
              color: Colors.grey,
            ), // borde gris claro
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Color(0xFF6C63FF)),
            borderRadius: BorderRadius.circular(15),
          ),
          labelStyle: const TextStyle(
            color: Colors.black87,
          ), // color de texto en labels
          hintStyle: const TextStyle(
            color: Colors.grey,
          ), // hint text (ej: "ingrese usuario")
        ),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Colors.black87),
          bodyMedium: TextStyle(color: Colors.black87),
          titleLarge: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
          ),
          labelLarge: TextStyle(color: Colors.black87),
        ),
      ),
      home: const LoginScreen(),
    );
  }
}
