import 'package:flutter/material.dart';

// Cabecera con logo de Emprende
// Colores oficiales: Marrón café oscuro + Dorado
// Frase: "Compras aquí, apoyas allá" 💚

class LogoEmprende extends StatelessWidget {
  final double tamano;
  final bool centrado;

  const LogoEmprende({
    super.key,
    this.tamano = 65,
    this.centrado = true,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment:
            centrado ? MainAxisAlignment.center : MainAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.asset(
              'assets/logo_emprende.png',
              width: tamano,
              height: tamano,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: tamano,
                  height: tamano,
                  decoration: BoxDecoration(
                    color: const Color(0xFF603815),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.storefront,
                    color: Colors.white,
                    size: 40,
                  ),
                );
              },
            ),
          ),
          const SizedBox(width: 16),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'EMPRENDE',
                  style: TextStyle(
                    fontSize: tamano * 0.38,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF603815),
                    letterSpacing: 3,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '"Compras aquí, apoyas allá"',
                  style: TextStyle(
                    fontSize: 11,
                    fontStyle: FontStyle.italic,
                    color: const Color(0xFFD4AF37),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
