import 'package:flutter/material.dart';

class AppColors {
  static const Color primaryRed = Color(0xFFE53E3E);
  static const Color darkBackground = Color(0xFF1A1A1A);
  static const Color cardBackground = Color(0xFF2D3748);
  static const Color lightGray = Color(0xFFE2E8F0);
  static const Color darkGray = Color(0xFF4A5568);
  static const Color successGreen = Color(0xFF38A169);
  static const Color warningOrange = Color(0xFFED8936);
  static const Color errorRed = Color(0xFFE53E3E);
  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Color(0xFFA0AEC0);
  static const Color botttomBar = Color.fromARGB(255, 36, 36, 36);
  
  // Colores del gauge de riesgo
  static const Color riskLow = Color(0xFF38A169);
  static const Color riskMedium = Color(0xFFED8936);
  static const Color riskHigh = Color(0xFFE53E3E);
  
  // Colores para tema claro
  static const Color lightCardBackground = Color(0xFFF7FAFC);
  static const Color lightTextPrimary = Color(0xFF1A202C);
  static const Color lightTextSecondary = Color(0xFF718096);
  static const Color lightBorder = Color(0xFFE2E8F0);
  
  // Gradientes
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryRed, Color(0xFFD53F8C)],
  );
  
  // Helper para obtener colores según el tema
  static Color getTextPrimary(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? textPrimary
        : lightTextPrimary;
  }
  
  static Color getTextSecondary(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? textSecondary
        : lightTextSecondary;
  }
  
  static Color getCardBackground(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? cardBackground
        : lightCardBackground;
  }
}