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
  static const Color text = Color(0xFF2F2F2F);          // Gris carbón
  static const Color textSecondary = Color(0xFF5E6D55); // Gris cálido

  // Colores de estado
  static const Color success = Color(0xFF6DC9A1);       // Verde menta
  static const Color warning = Color(0xFFF6C667);       // Amarillo miel
  static const Color error = Color(0xFFF08A84);         // Coral suave
  static const Color info = Color(0xFF64B5F6);          // Azul información

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

  // Alias para compatibilidad con código existente
  static const Color primaryColor = primary;
  static const Color secondaryColor = secondary;
  static const Color accentColor = accent;
  static const Color backgroundColor = background;
  static const Color textDark = text;
  static const Color textMedium = textSecondary;
  static const Color borderColor = Color(0xFFE0E0E0);
  static const Color shadowColor = Color(0xFF000000);
}
