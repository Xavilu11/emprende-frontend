import 'package:flutter/material.dart';
import '../services/api_service.dart';

/// Prueba de conectividad con el backend Node.js (GET /status).
class StatusScreen extends StatefulWidget {
  const StatusScreen({super.key});

  @override
  State<StatusScreen> createState() => _StatusScreenState();
}

class _StatusScreenState extends State<StatusScreen> {
  late Future<String> _conexion;

  @override
  void initState() {
    super.initState();
    _conexion = ApiService.probarConexion();
  }

  void _reintentar() {
    setState(() {
      _conexion = ApiService.probarConexion();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Prueba de conexión")),
      body: FutureBuilder<String>(
        future: _conexion,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final texto = snapshot.data ?? "Error de conexión";
          final fallo = snapshot.hasError || texto.startsWith('Error');
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    fallo ? Icons.cloud_off : Icons.cloud_done,
                    size: 64,
                    color: fallo ? Colors.red : Colors.green,
                  ),
                  const SizedBox(height: 12),
                  Text(fallo ? texto : "Respuesta: $texto",
                      textAlign: TextAlign.center),
                  const SizedBox(height: 8),
                  Text("Servidor: ${ApiService.baseUrl}",
                      style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: _reintentar,
                    child: const Text("Reintentar"),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
