import 'dart:convert';                            //Convierte datos de Json
import 'package:http/http.dart' as http;          //Para hacer peticiones en http
import 'package:shared_preferences/shared_preferences.dart';


// Función asíncrona que intenta iniciar sesión con email, contraseña y lumina
Future<Map<String, dynamic>> loginUser({                      //Future<> devuelve un valor en el futuro (peticion)
  required String email,                                      
  required String password,
  required int lumina,
}) async {                                            //función va a ejecutar operaciones que toman tiempo (como esperar una respuesta del servidor) 
  final url = Uri.parse('https://rhnube.com.pe/api/web_services/login');  //combierte el string en URI

  try {
    final response = await http.post(    //http.post(...) es una función que hace una solicitud HTTP al servidor. Como esta operación puede tardar (por la red), se usa await para decirle a Dart:
      url,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({
        'email': email,
        'password': password,
        'lumina': lumina,
      }),
    );

    // Imprime el código de estado y el cuerpo de la respuesta para depuración
    print(response.statusCode);
    print(response.body);

    // Si la respuesta es exitosa (200), se decodifica el JSON y se retorna
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);                 //convierte Json en un objeto
      final token = data['token']; // <-- extrae el token

      // Guardarlo localmente
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', token); // Guarda con la clave 'auth_token'
      
      return {'success': true, 'data': data};

    // Si el usuario no está autorizado (401)
    } else if (response.statusCode == 401) {
      return {
        'success': false,
        'message': 'Contraseña Incorrecta'
      };

    // Si faltan campos requeridos (422)
    } else if (response.statusCode == 422) {
      return {
        'success': false,
        'message': 'Debe ingresar correo y contraseña'
      };
    } else {                                // Otros errores
      return {'success': false, 'message': 'Error: ${response.statusCode}'};
    }
  } catch (e) {                             // Si ocurre un error de red o excepción
    return {'success': false, 'message': 'Error de conexión: $e'};
  }
}

// Función asíncrona para solicitar el reinicio de contraseña
Future<Map<String, dynamic>> resetPassword({required String email}) async {
  // URL del endpoint para resetear contraseña
  final url = Uri.parse('https://rhnube.com.pe/api/web_services/password-reset');

  try {
    // Se envía una petición POST con el email
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({'email': email}),
    );

    // Imprime el código de estado y el cuerpo de la respuesta
    print(response.statusCode);
    print(response.body);
    
    // Si el correo fue enviado correctamente
    if (response.statusCode == 200) {
      return {'success': true, 'message': 'Correo enviado correctamente'};

    // Si hubo un error al enviar el correo
    } else if (response.statusCode == 400) {
      return {'success': false, 'message': 'Correo no enviado'};

    // Si hay errores de validación (por ejemplo, email inválido)
    } else if (response.statusCode == 422) {
      final body = jsonDecode(response.body);
      final errors = body['errors'] ?? {};
      final emailError = errors['email']?[0];

      return {
        'success': false,
        'emailError': emailError,
        'message': body['message'] ?? 'Error de validación'
      };
    } else {                                      //otros errores
      return {'success': false, 'message': 'Error: ${response.statusCode}'};
    }
  } catch (e) {                                   //Si ocurre otro error como red
    return {'success': false, 'message': 'Error de conexión: $e'};
  }
}
