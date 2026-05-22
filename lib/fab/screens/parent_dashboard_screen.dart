import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/models/check_in_entry.dart';
import '../../core/repositories/check_in_repository.dart';
import 'clinician_export_screen.dart';
import 'senco_report_screen.dart';

// ─────────────────────────────────────────────────────────────
// PARENT DASHBOARD SCREEN
// 7-day summary read from CheckInRepository.
// Sections: summary stats, pain trend chart, recent entries,
//           high-pain alerts, quick-action PDF button.
// ─────────────────────────────────────────────────────────────

class ParentDashboardScreen extends StatefulWidget {
  const ParentDashboardScreen({super.key});

  @override
  State<ParentDashboardScreen> createState() => _ParentDashboardScreenState();
}

class _ParentDashboardScreenState extends State<ParentDashboardScreen> {
  final _repo = CheckInRepository();

  List<CheckInEntry> _week   = []; // last 7 days, all entry types
  List<CheckInEntry> _pain   = []; // non check-in entries in last 7 days
  List<CheckInEntry> _recent = []; // last 5 pain entries overall
  bool _loading = true;

  // ── Colours ──────────────────────────────────────────────────
  static const _bg     = Color(0xFF0B0D1E);
  static const _panel  = Color(0xFF111527);
  static const _border = Color(0xFF1C2040);
  static const _text   = Color(0xFFF2EFFF);
  static const _muted  = Color(0xFF8A8EAB);
  static const _pink   = Color(0xFFFF6FB0);
  static const _blue   = Color(0xFF5DADEC);
  static const _purple = Color(0xFF9B7DFF);
  static const _amber  = Color(0xFFFFB830);
  static const _red    = Color(0xFFFF4D4D);
  static const _green  = Color(0xFF4CAF50);

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final all = await _repo.getAllEntries();
    if (!mounted) return;

    final cutoff = DateTime.now().subtract(const Duration(days: 7));
    final week   = all.where((e) => e.date.isAfter(cutoff)).toList();
    final pain   = week.where((e) => !e.id.startsWith('checkin_')).toList();

    // last 5 pain entries overall (most recent first)
    final allPain = all.where((e) => !e.id.startsWith('checkin_')).toList();
    allPain.sort((a, b) => b.date.compareTo(a.date));
    final recent = allPain.take(5).toList();

    setState(() {
      _week   = week;
      _pain   = pain;
      _recent = recent;
      _loading = false;
    });
  }

  // ── Derived stats ─────────────────────────────────────────────

  double get _avgPain {
    if (_pain.isEmpty) return 0;
    return _pain.map((e) => e.painRating).reduce((a, b) => a + b) / _pain.length;
  }

  double get _avgNerve {
    if (_pain.isEmpty) return 0;
    return _pain.map((e) => e.nerveSymptomRating).reduce((a, b) => a + b) /
        _pain.length;
  }

  int get _checkInCount =>
      _week.where((e) => e.id.startsWith('checkin_')).length;

  List<String> get _topZones {
    final freq = <String, int>{};
    for (final e in _pain) {
      for (final z in e.painLocations) {
        freq[z] = (freq[z] ?? 0) + 1;
      }
    }
    final sorted = freq.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return sorted.take(3).map((e) => e.key).toList();
  }

  List<String> get _topTriggers {
    final freq = <String, int>{};
    for (final e in _pain) {
      for (final t in e.triggers) {
        freq[t] = (freq[t] ?? 0) + 1;
      }
    }
    final sorted = freq.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return sorted.take(3).map((e) => e.key).toList();
  }

  String get _mostCommonMood {
    final checkIns = _week.where((e) => e.id.startsWith('checkin_')).toList();
    final freq = <String, int>{};
    for (final e in checkIns) {
      final match = RegExp(r'Mood: (.+)').firstMatch(e.notes);
      if (match != null) {
        final m = match.group(1)!.trim();
        freq[m] = (freq[m] ?? 0) + 1;
      }
    }
    if (freq.isEmpty) return '—';
    return freq.entries
        .reduce((a, b) => a.value >= b.value ? a : b)
        .key;
  }

  // ── 7-day chart spots ─────────────────────────────────────────

  List<FlSpot> get _painSpots {
    final spots = <FlSpot>[];
    for (int i = 6; i >= 0; i--) {
      final day = DateTime.now().subtract(Duration(days: i));
      final dayStr = day.toIso8601String().substring(0, 10);
      final entries = _pain
          .where((e) => e.date.toIso8601String().substring(0, 10) == dayStr)
          .toList();
      if (entries.isNotEmpty) {
        final avg = entries.map((e) => e.painRating).reduce((a, b) => a + b) /
            entries.length;
        spots.add(FlSpot((6 - i).toDouble(), avg));
      }
    }
    return spots;
  }

  List<CheckInEntry> get _highPainAlerts =>
      _pain.where((e) => e.painRating >= 8).toList()
        ..sort((a, b) => b.date.compareTo(a.date));

  // ── Build ──────────────────────────────────────────────────────

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
          'Parent Dashboard',
          style: TextStyle(color: _text, fontSize: 17, fontWeight: FontWeight.w700),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 14),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: _purple.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: _purple.withValues(alpha: 0.35)),
            ),
            child: const Text(
              'Last 7 days',
              style: TextStyle(color: _purple, fontSize: 11, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: _pink))
          : RefreshIndicator(
              color: _pink,
              backgroundColor: _panel,
              onRefresh: () async {
                setState(() => _loading = true);
                await _load();
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(18, 8, 18, 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSummaryCards(),
                    const SizedBox(height: 20),
                    _buildZonesTriggers(),
                    const SizedBox(height: 20),
                    _buildTrendChart(),
                    const SizedBox(height: 20),
                    if (_highPainAlerts.isNotEmpty) ...[
                      _buildAlerts(),
                      const SizedBox(height: 20),
                    ],
                    _buildRecentEntries(),
                    const SizedBox(height: 20),
                    _buildPdfButton(),
                    const SizedBox(height: 12),
                    _buildSencoButton(),
                    if (kDebugMode) ...[
                      const SizedBox(height: 12),
                      _buildClearDataButton(),
                    ],
                  ],
                ),
              ),
            ),
    );
  }

  // ── Summary stat cards ────────────────────────────────────────

  Widget _buildSummaryCards() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _statCard('Avg Pain', _avgPain.toStringAsFixed(1), '/10', _painColor(_avgPain), Icons.thermostat_rounded)),
            const SizedBox(width: 10),
            Expanded(child: _statCard('Avg Nerve', _avgNerve.toStringAsFixed(1), '/10', _blue, Icons.electric_bolt_rounded)),
            const SizedBox(width: 10),
            Expanded(child: _statCard('Check-ins', '$_checkInCount', '/7 days', _green, Icons.check_circle_rounded)),
          ],
        ),
        const SizedBox(height: 10),
        _moodCard(),
      ],
    );
  }

  Widget _statCard(String label, String value, String suffix, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _panel,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(height: 8),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: value,
                  style: TextStyle(
                    color: color,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                TextSpan(
                  text: suffix,
                  style: TextStyle(
                    color: _muted,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(color: _muted, fontSize: 11)),
        ],
      ),
    );
  }

  Widget _moodCard() {
    final mood = _mostCommonMood;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: _panel,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _border),
      ),
      child: Row(
        children: [
          const Icon(Icons.mood_rounded, color: _pink, size: 20),
          const SizedBox(width: 10),
          const Text('Most common mood', style: TextStyle(color: _muted, fontSize: 13)),
          const Spacer(),
          Text(
            mood,
            style: const TextStyle(color: _text, fontSize: 14, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }

  // ── Top zones + triggers ──────────────────────────────────────

  Widget _buildZonesTriggers() {
    final zones    = _topZones;
    final triggers = _topTriggers;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: _listPanel('Most affected', Icons.location_on_rounded, _blue, zones, 'No zones logged')),
        const SizedBox(width: 10),
        Expanded(child: _listPanel('Top triggers', Icons.warning_amber_rounded, _amber, triggers, 'No triggers logged')),
      ],
    );
  }

  Widget _listPanel(String title, IconData icon, Color color, List<String> items, String empty) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _panel,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(icon, color: color, size: 15),
            const SizedBox(width: 6),
            Text(title, style: const TextStyle(color: _text, fontSize: 12, fontWeight: FontWeight.w700)),
          ]),
          const SizedBox(height: 10),
          if (items.isEmpty)
            Text(empty, style: const TextStyle(color: _muted, fontSize: 11))
          else
            ...items.asMap().entries.map((e) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(children: [
                Container(
                  width: 18,
                  height: 18,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Center(
                    child: Text(
                      '${e.key + 1}',
                      style: TextStyle(color: color, fontSize: 9, fontWeight: FontWeight.w800),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(e.value, style: const TextStyle(color: _muted, fontSize: 11), overflow: TextOverflow.ellipsis),
                ),
              ]),
            )),
        ],
      ),
    );
  }

  // ── 7-day pain trend chart ────────────────────────────────────

  Widget _buildTrendChart() {
    final spots = _painSpots;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
      decoration: BoxDecoration(
        color: _panel,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            const Icon(Icons.show_chart_rounded, color: _pink, size: 18),
            const SizedBox(width: 8),
            const Text('7-day pain trend', style: TextStyle(color: _text, fontSize: 14, fontWeight: FontWeight.w700)),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: _pink.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Row(children: [
                Icon(Icons.circle, color: _pink, size: 7),
                SizedBox(width: 4),
                Text('Pain', style: TextStyle(color: _pink, fontSize: 10, fontWeight: FontWeight.w600)),
              ]),
            ),
          ]),
          const SizedBox(height: 16),
          if (spots.isEmpty)
            SizedBox(
              height: 100,
              child: Center(
                child: Text('No pain entries in last 7 days',
                    style: TextStyle(color: _muted.withValues(alpha: 0.60), fontSize: 13)),
              ),
            )
          else
            SizedBox(
              height: 120,
              child: LineChart(
                LineChartData(
                  minX: 0,
                  maxX: 6,
                  minY: 0,
                  maxY: 10,
                  clipData: const FlClipData.all(),
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: 5,
                    getDrawingHorizontalLine: (_) => FlLine(
                      color: Colors.white.withValues(alpha: 0.06),
                      strokeWidth: 1,
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  titlesData: FlTitlesData(
                    leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (x, _) {
                          final day = DateTime.now().subtract(Duration(days: 6 - x.toInt()));
                          const labels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
                          return Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Text(
                              labels[day.weekday - 1],
                              style: const TextStyle(color: _muted, fontSize: 9),
                            ),
                          );
                        },
                        reservedSize: 22,
                      ),
                    ),
                  ),
                  lineTouchData: LineTouchData(
                    touchTooltipData: LineTouchTooltipData(
                      getTooltipColor: (_) => const Color(0xFF1C2040),
                      getTooltipItems: (spots) => spots
                          .map((s) => LineTooltipItem(
                                s.y.toStringAsFixed(1),
                                const TextStyle(
                                  color: _pink,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                ),
                              ))
                          .toList(),
                    ),
                  ),
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: true,
                      curveSmoothness: 0.35,
                      color: _pink,
                      barWidth: 2.5,
                      dotData: FlDotData(
                        show: true,
                        getDotPainter: (spot, _, __, ___) => FlDotCirclePainter(
                          radius: 3.5,
                          color: spot.y >= 8 ? _red : _pink,
                          strokeWidth: 1.5,
                          strokeColor: _bg,
                        ),
                      ),
                      belowBarData: BarAreaData(
                        show: true,
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            _pink.withValues(alpha: 0.22),
                            _pink.withValues(alpha: 0.00),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ── High-pain alerts ──────────────────────────────────────────

  Widget _buildAlerts() {
    final alerts = _highPainAlerts;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _red.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _red.withValues(alpha: 0.30)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            const Icon(Icons.warning_rounded, color: _red, size: 18),
            const SizedBox(width: 8),
            Text(
              'High pain alert${alerts.length > 1 ? 's' : ''} — last 7 days',
              style: const TextStyle(color: _red, fontSize: 14, fontWeight: FontWeight.w700),
            ),
          ]),
          const SizedBox(height: 4),
          Text(
            'Pain scored 8 or above — consider speaking to a clinician.',
            style: TextStyle(color: _red.withValues(alpha: 0.70), fontSize: 12),
          ),
          const SizedBox(height: 12),
          ...alerts.map((e) => _alertRow(e)),
        ],
      ),
    );
  }

  Widget _alertRow(CheckInEntry e) {
    final d = e.date;
    final dateStr = '${_weekday(d.weekday)} ${d.day}/${d.month}';
    final top = e.symptoms.isNotEmpty ? e.symptoms.first : (e.painLocations.isNotEmpty ? e.painLocations.first : '');

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: _red.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _red.withValues(alpha: 0.22)),
      ),
      child: Row(children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(dateStr, style: TextStyle(color: _red.withValues(alpha: 0.80), fontSize: 11, fontWeight: FontWeight.w600)),
              if (top.isNotEmpty)
                Text(top, style: TextStyle(color: _muted, fontSize: 11), overflow: TextOverflow.ellipsis),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: _red.withValues(alpha: 0.18),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: _red.withValues(alpha: 0.40)),
          ),
          child: Text(
            '${e.painRating}/10',
            style: const TextStyle(color: _red, fontSize: 14, fontWeight: FontWeight.w800),
          ),
        ),
      ]),
    );
  }

  // ── Recent entries list ───────────────────────────────────────

  Widget _buildRecentEntries() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Recent entries', style: TextStyle(color: _text, fontSize: 14, fontWeight: FontWeight.w700)),
        const SizedBox(height: 10),
        if (_recent.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: _panel,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: _border),
            ),
            child: const Text(
              'No pain entries logged yet.',
              textAlign: TextAlign.center,
              style: TextStyle(color: _muted, fontSize: 13),
            ),
          )
        else
          ..._recent.map((e) => _entryRow(e)),
      ],
    );
  }

  Widget _entryRow(CheckInEntry e) {
    final d = e.date;
    final dateStr = '${_weekday(d.weekday)} ${d.day}/${d.month}/${d.year}';
    final topSymptom = e.symptoms.isNotEmpty ? e.symptoms.first : (e.painLocations.isNotEmpty ? e.painLocations.first : '—');

    // extract mood from check-in note if it's a check-in entry
    String? mood;
    if (e.id.startsWith('checkin_')) {
      final m = RegExp(r'Mood: (.+)').firstMatch(e.notes);
      if (m != null) mood = m.group(1)!.trim();
    }

    final Color scoreColor = _painColor(e.painRating.toDouble());
    final bool isHigh = e.painRating >= 8;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _panel,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isHigh ? _red.withValues(alpha: 0.35) : _border,
        ),
      ),
      child: Row(children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: scoreColor.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: scoreColor.withValues(alpha: 0.30)),
          ),
          child: Center(
            child: Text(
              '${e.painRating}',
              style: TextStyle(color: scoreColor, fontSize: 18, fontWeight: FontWeight.w800),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(dateStr, style: const TextStyle(color: _muted, fontSize: 11)),
              const SizedBox(height: 3),
              Text(
                topSymptom,
                style: const TextStyle(color: _text, fontSize: 13, fontWeight: FontWeight.w600),
                overflow: TextOverflow.ellipsis,
              ),
              if (mood != null)
                Text('Mood: $mood', style: const TextStyle(color: _muted, fontSize: 11)),
            ],
          ),
        ),
        if (isHigh)
          const Icon(Icons.warning_amber_rounded, color: _red, size: 16),
      ]),
    );
  }

  // ── PDF quick action ──────────────────────────────────────────

  Widget _buildPdfButton() {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const ClinicianExportScreen()),
      ),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF5DADEC), Color(0xFF9B7DFF)],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: _blue.withValues(alpha: 0.25),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.picture_as_pdf_rounded, color: Colors.white, size: 22),
            SizedBox(width: 10),
            Text(
              'Generate GP / PIP PDF Report',
              style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSencoButton() {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const SencoReportScreen()),
      ),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF00C9A7), Color(0xFF5DADEC)],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF00C9A7).withValues(alpha: 0.25),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.school_rounded, color: Colors.white, size: 22),
            SizedBox(width: 10),
            Text(
              'School Report (SENCO)',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }

  // ── Dev: clear all data ───────────────────────────────────────

  Future<void> _clearAllData() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: _panel,
        title: const Text('Clear all test data?', style: TextStyle(color: _text)),
        content: const Text(
          'This removes every entry from nova_check_in_entries in SharedPreferences. '
          'Cannot be undone.',
          style: TextStyle(color: _muted),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel', style: TextStyle(color: _muted)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Clear', style: TextStyle(color: _red)),
          ),
        ],
      ),
    );
    if (confirm != true || !mounted) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('nova_check_in_entries');
    setState(() => _loading = true);
    await _load();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('All entries cleared'),
      backgroundColor: Color(0xFF1C2040),
    ));
  }

  Widget _buildClearDataButton() {
    return GestureDetector(
      onTap: _clearAllData,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: _red.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _red.withValues(alpha: 0.30)),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.delete_sweep_rounded, color: _red, size: 18),
            SizedBox(width: 8),
            Text(
              'DEV — Clear all test data',
              style: TextStyle(color: _red, fontSize: 13, fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }

  // ── Helpers ───────────────────────────────────────────────────

  Color _painColor(double score) {
    if (score <= 3) return _green;
    if (score <= 6) return _amber;
    if (score <= 7) return const Color(0xFFFF8C42);
    return _red;
  }

  String _weekday(int wd) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[(wd - 1).clamp(0, 6)];
  }
}
