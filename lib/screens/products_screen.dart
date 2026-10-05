import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/negocio.dart';
import '../providers/auth_provider.dart';
import '../services/negocios_service.dart';

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  List<Negocio> _negocios = [];
  bool _cargando = true;
  bool _desdeCache = false;
  bool _inicializado = false;
  LatLng? _ubicacion; // Solo si el usuario dio permiso de ubicación

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_inicializado) {
      _inicializado = true;
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is LatLng) _ubicacion = args;
      _cargar();
    }
  }

  Future<void> _cargar() async {
    setState(() => _cargando = true);
    final r = await NegociosService.cargar(
      lat: _ubicacion?.latitude,
      lng: _ubicacion?.longitude,
    );
    if (!mounted) return;
    setState(() {
      _negocios = r.negocios;
      _desdeCache = r.desdeCache;
      _cargando = false;
    });
  }

  Future<void> _logout() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final navigator = Navigator.of(context);
    await auth.logout(); // Borra sesión del teléfono también
    navigator.pushNamedAndRemoveUntil('/', (route) => false);
  }

  Future<void> _abrirEnMapas(Negocio n) async {
    final url = Uri.parse(
        "https://www.google.com/maps/search/?api=1&query=${n.lat},${n.lng}");
    try {
      final ok = await launchUrl(url, mode: LaunchMode.externalApplication);
      if (!ok && mounted) _avisar("No se pudo abrir el mapa");
    } catch (_) {
      if (mounted) _avisar("No se pudo abrir el mapa");
    }
  }

  void _avisar(String texto) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(texto), backgroundColor: const Color(0xFF2E7D32)),
    );
  }

  void _mostrarDetalle(Negocio negocio, bool esDueno) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Frase y nombre del negocio 💚
            const Text(
              '"Compras aquí, apoyas allá"',
              style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey,
                  fontStyle: FontStyle.italic),
            ),
            const SizedBox(height: 15),
            Text(
              negocio.nombre,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2E7D32),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 5),
            Text(
              negocio.descripcion,
              style: TextStyle(color: Colors.grey.shade600),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),

            // Dueño / Representante 👤
            ListTile(
              leading: const Icon(Icons.person, color: Color(0xFF2E7D32)),
              title: const Text("Representante"),
              subtitle: Text(negocio.dueno),
            ),

            // Dirección 📍
            ListTile(
              leading: const Icon(Icons.location_on, color: Color(0xFFFF8F00)),
              title: const Text("Dirección"),
              subtitle: Text(negocio.direccion),
            ),

            // Contacto 📞
            ListTile(
              leading: const Icon(Icons.phone, color: Color(0xFF2E7D32)),
              title: const Text("Contacto"),
              subtitle: Text(negocio.contacto),
            ),

            const SizedBox(height: 10),

            // Botón ver en mapa — solo para clientes 🗺️
            if (!esDueno)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2E7D32),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Icon(Icons.map),
                  label: const Text("Ver ubicación en el mapa"),
                  onPressed: () {
                    Navigator.pop(context);
                    _abrirEnMapas(negocio);
                  },
                ),
              ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final esDueno = auth.esDueno;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text("Emprendimientos y Negocios"),
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            tooltip: "Actualizar",
            icon: const Icon(Icons.refresh),
            onPressed: _cargar,
          ),
          IconButton(
            tooltip: "Cerrar sesión",
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      floatingActionButton: esDueno
          ? FloatingActionButton.extended(
              backgroundColor: const Color(0xFFFF8F00),
              foregroundColor: Colors.white,
              icon: const Icon(Icons.add_a_photo),
              label: const Text("Agregar producto"),
              onPressed: () => Navigator.pushNamed(context, '/addProduct'),
            )
          : null,
      body: Column(
        children: [
          // Frase de la app 💚
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Text(
              '"Compras aquí, apoyas allá"',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ),

          // Aviso: datos guardados localmente 📡
          if (_desdeCache)
            Container(
              width: double.infinity,
              color: const Color(0xFFFF8F00).withOpacity(0.15),
              padding: const EdgeInsets.all(10),
              child: const Text(
                "Sin conexión: mostrando datos guardados en tu dispositivo",
                textAlign: TextAlign.center,
                style: TextStyle(color: Color(0xFFB36B00)),
              ),
            ),

          // Aviso: sin ubicación 📍
          if (_ubicacion == null && !_cargando)
            Container(
              width: double.infinity,
              color: const Color(0xFF2E7D32).withOpacity(0.08),
              padding: const EdgeInsets.all(8),
              child: const Text(
                "Lista general — activa la ubicación para ver los más cercanos",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: Color(0xFF2E7D32)),
              ),
            ),

          // Lista de negocios 🏪
          Expanded(
            child: _cargando
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(color: Color(0xFF2E7D32)),
                        SizedBox(height: 12),
                        Text("Cargando emprendimientos...",
                            style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: _cargar,
                    color: const Color(0xFF2E7D32),
                    child: _negocios.isEmpty
                        ? ListView(
                            padding: const EdgeInsets.all(40),
                            children: const [
                              Icon(Icons.storefront,
                                  size: 60, color: Colors.grey),
                              SizedBox(height: 15),
                              Text(
                                "Aún no hay negocios registrados",
                                textAlign: TextAlign.center,
                                style:
                                    TextStyle(fontSize: 16, color: Colors.grey),
                              ),
                            ],
                          )
                        : ListView.builder(
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: const EdgeInsets.all(16),
                            itemCount: _negocios.length,
                            itemBuilder: (context, index) {
                              final negocio = _negocios[index];
                              final km = negocio.distanciaKm;

                              return Card(
                                elevation: 2,
                                margin: const EdgeInsets.only(bottom: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: const Color(0xFF2E7D32)
                                        .withOpacity(0.1),
                                    child: const Icon(Icons.storefront,
                                        color: Color(0xFF2E7D32)),
                                  ),
                                  title: Text(
                                    negocio.nombre,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold),
                                  ),
                                  subtitle: Text(
                                    km == null
                                        ? negocio.descripcion
                                        : "${negocio.descripcion}\n"
                                            "A ${km < 1 ? '${(km * 1000).round()} metros' : '${km.toStringAsFixed(1)} km'} de ti",
                                    style: TextStyle(height: 1.3),
                                  ),
                                  isThreeLine: km != null,
                                  onTap: () =>
                                      _mostrarDetalle(negocio, esDueno),
                                  trailing: !esDueno
                                      ? IconButton(
                                          icon: const Icon(Icons.location_on,
                                              color: Color(0xFFFF8F00)),
                                          onPressed: () =>
                                              _mostrarDetalle(negocio, esDueno),
                                        )
                                      : null,
                                ),
                              );
                            },
                          ),
                  ),
          ),
        ],
      ),
    );
  }
}
