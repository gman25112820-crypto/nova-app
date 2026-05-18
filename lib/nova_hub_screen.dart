import 'package:flutter/material.dart';
import 'package:nova_app/fab/screens/fab_home_screen.dart';
import 'package:nova_app/nova_health_screen.dart';

// Nova Universe Hub — top-level switchboard.
// Fabulously Me and Nova Health are kept as separate branches.

class NovaHubScreen extends StatelessWidget {
  const NovaHubScreen({super.key});

  static const _bg      = Color(0xFF090C18);
  static const _panel   = Color(0xFF13172A);
  static const _text    = Color(0xFFF2EFFF);
  static const _muted   = Color(0xFFAAABC8);
  static const _fabAccent    = Color(0xFFB97FFF);
  static const _healthAccent = Color(0xFF5DADEC);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),
              const Text(
                'Nova',
                style: TextStyle(
                  color: _text,
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Your personal wellbeing universe',
                style: TextStyle(color: _muted, fontSize: 15),
              ),
              const SizedBox(height: 36),

              // ── Fabulously Me card ──────────────────────────────
              _BranchCard(
                icon: Icons.auto_awesome_rounded,
                iconColor: _fabAccent,
                borderColor: _fabAccent.withValues(alpha: 0.35),
                title: 'Fabulously Me',
                subtitle: 'Child and family wellbeing',
                description:
                    'A warm, magical world for children and families. '
                    'Check-ins, calm activities, parent notes, and character friends.',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const FabHomeScreen(),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // ── Nova Health card ────────────────────────────────
              _BranchCard(
                icon: Icons.favorite_border_rounded,
                iconColor: _healthAccent,
                borderColor: _healthAccent.withValues(alpha: 0.35),
                title: 'Nova Health',
                subtitle: 'Your personal health records',
                description:
                    'Track pain, recovery, sleep, nutrition, and patterns. '
                    'Build a personal record for your own understanding and '
                    'appointment preparation.',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const NovaHealthScreen(),
                  ),
                ),
              ),

              const Spacer(),

              // ── Privacy notice ──────────────────────────────────
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: _panel,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.lock_outline_rounded, color: _muted, size: 16),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Nova is designed as a personal record and preparation tool. '
                        'No cloud sharing, accounts, or external data upload are enabled. '
                        'Keep sensitive details private. Your data stays on this device.',
                        style: TextStyle(color: _muted, fontSize: 12.5),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Branch card ───────────────────────────────────────────────────

class _BranchCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color borderColor;
  final String title;
  final String subtitle;
  final String description;
  final VoidCallback onTap;

  const _BranchCard({
    required this.icon,
    required this.iconColor,
    required this.borderColor,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.onTap,
  });

  static const _panel = Color(0xFF13172A);
  static const _text  = Color(0xFFF2EFFF);
  static const _muted = Color(0xFFAAABC8);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        decoration: BoxDecoration(
          color: _panel,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: borderColor, width: 1.2),
        ),
        padding: const EdgeInsets.all(20),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: iconColor, size: 26),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: _text,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: iconColor,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    description,
                    style: const TextStyle(
                      color: _muted,
                      fontSize: 13.5,
                      height: 1.45,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.chevron_right_rounded,
              color: _muted.withValues(alpha: 0.6),
              size: 22,
            ),
          ],
        ),
      ),
    );
  }
}
