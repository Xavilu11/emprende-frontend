import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/negocio.dart';
import '../services/negocios_service.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  // Centro por defecto (Quito) cuando NO hay ubicación del usuario
  static const LatLng _centroPorDefecto = LatLng(-0.22985, -78.52495);

  LatLng? _usuario; // llega desde Inicio solo si el permiso fue concedido
  List<Negocio> _negocios = [];
  bool _cargando = true;
  bool _desdeCache = false;
  bool _inicializado = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_inicializado) {
      _inicializado = true;
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is LatLng) _usuario = args;
      _cargar();
    }
  }

  Future<void> _cargar() async {
    // BACKEND (con coordenadas del usuario) -> si falla, datos guardados en el teléfono
    final r = await NegociosService.cargar(
      lat: _usuario?.latitude,
      lng: _usuario?.longitude,
    );
    if (!mounted) return;
    setState(() {
      _negocios = r.negocios;
      _desdeCache = r.desdeCache;
      _cargando = false;
    });
  }

  Future<void> _abrirEnMapas(Negocio n) async {
    final url = Uri.parse(
        "https://www.google.com/maps/search/?api=1&query=${n.lat},${n.lng}");
    try {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("No se pudo abrir Google Maps")));
      }
    }
  }

  void _showBusinessDetails(Negocio negocio) {
    showModalBottomSheet(
      context: context,
      builder: (_) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.store, color: Colors.indigo),
            title: Text(negocio.nombre),
            subtitle: Text(negocio.descripcion),
          ),
          ListTile(
            leading: const Icon(Icons.location_on, color: Colors.red),
            title: const Text("Dirección"),
            subtitle: Text(negocio.direccion),
          ),
          ListTile(
            leading: const Icon(Icons.phone, color: Colors.green),
            title: const Text("Contacto"),
            subtitle: Text(negocio.contacto),
          ),
          ElevatedButton.icon(
            icon: const Icon(Icons.map),
            label: const Text("Ver en Google Maps"),
            onPressed: () => _abrirEnMapas(negocio),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final centro = _usuario ?? _centroPorDefecto;

    return Scaffold(
      appBar: AppBar(title: const Text("Mapa de Negocios")),
      body: Stack(
        children: [
          FlutterMap(
            options: MapOptions(initialCenter: centro, initialZoom: 15),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.emprende',
              ),
              MarkerLayer(
                markers: [
                  // Punto azul: "tú estás aquí" (solo con permiso de ubicación)
                  if (_usuario != null)
                    Marker(
                      point: _usuario!,
                      width: 40,
                      height: 40,
                      child: const Icon(Icons.my_location,
                          color: Colors.blue, size: 34),
                    ),
                  // Negocios (desde el backend o desde el almacenamiento local)
                  ..._negocios.map(
                    (negocio) => Marker(
                      point: LatLng(negocio.lat, negocio.lng),
                      width: 48,
                      height: 48,
                      child: IconButton(
                        icon: const Icon(Icons.location_on,
                            color: Colors.red, size: 40),
                        onPressed: () => _showBusinessDetails(negocio),
                      ),
                    ),
                  ),
                ],
              ),
              const RichAttributionWidget(
                attributions: [
                  TextSourceAttribution('OpenStreetMap contributors'),
                ],
              ),
            ],
          ),
          if (_cargando) const LinearProgressIndicator(),
          if (_desdeCache)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                color: Colors.amber.shade100,
                padding: const EdgeInsets.all(8),
                child: const Text(
                  "Sin conexión con el servidor: datos guardados en el teléfono",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
