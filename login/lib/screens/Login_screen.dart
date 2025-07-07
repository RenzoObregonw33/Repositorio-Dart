import 'package:flutter/material.dart';
import 'package:login/screens/password_reset_screen.dart';
import 'package:login/widgets/login_button.dart';

class LoginScreem extends StatefulWidget {
  const LoginScreem({super.key});

  @override
  State<LoginScreem> createState() => _LoginScreemState();
}

class _LoginScreemState extends State<LoginScreem> {
  final TextEditingController _usernameController = TextEditingController();    //Controlador de email
  final TextEditingController _passwordController = TextEditingController();    //Controlador de password


  String? _emailError;              //Mensaje de error para email
  String? _passwordError;           //Mensaje de error para contraseña

  bool _ocultarPassword = true;     //Contraseña oculta al escribir

 
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
      backgroundColor: const Color(0xFFF5F8FC),
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                height: 70,
                child: Image.asset('assets/lumina.png', height: 100),
              ),
              SizedBox(height: 50),
              Text(
                'Bienvenido',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[700],
                ),
              ),
              SizedBox(height: 10),
              Text(
                'Por favor, inicia sesión para continuar',
                style: TextStyle(color: Colors.grey[700]),
              ),
              SizedBox(height: 30),

              //TextField de Email
              TextField(
                controller: _usernameController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(
                    Icons.person_outline,
                    color: _emailError != null
                        ? Colors.red
                        : Colors.lightBlueAccent,
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
              SizedBox(height: 20),
              TextField(
                controller: _passwordController,
                obscureText: _ocultarPassword,
                decoration: InputDecoration(
                  labelText: 'Contraseña',
                  prefixIcon: Icon(
                    Icons.lock_outline,
                    color: _passwordError != null
                        ? Colors.red
                        : Colors.lightBlueAccent,
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

              //Boton Inicio de sesion
              SizedBox(height: 30),
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

              SizedBox(height: 10),
              Align(
                alignment: Alignment.center,
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
                    'Olvidaste tu Contraseña',
                    style: TextStyle(
                      color: Colors.lightBlueAccent,
                      fontSize: 14,
                      decoration: TextDecoration.underline,
                      decorationColor: Colors.lightBlueAccent
                    ),
                  ),
                ),
              ),

            ],
          ),
        ),
      ),
    );
  }
}
