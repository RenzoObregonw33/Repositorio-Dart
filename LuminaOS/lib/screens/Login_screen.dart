import 'package:flutter/material.dart';
import 'package:login/screens/password_reset_screen.dart';
import 'package:login/widgets/login_button.dart';
import 'package:login/widgets/secure_storage_service.dart';


class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreemState();
}

class _LoginScreemState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();    //Controlador de email
  final TextEditingController _passwordController = TextEditingController();    //Controlador de password
  

  String? _emailError;              //Mensaje de error para email
  String? _passwordError;           //Mensaje de error para contraseña
  bool _ocultarPassword = true;     //Contraseña oculta al escribir

  @override void initState() { 
    super.initState(); 
    // Cargar credenciales después de que el widget esté completamente construido 
    WidgetsBinding.instance.addPostFrameCallback((_) { 
      _cargarCredencialesGuardadas(); 
    }); 
  }

  // Cargar credenciales guardadas al iniciar la pantalla 
  Future<void> _cargarCredencialesGuardadas() async { 
    final bool tieneCredenciales = await 
    SecureStorageService.hasCredentials(); 
    if (tieneCredenciales) { 
      final credenciales = await SecureStorageService.getCredentials(); 
      setState(() { 
        _usernameController.text = credenciales['email'] ?? ''; 
        _passwordController.text = credenciales['password'] ?? ''; 
      }); 
    } 
  }

  //Sobreescribir api
  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override

  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 30, vertical: 40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Hola de nuevo!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF3D2A6A),
                  fontFamily: '-apple-system'
                ),
              ),
              SizedBox(height: 10),
              Text(
                'Bienvenido de regreso,',
                style: TextStyle( 
                fontSize: 16,
                fontFamily: '-apple-system', // Tu fuente principal (como una sola String)
                fontFamilyFallback: [
                  'system-ui',
                  'Segoe UI',
                  'roboto',
                  'helvetica',
                  'arial',
                  'sans-serif',
                  'Apple Color Emoji',
                  'Segoe UI Emoji',
                  'Segoe UI Symbol',
                ]),
              ),
              Text('te extrañamos!',
                style: TextStyle( 
                fontSize: 16,
                fontFamily: '-apple-system', // Tu fuente principal (como una sola String)
                fontFamilyFallback: [
                  'system-ui',
                  'Segoe UI',
                  'roboto',
                ]),
              ),

              SizedBox(height: 50),

              //TextField de Email
              TextField(
                controller: _usernameController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'Email',
                  labelStyle: TextStyle(fontFamily: '-apple-system',color: Colors.grey),
                  prefixIcon: Icon(
                    Icons.person_outline,
                    color: _emailError != null
                        ? Colors.red
                        : Color(0xFF3D2A6A),
                  ),
                  suffixIcon: _emailError != null
                      ? Icon(Icons.error_outline, color: Colors.red)
                      : null,
                  errorText: _emailError,
                ),
                onChanged: (value) {
                  setState(() {
                    _emailError = null;
                  });
                },
              ),

              //TextField de Password
              SizedBox(height: 10),
              TextField(
                controller: _passwordController,
                obscureText: _ocultarPassword,
                decoration: InputDecoration(
                  labelText: 'Contraseña',
                  labelStyle: TextStyle(fontFamily: '-apple-system',color: Colors.grey),
                  prefixIcon: Icon(
                    Icons.lock_outline,
                    color: _passwordError != null
                        ? Colors.red
                        : Color(0xFF3D2A6A),
                  ),
                  suffixIcon: _passwordError != null
                      ? Icon(Icons.error_outline, color: Colors.red)
                      : IconButton(
                          onPressed: () {
                            setState(() {
                              _ocultarPassword = !_ocultarPassword;
                            });
                          },
                          icon: Icon(
                            color: Colors.grey,
                            _ocultarPassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                        ),
                  errorText: _passwordError,
                ),
                onChanged: (value) {
                  setState(() {
                    _passwordError = null;
                  });
                },
              ),

              //olvidaste contraseña
              SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(                  //Reestablercer contraseña
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PasswordResetScreen(),
                      ),
                    );
                  },
                  child: Text(
                    'Recuperar Contraseña',
                    style: TextStyle(
                      color: Color(0xFF3D2A6A),
                      fontSize: 14,
                      /*decoration: TextDecoration.underline,
                      decorationColor: Color(0xFF3D2A6A),*/
                      fontFamily: '-apple-system'
                    ),
                  ),
                ),
              ),

              //Boton Inicio de sesion
              SizedBox(height: 10),
              LoginButton(
                emailController: _usernameController,
                passwordController: _passwordController,
                onError: ({String? emailError, String? passwordError}) {
                  setState(() {
                    _emailError = emailError;
                    _passwordError = passwordError;
                  });
                },
              ),
              SizedBox(height: 240),
              SizedBox(
                height: 30,
                child: Image.asset('assets/logolumina.png', height: 100),
              ),
              
            ],
          ),
        ),
      ),
    );
  
  }
}

