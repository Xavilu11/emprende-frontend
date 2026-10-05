import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  late Animation<double> _rotation;

  @override
  void initState() {
    super.initState();

    // Mientras corre la animación, se lee la sesión guardada en el teléfono.
    final sesionCargada =
        Provider.of<AuthProvider>(context, listen: false).cargarSesion();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );

    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
    _rotation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: -0.08, end: 0.06)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 35,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 0.06, end: -0.025)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 25,
      ),
      TweenSequenceItem(
        tween: Tween(begin: -0.025, end: 0.0)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 40,
      ),
    ]).animate(_controller);

    _controller.forward().whenComplete(() async {
      await sesionCargada;
      if (!mounted) return;
      final auth = Provider.of<AuthProvider>(context, listen: false);
      Navigator.of(context)
          .pushReplacementNamed(auth.isAuthenticated ? '/home' : '/main');
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FadeTransition(
              opacity: _animation,
              child: ScaleTransition(
                scale: _animation,
                child: RotationTransition(
                  turns: _rotation,
                  child: Image.asset(
                    "assets/logo_emprende.jpeg",
                    width: 200,
                    cacheWidth: 400,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              "Pides aquí, impulsas allá",
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
