import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text("Mi Perfil")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const CircleAvatar(
              radius: 40,
              backgroundColor: Colors.indigo,
              child: Icon(Icons.person, size: 50, color: Colors.white),
            ),
            const SizedBox(height: 20),
            Text(
              "Emprendimiento / Nickname: ${auth.userSession.nickname}",
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              "Correo de contacto: ${auth.userSession.email}",
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 10),
            Text(
              "Teléfono registrado: ${auth.userSession.telefono.isEmpty ? 'No registrado' : auth.userSession.telefono}",
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 10),
            Text(
              "Tipo de cuenta: ${auth.esDueno ? 'Dueño de negocio' : 'Cliente'}",
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              icon: const Icon(Icons.security),
              label: const Text("Gestión de permisos"),
              onPressed: () => Navigator.pushNamed(context, '/permisos'),
            ),
            const Spacer(),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(45),
              ),
              icon: const Icon(Icons.logout),
              label: const Text("Cerrar Sesión"),
              onPressed: () async {
                final navigator = Navigator.of(context);
                await auth
                    .logout(); // borra también la sesión guardada en el teléfono
                navigator.pushNamedAndRemoveUntil('/login', (route) => false);
              },
            ),
          ],
        ),
      ),
    );
  }
}
