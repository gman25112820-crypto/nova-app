import 'dart:math' as math;
import 'package:flutter/material.dart';

// ─────────────────────────────────────────────────────────────
// GiraffeSleepNestScreen
//
// Giraffe House bedroom — a tall, starlit room with a high
// four-poster bed, soft night lights, and a gentle rain ambience
// card. All drawn in Flutter; no assets required.
// ─────────────────────────────────────────────────────────────

class GiraffeSleepNestScreen extends StatefulWidget {
  const GiraffeSleepNestScreen({super.key});

  @override
  State<GiraffeSleepNestScreen> createState() =>
      _GiraffeSleepNestScreenState();
}

class _GiraffeSleepNestScreenState extends State<GiraffeSleepNestScreen>
    with TickerProviderStateMixin {
  late final AnimationController _ambient;
  late final AnimationController _float;
  bool _rainsound = false;
  bool _nightlight = false;

  @override
  void initState() {
    super.initState();
    _ambient = AnimationController(
        vsync: this, duration: const Duration(seconds: 6))
      ..repeat(reverse: true);
    _float = AnimationController(
        vsync: this, duration: const Duration(seconds: 4))
      ..repeat(reverse: true);
  }

  @override
  void dispose() {
    _ambient.dispose();
    _float.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF050C1A),
      body: SafeArea(
        child: Stack(
          children: [
            // Starfield
            AnimatedBuilder(
              animation: _ambient,
              builder: (_, __) => CustomPaint(
                painter: _StarfieldPainter(_ambient.value),
                size: MediaQuery.of(context).size,
              ),
            ),
            Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 10, 16, 0),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          width: 38, height: 38,
                          decoration: BoxDecoration(
                            color: const Color(0xFF4ECDC4)
                                .withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.arrow_back_rounded,
                              color: Color(0xFFF0D6FF), size: 20),
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        '🌙  Sleep Nest — Giraffe Room',
                        style: TextStyle(
                          color: Color(0xFFF0D6FF),
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          fontFamily: 'DM Sans',
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // Bed (floating)
                AnimatedBuilder(
                  animation: _float,
                  builder: (_, child) => Transform.translate(
                    offset:
                        Offset(0, math.sin(_float.value * math.pi) * 5),
                    child: child,
                  ),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 32),
                    child: _GiraffeBed(),
                  ),
                ),
                const SizedBox(height: 24),
                // Activity cards
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                    children: [
                      _ActivityCard(
                        emoji: '🌧️',
                        title: 'Rain Sounds',
                        subtitle: 'Gentle rain helps you drift off',
                        accent: const Color(0xFF4ECDC4),
                        active: _rainsound,
                        onTap: () =>
                            setState(() => _rainsound = !_rainsound),
                      ),
                      const SizedBox(height: 10),
                      _ActivityCard(
                        emoji: '🌟',
                        title: 'Night Light',
                        subtitle:
                            'A soft glow so you never feel alone',
                        accent: const Color(0xFFFFD700),
                        active: _nightlight,
                        onTap: () =>
                            setState(() => _nightlight = !_nightlight),
                      ),
                      const SizedBox(height: 10),
                      _ActivityCard(
                        emoji: '🦒',
                        title: 'Goodnight Story',
                        subtitle:
                            'Close your eyes. Imagine a tall, quiet savanna…',
                        accent: const Color(0xFFFF8C00),
                        active: false,
                        onTap: () => _showStory(context),
                      ),
                      const SizedBox(height: 10),
                      _ActivityCard(
                        emoji: '💤',
                        title: 'Body Scan',
                        subtitle:
                            'Notice your feet… then your legs… breathe out',
                        accent: const Color(0xFF7C6AF5),
                        active: false,
                        onTap: () => _showBodyScan(context),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            // Night light glow
            if (_nightlight)
              Positioned.fill(
                child: IgnorePointer(
                  child: AnimatedBuilder(
                    animation: _ambient,
                    builder: (_, __) => Container(
                      decoration: BoxDecoration(
                        gradient: RadialGradient(
                          center: Alignment.bottomCenter,
                          radius: 1.2,
                          colors: [
                            const Color(0xFFFFD700).withValues(
                                alpha: 0.08 + _ambient.value * 0.04),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showStory(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF0A1A2E),
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🦒  Goodnight Story',
                style: TextStyle(
                    color: Color(0xFFF0D6FF),
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    fontFamily: 'DM Sans')),
            const SizedBox(height: 16),
            Text(
              'Far, far away on a quiet golden savanna, a young giraffe '
              'found the perfect sleeping spot beneath the tallest acacia tree.\n\n'
              'The stars came out one by one.\nThe breeze was warm and soft.\n'
              'The giraffe folded its long legs, closed its eyes,\n'
              'and let the night carry it gently to sleep. 🌟',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.70),
                fontSize: 14,
                fontFamily: 'DM Sans',
                height: 1.7,
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  void _showBodyScan(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF0A0A2E),
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('💤  Body Scan',
                style: TextStyle(
                    color: Color(0xFFF0D6FF),
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    fontFamily: 'DM Sans')),
            const SizedBox(height: 16),
            ...[
              '👣  Notice your feet. Let them go heavy.',
              '🦵  Your legs. Breathe out and let go.',
              '🫁  Your tummy rises and falls gently.',
              '🤲  Your hands feel warm and heavy.',
              '😌  Your face softens. Your eyes close.',
              '🌙  You are safe. You can sleep now.',
            ].map((step) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Text(
                    step,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.70),
                      fontSize: 14,
                      fontFamily: 'DM Sans',
                    ),
                  ),
                )),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

// ── Giraffe bed ────────────────────────────────────────────────

class _GiraffeBed extends StatelessWidget {
  const _GiraffeBed();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 160,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0D2240), Color(0xFF050C1A)],
        ),
        border: Border.all(
            color: const Color(0xFF4ECDC4).withValues(alpha: 0.35),
            width: 1.5),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4ECDC4).withValues(alpha: 0.15),
            blurRadius: 30,
          ),
        ],
      ),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('🦒', style: TextStyle(fontSize: 52)),
            SizedBox(height: 8),
            Text(
              'Sweet dreams, tall one 🌙',
              style: TextStyle(
                color: Color(0xFF4ECDC4),
                fontSize: 13,
                fontFamily: 'DM Sans',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Activity card ──────────────────────────────────────────────

class _ActivityCard extends StatelessWidget {
  final String emoji;
  final String title;
  final String subtitle;
  final Color accent;
  final bool active;
  final VoidCallback onTap;

  const _ActivityCard({
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.accent,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: active
              ? accent.withValues(alpha: 0.18)
              : Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: active
                ? accent.withValues(alpha: 0.55)
                : Colors.white.withValues(alpha: 0.10),
          ),
        ),
        child: Row(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 28)),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: TextStyle(
                        color: active ? accent : const Color(0xFFF0D6FF),
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'DM Sans',
                      )),
                  const SizedBox(height: 2),
                  Text(subtitle,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.45),
                        fontSize: 11,
                        fontFamily: 'DM Sans',
                      )),
                ],
              ),
            ),
            if (active)
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.20),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text('ON',
                    style: TextStyle(
                        color: accent,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        fontFamily: 'DM Sans')),
              ),
          ],
        ),
      ),
    );
  }
}

// ── Starfield painter ──────────────────────────────────────────

class _StarfieldPainter extends CustomPainter {
  final double t;
  _StarfieldPainter(this.t);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white;
    final rng = math.Random(42);
    for (int i = 0; i < 60; i++) {
      final x = rng.nextDouble() * size.width;
      final y = rng.nextDouble() * size.height * 0.6;
      final r = 0.5 + rng.nextDouble() * 1.2;
      final opacity =
          0.15 + 0.55 * math.sin(t * math.pi * 2 + i * 0.7).abs();
      canvas.drawCircle(
          Offset(x, y), r, paint..color = Colors.white.withValues(alpha: opacity));
    }
  }

  @override
  bool shouldRepaint(_StarfieldPainter old) => old.t != t;
}
