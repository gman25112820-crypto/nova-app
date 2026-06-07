import 'package:flutter/material.dart';

// ─────────────────────────────────────────────────────────────
// EnchantedGardenScreen
//
// Magical front garden scene — fireflies, glowing lanterns,
// winding stone path. Navigated to from house front doors.
// ─────────────────────────────────────────────────────────────

class EnchantedGardenScreen extends StatefulWidget {
  const EnchantedGardenScreen({super.key});

  @override
  State<EnchantedGardenScreen> createState() => _EnchantedGardenState();
}

class _EnchantedGardenState extends State<EnchantedGardenScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _glowCtrl;

  @override
  void initState() {
    super.initState();
    _glowCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _glowCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Background scene
          Positioned.fill(
            child: Image.asset(
              'assets/images/rooms/enchanted_garden_bg.png',
              fit: BoxFit.cover,
            ),
          ),

          // Ambient glow overlay — pulsing firefly effect
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _glowCtrl,
              builder: (_, __) => DecoratedBox(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: const Alignment(-0.2, 0.3),
                    radius: 0.9,
                    colors: [
                      const Color(0xFFFFD700).withValues(
                          alpha: 0.04 + 0.06 * _glowCtrl.value),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ),

          // SafeArea overlay — back button + label
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          width: 40, height: 40,
                          decoration: BoxDecoration(
                            color: Colors.black54,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white24),
                          ),
                          child: const Icon(
                            Icons.arrow_back_rounded,
                            color: Colors.white70,
                            size: 20,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        '✨  Enchanted Garden',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'DM Sans',
                          shadows: [Shadow(color: Colors.black54, blurRadius: 8)],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Bottom hint label
          Positioned(
            bottom: 32, left: 0, right: 0,
            child: AnimatedBuilder(
              animation: _glowCtrl,
              builder: (_, __) => Opacity(
                opacity: 0.55 + 0.35 * _glowCtrl.value,
                child: const Text(
                  '🌿 Tap the back arrow to return home',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontFamily: 'DM Sans',
                    shadows: [Shadow(color: Colors.black87, blurRadius: 10)],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
