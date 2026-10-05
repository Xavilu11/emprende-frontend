import 'package:flutter/material.dart';

/// Pantalla de bienvenida: elegir entre registrarse o entrar con una cuenta existente.
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Emprende")),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.asset(
                  "assets/logo_emprende.jpeg",
                  height: 130,
                  errorBuilder: (_, __, ___) =>
                      const Icon(Icons.store, size: 100, color: Colors.indigo),
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                "Pides aquí, impulsas allá",
                style: TextStyle(fontStyle: FontStyle.italic),
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(46)),
                child: const Text("Registrar"),
                onPressed: () => Navigator.pushNamed(context, '/register'),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(46)),
                child: const Text("Ya tengo cuenta"),
                onPressed: () => Navigator.pushNamed(context, '/login_existing'),
              ),
              const SizedBox(height: 12),
              TextButton.icon(
                icon: const Icon(Icons.wifi_tethering),
                label: const Text("Probar conexión con el servidor"),
                onPressed: () => Navigator.pushNamed(context, '/status'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
