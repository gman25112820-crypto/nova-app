import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../fab_theme.dart';
import 'worry_zone_screen.dart' show WorryEntry;
import 'sleep_screen.dart' show SleepEntry;

// ─────────────────────────────────────────────────────────────
// FAB INSIGHTS SCREEN — child-focused trend charts
// Sources: Hive 'worries', SharedPrefs sleep_entries + checkin_*,
//          Hive 'parent_notes' (PDA flags).
// ─────────────────────────────────────────────────────────────

class FabInsightsScreen extends StatefulWidget {
  const FabInsightsScreen({super.key});

  @override
  State<FabInsightsScreen> createState() => _FabInsightsScreenState();
}

class _FabInsightsScreenState extends State<FabInsightsScreen> {
  List<WorryEntry> _worries   = [];
  List<SleepEntry> _sleep     = [];
  // mood: index 0 = 6 days ago … 6 = today; null = no data
  List<int?> _moodByDay       = List.filled(7, null);
  // flags keyed by entry id
  Map<String, List<String>> _flags = {};

  bool _loading = true;

  // Palette constants
  static const _purple = Color(0xFF6C63FF);
  static const _pink   = Color(0xFFFF6B8A);
  static const _teal   = Color(0xFF00C9A7);
  static const _amber  = Color(0xFFFFB830);

  static const _pdaOptions = [
    'Demand refused',
    'Transition difficulty',
    'Meltdown',
    'Masking observed',
  ];
  static const _pdaColors = [_purple, _pink, FabColors.rose, _teal];

  @override
  void initState() {
    super.initState();
    _load();
  }

  // ── Data loading ──────────────────────────────────────────

  Future<void> _load() async {
    final prefs    = await SharedPreferences.getInstance();
    final now      = DateTime.now();

    // Worries
    List<WorryEntry> worries = [];
    if (Hive.isBoxOpen('worries')) {
      worries = Hive.box<Map>('worries')
          .values
          .map((m) => WorryEntry.fromJson(Map<String, dynamic>.from(m)))
          .toList()
        ..sort((a, b) => a.date.compareTo(b.date));
    }

    // Sleep
    final rawSleep = prefs.getStringList('sleep_entries') ?? [];
    final sleep = rawSleep
        .map((s) => SleepEntry.fromJson(jsonDecode(s) as Map<String, dynamic>))
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));

    // Mood — last 7 days
    final moodByDay = List<int?>.filled(7, null);
    for (int i = 0; i < 7; i++) {
      final day = now.subtract(Duration(days: 6 - i));
      final key = '${day.year}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}';
      final done = prefs.getBool('checkin_done_$key') ?? false;
      if (done) moodByDay[i] = prefs.getInt('checkin_mood_$key') ?? 2;
    }

    // PDA flags
    Map<String, List<String>> flags = {};
    if (Hive.isBoxOpen('parent_notes')) {
      final box = Hive.box<String>('parent_notes');
      for (final k in box.keys.cast<String>()) {
        if (k.startsWith('flags_')) {
          final id = k.substring(6);
          flags[id] = List<String>.from(jsonDecode(box.get(k)!) as List);
        }
      }
    }

    if (!mounted) return;
    setState(() {
      _worries   = worries;
      _sleep     = sleep;
      _moodByDay = moodByDay;
      _flags     = flags;
      _loading   = false;
    });
  }

  // ── Derived helpers ───────────────────────────────────────

  /// Last 7 days worry entries, one average per day (index 0=6 days ago).
  List<FlSpot> get _worrySpots {
    final now   = DateTime.now();
    final spots = <FlSpot>[];
    for (int i = 0; i < 7; i++) {
      final day    = now.subtract(Duration(days: 6 - i));
      final ymd    = '${day.year}-${day.month.toString().padLeft(2,'0')}-${day.day.toString().padLeft(2,'0')}';
      final bucket = _worries
          .where((w) => w.date.toIso8601String().substring(0, 10) == ymd && w.intensity > 0)
          .toList();
      if (bucket.isNotEmpty) {
        final avg = bucket.map((w) => w.intensity).reduce((a, b) => a + b) / bucket.length;
        spots.add(FlSpot(i.toDouble(), avg));
      }
    }
    return spots;
  }

  /// Mood spots: wellbeing = 4 - rawMood so higher = happier.
  List<FlSpot> get _moodSpots {
    final spots = <FlSpot>[];
    for (int i = 0; i < 7; i++) {
      final v = _moodByDay[i];
      if (v != null) spots.add(FlSpot(i.toDouble(), (4 - v).toDouble()));
    }
    return spots;
  }

  /// Sleep bar data — 7 nights, height = hours (0 if no data).
  List<_SleepBar> get _sleepBars {
    final now = DateTime.now();
    return List.generate(7, (i) {
      final day = now.subtract(Duration(days: 6 - i));
      final ymd = '${day.year}-${day.month.toString().padLeft(2,'0')}-${day.day.toString().padLeft(2,'0')}';
      final entry = _sleep
          .where((s) => s.date.toIso8601String().substring(0, 10) == ymd)
          .fold<SleepEntry?>(null, (prev, e) => e); // last entry for that day
      final hours  = entry?.sleepDurationMinutes != null
          ? entry!.sleepDurationMinutes! / 60.0
          : 0.0;
      final stars  = entry?.stars ?? 0;
      return _SleepBar(
        dayIndex: i,
        hours: hours,
        stars: stars,
        bedtime:  entry?.bedtime,
        wakeTime: entry?.wakeTime,
      );
    });
  }

  /// Body sensations across all worry entries, sorted descending.
  List<MapEntry<String, int>> get _bodyFrequency {
    final counts = <String, int>{};
    for (final w in _worries) {
      for (final s in w.bodySensations) {
        counts[s] = (counts[s] ?? 0) + 1;
      }
    }
    final sorted = counts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return sorted.take(6).toList();
  }

  /// PDA flag counts — [thisWeek, lastWeek] per flag.
  List<List<int>> get _pdaCounts {
    final now       = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final prevStart = weekStart.subtract(const Duration(days: 7));

    // Build a date map for each worry entry
    final worryDates = {for (final w in _worries) w.id: w.date};

    final thisW = List.filled(_pdaOptions.length, 0);
    final lastW = List.filled(_pdaOptions.length, 0);

    for (final entry in _flags.entries) {
      final date = worryDates[entry.key];
      if (date == null) continue;
      for (int fi = 0; fi < _pdaOptions.length; fi++) {
        if (entry.value.contains(_pdaOptions[fi])) {
          if (!date.isBefore(weekStart)) {
            thisW[fi]++;
          } else if (!date.isBefore(prevStart)) {
            lastW[fi]++;
          }
        }
      }
    }
    return List.generate(_pdaOptions.length, (i) => [thisW[i], lastW[i]]);
  }

  int get _totalDataPoints =>
      _worries.length +
      _sleep.length +
      _moodByDay.where((v) => v != null).length;

  // ── Build ─────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FabColors.bg,
      appBar: AppBar(
        backgroundColor: FabColors.mid,
        elevation: 0,
        title: const Text(
          'My Insights',
          style: TextStyle(color: FabColors.pink, fontSize: 16,
              fontWeight: FontWeight.w700),
        ),
        iconTheme: const IconThemeData(color: FabColors.pink),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: FabColors.muted),
            onPressed: () {
              setState(() => _loading = true);
              _load();
            },
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: _purple))
          : _totalDataPoints < 3
              ? _buildEmpty()
              : _buildContent(),
    );
  }

  // ── Empty state ────────────────────────────────────────────

  Widget _buildEmpty() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('✨', style: const TextStyle(fontSize: 56)),
            const SizedBox(height: 16),
            const Text(
              "Cluck cluck! Not enough data yet!",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: FabColors.pink,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              "Miss CL says: pop back after a few more check-ins "
              "and some sleep logs — then your charts will be SO fabulous! 🌟",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: FabColors.muted,
                fontSize: 14,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 28),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: _purple.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: _purple.withValues(alpha: 0.3)),
              ),
              child: const Text(
                'Come back with 3+ entries 💜',
                style: TextStyle(
                    color: _purple,
                    fontWeight: FontWeight.w700,
                    fontSize: 13),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Main content ───────────────────────────────────────────

  Widget _buildContent() {
    return RefreshIndicator(
      color: _purple,
      backgroundColor: FabColors.panel,
      onRefresh: _load,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildQuickStats(),
            const SizedBox(height: 16),
            _buildWorryChart(),
            const SizedBox(height: 16),
            _buildMoodChart(),
            const SizedBox(height: 16),
            _buildSleepChart(),
            const SizedBox(height: 16),
            _buildBodySymptoms(),
            const SizedBox(height: 16),
            _buildPdaFlags(),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  // ── Quick stats row ────────────────────────────────────────

  Widget _buildQuickStats() {
    final worriesThisWeek = _worries.where((w) {
      final cutoff = DateTime.now().subtract(const Duration(days: 7));
      return w.date.isAfter(cutoff);
    }).length;

    final avgSleep = () {
      final valid = _sleep.where((s) => s.sleepDurationMinutes != null).toList();
      if (valid.isEmpty) return '—';
      final avg = valid.map((s) => s.sleepDurationMinutes!).reduce((a, b) => a + b) / valid.length;
      return '${(avg / 60).toStringAsFixed(1)}h';
    }();

    final moodDays  = _moodByDay.where((v) => v != null).length;
    final avgMood   = moodDays == 0 ? null :
        _moodByDay.where((v) => v != null).map((v) => v!).reduce((a, b) => a + b) / moodDays;
    final moodLabel = avgMood == null ? '—'
        : avgMood < 1.0 ? '😊'
        : avgMood < 2.0 ? '😐'
        : avgMood < 3.0 ? '😢'
        : '😢';

    final totalPda = _flags.values.fold<int>(0, (s, f) => s + f.length);

    return Row(children: [
      Expanded(child: _statCard(
        emoji: '💭', label: 'Worries', value: '$worriesThisWeek',
        sub: 'this week', color: _purple,
      )),
      const SizedBox(width: 8),
      Expanded(child: _statCard(
        emoji: '🌙', label: 'Avg sleep', value: avgSleep,
        sub: '7 nights', color: _teal,
      )),
      const SizedBox(width: 8),
      Expanded(child: _statCard(
        emoji: '😊', label: 'Mood', value: moodLabel,
        sub: '$moodDays days logged', color: _amber,
      )),
      const SizedBox(width: 8),
      Expanded(child: _statCard(
        emoji: '🚦', label: 'PDA flags', value: '$totalPda',
        sub: 'total logged', color: _pink,
      )),
    ]);
  }

  Widget _statCard({
    required String emoji,
    required String label,
    required String value,
    required String sub,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        color: FabColors.panel,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(emoji, style: const TextStyle(fontSize: 18)),
        const SizedBox(height: 6),
        Text(value,
            style: TextStyle(
                color: color, fontSize: 18, fontWeight: FontWeight.w800)),
        Text(sub, style: const TextStyle(color: FabColors.muted, fontSize: 9)),
        const SizedBox(height: 2),
        Text(label.toUpperCase(),
            style: const TextStyle(
                color: FabColors.muted, fontSize: 9, letterSpacing: 1.0)),
      ]),
    );
  }

  // ── Worry intensity line chart ─────────────────────────────

  Widget _buildWorryChart() {
    final spots = _worrySpots;
    if (spots.isEmpty) {
      return _card(
        title: 'Worry Levels',
        subtitle: 'No worry entries yet this week',
        child: const SizedBox(
          height: 60,
          child: Center(
            child: Text('Log some worries to see your chart 💙',
                style: TextStyle(color: FabColors.muted, fontSize: 12)),
          ),
        ),
      );
    }

    return _card(
      title: 'Worry Intensity',
      subtitle: 'Last 7 days  (1 = tiny, 5 = huge)',
      child: SizedBox(
        height: 170,
        child: LineChart(
          LineChartData(
            minY: 0,
            maxY: 5,
            gridData: FlGridData(
              show: true,
              drawVerticalLine: false,
              horizontalInterval: 1,
              getDrawingHorizontalLine: (_) => FlLine(
                color: Colors.white.withValues(alpha: 0.06),
                strokeWidth: 1,
              ),
            ),
            borderData: FlBorderData(show: false),
            titlesData: FlTitlesData(
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  interval: 1,
                  reservedSize: 24,
                  getTitlesWidget: (v, _) => Text('${v.toInt()}',
                      style: const TextStyle(
                          color: FabColors.muted, fontSize: 10)),
                ),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 22,
                  getTitlesWidget: (v, _) {
                    final day = DateTime.now()
                        .subtract(Duration(days: 6 - v.toInt()));
                    const labels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
                    return Text(
                      labels[day.weekday - 1],
                      style: const TextStyle(
                          color: FabColors.muted, fontSize: 10),
                    );
                  },
                ),
              ),
              topTitles:   AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            ),
            lineBarsData: [
              LineChartBarData(
                spots: spots,
                isCurved: true,
                color: _purple,
                barWidth: 3,
                dotData: FlDotData(
                  show: true,
                  getDotPainter: (spot, _, __, ___) => FlDotCirclePainter(
                    radius: 4,
                    color: _purple,
                    strokeWidth: 2,
                    strokeColor: FabColors.bg,
                  ),
                ),
                belowBarData: BarAreaData(
                  show: true,
                  color: _purple.withValues(alpha: 0.12),
                ),
              ),
            ],
            lineTouchData: LineTouchData(
              touchTooltipData: LineTouchTooltipData(
                getTooltipColor: (_) => FabColors.panel2,
                getTooltipItems: (spots) => spots.map((s) {
                  return LineTooltipItem(
                    'Intensity ${s.y.toStringAsFixed(1)}/5',
                    const TextStyle(
                        color: _purple,
                        fontSize: 12,
                        fontWeight: FontWeight.w600),
                  );
                }).toList(),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── Mood trend line ────────────────────────────────────────

  Widget _buildMoodChart() {
    final spots = _moodSpots;
    if (spots.isEmpty) {
      return _card(
        title: 'Mood Trend',
        subtitle: 'No check-ins yet this week',
        child: const SizedBox(
          height: 60,
          child: Center(
            child: Text('Do your daily check-in to see this chart 🌟',
                style: TextStyle(color: FabColors.muted, fontSize: 12)),
          ),
        ),
      );
    }

    const moodEmojis = ['😢', '😕', '😐', '😊', '🤩'];

    return _card(
      title: 'Mood Trend',
      subtitle: 'Last 7 days  (higher = happier)',
      child: SizedBox(
        height: 170,
        child: LineChart(
          LineChartData(
            minY: 0,
            maxY: 4,
            gridData: FlGridData(
              show: true,
              drawVerticalLine: false,
              horizontalInterval: 1,
              getDrawingHorizontalLine: (_) => FlLine(
                color: Colors.white.withValues(alpha: 0.06),
                strokeWidth: 1,
              ),
            ),
            borderData: FlBorderData(show: false),
            titlesData: FlTitlesData(
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  interval: 1,
                  reservedSize: 28,
                  getTitlesWidget: (v, _) => Text(
                    moodEmojis[v.toInt().clamp(0, 4)],
                    style: const TextStyle(fontSize: 11),
                  ),
                ),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 22,
                  getTitlesWidget: (v, _) {
                    final day = DateTime.now()
                        .subtract(Duration(days: 6 - v.toInt()));
                    const labels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
                    return Text(
                      labels[day.weekday - 1],
                      style: const TextStyle(
                          color: FabColors.muted, fontSize: 10),
                    );
                  },
                ),
              ),
              topTitles:   AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            ),
            lineBarsData: [
              LineChartBarData(
                spots: spots,
                isCurved: true,
                color: _amber,
                barWidth: 3,
                dotData: FlDotData(
                  show: true,
                  getDotPainter: (spot, _, __, ___) => FlDotCirclePainter(
                    radius: 4,
                    color: _amber,
                    strokeWidth: 2,
                    strokeColor: FabColors.bg,
                  ),
                ),
                belowBarData: BarAreaData(
                  show: true,
                  color: _amber.withValues(alpha: 0.12),
                ),
              ),
            ],
            lineTouchData: LineTouchData(
              touchTooltipData: LineTouchTooltipData(
                getTooltipColor: (_) => FabColors.panel2,
                getTooltipItems: (spots) => spots.map((s) {
                  final idx = s.y.round().clamp(0, 4);
                  const labels = ['Sad', 'Not great', 'Okay', 'Good', 'Amazing!'];
                  return LineTooltipItem(
                    '${moodEmojis[idx]} ${labels[idx]}',
                    const TextStyle(
                        color: _amber,
                        fontSize: 12,
                        fontWeight: FontWeight.w600),
                  );
                }).toList(),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── Sleep duration bar chart ───────────────────────────────

  Widget _buildSleepChart() {
    final bars   = _sleepBars;
    final maxH   = bars.map((b) => b.hours).fold(0.0, (a, b) => a > b ? a : b);
    final chartMax = maxH < 8 ? 10.0 : maxH + 1;

    return _card(
      title: 'Sleep Duration',
      subtitle: 'Last 7 nights — tap a bar for details',
      child: SizedBox(
        height: 180,
        child: BarChart(
          BarChartData(
            maxY: chartMax,
            gridData: FlGridData(
              show: true,
              drawVerticalLine: false,
              horizontalInterval: 2,
              getDrawingHorizontalLine: (_) => FlLine(
                color: Colors.white.withValues(alpha: 0.06),
                strokeWidth: 1,
              ),
            ),
            borderData: FlBorderData(show: false),
            titlesData: FlTitlesData(
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  interval: 2,
                  reservedSize: 28,
                  getTitlesWidget: (v, _) => Text('${v.toInt()}h',
                      style: const TextStyle(
                          color: FabColors.muted, fontSize: 9)),
                ),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 20,
                  getTitlesWidget: (v, _) {
                    final day = DateTime.now()
                        .subtract(Duration(days: 6 - v.toInt()));
                    const labels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
                    return Text(
                      labels[day.weekday - 1],
                      style: const TextStyle(
                          color: FabColors.muted, fontSize: 10),
                    );
                  },
                ),
              ),
              topTitles:   AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            ),
            barGroups: bars.map((b) {
              final color = b.hours == 0
                  ? FabColors.muted.withValues(alpha: 0.25)
                  : b.hours >= 9
                      ? _teal
                      : b.hours >= 7
                          ? _teal.withValues(alpha: 0.65)
                          : b.hours >= 5
                              ? _amber
                              : _pink;
              return BarChartGroupData(
                x: b.dayIndex,
                barRods: [
                  BarChartRodData(
                    toY: b.hours,
                    color: color,
                    width: 18,
                    borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(6)),
                    backDrawRodData: BackgroundBarChartRodData(
                      show: true,
                      toY: chartMax,
                      color: Colors.white.withValues(alpha: 0.04),
                    ),
                  ),
                ],
              );
            }).toList(),
            barTouchData: BarTouchData(
              touchTooltipData: BarTouchTooltipData(
                getTooltipColor: (_) => FabColors.panel2,
                getTooltipItem: (group, _, rod, __) {
                  final b = bars[group.x];
                  if (b.hours == 0) {
                    return BarTooltipItem(
                      'No sleep data\nlogged',
                      const TextStyle(
                          color: FabColors.muted,
                          fontSize: 11,
                          height: 1.4),
                    );
                  }
                  final durLabel = b.hours > 0
                      ? '${b.hours.toStringAsFixed(1)}h'
                      : '—';
                  final detail = (b.bedtime != null && b.wakeTime != null)
                      ? '\n🌙 ${_fmtTime(b.bedtime!)}  →  ☀️ ${_fmtTime(b.wakeTime!)}'
                      : '';
                  return BarTooltipItem(
                    '$durLabel$detail',
                    const TextStyle(
                        color: _teal,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        height: 1.5),
                  );
                },
              ),
            ),
          ),
        ),
      ),
      legend: Row(children: [
        _legendDot(_teal), const SizedBox(width: 4),
        const Text('9h+', style: TextStyle(color: FabColors.muted, fontSize: 10)),
        const SizedBox(width: 8),
        _legendDot(_amber), const SizedBox(width: 4),
        const Text('5–8h', style: TextStyle(color: FabColors.muted, fontSize: 10)),
        const SizedBox(width: 8),
        _legendDot(_pink), const SizedBox(width: 4),
        const Text('<5h', style: TextStyle(color: FabColors.muted, fontSize: 10)),
      ]),
    );
  }

  // ── Body symptoms horizontal bars ─────────────────────────

  Widget _buildBodySymptoms() {
    final freq = _bodyFrequency;
    if (freq.isEmpty) {
      return _card(
        title: 'Body Feelings',
        subtitle: 'Log worries to see body symptoms',
        child: const SizedBox(
          height: 40,
          child: Center(
            child: Text('No body sensations logged yet 🌈',
                style: TextStyle(color: FabColors.muted, fontSize: 12)),
          ),
        ),
      );
    }

    final maxCount = freq.first.value;
    const barColors = [_pink, _purple, _teal, _amber, FabColors.rose, _pink];

    return _card(
      title: 'Body Feelings',
      subtitle: 'Most common sensations when worried',
      child: Column(
        children: List.generate(freq.length, (i) {
          final item  = freq[i];
          final pct   = item.value / maxCount;
          final color = barColors[i % barColors.length];
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 5),
            child: Row(children: [
              SizedBox(
                width: 110,
                child: Text(
                  item.key,
                  style: const TextStyle(
                      color: FabColors.text, fontSize: 12),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(5),
                  child: LinearProgressIndicator(
                    value: pct,
                    backgroundColor: FabColors.panel2,
                    valueColor: AlwaysStoppedAnimation(color),
                    minHeight: 10,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text('${item.value}×',
                  style: const TextStyle(
                      color: FabColors.muted, fontSize: 11)),
            ]),
          );
        }),
      ),
    );
  }

  // ── PDA flags this week vs last week ──────────────────────

  Widget _buildPdaFlags() {
    final counts = _pdaCounts;
    final anyData = counts.any((c) => c[0] > 0 || c[1] > 0);

    if (!anyData) {
      return _card(
        title: 'PDA Observations',
        subtitle: 'This week vs last week',
        child: const SizedBox(
          height: 40,
          child: Center(
            child: Text('No PDA flags logged yet — parents can add these 🌿',
                style: TextStyle(color: FabColors.muted, fontSize: 12)),
          ),
        ),
      );
    }

    final maxCount = counts
        .expand((c) => c)
        .fold(0, (a, b) => a > b ? a : b)
        .toDouble()
        .clamp(1, double.infinity);

    return _card(
      title: 'PDA Observations',
      subtitle: 'This week vs last week — from parent notes',
      legend: Row(children: [
        _legendDot(_purple), const SizedBox(width: 4),
        const Text('This week', style: TextStyle(color: FabColors.muted, fontSize: 10)),
        const SizedBox(width: 10),
        _legendDot(FabColors.muted.withValues(alpha: 0.5)), const SizedBox(width: 4),
        const Text('Last week', style: TextStyle(color: FabColors.muted, fontSize: 10)),
      ]),
      child: SizedBox(
        height: 180,
        child: BarChart(
          BarChartData(
            maxY: maxCount + 1,
            groupsSpace: 14,
            gridData: FlGridData(
              show: true,
              drawVerticalLine: false,
              horizontalInterval: 1,
              getDrawingHorizontalLine: (_) => FlLine(
                color: Colors.white.withValues(alpha: 0.06),
                strokeWidth: 1,
              ),
            ),
            borderData: FlBorderData(show: false),
            titlesData: FlTitlesData(
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  interval: 1,
                  reservedSize: 20,
                  getTitlesWidget: (v, _) => Text('${v.toInt()}',
                      style: const TextStyle(
                          color: FabColors.muted, fontSize: 10)),
                ),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 30,
                  getTitlesWidget: (v, _) {
                    final labels = ['Demand\nrefused', 'Transition', 'Meltdown', 'Masking'];
                    return Text(
                      labels[v.toInt().clamp(0, 3)],
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          color: FabColors.muted, fontSize: 8, height: 1.3),
                    );
                  },
                ),
              ),
              topTitles:   AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            ),
            barGroups: List.generate(_pdaOptions.length, (i) {
              return BarChartGroupData(
                x: i,
                groupVertically: false,
                barRods: [
                  BarChartRodData(
                    toY: counts[i][0].toDouble(),
                    color: _pdaColors[i],
                    width: 14,
                    borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(4)),
                  ),
                  BarChartRodData(
                    toY: counts[i][1].toDouble(),
                    color: FabColors.muted.withValues(alpha: 0.35),
                    width: 14,
                    borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(4)),
                  ),
                ],
              );
            }),
            barTouchData: BarTouchData(
              touchTooltipData: BarTouchTooltipData(
                getTooltipColor: (_) => FabColors.panel2,
                getTooltipItem: (group, _, rod, rodIndex) {
                  final label = _pdaOptions[group.x];
                  final week  = rodIndex == 0 ? 'This week' : 'Last week';
                  return BarTooltipItem(
                    '$label\n$week: ${rod.toY.toInt()}',
                    TextStyle(
                        color: rodIndex == 0
                            ? _pdaColors[group.x]
                            : FabColors.muted,
                        fontSize: 11,
                        height: 1.4),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── Shared helpers ─────────────────────────────────────────

  Widget _card({
    required String title,
    required String subtitle,
    required Widget child,
    Widget? legend,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: FabColors.panel,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0x1EFF8FAB), width: 0.5),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title.toUpperCase(),
                    style: const TextStyle(
                        fontSize: 10,
                        color: FabColors.pink,
                        letterSpacing: 1.2,
                        fontWeight: FontWeight.w700)),
                const SizedBox(height: 2),
                Text(subtitle,
                    style: const TextStyle(
                        fontSize: 11, color: FabColors.muted)),
              ],
            ),
          ),
          if (legend != null) legend,
        ]),
        const SizedBox(height: 14),
        child,
      ]),
    );
  }

  Widget _legendDot(Color c) => Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(color: c, shape: BoxShape.circle));

  Widget _legendDash(Color c) => Container(
      width: 14,
      height: 2,
      decoration:
          BoxDecoration(color: c, borderRadius: BorderRadius.circular(1)));

  String _fmtTime(String hhmm) {
    final parts = hhmm.split(':');
    final h = int.parse(parts[0]);
    final m = int.parse(parts[1]);
    final suffix   = h < 12 ? 'AM' : 'PM';
    final displayH = h == 0 ? 12 : (h > 12 ? h - 12 : h);
    return '$displayH:${m.toString().padLeft(2, '0')} $suffix';
  }
}

// ── Data containers ──────────────────────────────────────────

class _SleepBar {
  final int dayIndex;
  final double hours;
  final int stars;
  final String? bedtime;
  final String? wakeTime;
  const _SleepBar({
    required this.dayIndex,
    required this.hours,
    required this.stars,
    this.bedtime,
    this.wakeTime,
  });
}
