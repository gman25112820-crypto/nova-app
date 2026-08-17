import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../screens/house_interior_screen.dart';
import '../services/selected_child_service.dart';

// ─────────────────────────────────────────────────────────────
// UndergroundEntranceScreen
//
// Welcome-room shell for the underground retreat (see
// docs/session_notes/DESIGN_2026-07-13_underground.md). The doorway now
// leads into the existing age-appropriate room system.
// ─────────────────────────────────────────────────────────────

class UndergroundEntranceScreen extends StatelessWidget {
  const UndergroundEntranceScreen({super.key});

  void _openAgeAppropriateRooms(BuildContext context) {
    final child =
        SelectedChildService.current ?? SelectedChildService.selectDefault();

    if (child == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Add or select a child profile first.'),
          backgroundColor: Color(0xFF2D1556),
        ),
      );
      return;
    }

    Navigator.push(
      context,
      HouseInteriorScreen.route(houseTypeForAge(child.age)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2A160A),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final w = constraints.maxWidth;
          final h = constraints.maxHeight;
          final archWidth = math.min(w * 0.45, 420.0);
          final archMargin = (w - archWidth) / 2;
          final glowSize = archWidth * 0.30;
          final glowMargin = archMargin + (archWidth - glowSize) / 2;
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
              // Message — upper-middle, leaves room for the doorway below
              Positioned(
                left: w * 0.08,
                right: w * 0.08,
                top: h * 0.26,
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
              // Doorway down — tunnel-mouth arch, bottom-centre.
              Positioned(
                left: archMargin,
                right: archMargin,
                bottom: h * 0.14,
                height: h * 0.20,
                child: GestureDetector(
                  key: const Key('underground-doorway'),
                  behavior: HitTestBehavior.opaque,
                  onTap: () => _openAgeAppropriateRooms(context),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(w * 0.18),
                      ),
                      gradient: const LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Color(0xFF120A04), Color(0xFF1F1305)],
                      ),
                    ),
                  ),
                ),
              ),
              // Faint glow inside the doorway — lamplight further down
              Positioned(
                left: glowMargin,
                right: glowMargin,
                top: h * 0.68,
                height: glowSize,
                child: IgnorePointer(
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          const Color(0xFFB8763A).withValues(alpha: 0.35),
                          const Color(0xFFB8763A).withValues(alpha: 0.0),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              // Doorway invitation — quiet, beneath the doorway
              Positioned(
                left: 0,
                right: 0,
                bottom: h * 0.06,
                child: const Text(
                  'Explore the rooms',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0x99F0D6B8),
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    fontFamily: 'DM Sans',
                    letterSpacing: 0.2,
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
                    child: Align(
                      alignment: Alignment.topLeft,
                      child: GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          width: 38,
                          height: 38,
                          decoration: const BoxDecoration(
                            color: Colors.black38,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.arrow_back_rounded,
                            color: Colors.white70,
                            size: 20,
                          ),
                        ),
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
