import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  // ========== CLIENTE ==========
  final nombreController = TextEditingController();
  final apellidoController = TextEditingController();
  final telefonoController = TextEditingController();
  final passwordController = TextEditingController();
  bool _verPassCliente = false; // El ojo 👁️

  // ========== DUEÑO DE NEGOCIO (ventana flotante) ==========
  final negocioController = TextEditingController();
  final representanteController = TextEditingController();
  final telefonoNegocioController = TextEditingController();
  final ubicacionController = TextEditingController();
  final horarioController = TextEditingController();
  final passwordNegocioController = TextEditingController();
  bool _verPassNegocio = false; // El ojo para la ventana 👁️

  bool _cargando = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        Provider.of<AuthProvider>(context, listen: false).clearError();
      }
    });
  }

  @override
  void dispose() {
    // Libero todos los campos ✅
    for (final c in [
      nombreController,
      apellidoController,
      telefonoController,
      passwordController,
      negocioController,
      representanteController,
      telefonoNegocioController,
      ubicacionController,
      horarioController,
      passwordNegocioController,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  void _irAlInicio() {
    Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
  }

  // Aviso de membresía para dueños 💳
  void _mostrarAvisoMembresia() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.storefront,
                color: const Color(0xFF603815)), // Marrón del logo ✅
            const SizedBox(width: 8),
            const Text('¡Negocio Registrado!'),
          ],
        ),
        content: const Text(
          '¡Felicidades! Tu negocio ya está en Emprende 🎉\n\n'
          'Para aparecer en la app y empezar a recibir pedidos, debes activar tu membresía.\n\n'
          '¿Quieres ver los detalles de pago ahora?',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _irAlInicio();
            },
            child: const Text('Más tarde'),
          ),
          ElevatedButton(
            // SIN color fijo → toma el marrón del tema ✅
            onPressed: () {
              Navigator.pop(context);
              _irAlInicio();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Enlace de pago — lo conectamos después 💳'),
                  backgroundColor: Color(0xFFFF8F00),
                  duration: Duration(seconds: 3),
                ),
              );
            },
            child: const Text('Ver pago de membresía'),
          ),
        ],
      ),
    );
  }

  Future<void> _ejecutarRegistroCliente() async {
    setState(() => _cargando = true);
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final exito = await auth.registerCliente(
      nombre: nombreController.text.trim(),
      apellido: apellidoController.text.trim(),
      telefono: telefonoController.text.trim(),
      password: passwordController.text.trim(),
    );
    if (!mounted) return;
    setState(() => _cargando = false);
    if (exito) _irAlInicio();
  }

  // Cajita de error con estilo bonito ⚠️
  Widget _cajaError(String? mensaje) {
    if (mensaje == null) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.red.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.red.shade300),
        ),
        child: Text(
          mensaje,
          style:
              const TextStyle(color: Colors.red, fontWeight: FontWeight.w500),
        ),
      ),
    );
  }

  void _abrirRegistroNegocio() {
    Provider.of<AuthProvider>(context, listen: false).clearError();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) {
        final auth = Provider.of<AuthProvider>(sheetContext);
        return StatefulBuilder(
          builder: (sheetContext, setSheetState) {
            // Mis colores oficiales 🎨
            const colorMarron = Color(0xFF603815);

            return Padding(
              padding: EdgeInsets.fromLTRB(20, 20, 20,
                  MediaQuery.of(sheetContext).viewInsets.bottom + 20),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      "Registrar mi negocio",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: colorMarron, // ✅ Marrón
                      ),
                    ),
                    const SizedBox(height: 8),
                    _cajaError(auth.errorMessage),
                    TextField(
                      controller: negocioController,
                      decoration: InputDecoration(
                        labelText: "Nombre del negocio *",
                        prefixIcon: Icon(Icons.store, color: colorMarron), // ✅
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: representanteController,
                      decoration: InputDecoration(
                        labelText: "Representante *",
                        prefixIcon: Icon(Icons.person, color: colorMarron), // ✅
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: telefonoNegocioController,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        labelText: "Teléfono del negocio *",
                        prefixIcon: Icon(Icons.phone, color: colorMarron), // ✅
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: ubicacionController,
                      decoration: InputDecoration(
                        labelText: "Ubicación exacta *",
                        prefixIcon:
                            Icon(Icons.location_on, color: colorMarron), // ✅
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: horarioController,
                      decoration: InputDecoration(
                        labelText: "Días y horario de atención *",
                        prefixIcon:
                            Icon(Icons.schedule, color: colorMarron), // ✅
                        hintText: "Ej: Lun - Vie 8:00 a 18:00",
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Contraseña con el ojo 👁️
                    TextField(
                      controller: passwordNegocioController,
                      obscureText: !_verPassNegocio,
                      decoration: InputDecoration(
                        labelText: "Crear contraseña *",
                        prefixIcon: Icon(Icons.lock, color: colorMarron), // ✅
                        suffixIcon: IconButton(
                          icon: Icon(
                            _verPassNegocio
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: colorMarron, // ✅
                          ),
                          onPressed: () {
                            setSheetState(() {
                              _verPassNegocio = !_verPassNegocio;
                            });
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 25),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size.fromHeight(45),
                        // SIN color → toma el marrón del tema ✅
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () async {
                        final exito = await auth.registerDueno(
                          negocio: negocioController.text.trim(),
                          representante: representanteController.text.trim(),
                          telefono: telefonoNegocioController.text.trim(),
                          ubicacion: ubicacionController.text.trim(),
                          horario: horarioController.text.trim(),
                          password: passwordNegocioController.text.trim(),
                        );
                        if (exito && mounted) {
                          Navigator.pop(sheetContext); // cierro ventana
                          _mostrarAvisoMembresia(); // muestro aviso 💳
                        }
                      },
                      child: const Text(
                        "Registrar mi Negocio",
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    // Mis colores oficiales del logo 🎨
    const colorMarron = Color(0xFF603815);
    const colorDorado = Color(0xFFD4AF37);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Registro"),
        // SIN backgroundColor → toma el marrón del tema ✅
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
            const SizedBox(height: 20),
            _cajaError(auth.errorMessage),
            // Campos del cliente
            TextField(
              controller: nombreController,
              decoration: InputDecoration(
                labelText: "Nombres *",
                prefixIcon: Icon(Icons.badge, color: colorMarron), // ✅
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: apellidoController,
              decoration: InputDecoration(
                labelText: "Apellidos *",
                prefixIcon: Icon(Icons.badge_outlined, color: colorMarron), // ✅
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: telefonoController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                labelText: "Teléfono *",
                prefixIcon: Icon(Icons.phone, color: colorMarron), // ✅
              ),
            ),
            const SizedBox(height: 12),
            // Contraseña con el ojo 👁️
            TextField(
              controller: passwordController,
              obscureText: !_verPassCliente,
              decoration: InputDecoration(
                labelText: "Crear contraseña * (mínimo 6 caracteres)",
                prefixIcon: Icon(Icons.lock, color: colorMarron), // ✅
                suffixIcon: IconButton(
                  icon: Icon(
                    _verPassCliente ? Icons.visibility_off : Icons.visibility,
                    color: colorMarron, // ✅
                  ),
                  onPressed: () {
                    setState(() {
                      _verPassCliente = !_verPassCliente;
                    });
                  },
                ),
              ),
            ),
            const SizedBox(height: 25),
            _cargando
                ? Center(
                    child: CircularProgressIndicator(color: colorDorado)) // ✅
                : ElevatedButton(
                    onPressed: _ejecutarRegistroCliente,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(50),
                      // SIN color → toma el marrón del tema ✅
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      "Registrar como Cliente",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
            const SizedBox(height: 15),
            TextButton(
              onPressed: _abrirRegistroNegocio,
              style: TextButton.styleFrom(
                foregroundColor: colorMarron, // ✅
              ),
              child: const Text("🏪 Registrar mi negocio"),
            ),
            TextButton(
              onPressed: () {
                auth.clearError();
                Navigator.pushReplacementNamed(context, '/login');
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.grey.shade700,
              ),
              child: const Text("¿Ya tienes cuenta? Inicia sesión"),
            ),
          ],
        ),
      ),
    );
  }
}
