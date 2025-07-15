import 'package:flutter/material.dart';   // paquete principal para construir interfaces gráficas Android
import 'package:flutter/cupertino.dart';  
import 'package:login/screens/Login_screen.dart';

// Función principal que inicia la aplicación
void main() => runApp(const MyApp());

// Clase principal de la app, que extiende StatelessWidget (no tiene estado interno)
class MyApp extends StatelessWidget {
  // Define un color primario personalizado para usar en toda la app
  final Color primaryColor = const Color(0xFFF3B83C);
  const MyApp({super.key});                                //Constructor

  //Widget Principal
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Login App',               
      theme: ThemeData(                                   //tema visual
        primaryColor: primaryColor,                       //usado en botones, íconos, etc
        colorScheme: ColorScheme.fromSwatch().copyWith(   //hace color personalizado
          primary: primaryColor,                          // cambia el color del foco
        ),
        inputDecorationTheme: InputDecorationTheme(       //Estilo para el textField
          focusedBorder: OutlineInputBorder(              //Borde 
            borderSide: BorderSide(color: primaryColor, width: 2),
            borderRadius: BorderRadius.circular(10),
          ),
          enabledBorder: OutlineInputBorder(              // Borde cuando el campo está habilitado pero no enfocado
            borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
            borderRadius: BorderRadius.circular(10),
          ),
          filled: true,                                   // Fondo blanco para los campos de texto
          fillColor: Colors.white,
        ),
      ),
      home: const LoginScreem()
    );
  }
}