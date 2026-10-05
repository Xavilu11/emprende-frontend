import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

/// Estados que la app distingue para cada permiso (base de la matriz de degradación).
enum EstadoPermiso { sinVerificar, concedido, denegado, denegadoPermanente }

extension EstadoPermisoUi on EstadoPermiso {
  String get etiqueta => switch (this) {
        EstadoPermiso.sinVerificar => 'Aún no solicitado',
        EstadoPermiso.concedido => 'Concedido',
        EstadoPermiso.denegado => 'Denegado',
        EstadoPermiso.denegadoPermanente => 'Denegado permanentemente',
      };

  IconData get icono => switch (this) {
        EstadoPermiso.sinVerificar => Icons.help_outline,
        EstadoPermiso.concedido => Icons.check_circle,
        EstadoPermiso.denegado => Icons.cancel,
        EstadoPermiso.denegadoPermanente => Icons.block,
      };

  Color get color => switch (this) {
        EstadoPermiso.sinVerificar => Colors.grey,
        EstadoPermiso.concedido => Colors.green,
        EstadoPermiso.denegado => Colors.orange,
        EstadoPermiso.denegadoPermanente => Colors.red,
      };
}

class ResultadoUbicacion {
  final EstadoPermiso permiso;
  final Position? posicion;
  final bool gpsApagado;
  final bool esUltimaConocida;

  const ResultadoUbicacion({
    required this.permiso,
    this.posicion,
    this.gpsApagado = false,
    this.esUltimaConocida = false,
  });
}

/// Punto único de acceso a los permisos de Ubicación y Cámara.
class PermisosService {
  static EstadoPermiso _mapear(PermissionStatus s) {
    if (s.isGranted || s.isLimited) return EstadoPermiso.concedido;
    if (s.isPermanentlyDenied) return EstadoPermiso.denegadoPermanente;
    return EstadoPermiso.denegado; // denied / restricted / provisional
  }

  /// Combina el estado que tenemos en pantalla con el que devuelve el sistema al
  /// volver de Ajustes. Android no distingue "nunca pedido" de "denegado" al consultar.
  static EstadoPermiso combinar(EstadoPermiso actual, EstadoPermiso nuevo) {
    if (nuevo == EstadoPermiso.concedido ||
        nuevo == EstadoPermiso.denegadoPermanente) {
      return nuevo;
    }
    if (actual == EstadoPermiso.concedido || actual == EstadoPermiso.denegado) {
      return EstadoPermiso.denegado; // fue revocado o sigue denegado
    }
    return EstadoPermiso.sinVerificar;
  }

  // ---- Consulta pasiva (no muestra ningún diálogo) ----
  static Future<EstadoPermiso> estadoUbicacion() async =>
      _mapear(await Permission.location.status);
  static Future<EstadoPermiso> estadoCamara() async =>
      _mapear(await Permission.camera.status);

  // ---- Solicitud (muestra el diálogo del sistema si hace falta) ----
  static Future<EstadoPermiso> solicitarUbicacion() async =>
      _mapear(await Permission.location.request());
  static Future<EstadoPermiso> solicitarCamara() async =>
      _mapear(await Permission.camera.request());

  static Future<bool> abrirAjustes() => openAppSettings();

  /// Pide el permiso y, si se concede, obtiene la posición actual.
  static Future<ResultadoUbicacion> obtenerUbicacion() async {
    final permiso = await solicitarUbicacion();
    if (permiso != EstadoPermiso.concedido) {
      return ResultadoUbicacion(permiso: permiso);
    }

    // Permiso concedido pero GPS del teléfono apagado
    final servicioActivo = await Geolocator.isLocationServiceEnabled();
    if (!servicioActivo) {
      return ResultadoUbicacion(permiso: permiso, gpsApagado: true);
    }

    try {
      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 15),
      );
      return ResultadoUbicacion(permiso: permiso, posicion: pos);
    } catch (_) {
      // Sin señal a tiempo: usamos la última posición que conoce el sistema
      try {
        final ultima = await Geolocator.getLastKnownPosition();
        return ResultadoUbicacion(
          permiso: permiso,
          posicion: ultima,
          esUltimaConocida: ultima != null,
        );
      } catch (_) {
        return ResultadoUbicacion(permiso: permiso);
      }
    }
  }
}

/// Diálogo para la DENEGACIÓN PERMANENTE: explica y da acceso directo a Ajustes.
/// Devuelve true si el usuario pulsó "Abrir ajustes".
Future<bool> mostrarDialogoAjustes(
  BuildContext context, {
  required String titulo,
  required String mensaje,
}) async {
  final abrir = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      icon: const Icon(Icons.settings, size: 32),
      title: Text(titulo),
      content: Text(mensaje),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: const Text('Ahora no'),
        ),
        FilledButton.icon(
          onPressed: () => Navigator.pop(ctx, true),
          icon: const Icon(Icons.open_in_new),
          label: const Text('Abrir ajustes'),
        ),
      ],
    ),
  );
  if (abrir == true) {
    await PermisosService.abrirAjustes();
    return true;
  }
  return false;
}
