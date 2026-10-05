import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/permisos_service.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen>
    with WidgetsBindingObserver {
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();
  EstadoPermiso _permisoCamara = EstadoPermiso.sinVerificar;

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

  // Al volver de "Ajustes" se actualiza el estado del permiso
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _refrescarEstado();
  }

  Future<void> _refrescarEstado() async {
    final nuevo = await PermisosService.estadoCamara();
    if (!mounted) return;
    setState(
        () => _permisoCamara = PermisosService.combinar(_permisoCamara, nuevo));
  }

  Future<void> _tomarFoto() async {
    final estado = await PermisosService.solicitarCamara();
    if (!mounted) return;
    setState(() => _permisoCamara = estado);

    if (estado == EstadoPermiso.concedido) {
      try {
        final foto = await _picker.pickImage(
          source: ImageSource.camera,
          maxWidth: 1280,
          imageQuality: 85,
        );
        if (foto != null && mounted) {
          setState(() => _imageFile = File(foto.path));
        }
      } catch (_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text("No se pudo abrir la cámara en este dispositivo")));
        }
      }
    } else if (estado == EstadoPermiso.denegadoPermanente) {
      // 🚫 Denegación permanente: explicación + acceso directo a Ajustes
      await mostrarDialogoAjustes(
        context,
        titulo: "Permiso de cámara bloqueado",
        mensaje:
            "Denegaste el permiso de cámara de forma permanente. Actívalo en Ajustes > Permisos > "
            "Cámara para tomar fotos. Mientras tanto puedes elegir una imagen de la galería.",
      );
    } else if (mounted) {
      // ❌ Denegado esta vez
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
              "Sin permiso de cámara: puedes usar la galería o la imagen por defecto")));
    }
  }

  // Alternativa SIN permiso de cámara: el selector de fotos del sistema
  Future<void> _elegirDeGaleria() async {
    try {
      final elegido = await _picker.pickImage(source: ImageSource.gallery);
      if (elegido != null && mounted) {
        setState(() => _imageFile = File(elegido.path));
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("No se pudo abrir la galería")));
      }
    }
  }

  Widget _vistaPrevia() {
    // Con foto: se muestra la foto
    if (_imageFile != null) {
      return Image.file(_imageFile!, height: 220, fit: BoxFit.cover);
    }
    // Sin foto y con la cámara denegada: DEGRADACIÓN -> imagen por defecto + mensaje
    if (_permisoCamara == EstadoPermiso.denegado ||
        _permisoCamara == EstadoPermiso.denegadoPermanente) {
      return Column(
        children: [
          Image.asset("assets/logo_emprende.png", height: 140),
          const SizedBox(height: 8),
          Text(
            _permisoCamara == EstadoPermiso.denegado
                ? "Permiso de cámara denegado. Se usará la imagen por defecto."
                : "Cámara bloqueada. Actívala en ajustes o usa la galería.",
            textAlign: TextAlign.center,
          ),
        ],
      );
    }
    return const Text("No se ha seleccionado ninguna imagen");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Agregar Producto")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(_permisoCamara.icono, color: _permisoCamara.color),
                const SizedBox(width: 8),
                Text("Cámara: ${_permisoCamara.etiqueta}"),
              ],
            ),
            const SizedBox(height: 16),
            _vistaPrevia(),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              icon: const Icon(Icons.camera_alt),
              label: const Text("Tomar foto"),
              onPressed: _tomarFoto,
            ),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              icon: const Icon(Icons.photo_library),
              label: const Text("Seleccionar de galería"),
              onPressed: _elegirDeGaleria,
            ),
            if (_permisoCamara == EstadoPermiso.denegadoPermanente) ...[
              const SizedBox(height: 10),
              TextButton.icon(
                icon: const Icon(Icons.settings),
                label: const Text("Abrir ajustes de la app"),
                onPressed: PermisosService.abrirAjustes,
              ),
            ],
            const SizedBox(height: 30),
            FilledButton.icon(
              icon: const Icon(Icons.save),
              label: const Text("Guardar Producto"),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(_imageFile != null
                        ? "Producto guardado (imagen lista para enviar)"
                        : "Producto guardado con la imagen por defecto"),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
