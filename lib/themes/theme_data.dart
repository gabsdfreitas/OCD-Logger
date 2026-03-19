import 'dart:ui';
import 'package:flutter/material.dart';

enum ThemeType {
  mirror, // Silver
  midnight, // Blue
  ocean, // Teal
  amethyst, // Purple
  crimson, // Red
  amber, // Orange
  emerald, // Green
}

abstract class AppTheme {
  String get nameKey;
  Color get accentColor;
}

class MirrorTheme implements AppTheme {
  @override
  String get nameKey => 'theme_mirror';
  @override
  Color get accentColor => const Color(0xFFB0BEC5); // Pastel Blue-Grey
}

class MidnightTheme implements AppTheme {
  @override
  String get nameKey => 'theme_midnight';
  @override
  Color get accentColor => const Color(0xFF7986CB); // Pastel Indigo
}

class OceanTheme implements AppTheme {
  @override
  String get nameKey => 'theme_ocean';
  @override
  Color get accentColor => const Color(0xFF4DD0E1); // Pastel Cyan
}

class AmethystTheme implements AppTheme {
  @override
  String get nameKey => 'theme_amethyst';
  @override
  Color get accentColor => const Color(0xFFBA68C8); // Pastel Purple
}

class CrimsonTheme implements AppTheme {
  @override
  String get nameKey => 'theme_dawn';
  @override
  Color get accentColor => const Color(0xFFE57373); // Pastel Rose/Red
}

class AmberTheme implements AppTheme {
  @override
  String get nameKey => 'theme_amber';
  @override
  Color get accentColor => const Color(0xFFFFD54F); // Pastel Amber
}

class EmeraldTheme implements AppTheme {
  @override
  String get nameKey => 'theme_emerald';
  @override
  Color get accentColor => const Color(0xFF81C784); // Pastel Green
}

AppTheme getThemeData(ThemeType type) {
  switch (type) {
    case ThemeType.mirror:
      return MirrorTheme();
    case ThemeType.midnight:
      return MidnightTheme();
    case ThemeType.ocean:
      return OceanTheme();
    case ThemeType.amethyst:
      return AmethystTheme();
    case ThemeType.crimson:
      return CrimsonTheme();
    case ThemeType.amber:
      return AmberTheme();
    case ThemeType.emerald:
      return EmeraldTheme();
  }
}