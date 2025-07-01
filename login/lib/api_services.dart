import 'dart:convert';
import 'package:http/http.dart' as http;

Future<Map<String, dynamic>> loginUser({
  required String email,
  required String password,
  required int lumina,
}) async {
  final url = Uri.parse('https://rhnube.com.pe/api/web_services/login');

  try {
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
        'lumina': lumina,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return {'success': true, 'data': data};
    } else if (response.statusCode == 401) {
      return {
        'success': false,
        'message': 'Credenciales incorrectas'
      };
    } else {
      return {'success': false, 'message': 'Error: ${response.statusCode}'};
    }
  } catch (e) {
    return {'success': false, 'message': 'Error de conexión: $e'};
  }
}
//verificacion de tokens