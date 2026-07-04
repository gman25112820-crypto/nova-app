

import 'package:flutter/material.dart';

// ──────────────────────────────────────────────────────────
//  EDDIE — the Jack Russell
//
//  Usage:
//    EddieWidget(mood: EddieMood.happy, scale: 1.0)
//
//  Moods: happy · sad · worried · proud · crowned · sleeping · wink
// ──────────────────────────────────────────────────────────

enum EddieMood { happy, sad, worried, proud, crowned, sleeping, wink }

class EddieWidget extends StatefulWidget {
  final EddieMood mood;
  final double scale;

  const EddieWidget({
    super.key,
    this.mood = EddieMood.happy,
    this.scale = 1.0,
  });

  @override
  State<EddieWidget> createState() => _EddieWidgetState();
}

class _EddieWidgetState extends State<EddieWidget> {
  @override
  Widget build(BuildContext context) {
    final w = 180.0 * widget.scale;
    final h = 220.0 * widget.scale;
    return SizedBox(
      width: w,
      height: h,
      child: Image.asset(
        'assets/images/characters/jack_russell.png',
        fit: BoxFit.contain,
      ),
    );
  }
}
