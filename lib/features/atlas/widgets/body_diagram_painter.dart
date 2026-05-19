import 'package:flutter/material.dart';

/// Programmatic back-view torso anatomy painter.
///
/// Draws entirely with canvas primitives — no SVG or PNG assets required.
/// Pass [selectedLocations] using the canonical vocabulary from [CheckInEntry]
/// to highlight regions with a translucent coral overlay.
///
/// Tap translation is handled by [getRegionFromOffset], which uses scale
/// multipliers relative to [canvasSize] to prevent touch drift on high-DPI
/// and resizable browser windows.
class BodyDiagramPainter extends CustomPainter {
  const BodyDiagramPainter({
    required this.selectedLocations,
    this.isDarkMode = false,
  });

  final List<String> selectedLocations;
  final bool isDarkMode;

  // ── Colour constants ────────────────────────────────────────────────────

  static const Color _coral = Color(0xFFFF6B6B);
  static const Color _highlightFill = Color(0x44FF6B6B); // translucent coral
  static const Color _spineDark = Color(0xFF8D6CFF);
  static const Color _spineLight = Color(0xFF5C4A9E);
  static const Color _jointDark = Color(0xFF5DADEC);
  static const Color _jointLight = Color(0xFF2F7FBA);

  // ── Hit-box region names (canonical vocabulary) ─────────────────────────

  static const String _regionNeck = 'Neck/shoulder';
  static const String _regionUpperBack = 'Upper back';
  static const String _regionMiddleBack = 'Middle back';
  static const String _regionLowerBack = 'Lower back';
  static const String _regionLeftShoulder = 'Left shoulder';
  static const String _regionRightShoulder = 'Right shoulder';
  static const String _regionLeftHip = 'Left hip';
  static const String _regionRightHip = 'Right hip';

  // ── Public tap translator ───────────────────────────────────────────────

  /// Maps a local gesture offset to a canonical region name.
  /// Returns null if the tap falls outside all defined hitboxes.
  ///
  /// All bounds are expressed as fractions of [canvasSize] so the mapping
  /// remains accurate at any rendered size or pixel density.
  static String? getRegionFromOffset(Offset localPosition, Size canvasSize) {
    final double x = localPosition.dx / canvasSize.width;
    final double y = localPosition.dy / canvasSize.height;

    // Neck / shoulder band
    if (y >= 0.13 && y <= 0.22) {
      if (x >= 0.20 && x <= 0.80) return _regionNeck;
    }

    // Shoulder joints (wide lateral zones)
    if (y >= 0.20 && y <= 0.35) {
      if (x >= 0.10 && x < 0.30) return _regionLeftShoulder;
      if (x > 0.70 && x <= 0.90) return _regionRightShoulder;
    }

    // Upper back (thoracic T1–T6, top third of torso)
    if (y >= 0.22 && y <= 0.44 && x >= 0.30 && x <= 0.70) {
      return _regionUpperBack;
    }

    // Middle back (thoracic T7–T12, mid torso)
    if (y > 0.44 && y <= 0.62 && x >= 0.32 && x <= 0.68) {
      return _regionMiddleBack;
    }

    // Lower back (lumbar L1–L5, lower torso)
    if (y > 0.62 && y <= 0.78 && x >= 0.33 && x <= 0.67) {
      return _regionLowerBack;
    }

    // Hip joints
    if (y > 0.76 && y <= 0.88) {
      if (x >= 0.22 && x < 0.42) return _regionLeftHip;
      if (x >= 0.58 && x <= 0.78) return _regionRightHip;
    }

    return null;
  }

  // ── CustomPainter ───────────────────────────────────────────────────────

  @override
  void paint(Canvas canvas, Size size) {
    final Color outlineColor =
        isDarkMode ? const Color(0xFFB9AECF) : const Color(0xFF3D3060);
    final Color fillColor =
        isDarkMode ? const Color(0xFF211C3A) : const Color(0xFFECE9F7);
    final Color jointColor = isDarkMode ? _jointDark : _jointLight;
    final Color spineColor = isDarkMode ? _spineDark : _spineLight;

    final Paint bodyFill = Paint()
      ..color = fillColor
      ..style = PaintingStyle.fill;

    final Paint bodyOutline = Paint()
      ..color = outlineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8
      ..strokeJoin = StrokeJoin.round;

    final Paint spinePaint = Paint()
      ..color = spineColor
      ..style = PaintingStyle.fill;

    final Paint jointPaint = Paint()
      ..color = jointColor
      ..style = PaintingStyle.fill;

    final Paint highlightPaint = Paint()
      ..color = _highlightFill
      ..style = PaintingStyle.fill;

    final Paint highlightStroke = Paint()
      ..color = _coral
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    // Convenience scale helpers
    double w(double f) => size.width * f;
    double h(double f) => size.height * f;

    // ── Head ───────────────────────────────────────────────────────────────
    final Rect headRect = Rect.fromCenter(
      center: Offset(w(0.50), h(0.065)),
      width: w(0.22),
      height: h(0.10),
    );
    canvas.drawOval(headRect, bodyFill);
    canvas.drawOval(headRect, bodyOutline);

    // ── Neck ───────────────────────────────────────────────────────────────
    final Rect neckRect = Rect.fromLTWH(
      w(0.44), h(0.11), w(0.12), h(0.06),
    );
    canvas.drawRect(neckRect, bodyFill);
    canvas.drawRect(neckRect, bodyOutline);

    // ── Torso (trapezoid — wider at shoulders, tapers to pelvis) ───────────
    final Path torsoPath = Path()
      ..moveTo(w(0.20), h(0.20)) // left shoulder line
      ..lineTo(w(0.80), h(0.20)) // right shoulder line
      ..lineTo(w(0.67), h(0.80)) // right hip
      ..lineTo(w(0.33), h(0.80)) // left hip
      ..close();

    canvas.drawPath(torsoPath, bodyFill);
    canvas.drawPath(torsoPath, bodyOutline);

    // ── Pelvis arc ─────────────────────────────────────────────────────────
    final Path pelvisPath = Path()
      ..moveTo(w(0.28), h(0.82))
      ..quadraticBezierTo(w(0.50), h(0.92), w(0.72), h(0.82));

    canvas.drawPath(pelvisPath, bodyOutline);

    // ── Shoulder joint markers ─────────────────────────────────────────────
    canvas.drawCircle(Offset(w(0.20), h(0.22)), w(0.055), jointPaint);
    canvas.drawCircle(Offset(w(0.80), h(0.22)), w(0.055), jointPaint);

    // ── Hip joint markers ──────────────────────────────────────────────────
    canvas.drawCircle(Offset(w(0.33), h(0.80)), w(0.048), jointPaint);
    canvas.drawCircle(Offset(w(0.67), h(0.80)), w(0.048), jointPaint);

    // ── Spine column (12 vertebra segments: 7 thoracic + 5 lumbar) ─────────
    //
    // Spine runs from y=0.24 (T1) to y=0.78 (L5).
    // Each segment is a small rounded rect centred on the midline.
    // Segments taper slightly in width from thoracic to lumbar.
    const int segmentCount = 12;
    const double spineTop = 0.24;
    const double spineBottom = 0.78;
    const double segmentHeight = (spineBottom - spineTop) / segmentCount;

    for (int i = 0; i < segmentCount; i++) {
      // Thoracic vertebrae (0–6) are slightly narrower than lumbar (7–11)
      final double widthFraction = i < 7 ? 0.085 : 0.105;
      final double segTop = spineTop + i * segmentHeight;
      final double gap = segmentHeight * 0.15; // inter-disc gap

      final RRect vertebra = RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(w(0.50), h(segTop + segmentHeight / 2)),
          width: w(widthFraction),
          height: h(segmentHeight - gap),
        ),
        Radius.circular(w(0.012)),
      );

      canvas.drawRRect(vertebra, spinePaint);
    }

    // ── Highlight overlays for selected regions ────────────────────────────
    for (final String region in selectedLocations) {
      final Path? overlay = _overlayPath(region, size);
      if (overlay != null) {
        canvas.drawPath(overlay, highlightPaint);
        canvas.drawPath(overlay, highlightStroke);
      }
    }
  }

  /// Returns the highlight overlay path for [region], scaled to [size].
  /// Returns null for unrecognised region names.
  Path? _overlayPath(String region, Size size) {
    double w(double f) => size.width * f;
    double h(double f) => size.height * f;

    switch (region) {
      case _regionNeck:
        return Path()
          ..addRect(Rect.fromLTWH(w(0.38), h(0.11), w(0.24), h(0.10)));

      case _regionUpperBack:
        return Path()
          ..moveTo(w(0.28), h(0.22))
          ..lineTo(w(0.72), h(0.22))
          ..lineTo(w(0.68), h(0.44))
          ..lineTo(w(0.32), h(0.44))
          ..close();

      case _regionMiddleBack:
        return Path()
          ..moveTo(w(0.32), h(0.44))
          ..lineTo(w(0.68), h(0.44))
          ..lineTo(w(0.65), h(0.62))
          ..lineTo(w(0.35), h(0.62))
          ..close();

      case _regionLowerBack:
        return Path()
          ..moveTo(w(0.35), h(0.62))
          ..lineTo(w(0.65), h(0.62))
          ..lineTo(w(0.63), h(0.79))
          ..lineTo(w(0.37), h(0.79))
          ..close();

      case _regionLeftShoulder:
        return Path()
          ..addOval(Rect.fromCenter(
            center: Offset(w(0.20), h(0.22)),
            width: w(0.16),
            height: h(0.10),
          ));

      case _regionRightShoulder:
        return Path()
          ..addOval(Rect.fromCenter(
            center: Offset(w(0.80), h(0.22)),
            width: w(0.16),
            height: h(0.10),
          ));

      case _regionLeftHip:
        return Path()
          ..addOval(Rect.fromCenter(
            center: Offset(w(0.33), h(0.80)),
            width: w(0.14),
            height: h(0.09),
          ));

      case _regionRightHip:
        return Path()
          ..addOval(Rect.fromCenter(
            center: Offset(w(0.67), h(0.80)),
            width: w(0.14),
            height: h(0.09),
          ));

      // 'Neck' is a generalLocations alias for 'Neck/shoulder'
      case 'Neck':
        return _overlayPath(_regionNeck, size);

      default:
        return null;
    }
  }

  @override
  bool shouldRepaint(BodyDiagramPainter oldDelegate) {
    return oldDelegate.selectedLocations != selectedLocations ||
        oldDelegate.isDarkMode != isDarkMode;
  }
}
