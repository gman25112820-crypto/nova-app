import 'package:flutter/material.dart';
import '../../core/models/check_in_entry.dart';
import '../../core/repositories/check_in_repository.dart';

// ─────────────────────────────────────────────────────────────
// SCIATICA & BACK PAIN SCREEN
// Logs nerve-specific symptoms to CheckInRepository.
// Fields: nerve selector, radiation pattern, symptom types,
//         severity slider, posture triggers, free-text notes.
// Saves as CheckInEntry with id prefix 'sciatica_'.
// ─────────────────────────────────────────────────────────────

class SciaticaScreen extends StatefulWidget {
  const SciaticaScreen({super.key});

  @override
  State<SciaticaScreen> createState() => _SciaticaScreenState();
}

class _SciaticaScreenState extends State<SciaticaScreen> {
  final _repo = CheckInRepository();
  final _notesCtrl = TextEditingController();
  bool _saving = false;
  bool _saved = false;

  // ── Colours ──────────────────────────────────────────────────
  static const _bg      = Color(0xFF090C18);
  static const _panel   = Color(0xFF111426);
  static const _border  = Color(0xFF1E2240);
  static const _text    = Color(0xFFF2EFFF);
  static const _muted   = Color(0xFF8A8EAB);
  static const _blue    = Color(0xFF5DADEC);
  static const _purple  = Color(0xFF9B7DFF);
  static const _coral   = Color(0xFFFF6B6B);

  // ── Nerve selections ─────────────────────────────────────────
  static const _nerves = [
    'Sciatic nerve',
    'Lumbar',
    'Sacral',
    'Femoral',
  ];
  final Set<String> _selNerves = {};

  // ── Radiation pattern ────────────────────────────────────────
  static const _radiation = [
    'Buttock',
    'Back of leg',
    'Front of leg',
    'Foot',
    'Toes',
  ];
  final Set<String> _selRadiation = {};

  // ── Symptom types ─────────────────────────────────────────────
  static const _symptomTypes = [
    'Shooting pain',
    'Burning',
    'Numbness',
    'Tingling',
    'Weakness',
    'Pins and needles',
  ];
  final Set<String> _selSymptoms = {};

  // ── Severity ─────────────────────────────────────────────────
  double _severity = 5;

  // ── Posture triggers ─────────────────────────────────────────
  static const _postureTriggers = [
    'Sitting',
    'Standing',
    'Walking',
    'Lying down',
    'Bending',
  ];
  final Set<String> _selTriggers = {};

  @override
  void dispose() {
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    final now = DateTime.now();
    final ts  = now.millisecondsSinceEpoch;

    final locations = [
      ..._selNerves,
      ..._selRadiation,
    ];

    await _repo.saveEntry(CheckInEntry(
      id:                 'sciatica_$ts',
      date:               DateTime(now.year, now.month, now.day),
      painRating:         _severity.round(),
      nerveSymptomRating: _severity.round(),
      painLocations:      locations,
      symptoms:           _selSymptoms.toList(),
      triggers:           _selTriggers.toList(),
      notes:              _notesCtrl.text.trim(),
    ));

    setState(() { _saving = false; _saved = true; });
  }

  // ── Build ─────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 18),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Sciatica & Back Pain',
          style: TextStyle(color: _text, fontSize: 17, fontWeight: FontWeight.w700),
        ),
      ),
      body: _saved ? _buildSavedState() : _buildForm(),
    );
  }

  Widget _buildForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader('🧠', 'Which nerve area?'),
          _chipGrid(_nerves, _selNerves, _blue),

          const SizedBox(height: 24),
          _sectionHeader('📍', 'Where does the pain travel?'),
          _chipGrid(_radiation, _selRadiation, _purple),

          const SizedBox(height: 24),
          _sectionHeader('⚡', 'Symptom type'),
          _chipGrid(_symptomTypes, _selSymptoms, _coral),

          const SizedBox(height: 28),
          _sectionHeader('📊', 'Severity'),
          const SizedBox(height: 4),
          _buildSeveritySlider(),

          const SizedBox(height: 28),
          _sectionHeader('🪑', 'Posture triggers'),
          _chipGrid(_postureTriggers, _selTriggers, _blue),

          const SizedBox(height: 28),
          _sectionHeader('📝', 'Notes'),
          const SizedBox(height: 10),
          _buildNotesField(),

          const SizedBox(height: 36),
          _buildSaveButton(),
        ],
      ),
    );
  }

  Widget _sectionHeader(String emoji, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 18)),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              color: _text,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _chipGrid(
    List<String> options,
    Set<String> selected,
    Color activeColor,
  ) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: options.map((opt) {
        final on = selected.contains(opt);
        return GestureDetector(
          onTap: () => setState(() {
            if (on) { selected.remove(opt); } else { selected.add(opt); }
          }),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
            decoration: BoxDecoration(
              color: on
                  ? activeColor.withValues(alpha: 0.18)
                  : _panel,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: on ? activeColor : _border,
                width: on ? 1.5 : 1,
              ),
            ),
            child: Text(
              opt,
              style: TextStyle(
                color: on ? activeColor : _muted,
                fontSize: 13,
                fontWeight: on ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSeveritySlider() {
    final sev = _severity.round();
    final Color sevColor = sev <= 3
        ? const Color(0xFF4CAF50)
        : sev <= 6
            ? const Color(0xFFFFB830)
            : _coral;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
      decoration: BoxDecoration(
        color: _panel,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _border),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('None', style: TextStyle(color: _muted, fontSize: 12)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: sevColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: sevColor.withValues(alpha: 0.40)),
                ),
                child: Text(
                  '$sev / 10',
                  style: TextStyle(
                    color: sevColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const Text('Severe', style: TextStyle(color: _muted, fontSize: 12)),
            ],
          ),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: sevColor,
              inactiveTrackColor: _border,
              thumbColor: sevColor,
              overlayColor: sevColor.withValues(alpha: 0.15),
              trackHeight: 4,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
            ),
            child: Slider(
              value: _severity,
              min: 0,
              max: 10,
              divisions: 10,
              onChanged: (v) => setState(() => _severity = v),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(11, (i) {
              return Text(
                '$i',
                style: TextStyle(
                  color: i == sev ? sevColor : _muted.withValues(alpha: 0.40),
                  fontSize: 10,
                  fontWeight: i == sev ? FontWeight.w700 : FontWeight.normal,
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildNotesField() {
    return Container(
      decoration: BoxDecoration(
        color: _panel,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _border),
      ),
      child: TextField(
        controller: _notesCtrl,
        style: const TextStyle(color: _text, fontSize: 15),
        maxLines: 4,
        decoration: InputDecoration(
          hintText: 'Describe how it feels, when it started, anything else…',
          hintStyle: TextStyle(
            color: _muted.withValues(alpha: 0.55),
            fontSize: 14,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(16),
        ),
      ),
    );
  }

  Widget _buildSaveButton() {
    final hasData = _selNerves.isNotEmpty ||
        _selRadiation.isNotEmpty ||
        _selSymptoms.isNotEmpty ||
        _selTriggers.isNotEmpty;

    return GestureDetector(
      onTap: (hasData && !_saving) ? _save : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          gradient: hasData
              ? const LinearGradient(
                  colors: [Color(0xFF5DADEC), Color(0xFF9B7DFF)],
                )
              : null,
          color: hasData ? null : _panel,
          borderRadius: BorderRadius.circular(16),
          border: hasData ? null : Border.all(color: _border),
        ),
        child: Center(
          child: _saving
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: Colors.white,
                  ),
                )
              : Text(
                  'Save Entry',
                  style: TextStyle(
                    color: hasData ? Colors.white : _muted,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildSavedState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _blue.withValues(alpha: 0.15),
                border: Border.all(color: _blue.withValues(alpha: 0.40), width: 2),
              ),
              child: const Icon(Icons.check_rounded, color: _blue, size: 40),
            ),
            const SizedBox(height: 24),
            const Text(
              'Entry saved',
              style: TextStyle(
                color: _text,
                fontSize: 22,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Your sciatica log has been saved.\nIt will appear in Insights and Clinician Export.',
              textAlign: TextAlign.center,
              style: TextStyle(color: _muted, fontSize: 14, height: 1.6),
            ),
            const SizedBox(height: 40),
            GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 14),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF5DADEC), Color(0xFF9B7DFF)],
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Text(
                  'Done',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: () => setState(() {
                _saved = false;
                _selNerves.clear();
                _selRadiation.clear();
                _selSymptoms.clear();
                _selTriggers.clear();
                _severity = 5;
                _notesCtrl.clear();
              }),
              child: Text(
                'Log another',
                style: TextStyle(
                  color: _muted.withValues(alpha: 0.70),
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
