import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
//import 'package:shared_preferences/shared_preferences.dart';

class ApiGraphicsService {
  static const String _baseUrl = 'https://rhnube.com.pe';
  final String token; // Cambiado a final y non-nullable
  final int organiId; // ID de la organización, puede ser dinámico si es necesario

  // Constructor ahora requiere token obligatorio
  ApiGraphicsService({required this.token, required this.organiId,});

  // Eliminamos _initializeToken() porque el token ahora es requerido

  Future<Map<String, dynamic>> fetchGraphicsData({
    required DateTime fechaIni,
    required DateTime fechaFin,
    required int organiId,
    List<int>? empleadosIds, // Lista de IDs de empleados opcional
  }) async {
    // 1. Configuración automática del header
    final authHeader = token.startsWith('Bearer ') ? token : 'Bearer $token';

    // 2. Debug de la petición
    print('URL: $_baseUrl/api/v5/graficsLumina');
    print('Authorization: $authHeader');

    // Crear el cuerpo de la petición
    final body = {
      'fecha_ini': _formatDate(fechaIni),
      'fecha_fin': _formatDate(fechaFin),
      'organi_id': organiId,
      if (empleadosIds != null && empleadosIds.isNotEmpty) 
      'empleados': empleadosIds,
    };

    // AÑADE AQUÍ EL debugPrint PARA VER LOS DATOS QUE SE ENVIARÁN
    debugPrint('📤 Enviando a la API: ${jsonEncode(body)}');

    final response = await http.post(
      Uri.parse('$_baseUrl/api/v5/graficsLumina'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': token, // Usamos el header formateado
      },
      body: jsonEncode(body), // Usamos el body que ya creamos
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

  Future<Map<String, dynamic>> fetchFiltrosEmpresariales() async {
    try {
      final url = Uri.parse('https://rhnube.com.pe/api/fdee/filtros-datos-empresariales');
      
      final body = jsonEncode({
        'lumina': 1,
        'emple_estado': 1,
        'organi_id': organiId, // Usando la variable de instancia
      });

      final response = await http.post(
        url,
        headers: {
          'Authorization': token,
          'Content-Type': 'application/json',
        },
        body: body,
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Error ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      debugPrint('Error en fetchFiltrosEmpresariales: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> fetchEmpleados({List<String>? filtrosIds}) async {
    final url = Uri.parse('https://rhnube.com.pe/api/fdee/filtros-datos-empleados');
    
    final body = {
      'lumina': 1,
      'estado': 1,
      'combinar': false,
      'organi_id': organiId,
      if (filtrosIds != null && filtrosIds.isNotEmpty) 
      'query': filtrosIds,
    };

    final response = await http.post(
      url,
      headers: {
        'Authorization': token,
        'Content-Type': 'application/json',
      },
      body: jsonEncode(body),
    );

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