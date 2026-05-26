import 'package:flutter/material.dart';

class FabColors {
  static const bg = Color(0xFF1A0A2E);
  static const mid = Color(0xFF26103F);
  static const panel = Color(0xFF32155A);
  static const panel2 = Color(0xFF3D1A6E);
  static const pink = Color(0xFFFF8FAB);
  static const gold = Color(0xFFFFD700);
  static const yellow = Color(0xFFFFE66D);
  static const rose = Color(0xFFFF4D78);
  static const deepRose = Color(0xFFCC1450);
  static const teal = Color(0xFF00C9A7);
  static const ice = Color(0xFF7EC8E3);
  static const blush = Color(0xFFFFB3C6);
  static const text = Color(0xFFFFF0F8);
  static const muted = Color(0xFFC9A0C9);
  static const duckYellow = Color(0xFFFFE66D);
  static const duckOrange = Color(0xFFF9A825);
  static const duckPink = Color(0xFFFFB3C6);
}

class FabTheme {
  static ThemeData get theme => ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: FabColors.bg,
    colorScheme: const ColorScheme.dark(
      primary: FabColors.pink,
      secondary: FabColors.gold,
      surface: FabColors.panel,
      onSurface: FabColors.text,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: FabColors.mid,
      foregroundColor: FabColors.text,
      elevation: 0,
    ),
    cardTheme: CardThemeData(
      color: FabColors.panel,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: Color(0x2EFF8FAB), width: 0.5),
      ),
      elevation: 0,
    ),
    textTheme: const TextTheme(
      titleLarge: TextStyle(color: FabColors.text, fontSize: 18, fontWeight: FontWeight.w500),
      titleMedium: TextStyle(color: FabColors.text, fontSize: 15, fontWeight: FontWeight.w500),
      bodyMedium: TextStyle(color: FabColors.text, fontSize: 13),
      bodySmall: TextStyle(color: FabColors.muted, fontSize: 11),
    ),
  );
}

enum FabCondition { adhd, sleep, autism, bipolar, dyspraxia, dyslexia, dyscalculia, tourettes, anxiety, sensory }

extension FabConditionExt on FabCondition {
  String get label {
    switch (this) {
      case FabCondition.adhd:        return 'ADHD';
      case FabCondition.sleep:       return 'Sleep';
      case FabCondition.autism:      return 'Autism';
      case FabCondition.bipolar:     return 'Bipolar';
      case FabCondition.dyspraxia:   return 'Dyspraxia';
      case FabCondition.dyslexia:    return 'Dyslexia';
      case FabCondition.dyscalculia: return 'Dyscalculia';
      case FabCondition.tourettes:   return 'Tourettes';
      case FabCondition.anxiety:     return 'Anxiety';
      case FabCondition.sensory:     return 'Sensory';
    }
  }
  Color get color {
    switch (this) {
      case FabCondition.adhd:        return FabColors.pink;
      case FabCondition.sleep:       return FabColors.gold;
      case FabCondition.autism:      return FabColors.teal;
      case FabCondition.bipolar:     return FabColors.ice;
      case FabCondition.dyspraxia:   return const Color(0xFF81C784);
      case FabCondition.dyslexia:    return const Color(0xFFFF9800);
      case FabCondition.dyscalculia: return FabColors.yellow;
      case FabCondition.tourettes:   return FabColors.rose;
      case FabCondition.anxiety:     return FabColors.ice;
      case FabCondition.sensory:     return const Color(0xFFCE93D8);
    }
  }
}