import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/selected_child_service.dart';

// ─────────────────────────────────────────────────────────────
// ENERGY SCREEN — Fabulously Me
// Battery-style 5-level energy selector, drainer chips, notes.
// Key: energy_entries
// ─────────────────────────────────────────────────────────────

class EnergyEntry {
  final String id;
  final DateTime date;
  final int level; // 1–5
  final List<String> drainers;
  final String notes;

  EnergyEntry({
    required this.id,
    required this.date,
    required this.level,
    required this.drainers,
    required this.notes,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'date': date.toIso8601String().substring(0, 10),
        'level': level,
        'drainers': drainers,
        'notes': notes,
      };

  factory EnergyEntry.fromJson(Map<String, dynamic> j) => EnergyEntry(
        id: j['id'] as String,
        date: DateTime.parse(j['date'] as String),
        level: (j['level'] as num).toInt(),
        drainers: List<String>.from((j['drainers'] as List?) ?? []),
        notes: j['notes'] as String? ?? '',
      );
}

class EnergyScreen extends StatefulWidget {
  const EnergyScreen({super.key});

  @override
  State<EnergyScreen> createState() => _EnergyScreenState();
}

class _EnergyScreenState extends State<EnergyScreen> {
  // ── Form state ───────────────────────────────────────────
  int _level = 0; // 0 = not set
  final Set<String> _selectedDrainers = {};
  final _notesCtrl = TextEditingController();
  bool _saved = false;

  // ── History ──────────────────────────────────────────────
  List<EnergyEntry> _entries = [];

  // ── Constants ────────────────────────────────────────────
  static const _levelLabels = [
    'Empty',
    'Low',
    'Half',
    'Good',
    'Full',
  ];

  static const _levelColors = [
    Color(0xFFFF1744), // Empty  — red
    Color(0xFFFF7043), // Low    — orange
    Color(0xFFFFB830), // Half   — amber
    Color(0xFF8BC34A), // Good   — light green
    Color(0xFF4CAF50), // Full   — green
  ];

  static const _levelEmojis = ['😴', '🥱', '😐', '😊', '⚡'];

  static const _drainerOptions = [
    'School',
    'PE',
    'Poor sleep',
    'Pain',
    'Worry',
    'Lots of activity',
    "Don't know",
  ];

  static const _bgDark  = Color(0xFF0D0820);
  static const _cardBg  = Color(0xFF1A1040);
  static const _purple  = Color(0xFF6C63FF);
  static const _teal    = Color(0xFF00C9A7);

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

  // ── Persistence ──────────────────────────────────────────
  Future<void> _loadEntries() async {
    final child = SelectedChildService.current ?? SelectedChildService.selectDefault();
    final prefsKey = '${child?.id ?? ''}_energy_entries';
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(prefsKey) ?? [];
    if (!mounted) return;
    setState(() {
      _entries = raw
          .map((s) => EnergyEntry.fromJson(
              jsonDecode(s) as Map<String, dynamic>))
          .toList()
        ..sort((a, b) => b.date.compareTo(a.date));
    });
  }

  Future<void> _saveEntry() async {
    if (_level == 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Tap a battery segment to set your energy first!'),
        backgroundColor: _purple,
      ));
      return;
    }
    final entry = EnergyEntry(
      id: 'energy_${DateTime.now().millisecondsSinceEpoch}',
      date: DateTime.now(),
      level: _level,
      drainers: _selectedDrainers.toList(),
      notes: _notesCtrl.text.trim(),
    );
    final child = SelectedChildService.current ?? SelectedChildService.selectDefault();
    final prefsKey = '${child?.id ?? ''}_energy_entries';
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(prefsKey) ?? [];
    raw.insert(0, jsonEncode(entry.toJson()));
    await prefs.setStringList(prefsKey, raw);
    if (!mounted) return;
    setState(() => _saved = true);
    await _loadEntries();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(_level == 5
          ? 'Full energy — amazing! ⚡'
          : 'Energy logged! Keep going 💪'),
      backgroundColor: _teal,
    ));
  }

  // ── Build ─────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgDark,
      appBar: AppBar(
        backgroundColor: _bgDark,
        title: const Row(
          children: [
            Text('⚡', style: TextStyle(fontSize: 20)),
            SizedBox(width: 8),
            Text('My Battery',
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'DM Sans')),
          ],
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildBatterySelector(),
            const SizedBox(height: 16),
            _buildDrainerChips(),
            const SizedBox(height: 16),
            _buildNotesField(),
            const SizedBox(height: 20),
            _buildSaveButton(),
            const SizedBox(height: 28),
            _buildWeekRow(),
          ],
        ),
      ),
    );
  }

  // ── Battery selector ─────────────────────────────────────
  Widget _buildBatterySelector() {
    return _card(child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label('How is your energy today?'),
        const SizedBox(height: 18),
        // Battery shell
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(child: _buildBatteryBody()),
            const SizedBox(width: 4),
            // Battery terminal nub
            Container(
              width: 8,
              height: 28,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        // Level label below battery
        if (_level > 0)
          Center(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: Row(
                key: ValueKey(_level),
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _levelEmojis[_level - 1],
                    style: const TextStyle(fontSize: 28),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    _levelLabels[_level - 1],
                    style: TextStyle(
                      color: _levelColors[_level - 1],
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      fontFamily: 'DM Sans',
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          Center(
            child: Text(
              'Tap a segment',
              style: TextStyle(
                  color: Colors.white30,
                  fontSize: 14,
                  fontFamily: 'DM Sans'),
            ),
          ),
      ],
    ));
  }

  Widget _buildBatteryBody() {
    return Container(
      height: 64,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _level > 0
              ? _levelColors[_level - 1].withValues(alpha: 0.55)
              : Colors.white24,
          width: 2,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Row(
          children: List.generate(5, (i) {
            final segLevel = i + 1;
            final filled = segLevel <= _level;
            final segColor = _levelColors[i];
            return Expanded(
              child: GestureDetector(
                onTap: () => setState(() {
                  _level = segLevel;
                  _saved = false;
                }),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: EdgeInsets.only(
                    left: i == 0 ? 0 : 1.5,
                    right: i == 4 ? 0 : 1.5,
                  ),
                  decoration: BoxDecoration(
                    color: filled
                        ? segColor.withValues(alpha: 0.85)
                        : Colors.white.withValues(alpha: 0.04),
                  ),
                  child: filled
                      ? Center(
                          child: Text(
                            _levelEmojis[i],
                            style: TextStyle(
                              fontSize: _level == segLevel ? 22 : 16,
                            ),
                          ),
                        )
                      : Center(
                          child: Text(
                            _levelEmojis[i],
                            style: const TextStyle(
                                fontSize: 14, color: Colors.transparent),
                          ),
                        ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  // ── Drainer chips ─────────────────────────────────────────
  Widget _buildDrainerChips() {
    return _card(child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label("What drained your energy? (Optional)"),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _drainerOptions.map((d) {
            final sel = _selectedDrainers.contains(d);
            return GestureDetector(
              onTap: () => setState(() {
                _saved = false;
                if (d == "Don't know") {
                  _selectedDrainers.clear();
                  _selectedDrainers.add(d);
                } else {
                  _selectedDrainers.remove("Don't know");
                  if (sel) {
                    _selectedDrainers.remove(d);
                  } else {
                    _selectedDrainers.add(d);
                  }
                }
              }),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 9),
                decoration: BoxDecoration(
                  color: sel
                      ? _teal.withValues(alpha: 0.18)
                      : Colors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: sel
                        ? _teal.withValues(alpha: 0.70)
                        : Colors.white.withValues(alpha: 0.14),
                    width: sel ? 1.5 : 1,
                  ),
                ),
                child: Text(d,
                    style: TextStyle(
                      color: sel ? _teal : Colors.white60,
                      fontSize: 13,
                      fontFamily: 'DM Sans',
                      fontWeight:
                          sel ? FontWeight.w600 : FontWeight.normal,
                    )),
              ),
            );
          }).toList(),
        ),
      ],
    ));
  }

  // ── Notes field ───────────────────────────────────────────
  Widget _buildNotesField() {
    return _card(child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label('Any notes? (Optional)'),
        const SizedBox(height: 10),
        TextField(
          controller: _notesCtrl,
          maxLines: 3,
          onChanged: (_) => setState(() => _saved = false),
          style: const TextStyle(
              color: Colors.white, fontSize: 13, fontFamily: 'DM Sans'),
          decoration: InputDecoration(
            hintText: 'e.g. felt tired after lunch, had loads of energy at PE...',
            hintStyle:
                const TextStyle(color: Colors.white30, fontSize: 13),
            filled: true,
            fillColor: Colors.white.withValues(alpha: 0.05),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                  color: Colors.white.withValues(alpha: 0.12)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                  color: Colors.white.withValues(alpha: 0.12)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: _teal),
            ),
            contentPadding: const EdgeInsets.symmetric(
                horizontal: 12, vertical: 10),
          ),
        ),
      ],
    ));
  }

  // ── Save button ───────────────────────────────────────────
  Widget _buildSaveButton() {
    final btnColor = _saved
        ? const Color(0xFF4CAF50)
        : (_level > 0 ? _levelColors[_level - 1] : _teal);
    return SizedBox(
      width: double.infinity,
      child: FilledButton.icon(
        style: FilledButton.styleFrom(
          backgroundColor: btnColor,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14)),
        ),
        onPressed: _saved ? null : _saveEntry,
        icon: Icon(
            _saved ? Icons.check_circle_rounded : Icons.bolt_rounded),
        label: Text(
          _saved ? 'Energy Logged!' : 'Log My Energy',
          style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              fontFamily: 'DM Sans'),
        ),
      ),
    );
  }

  // ── 7-day mini battery row ────────────────────────────────
  Widget _buildWeekRow() {
    if (_entries.isEmpty) return const SizedBox.shrink();

    final today = DateTime.now();
    final days = List.generate(
        7,
        (i) => DateTime(today.year, today.month, today.day)
            .subtract(Duration(days: 6 - i)));

    final byDate = <String, EnergyEntry>{};
    for (final e in _entries) {
      final key = e.date.toIso8601String().substring(0, 10);
      byDate.putIfAbsent(key, () => e);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label('Last 7 days'),
        const SizedBox(height: 12),
        Row(
          children: days.map((d) {
            final key = d.toIso8601String().substring(0, 10);
            final entry = byDate[key];
            final lvl = entry?.level ?? 0;
            final diff =
                DateTime(today.year, today.month, today.day)
                    .difference(
                        DateTime(d.year, d.month, d.day))
                    .inDays;
            final dayStr = diff == 0
                ? 'Today'
                : diff == 1
                    ? 'Yest'
                    : _shortDay(d.weekday);
            final col =
                lvl > 0 ? _levelColors[lvl - 1] : Colors.white12;

            return Expanded(
              child: Column(
                children: [
                  Text(dayStr,
                      style: const TextStyle(
                          color: Colors.white38,
                          fontSize: 9,
                          fontFamily: 'DM Sans'),
                      textAlign: TextAlign.center),
                  const SizedBox(height: 6),
                  // Mini battery — vertical fill bar
                  Container(
                    width: 22,
                    height: 44,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      border: Border.all(color: Colors.white12),
                      color: Colors.white.withValues(alpha: 0.04),
                    ),
                    alignment: Alignment.bottomCenter,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 400),
                      width: double.infinity,
                      height: lvl > 0 ? (44.0 * lvl / 5) : 0,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        color: col,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  if (lvl > 0)
                    Text(_levelEmojis[lvl - 1],
                        style: const TextStyle(fontSize: 11),
                        textAlign: TextAlign.center)
                  else
                    const Text('—',
                        style: TextStyle(
                            color: Colors.white12, fontSize: 10),
                        textAlign: TextAlign.center),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  String _shortDay(int weekday) {
    const d = ['Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa', 'Su'];
    return d[weekday - 1];
  }

  // ── Helpers ───────────────────────────────────────────────
  Widget _card({required Widget child}) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color: Colors.white.withValues(alpha: 0.07)),
        ),
        child: child,
      );

  Widget _label(String text) => Text(text,
      style: const TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.w700,
          fontFamily: 'DM Sans'));
}
