import 'dart:math';
import 'package:flutter/material.dart';

enum LivingCharacterMotion {
  calm,
  playful,
  sleepy,
  protective,
  curious,
}

class LivingWorldCharacter extends StatelessWidget {
  final String assetPath;
  final double width;
  final double phase;
  final LivingCharacterMotion motion;
  final double shadowStrength;
  final String? label;
  final VoidCallback? onTap;
  final bool flipped;
  final double depth;
  final double interactionPull;

  // New: temporary blend to hide white foot patches
  final bool hideFootPatch;
  final double footBlendFactor;
  final double footBlendWidthFactor;
  final Color footBlendColor;

  const LivingWorldCharacter({
    super.key,
    required this.assetPath,
    required this.width,
    required this.phase,
    this.motion = LivingCharacterMotion.calm,
    this.shadowStrength = 0.28,
    this.label,
    this.onTap,
    this.flipped = false,
    this.depth = 1.0,
    this.interactionPull = 0.0,
    this.hideFootPatch = false,
    this.footBlendFactor = 0.0,
    this.footBlendWidthFactor = 0.72,
    this.footBlendColor = const Color(0xFF102116),
  });

  @override
  Widget build(BuildContext context) {
    final p = phase * pi * 2;

    final bob = _bob(p);
    final sway = _sway(p);
    final drift = _drift(p);
    final breathe = _breathe(p);
    final lean = _lean(p);

    final effectiveWidth = width * depth * breathe;
    final footBlendHeight = effectiveWidth * footBlendFactor;

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: onTap,
      child: Transform.translate(
        offset: Offset(drift + interactionPull, bob),
        child: Transform.rotate(
          angle: lean,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (label != null) _SpeechPill(label: label!),
              Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  Positioned(
                    bottom: 0,
                    child: Transform.scale(
                      scaleX: 1.0 + (shadowStrength * 0.25),
                      scaleY: 0.42,
                      child: Container(
                        width: effectiveWidth * 0.78,
                        height: effectiveWidth * 0.20,
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(
                            alpha: shadowStrength.clamp(0.08, 0.45),
                          ),
                          borderRadius: BorderRadius.circular(999),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(
                                alpha: (shadowStrength * 0.55).clamp(0.06, 0.30),
                              ),
                              blurRadius: 18,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(bottom: effectiveWidth * 0.05),
                    child: Stack(
                      alignment: Alignment.bottomCenter,
                      children: [
                        Transform(
                          alignment: Alignment.center,
                          transform: Matrix4.identity()
                            ..scale(flipped ? -1.0 : 1.0, 1.0),
                          child: Image.asset(
                            assetPath,
                            width: effectiveWidth,
                            fit: BoxFit.contain,
                            filterQuality: FilterQuality.medium,
                          ),
                        ),
                        if (hideFootPatch && footBlendFactor > 0)
                          Positioned(
                            bottom: effectiveWidth * 0.01,
                            child: IgnorePointer(
                              child: Container(
                                width: effectiveWidth * footBlendWidthFactor,
                                height: footBlendHeight,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      footBlendColor.withValues(alpha: 0.0),
                                      footBlendColor.withValues(alpha: 0.82),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(999),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  double _bob(double p) {
    switch (motion) {
      case LivingCharacterMotion.playful:
        return sin(p) * 5.5;
      case LivingCharacterMotion.sleepy:
        return sin(p * 0.55) * 1.8;
      case LivingCharacterMotion.protective:
        return sin(p * 0.75) * 2.2;
      case LivingCharacterMotion.curious:
        return sin(p * 1.15) * 3.5;
      case LivingCharacterMotion.calm:
        return sin(p) * 2.6;
    }
  }

  double _sway(double p) {
    switch (motion) {
      case LivingCharacterMotion.playful:
        return sin(p * 0.8) * 3.5;
      case LivingCharacterMotion.sleepy:
        return sin(p * 0.35) * 1.2;
      case LivingCharacterMotion.protective:
        return sin(p * 0.45) * 1.5;
      case LivingCharacterMotion.curious:
        return sin(p * 0.9) * 2.8;
      case LivingCharacterMotion.calm:
        return sin(p * 0.55) * 1.8;
    }
  }

  double _drift(double p) {
    final base = _sway(p);
    return base + sin(p * 0.23) * 1.5;
  }

  double _breathe(double p) {
    switch (motion) {
      case LivingCharacterMotion.sleepy:
        return 1.0 + sin(p * 0.45) * 0.012;
      case LivingCharacterMotion.protective:
        return 1.0 + sin(p * 0.55) * 0.009;
      default:
        return 1.0 + sin(p * 0.7) * 0.014;
    }
  }

  double _lean(double p) {
    switch (motion) {
      case LivingCharacterMotion.playful:
        return sin(p * 0.65) * 0.030;
      case LivingCharacterMotion.sleepy:
        return sin(p * 0.30) * 0.012;
      case LivingCharacterMotion.protective:
        return sin(p * 0.35) * 0.010;
      case LivingCharacterMotion.curious:
        return sin(p * 0.75) * 0.022;
      case LivingCharacterMotion.calm:
        return sin(p * 0.50) * 0.016;
    }
  }
}

class _SpeechPill extends StatelessWidget {
  final String label;

  const _SpeechPill({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1035).withValues(alpha: 0.78),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: Colors.white.withValues(alpha: 0.16)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.22),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 10,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}