import 'package:flutter/material.dart';

class NovaInsightsModuleScreen extends StatelessWidget {
  const NovaInsightsModuleScreen({super.key});

  static const Color _bg = Color(0xFF0D1020);
  static const Color _panel = Color(0xFF171A2E);
  static const Color _panel2 = Color(0xFF1C1A36);
  static const Color _text = Color(0xFFF7F4FF);
  static const Color _muted = Color(0xFFB9AECF);
  static const Color _purple = Color(0xFFB97FFF);
  static const Color _teal = Color(0xFF46D6C8);
  static const Color _amber = Color(0xFFFFC857);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        foregroundColor: _text,
        title: const Text(
          'Insights',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _header(),
          const SizedBox(height: 20),

          // ── What Insights will do ────────────────────────────
          _panel_(
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'What Insights will do',
                  style: TextStyle(
                      color: _text,
                      fontSize: 16,
                      fontWeight: FontWeight.w700),
                ),
                SizedBox(height: 10),
                Text(
                  'Insights will help spot patterns across pain, sleep, fatigue, '
                  'food, mood, routines, and flare-ups.',
                  style: TextStyle(color: _muted, fontSize: 14, height: 1.5),
                ),
                SizedBox(height: 8),
                Text(
                  'It will connect your own notes across modules — not pull data from anywhere else. '
                  'You choose what to review, what to keep, and what to share.',
                  style: TextStyle(color: _muted, fontSize: 14, height: 1.5),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // ── Not active yet banner ────────────────────────────
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: _amber.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: _amber.withValues(alpha: 0.35)),
            ),
            child: const Row(
              children: [
                Icon(Icons.hourglass_top_rounded, color: _amber, size: 18),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Pattern summaries are not active yet. '
                    'The cards below are examples of what Insights will show.',
                    style: TextStyle(color: _amber, fontSize: 13, height: 1.4),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // ── Example insight cards ────────────────────────────
          const Padding(
            padding: EdgeInsets.only(left: 4, bottom: 10),
            child: Text(
              'EXAMPLE INSIGHTS — NOT ACTIVE',
              style: TextStyle(
                color: _purple,
                fontSize: 11,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.2,
              ),
            ),
          ),

          _exampleInsightCard(
            icon: Icons.bedtime_rounded,
            color: _purple,
            text: 'Pain appears worse after poor sleep.',
            detail: 'Based on back pain score vs sleep quality across logged days.',
          ),
          const SizedBox(height: 10),
          _exampleInsightCard(
            icon: Icons.battery_2_bar_rounded,
            color: _amber,
            text: 'Fatigue rises after high-activity days.',
            detail: 'Based on energy score and fatigue level across logged days.',
          ),
          const SizedBox(height: 10),
          _exampleInsightCard(
            icon: Icons.restaurant_menu_rounded,
            color: _teal,
            text: 'Certain meals may link with gastro symptoms.',
            detail: 'Based on meal notes and gastro symptom logs.',
          ),
          const SizedBox(height: 20),

          // ── Not medical diagnosis ────────────────────────────
          _panel_(
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'What Insights is not',
                  style: TextStyle(
                      color: _text,
                      fontSize: 15,
                      fontWeight: FontWeight.w700),
                ),
                SizedBox(height: 8),
                Text(
                  'Insights does not diagnose, prescribe, or replace medical advice. '
                  'It is a pattern-spotting tool to help you understand your own experience '
                  'and prepare for appointments or support conversations.',
                  style: TextStyle(color: _muted, fontSize: 14, height: 1.5),
                ),
                SizedBox(height: 8),
                Text(
                  'Patterns shown are based only on what you log here. '
                  'They are not clinical findings.',
                  style: TextStyle(color: _muted, fontSize: 14, height: 1.5),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // ── Coming next ──────────────────────────────────────
          _panel_(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Coming next',
                  style: TextStyle(
                      color: _text,
                      fontSize: 15,
                      fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    'Weekly pattern summary',
                    'Trigger review',
                    'Progress timeline',
                    'What helped list',
                    'Appointment prep notes',
                    'Consent-led sharing',
                  ]
                      .map(
                        (label) => Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 11, vertical: 6),
                          decoration: BoxDecoration(
                            color: _panel2,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                                color: _purple.withValues(alpha: 0.30)),
                          ),
                          child: Text(
                            label,
                            style: const TextStyle(
                                color: _muted,
                                fontSize: 12,
                                fontWeight: FontWeight.w500),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _header() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF30195A), Color(0xFF171A2E)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _purple.withValues(alpha: 0.35)),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Nova Insights',
            style:
                TextStyle(color: _text, fontSize: 28, fontWeight: FontWeight.w900),
          ),
          SizedBox(height: 8),
          Text(
            'A clearer view of what your records are telling you. '
            'Pattern summaries will connect notes across pain, sleep, food, fatigue, and more.',
            style: TextStyle(color: _muted, fontSize: 14, height: 1.35),
          ),
        ],
      ),
    );
  }

  Widget _panel_({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _panel,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _purple.withValues(alpha: 0.18)),
      ),
      child: child,
    );
  }

  Widget _exampleInsightCard({
    required IconData icon,
    required Color color,
    required String text,
    required String detail,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _panel,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.30)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  text,
                  style: TextStyle(
                      color: color, fontSize: 14, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                Text(
                  detail,
                  style: const TextStyle(
                      color: _muted, fontSize: 12.5, height: 1.4),
                ),
                const SizedBox(height: 6),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: _amber.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    'EXAMPLE — NOT ACTIVE',
                    style: TextStyle(
                        color: _amber,
                        fontSize: 9.5,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
