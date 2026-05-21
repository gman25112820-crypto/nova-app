import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SleepEntry {
  final String id;
  final DateTime date;
  final int stars;
  final String? bedtime;
  final String? wakeTime;
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

  factory SleepEntry.fromJson(Map<String, dynamic> j) => SleepEntry(
        id: j['id'] as String,
        date: DateTime.parse(j['date'] as String),
        stars: (j['stars'] as num).toInt(),
        bedtime: j['bedtime'] as String?,
        wakeTime: j['wakeTime'] as String?,
        morningFace: (j['morningFace'] as num).toInt(),
        blockers: List<String>.from(j['blockers'] as List),
        notes: j['notes'] as String? ?? '',
      );
}

class SleepScreen extends StatefulWidget {
  const SleepScreen({super.key});

  @override
  State<SleepScreen> createState() => _SleepScreenState();
}

class _SleepScreenState extends State<SleepScreen> {
  int _stars = 0;
  TimeOfDay? _bedtime;
  TimeOfDay? _wakeTime;
  int _morningFace = -1;
  final Set<String> _selectedBlockers = {};
  final _notesCtrl = TextEditingController();
  bool _saved = false;
  List<SleepEntry> _entries = [];

  static const _prefsKey = 'sleep_entries';

  static const _faces = ['😊', '😄', '😐', '😕', '😣'];
  static const _faceLabels = ['Amazing', 'Good', 'Okay', 'Tired', 'Exhausted'];
  static const _faceColors = [
    Color(0xFF00C9A7),
    Color(0xFF6C63FF),
    Color(0xFFFFB830),
    Color(0xFFFF8C42),
    Color(0xFFFF6B8A),
  ];

  static const _blockerOptions = [
    'Nightmares',
    'Too hot',
    'Too cold',
    'Noises',
    "Couldn't stop thinking",
    'Tummy ache',
    'Pain',
    'Nothing',
  ];

  static const _purple = Color(0xFF6C63FF);
  static const _moon   = Color(0xFF5DADEC);
  static const _bgDark = Color(0xFF0D0820);
  static const _cardBg = Color(0xFF1A1040);

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
    final raw = prefs.getStringList(_prefsKey) ?? [];
    if (!mounted) return;
    setState(() {
      _entries = raw
          .map((s) => SleepEntry.fromJson(jsonDecode(s) as Map<String, dynamic>))
          .toList()
        ..sort((a, b) => b.date.compareTo(a.date));
    });
  }

  Future<void> _saveEntry() async {
    if (_stars == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tap the stars to rate your sleep first!'),
          backgroundColor: Color(0xFF6C63FF),
        ),
      );
      return;
    }

    String? bedStr;
    if (_bedtime != null) {
      final hh = _bedtime!.hour.toString().padLeft(2, '0');
      final mm = _bedtime!.minute.toString().padLeft(2, '0');
      bedStr = '$hh:$mm';
    }
    String? wakeStr;
    if (_wakeTime != null) {
      final hh = _wakeTime!.hour.toString().padLeft(2, '0');
      final mm = _wakeTime!.minute.toString().padLeft(2, '0');
      wakeStr = '$hh:$mm';
    }

    final entry = SleepEntry(
      id: 'sleep_${DateTime.now().millisecondsSinceEpoch}',
      date: DateTime.now(),
      stars: _stars,
      bedtime: bedStr,
      wakeTime: wakeStr,
      morningFace: _morningFace,
      blockers: _selectedBlockers.toList(),
      notes: _notesCtrl.text.trim(),
    );

    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_prefsKey) ?? [];
    raw.insert(0, jsonEncode(entry.toJson()));
    await prefs.setStringList(_prefsKey, raw);

    if (!mounted) return;
    setState(() => _saved = true);
    await _loadEntries();

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_stars == 5
            ? 'Perfect night logged! ⭐'
            : 'Sleep logged! Well done for tracking 🌙'),
        backgroundColor: _purple,
      ),
    );
  }

  String _formatTime(TimeOfDay t) {
    final h = t.hourOfPeriod == 0 ? 12 : t.hourOfPeriod;
    final m = t.minute.toString().padLeft(2, '0');
    final period = t.period == DayPeriod.am ? 'AM' : 'PM';
    return '$h:$m $period';
  }

  Future<void> _pickBedtime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _bedtime ?? const TimeOfDay(hour: 21, minute: 0),
      builder: (ctx, child) => _darkTimePicker(ctx, child),
    );
    if (picked != null) setState(() => _bedtime = picked);
  }

  Future<void> _pickWakeTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _wakeTime ?? const TimeOfDay(hour: 7, minute: 0),
      builder: (ctx, child) => _darkTimePicker(ctx, child),
    );
    if (picked != null) setState(() => _wakeTime = picked);
  }

  Widget _darkTimePicker(BuildContext ctx, Widget? child) {
    return Theme(
      data: ThemeData.dark().copyWith(
        colorScheme: const ColorScheme.dark(
          primary: _purple,
          onPrimary: Colors.white,
          surface: Color(0xFF1A1040),
          onSurface: Colors.white,
        ),
        timePickerTheme: const TimePickerThemeData(
          backgroundColor: Color(0xFF0D0820),
          dialHandColor: _purple,
          dialBackgroundColor: Color(0xFF1A1040),
        ),
      ),
      child: child!,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgDark,
      appBar: AppBar(
        backgroundColor: _bgDark,
        title: const Row(
          children: [
            Text('🌙', style: TextStyle(fontSize: 20)),
            SizedBox(width: 8),
            Text(
              'Sleep Tracker',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontFamily: 'DM Sans',
              ),
            ),
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

  Widget _buildStarRating() {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionLabel('⭐ How was your sleep?'),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(5, (i) {
              final n = i + 1;
              final filled = n <= _stars;
              return GestureDetector(
                onTap: () => setState(() => _stars = n),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.all(6),
                  child: Column(
                    children: [
                      Icon(
                        filled ? Icons.star_rounded : Icons.star_outline_rounded,
                        color: filled ? const Color(0xFFFFD700) : Colors.white24,
                        size: filled ? 44 : 38,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _starLabel(n),
                        style: TextStyle(
                          color: filled ? const Color(0xFFFFD700) : Colors.white38,
                          fontSize: 10,
                          fontFamily: 'DM Sans',
                          fontWeight: filled ? FontWeight.w600 : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  String _starLabel(int n) {
    switch (n) {
      case 1: return 'Awful';
      case 2: return 'Poor';
      case 3: return 'Okay';
      case 4: return 'Good';
      case 5: return 'Great!';
      default: return '';
    }
  }

  Widget _buildTimePickers() {
    return Row(
      children: [
        Expanded(child: _timeCard(
          icon: '🌙',
          label: 'Bedtime',
          value: _bedtime != null ? _formatTime(_bedtime!) : 'Tap to set',
          onTap: _pickBedtime,
        )),
        const SizedBox(width: 10),
        Expanded(child: _timeCard(
          icon: '🌤',
          label: 'Wake up',
          value: _wakeTime != null ? _formatTime(_wakeTime!) : 'Tap to set',
          onTap: _pickWakeTime,
        )),
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
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: _cardBg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: hasValue
                ? _moon.withValues(alpha: 0.50)
                : Colors.white.withValues(alpha: 0.10),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(icon, style: const TextStyle(fontSize: 22)),
            const SizedBox(height: 6),
            Text(label,
                style: const TextStyle(
                    color: Colors.white54,
                    fontSize: 11,
                    fontFamily: 'DM Sans')),
            const SizedBox(height: 2),
            Text(value,
                style: TextStyle(
                  color: hasValue ? _moon : Colors.white38,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'DM Sans',
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildMorningFaces() {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionLabel('😊 How do you feel this morning?'),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(_faces.length, (i) {
              final selected = _morningFace == i;
              return GestureDetector(
                onTap: () => setState(() => _morningFace = i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  decoration: BoxDecoration(
                    color: selected
                        ? _faceColors[i].withValues(alpha: 0.20)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: selected
                          ? _faceColors[i].withValues(alpha: 0.60)
                          : Colors.white12,
                      width: selected ? 1.5 : 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(_faces[i],
                          style: TextStyle(fontSize: selected ? 28 : 22)),
                      const SizedBox(height: 3),
                      Text(_faceLabels[i],
                          style: TextStyle(
                            color: selected ? _faceColors[i] : Colors.white38,
                            fontSize: 9,
                            fontFamily: 'DM Sans',
                            fontWeight: selected
                                ? FontWeight.w600
                                : FontWeight.normal,
                          )),
                    ],
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildBlockerChips() {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionLabel('😴 What got in the way? (Optional)'),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _blockerOptions.map((b) {
              final selected = _selectedBlockers.contains(b);
              return GestureDetector(
                onTap: () {
                  setState(() {
                    if (b == 'Nothing') {
                      _selectedBlockers.clear();
                      _selectedBlockers.add('Nothing');
                    } else {
                      _selectedBlockers.remove('Nothing');
                      if (selected) {
                        _selectedBlockers.remove(b);
                      } else {
                        _selectedBlockers.add(b);
                      }
                    }
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 160),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 13, vertical: 8),
                  decoration: BoxDecoration(
                    color: selected
                        ? _purple.withValues(alpha: 0.22)
                        : Colors.white.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: selected
                          ? _purple.withValues(alpha: 0.70)
                          : Colors.white.withValues(alpha: 0.15),
                      width: selected ? 1.5 : 1,
                    ),
                  ),
                  child: Text(b,
                      style: TextStyle(
                        color: selected ? _purple : Colors.white60,
                        fontSize: 12,
                        fontFamily: 'DM Sans',
                        fontWeight: selected
                            ? FontWeight.w600
                            : FontWeight.normal,
                      )),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildNotesField() {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionLabel('📝 Any notes? (Optional)'),
          const SizedBox(height: 10),
          TextField(
            controller: _notesCtrl,
            maxLines: 3,
            style: const TextStyle(
                color: Colors.white, fontSize: 13, fontFamily: 'DM Sans'),
            decoration: InputDecoration(
              hintText: 'e.g. had a nice dream, woke up early...',
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
                borderSide: const BorderSide(color: _purple),
              ),
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12, vertical: 10),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      child: FilledButton.icon(
        style: FilledButton.styleFrom(
          backgroundColor:
              _saved ? const Color(0xFF00C9A7) : _purple,
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

  Widget _buildWeekSummary() {
    if (_entries.isEmpty) return const SizedBox.shrink();
    final last7 = _entries.take(7).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 2, bottom: 12),
          child: _sectionLabel('📅 Last 7 nights'),
        ),
        ...last7.map(_buildSummaryRow),
      ],
    );
  }

  Widget _buildSummaryRow(SleepEntry e) {
    final face = (e.morningFace >= 0 && e.morningFace < _faces.length)
        ? _faces[e.morningFace]
        : '';
    final parts = <String>[
      if (e.bedtime != null) '🌙 ${e.bedtime}',
      if (e.wakeTime != null) '🌤 ${e.wakeTime}',
    ];
    final times = parts.join('  ');
    final hasRealBlockers =
        e.blockers.isNotEmpty && e.blockers.first != 'Nothing';

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      decoration: BoxDecoration(
        color: _cardBg.withValues(alpha: 0.70),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: Colors.white.withValues(alpha: 0.07)),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 44,
            child: Text(_dayLabel(e.date),
                style: const TextStyle(
                    color: Colors.white54,
                    fontSize: 11,
                    fontFamily: 'DM Sans',
                    fontWeight: FontWeight.w600)),
          ),
          const SizedBox(width: 8),
          ...List.generate(
              5,
              (i) => Icon(
                    i < e.stars
                        ? Icons.star_rounded
                        : Icons.star_outline_rounded,
                    color: i < e.stars
                        ? const Color(0xFFFFD700)
                        : Colors.white12,
                    size: 13,
                  )),
          const SizedBox(width: 6),
          if (face.isNotEmpty)
            Text(face, style: const TextStyle(fontSize: 13)),
          const SizedBox(width: 6),
          Expanded(
            child: Text(times,
                style: const TextStyle(
                    color: Colors.white38,
                    fontSize: 10,
                    fontFamily: 'DM Sans'),
                overflow: TextOverflow.ellipsis),
          ),
          if (hasRealBlockers)
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: _purple.withValues(alpha: 0.20),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${e.blockers.length} issue${e.blockers.length > 1 ? "s" : ""}',
                style: const TextStyle(
                    color: _purple,
                    fontSize: 9,
                    fontFamily: 'DM Sans',
                    fontWeight: FontWeight.w600),
              ),
            ),
        ],
      ),
    );
  }

  String _dayLabel(DateTime d) {
    final today = DateTime.now();
    final diff =
        DateTime(today.year, today.month, today.day)
            .difference(DateTime(d.year, d.month, d.day))
            .inDays;
    if (diff == 0) return 'Today';
    if (diff == 1) return 'Yest.';
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[d.weekday - 1];
  }

  Widget _card({required Widget child}) {
    return Container(
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
  }

  Widget _sectionLabel(String text) {
    return Text(text,
        style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w700,
            fontFamily: 'DM Sans'));
  }
}
