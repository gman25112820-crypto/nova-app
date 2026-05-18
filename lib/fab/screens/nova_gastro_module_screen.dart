import 'package:flutter/material.dart';

class NovaGastroModuleScreen extends StatefulWidget {
  const NovaGastroModuleScreen({super.key});

  @override
  State<NovaGastroModuleScreen> createState() => _NovaGastroModuleScreenState();
}

class _NovaGastroModuleScreenState extends State<NovaGastroModuleScreen> {
  String _mainSymptom = 'Bloating';
  String _stoolNote = 'Normal';
  String _safeNextStep = 'Track and monitor';
  int _severityScore = 4;
  int _stressScore = 3;
  int _sleepScore = 5;

  final Set<String> _symptoms = {};
  final Set<String> _triggers = {};
  final Set<String> _helped = {};
  final TextEditingController _foodCtrl = TextEditingController();
  final TextEditingController _notesCtrl = TextEditingController();

  static const Color _bg = Color(0xFF0D1020);
  static const Color _panel = Color(0xFF171A2E);
  static const Color _panel2 = Color(0xFF211C3A);
  static const Color _text = Color(0xFFF7F4FF);
  static const Color _muted = Color(0xFFB9AECF);
  static const Color _orange = Color(0xFFFFA24C);
  static const Color _amber = Color(0xFFFFC857);
  static const Color _teal = Color(0xFF46D6C8);
  static const Color _rose = Color(0xFFFF6FAE);
  static const Color _purple = Color(0xFF8D6CFF);

  static const List<String> _mainSymptoms = [
    'Bloating',
    'Reflux',
    'Nausea',
    'Cramps',
    'Urgency',
    'Constipation',
    'Loose stool',
    'Food reaction',
    'Flare',
  ];

  static const List<String> _stoolNotes = [
    'Normal',
    'Loose',
    'Hard',
    'Urgent',
    'Painful',
    'Changed',
    'Not sure',
  ];

  static const List<String> _symptomOptions = [
    'Bloating',
    'Gas',
    'Reflux',
    'Nausea',
    'Cramps',
    'Urgency',
    'Constipation',
    'Loose stool',
    'Fatigue after food',
    'Pain after food',
  ];

  static const List<String> _triggerOptions = [
    'Dairy',
    'Gluten/wheat',
    'Spicy food',
    'Greasy food',
    'Large meal',
    'Stress',
    'Poor sleep',
    'Medication change',
    'Too much caffeine',
    'Unknown',
  ];

  static const List<String> _helpedOptions = [
    'Plain food',
    'Hydration',
    'Rest',
    'Heat',
    'Walking gently',
    'Smaller meal',
    'Avoided trigger',
    'Medication routine',
    'Breathing',
    'Logged it',
  ];

  static const List<String> _safeSteps = [
    'Track and monitor',
    'Keep food simple',
    'Hydrate',
    'Rest',
    'Avoid suspected trigger',
    'Prepare GP notes',
    'Prepare dietitian notes',
    'Seek support if worsening',
  ];

  @override
  void dispose() {
    _foodCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  String get _summary {
    return '''
Nova Gastro Summary

Main symptom: $_mainSymptom
Severity: $_severityScore / 10
Stool note: $_stoolNote
Stress today: $_stressScore / 10
Sleep quality: $_sleepScore / 10

Food / possible trigger notes:
${_foodCtrl.text.trim().isEmpty ? 'No food notes entered yet.' : _foodCtrl.text.trim()}

Symptoms selected:
${_symptoms.isEmpty ? 'No symptoms selected yet.' : _symptoms.join(', ')}

Possible triggers:
${_triggers.isEmpty ? 'No triggers selected yet.' : _triggers.join(', ')}

What helped:
${_helped.isEmpty ? 'Nothing selected yet.' : _helped.join(', ')}

Safe next step:
$_safeNextStep

Notes:
${_notesCtrl.text.trim().isEmpty ? 'No notes added yet.' : _notesCtrl.text.trim()}

Safety note:
This is a personal gastro and digestion pattern log only. It does not diagnose IBS, Crohn’s, coeliac disease, allergies, reflux disease, or any medical condition.
''';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _header(),
            const SizedBox(height: 16),
            _section(
              title: 'MAIN GUT SYMPTOM',
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _mainSymptoms.map((item) {
                  return _chip(
                    item,
                    _mainSymptom == item,
                    _orange,
                    () => setState(() => _mainSymptom = item),
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
                    label: 'Severity',
                    value: _severityScore,
                    activeColor: _rose,
                    onChanged: (v) => setState(() => _severityScore = v.round()),
                  ),
                  _sliderRow(
                    label: 'Stress',
                    value: _stressScore,
                    activeColor: _amber,
                    onChanged: (v) => setState(() => _stressScore = v.round()),
                  ),
                  _sliderRow(
                    label: 'Sleep quality',
                    value: _sleepScore,
                    activeColor: _teal,
                    onChanged: (v) => setState(() => _sleepScore = v.round()),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            _section(
              title: 'STOOL / DIGESTION NOTE',
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _stoolNotes.map((note) {
                  return _chip(
                    note,
                    _stoolNote == note,
                    _purple,
                    () => setState(() => _stoolNote = note),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 12),
            _section(
              title: 'FOOD / POSSIBLE TRIGGER NOTES',
              child: TextField(
                controller: _foodCtrl,
                maxLines: 4,
                onChanged: (_) => setState(() {}),
                style: const TextStyle(color: _text),
                decoration: InputDecoration(
                  hintText: 'What did you eat or drink before symptoms changed?',
                  hintStyle: const TextStyle(color: _muted),
                  filled: true,
                  fillColor: _panel2,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                ),
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
              title: 'POSSIBLE TRIGGERS',
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
              title: 'GASTRO NOTES',
              child: TextField(
                controller: _notesCtrl,
                maxLines: 5,
                onChanged: (_) => setState(() {}),
                style: const TextStyle(color: _text),
                decoration: InputDecoration(
                  hintText: 'What changed? What helped? Is this repeating?',
                  hintStyle: const TextStyle(color: _muted),
                  filled: true,
                  fillColor: _panel2,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                ),
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
            _safetyCard(),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _header() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF7A3F0F), Color(0xFF171A2E)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _orange.withValues(alpha: 0.35)),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Nova Gastro',
            style: TextStyle(color: _text, fontSize: 28, fontWeight: FontWeight.w900),
          ),
          SizedBox(height: 8),
          Text(
            'Digestion symptoms, food triggers, stool notes, stress/sleep links, and what helped.',
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
        border: Border.all(color: _orange.withValues(alpha: 0.22)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: _orange,
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
        'Nova Gastro is a personal digestion and pattern log. It does not diagnose IBS, Crohn’s, coeliac disease, allergies, reflux disease, or any condition. If symptoms are severe, new, worsening, include blood, dehydration, weight loss, fever, severe pain, or feel unsafe, seek appropriate medical help.',
        style: TextStyle(color: _text, height: 1.35, fontWeight: FontWeight.w600),
      ),
    );
  }
}