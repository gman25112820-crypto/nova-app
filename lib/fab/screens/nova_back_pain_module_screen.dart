import 'package:flutter/material.dart';

class NovaBackPainModuleScreen extends StatefulWidget {
  const NovaBackPainModuleScreen({super.key});

  @override
  State<NovaBackPainModuleScreen> createState() => _NovaBackPainModuleScreenState();
}

class _NovaBackPainModuleScreenState extends State<NovaBackPainModuleScreen> {
  int _painScore = 6;
  int _nerveScore = 5;
  int _mobilityScore = 5;
  int _walkingTolerance = 5;
  int _sittingTolerance = 5;
  int _standingTolerance = 5;
  String _painLocation = 'Lower back';
  String _safeNextStep = 'Pace and monitor';
  final Set<String> _symptoms = {};
  final Set<String> _triggers = {};
  final Set<String> _helped = {};
  final TextEditingController _notesCtrl = TextEditingController();
  final TextEditingController _flareCtrl = TextEditingController();
  final TextEditingController _medicationCtrl = TextEditingController();
  final TextEditingController _sleepCtrl = TextEditingController();
  final TextEditingController _gpNotesCtrl = TextEditingController();
  final TextEditingController _evidenceCtrl = TextEditingController();

  static const Color _bg = Color(0xFF0D1020);
  static const Color _panel = Color(0xFF171A2E);
  static const Color _panel2 = Color(0xFF211C3A);
  static const Color _text = Color(0xFFF7F4FF);
  static const Color _muted = Color(0xFFB9AECF);
  static const Color _purple = Color(0xFF8D6CFF);
  static const Color _blue = Color(0xFF5DADEC);
  static const Color _rose = Color(0xFFFF6FAE);
  static const Color _amber = Color(0xFFFFC857);
  static const Color _teal = Color(0xFF46D6C8);

  static const List<String> _locations = [
    'Lower back',
    'Middle back',
    'Upper back',
    'Hip',
    'Left leg',
    'Right leg',
    'Both legs',
    'Neck/shoulder',
  ];

  static const List<String> _symptomOptions = [
    'Sciatica',
    'Nerve pain',
    'Sharp pain',
    'Dull ache',
    'Burning',
    'Pins and needles',
    'Numbness',
    'Stiffness',
    'Weakness',
    'Spasm',
  ];

  static const List<String> _triggerOptions = [
    'Sitting too long',
    'Standing too long',
    'Walking',
    'Bending',
    'Lifting',
    'Poor sleep',
    'Stress',
    'Cold weather',
    'Overdoing it',
    'Unknown',
  ];

  static const List<String> _helpedOptions = [
    'Rest',
    'Heat',
    'Medication routine',
    'Gentle movement',
    'Changing position',
    'Lying down',
    'Stretching carefully',
    'Breathing',
    'Asked for help',
    'Stopped activity',
  ];

  static const List<String> _safeSteps = [
    'Pace and monitor',
    'Rest and reset',
    'Gentle movement only',
    'Avoid lifting',
    'Use heat',
    'Change position',
    'Prepare GP/physio notes',
    'Ask for help',
    'Stop and recover',
  ];

  @override
  void dispose() {
    _notesCtrl.dispose();
    _flareCtrl.dispose();
    _medicationCtrl.dispose();
    _sleepCtrl.dispose();
    _gpNotesCtrl.dispose();
    _evidenceCtrl.dispose();
    super.dispose();
  }

  String get _summary {
    return '''
Nova Back Pain Summary

Main location: $_painLocation
Pain score: $_painScore / 10
Nerve symptom score: $_nerveScore / 10
Mobility impact: $_mobilityScore / 10
Walking tolerance: $_walkingTolerance / 10
Sitting tolerance: $_sittingTolerance / 10
Standing tolerance: $_standingTolerance / 10

Symptoms:
${_symptoms.isEmpty ? 'No symptoms selected yet.' : _symptoms.join(', ')}

What made it worse:
${_triggers.isEmpty ? 'Nothing selected yet.' : _triggers.join(', ')}

What helped:
${_helped.isEmpty ? 'Nothing selected yet.' : _helped.join(', ')}

Safe next step:
$_safeNextStep

Flare-up notes:
${_flareCtrl.text.trim().isEmpty ? 'No flare-up notes added yet.' : _flareCtrl.text.trim()}

Medication notes:
${_medicationCtrl.text.trim().isEmpty ? 'No medication notes added yet.' : _medicationCtrl.text.trim()}

Sleep impact:
${_sleepCtrl.text.trim().isEmpty ? 'No sleep impact notes added yet.' : _sleepCtrl.text.trim()}

General notes:
${_notesCtrl.text.trim().isEmpty ? 'No notes added yet.' : _notesCtrl.text.trim()}

Appointment / GP notes:
${_gpNotesCtrl.text.trim().isEmpty ? 'No GP notes added yet.' : _gpNotesCtrl.text.trim()}

Evidence / support notes:
${_evidenceCtrl.text.trim().isEmpty ? 'No evidence notes added yet.' : _evidenceCtrl.text.trim()}

Safety note:
This is a personal back pain and sciatica log only. It does not diagnose, prescribe treatment, or replace GP, physio, pain clinic, emergency care, or specialist advice.
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
          'Back Pain',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _header(),
          const SizedBox(height: 16),
            _section(
              title: 'PAIN LOCATION',
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _locations.map((location) {
                  return _chip(
                    location,
                    _painLocation == location,
                    _blue,
                    () => setState(() => _painLocation = location),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 12),
            _section(
              title: 'TODAY’S BASELINE',
              child: Column(
                children: [
                  _sliderRow(
                    label: 'Pain',
                    value: _painScore,
                    activeColor: _rose,
                    onChanged: (v) => setState(() => _painScore = v.round()),
                  ),
                  _sliderRow(
                    label: 'Nerve symptoms',
                    value: _nerveScore,
                    activeColor: _amber,
                    onChanged: (v) => setState(() => _nerveScore = v.round()),
                  ),
                  _sliderRow(
                    label: 'Mobility impact',
                    value: _mobilityScore,
                    activeColor: _teal,
                    onChanged: (v) => setState(() => _mobilityScore = v.round()),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            _section(
              title: 'TOLERANCE TODAY',
              child: Column(
                children: [
                  _sliderRow(
                    label: 'Walking tolerance',
                    value: _walkingTolerance,
                    activeColor: _teal,
                    onChanged: (v) => setState(() => _walkingTolerance = v.round()),
                  ),
                  _sliderRow(
                    label: 'Sitting tolerance',
                    value: _sittingTolerance,
                    activeColor: _blue,
                    onChanged: (v) => setState(() => _sittingTolerance = v.round()),
                  ),
                  _sliderRow(
                    label: 'Standing tolerance',
                    value: _standingTolerance,
                    activeColor: _purple,
                    onChanged: (v) => setState(() => _standingTolerance = v.round()),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            _section(
              title: 'SYMPTOMS',
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _symptomOptions.map((symptom) {
                  final selected = _symptoms.contains(symptom);
                  return _chip(
                    symptom,
                    selected,
                    _rose,
                    () {
                      setState(() {
                        selected ? _symptoms.remove(symptom) : _symptoms.add(symptom);
                      });
                    },
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 12),
            _section(
              title: 'WHAT MADE IT WORSE',
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _triggerOptions.map((trigger) {
                  final selected = _triggers.contains(trigger);
                  return _chip(
                    trigger,
                    selected,
                    _amber,
                    () {
                      setState(() {
                        selected ? _triggers.remove(trigger) : _triggers.add(trigger);
                      });
                    },
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 12),
            _section(
              title: 'WHAT HELPED',
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _helpedOptions.map((item) {
                  final selected = _helped.contains(item);
                  return _chip(
                    item,
                    selected,
                    _teal,
                    () {
                      setState(() {
                        selected ? _helped.remove(item) : _helped.add(item);
                      });
                    },
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 12),
            _section(
              title: 'SAFE NEXT STEP',
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _safeSteps.map((step) {
                  return _chip(
                    step,
                    _safeNextStep == step,
                    _purple,
                    () => setState(() => _safeNextStep = step),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 12),
            _section(
              title: 'FLARE-UP NOTES',
              child: _textField(
                controller: _flareCtrl,
                hint: 'Describe any flare-up today — what triggered it, how severe, how long it lasted.',
              ),
            ),
            const SizedBox(height: 12),
            _section(
              title: 'MEDICATION NOTES',
              child: _textField(
                controller: _medicationCtrl,
                hint: 'What did you take, when, and did it help? (For your own reference only.)',
              ),
            ),
            const SizedBox(height: 12),
            _section(
              title: 'SLEEP IMPACT',
              child: _textField(
                controller: _sleepCtrl,
                hint: 'How did pain affect your sleep last night? Could you lie flat, turn over, get comfortable?',
              ),
            ),
            const SizedBox(height: 12),
            _section(
              title: 'BACK PAIN NOTES',
              child: _textField(
                controller: _notesCtrl,
                hint: 'What happened? How did it affect sitting, standing, walking, or daily tasks?',
                maxLines: 5,
              ),
            ),
            const SizedBox(height: 12),
            _section(
              title: 'APPOINTMENT / GP NOTES',
              child: _textField(
                controller: _gpNotesCtrl,
                hint: 'Notes to raise at your next GP, physio, or specialist appointment.',
                maxLines: 4,
              ),
            ),
            const SizedBox(height: 12),
            _section(
              title: 'EVIDENCE / SUPPORT NOTES',
              child: _textField(
                controller: _evidenceCtrl,
                hint: 'Notes for benefits evidence, support letters, or Personal Independence Payment (PIP) records. Describe impact on daily life in your own words.',
                maxLines: 5,
              ),
            ),
            const SizedBox(height: 12),
            _section(
              title: 'SUMMARY PREVIEW',
              child: SelectableText(
                _summary,
                style: const TextStyle(color: _text, height: 1.35),
              ),
            ),
            const SizedBox(height: 12),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                'This does not replace medical advice. '
                'It helps you keep a clearer personal record.',
                style: TextStyle(color: _muted, fontSize: 13, height: 1.45),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 12),
            _safetyCard(),
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
          colors: [Color(0xFF17335A), Color(0xFF171A2E)],
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
            'Nova Back Pain',
            style: TextStyle(color: _text, fontSize: 28, fontWeight: FontWeight.w900),
          ),
          SizedBox(height: 8),
          Text(
            'Back pain, sciatica, nerve symptoms, triggers, mobility impact, and what helped.',
            style: TextStyle(color: _muted, fontSize: 14, height: 1.35),
          ),
        ],
      ),
    );
  }

  Widget _section({required String title, required Widget child}) {
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
          child,
        ],
      ),
    );
  }

  Widget _sliderRow({
    required String label,
    required int value,
    required Color activeColor,
    required ValueChanged<double> onChanged,
  }) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: const TextStyle(color: _text, fontWeight: FontWeight.w700),
              ),
            ),
            Text(
              '$value / 10',
              style: TextStyle(color: activeColor, fontWeight: FontWeight.w900),
            ),
          ],
        ),
        Slider(
          value: value.toDouble(),
          min: 0,
          max: 10,
          divisions: 10,
          activeColor: activeColor,
          inactiveColor: activeColor.withValues(alpha: 0.18),
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _textField({
    required TextEditingController controller,
    required String hint,
    int maxLines = 3,
  }) {
    return TextField(
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
    );
  }

  Widget _chip(String label, bool selected, Color color, VoidCallback onTap) {
    return InkWell(
      borderRadius: BorderRadius.circular(30),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? color.withValues(alpha: 0.2) : _panel2,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: selected ? color : color.withValues(alpha: 0.22)),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? color : _muted,
            fontWeight: selected ? FontWeight.w800 : FontWeight.w500,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  Widget _safetyCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF332A14),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _amber.withValues(alpha: 0.35)),
      ),
      child: const Text(
        'Nova Back Pain is a personal tracking and appointment-prep tool. It does not diagnose or replace professional support. If symptoms are severe, new, worsening, linked to weakness/numbness, bladder/bowel changes, fever, injury, or feel unsafe, seek appropriate medical help.',
        style: TextStyle(color: _text, height: 1.35, fontWeight: FontWeight.w600),
      ),
    );
  }
}