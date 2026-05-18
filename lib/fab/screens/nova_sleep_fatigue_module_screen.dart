import 'package:flutter/material.dart';

class NovaSleepFatigueModuleScreen extends StatelessWidget {
  const NovaSleepFatigueModuleScreen({super.key});

  static const String routeName = '/nova-sleep-fatigue';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F2FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF4F2FA),
        elevation: 0,
        foregroundColor: const Color(0xFF252235),
        title: const Text('Nova Sleep / Fatigue'),
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
              title: 'Sleep pattern tracking',
              body:
                  'Track bedtime, wake time, night waking, naps, rest quality, and what may have affected sleep.',
              icon: Icons.bedtime_rounded,
            ),
            _InfoCard(
              title: 'Fatigue notes',
              body:
                  'Record low-energy days, crashes, pacing problems, pain flare links, stress links, and recovery needs.',
              icon: Icons.battery_2_bar_rounded,
            ),
            _InfoCard(
              title: 'Routine support',
              body:
                  'Build gentle evening and morning routines that are realistic, calm, and adjustable around family life.',
              icon: Icons.nightlight_round,
            ),
            _InfoCard(
              title: 'Appointment preparation',
              body:
                  'Prepare clear summaries about sleep, tiredness, routines, triggers, and what has helped.',
              icon: Icons.description_rounded,
            ),
            SizedBox(height: 18),
            _SectionTitle('Safety and boundaries'),
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
        color: const Color(0xFFFFFCFF),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: const Color(0xFFDCD5EC)),
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
              color: const Color(0xFFE7DFFF),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(
              Icons.dark_mode_rounded,
              color: Color(0xFF4A3C7A),
              size: 30,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'A calm place to understand sleep, rest, and energy.',
            style: TextStyle(
              fontSize: 25,
              height: 1.1,
              fontWeight: FontWeight.w800,
              color: Color(0xFF252235),
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Nova Sleep / Fatigue is for tracking patterns, spotting what affects rest, and preparing simple notes for yourself or professionals.',
            style: TextStyle(
              fontSize: 15.5,
              height: 1.45,
              color: Color(0xFF5C586C),
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
        color: Color(0xFF252235),
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
        border: Border.all(color: const Color(0xFFE0DCEB)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: const Color(0xFF5C4B96), size: 26),
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
                    color: Color(0xFF252235),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  body,
                  style: const TextStyle(
                    fontSize: 14,
                    height: 1.4,
                    color: Color(0xFF645F74),
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
        color: const Color(0xFFEFF3FF),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFD2DCF7)),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Nova Sleep / Fatigue does not diagnose sleep disorders or replace medical advice.',
            style: TextStyle(
              fontSize: 15,
              height: 1.35,
              fontWeight: FontWeight.w800,
              color: Color(0xFF25385F),
            ),
          ),
          SizedBox(height: 8),
          Text(
            'It helps organise patterns, routines, symptoms, and notes that the user chooses to keep or share.',
            style: TextStyle(
              fontSize: 14,
              height: 1.4,
              color: Color(0xFF40547D),
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
      'Sleep diary',
      'Fatigue tracker',
      'Pacing notes',
      'Evening routine builder',
      'Morning routine builder',
      'Trigger pattern review',
      'Rest plan',
      'Clinician summary export',
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF252235),
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
                  color: const Color(0xFFFFFCFF),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  tool,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF252235),
                  ),
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}