import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/models/check_in_entry.dart';
import '../../core/repositories/check_in_repository.dart';
import '../fab_theme.dart';

// ─────────────────────────────────────────────────────────────
// FAB INSIGHTS SCREEN
// Reads from CheckInRepository. No data leaves the device.
// ─────────────────────────────────────────────────────────────

class FabInsightsScreen extends StatefulWidget {
  const FabInsightsScreen({super.key});

  @override
  State<FabInsightsScreen> createState() => _FabInsightsScreenState();
}

class _FabInsightsScreenState extends State<FabInsightsScreen> {
  final _repo = CheckInRepository();

  List<CheckInEntry> _entries = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final data = await _repo.getAllEntries(); // oldest-first
    if (!mounted) return;
    setState(() {
      _entries = data;
      _loading = false;
    });
  }

  // ── Derived stats ───────────────────────────────────────────

  double get _avgPain {
    if (_entries.isEmpty) return 0;
    return _entries.map((e) => e.painRating).reduce((a, b) => a + b) /
        _entries.length;
  }

  double get _avgNerve {
    if (_entries.isEmpty) return 0;
    return _entries.map((e) => e.nerveSymptomRating).reduce((a, b) => a + b) /
        _entries.length;
  }

  int get _highPainDays =>
      _entries.where((e) => e.painRating >= 7).length;

  // Most affected body zones (top 4)
  List<MapEntry<String, int>> get _topZones {
    final counts = <String, int>{};
    for (final e in _entries) {
      for (final loc in e.painLocations) {
        counts[loc] = (counts[loc] ?? 0) + 1;
      }
    }
    final sorted = counts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return sorted.take(4).toList();
  }

  // Most common symptoms (top 5)
  List<MapEntry<String, int>> get _topSymptoms {
    final counts = <String, int>{};
    for (final e in _entries) {
      for (final s in e.symptoms) {
        counts[s] = (counts[s] ?? 0) + 1;
      }
    }
    final sorted = counts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return sorted.take(5).toList();
  }

  // Most common triggers (top 5)
  List<MapEntry<String, int>> get _topTriggers {
    final counts = <String, int>{};
    for (final e in _entries) {
      for (final t in e.triggers) {
        counts[t] = (counts[t] ?? 0) + 1;
      }
    }
    final sorted = counts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return sorted.take(5).toList();
  }

  // Weekly buckets — last 4 weeks
  List<_WeekSummary> get _weeklyData {
    final now = DateTime.now();
    return List.generate(4, (i) {
      final weekStart = now.subtract(Duration(days: (3 - i) * 7 + now.weekday - 1));
      final weekEnd = weekStart.add(const Duration(days: 6));
      final week = _entries.where((e) =>
          !e.date.isBefore(weekStart) && !e.date.isAfter(weekEnd)).toList();
      return _WeekSummary(
        label: 'W${i + 1}',
        startDate: weekStart,
        entries: week,
      );
    });
  }

  // fl_chart spots for pain trend (last 14 entries max)
  List<FlSpot> get _painSpots {
    final recent = _entries.length > 14
        ? _entries.sublist(_entries.length - 14)
        : _entries;
    return List.generate(recent.length,
        (i) => FlSpot(i.toDouble(), recent[i].painRating.toDouble()));
  }

  List<FlSpot> get _nerveSpots {
    final recent = _entries.length > 14
        ? _entries.sublist(_entries.length - 14)
        : _entries;
    return List.generate(recent.length,
        (i) => FlSpot(i.toDouble(), recent[i].nerveSymptomRating.toDouble()));
  }

  // ── Build ───────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FabColors.bg,
      appBar: AppBar(
        backgroundColor: FabColors.mid,
        title: const Text('Insights',
            style: TextStyle(color: FabColors.pink, fontSize: 16)),
        iconTheme: const IconThemeData(color: FabColors.pink),
        elevation: 0,
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
          ? const Center(
              child: CircularProgressIndicator(color: FabColors.pink))
          : _entries.isEmpty
              ? _buildEmpty()
              : _buildContent(),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.insights_rounded, size: 64, color: FabColors.muted),
          const SizedBox(height: 16),
          const Text('No check-ins yet',
              style: TextStyle(color: FabColors.text, fontSize: 16)),
          const SizedBox(height: 8),
          const Text('Log a pain entry to see your insights here.',
              style: TextStyle(color: FabColors.muted, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return RefreshIndicator(
      color: FabColors.pink,
      backgroundColor: FabColors.panel,
      onRefresh: _load,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _buildSummaryCards(),
          const SizedBox(height: 16),
          _buildTrendChart(),
          const SizedBox(height: 16),
          _buildWeeklySummary(),
          const SizedBox(height: 16),
          _buildTopZones(),
          const SizedBox(height: 16),
          _buildTopSymptoms(),
          const SizedBox(height: 16),
          _buildTopTriggers(),
          const SizedBox(height: 24),
        ]),
      ),
    );
  }

  // ── Summary stat cards ──────────────────────────────────────

  Widget _buildSummaryCards() {
    return Row(children: [
      Expanded(child: _statCard(
        label: 'Avg Pain',
        value: _avgPain.toStringAsFixed(1),
        sub: 'out of 10',
        color: _levelColor(_avgPain.round()),
        icon: Icons.thermostat_rounded,
      )),
      const SizedBox(width: 10),
      Expanded(child: _statCard(
        label: 'Avg Nerve',
        value: _avgNerve.toStringAsFixed(1),
        sub: 'out of 10',
        color: const Color(0xFF7C4DFF),
        icon: Icons.electric_bolt_rounded,
      )),
      const SizedBox(width: 10),
      Expanded(child: _statCard(
        label: 'High Pain',
        value: '$_highPainDays',
        sub: 'days ≥ 7',
        color: FabColors.rose,
        icon: Icons.warning_amber_rounded,
      )),
      const SizedBox(width: 10),
      Expanded(child: _statCard(
        label: 'Entries',
        value: '${_entries.length}',
        sub: 'total',
        color: FabColors.teal,
        icon: Icons.edit_note_rounded,
      )),
    ]);
  }

  Widget _statCard({
    required String label,
    required String value,
    required String sub,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: FabColors.panel,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(height: 8),
        Text(value,
            style: TextStyle(
                color: color,
                fontSize: 22,
                fontWeight: FontWeight.w700)),
        Text(sub,
            style: const TextStyle(color: FabColors.muted, fontSize: 10)),
        const SizedBox(height: 4),
        Text(label.toUpperCase(),
            style: const TextStyle(
                color: FabColors.muted,
                fontSize: 9,
                letterSpacing: 1.1)),
      ]),
    );
  }

  // ── Pain + nerve trend chart ────────────────────────────────

  Widget _buildTrendChart() {
    final painSpots = _painSpots;
    final nerveSpots = _nerveSpots;
    if (painSpots.isEmpty) return const SizedBox.shrink();

    return _card(
      title: 'Pain Trend',
      subtitle: 'Last ${painSpots.length} entries',
      child: SizedBox(
        height: 180,
        child: LineChart(
          LineChartData(
            minY: 0,
            maxY: 10,
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
                  getTitlesWidget: (v, _) => Text(
                    '${v.toInt()}',
                    style: const TextStyle(
                        color: FabColors.muted, fontSize: 10),
                  ),
                ),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              topTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false)),
              rightTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false)),
            ),
            lineBarsData: [
              // Pain line — rose
              LineChartBarData(
                spots: painSpots,
                isCurved: true,
                color: FabColors.rose,
                barWidth: 2.5,
                dotData: FlDotData(
                  show: true,
                  getDotPainter: (spot, _, __, ___) => FlDotCirclePainter(
                    radius: 3,
                    color: FabColors.rose,
                    strokeWidth: 1.5,
                    strokeColor: FabColors.bg,
                  ),
                ),
                belowBarData: BarAreaData(
                  show: true,
                  color: FabColors.rose.withValues(alpha: 0.10),
                ),
              ),
              // Nerve line — purple
              if (nerveSpots.any((s) => s.y > 0))
                LineChartBarData(
                  spots: nerveSpots,
                  isCurved: true,
                  color: const Color(0xFF7C4DFF),
                  barWidth: 2,
                  dashArray: [5, 4],
                  dotData: FlDotData(show: false),
                  belowBarData: BarAreaData(
                    show: true,
                    color: const Color(0xFF7C4DFF).withValues(alpha: 0.07),
                  ),
                ),
            ],
            lineTouchData: LineTouchData(
              touchTooltipData: LineTouchTooltipData(
                getTooltipColor: (_) => FabColors.panel2,
                getTooltipItems: (spots) => spots.map((s) {
                  final isNerve = s.barIndex == 1;
                  return LineTooltipItem(
                    isNerve
                        ? 'Nerve ${s.y.toInt()}'
                        : 'Pain ${s.y.toInt()}',
                    TextStyle(
                      color: isNerve
                          ? const Color(0xFF7C4DFF)
                          : FabColors.rose,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ),
      ),
      legend: Row(children: [
        _legendDot(FabColors.rose), const SizedBox(width: 4),
        const Text('Pain', style: TextStyle(color: FabColors.muted, fontSize: 11)),
        const SizedBox(width: 12),
        _legendDash(const Color(0xFF7C4DFF)), const SizedBox(width: 4),
        const Text('Nerve', style: TextStyle(color: FabColors.muted, fontSize: 11)),
      ]),
    );
  }

  Widget _legendDot(Color c) => Container(
      width: 10, height: 10,
      decoration: BoxDecoration(color: c, shape: BoxShape.circle));

  Widget _legendDash(Color c) => Container(
      width: 14, height: 2,
      decoration: BoxDecoration(
          color: c, borderRadius: BorderRadius.circular(1)));

  // ── Weekly summary ──────────────────────────────────────────

  Widget _buildWeeklySummary() {
    final weeks = _weeklyData;
    return _card(
      title: 'Weekly Summary',
      subtitle: 'Last 4 weeks',
      child: Column(
        children: weeks.map((week) {
          if (week.entries.isEmpty) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(children: [
                SizedBox(
                  width: 28,
                  child: Text(week.label,
                      style: const TextStyle(
                          color: FabColors.muted, fontSize: 11,
                          fontWeight: FontWeight.w600)),
                ),
                const SizedBox(width: 8),
                const Text('No entries',
                    style: TextStyle(color: FabColors.muted, fontSize: 12)),
              ]),
            );
          }
          final avgP = week.entries
                  .map((e) => e.painRating)
                  .reduce((a, b) => a + b) /
              week.entries.length;
          final maxP = week.entries
              .map((e) => e.painRating)
              .reduce((a, b) => a > b ? a : b);
          final color = _levelColor(avgP.round());
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(children: [
              SizedBox(
                width: 28,
                child: Text(week.label,
                    style: TextStyle(
                        color: color,
                        fontSize: 11,
                        fontWeight: FontWeight.w700)),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: avgP / 10,
                    backgroundColor: FabColors.panel2,
                    valueColor: AlwaysStoppedAnimation(color),
                    minHeight: 8,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              SizedBox(
                width: 60,
                child: Text(
                  'avg ${avgP.toStringAsFixed(1)}  ↑$maxP',
                  style: const TextStyle(
                      color: FabColors.muted, fontSize: 10),
                ),
              ),
              Text(
                '${week.entries.length}d',
                style: const TextStyle(
                    color: FabColors.muted, fontSize: 10),
              ),
            ]),
          );
        }).toList(),
      ),
    );
  }

  // ── Top zones bar chart ─────────────────────────────────────

  Widget _buildTopZones() {
    final zones = _topZones;
    if (zones.isEmpty) return const SizedBox.shrink();
    final max = zones.first.value;

    return _card(
      title: 'Most Affected Areas',
      subtitle: 'By number of entries',
      child: Column(
        children: zones.map((z) {
          final pct = z.value / max;
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 5),
            child: Row(children: [
              SizedBox(
                width: 110,
                child: Text(z.key,
                    style: const TextStyle(
                        color: FabColors.text, fontSize: 12)),
              ),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: pct,
                    backgroundColor: FabColors.panel2,
                    valueColor:
                        const AlwaysStoppedAnimation(FabColors.rose),
                    minHeight: 10,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text('${z.value}x',
                  style: const TextStyle(
                      color: FabColors.muted, fontSize: 11)),
            ]),
          );
        }).toList(),
      ),
    );
  }

  // ── Top symptoms ────────────────────────────────────────────

  Widget _buildTopSymptoms() {
    final items = _topSymptoms;
    if (items.isEmpty) return const SizedBox.shrink();
    final max = items.first.value;

    return _card(
      title: 'Common Symptoms',
      subtitle: 'Frequency across all entries',
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: items.map((s) {
          final pct = s.value / max;
          final alpha = 0.18 + pct * 0.45;
          return Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: FabColors.pink.withValues(alpha: alpha),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                  color: FabColors.pink.withValues(alpha: alpha + 0.15)),
            ),
            child: Text(
              '${s.key}  ${s.value}×',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.7 + pct * 0.3),
                fontSize: 12,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // ── Top triggers ────────────────────────────────────────────

  Widget _buildTopTriggers() {
    final items = _topTriggers;
    if (items.isEmpty) return const SizedBox.shrink();
    final max = items.first.value;

    return _card(
      title: 'Common Triggers',
      subtitle: 'What sets off pain most often',
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: items.map((t) {
          final pct = t.value / max;
          final alpha = 0.18 + pct * 0.45;
          return Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: FabColors.teal.withValues(alpha: alpha),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                  color: FabColors.teal.withValues(alpha: alpha + 0.15)),
            ),
            child: Text(
              '${t.key}  ${t.value}×',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.7 + pct * 0.3),
                fontSize: 12,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // ── Shared card wrapper ─────────────────────────────────────

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
            ]),
          ),
          if (legend != null) legend,
        ]),
        const SizedBox(height: 14),
        child,
      ]),
    );
  }

  // ── Utilities ───────────────────────────────────────────────

  Color _levelColor(int level) {
    if (level == 0) return FabColors.muted;
    if (level <= 3) return FabColors.teal;
    if (level <= 6) return FabColors.gold;
    if (level <= 8) return FabColors.rose;
    return const Color(0xFFFF1744);
  }
}

// ── Data models ──────────────────────────────────────────────

class _WeekSummary {
  final String label;
  final DateTime startDate;
  final List<CheckInEntry> entries;
  const _WeekSummary(
      {required this.label,
      required this.startDate,
      required this.entries});
}
