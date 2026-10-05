import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class ApiService {
  static String get baseUrl {
    final configuredUrl =
        dotenv.isInitialized ? dotenv.env['API_BASE_URL']?.trim() : null;
    if (configuredUrl != null && configuredUrl.isNotEmpty) {
      return configuredUrl.replaceFirst(RegExp(r'/$'), '');
    }

    // Si estás probando en Android físico o emulador:
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      return 'http://192.168.10.94:3000';
    }
    return 'http://localhost:3000';
  }

  static Future<Map<String, dynamic>> _post(
    String path,
    Map<String, dynamic> body,
  ) async {
    final url = '$baseUrl$path';
    debugPrint('🌐 Realizando POST a: $url con body: $body');

    try {
      final response = await http
          .post(
            Uri.parse(url),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 10));

      debugPrint(
          '📩 Respuesta recibida [${response.statusCode}]: ${response.body}');

      dynamic data;
      try {
        data = jsonDecode(response.body);
      } on FormatException {
        data = {'error': 'El servidor devolvió una respuesta inválida.'};
      }
      return {'statusCode': response.statusCode, 'data': data};
    } catch (e) {
      debugPrint('❌ Error en _post a $url: $e');
      rethrow; // Permite que el provider capture el tipo de error
    }
  }

  // Inicio de sesión
  static Future<Map<String, dynamic>> login(
      String email, String password) async {
    return _post('/login', {
      'email': email.trim(),
      'password': password.trim(),
    });
  }

  // Registro genérico
  static Future<Map<String, dynamic>> register({
    required String nombre,
    required String apellido,
    required String cedula,
    required String telefono,
    required String direccion,
    required String emprendimiento,
    required String password,
  }) async {
    return _post('/register', {
      'nombre': nombre.trim(),
      'apellido': apellido.trim(),
      'cedula': cedula.trim(),
      'telefono': telefono.trim(),
      'direccion': direccion.trim(),
      'emprendimiento': emprendimiento.trim(),
      'password': password.trim(),
    });
  }

  // Registro de cliente
  static Future<Map<String, dynamic>> registerCliente({
    required String nombre,
    required String apellido,
    required String telefono,
    required String password,
  }) async {
    return _post('/registerCliente', {
      'nombre': nombre.trim(),
      'apellido': apellido.trim(),
      'telefono': telefono.trim(),
      'password': password.trim(),
    });
  }

  // Registro de dueño de negocio
  static Future<Map<String, dynamic>> registerDueno({
    required String negocio,
    required String representante,
    required String telefono,
    required String ubicacion,
    required String horario,
    required String password,
  }) async {
    return _post('/registerDueno', {
      'negocio': negocio.trim(),
      'representante': representante.trim(),
      'telefono': telefono.trim(),
      'ubicacion': ubicacion.trim(),
      'horario': horario.trim(),
      'password': password.trim(),
    });
  }

  static Future<String> probarConexion() async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/status'))
          .timeout(const Duration(seconds: 5));
      if (response.statusCode == 200) {
        return response.body;
      } else {
        return "Error: ${response.statusCode}";
      }
    } catch (e) {
      return "Error de conexión: $e";
    }
  }

  // Obtener lista de negocios
  static Future<List<dynamic>> getBusinesses({
    double? lat,
    double? lng,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/businesses').replace(
        queryParameters: {
          if (lat != null) 'lat': lat.toString(),
          if (lng != null) 'lng': lng.toString(),
        },
      );
      final response = await http.get(uri).timeout(const Duration(seconds: 8));
      if (response.statusCode != 200) {
        throw Exception('Error al cargar negocios (${response.statusCode})');
      }
      final decoded = jsonDecode(response.body);
      if (decoded is! List) {
        throw const FormatException('Respuesta de negocios inválida');
      }
      return decoded;
    } catch (error) {
      throw Exception('No se pudo conectar con el servidor: $error');
    }
  }
}
