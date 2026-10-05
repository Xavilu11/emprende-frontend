// Pantalla de inicio de sesión para usuarios que ya tienen cuenta
// Agregado el ojo para ver la contraseña y campos con diseño más bonito 👁️
// Banner con mi logo arriba sin estorbar 💚
// "Compras aquí, apoyas allá" 💚
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/logo_emprende.dart'; // ✅ Mi banner-cabecera

class LoginExistingScreen extends StatefulWidget {
  const LoginExistingScreen({super.key});

  @override
  State<LoginExistingScreen> createState() => _LoginExistingScreenState();
}

class _LoginExistingScreenState extends State<LoginExistingScreen> {
  final usuarioController = TextEditingController();
  final passwordController = TextEditingController();
  // Para mostrar o esconder la contraseña — el ojo 👁️
  bool _verContrasena = false;
  bool _cargando = false;

  @override
  void initState() {
    super.initState();
    // Limpia errores de otras pantallas por si acaso
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        Provider.of<AuthProvider>(context, listen: false).clearError();
      }
    });
  }

  @override
  void dispose() {
    usuarioController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void _irAlInicio() {
    Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
  }

  Future<void> _ejecutarLogin() async {
    setState(() => _cargando = true);
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final exito = await auth.login(
      usuarioController.text.trim(),
      passwordController.text.trim(),
    );
    if (!mounted) return;
    setState(() => _cargando = false);
    if (exito) _irAlInicio();
  }

  Future<void> _loginGoogle() async {
    if (_cargando) return;
    setState(() => _cargando = true);
    try {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      final exito = await auth.loginConGoogle();
      if (exito && mounted) _irAlInicio();
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    // Mis colores oficiales del logo 🎨
    final colorMarron = const Color(0xFF603815);
    final colorDorado = const Color(0xFFD4AF37);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Iniciar Sesión"),
        // SIN backgroundColor → toma el marrón del tema automáticamente ✅
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ✅ BANNER CON LOGO ARRIBA — sin estorbar
            LogoEmprende(tamano: 65),
            const Divider(height: 1, color: Color(0xFFE8E8E8)),
            // ✅ Todo tu contenido debajo — con los colores correctos
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  // Si hay error, lo muestro bien visible
                  if (auth.errorMessage != null) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.red.shade300),
                      ),
                      child: Text(
                        auth.errorMessage!,
                        style: const TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                  // Campo de correo o teléfono con celda bonita
                  TextField(
                    controller: usuarioController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: "Correo o Teléfono *",
                      prefixIcon: Icon(Icons.person, color: colorMarron),
                      filled: true,
                      fillColor: Colors.grey.shade50,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: colorDorado, // ✅ Dorado al escribir
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Campo de contraseña CON EL OJO 👁️
                  TextField(
                    controller: passwordController,
                    obscureText: !_verContrasena,
                    decoration: InputDecoration(
                      labelText: "Contraseña *",
                      prefixIcon: Icon(Icons.lock, color: colorMarron),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _verContrasena
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: colorMarron, // ✅ Marrón el ojo
                        ),
                        onPressed: () {
                          // Cambio entre mostrar y ocultar la contraseña
                          setState(() {
                            _verContrasena = !_verContrasena;
                          });
                        },
                      ),
                      filled: true,
                      fillColor: Colors.grey.shade50,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: colorDorado, // ✅ Dorado al escribir
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  // Botón de ingresar
                  _cargando
                      ? CircularProgressIndicator(color: colorDorado)
                      : SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _ejecutarLogin,
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              // SIN backgroundColor → toma el marrón del tema ✅
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              "Ingresar",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.account_circle),
                      label: const Text('Ingresar con Google'),
                      onPressed: _cargando ? null : _loginGoogle,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.shade600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Enlace para registrarse si es nuevo
                  TextButton(
                    onPressed: () {
                      auth.clearError();
                      Navigator.pushReplacementNamed(context, '/register');
                    },
                    child: Text(
                      "¿Nuevo usuario? Regístrate aquí",
                      style: TextStyle(color: colorMarron, fontSize: 15),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
