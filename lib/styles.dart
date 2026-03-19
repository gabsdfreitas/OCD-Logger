import 'package:flutter/material.dart';

class AppStyles {
  static const deepSpaceTop = Color(0xFF1E293B); 
  static const deepSpaceBottom = Color(0xFF0F172A);

  static const lightTop = Color(0xFFF8FAFC); 
  static const lightBottom = Color(0xFFE2E8F0);

  static const textMainLight = Color(0xFF334155); 
  static const textMainDark = Color(0xFFF8FAFC);

  static const highDistress = Color(0xFFE57373); 
  static const mediumDistress = Color(0xFFFFB74D); 
  static const lowDistress = Color(0xFF81C784); 
  static const accentColor = Color(0xFF4DD0E1); 
  static const resistanceWarmth = Color(0xFFFFD54F); 

  static Color getText(bool isDark) => isDark ? textMainDark : textMainLight;

  static List<BoxShadow> glassShadow(bool isDark) {
    return [
      BoxShadow(
        color: isDark
            ? Colors.black.withValues(alpha: 0.4)
            : const Color(0xFF64748B).withValues(alpha: 0.15),
        blurRadius: 24,
        spreadRadius: -2,
        offset: const Offset(0, 12), 
      ),
    ];
  }

  static BoxDecoration glassDecorationNoShadow(bool isDark) {
    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        stops: const [0.0, 0.3, 0.6, 1.0],
        colors: [
          (isDark ? Colors.white : Colors.white).withValues(alpha: isDark ? 0.08 : 0.35), 
          (isDark ? Colors.white : Colors.white).withValues(alpha: isDark ? 0.02 : 0.10),
          (isDark ? Colors.black : const Color(0xFF94A3B8)).withValues(alpha: isDark ? 0.05 : 0.02),
          (isDark ? Colors.black : const Color(0xFF64748B)).withValues(alpha: isDark ? 0.15 : 0.05),
        ],
      ),
      borderRadius: BorderRadius.circular(45), 
    );
  }

  static TextStyle get titleStyle => const TextStyle(
        fontFamily: 'Times New Roman',
        fontSize: 28,
        fontWeight: FontWeight.bold,
        letterSpacing: 2.0,
      );
}