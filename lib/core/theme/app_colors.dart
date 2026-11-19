import 'package:flutter/material.dart';

enum AppColorPalette {
  ember(
    id: 'ember',
    name: 'Ember',
    description: 'Warm amber',
    background: Color(0xFF101114),
    surface: Color(0xFF1B1D22),
    surfaceLight: Color(0xFF252830),
    primary: Color(0xFFFF9F43),
    secondary: Color(0xFFFFC078),
    textPrimary: Color(0xFFF5F5F5),
    textSecondary: Color(0xFF9699A3),
  ),
  ocean(
    id: 'ocean',
    name: 'Ocean',
    description: 'Calm blue',
    background: Color(0xFF0D131B),
    surface: Color(0xFF172331),
    surfaceLight: Color(0xFF203246),
    primary: Color(0xFF54B7FF),
    secondary: Color(0xFF9AD8FF),
    textPrimary: Color(0xFFF1F7FC),
    textSecondary: Color(0xFF95A8BA),
  ),
  violet(
    id: 'violet',
    name: 'Violet',
    description: 'Creative purple',
    background: Color(0xFF15111B),
    surface: Color(0xFF211A2B),
    surfaceLight: Color(0xFF30253E),
    primary: Color(0xFFB58AFF),
    secondary: Color(0xFFD4B9FF),
    textPrimary: Color(0xFFF7F2FC),
    textSecondary: Color(0xFFA99BB8),
  ),
  forest(
    id: 'forest',
    name: 'Forest',
    description: 'Balanced green',
    background: Color(0xFF101713),
    surface: Color(0xFF19241D),
    surfaceLight: Color(0xFF25352B),
    primary: Color(0xFF66D69A),
    secondary: Color(0xFFA1E8BE),
    textPrimary: Color(0xFFF1F8F3),
    textSecondary: Color(0xFF97AA9D),
  ),
  rose(
    id: 'rose',
    name: 'Rose',
    description: 'Soft pink',
    background: Color(0xFF191114),
    surface: Color(0xFF281A20),
    surfaceLight: Color(0xFF39252E),
    primary: Color(0xFFFF8FA8),
    secondary: Color(0xFFFFB8C8),
    textPrimary: Color(0xFFFFF3F6),
    textSecondary: Color(0xFFB49BA3),
  );

  const AppColorPalette({
    required this.id,
    required this.name,
    required this.description,
    required this.background,
    required this.surface,
    required this.surfaceLight,
    required this.primary,
    required this.secondary,
    required this.textPrimary,
    required this.textSecondary,
  });

  final String id;
  final String name;
  final String description;
  final Color background;
  final Color surface;
  final Color surfaceLight;
  final Color primary;
  final Color secondary;
  final Color textPrimary;
  final Color textSecondary;

  static AppColorPalette fromId(String id) => AppColorPalette.values.firstWhere(
    (palette) => palette.id == id,
    orElse: () => ember,
  );
}

class AppColors {
  AppColors._();

  static AppColorPalette palette = AppColorPalette.ember;

  static Color get background => palette.background;
  static Color get surface => palette.surface;
  static Color get surfaceLight => palette.surfaceLight;
  static Color get primary => palette.primary;
  static Color get secondary => palette.secondary;
  static Color get textPrimary => palette.textPrimary;
  static Color get textSecondary => palette.textSecondary;

  static const success = Color(0xFF42C98A);
  static const danger = Color(0xFFFF5C5C);
}
