import 'package:flutter/material.dart';

// ─────────────────────────────────────────────────────────────
// Responsive — viewport helpers for Fabulously Me
//
// Usage:
//   final r = Responsive.of(context);
//   if (r.isMobile) ...
//   padding: EdgeInsets.all(r.padding)
// ─────────────────────────────────────────────────────────────

class Responsive {
  final double screenW;
  final double screenH;

  const Responsive._(this.screenW, this.screenH);

  factory Responsive.of(BuildContext context) {
    final sz = MediaQuery.sizeOf(context);
    return Responsive._(sz.width, sz.height);
  }

  // ── Breakpoints ─────────────────────────────────────────────

  bool get isMobile  => screenW < 600;
  bool get isTablet  => screenW >= 600 && screenW < 900;
  bool get isDesktop => screenW >= 900;

  // ── Spacing ──────────────────────────────────────────────────

  double get padding => isMobile ? 16 : isTablet ? 24 : 32;
  double get cardRadius => isMobile ? 14 : 18;
  double get tileHeight => isMobile ? 160 : 200;

  // ── Typography ────────────────────────────────────────────────

  double get titleFontSize    => isMobile ? 20 : isTablet ? 24 : 28;
  double get bodyFontSize     => isMobile ? 13 : 14;
  double get subtitleFontSize => isMobile ? 11 : 12;

  // ── Grid ─────────────────────────────────────────────────────

  int get gridCols => isMobile ? 2 : isTablet ? 3 : 4;

  // ── Touch targets (minimum 44 dp per HIG / WCAG) ─────────────

  static const double minTapSize = 44;

  // ── Convenience ──────────────────────────────────────────────

  EdgeInsets get screenPadding => EdgeInsets.symmetric(horizontal: padding);
  EdgeInsets get cardPadding   => EdgeInsets.all(isMobile ? 12 : 16);
}
