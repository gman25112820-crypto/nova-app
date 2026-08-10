import 'package:flutter/material.dart';

import '../../core/models/sleep_fatigue_entry.dart';
import '../../core/repositories/sleep_fatigue_repository.dart';

class NovaSleepFatigueModuleScreen extends StatefulWidget {
  const NovaSleepFatigueModuleScreen({super.key});

  @override
  State<NovaSleepFatigueModuleScreen> createState() =>
      _NovaSleepFatigueModuleScreenState();
}

class _NovaSleepFatigueModuleScreenState
    extends State<NovaSleepFatigueModuleScreen> {
  int _sleepQuality = 5;
  int _hoursSlept = 6;
  int _fatigueLevel = 5;
  int _restBreaksNeeded = 2;
  String _wokeInNight = 'Sometimes';
  String _painDisturbed = 'Somewhat';
  final Set<String> _helped = {};
  final TextEditingController _notesCtrl = TextEditingController();

  final SleepFatigueRepository _repo = SleepFatigueRepository();
  bool _saving = false;

  static const Color _bg = Color(0xFF0D1020);
  static const Color _panel = Color(0xFF171A2E);
  static const Color _panel2 = Color(0xFF211C3A);
  static const Color _text = Color(0xFFF7F4FF);
  static const Color _muted = Color(0xFFB9AECF);
  static const Color _purple = Color(0xFF9B8FFF);
  static const Color _blue = Color(0xFF5DADEC);
  static const Color _teal = Color(0xFF46D6C8);
  static const Color _amber = Color(0xFFFFC857);

  static const List<String> _wokeOptions = ['No', 'Sometimes', 'Yes — often'];
  static const List<String> _painOptions = ['No', 'Somewhat', 'Yes — a lot'];

  static const List<String> _helpedOptions = [
    'Consistent bedtime',
    'No screens before bed',
    'Heat / warm bath',
    'Medication',
    'Calm environment',
    'Rest during the day',
    'Gentle movement',
    'Breathing / relaxation',
    'Dark and quiet room',
    'Good temperature',
    'Reduced stress',
    'Good meal timing',
  ];

  @override
  void initState() {
    super.initState();
    _loadTodayEntry();
  }

  @override
  void dispose() {
    _notesCtrl.dispose();
    super.dispose();
  }

  /// Deterministic per-day id — saving again today updates this entry
  /// instead of creating a duplicate.
  String get _todayId {
    final now = DateTime.now();
    final y = now.year.toString().padLeft(4, '0');
    final m = now.month.toString().padLeft(2, '0');
    final d = now.day.toString().padLeft(2, '0');
    return 'sleepfatigue_$y-$m-$d';
  }

  Future<void> _loadTodayEntry() async {
    final existing = await _repo.getEntryById(_todayId);
    if (existing == null || !mounted) return;
    setState(() {
      _sleepQuality = existing.sleepQuality;
      _hoursSlept = existing.hoursSlept;
      _fatigueLevel = existing.fatigueLevel;
      _restBreaksNeeded = existing.restBreaksNeeded;
      _wokeInNight = existing.wokeInNight;
      _painDisturbed = existing.painDisturbed;
      _helped
        ..clear()
        ..addAll(existing.helped);
      _notesCtrl.text = existing.notes;
    });
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    final entry = SleepFatigueEntry(
      id: _todayId,
      date: DateTime.now(),
      sleepQuality: _sleepQuality,
      hoursSlept: _hoursSlept,
      fatigueLevel: _fatigueLevel,
      restBreaksNeeded: _restBreaksNeeded,
      wokeInNight: _wokeInNight,
      painDisturbed: _painDisturbed,
      helped: _helped.toList(),
      notes: _notesCtrl.text.trim(),
    );
    final ok = await _repo.saveEntry(entry);
    if (!mounted) return;
    setState(() => _saving = false);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(ok
          ? "Today's entry saved"
          : 'Save failed — please try again'),
      backgroundColor:
          ok ? _teal.withValues(alpha: 0.9) : const Color(0xFFFF6FAE).withValues(alpha: 0.9),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      duration: const Duration(seconds: 3),
    ));
  }

  String get _summary {
    return '''
Nova Sleep / Fatigue Summary

Sleep quality: $_sleepQuality / 10
Hours slept: $_hoursSlept
Fatigue level today: $_fatigueLevel / 10
Rest breaks needed: $_restBreaksNeeded

Woke during night: $_wokeInNight
Pain disturbed sleep: $_painDisturbed

What helped sleep or rest:
${_helped.isEmpty ? 'Nothing selected.' : _helped.join(', ')}

Notes for patterns:
${_notesCtrl.text.trim().isEmpty ? 'No notes added yet.' : _notesCtrl.text.trim()}

Note:
This is a personal sleep and fatigue log. It does not diagnose sleep disorders or replace medical advice. Use it to spot your own patterns and prepare for appointments.
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
          'Sleep / Fatigue',
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
            title: 'SLEEP QUALITY',
            child: _sliderRow(
              label: 'How well did you sleep?',
              value: _sleepQuality,
              activeColor: _purple,
              onChanged: (v) => setState(() => _sleepQuality = v.round()),
            ),
          ),
          const SizedBox(height: 12),
          _section(
            title: 'HOURS SLEPT',
            child: _sliderRow(
              label: 'Approximate hours slept',
              value: _hoursSlept,
              min: 0,
              max: 12,
              activeColor: _blue,
              onChanged: (v) => setState(() => _hoursSlept = v.round()),
            ),
          ),
          const SizedBox(height: 12),
          _section(
            title: 'WOKE DURING NIGHT',
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _wokeOptions.map((option) {
                return _chip(
                  option,
                  _wokeInNight == option,
                  _purple,
                  () => setState(() => _wokeInNight = option),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 12),
          _section(
            title: 'PAIN DISTURBED SLEEP',
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _painOptions.map((option) {
                return _chip(
                  option,
                  _painDisturbed == option,
                  _amber,
                  () => setState(() => _painDisturbed = option),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 12),
          _section(
            title: 'FATIGUE LEVEL TODAY',
            child: _sliderRow(
              label: 'How fatigued do you feel?',
              value: _fatigueLevel,
              activeColor: _amber,
              onChanged: (v) => setState(() => _fatigueLevel = v.round()),
            ),
          ),
          const SizedBox(height: 12),
          _section(
            title: 'REST BREAKS NEEDED',
            child: _sliderRow(
              label: 'How many rest breaks did you need?',
              value: _restBreaksNeeded,
              min: 0,
              max: 10,
              activeColor: _teal,
              onChanged: (v) => setState(() => _restBreaksNeeded = v.round()),
            ),
          ),
          const SizedBox(height: 12),
          _section(
            title: 'WHAT HELPED SLEEP OR REST',
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
            title: 'NOTES FOR PATTERNS',
            child: TextField(
              controller: _notesCtrl,
              maxLines: 5,
              onChanged: (_) => setState(() {}),
              style: const TextStyle(color: _text),
              decoration: InputDecoration(
                hintText:
                    'What patterns do you notice? What affects your sleep most? '
                    'Any links to pain, stress, food, or activity?',
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
          const SizedBox(height: 16),
          _saveButton(),
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
          colors: [Color(0xFF2A1F5A), Color(0xFF171A2E)],
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
            'Nova Sleep / Fatigue',
            style: TextStyle(
                color: _text, fontSize: 28, fontWeight: FontWeight.w900),
          ),
          SizedBox(height: 8),
          Text(
            'Track sleep quality, fatigue, night waking, rest needs, and what helps. '
            'Use it to spot your own patterns and prepare for appointments.',
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
    int min = 0,
    int max = 10,
  }) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                label,
                style:
                    const TextStyle(color: _text, fontWeight: FontWeight.w700),
              ),
            ),
            Text(
              '$value',
              style:
                  TextStyle(color: activeColor, fontWeight: FontWeight.w900),
            ),
          ],
        ),
        Slider(
          value: value.toDouble(),
          min: min.toDouble(),
          max: max.toDouble(),
          divisions: max - min,
          activeColor: activeColor,
          inactiveColor: activeColor.withValues(alpha: 0.18),
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _chip(
      String label, bool selected, Color color, VoidCallback onTap) {
    return InkWell(
      borderRadius: BorderRadius.circular(30),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? color.withValues(alpha: 0.2) : _panel2,
          borderRadius: BorderRadius.circular(30),
          border:
              Border.all(color: selected ? color : color.withValues(alpha: 0.22)),
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

  Widget _saveButton() {
    return GestureDetector(
      onTap: _saving ? null : _save,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: _saving ? [_muted, _muted] : [_purple, _teal],
          ),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Center(
          child: _saving
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: Colors.white),
                )
              : const Text(
                  "Save today's entry",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
        ),
      ),
    );
  }

  Widget _safetyCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A3A),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _purple.withValues(alpha: 0.35)),
      ),
      child: const Text(
        'Nova Sleep / Fatigue is a personal log and pattern-spotting tool. '
        'It does not diagnose sleep disorders or replace medical advice. '
        'If sleep problems are severely affecting your health or safety, speak to your GP.',
        style: TextStyle(color: _text, height: 1.35, fontWeight: FontWeight.w600),
      ),
    );
  }
}
