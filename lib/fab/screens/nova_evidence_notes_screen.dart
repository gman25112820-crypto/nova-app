import 'package:flutter/material.dart';

class NovaEvidenceNotesScreen extends StatefulWidget {
  const NovaEvidenceNotesScreen({super.key});

  @override
  State<NovaEvidenceNotesScreen> createState() =>
      _NovaEvidenceNotesScreenState();
}

class _NovaEvidenceNotesScreenState extends State<NovaEvidenceNotesScreen> {
  final TextEditingController _symptomsCtrl = TextEditingController();
  final TextEditingController _frequencyCtrl = TextEditingController();
  final TextEditingController _dailyImpactCtrl = TextEditingController();
  final TextEditingController _mobilityCtrl = TextEditingController();
  final TextEditingController _sleepCtrl = TextEditingController();
  final TextEditingController _medicationCtrl = TextEditingController();
  final TextEditingController _whatHelpsCtrl = TextEditingController();
  final TextEditingController _appointmentCtrl = TextEditingController();

  static const Color _bg = Color(0xFF0D1020);
  static const Color _panel = Color(0xFF171A2E);
  static const Color _panel2 = Color(0xFF211C3A);
  static const Color _text = Color(0xFFF7F4FF);
  static const Color _muted = Color(0xFFB9AECF);
  static const Color _blue = Color(0xFF8DA7C4);
  static const Color _amber = Color(0xFFFFC857);

  @override
  void dispose() {
    _symptomsCtrl.dispose();
    _frequencyCtrl.dispose();
    _dailyImpactCtrl.dispose();
    _mobilityCtrl.dispose();
    _sleepCtrl.dispose();
    _medicationCtrl.dispose();
    _whatHelpsCtrl.dispose();
    _appointmentCtrl.dispose();
    super.dispose();
  }

  String get _summary {
    return '''
Evidence Notes Summary

Symptoms:
${_symptomsCtrl.text.trim().isEmpty ? 'Not filled in.' : _symptomsCtrl.text.trim()}

Frequency and pattern:
${_frequencyCtrl.text.trim().isEmpty ? 'Not filled in.' : _frequencyCtrl.text.trim()}

Impact on daily living:
${_dailyImpactCtrl.text.trim().isEmpty ? 'Not filled in.' : _dailyImpactCtrl.text.trim()}

Mobility limits:
${_mobilityCtrl.text.trim().isEmpty ? 'Not filled in.' : _mobilityCtrl.text.trim()}

Sleep impact:
${_sleepCtrl.text.trim().isEmpty ? 'Not filled in.' : _sleepCtrl.text.trim()}

Medication notes:
${_medicationCtrl.text.trim().isEmpty ? 'Not filled in.' : _medicationCtrl.text.trim()}

What helps:
${_whatHelpsCtrl.text.trim().isEmpty ? 'Not filled in.' : _whatHelpsCtrl.text.trim()}

Appointment preparation notes:
${_appointmentCtrl.text.trim().isEmpty ? 'Not filled in.' : _appointmentCtrl.text.trim()}

---
This summary is a personal record only. It does not constitute official evidence, a clinical report, or a benefits claim. Use it as a starting point for conversations with clinicians or support services.
''';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        foregroundColor: _text,
        title: const Text(
          'Evidence Notes',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _header(),
          const SizedBox(height: 16),

          // ── What this area is for ────────────────────────────
          _panel_(
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'What this area is for',
                  style: TextStyle(
                      color: _text,
                      fontSize: 15,
                      fontWeight: FontWeight.w700),
                ),
                SizedBox(height: 8),
                Text(
                  'This area helps you prepare clear notes about your health, '
                  'daily impact, and needs. You can use these notes to prepare '
                  'for GP appointments, physio sessions, support letters, or '
                  'benefits and evidence conversations.',
                  style: TextStyle(color: _muted, fontSize: 14, height: 1.5),
                ),
                SizedBox(height: 8),
                Text(
                  'Write in your own words. Plain, honest descriptions of '
                  'how things affect you day to day are the most useful.',
                  style: TextStyle(color: _muted, fontSize: 14, height: 1.5),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // ── What to include note ─────────────────────────────
          _panel_(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'What to include',
                  style: TextStyle(
                      color: _text,
                      fontSize: 15,
                      fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 10),
                ...[
                  'Symptoms — what you experience and how often',
                  'Frequency — daily, weekly, constant, or unpredictable',
                  'Impact on daily living — cooking, dressing, shopping, cleaning',
                  'Mobility limits — walking distance, standing time, sitting time',
                  'Sleep impact — how health affects rest and recovery',
                  'Medication notes — what you take and whether it helps',
                  'What helps — rest, heat, pacing, changing position',
                ].map(
                  (item) => Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('• ',
                            style:
                                TextStyle(color: _blue, fontWeight: FontWeight.w700)),
                        Expanded(
                          child: Text(
                            item,
                            style: const TextStyle(
                                color: _muted, fontSize: 13.5, height: 1.4),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // ── Input sections ───────────────────────────────────
          _section(
            title: 'SYMPTOMS',
            hint: 'Describe your main symptoms in your own words. What do you experience? What does it feel like?',
            controller: _symptomsCtrl,
          ),
          const SizedBox(height: 12),
          _section(
            title: 'FREQUENCY AND PATTERN',
            hint: 'How often do symptoms occur? Daily, weekly, constant, unpredictable? Any pattern you have noticed?',
            controller: _frequencyCtrl,
          ),
          const SizedBox(height: 12),
          _section(
            title: 'IMPACT ON DAILY LIVING',
            hint: 'How do symptoms affect daily tasks? Cooking, dressing, shopping, housework, childcare, work, socialising?',
            controller: _dailyImpactCtrl,
            maxLines: 5,
          ),
          const SizedBox(height: 12),
          _section(
            title: 'MOBILITY LIMITS',
            hint: 'How far can you walk? How long can you stand or sit? What movements are difficult or painful?',
            controller: _mobilityCtrl,
          ),
          const SizedBox(height: 12),
          _section(
            title: 'SLEEP IMPACT',
            hint: 'How does pain, fatigue, or symptoms affect your sleep? Can you get comfortable? Do you wake during the night?',
            controller: _sleepCtrl,
          ),
          const SizedBox(height: 12),
          _section(
            title: 'MEDICATION NOTES',
            hint: 'What do you take, how often, and does it help? Any side effects? (For your own reference — not a prescription record.)',
            controller: _medicationCtrl,
          ),
          const SizedBox(height: 12),
          _section(
            title: 'WHAT HELPS',
            hint: 'What helps manage symptoms? Rest, heat, pacing, changing position, medication timing, support from others?',
            controller: _whatHelpsCtrl,
          ),
          const SizedBox(height: 12),
          _section(
            title: 'APPOINTMENT PREPARATION NOTES',
            hint: 'What do you want to raise at your next appointment? Questions, concerns, requests for referrals or support?',
            controller: _appointmentCtrl,
            maxLines: 5,
          ),
          const SizedBox(height: 16),

          // ── Summary preview ──────────────────────────────────
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: _panel,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: _blue.withValues(alpha: 0.22)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'SUMMARY DRAFT',
                  style: TextStyle(
                    color: _blue,
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 12),
                SelectableText(
                  _summary,
                  style: const TextStyle(color: _text, height: 1.35),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // ── What this does not do ────────────────────────────
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFF332A14),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: _amber.withValues(alpha: 0.35)),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'What this does not do',
                  style: TextStyle(
                      color: _amber,
                      fontSize: 14,
                      fontWeight: FontWeight.w700),
                ),
                SizedBox(height: 8),
                Text(
                  '• Does not send or upload your data\n'
                  '• Does not replace professional medical advice\n'
                  '• Does not automatically create official claims\n'
                  '• Does not generate clinical reports\n'
                  '• Does not share anything without your action',
                  style: TextStyle(color: _text, height: 1.55, fontSize: 13.5),
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
          colors: [Color(0xFF1D2E3F), Color(0xFF171A2E)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _blue.withValues(alpha: 0.35)),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Evidence Notes',
            style: TextStyle(
                color: _text, fontSize: 28, fontWeight: FontWeight.w900),
          ),
          SizedBox(height: 8),
          Text(
            'Prepare clear personal notes for appointments, support conversations, '
            'or evidence and benefits records. Written in your own words, kept on your device.',
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
        border: Border.all(color: _blue.withValues(alpha: 0.18)),
      ),
      child: child,
    );
  }

  Widget _section({
    required String title,
    required String hint,
    required TextEditingController controller,
    int maxLines = 3,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _panel,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _blue.withValues(alpha: 0.22)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: _blue,
              fontSize: 11,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: controller,
            maxLines: maxLines,
            onChanged: (_) => setState(() {}),
            style: const TextStyle(color: _text),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(color: _muted),
              filled: true,
              fillColor: _panel2,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
