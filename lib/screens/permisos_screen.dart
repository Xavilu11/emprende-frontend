import 'package:flutter/material.dart';
import '../services/permisos_service.dart';

/// Panel de gestión de permisos: muestra el estado de las 2 capacidades,
/// permite solicitarlas y dar acceso directo a los Ajustes del sistema.
class PermisosScreen extends StatefulWidget {
  const PermisosScreen({super.key});

  @override
  State<PermisosScreen> createState() => _PermisosScreenState();
}

class _PermisosScreenState extends State<PermisosScreen>
    with WidgetsBindingObserver {
  EstadoPermiso _ubicacion = EstadoPermiso.sinVerificar;
  EstadoPermiso _camara = EstadoPermiso.sinVerificar;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _refrescar();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _refrescar();
  }

  Future<void> _refrescar() async {
    final u = await PermisosService.estadoUbicacion();
    final c = await PermisosService.estadoCamara();
    if (!mounted) return;
    setState(() {
      _ubicacion = PermisosService.combinar(_ubicacion, u);
      _camara = PermisosService.combinar(_camara, c);
    });
  }

  Future<void> _pedirUbicacion() async {
    final e = await PermisosService.solicitarUbicacion();
    if (!mounted) return;
    setState(() => _ubicacion = e);
  }

  Future<void> _pedirCamara() async {
    final e = await PermisosService.solicitarCamara();
    if (!mounted) return;
    setState(() => _camara = e);
  }

  Widget _fila({
    required IconData icono,
    required String titulo,
    required String uso,
    required EstadoPermiso estado,
    required VoidCallback onSolicitar,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icono, size: 28),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(titulo,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(uso, style: const TextStyle(fontSize: 12, color: Colors.grey)),
            const SizedBox(height: 10),
            Row(
              children: [
                Icon(estado.icono, color: estado.color),
                const SizedBox(width: 6),
                Text("Estado: ${estado.etiqueta}"),
              ],
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              children: [
                FilledButton(
                  onPressed: estado == EstadoPermiso.concedido ? null : onSolicitar,
                  child: const Text("Solicitar permiso"),
                ),
                OutlinedButton.icon(
                  icon: const Icon(Icons.settings),
                  label: const Text("Abrir ajustes"),
                  onPressed: PermisosService.abrirAjustes,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Gestión de permisos")),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _fila(
            icono: Icons.location_on,
            titulo: "Ubicación (GPS)",
            uso: "Para mostrar y ordenar los negocios más cercanos a ti.",
            estado: _ubicacion,
            onSolicitar: _pedirUbicacion,
          ),
          const SizedBox(height: 12),
          _fila(
            icono: Icons.camera_alt,
            titulo: "Cámara",
            uso: "Para que los emprendedores fotografíen sus productos.",
            estado: _camara,
            onSolicitar: _pedirCamara,
          ),
          const SizedBox(height: 12),
          const Text(
            "Si un permiso queda denegado de forma permanente, Android ya no muestra el "
            "diálogo: usa «Abrir ajustes» para activarlo manualmente.",
            style: TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }
}
