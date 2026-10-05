// Pantalla de Inicio — Emprende 💚
// "Compras aquí, apoyas allá"
// Bienvenida + ubicación + lista de negocios + perfil ✅
// Todo conectado con mi AuthProvider y servicios de ubicación 📍

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/local_storage.dart';
import '../services/permisos_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  EstadoPermiso _permiso = EstadoPermiso.sinVerificar;
  bool _gpsApagado = false;
  bool _buscando = false;
  Position? _posicion;
  UbicacionGuardada? _ultima;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _refrescarEstado();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // Al volver de Ajustes actualizo el estado sin volver a pedir permiso ✅
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _refrescarEstado();
  }

  Future<void> _refrescarEstado() async {
    final nuevo = await PermisosService.estadoUbicacion();
    final ultima = await LocalStorage.leerUbicacion();
    if (!mounted) return;
    setState(() {
      _permiso = PermisosService.combinar(_permiso, nuevo);
      if (_permiso != EstadoPermiso.concedido) _posicion = null;
      _ultima = ultima;
    });
  }

  Future<void> _verNegociosCercanos() async {
    setState(() => _buscando = true);
    final r = await PermisosService.obtenerUbicacion();
    if (!mounted) return;
    setState(() {
      _buscando = false;
      _permiso = r.permiso;
      _gpsApagado = r.gpsApagado;
      _posicion = r.posicion;
    });

    // ✅ Tenemos ubicación → vamos al mapa centrado en mí
    if (r.posicion != null) {
      await LocalStorage.guardarUbicacion(
          r.posicion!.latitude, r.posicion!.longitude);
      final ultima = await LocalStorage.leerUbicacion();
      if (!mounted) return;
      setState(() => _ultima = ultima);
      if (r.esUltimaConocida) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text("Sin señal GPS: usando tu última ubicación conocida"),
            backgroundColor: Color(0xFFFF8F00),
          ));
        }
      }
      if (mounted) {
        Navigator.pushNamed(context, '/map',
            arguments: LatLng(r.posicion!.latitude, r.posicion!.longitude));
      }
      return;
    }

    // 🚫 Bloqueado permanentemente → explico cómo activarlo
    if (r.permiso == EstadoPermiso.denegadoPermanente) {
      final abrio = await mostrarDialogoAjustes(
        context,
        titulo: "Permiso de ubicación bloqueado",
        mensaje:
            "Denegaste el permiso de forma permanente. Actívalo en Ajustes > Permisos > Ubicación para ver negocios cercanos.",
      );
      if (!abrio && mounted) Navigator.pushNamed(context, '/products');
      return;
    }

    // 📡 Permiso dado pero GPS apagado → pregunto si lo activa
    if (r.gpsApagado) {
      final activar = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          icon: const Icon(Icons.location_off,
              size: 32, color: Color(0xFFFF8F00)),
          title: const Text("GPS desactivado"),
          content: const Text(
              "Tienes el permiso, pero la ubicación del teléfono está apagada. ¿Quieres activarla?"),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text("Ahora no")),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF2E7D32),
                foregroundColor: Colors.white,
              ),
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text("Activar GPS"),
            ),
          ],
        ),
      );
      if (activar == true) {
        await Geolocator.openLocationSettings();
      } else if (mounted) {
        Navigator.pushNamed(context, '/products');
      }
      return;
    }

    // ❌ Sin permiso → lista general igual funciona
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Sin permiso de ubicación: mostrando lista general"),
        backgroundColor: Color(0xFFFF8F00),
      ));
      Navigator.pushNamed(context, '/products');
    }
  }

  String get _mensajeDegradacion {
    switch (_permiso) {
      case EstadoPermiso.concedido:
        if (_gpsApagado) return "Permiso dado, pero el GPS está apagado.";
        if (_posicion != null) {
          return "Tu ubicación: ${_posicion!.latitude.toStringAsFixed(5)}, "
              "${_posicion!.longitude.toStringAsFixed(5)}";
        }
        return "Permiso concedido. Pulsa el botón para ver negocios cercanos.";
      case EstadoPermiso.denegado:
        return "Mostrando lista general de negocios (sin ubicación).";
      case EstadoPermiso.denegadoPermanente:
        return "Activa la ubicación en Ajustes para ver negocios cercanos.";
      case EstadoPermiso.sinVerificar:
        return "Ubicación aún no solicitada.";
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Emprende"),
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            tooltip: "Mi Perfil",
            icon: const Icon(Icons.person),
            onPressed: () => Navigator.pushNamed(context, '/profile'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Frase de la app 💚
            const Center(
              child: Text(
                '"Compras aquí, apoyas allá"',
                style: TextStyle(fontSize: 15, color: Colors.grey),
              ),
            ),
            const SizedBox(height: 25),

            // Tarjeta de bienvenida 👋
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Text(
                      "¡Bienvenido, ${auth.userSession.nickname}! 🎉",
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2E7D32),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "${auth.userSession.email}\n"
                      "${auth.esDueno ? '🏪 Dueño de negocio' : '🛒 Cliente'}",
                      textAlign: TextAlign.center,
                      style:
                          TextStyle(color: Colors.grey.shade600, height: 1.3),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 25),

            // Tarjeta de ubicación 📍
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(_permiso.icono, color: _permiso.color, size: 28),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            "Ubicación: ${_permiso.etiqueta}",
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(_mensajeDegradacion,
                        style: TextStyle(color: Colors.grey.shade700)),
                    if (_ultima != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        "Última ubicación guardada: ${_ultima!.lat.toStringAsFixed(4)}, "
                        "${_ultima!.lng.toStringAsFixed(4)}",
                        style:
                            const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                    const SizedBox(height: 16),
                    _buscando
                        ? const Center(
                            child: CircularProgressIndicator(
                                color: Color(0xFF2E7D32)))
                        : FilledButton.icon(
                            style: FilledButton.styleFrom(
                              backgroundColor: const Color(0xFF2E7D32),
                              foregroundColor: Colors.white,
                              minimumSize: const Size(double.infinity, 50),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            icon: const Icon(Icons.location_on),
                            label: const Text("Ver negocios cercanos",
                                style: TextStyle(fontSize: 16)),
                            onPressed: _verNegociosCercanos,
                          ),
                    if (_permiso == EstadoPermiso.denegadoPermanente)
                      TextButton.icon(
                        style: TextButton.styleFrom(
                            foregroundColor: const Color(0xFF2E7D32)),
                        icon: const Icon(Icons.settings),
                        label: const Text("Abrir ajustes de la app"),
                        onPressed: PermisosService.abrirAjustes,
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Botones de navegación �
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2E7D32),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(Icons.storefront),
              label: const Text("Ver Emprendimientos y Negocios",
                  style: TextStyle(fontSize: 16)),
              onPressed: () => Navigator.pushNamed(context, '/products'),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF8F00),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(Icons.camera_alt),
              label: const Text("Agregar producto",
                  style: TextStyle(fontSize: 16)),
              onPressed: () => Navigator.pushNamed(context, '/addProduct'),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(Icons.security),
              label: const Text("Gestión de permisos"),
              onPressed: () => Navigator.pushNamed(context, '/permisos'),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(Icons.wifi_tethering),
              label: const Text("Estado del servidor"),
              onPressed: () => Navigator.pushNamed(context, '/status'),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(Icons.account_circle),
              label: const Text("Mi Perfil"),
              onPressed: () => Navigator.pushNamed(context, '/profile'),
            ),
          ],
        ),
      ),
    );
  }
}
