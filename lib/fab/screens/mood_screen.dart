import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// mood index → (emoji, label)
const _kMoods = [
  ('😢', 'Awful'),
  ('😟', 'Sad'),
  ('😐', 'Okay'),
  ('😊', 'Good'),
  ('😄', 'Amazing'),
];

const _kFactors = [
  'School',
  'Friends',
  'Family',
  'Tired',
  'Poorly',
  'Excited',
  'Worried',
  "Don't know",
];

const _kPrefsKey = 'fab_mood_entries';

// Accent palette matching the hub sheet
const _kAccent = Color(0xFF6C63FF);

class MoodScreen extends StatefulWidget {
  const MoodScreen({super.key});

  @override
  State<MoodScreen> createState() => _MoodScreenState();
}

class _MoodScreenState extends State<MoodScreen> {
  int? _selectedMood;
  final Set<String> _selectedFactors = {};
  final _notesCtrl = TextEditingController();
  List<Map<String, dynamic>> _allEntries = [];

  @override
  void initState() {
    super.initState();
    _loadEntries();
  }

  @override
  void dispose() {
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadEntries() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kPrefsKey);
    if (raw == null) return;
    setState(() {
      _allEntries = (jsonDecode(raw) as List)
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList();
    });
  }

  Future<void> _saveEntry() async {
    if (_selectedMood == null) return;
    final entry = <String, dynamic>{
      'timestamp': DateTime.now().toIso8601String(),
      'mood': _selectedMood,
      'factors': _selectedFactors.toList(),
      'notes': _notesCtrl.text.trim(),
    };
    final updated = [..._allEntries, entry];
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kPrefsKey, jsonEncode(updated));
    setState(() {
      _allEntries = updated;
      _selectedMood = null;
      _selectedFactors.clear();
      _notesCtrl.clear();
    });
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Mood saved! 🌟'),
          backgroundColor: _kAccent,
        ),
      );
    }
  }

  List<Map<String, dynamic>> get _last7Days {
    final cutoff = DateTime.now().subtract(const Duration(days: 7));
    final recent = _allEntries
        .where((e) {
          final ts = DateTime.tryParse(e['timestamp'] as String? ?? '');
          return ts != null && ts.isAfter(cutoff);
        })
        .toList()
      ..sort((a, b) =>
          (a['timestamp'] as String).compareTo(b['timestamp'] as String));
    return recent.length > 7 ? recent.sublist(recent.length - 7) : recent;
  }

  @override
  Widget build(BuildContext context) {
    final last7 = _last7Days;
    return Scaffold(
      backgroundColor: const Color(0xFF0D0820),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1040),
        elevation: 0,
        title: const Text(
          'How are you feeling?',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w700,
            fontFamily: 'DM Sans',
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white70),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _MoodRow(
              selected: _selectedMood,
              onSelect: (i) => setState(() => _selectedMood = i),
            ),
            const SizedBox(height: 32),
            _sectionLabel("What's affecting your mood?"),
            const SizedBox(height: 12),
            _FactorChips(
              selected: _selectedFactors,
              onToggle: (f) => setState(() {
                _selectedFactors.contains(f)
                    ? _selectedFactors.remove(f)
                    : _selectedFactors.add(f);
              }),
            ),
            const SizedBox(height: 24),
            _sectionLabel('Anything else?'),
            const SizedBox(height: 8),
            _NotesField(controller: _notesCtrl),
            const SizedBox(height: 28),
            _SaveButton(
              enabled: _selectedMood != null,
              onPressed: _saveEntry,
            ),
            if (last7.isNotEmpty) ...[
              const SizedBox(height: 36),
              _sectionLabel('Your last 7 days'),
              const SizedBox(height: 12),
              _Last7DaysRow(entries: last7),
            ],
          ],
        ),
      ),
    );
  }

  Widget _sectionLabel(String text) => Text(
        text,
        style: const TextStyle(
          color: Colors.white70,
          fontSize: 14,
          fontWeight: FontWeight.w600,
          fontFamily: 'DM Sans',
        ),
      );
}

// ─── Sub-widgets ─────────────────────────────────────────────────────────────

class _MoodRow extends StatelessWidget {
  const _MoodRow({required this.selected, required this.onSelect});

  final int? selected;
  final ValueChanged<int> onSelect;

  // per-mood glow colours
  static const _glows = [
    Color(0xFF5DADEC), // Awful — blue
    Color(0xFFFF8FAB), // Sad — pink
    Color(0xFFC9A0C9), // Okay — muted purple
    Color(0xFF00C9A7), // Good — teal
    Color(0xFFFFD700), // Amazing — gold
  ];

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(_kMoods.length, (i) {
        final (emoji, label) = _kMoods[i];
        final isSelected = selected == i;
        return GestureDetector(
          onTap: () => onSelect(i),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isSelected
                  ? _glows[i].withValues(alpha: 0.18)
                  : Colors.transparent,
              border: Border.all(
                color: isSelected ? _glows[i] : Colors.white12,
                width: isSelected ? 2.5 : 1,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: _glows[i].withValues(alpha: 0.50),
                        blurRadius: 18,
                        spreadRadius: 2,
                      ),
                    ]
                  : [],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(emoji,
                    style: TextStyle(fontSize: isSelected ? 48 : 40)),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 10,
                    fontFamily: 'DM Sans',
                    fontWeight: isSelected
                        ? FontWeight.w700
                        : FontWeight.normal,
                    color:
                        isSelected ? _glows[i] : Colors.white38,
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}

class _FactorChips extends StatelessWidget {
  const _FactorChips({required this.selected, required this.onToggle});

  final Set<String> selected;
  final ValueChanged<String> onToggle;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _kFactors.map((f) {
        final isOn = selected.contains(f);
        return FilterChip(
          label: Text(f),
          selected: isOn,
          onSelected: (_) => onToggle(f),
          backgroundColor: const Color(0xFF1A1040),
          selectedColor: _kAccent.withValues(alpha: 0.22),
          labelStyle: TextStyle(
            color: isOn ? Colors.white : Colors.white70,
            fontWeight: isOn ? FontWeight.w600 : FontWeight.normal,
            fontSize: 12,
            fontFamily: 'DM Sans',
          ),
          checkmarkColor: Colors.white,
          side: BorderSide(
            color: isOn
                ? _kAccent.withValues(alpha: 0.80)
                : Colors.white12,
          ),
          padding:
              const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        );
      }).toList(),
    );
  }
}

class _NotesField extends StatelessWidget {
  const _NotesField({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLines: 3,
      style: const TextStyle(
          color: Colors.white, fontSize: 14, fontFamily: 'DM Sans'),
      decoration: InputDecoration(
        hintText: 'Write how you feel...',
        hintStyle: const TextStyle(
            color: Colors.white38, fontSize: 14, fontFamily: 'DM Sans'),
        filled: true,
        fillColor: const Color(0xFF1A1040),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide:
              const BorderSide(color: _kAccent, width: 1.5),
        ),
      ),
    );
  }
}

class _SaveButton extends StatelessWidget {
  const _SaveButton({required this.enabled, required this.onPressed});

  final bool enabled;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: AnimatedOpacity(
        opacity: enabled ? 1.0 : 0.40,
        duration: const Duration(milliseconds: 200),
        child: ElevatedButton(
          onPressed: enabled ? onPressed : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: _kAccent,
            foregroundColor: Colors.white,
            disabledBackgroundColor: _kAccent,
            disabledForegroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(26),
            ),
            elevation: enabled ? 4 : 0,
          ),
          child: const Text(
            'Save my mood 🌟',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              fontFamily: 'DM Sans',
            ),
          ),
        ),
      ),
    );
  }
}

class _Last7DaysRow extends StatelessWidget {
  const _Last7DaysRow({required this.entries});

  final List<Map<String, dynamic>> entries;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 8,
      children: entries.map((e) {
        final idx =
            ((e['mood'] as num?)?.toInt() ?? 2).clamp(0, 4);
        final ts =
            DateTime.tryParse(e['timestamp'] as String? ?? '');
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _kMoods[idx].$1,
              style: const TextStyle(fontSize: 28),
            ),
            if (ts != null)
              Text(
                '${ts.day}/${ts.month}',
                style: const TextStyle(
                  color: Colors.white38,
                  fontSize: 10,
                  fontFamily: 'DM Sans',
                ),
              ),
          ],
        );
      }).toList(),
    );
  }
}
