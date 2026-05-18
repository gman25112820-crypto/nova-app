import 'package:flutter/material.dart';

class NovaInsightsModuleScreen extends StatelessWidget {
  const NovaInsightsModuleScreen({super.key});

  static const String routeName = '/nova-insights';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F7F6),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF2F7F6),
        elevation: 0,
        foregroundColor: const Color(0xFF203735),
        title: const Text('Nova Insights'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: const [
            _HeroCard(),
            SizedBox(height: 16),
            _SectionTitle('What this module helps with'),
            SizedBox(height: 10),
            _InfoCard(
              title: 'Pattern spotting',
              body:
                  'Bring together notes from recovery, pain, food, sleep, symptoms, routines, and daily check-ins to help spot useful patterns.',
              icon: Icons.auto_graph_rounded,
            ),
            _InfoCard(
              title: 'Plain-English summaries',
              body:
                  'Turn scattered notes into calm summaries that explain what changed, what helped, and what may need attention.',
              icon: Icons.summarize_rounded,
            ),
            _InfoCard(
              title: 'Personal timeline',
              body:
                  'Create a clearer view of weeks and months, including better days, harder days, triggers, routines, and progress.',
              icon: Icons.timeline_rounded,
            ),
            _InfoCard(
              title: 'Next-best-action prompts',
              body:
                  'Suggest practical next steps like logging a note, checking a pattern, preparing an appointment summary, or reviewing a routine.',
              icon: Icons.lightbulb_rounded,
            ),
            SizedBox(height: 18),
            _SectionTitle('Privacy-first design'),
            SizedBox(height: 10),
            _SafetyCard(),
            SizedBox(height: 18),
            _SectionTitle('Future tools'),
            SizedBox(height: 10),
            _FutureToolsCard(),
          ],
        ),
      ),
    );
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFEFC),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: const Color(0xFFD4E6E2)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 18,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: const Color(0xFFDDF3EC),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(
              Icons.insights_rounded,
              color: Color(0xFF1F675B),
              size: 30,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'A clearer view of what your records are trying to tell you.',
            style: TextStyle(
              fontSize: 25,
              height: 1.1,
              fontWeight: FontWeight.w800,
              color: Color(0xFF203735),
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Nova Insights is the pattern and summary layer for the wider Nova universe. It helps connect notes across modules without taking ownership away from the user.',
            style: TextStyle(
              fontSize: 15.5,
              height: 1.45,
              color: Color(0xFF526866),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;

  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w800,
        color: Color(0xFF203735),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String title;
  final String body;
  final IconData icon;

  const _InfoCard({
    required this.title,
    required this.body,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFD8E7E4)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: const Color(0xFF1F675B), size: 26),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15.5,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF203735),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  body,
                  style: const TextStyle(
                    fontSize: 14,
                    height: 1.4,
                    color: Color(0xFF5C6F6C),
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

class _SafetyCard extends StatelessWidget {
  const _SafetyCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF6F1),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFCBE7DC)),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Nova Insights does not diagnose, score risk clinically, or automatically share records.',
            style: TextStyle(
              fontSize: 15,
              height: 1.35,
              fontWeight: FontWeight.w800,
              color: Color(0xFF214D42),
            ),
          ),
          SizedBox(height: 8),
          Text(
            'It should explain patterns clearly and help the user decide what they want to keep, review, or export.',
            style: TextStyle(
              fontSize: 14,
              height: 1.4,
              color: Color(0xFF41695F),
            ),
          ),
        ],
      ),
    );
  }
}

class _FutureToolsCard extends StatelessWidget {
  const _FutureToolsCard();

  @override
  Widget build(BuildContext context) {
    final tools = [
      'Weekly pattern summary',
      'Trigger review',
      'Progress timeline',
      'Module comparison',
      'What helped list',
      'Appointment prep notes',
      'Export preview',
      'Consent-led sharing',
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF203735),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: tools
            .map(
              (tool) => Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFFEFC),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  tool,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF203735),
                  ),
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}