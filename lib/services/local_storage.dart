import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/negocio.dart';
import '../models/user_session.dart';

class UbicacionGuardada {
  final double lat;
  final double lng;
  final DateTime fecha;
  const UbicacionGuardada(this.lat, this.lng, this.fecha);
}

/// Almacenamiento LOCAL (SharedPreferences) — todo lo que la app recuerda en el teléfono:
///  1) la sesión del usuario (para no pedir login cada vez),
///  2) la caché de negocios (para funcionar sin conexión con el backend),
///  3) la última ubicación conocida.
class LocalStorage {
  static const _kSesion = 'sesion_usuario';
  static const _kNegocios = 'negocios_cache';
  static const _kUbicacion = 'ultima_ubicacion';

  // ---------- Sesión ----------
  static Future<void> guardarSesion(UserSession s) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kSesion, jsonEncode(s.toJson()));
  }

  static Future<UserSession?> leerSesion() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_kSesion);
      if (raw == null) return null;
      return UserSession.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  static Future<void> borrarSesion() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kSesion);
    await prefs.remove(_kUbicacion); // la ubicación es dato personal: se borra al salir
  }

  // ---------- Caché de negocios ----------
  static Future<void> guardarNegocios(List<Negocio> negocios) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        _kNegocios, jsonEncode(negocios.map((n) => n.toJson()).toList()));
  }

  static Future<List<Negocio>> leerNegocios() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_kNegocios);
      if (raw == null) return [];
      final lista = jsonDecode(raw) as List<dynamic>;
      return lista
          .map((e) => Negocio.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
    } catch (_) {
      return [];
    }
  }

  // ---------- Última ubicación ----------
  static Future<void> guardarUbicacion(double lat, double lng) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _kUbicacion,
      jsonEncode({'lat': lat, 'lng': lng, 'fecha': DateTime.now().toIso8601String()}),
    );
  }

  static Future<UbicacionGuardada?> leerUbicacion() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_kUbicacion);
      if (raw == null) return null;
      final m = jsonDecode(raw) as Map<String, dynamic>;
      return UbicacionGuardada(
        (m['lat'] as num).toDouble(),
        (m['lng'] as num).toDouble(),
        DateTime.parse(m['fecha'] as String),
      );
    } catch (_) {
      return null;
    }
  }
}
