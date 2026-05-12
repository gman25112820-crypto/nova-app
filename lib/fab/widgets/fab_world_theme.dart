import 'dart:ui';
import 'package:flutter/material.dart';

// ─────────────────────────────────────────────────────────────
// FAB WORLD THEME — Season & Weather Data Model
// Drives every visual layer of the world scene.
// ─────────────────────────────────────────────────────────────

enum FabSeason { spring, summer, autumn, winter }

enum FabWeather { clear, rain, snow, windy }

enum FabTimeOfDay { day, dusk, night }

// ── Derive season from real calendar month ──────────────────
FabSeason currentSeason() {
  final m = DateTime.now().month;
  if (m >= 3 && m <= 5) return FabSeason.spring;
  if (m >= 6 && m <= 8) return FabSeason.summer;
  if (m >= 9 && m <= 11) return FabSeason.autumn;
  return FabSeason.winter;
}

// ── Derive weather from season (simple default) ─────────────
FabWeather defaultWeather(FabSeason season) {
  switch (season) {
    case FabSeason.spring:
      return FabWeather.rain;
    case FabSeason.summer:
      return FabWeather.clear;
    case FabSeason.autumn:
      return FabWeather.windy;
    case FabSeason.winter:
      return FabWeather.snow;
  }
}

// ─────────────────────────────────────────────────────────────
// THEME DATA
// ─────────────────────────────────────────────────────────────

class FabWorldTheme {
  final FabSeason season;
  final FabWeather weather;

  const FabWorldTheme({required this.season, required this.weather});

  factory FabWorldTheme.fromCalendar() {
    final s = currentSeason();
    return FabWorldTheme(season: s, weather: defaultWeather(s));
  }

  // ── Sky gradient colours ────────────────────────────────────
  List<Color> get skyColors {
    switch (season) {
      case FabSeason.spring:
        return const [
          Color(0xFF0D0A2E),
          Color(0xFF1A1045),
          Color(0xFF2D1B5E),
          Color(0xFF3D2E6B),
        ];
      case FabSeason.summer:
        return const [
          Color(0xFF070A24),
          Color(0xFF0B1733),
          Color(0xFF142A45),
          Color(0xFF203A52),
        ];
      case FabSeason.autumn:
        return const [
          Color(0xFF120808),
          Color(0xFF1F0F0A),
          Color(0xFF2E1A10),
          Color(0xFF3D2815),
        ];
      case FabSeason.winter:
        return const [
          Color(0xFF060C1A),
          Color(0xFF0A1428),
          Color(0xFF0E1E38),
          Color(0xFF162840),
        ];
    }
  }

  // ── Moon tint ───────────────────────────────────────────────
  Color get moonColor {
    switch (season) {
      case FabSeason.spring:
        return const Color(0xFFFFC8E8); // pink
      case FabSeason.summer:
        return const Color(0xFFF3FAFF); // white
      case FabSeason.autumn:
        return const Color(0xFFFFB347); // harvest orange
      case FabSeason.winter:
        return const Color(0xFFD0E8FF); // icy blue
    }
  }

  // ── Mountain colours ────────────────────────────────────────
  Color get mountainFarColor {
    switch (season) {
      case FabSeason.spring:
        return const Color(0xFF2A1B52);
      case FabSeason.summer:
        return const Color(0xFF1B2E4A);
      case FabSeason.autumn:
        return const Color(0xFF3D1A0A);
      case FabSeason.winter:
        return const Color(0xFF1A2A3D);
    }
  }

  Color get mountainNearColor {
    switch (season) {
      case FabSeason.spring:
        return const Color(0xFF1E1040);
      case FabSeason.summer:
        return const Color(0xFF14263E);
      case FabSeason.autumn:
        return const Color(0xFF2E1208);
      case FabSeason.winter:
        return const Color(0xFF1C2E42);
    }
  }

  Color get mountainSnowColor => season == FabSeason.winter
      ? const Color(0xFFD8E8F5).withValues(alpha: 0.55)
      : Colors.transparent;

  // ── Forest back colour ──────────────────────────────────────
  Color get forestBackColor {
    switch (season) {
      case FabSeason.spring:
        return const Color(0xFF1A3D20);
      case FabSeason.summer:
        return const Color(0xFF183A42);
      case FabSeason.autumn:
        return const Color(0xFF3D2208);
      case FabSeason.winter:
        return const Color(0xFF182830);
    }
  }

  // ── Forest mid colour + glow ────────────────────────────────
  Color get forestMidColor {
    switch (season) {
      case FabSeason.spring:
        return const Color(0xFF1A5C28);
      case FabSeason.summer:
        return const Color(0xFF16482F);
      case FabSeason.autumn:
        return const Color(0xFF6B3210);
      case FabSeason.winter:
        return const Color(0xFF1A3040);
    }
  }

  Color get forestGlowColor {
    switch (season) {
      case FabSeason.spring:
        return const Color(0xFF80FFB0); // spring green glow
      case FabSeason.summer:
        return const Color(0xFF1DE9B6); // teal firefly glow
      case FabSeason.autumn:
        return const Color(0xFFFF8C00); // amber glow
      case FabSeason.winter:
        return const Color(0xFF88CCFF); // ice blue glow
    }
  }

  // ── Ground colours ──────────────────────────────────────────
  List<Color> get groundColors {
    switch (season) {
      case FabSeason.spring:
        return const [Color(0xFF2A5C30), Color(0xFF1A3820), Color(0xFF0F2018)];
      case FabSeason.summer:
        return const [Color(0xFF224429), Color(0xFF142B1E), Color(0xFF0C1C14)];
      case FabSeason.autumn:
        return const [Color(0xFF5C3820), Color(0xFF3A2210), Color(0xFF1E1008)];
      case FabSeason.winter:
        return const [Color(0xFFCCDDEE), Color(0xFF8899AA), Color(0xFF445566)];
    }
  }

  Color get groundLineColor {
    switch (season) {
      case FabSeason.spring:
        return const Color(0xFF80FF90);
      case FabSeason.summer:
        return const Color(0xFF6FD18A);
      case FabSeason.autumn:
        return const Color(0xFFD4882A);
      case FabSeason.winter:
        return const Color(0xFFAABBCC);
    }
  }

  // ── Left house accent ───────────────────────────────────────
  Color get leftHouseAccent {
    switch (season) {
      case FabSeason.spring:
        return const Color(0xFFFF9ECC); // cherry blossom pink
      case FabSeason.summer:
        return const Color(0xFFFF80AB);
      case FabSeason.autumn:
        return const Color(0xFFFF6B35);
      case FabSeason.winter:
        return const Color(0xFFFF4488); // Christmas pink
    }
  }

  // ── Right house accent ──────────────────────────────────────
  Color get rightHouseAccent {
    switch (season) {
      case FabSeason.spring:
        return const Color(0xFF66FFB2);
      case FabSeason.summer:
        return const Color(0xFF4DB6AC);
      case FabSeason.autumn:
        return const Color(0xFFD4A020);
      case FabSeason.winter:
        return const Color(0xFF44AAFF); // blue Christmas lights
    }
  }

  // ── Window glow ─────────────────────────────────────────────
  Color get leftWindowGlow => const Color(0xFFFFE082);
  Color get rightWindowGlow => season == FabSeason.winter
      ? const Color(0xFF88CCFF)
      : const Color(0xFFB2DFDB);

  // ── Firefly / particle colour ───────────────────────────────
  Color get particleColor {
    switch (season) {
      case FabSeason.spring:
        return const Color(0xFFFFB7E8); // pink butterflies
      case FabSeason.summer:
        return const Color(0xFFFFF59D); // yellow fireflies
      case FabSeason.autumn:
        return const Color(0xFFFFAA44); // amber sparks
      case FabSeason.winter:
        return const Color(0xFFDDEEFF); // white snowflakes
    }
  }

  // ── Atmospheric haze per layer (0=none, 1=full) ─────────────
  // Used to tint distant layers toward sky colour
  double hazeForDepth(double depth) {
    // depth 0=sky, 1=near ground. Haze increases with distance.
    final base = 1.0 - depth;
    switch (season) {
      case FabSeason.spring:
        return base * 0.30;
      case FabSeason.summer:
        return base * 0.20;
      case FabSeason.autumn:
        return base * 0.40;
      case FabSeason.winter:
        return base * 0.35;
    }
  }

  Color get hazeColor {
    switch (season) {
      case FabSeason.spring:
        return const Color(0xFF2D1B5E);
      case FabSeason.summer:
        return const Color(0xFF0B1733);
      case FabSeason.autumn:
        return const Color(0xFF1F0F0A);
      case FabSeason.winter:
        return const Color(0xFF0A1428);
    }
  }

  // ── Season label (for debug / UI) ───────────────────────────
  String get label {
    switch (season) {
      case FabSeason.spring:
        return 'Spring';
      case FabSeason.summer:
        return 'Summer';
      case FabSeason.autumn:
        return 'Autumn';
      case FabSeason.winter:
        return 'Winter';
    }
  }

  // ── House decorations active this season ────────────────────
  bool get showFlowerBoxes => season == FabSeason.spring || season == FabSeason.summer;
  bool get showPumpkins => season == FabSeason.autumn;
  bool get showSnowOnRoof => season == FabSeason.winter;
  bool get showChristmasLights => season == FabSeason.winter;
  bool get showFireflies => season == FabSeason.summer;
  bool get showButterflies => season == FabSeason.spring;
  bool get showFallingLeaves => season == FabSeason.autumn;
  bool get showSnow => season == FabSeason.winter;
  bool get showRain => weather == FabWeather.rain;
}
