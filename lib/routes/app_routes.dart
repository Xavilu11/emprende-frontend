import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../screens/splash_screen.dart';
import '../screens/welcome_screen.dart';
import '../screens/login_existing.dart';
import '../screens/register_screen.dart';
import '../screens/home_screen.dart';
import '../screens/products_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/status_screen.dart';
import '../screens/add_product_screen.dart';
import '../screens/map_screen.dart';
import '../screens/permisos_screen.dart';

class AppRoutes {
  // Si no hay sesión, cualquier ruta protegida muestra la pantalla de bienvenida.
  static Widget _protectedRoute(BuildContext context, Widget screen) {
    final auth = Provider.of<AuthProvider>(context);
    if (!auth.isAuthenticated) {
      return const WelcomeScreen();
    }
    return screen;
  }

  static Map<String, WidgetBuilder> get routes => {
        // Públicas
        '/splash': (context) => const SplashScreen(),
        '/main': (context) => const WelcomeScreen(),
        '/register': (context) => const RegisterScreen(),
        '/login': (context) => const LoginExistingScreen(),
        '/login_existing': (context) => const LoginExistingScreen(),
        '/status': (context) => const StatusScreen(),
        // Protegidas (requieren sesión)
        '/home': (context) => _protectedRoute(context, const HomeScreen()),
        '/products': (context) =>
            _protectedRoute(context, const ProductsScreen()),
        '/map': (context) => _protectedRoute(context, const MapScreen()),
        '/profile': (context) =>
            _protectedRoute(context, const ProfileScreen()),
        '/addProduct': (context) =>
            _protectedRoute(context, const AddProductScreen()),
        '/permisos': (context) =>
            _protectedRoute(context, const PermisosScreen()),
      };
}
