import 'package:flutter/material.dart';
import 'package:login/api_services.dart';
import 'package:login/screems/home_screem.dart';

class LoginScreem extends StatefulWidget {
  const LoginScreem({super.key});

  @override
  State<LoginScreem> createState() => _LoginScreemState();
}

class _LoginScreemState extends State<LoginScreem> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  String? _errorMessage;
  String? _emailError;
  String? _passwordError;

  bool _ocultarPassword = true;
  bool _emailVacio = false;
  bool _passwordVacio = false;

  //Sobreescribir api
  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  //Validacion del email
  void _validarEmail() {
  String email = _usernameController.text.trim();
  String password = _passwordController.text;

  setState(() {
    _emailVacio = email.isEmpty;
    _passwordVacio = password.isEmpty;

    if (_emailVacio || _passwordVacio) {
      _errorMessage = 'Este campo no puede estar vacio';
    } else if (!_esEmailValido(email)) {
      _errorMessage = 'Ingrese un email valido';
    } else {
      _errorMessage = null;
    }
  });
}


  //Estructura de escritura del Email
  bool _esEmailValido(String email) {
    String emailPattern = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';
    RegExp regex = RegExp(emailPattern);
    return regex.hasMatch(email);
  }
/*void _login() {
    final username = _usernameController.text;
    final password = _passwordController.text;
  

    if (username == 'admin' && password == '1234') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => HomeScreem(username: username)),
      );
    } else {
      setState(() {
        _errorMessage = 'Usuario o contraseña incorrectos';
      });
    }
  }*/

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
                child: Image.asset('assets/lumina.png',
                height: 100,
                ),
              ),
              SizedBox(height: 50),
              Text(
                'Bienvenido',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.grey[700]),
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
                  labelStyle: TextStyle(color: _emailVacio ? Color(0xFFF7596E) : Colors.grey[700],),
                  prefixIcon: Icon(Icons.person_outline, color: _emailVacio ? Color(0xFFF7596E): Colors.lightBlueAccent,),
                  suffixIcon: _emailVacio
                    ? Icon(Icons.error_outline, color: Color(0xFFF7596E))
                    : null,
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: _emailVacio? Color(0xFFF7596E) : Colors.grey.shade300,
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                    color: _emailVacio ? Color(0xFFF7596E): Colors.lightBlueAccent,
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    // Limpiar el error y restablecer colores cuando se escribe
                    _emailVacio = false;
                    _errorMessage = null;
                  });
                }  
              ),


              if (_emailVacio)
                Padding(
                padding: const EdgeInsets.only(top: 5),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Este campo debe ser llenado',
                    style: TextStyle(color: Colors.red, fontSize: 12),
                  ),
                ),
              ),

              //TextField de Password

              SizedBox(height: 20),
              TextField(
                controller: _passwordController,
                keyboardType: TextInputType.emailAddress,
                obscureText: _ocultarPassword,
                decoration: InputDecoration(
                  labelText: 'Contraseña',
                  labelStyle: TextStyle(color: _passwordVacio ? Color(0xFFF7596E) : Colors.grey[700],),
                  prefixIcon: Icon(Icons.lock_outline, color: _passwordVacio ? Color(0xFFF7596E) : Colors.lightBlueAccent,),
                  suffixIcon: IconButton(
                  onPressed: () {
                    setState(() {
                      _ocultarPassword = !_ocultarPassword;
                    });
                  },
                  icon: Icon(_ocultarPassword
                      ? Icons.visibility_off
                      : Icons.visibility, color: Colors.grey[700],),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: _passwordVacio? Color(0xFFF7596E) : Colors.grey.shade300,
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                    color: _passwordVacio ? Color(0xFFF7596E): Colors.lightBlueAccent,
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    // Limpiar el error y restablecer colores cuando se escribe
                    _passwordVacio = false;
                    _errorMessage = null;
                  });
                }     
              ),

              if (_passwordVacio)
                Padding(
                padding: const EdgeInsets.only(top: 5),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Este campo debe ser llenado',
                    style: TextStyle(color: Colors.red, fontSize: 12),
                  ),
                ),
              ),

              /*if (_errorMessage != null) ...[
                SizedBox(height: 10),
                Text(_errorMessage!,
                    style: TextStyle(color: Colors.red, fontSize: 14)),
              ],*/
              SizedBox(height: 30),
              ElevatedButton(
                onPressed: _validarEmail,
                //_login,
                /*() {
                  String email = _usernameController.text.trim();
                  String password = _passwordController.text;
                  loginUser(
                    email: email,
                    password: password,
                    lumina: 1,
                  );
                },*/  //
                child: Text(
                  'Iniciar Sesión', 
                  style: TextStyle(fontSize: 16, color: Colors.lightBlue )
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}