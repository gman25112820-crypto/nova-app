import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ─────────────────────────────────────────────────────────────
// NOVA HEALTH PROFILE SCREEN
// Persists to SharedPreferences under 'nova_health_profile'.
// Personal record only — stays on device, never transmitted.
// ─────────────────────────────────────────────────────────────

class HealthProfileScreen extends StatefulWidget {
  const HealthProfileScreen({super.key});

  @override
  State<HealthProfileScreen> createState() => _HealthProfileScreenState();
}

class _HealthProfileScreenState extends State<HealthProfileScreen> {
  static const _prefsKey = 'nova_health_profile';

  // ── Text controllers ─────────────────────────────────────
  final _nameCtrl       = TextEditingController();
  final _dobCtrl        = TextEditingController();
  final _pronounsCtrl   = TextEditingController();
  final _gpNameCtrl     = TextEditingController();
  final _gpPracticeCtrl = TextEditingController();
  final _gpPhoneCtrl    = TextEditingController();
  final _specNameCtrl   = TextEditingController();
  final _specRoleCtrl   = TextEditingController();
  final _emergencyNameCtrl  = TextEditingController();
  final _emergencyPhoneCtrl = TextEditingController();
  final _notesCtrl      = TextEditingController();

  // ── Multi-value state ────────────────────────────────────
  final Set<String>  _conditions      = {};
  final List<String> _medications     = [];
  final List<String> _customConditions = [];
  final Set<String>  _allergies       = {};
  final List<String> _customAllergies = [];
  final Set<String>  _accessNeeds     = {};
  final List<String> _customAccess    = [];

  bool _loading = true;
  bool _saving  = false;
  bool _saved   = false;

  // ── Palette ──────────────────────────────────────────────
  static const _bg     = Color(0xFF0D1020);
  static const _panel  = Color(0xFF171A2E);
  static const _panel2 = Color(0xFF211C3A);
  static const _border = Color(0xFF252845);
  static const _text   = Color(0xFFF7F4FF);
  static const _muted  = Color(0xFFB9AECF);
  static const _blue   = Color(0xFF5DADEC);
  static const _purple = Color(0xFF8D6CFF);
  static const _teal   = Color(0xFF46D6C8);
  static const _amber  = Color(0xFFFFC857);
  static const _rose   = Color(0xFFFF6FAE);

  // ── Preset option lists ──────────────────────────────────
  static const _conditionPresets = [
    'Chronic back pain', 'Sciatica', 'Fibromyalgia',
    'ME / Chronic fatigue', 'Hypermobility / EDS',
    'POTS / Dysautonomia', 'Arthritis', 'Osteoporosis',
    'Crohn\'s disease', 'IBS / IBD', 'Coeliac disease',
    'Endometriosis', 'PCOS', 'Diabetes (Type 1)', 'Diabetes (Type 2)',
    'Asthma', 'Lupus', 'MS', 'Epilepsy', 'Migraine',
    'ADHD', 'Autism', 'Dyspraxia', 'Anxiety', 'Depression',
    'PTSD', 'PMDD', 'Raynaud\'s', 'Scoliosis',
  ];

  static const _allergyPresets = [
    'Penicillin', 'Amoxicillin', 'Aspirin', 'Ibuprofen / NSAIDs',
    'Codeine', 'Morphine', 'Sulfonamides', 'Contrast dye',
    'Latex', 'Peanuts', 'Tree nuts', 'Dairy / Lactose',
    'Gluten / Wheat', 'Eggs', 'Shellfish', 'Soya', 'Sesame',
  ];

  static const _accessPresets = [
    'Wheelchair user', 'Walking aid', 'Step-free access needed',
    'Hearing loop needed', 'British Sign Language (BSL)',
    'Screen reader / visual impairment', 'Large print',
    'Processing time needed', 'Written instructions preferred',
    'Quiet / low-stimulation environment', 'Rest breaks needed',
    'Carer / support person accompanying', 'Communication aid',
    'Adjustable seating needed', 'Pain flare protocol',
    'Flexible / remote options needed',
  ];

  // ── Lifecycle ────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _dobCtrl.dispose();
    _pronounsCtrl.dispose();
    _gpNameCtrl.dispose();
    _gpPracticeCtrl.dispose();
    _gpPhoneCtrl.dispose();
    _specNameCtrl.dispose();
    _specRoleCtrl.dispose();
    _emergencyNameCtrl.dispose();
    _emergencyPhoneCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  // ── Persistence ──────────────────────────────────────────

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_prefsKey);
    if (raw != null) {
      try {
        final d = jsonDecode(raw) as Map<String, dynamic>;
        _nameCtrl.text       = (d['name']        as String?) ?? '';
        _dobCtrl.text        = (d['dob']         as String?) ?? '';
        _pronounsCtrl.text   = (d['pronouns']    as String?) ?? '';
        _gpNameCtrl.text     = (d['gpName']      as String?) ?? '';
        _gpPracticeCtrl.text = (d['gpPractice']  as String?) ?? '';
        _gpPhoneCtrl.text    = (d['gpPhone']     as String?) ?? '';
        _specNameCtrl.text   = (d['specName']    as String?) ?? '';
        _specRoleCtrl.text   = (d['specRole']    as String?) ?? '';
        _emergencyNameCtrl.text  = (d['emergencyName']  as String?) ?? '';
        _emergencyPhoneCtrl.text = (d['emergencyPhone'] as String?) ?? '';
        _notesCtrl.text      = (d['notes']       as String?) ?? '';

        _conditions.addAll(
            List<String>.from((d['conditions'] as List?) ?? []));
        _medications.addAll(
            List<String>.from((d['medications'] as List?) ?? []));
        _customConditions.addAll(
            List<String>.from((d['customConditions'] as List?) ?? []));
        _allergies.addAll(
            List<String>.from((d['allergies'] as List?) ?? []));
        _customAllergies.addAll(
            List<String>.from((d['customAllergies'] as List?) ?? []));
        _accessNeeds.addAll(
            List<String>.from((d['accessNeeds'] as List?) ?? []));
        _customAccess.addAll(
            List<String>.from((d['customAccess'] as List?) ?? []));
      } catch (_) {/* corrupt prefs — start fresh */}
    }
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _prefsKey,
      jsonEncode({
        'name':             _nameCtrl.text.trim(),
        'dob':              _dobCtrl.text.trim(),
        'pronouns':         _pronounsCtrl.text.trim(),
        'gpName':           _gpNameCtrl.text.trim(),
        'gpPractice':       _gpPracticeCtrl.text.trim(),
        'gpPhone':          _gpPhoneCtrl.text.trim(),
        'specName':         _specNameCtrl.text.trim(),
        'specRole':         _specRoleCtrl.text.trim(),
        'emergencyName':    _emergencyNameCtrl.text.trim(),
        'emergencyPhone':   _emergencyPhoneCtrl.text.trim(),
        'notes':            _notesCtrl.text.trim(),
        'conditions':       _conditions.toList(),
        'medications':      _medications,
        'customConditions': _customConditions,
        'allergies':        _allergies.toList(),
        'customAllergies':  _customAllergies,
        'accessNeeds':      _accessNeeds.toList(),
        'customAccess':     _customAccess,
      }),
    );
    if (!mounted) return;
    setState(() {
      _saving = false;
      _saved  = true;
    });
    Future.delayed(const Duration(seconds: 2),
        () { if (mounted) setState(() => _saved = false); });
  }

  String get _summaryText {
    final buf = StringBuffer();
    buf.writeln('Nova Health Profile');
    buf.writeln('─' * 40);
    if (_nameCtrl.text.trim().isNotEmpty)
      buf.writeln('Name: ${_nameCtrl.text.trim()}');
    if (_dobCtrl.text.trim().isNotEmpty)
      buf.writeln('Date of birth: ${_dobCtrl.text.trim()}');
    if (_pronounsCtrl.text.trim().isNotEmpty)
      buf.writeln('Pronouns: ${_pronounsCtrl.text.trim()}');
    buf.writeln();
    final allConditions = {..._conditions, ..._customConditions};
    buf.writeln('Conditions / diagnoses:');
    buf.writeln(allConditions.isEmpty ? 'None recorded.' : allConditions.join(', '));
    buf.writeln();
    buf.writeln('Current medications:');
    buf.writeln(_medications.isEmpty ? 'None recorded.' : _medications.join('\n'));
    buf.writeln();
    final allAllergies = {..._allergies, ..._customAllergies};
    buf.writeln('Allergies / sensitivities:');
    buf.writeln(allAllergies.isEmpty ? 'None recorded.' : allAllergies.join(', '));
    buf.writeln();
    buf.writeln('GP / medical team:');
    if (_gpNameCtrl.text.trim().isNotEmpty)
      buf.writeln('  GP: ${_gpNameCtrl.text.trim()}');
    if (_gpPracticeCtrl.text.trim().isNotEmpty)
      buf.writeln('  Practice: ${_gpPracticeCtrl.text.trim()}');
    if (_gpPhoneCtrl.text.trim().isNotEmpty)
      buf.writeln('  Phone: ${_gpPhoneCtrl.text.trim()}');
    if (_specNameCtrl.text.trim().isNotEmpty)
      buf.writeln('  Specialist: ${_specNameCtrl.text.trim()}'
          '${_specRoleCtrl.text.trim().isNotEmpty ? " (${_specRoleCtrl.text.trim()})" : ""}');
    buf.writeln();
    if (_emergencyNameCtrl.text.trim().isNotEmpty) {
      buf.writeln('Emergency contact:');
      buf.writeln('  ${_emergencyNameCtrl.text.trim()}'
          '${_emergencyPhoneCtrl.text.trim().isNotEmpty ? " — ${_emergencyPhoneCtrl.text.trim()}" : ""}');
      buf.writeln();
    }
    final allAccess = {..._accessNeeds, ..._customAccess};
    if (allAccess.isNotEmpty) {
      buf.writeln('Accessibility / adjustments needed:');
      buf.writeln(allAccess.join(', '));
      buf.writeln();
    }
    if (_notesCtrl.text.trim().isNotEmpty) {
      buf.writeln('Profile notes:');
      buf.writeln(_notesCtrl.text.trim());
      buf.writeln();
    }
    buf.writeln('─' * 40);
    buf.writeln('Personal record — not a clinical document. '
        'Data stored locally on device only.');
    return buf.toString();
  }

  // ── Build ────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        foregroundColor: _text,
        elevation: 0,
        title: const Text(
          'Health Profile',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        actions: [
          // Copy summary
          IconButton(
            icon: const Icon(Icons.copy_rounded, size: 20),
            color: _muted,
            tooltip: 'Copy summary',
            onPressed: () {
              Clipboard.setData(ClipboardData(text: _summaryText));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Profile summary copied to clipboard'),
                  backgroundColor: _panel2,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
              );
            },
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: _blue))
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
              children: [
                _purposeNote(),
                const SizedBox(height: 20),
                _section(
                  title: 'PERSONAL DETAILS',
                  color: _blue,
                  child: Column(children: [
                    _textField('Preferred name', _nameCtrl,
                        'What you like to be called'),
                    const SizedBox(height: 10),
                    _textField('Date of birth', _dobCtrl,
                        'e.g. 12 March 1985 (optional)'),
                    const SizedBox(height: 10),
                    _textField('Pronouns', _pronounsCtrl,
                        'e.g. she/her, he/him, they/them'),
                  ]),
                ),
                const SizedBox(height: 12),
                _section(
                  title: 'CONDITIONS & DIAGNOSES',
                  color: _purple,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Tap to select. Add your own below.',
                        style: TextStyle(color: _muted, fontSize: 12),
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          ..._conditionPresets.map((c) => _chip(
                                c, _conditions.contains(c), _purple,
                                () => setState(() {
                                  if (_conditions.contains(c)) {
                                    _conditions.remove(c);
                                  } else {
                                    _conditions.add(c);
                                  }
                                }),
                              )),
                          ..._customConditions.map((c) => _chip(
                                c, true, _purple,
                                () => setState(
                                    () => _customConditions.remove(c)),
                                removable: true,
                              )),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _addItemRow(
                        hint: 'Add a condition not listed…',
                        color: _purple,
                        onAdd: (val) =>
                            setState(() => _customConditions.add(val)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                _section(
                  title: 'CURRENT MEDICATIONS',
                  color: _rose,
                  child: Column(
                    children: [
                      if (_medications.isEmpty)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Text(
                            'No medications added yet.',
                            style: TextStyle(
                                color: _muted.withValues(alpha: 0.7),
                                fontSize: 13),
                          ),
                        )
                      else
                        ..._medications.asMap().entries.map((e) =>
                            _medicationRow(e.value, e.key)),
                      const SizedBox(height: 4),
                      _addItemRow(
                        hint: 'Add medication (name + dose)…',
                        color: _rose,
                        onAdd: (val) =>
                            setState(() => _medications.add(val)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                _section(
                  title: 'ALLERGIES & SENSITIVITIES',
                  color: _amber,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Select known allergies or intolerances.',
                        style: TextStyle(color: _muted, fontSize: 12),
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          ..._allergyPresets.map((a) => _chip(
                                a, _allergies.contains(a), _amber,
                                () => setState(() {
                                  if (_allergies.contains(a)) {
                                    _allergies.remove(a);
                                  } else {
                                    _allergies.add(a);
                                  }
                                }),
                              )),
                          ..._customAllergies.map((a) => _chip(
                                a, true, _amber,
                                () => setState(
                                    () => _customAllergies.remove(a)),
                                removable: true,
                              )),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _addItemRow(
                        hint: 'Add an allergy not listed…',
                        color: _amber,
                        onAdd: (val) =>
                            setState(() => _customAllergies.add(val)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                _section(
                  title: 'GP & MEDICAL TEAM',
                  color: _teal,
                  child: Column(children: [
                    _textField('GP name', _gpNameCtrl, 'Dr …'),
                    const SizedBox(height: 10),
                    _textField('Practice / surgery', _gpPracticeCtrl,
                        'Surgery name'),
                    const SizedBox(height: 10),
                    _textField('Practice phone', _gpPhoneCtrl,
                        'Contact number'),
                    const SizedBox(height: 14),
                    _divider(),
                    const SizedBox(height: 14),
                    _textField('Specialist name', _specNameCtrl,
                        'Consultant / physio / specialist'),
                    const SizedBox(height: 10),
                    _textField('Specialist role', _specRoleCtrl,
                        'e.g. Rheumatologist, Pain clinic'),
                  ]),
                ),
                const SizedBox(height: 12),
                _section(
                  title: 'EMERGENCY CONTACT',
                  color: _rose,
                  child: Column(children: [
                    _textField('Contact name', _emergencyNameCtrl,
                        'Name of emergency contact'),
                    const SizedBox(height: 10),
                    _textField('Phone number', _emergencyPhoneCtrl,
                        'Mobile or home number'),
                  ]),
                ),
                const SizedBox(height: 12),
                _section(
                  title: 'ACCESSIBILITY & ADJUSTMENTS',
                  color: _blue,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Adjustments you need in healthcare or daily settings.',
                        style: TextStyle(color: _muted, fontSize: 12),
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          ..._accessPresets.map((a) => _chip(
                                a, _accessNeeds.contains(a), _blue,
                                () => setState(() {
                                  if (_accessNeeds.contains(a)) {
                                    _accessNeeds.remove(a);
                                  } else {
                                    _accessNeeds.add(a);
                                  }
                                }),
                              )),
                          ..._customAccess.map((a) => _chip(
                                a, true, _blue,
                                () => setState(
                                    () => _customAccess.remove(a)),
                                removable: true,
                              )),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _addItemRow(
                        hint: 'Add an adjustment not listed…',
                        color: _blue,
                        onAdd: (val) =>
                            setState(() => _customAccess.add(val)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                _section(
                  title: 'PROFILE NOTES',
                  color: _muted,
                  child: _textField(
                    'Notes',
                    _notesCtrl,
                    'Anything else important to your health record…',
                    maxLines: 5,
                  ),
                ),
                const SizedBox(height: 24),
                _saveButton(),
                const SizedBox(height: 16),
                _privacyNote(),
              ],
            ),
    );
  }

  // ── Widgets ──────────────────────────────────────────────

  Widget _purposeNote() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _blue.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _blue.withValues(alpha: 0.20)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.person_outline_rounded, color: _blue, size: 18),
          const SizedBox(width: 10),
          const Expanded(
            child: Text(
              'Your personal health record. Use it to keep key information '
              'in one place — for yourself, for appointments, or to share '
              'a printed summary with your care team. Stored only on this device.',
              style: TextStyle(color: _muted, fontSize: 13, height: 1.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _section({
    required String title,
    required Color color,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _panel,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.22)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Container(
              width: 3,
              height: 14,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                color: color,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.1,
              ),
            ),
          ]),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }

  Widget _textField(
    String label,
    TextEditingController ctrl,
    String hint, {
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
              color: _muted, fontSize: 12, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: ctrl,
          maxLines: maxLines,
          style: const TextStyle(color: _text, fontSize: 14),
          cursorColor: _blue,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
                color: _muted.withValues(alpha: 0.5), fontSize: 13),
            filled: true,
            fillColor: _panel2,
            contentPadding: const EdgeInsets.symmetric(
                horizontal: 14, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: _border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: _border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: _blue.withValues(alpha: 0.6)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _chip(
    String label,
    bool selected,
    Color color,
    VoidCallback onTap, {
    bool removable = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        padding: EdgeInsets.fromLTRB(
            10, 6, removable ? 4 : 10, 6),
        decoration: BoxDecoration(
          color: selected
              ? color.withValues(alpha: 0.18)
              : _panel2,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected
                ? color.withValues(alpha: 0.55)
                : _border,
            width: selected ? 1.2 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                color: selected ? color : _muted,
                fontSize: 12.5,
                fontWeight:
                    selected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
            if (removable) ...[
              const SizedBox(width: 2),
              Icon(Icons.close_rounded, size: 14, color: color),
            ],
          ],
        ),
      ),
    );
  }

  Widget _addItemRow({
    required String hint,
    required Color color,
    required ValueChanged<String> onAdd,
  }) {
    final ctrl = TextEditingController();
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: ctrl,
            style: const TextStyle(color: _text, fontSize: 13),
            cursorColor: color,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(
                  color: _muted.withValues(alpha: 0.45), fontSize: 12.5),
              filled: true,
              fillColor: _panel2,
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12, vertical: 10),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: _border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: _border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide:
                    BorderSide(color: color.withValues(alpha: 0.5)),
              ),
            ),
            onSubmitted: (v) {
              final trimmed = v.trim();
              if (trimmed.isNotEmpty) {
                onAdd(trimmed);
                ctrl.clear();
              }
            },
          ),
        ),
        const SizedBox(width: 8),
        GestureDetector(
          onTap: () {
            final trimmed = ctrl.text.trim();
            if (trimmed.isNotEmpty) {
              onAdd(trimmed);
              ctrl.clear();
            }
          },
          child: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: color.withValues(alpha: 0.35)),
            ),
            child: Icon(Icons.add_rounded, color: color, size: 20),
          ),
        ),
      ],
    );
  }

  Widget _medicationRow(String med, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.fromLTRB(12, 10, 8, 10),
      decoration: BoxDecoration(
        color: _panel2,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _border),
      ),
      child: Row(
        children: [
          Icon(Icons.medication_rounded,
              color: _rose.withValues(alpha: 0.7), size: 16),
          const SizedBox(width: 10),
          Expanded(
            child: Text(med,
                style:
                    const TextStyle(color: _text, fontSize: 13.5)),
          ),
          GestureDetector(
            onTap: () =>
                setState(() => _medications.removeAt(index)),
            child: Icon(Icons.remove_circle_outline_rounded,
                color: _muted.withValues(alpha: 0.5), size: 18),
          ),
        ],
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
            colors: _saved
                ? [_teal, const Color(0xFF2AA98C)]
                : [_blue, const Color(0xFF3A8FD4)],
          ),
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: (_saved ? _teal : _blue).withValues(alpha: 0.22),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _saved
                  ? Icons.check_circle_rounded
                  : Icons.save_rounded,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 10),
            Text(
              _saving ? 'Saving…' : _saved ? 'Saved' : 'Save Profile',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _privacyNote() {
    return Row(
      children: [
        Icon(Icons.lock_outline_rounded,
            color: _muted.withValues(alpha: 0.45), size: 13),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            'Personal record only. Not a clinical document. '
            'Stored on this device — nothing is uploaded or shared.',
            style: TextStyle(
                color: _muted.withValues(alpha: 0.55),
                fontSize: 11.5,
                height: 1.4),
          ),
        ),
      ],
    );
  }

  Widget _divider() => Container(
        height: 1,
        color: _border,
      );
}
