import 'package:flutter/material.dart';
import 'package:nova_app/fab/screens/nova_back_pain_module_screen.dart';
import 'package:nova_app/fab/screens/nova_recovery_module_screen.dart';
import 'package:nova_app/fab/screens/nova_sleep_fatigue_module_screen.dart';
import 'package:nova_app/fab/screens/nova_nutrition_module_screen.dart';
import 'package:nova_app/fab/screens/nova_gastro_module_screen.dart';
import 'package:nova_app/fab/screens/nova_cooking_module_screen.dart';
import 'package:nova_app/fab/screens/nova_insights_module_screen.dart';

// Nova Health — personal health module menu.
// All records are local and private. Nothing leaves the device.
// This is a personal record and appointment-preparation tool,
// not a medical service or clinical tool.

class NovaHealthScreen extends StatelessWidget {
  const NovaHealthScreen({super.key});

  static const _bg     = Color(0xFF090C18);
  static const _text   = Color(0xFFF2EFFF);
  static const _muted  = Color(0xFFAAABC8);
  static const _blue   = Color(0xFF5DADEC);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        foregroundColor: _text,
        title: const Text(
          'Nova Health',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: [
          // ── Purpose note ───────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.only(bottom: 24),
            decoration: BoxDecoration(
              color: _blue.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: _blue.withValues(alpha: 0.22), width: 1),
            ),
            child: const Text(
              'A personal record to help you understand your own patterns '
              'and prepare for appointments, support conversations, or '
              'evidence and benefits notes. Your data stays on this device. '
              'No accounts, cloud sync, or data sharing are enabled.',
              style: TextStyle(color: _muted, fontSize: 13.5, height: 1.5),
            ),
          ),

          // ── Modules ────────────────────────────────────────────
          _ModuleCard(
            icon: Icons.accessibility_new_rounded,
            color: const Color(0xFFFF6FAE),
            title: 'Back Pain',
            description:
                'Track pain, flare-ups, mobility limits, medication notes, '
                'sleep impact, and what helps.',
            onTap: () => _push(context, const NovaBackPainModuleScreen()),
          ),
          _ModuleCard(
            icon: Icons.trending_up_rounded,
            color: const Color(0xFF5DADEC),
            title: 'Recovery',
            description:
                'Record progress, setbacks, routines, support needs, '
                'and wins over time.',
            onTap: () => _push(context, const NovaRecoveryModuleScreen()),
          ),
          _ModuleCard(
            icon: Icons.bedtime_rounded,
            color: const Color(0xFF9B8FFF),
            title: 'Sleep / Fatigue',
            description:
                'Log sleep quality, fatigue patterns, rest strategies, '
                'and how sleep affects daily life.',
            onTap: () => _push(context, const NovaSleepFatigueModuleScreen()),
          ),
          _ModuleCard(
            icon: Icons.restaurant_menu_rounded,
            color: const Color(0xFF46D6C8),
            title: 'Nutrition',
            description:
                'Record meals, food sensitivities, energy patterns, '
                'and what nourishes you day to day.',
            onTap: () => _push(context, const NovaNutritionModuleScreen()),
          ),
          _ModuleCard(
            icon: Icons.monitor_heart_rounded,
            color: const Color(0xFFFFC857),
            title: 'Gastro',
            description:
                'Track gut symptoms, triggers, food reactions, '
                'and patterns over time.',
            onTap: () => _push(context, const NovaGastroModuleScreen()),
          ),
          _ModuleCard(
            icon: Icons.soup_kitchen_rounded,
            color: const Color(0xFF7EC87A),
            title: 'Cooking',
            description:
                'Save recipes, adapt meals for your needs, '
                'and keep a personal kitchen log.',
            onTap: () => _push(context, const NovaCookingModuleScreen()),
          ),
          _ModuleCard(
            icon: Icons.insights_rounded,
            color: const Color(0xFFB97FFF),
            title: 'Insights',
            description:
                'Spot patterns across pain, sleep, food, fatigue, '
                'mood, and daily routines.',
            onTap: () => _push(context, const NovaInsightsModuleScreen()),
          ),

          // ── Clinician Export — placeholder ────────────────────
          _ModuleCard(
            icon: Icons.description_outlined,
            color: const Color(0xFF8DA7C4),
            title: 'Clinician Export / Evidence Notes',
            description:
                'Prepare a clear summary of your records for appointments, '
                'support letters, or benefits evidence. Coming next.',
            badge: 'Coming next',
            onTap: null,
          ),
        ],
      ),
    );
  }

  void _push(BuildContext context, Widget screen) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
  }
}

// ── Module card ───────────────────────────────────────────────────

class _ModuleCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String description;
  final String? badge;
  final VoidCallback? onTap;

  const _ModuleCard({
    required this.icon,
    required this.color,
    required this.title,
    required this.description,
    this.badge,
    this.onTap,
  });

  static const _panel = Color(0xFF13172A);
  static const _text  = Color(0xFFF2EFFF);
  static const _muted = Color(0xFFAAABC8);

  @override
  Widget build(BuildContext context) {
    final available = onTap != null;
    return GestureDetector(
      onTap: onTap,
      child: Opacity(
        opacity: available ? 1.0 : 0.65,
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _panel,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: available
                  ? color.withValues(alpha: 0.28)
                  : const Color(0xFF2A2D45),
              width: 1,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            color: _text,
                            fontSize: 15.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (badge != null) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 7, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFF2A2D45),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              badge!,
                              style: const TextStyle(
                                color: _muted,
                                fontSize: 10.5,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 5),
                    Text(
                      description,
                      style: const TextStyle(
                        color: _muted,
                        fontSize: 13,
                        height: 1.45,
                      ),
                    ),
                  ],
                ),
              ),
              if (available)
                Icon(
                  Icons.chevron_right_rounded,
                  color: _muted.withValues(alpha: 0.5),
                  size: 20,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
