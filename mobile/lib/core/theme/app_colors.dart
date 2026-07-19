import "package:flutter/material.dart";

/// Palette E-sensya & Co — mêmes valeurs que le design system web (web/src/app/globals.css).
class AppColors {
  AppColors._();

  static const primary = Color(0xFF8C68D5);
  static const primaryDark = Color(0xFF6F49C8);
  static const primarySoft = Color(0xFFBCA8E7);

  static const secondary = Color(0xFFE75E9D);
  static const success = Color(0xFF59B37D);
  static const warning = Color(0xFFF6A53A);

  static const background = Color(0xFFF9F6F7);
  static const surface = Color(0xFFFFFFFF);
  static const surfaceAlt = Color(0xFFF5F3F8);
  static const border = Color(0xFFECE8F4);

  static const title = Color(0xFF1D2433);
  static const text = Color(0xFF444B57);
  static const textMuted = Color(0xFF8A9099);
  static const textDisabled = Color(0xFFB8BDC8);

  static const gradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF9B74E7), Color(0xFF845DD7), Color(0xFF6F49C8)],
  );

  /// Couleurs de rôle, reprises de la légende "Profils" des maquettes.
  static const roleResident = primary;
  static const roleFamily = secondary;
  static const roleProfessional = success;
  static const roleProvider = warning;
}
