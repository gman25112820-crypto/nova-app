import 'package:flutter/material.dart';

class NovaRecoveryModuleScreen extends StatefulWidget {
  const NovaRecoveryModuleScreen({super.key});

  @override
  State<NovaRecoveryModuleScreen> createState() => _NovaRecoveryModuleScreenState();
}

class _NovaRecoveryModuleScreenState extends State<NovaRecoveryModuleScreen> {
  int _painScore = 5;
  int _energyScore = 5;
  int _fatigueScore = 5;
  String _recoveryState = 'Coping';
  String _safeNextStep = 'Pace myself';
  final Set<String> _triggers = {};
  final Set<String> _helped = {};
  final Set<String> _supportNeeded = {};
  final TextEditingController _notesCtrl = TextEditingController();
  final TextEditingController _routineCtrl = TextEditingController();
  final TextEditingController _setbackCtrl = TextEditingController();
  final TextEditingController _winCtrl = TextEditingController();
  final TextEditingController _appointmentCtrl = TextEditingController();

  static const Color _bg = Color(0xFF0D1020);
  static const Color _panel = Color(0xFF171A2E);
  static const Color _panel2 = Color(0xFF211C3A);
  static const Color _text = Color(0xFFF7F4FF);
  static const Color _muted = Color(0xFFB9AECF);
  static const Color _purple = Color(0xFF8D6CFF);
  static const Color _teal = Color(0xFF46D6C8);
  static const Color _rose = Color(0xFFFF6FAE);
  static const Color _amber = Color(0xFFFFC857);

  static const List<String> _recoveryStates = [
    'Good',
    'Coping',
    'Sore',
    'Flare',
    'Exhausted',
    'Need support',
  ];

  static const List<String> _triggerOptions = [
    'Poor sleep',
    'Too much sitting',
    'Too much standing',
    'Walking',
    'Bending',
    'Stress',
    'Pain spike',
    'Bad news',
    'Arguments',
    'Food/digestion',
  ];

  static const List<String> _helpedOptions = [
    'Rest',
    'Heat',
    'Medication routine',
    'Gentle movement',
    'Lying down',
    'Breathing',
    'Hydration',
    'Food',
    'Asked for help',
    'Stopped early',
  ];

  static const List<String> _supportOptions = [
    'Practical help at home',
    'Someone to talk to',
    'Help getting to appointments',
    'Help with medication',
    'Emotional support',
    'Rest without interruption',
    'Financial/benefits support',
    'Nothing right now',
  ];

  static const List<String> _safeSteps = [
    'Pace myself',
    'Rest and reset',
    'Gentle movement',
    'Use heat',
    'Hydrate',
    'Eat something simple',
    'Ask for help',
    'Stop and recover',
    'Prepare appointment notes',
  ];

  @override
  void dispose() {
    _notesCtrl.dispose();
    _routineCtrl.dispose();
    _setbackCtrl.dispose();
    _winCtrl.dispose();
    _appointmentCtrl.dispose();
    super.dispose();
  }

  String get _summary {
    return '''
Nova Recovery Summary

Recovery state: $_recoveryState
Pain score: $_painScore / 10
Energy score: $_energyScore / 10
Fatigue score: $_fatigueScore / 10

What made it harder:
${_triggers.isEmpty ? 'Nothing selected.' : _triggers.join(', ')}

What helped:
${_helped.isEmpty ? 'Nothing selected.' : _helped.join(', ')}

Support needed:
${_supportNeeded.isEmpty ? 'Nothing selected.' : _supportNeeded.join(', ')}

Safe next step:
$_safeNextStep

Routine today:
${_routineCtrl.text.trim().isEmpty ? 'No routine notes.' : _routineCtrl.text.trim()}

Setback notes:
${_setbackCtrl.text.trim().isEmpty ? 'No setback notes.' : _setbackCtrl.text.trim()}

Small win today:
${_winCtrl.text.trim().isEmpty ? 'No win noted.' : _winCtrl.text.trim()}

General notes:
${_notesCtrl.text.trim().isEmpty ? 'No notes added yet.' : _notesCtrl.text.trim()}

Appointment / support notes:
${_appointmentCtrl.text.trim().isEmpty ? 'No appointment notes.' : _appointmentCtrl.text.trim()}

Safety note:
This is a personal recovery log only. It does not diagnose, prescribe treatment, or replace GP, physio, pain clinic, mental health, addiction recovery, or emergency support.
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
          'Recovery',
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
              title: 'RECOVERY CHECK-IN',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'How is recovery today?',
                    style: TextStyle(color: _text, fontSize: 18, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _recoveryStates.map((state) {
                      return _chip(
                        state,
                        _recoveryState == state,
                        _purple,
                        () => setState(() => _recoveryState = state),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            _section(
              title: 'BODY BASELINE',
              child: Column(
                children: [
                  _sliderRow(
                    label: 'Pain',
                    value: _painScore,
                    activeColor: _rose,
                    onChanged: (v) => setState(() => _painScore = v.round()),
                  ),
                  _sliderRow(
                    label: 'Energy',
                    value: _energyScore,
                    activeColor: _teal,
                    onChanged: (v) => setState(() => _energyScore = v.round()),
                  ),
                  _sliderRow(
                    label: 'Fatigue',
                    value: _fatigueScore,
                    activeColor: _amber,
                    onChanged: (v) => setState(() => _fatigueScore = v.round()),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            _section(
              title: 'WHAT MADE IT HARDER',
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _triggerOptions.map((trigger) {
                  final selected = _triggers.contains(trigger);
                  return _chip(
                    trigger,
                    selected,
                    _rose,
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
              title: 'SUPPORT NEEDED',
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _supportOptions.map((item) {
                  final selected = _supportNeeded.contains(item);
                  return _chip(
                    item,
                    selected,
                    _purple,
                    () {
                      setState(() {
                        selected ? _supportNeeded.remove(item) : _supportNeeded.add(item);
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
                    _amber,
                    () => setState(() => _safeNextStep = step),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 12),
            _section(
              title: 'ROUTINE TODAY',
              child: _textField(
                controller: _routineCtrl,
                hint: 'What routines did you manage today? Pacing, movement, rest, meals?',
              ),
            ),
            const SizedBox(height: 12),
            _section(
              title: 'SETBACK NOTES',
              child: _textField(
                controller: _setbackCtrl,
                hint: 'Any setbacks today? What happened and how did you respond?',
              ),
            ),
            const SizedBox(height: 12),
            _section(
              title: 'SMALL WIN TODAY',
              child: _textField(
                controller: _winCtrl,
                hint: 'What went even a little bit well today? Even small wins count.',
              ),
            ),
            const SizedBox(height: 12),
            _section(
              title: 'RECOVERY NOTES',
              child: _textField(
                controller: _notesCtrl,
                hint: 'What happened today? What helped? What made it harder?',
                maxLines: 5,
              ),
            ),
            const SizedBox(height: 12),
            _section(
              title: 'APPOINTMENT / SUPPORT NOTES',
              child: _textField(
                controller: _appointmentCtrl,
                hint: 'Notes for your next GP, physio, or support conversation.',
                maxLines: 4,
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
    );
  }

  Widget _header() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF3D2A8C), Color(0xFF171A2E)],
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
            'Nova Recovery',
            style: TextStyle(color: _text, fontSize: 28, fontWeight: FontWeight.w900),
          ),
          SizedBox(height: 8),
          Text(
            'Personal recovery, pacing, pain, fatigue, triggers, and what helped.',
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
        border: Border.all(color: _purple.withValues(alpha: 0.22)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: _purple,
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
        'Nova Recovery is a personal log and preparation tool. It does not diagnose, prescribe, or replace professional support. If symptoms are severe, new, worsening, or worrying, seek appropriate medical help.',
        style: TextStyle(color: _text, height: 1.35, fontWeight: FontWeight.w600),
      ),
    );
  }
}