import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/selected_child_service.dart';

// ─────────────────────────────────────────────────────────────
// SLEEP SCREEN — Fabulously Me
// Star rating, clock-face time pickers, morning face,
// sleep blocker chips, notes.  Key: sleep_entries
// ─────────────────────────────────────────────────────────────

class SleepEntry {
  final String id;
  final DateTime date;
  final int stars;
  final String? bedtime;   // HH:mm — null if not set
  final String? wakeTime;  // HH:mm — null if not set
  final int morningFace;
  final List<String> blockers;
  final String notes;

  SleepEntry({
    required this.id,
    required this.date,
    required this.stars,
    this.bedtime,
    this.wakeTime,
    required this.morningFace,
    required this.blockers,
    required this.notes,
  });

  // Duration between bedtime and wakeTime; null if either is unset.
  int? get sleepDurationMinutes {
    if (bedtime == null || wakeTime == null) return null;
    final bParts = bedtime!.split(':');
    final wParts = wakeTime!.split(':');
    final bMins = int.parse(bParts[0]) * 60 + int.parse(bParts[1]);
    final wMins = int.parse(wParts[0]) * 60 + int.parse(wParts[1]);
    int diff = wMins - bMins;
    if (diff <= 0) diff += 24 * 60; // crossed midnight
    if (diff > 16 * 60) return null; // implausible
    return diff;
  }

  String? get sleepDurationLabel {
    final mins = sleepDurationMinutes;
    if (mins == null) return null;
    final h = mins ~/ 60;
    final m = mins % 60;
    return m == 0 ? '${h}h' : '${h}h ${m}m';
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'date': date.toIso8601String().substring(0, 10),
        'stars': stars,
        'bedtime': bedtime,
        'wakeTime': wakeTime,
        'morningFace': morningFace,
        'blockers': blockers,
        'notes': notes,
      };

  factory SleepEntry.fromJson(Map<String, dynamic> j) {
    // Backward compat: old format stored bedtimeHour / wakeHour as int
    String? bedtime = j['bedtime'] as String?;
    if (bedtime == null && j['bedtimeHour'] != null) {
      bedtime =
          '${(j['bedtimeHour'] as int).toString().padLeft(2, '0')}:00';
    }
    String? wakeTime = j['wakeTime'] as String?;
    if (wakeTime == null && j['wakeHour'] != null) {
      wakeTime =
          '${(j['wakeHour'] as int).toString().padLeft(2, '0')}:00';
    }
    return SleepEntry(
      id: j['id'] as String,
      date: DateTime.parse(j['date'] as String),
      stars: (j['stars'] as num).toInt(),
      bedtime: bedtime,
      wakeTime: wakeTime,
      morningFace: (j['morningFace'] as num? ?? -1).toInt(),
      blockers: List<String>.from((j['blockers'] as List?) ?? []),
      notes: j['notes'] as String? ?? '',
    );
  }
}

class SleepScreen extends StatefulWidget {
  const SleepScreen({super.key});

  @override
  State<SleepScreen> createState() => _SleepScreenState();
}

class _SleepScreenState extends State<SleepScreen> {
  // ── Form state ────────────────────────────────────────────
  int _stars = 0;
  String? _bedtime;
  String? _wakeTime;
  int _morningFace = -1;
  final Set<String> _selectedBlockers = {};
  final _notesCtrl = TextEditingController();
  bool _saved = false;

  // ── History ───────────────────────────────────────────────
  List<SleepEntry> _entries = [];

  static const _starLabels = [
    'Terrible',
    'Not great',
    'Okay',
    'Good',
    'Amazing',
  ];
  static const _starColors = [
    Color(0xFFFF1744),
    Color(0xFFFF7043),
    Color(0xFFFFB830),
    Color(0xFF8BC34A),
    Color(0xFF4CAF50),
  ];

  static const _faces = ['😊', '😐', '😕', '😢', '😭'];
  static const _faceLabels = [
    'Feeling great',
    'A bit tired',
    'Pretty tired',
    'Very tired',
    'Exhausted',
  ];
  static const _faceColors = [
    Color(0xFF4CAF50),
    Color(0xFFFFEB3B),
    Color(0xFFFFB830),
    Color(0xFFFF7043),
    Color(0xFFFF1744),
  ];

  static const _blockerOptions = [
    'Nightmares',
    'Too hot',
    'Too cold',
    'Noises',
    "Couldn't stop thinking",
    'Tummy ache',
    'Pain',
    'Nothing — slept great',
  ];

  static const _purple = Color(0xFF6C63FF);
  static const _bgDark = Color(0xFF0D0820);
  static const _cardBg = Color(0xFF1A1040);
  static const _moon   = Color(0xFF5DADEC);

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

  // ── Persistence ───────────────────────────────────────────

  Future<void> _loadEntries() async {
    final child = SelectedChildService.current ?? SelectedChildService.selectDefault();
    final prefsKey = '${child?.id ?? ''}_sleep_entries';
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(prefsKey) ?? [];
    if (!mounted) return;
    setState(() {
      _entries = raw
          .map((s) =>
              SleepEntry.fromJson(jsonDecode(s) as Map<String, dynamic>))
          .toList()
        ..sort((a, b) => b.date.compareTo(a.date));
    });
  }

  Future<void> _saveEntry() async {
    if (_stars == 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Tap the stars to rate your sleep first!'),
        backgroundColor: _purple,
      ));
      return;
    }
    final entry = SleepEntry(
      id: 'sleep_${DateTime.now().millisecondsSinceEpoch}',
      date: DateTime.now(),
      stars: _stars,
      bedtime: _bedtime,
      wakeTime: _wakeTime,
      morningFace: _morningFace,
      blockers: _selectedBlockers.toList(),
      notes: _notesCtrl.text.trim(),
    );
    final child = SelectedChildService.current ?? SelectedChildService.selectDefault();
    final prefsKey = '${child?.id ?? ''}_sleep_entries';
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(prefsKey) ?? [];
    raw.insert(0, jsonEncode(entry.toJson()));
    await prefs.setStringList(prefsKey, raw);
    if (!mounted) return;
    setState(() => _saved = true);
    await _loadEntries();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(_stars == 5 ? 'Amazing sleep! ⭐' : 'Sleep logged! 🌙'),
      backgroundColor: _purple,
    ));
  }

  // ── Clock-face time picker ────────────────────────────────

  String _formatTime(String hhmm) {
    final parts = hhmm.split(':');
    final h = int.parse(parts[0]);
    final m = int.parse(parts[1]);
    final suffix     = h < 12 ? 'AM' : 'PM';
    final displayH   = h == 0 ? 12 : (h > 12 ? h - 12 : h);
    final displayM   = m.toString().padLeft(2, '0');
    return '$displayH:$displayM $suffix';
  }

  TimeOfDay _parseTime(String hhmm) {
    final parts = hhmm.split(':');
    return TimeOfDay(
        hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }

  String _todToHHMM(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  Future<void> _pickBedtime() async {
    final initial = _bedtime != null
        ? _parseTime(_bedtime!)
        : const TimeOfDay(hour: 21, minute: 0);
    final picked = await showTimePicker(
      context: context,
      initialTime: initial,
      initialEntryMode: TimePickerEntryMode.dial,
      helpText: 'What time did you go to bed?',
      builder: (ctx, child) => _darkTimePickerTheme(ctx, child!),
    );
    if (picked != null && mounted) {
      setState(() {
        _bedtime = _todToHHMM(picked);
        _saved = false;
      });
    }
  }

  Future<void> _pickWakeTime() async {
    final initial = _wakeTime != null
        ? _parseTime(_wakeTime!)
        : const TimeOfDay(hour: 7, minute: 0);
    final picked = await showTimePicker(
      context: context,
      initialTime: initial,
      initialEntryMode: TimePickerEntryMode.dial,
      helpText: 'What time did you wake up?',
      builder: (ctx, child) => _darkTimePickerTheme(ctx, child!),
    );
    if (picked != null && mounted) {
      setState(() {
        _wakeTime = _todToHHMM(picked);
        _saved = false;
      });
    }
  }

  Widget _darkTimePickerTheme(BuildContext ctx, Widget child) {
    return Theme(
      data: ThemeData.dark().copyWith(
        colorScheme: const ColorScheme.dark(
          primary: _purple,
          onPrimary: Colors.white,
          surface: Color(0xFF1A1040),
          onSurface: Colors.white,
        ),
        timePickerTheme: const TimePickerThemeData(
          backgroundColor: Color(0xFF1A1040),
          hourMinuteColor: Color(0xFF0D0820),
          dialBackgroundColor: Color(0xFF0D0820),
          hourMinuteTextColor: Colors.white,
          dialHandColor: _purple,
        ),
      ),
      child: child,
    );
  }

  // ── Build ─────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgDark,
      appBar: AppBar(
        backgroundColor: _bgDark,
        title: const Row(children: [
          Text('🌙', style: TextStyle(fontSize: 20)),
          SizedBox(width: 8),
          Text('Sleep Tracker',
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'DM Sans')),
        ]),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStarRating(),
            const SizedBox(height: 16),
            _buildTimePickers(),
            const SizedBox(height: 16),
            _buildMorningFaces(),
            const SizedBox(height: 16),
            _buildBlockerChips(),
            const SizedBox(height: 16),
            _buildNotesField(),
            const SizedBox(height: 20),
            _buildSaveButton(),
            const SizedBox(height: 28),
            _buildWeekSummary(),
          ],
        ),
      ),
    );
  }

  // ── Star rating ───────────────────────────────────────────

  Widget _buildStarRating() {
    return _card(
        child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label('How was your sleep last night?'),
        const SizedBox(height: 14),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(5, (i) {
            final n      = i + 1;
            final filled = n <= _stars;
            final col    = _starColors[i];
            return GestureDetector(
              onTap: () => setState(() {
                _stars = n;
                _saved = false;
              }),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(
                    horizontal: 4, vertical: 4),
                child: Column(children: [
                  Icon(
                    filled
                        ? Icons.star_rounded
                        : Icons.star_outline_rounded,
                    color: filled ? col : Colors.white24,
                    size: filled ? 46 : 38,
                  ),
                  const SizedBox(height: 4),
                  Text(_starLabels[i],
                      style: TextStyle(
                        color: filled ? col : Colors.white30,
                        fontSize: 9,
                        fontFamily: 'DM Sans',
                        fontWeight: filled
                            ? FontWeight.w600
                            : FontWeight.normal,
                      )),
                ]),
              ),
            );
          }),
        ),
      ],
    ));
  }

  // ── Time pickers ──────────────────────────────────────────

  Widget _buildTimePickers() {
    final duration = (_bedtime != null && _wakeTime != null)
        ? SleepEntry(
            id: '',
            date: DateTime.now(),
            stars: 0,
            bedtime: _bedtime,
            wakeTime: _wakeTime,
            morningFace: -1,
            blockers: [],
            notes: '',
          ).sleepDurationLabel
        : null;

    return Column(
      children: [
        Row(children: [
          Expanded(child: _timeCard(
            icon: '🌙',
            label: 'Bedtime',
            value: _bedtime != null
                ? _formatTime(_bedtime!)
                : 'Tap to set',
            onTap: _pickBedtime,
          )),
          const SizedBox(width: 10),
          Expanded(child: _timeCard(
            icon: '🌤',
            label: 'Wake up',
            value: _wakeTime != null
                ? _formatTime(_wakeTime!)
                : 'Tap to set',
            onTap: _pickWakeTime,
          )),
        ]),
        if (duration != null) ...[
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
                horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: _moon.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                  color: _moon.withValues(alpha: 0.25)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('😴',
                    style: TextStyle(fontSize: 14)),
                const SizedBox(width: 8),
                Text(
                  '$duration sleep',
                  style: const TextStyle(
                    color: _moon,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'DM Sans',
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _timeCard({
    required String icon,
    required String label,
    required String value,
    required VoidCallback onTap,
  }) {
    final hasValue = value != 'Tap to set';
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: _cardBg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: hasValue
                ? _moon.withValues(alpha: 0.50)
                : Colors.white10,
          ),
        ),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(icon, style: const TextStyle(fontSize: 24)),
              const SizedBox(height: 6),
              Text(label,
                  style: const TextStyle(
                      color: Colors.white54,
                      fontSize: 11,
                      fontFamily: 'DM Sans')),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  color: hasValue ? _moon : Colors.white30,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'DM Sans',
                ),
              ),
            ]),
      ),
    );
  }

  // ── Morning faces ─────────────────────────────────────────

  Widget _buildMorningFaces() {
    return _card(
        child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label('How do you feel this morning?'),
        const SizedBox(height: 14),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(_faces.length, (i) {
            final sel = _morningFace == i;
            final col = _faceColors[i];
            return GestureDetector(
              onTap: () => setState(() {
                _morningFace = i;
                _saved = false;
              }),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(
                    horizontal: 6, vertical: 6),
                decoration: BoxDecoration(
                  color: sel
                      ? col.withValues(alpha: 0.18)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: sel ? col : Colors.white12,
                    width: sel ? 1.5 : 1,
                  ),
                ),
                child: Column(children: [
                  Text(_faces[i],
                      style:
                          TextStyle(fontSize: sel ? 30 : 24)),
                  const SizedBox(height: 3),
                  Text(_faceLabels[i],
                      style: TextStyle(
                        color: sel ? col : Colors.white30,
                        fontSize: 8,
                        fontFamily: 'DM Sans',
                        fontWeight: sel
                            ? FontWeight.w600
                            : FontWeight.normal,
                      )),
                ]),
              ),
            );
          }),
        ),
      ],
    ));
  }

  // ── Blocker chips ─────────────────────────────────────────

  Widget _buildBlockerChips() {
    return _card(
        child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label('What got in the way? (Optional)'),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _blockerOptions.map((b) {
            final sel = _selectedBlockers.contains(b);
            return GestureDetector(
              onTap: () {
                setState(() {
                  _saved = false;
                  if (b == 'Nothing — slept great') {
                    _selectedBlockers.clear();
                    _selectedBlockers.add(b);
                  } else {
                    _selectedBlockers.remove('Nothing — slept great');
                    if (sel) {
                      _selectedBlockers.remove(b);
                    } else {
                      _selectedBlockers.add(b);
                    }
                  }
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.symmetric(
                    horizontal: 13, vertical: 8),
                decoration: BoxDecoration(
                  color: sel
                      ? _purple.withValues(alpha: 0.20)
                      : Colors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: sel
                        ? _purple.withValues(alpha: 0.70)
                        : Colors.white.withValues(alpha: 0.14),
                    width: sel ? 1.5 : 1,
                  ),
                ),
                child: Text(b,
                    style: TextStyle(
                      color: sel ? _purple : Colors.white60,
                      fontSize: 12,
                      fontFamily: 'DM Sans',
                      fontWeight: sel
                          ? FontWeight.w600
                          : FontWeight.normal,
                    )),
              ),
            );
          }).toList(),
        ),
      ],
    ));
  }

  // ── Notes ─────────────────────────────────────────────────

  Widget _buildNotesField() {
    return _card(
        child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label('Any notes? (Optional)'),
        const SizedBox(height: 10),
        TextField(
          controller: _notesCtrl,
          maxLines: 3,
          onChanged: (_) => setState(() => _saved = false),
          style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontFamily: 'DM Sans'),
          decoration: InputDecoration(
            hintText: 'e.g. had a nice dream, woke up early...',
            hintStyle: const TextStyle(
                color: Colors.white30, fontSize: 13),
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
              borderSide: const BorderSide(color: _purple),
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
    return SizedBox(
      width: double.infinity,
      child: FilledButton.icon(
        style: FilledButton.styleFrom(
          backgroundColor:
              _saved ? const Color(0xFF4CAF50) : _purple,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14)),
        ),
        onPressed: _saved ? null : _saveEntry,
        icon: Icon(
            _saved ? Icons.check_circle_rounded : Icons.bedtime_rounded),
        label: Text(
          _saved ? 'Sleep Logged!' : 'Log My Sleep',
          style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              fontFamily: 'DM Sans'),
        ),
      ),
    );
  }

  // ── 7-night summary ───────────────────────────────────────

  Widget _buildWeekSummary() {
    if (_entries.isEmpty) return const SizedBox.shrink();

    final today = DateTime.now();
    final days = List.generate(
      7,
      (i) => DateTime(today.year, today.month, today.day)
          .subtract(Duration(days: 6 - i)),
    );

    final byDate = <String, SleepEntry>{};
    for (final e in _entries) {
      final key = e.date.toIso8601String().substring(0, 10);
      byDate.putIfAbsent(key, () => e);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label('Last 7 nights'),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: days.map((d) {
            final key   = d.toIso8601String().substring(0, 10);
            final entry = byDate[key];
            final stars = entry?.stars ?? 0;
            final col   = stars > 0
                ? _starColors[stars - 1]
                : Colors.white12;
            final diff = DateTime(today.year, today.month, today.day)
                .difference(DateTime(d.year, d.month, d.day))
                .inDays;
            final dayStr = diff == 0
                ? 'Today'
                : diff == 1
                    ? 'Yest'
                    : _shortDay(d.weekday);
            return Expanded(
              child: Column(children: [
                Text(dayStr,
                    style: const TextStyle(
                        color: Colors.white38,
                        fontSize: 9,
                        fontFamily: 'DM Sans'),
                    textAlign: TextAlign.center),
                const SizedBox(height: 4),
                Column(
                  children: List.generate(5, (si) {
                    final filled = si < stars;
                    return Padding(
                      padding:
                          const EdgeInsets.symmetric(vertical: 1),
                      child: Icon(
                        filled
                            ? Icons.star_rounded
                            : Icons.star_outline_rounded,
                        size: 11,
                        color: filled ? col : Colors.white10,
                      ),
                    );
                  }).reversed.toList(),
                ),
                const SizedBox(height: 3),
                if (stars > 0)
                  Text('$stars★',
                      style: TextStyle(
                          color: col,
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'DM Sans'),
                      textAlign: TextAlign.center)
                else
                  const Text('—',
                      style: TextStyle(
                          color: Colors.white12,
                          fontSize: 9,
                          fontFamily: 'DM Sans'),
                      textAlign: TextAlign.center),
              ]),
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
          border:
              Border.all(color: Colors.white.withValues(alpha: 0.07)),
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
