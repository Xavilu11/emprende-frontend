import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../models/user_session.dart';
import '../services/api_service.dart';
import '../services/local_storage.dart';

class AuthProvider with ChangeNotifier {
  static Future<void>? _googleSignInInitialization;

  UserSession _userSession = const UserSession();
  String? _errorMessage;

  UserSession get userSession => _userSession;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _userSession.isAuthenticated;
  bool get esDueno => _userSession.rol == 'dueno';

  // Helper para extraer el mapa de usuario soporando ambas claves: 'user' o 'usuario'
  Map _extraerUsuario(dynamic data) {
    if (data is Map) {
      if (data['user'] is Map) return data['user'] as Map;
      if (data['usuario'] is Map) return data['usuario'] as Map;
    }
    return {};
  }

  // Mensaje de error que envía el backend (o uno por defecto)
  String _errorDe(dynamic data, String porDefecto) =>
      (data is Map && data['error'] != null)
          ? data['error'].toString()
          : (data is Map && data['mensaje'] != null)
              ? data['mensaje'].toString()
              : porDefecto;

  Future<void> _fallo(String mensaje) async {
    _errorMessage = mensaje;
    notifyListeners();
  }

  // Abre la sesión y la GUARDA en el almacenamiento local del teléfono
  Future<void> _abrirSesion(UserSession sesion) async {
    _userSession = sesion;
    _errorMessage = null;
    await LocalStorage.guardarSesion(sesion);
    notifyListeners();
  }

  /// Recupera la sesión guardada (se llama desde la pantalla Splash).
  Future<void> cargarSesion() async {
    final guardada = await LocalStorage.leerSesion();
    if (guardada != null) {
      _userSession = guardada;
      notifyListeners();
    }
  }

  // 🔑 Login universal (correo/teléfono + contraseña)
  Future<bool> login(
    String email,
    String password, {
    String? nickname,
    String? telefono,
  }) async {
    final emailValue = email.trim();
    final passwordValue = password.trim();

    if (emailValue.isEmpty || passwordValue.isEmpty) {
      await _fallo('El usuario y la contraseña son obligatorios.');
      return false;
    }

    final tieneArroba = emailValue.contains('@');
    final tienePunto = emailValue.contains('.');
    if (tieneArroba || tienePunto) {
      if (!tieneArroba || !tienePunto) {
        await _fallo('El formato del correo electrónico no es válido.');
        return false;
      }
    } else if (emailValue.length < 4) {
      await _fallo('El usuario o teléfono no es válido.');
      return false;
    }

    if (passwordValue.length < 6) {
      await _fallo('La contraseña debe tener al menos 6 caracteres.');
      return false;
    }

    try {
      final res = await ApiService.login(emailValue, passwordValue);
      final data = res['data'];

      if (res['statusCode'] == 200 || res['statusCode'] == 201) {
        final u = _extraerUsuario(data);
        await _abrirSesion(UserSession(
          email: (u['email'] ?? emailValue).toString(),
          nickname: (u['nickname'] ?? u['nombre'] ?? nickname ?? 'Usuario')
              .toString(),
          telefono: (u['telefono'] ?? telefono ?? '').toString(),
          rol: (u['rol'] ?? 'cliente').toString(),
          isAuthenticated: true,
        ));
        return true;
      }
      await _fallo(_errorDe(data, 'Credenciales incorrectas.'));
      return false;
    } catch (e) {
      debugPrint('❌ Exception en AuthProvider.login: $e');
      await _fallo('No se pudo conectar con el servidor backend.');
      return false;
    }
  }

  // 🔑 Registro de cliente
  Future<bool> registerCliente({
    required String nombre,
    required String apellido,
    required String telefono,
    required String password,
  }) async {
    if (nombre.trim().isEmpty ||
        apellido.trim().isEmpty ||
        telefono.trim().isEmpty ||
        password.trim().isEmpty) {
      await _fallo('Por favor complete los campos obligatorios (*).');
      return false;
    }
    if (password.trim().length < 6) {
      await _fallo('La contraseña debe tener al menos 6 caracteres.');
      return false;
    }

    try {
      final res = await ApiService.registerCliente(
        nombre: nombre,
        apellido: apellido,
        telefono: telefono,
        password: password,
      );
      final data = res['data'];

      if (res['statusCode'] == 200 || res['statusCode'] == 201) {
        final u = _extraerUsuario(data);
        await _abrirSesion(UserSession(
          email: (u['email'] ?? '').toString(),
          nickname: (u['nickname'] ?? u['nombre'] ?? nombre).toString(),
          telefono: (u['telefono'] ?? telefono).toString(),
          rol: (u['rol'] ?? 'cliente').toString(),
          isAuthenticated: true,
        ));
        return true;
      }
      await _fallo(_errorDe(data, 'Error al registrar cliente.'));
      return false;
    } catch (e) {
      debugPrint('❌ Exception en AuthProvider.registerCliente: $e');
      await _fallo('Error de conexión con el servidor backend.');
      return false;
    }
  }

  // 🔑 Registro de dueño de negocio
  Future<bool> registerDueno({
    required String negocio,
    required String representante,
    required String telefono,
    required String ubicacion,
    required String horario,
    required String password,
  }) async {
    if (negocio.trim().isEmpty ||
        representante.trim().isEmpty ||
        telefono.trim().isEmpty ||
        ubicacion.trim().isEmpty ||
        horario.trim().isEmpty ||
        password.trim().isEmpty) {
      await _fallo('Por favor complete todos los campos del negocio.');
      return false;
    }
    if (password.trim().length < 6) {
      await _fallo('La contraseña debe tener al menos 6 caracteres.');
      return false;
    }

    try {
      final res = await ApiService.registerDueno(
        negocio: negocio,
        representante: representante,
        telefono: telefono,
        ubicacion: ubicacion,
        horario: horario,
        password: password,
      );
      final data = res['data'];

      if (res['statusCode'] == 200 || res['statusCode'] == 201) {
        final u = _extraerUsuario(data);
        await _abrirSesion(UserSession(
          email: (u['email'] ?? '').toString(),
          nickname: (u['nickname'] ?? u['negocio'] ?? negocio).toString(),
          telefono: (u['telefono'] ?? telefono).toString(),
          rol: 'dueno',
          isAuthenticated: true,
        ));
        return true;
      }
      await _fallo(_errorDe(data, 'Error al registrar negocio.'));
      return false;
    } catch (e) {
      debugPrint('❌ Exception en AuthProvider.registerDueno: $e');
      await _fallo('Error de conexión con el servidor backend.');
      return false;
    }
  }

  Future<bool> loginConGoogle() async {
    try {
      final clientId = dotenv.isInitialized
          ? dotenv.env['GOOGLE_SERVER_CLIENT_ID']?.trim()
          : null;
      if (clientId == null || clientId.isEmpty) {
        await _fallo(
            'Google Sign-In requiere configurar un ID OAuth. No se inició sesión.');
        return false;
      }

      final googleSignIn = GoogleSignIn.instance;
      _googleSignInInitialization ??=
          googleSignIn.initialize(serverClientId: clientId);
      await _googleSignInInitialization;
      await googleSignIn.signOut();
      final account = await googleSignIn.authenticate();
      await _abrirSesion(UserSession(
        email: account.email,
        nickname: account.displayName ?? account.email,
        rol: 'cliente',
        isAuthenticated: true,
      ));
      return true;
    } on GoogleSignInException catch (error) {
      if (error.code == GoogleSignInExceptionCode.canceled) return false;
      await _fallo(
          'No se pudo iniciar con Google: ${error.description ?? error.code}');
      return false;
    } catch (error) {
      await _fallo('No se pudo iniciar con Google: $error');
      return false;
    }
  }

  Future<void> logout() async {
    _userSession = const UserSession();
    _errorMessage = null;
    await LocalStorage.borrarSesion();
    notifyListeners();
  }

  void clearError() {
    if (_errorMessage == null) return;
    _errorMessage = null;
    notifyListeners();
  }
}
