import 'dart:convert';
import 'package:http/http.dart' as http;
//import 'package:shared_preferences/shared_preferences.dart';

class ApiGraphicsService {
  static const String _baseUrl = 'https://rhnube.com.pe';
  final String token; // Cambiado a final y non-nullable

  // Constructor ahora requiere token obligatorio
  ApiGraphicsService({required this.token});

  // Eliminamos _initializeToken() porque el token ahora es requerido

  Future<Map<String, dynamic>> fetchGraphicsData({
    required DateTime fechaIni,
    required DateTime fechaFin,
    required int organiId,
  }) async {
    // 1. Configuración automática del header
    final authHeader = token.startsWith('Bearer ') ? token : 'Bearer $token';

    // 2. Debug de la petición
    print('URL: $_baseUrl/api/v5/graficsLumina');
    print('Authorization: $authHeader');

    final response = await http.post(
      Uri.parse('$_baseUrl/api/v5/graficsLumina'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': token, // Usamos el header formateado
      },
      body: jsonEncode({
        'fecha_ini': _formatDate(fechaIni),
        'fecha_fin': _formatDate(fechaFin),
        'organi_id': organiId,
      }),
    );

    print('✅ Response: ${response.statusCode}');
    
    return _processResponse(response);
  }

  Map<String, dynamic> _processResponse(http.Response response) {
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Error ${response.statusCode}: ${response.body}');
    }
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}