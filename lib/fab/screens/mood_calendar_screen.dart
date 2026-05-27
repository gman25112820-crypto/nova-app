import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ─── shared constants (mirrors mood_screen.dart) ─────────────────────────────

const _kMoods = [
  ('😢', 'Awful'),
  ('😟', 'Sad'),
  ('😐', 'Okay'),
  ('😊', 'Good'),
  ('😄', 'Amazing'),
];

const _kPrefsKey = 'fab_mood_entries';

// Cell background per mood index
const _kCellBg = [
  Color(0xFF5C1A1A), // 0 Awful  — dark red
  Color(0xFF5C2E00), // 1 Sad    — dark orange
  Color(0xFF4A3000), // 2 Okay   — dark amber
  Color(0xFF0D3B0D), // 3 Good   — dark green
  Color(0xFF2B1060), // 4 Amazing — dark purple
];

// Border/glow accent per mood index
const _kCellAccent = [
  Color(0xFFE53935), // red
  Color(0xFFFF7043), // orange
  Color(0xFFFFA000), // amber
  Color(0xFF43A047), // green
  Color(0xFF7C4DFF), // purple
];

const _kMonthNames = [
  'January', 'February', 'March', 'April', 'May', 'June',
  'July', 'August', 'September', 'October', 'November', 'December',
];

const _kDayLabels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

// ─── Screen ──────────────────────────────────────────────────────────────────

class MoodCalendarScreen extends StatefulWidget {
  const MoodCalendarScreen({super.key});

  @override
  State<MoodCalendarScreen> createState() => _MoodCalendarScreenState();
}

class _MoodCalendarScreenState extends State<MoodCalendarScreen> {
  late DateTime _focusedMonth;
  List<Map<String, dynamic>> _allEntries = [];

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _focusedMonth = DateTime(now.year, now.month);
    _loadEntries();
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

  /// Maps day-of-month → last entry logged that day (entries kept in order).
  Map<int, Map<String, dynamic>> _buildDayMap() {
    final y = _focusedMonth.year;
    final m = _focusedMonth.month;
    final result = <int, Map<String, dynamic>>{};
    for (final entry in _allEntries) {
      final ts = DateTime.tryParse(entry['timestamp'] as String? ?? '');
      if (ts == null || ts.year != y || ts.month != m) continue;
      result[ts.day] = entry; // later entries overwrite earlier ones
    }
    return result;
  }

  /// All entries for a given day (for the detail sheet).
  List<Map<String, dynamic>> _entriesForDay(int day) {
    final y = _focusedMonth.year;
    final m = _focusedMonth.month;
    return _allEntries.where((e) {
      final ts = DateTime.tryParse(e['timestamp'] as String? ?? '');
      return ts != null && ts.year == y && ts.month == m && ts.day == day;
    }).toList();
  }

  bool get _canGoForward {
    final now = DateTime.now();
    return _focusedMonth.year < now.year ||
        (_focusedMonth.year == now.year &&
            _focusedMonth.month < now.month);
  }

  void _prevMonth() => setState(() {
        _focusedMonth =
            DateTime(_focusedMonth.year, _focusedMonth.month - 1);
      });

  void _nextMonth() {
    if (!_canGoForward) return;
    setState(() {
      _focusedMonth =
          DateTime(_focusedMonth.year, _focusedMonth.month + 1);
    });
  }

  void _showDayDetail(int day) {
    final entries = _entriesForDay(day);
    if (entries.isEmpty) return;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _DayDetailSheet(
        day: day,
        month: _focusedMonth,
        entries: entries,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dayMap = _buildDayMap();
    final now = DateTime.now();
    final isCurrentMonth = _focusedMonth.year == now.year &&
        _focusedMonth.month == now.month;

    return Scaffold(
      backgroundColor: const Color(0xFF0D0820),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1040),
        elevation: 0,
        title: const Text(
          'Mood Calendar',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w700,
            fontFamily: 'DM Sans',
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white70),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(12, 16, 12, 0),
        child: Column(
          children: [
            _MonthHeader(
              month: _focusedMonth,
              canGoForward: _canGoForward,
              onPrev: _prevMonth,
              onNext: _nextMonth,
            ),
            const SizedBox(height: 14),
            _WeekdayHeader(),
            const SizedBox(height: 6),
            _CalendarGrid(
              focusedMonth: _focusedMonth,
              dayMap: dayMap,
              todayDay: isCurrentMonth ? now.day : null,
              onDayTap: _showDayDetail,
            ),
            const SizedBox(height: 20),
            const _Legend(),
          ],
        ),
      ),
    );
  }
}

// ─── Month header ─────────────────────────────────────────────────────────────

class _MonthHeader extends StatelessWidget {
  const _MonthHeader({
    required this.month,
    required this.canGoForward,
    required this.onPrev,
    required this.onNext,
  });

  final DateTime month;
  final bool canGoForward;
  final VoidCallback onPrev;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _NavButton(icon: Icons.chevron_left_rounded, onPressed: onPrev),
        Text(
          '${_kMonthNames[month.month - 1]} ${month.year}',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w700,
            fontFamily: 'DM Sans',
          ),
        ),
        _NavButton(
          icon: Icons.chevron_right_rounded,
          onPressed: canGoForward ? onNext : null,
        ),
      ],
    );
  }
}

class _NavButton extends StatelessWidget {
  const _NavButton({required this.icon, this.onPressed});

  final IconData icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: const Color(0xFF1A1040),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.white12),
        ),
        child: Icon(
          icon,
          color: onPressed != null ? Colors.white70 : Colors.white24,
          size: 20,
        ),
      ),
    );
  }
}

// ─── Weekday header ───────────────────────────────────────────────────────────

class _WeekdayHeader extends StatelessWidget {
  const _WeekdayHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: _kDayLabels
          .map(
            (l) => Expanded(
              child: Text(
                l,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white38,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'DM Sans',
                  letterSpacing: 0.5,
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}

// ─── Calendar grid ────────────────────────────────────────────────────────────

class _CalendarGrid extends StatelessWidget {
  const _CalendarGrid({
    required this.focusedMonth,
    required this.dayMap,
    required this.onDayTap,
    this.todayDay,
  });

  final DateTime focusedMonth;
  final Map<int, Map<String, dynamic>> dayMap;
  final ValueChanged<int> onDayTap;
  final int? todayDay;

  @override
  Widget build(BuildContext context) {
    final firstDay =
        DateTime(focusedMonth.year, focusedMonth.month, 1);
    final daysInMonth =
        DateTime(focusedMonth.year, focusedMonth.month + 1, 0).day;
    // weekday: 1=Mon … 7=Sun; leading blanks = weekday - 1
    final leadingBlanks = firstDay.weekday - 1;

    // Build flat list of cell descriptors
    final cells = <({int? day, Map<String, dynamic>? entry})>[];
    for (int i = 0; i < leadingBlanks; i++) {
      cells.add((day: null, entry: null));
    }
    for (int d = 1; d <= daysInMonth; d++) {
      cells.add((day: d, entry: dayMap[d]));
    }
    // Pad to complete the last row
    final remainder = cells.length % 7;
    if (remainder != 0) {
      for (int i = 0; i < 7 - remainder; i++) {
        cells.add((day: null, entry: null));
      }
    }

    final rowCount = cells.length ~/ 7;
    return Column(
      children: List.generate(rowCount * 2 - 1, (i) {
        if (i.isOdd) return const SizedBox(height: 5);
        final rowIndex = i ~/ 2;
        final start = rowIndex * 7;
        return Row(
          children: List.generate(7, (col) {
            final cell = cells[start + col];
            return Expanded(
              child: _CalendarCell(
                day: cell.day,
                entry: cell.entry,
                isToday: cell.day != null && cell.day == todayDay,
                onTap: cell.day != null && cell.entry != null
                    ? () => onDayTap(cell.day!)
                    : null,
              ),
            );
          }),
        );
      }),
    );
  }
}

// ─── Calendar cell ────────────────────────────────────────────────────────────

class _CalendarCell extends StatelessWidget {
  const _CalendarCell({
    required this.day,
    required this.entry,
    required this.isToday,
    this.onTap,
  });

  final int? day;
  final Map<String, dynamic>? entry;
  final bool isToday;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    if (day == null) {
      return AspectRatio(aspectRatio: 0.88, child: const SizedBox.shrink());
    }

    final moodIdx = entry != null
        ? ((entry!['mood'] as num?)?.toInt() ?? 2).clamp(0, 4)
        : -1;
    final hasEntry = entry != null;
    final emoji = hasEntry ? _kMoods[moodIdx].$1 : null;
    final bgColor =
        hasEntry ? _kCellBg[moodIdx] : const Color(0xFF12082A);
    final borderColor = isToday
        ? Colors.white54
        : hasEntry
            ? _kCellAccent[moodIdx].withValues(alpha: 0.55)
            : Colors.white.withValues(alpha: 0.05);

    return GestureDetector(
      onTap: onTap,
      child: AspectRatio(
        aspectRatio: 0.88,
        child: Container(
          margin: const EdgeInsets.all(2.5),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(9),
            border: Border.all(
              color: borderColor,
              width: isToday ? 1.5 : 0.8,
            ),
            boxShadow: hasEntry
                ? [
                    BoxShadow(
                      color: _kCellAccent[moodIdx]
                          .withValues(alpha: 0.20),
                      blurRadius: 6,
                    ),
                  ]
                : null,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (emoji != null) ...[
                Text(emoji,
                    style: const TextStyle(fontSize: 17),
                    textAlign: TextAlign.center),
                const SizedBox(height: 1),
              ],
              Text(
                '$day',
                style: TextStyle(
                  color: hasEntry
                      ? Colors.white
                      : Colors.white.withValues(alpha: 0.22),
                  fontSize: 10,
                  fontWeight: hasEntry
                      ? FontWeight.w700
                      : FontWeight.normal,
                  fontFamily: 'DM Sans',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Legend ───────────────────────────────────────────────────────────────────

class _Legend extends StatelessWidget {
  const _Legend();

  static const _items = [
    (Color(0xFF5C1A1A), Color(0xFFE53935), '😢', 'Awful'),
    (Color(0xFF5C2E00), Color(0xFFFF7043), '😟', 'Sad'),
    (Color(0xFF4A3000), Color(0xFFFFA000), '😐', 'Okay'),
    (Color(0xFF0D3B0D), Color(0xFF43A047), '😊', 'Good'),
    (Color(0xFF2B1060), Color(0xFF7C4DFF), '😄', 'Amazing'),
  ];

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: _items.map((item) {
        final (bg, accent, emoji, label) = item;
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: bg,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: accent.withValues(alpha: 0.55),
                  width: 0.8,
                ),
              ),
              child: Center(
                child: Text(emoji,
                    style: const TextStyle(fontSize: 16)),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white38,
                fontSize: 9,
                fontFamily: 'DM Sans',
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        );
      }).toList(),
    );
  }
}

// ─── Day detail bottom sheet ──────────────────────────────────────────────────

class _DayDetailSheet extends StatelessWidget {
  const _DayDetailSheet({
    required this.day,
    required this.month,
    required this.entries,
  });

  final int day;
  final DateTime month;
  final List<Map<String, dynamic>> entries;

  @override
  Widget build(BuildContext context) {
    // Always display the latest entry; badge if multiple exist
    final entry = entries.last;
    final moodIdx =
        ((entry['mood'] as num?)?.toInt() ?? 2).clamp(0, 4);
    final (emoji, label) = _kMoods[moodIdx];
    final factors =
        List<String>.from(entry['factors'] as List? ?? []);
    final notes = (entry['notes'] as String? ?? '').trim();
    final ts = DateTime.tryParse(entry['timestamp'] as String? ?? '');

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF1A1040),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle bar
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white30,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          // Mood header row
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: _kCellBg[moodIdx],
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: _kCellAccent[moodIdx].withValues(alpha: 0.5),
                  ),
                ),
                child: Text(emoji,
                    style: const TextStyle(fontSize: 30)),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'DM Sans',
                      ),
                    ),
                    if (ts != null)
                      Text(
                        _formatDate(ts),
                        style: const TextStyle(
                          color: Colors.white54,
                          fontSize: 12,
                          fontFamily: 'DM Sans',
                        ),
                      ),
                  ],
                ),
              ),
              if (entries.length > 1)
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: const Color(0xFF6C63FF).withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: const Color(0xFF6C63FF)
                            .withValues(alpha: 0.35)),
                  ),
                  child: Text(
                    '${entries.length}×',
                    style: const TextStyle(
                      color: Color(0xFF6C63FF),
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'DM Sans',
                    ),
                  ),
                ),
            ],
          ),
          if (factors.isNotEmpty) ...[
            const SizedBox(height: 20),
            const Text(
              'What was affecting you',
              style: TextStyle(
                color: Colors.white38,
                fontSize: 12,
                fontFamily: 'DM Sans',
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: factors
                  .map(
                    (f) => Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0D0820),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white12),
                      ),
                      child: Text(
                        f,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                          fontFamily: 'DM Sans',
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ],
          if (notes.isNotEmpty) ...[
            const SizedBox(height: 20),
            const Text(
              'Notes',
              style: TextStyle(
                color: Colors.white38,
                fontSize: 12,
                fontFamily: 'DM Sans',
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFF0D0820),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.white12),
              ),
              child: Text(
                notes,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontFamily: 'DM Sans',
                  height: 1.5,
                ),
              ),
            ),
          ],
          if (factors.isEmpty && notes.isEmpty) ...[
            const SizedBox(height: 20),
            const Text(
              'No extra details logged.',
              style: TextStyle(
                color: Colors.white38,
                fontSize: 13,
                fontFamily: 'DM Sans',
              ),
            ),
          ],
        ],
      ),
    );
  }

  static String _formatDate(DateTime dt) {
    const wdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    const mons = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${wdays[dt.weekday - 1]} ${dt.day} ${mons[dt.month - 1]}  '
        '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }
}
