import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
// Mis pantallas — cada una con su propósito
import 'screens/login_existing.dart'; // Iniciar sesión
import 'screens/register_screen.dart'; // Crear cuenta
import 'screens/home_screen.dart'; // Pantalla principal
import 'screens/products_screen.dart'; // Lista de negocios
import 'screens/map_screen.dart'; // Mapa de ubicación
import 'screens/profile_screen.dart'; // Mi perfil
import 'screens/add_product_screen.dart'; // Agregar producto
import 'screens/permisos_screen.dart'; // Gestión de permisos
import 'screens/status_screen.dart'; // Estado del servidor
import 'widgets/logo_emprende.dart'; // Mi logo reutilizable

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(isOptional: true);

  // Provider: la sesión se comparte en TODA la app
  runApp(
    ChangeNotifierProvider(
      create: (_) => AuthProvider(),
      child: const EmprendeApp(),
    ),
  );
}

class EmprendeApp extends StatelessWidget {
  const EmprendeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Emprende',
      // Colores OFICIALES del logo: Marrón + Dorado
      theme: ThemeData(
        primarySwatch: Colors.brown,
        primaryColor: const Color(0xFF603815),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF603815),
          primary: const Color(0xFF603815),
          secondary: const Color(0xFFD4AF37),
        ),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF603815),
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF603815),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.grey.shade50,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF603815), width: 1.5),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300, width: 1.5),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
              color: Color(0xFFD4AF37),
              width: 2,
            ),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
          prefixIconColor: Color(0xFF603815),
          suffixIconColor: Color(0xFF603815),
        ),
      ),
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/login': (context) => const LoginExistingScreen(),
        '/register': (context) => const RegisterScreen(),
        '/home': (context) => const HomeScreen(),
        '/products': (context) => const ProductsScreen(),
        '/map': (context) => const MapScreen(),
        '/profile': (context) => const ProfileScreen(),
        '/addProduct': (context) => const AddProductScreen(),
        '/permisos': (context) => const PermisosScreen(),
        '/status': (context) => const StatusScreen(),
      },
    );
  }
}

// Pantalla de presentación que aparece al abrir la app
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        Provider.of<AuthProvider>(context, listen: false).cargarSesion();
      }
    });
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/login');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            LogoEmprende(tamano: 160), // ✅ SIN "const"
            const SizedBox(height: 48),
            const CircularProgressIndicator(
              color: Color(0xFFD4AF37),
              strokeWidth: 3,
            ),
          ],
        ),
      ),
    );
  }
}
