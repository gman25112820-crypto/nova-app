import 'package:flutter/material.dart';
import '../widgets/sleepy_sloth_widget.dart';

// ─────────────────────────────────────────────────────────────
// BedtimeSceneScreen
//
// Decorative ambient scene — Sleepy and Saffi tucked up in bed.
// Reached from Sleep Den's AppBar. Purely decorative, no logging
// content — the sleep-tracking form itself lives in SleepScreen.
// ─────────────────────────────────────────────────────────────

class BedtimeSceneScreen extends StatelessWidget {
  const BedtimeSceneScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF050C2E),
      body: Stack(
        children: [
          const Positioned.fill(child: SleepySlothWidget()),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: Colors.black38,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.arrow_back_rounded,
                            color: Colors.white70, size: 20),
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      '🌙  Sleepy & Saffi',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        fontFamily: 'DM Sans',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
