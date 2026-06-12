import 'package:flutter/material.dart';

class AppColors {
  // Colores principales
  static const Color primary = Color(0xFF9DC183);       // Verde salvia
  static const Color secondary = Color(0xFFA9C5D3);     // Azul niebla
  static const Color tertiary = Color(0xFFD4EAC8);      // Verde claro suave
  static const Color accent = Color(0xFF4F6F52);        // Verde botella profundo

  // Fondo y texto
  static const Color background = Color(0xFFF9FBF9);    // Blanco muy suave
  static const Color cardBackground = Color(0xFFFFFFFF); // Blanco puro
  static const Color surface = Color(0xFFF2F6F0);       // Superficie sutil
  static const Color divider = Color(0xFFE8EDE4);       // Separador
  static const Color shadow = Color(0x1A2F2F2F);        // Sombra sutil
  static const Color text = Color(0xFF2F2F2F);          // Gris carbón
  static const Color textSecondary = Color(0xFF5E6D55); // Gris cálido

  // Colores de estado
  static const Color success = Color(0xFF6DC9A1);       // Verde menta
  static const Color warning = Color(0xFFF6C667);       // Amarillo miel
  static const Color error = Color(0xFFF08A84);         // Coral suave

  // Riesgo
  static const Color riskLow = Color(0xFF6DC9A1);       // Verde
  static const Color riskModerate = Color(0xFFF6C667);  // Amarillo
  static const Color riskHigh = Color(0xFFF08A84);      // Coral

  // Gradientes
  static const LinearGradient gradientPrimary = LinearGradient(
    colors: [primary, secondary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient gradientAccent = LinearGradient(
    colors: [tertiary, accent],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient gradientSuccess = LinearGradient(
    colors: [secondary, primary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient gradientRiskLow = LinearGradient(
    colors: [Color(0xFF6DC9A1), Color(0xFF9DC183)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient gradientRiskModerate = LinearGradient(
    colors: [Color(0xFFF6C667), Color(0xFFE8A838)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient gradientRiskHigh = LinearGradient(
    colors: [Color(0xFFF08A84), Color(0xFFE06060)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
