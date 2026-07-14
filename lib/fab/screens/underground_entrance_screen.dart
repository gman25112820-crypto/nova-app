import 'package:flutter/material.dart';

// ─────────────────────────────────────────────────────────────
// UndergroundEntranceScreen
//
// Welcome-room shell for the underground retreat (see
// docs/session_notes/DESIGN_2026-07-13_underground.md). Doorway only —
// no descent corridor, no dig flow, no prompts. Lamplight, not moonlight.
// ─────────────────────────────────────────────────────────────

class UndergroundEntranceScreen extends StatelessWidget {
  const UndergroundEntranceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2A160A),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final w = constraints.maxWidth;
          final h = constraints.maxHeight;
          return Stack(
            children: [
              // Lamp glow — warm radial wash, centred
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      center: Alignment.center,
                      radius: 0.9,
                      colors: [
                        const Color(0xFF6B4423).withValues(alpha: 0.55),
                        const Color(0xFF2A160A),
                      ],
                    ),
                  ),
                ),
              ),
              // Message
              Positioned(
                left: w * 0.08,
                right: w * 0.08,
                top: h * 0.45,
                child: const Text(
                  "It's warm down here. Stay as long as you like.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFFF0D6B8),
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'DM Sans',
                    height: 1.5,
                  ),
                ),
              ),
              // Back button
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: 38,
                        height: 38,
                        decoration: const BoxDecoration(
                          color: Colors.black38,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.arrow_back_rounded,
                            color: Colors.white70, size: 20),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
