import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:nova_app/core/models/check_in_entry.dart';
import 'package:nova_app/core/repositories/check_in_repository.dart';

// Nova Comparison — time-series view of check-in metrics.
// Reads painRating, nerveSymptomRating, and medicationTaken
// from the local CheckInRepository (Hive 'checkins' box).
// All data is private and stays on device.

// ── Enums ─────────────────────────────────────────────────────────────────

enum _Range {
  week(label: '7 days', days: 7),
  month(label: '30 days', days: 30),
  threeMonths(label: '3 months', days: 90);

  const _Range({required this.label, required this.days});
  final String label;
  final int days;
}

enum _View { split, overlaid }

// ── Data classes ──────────────────────────────────────────────────────────

class _DataPoint {
  final int index;
  final String xLabel;
  final double? avgPain;
  final double? avgNerve;
  final double medRate; // 0.0–1.0 fraction of logged days medication was taken
  final bool hasMedData;
  final int count;

  const _DataPoint({
    required this.index,
    required this.xLabel,
    this.avgPain,
    this.avgNerve,
    required this.medRate,
    required this.hasMedData,
    required this.count,
  });
}

class _TrendData {
  final double? avg;
  final double? firstAvg;
  final double? secondAvg;
  const _TrendData({this.avg, this.firstAvg, this.secondAvg});
}

// ── Screen ────────────────────────────────────────────────────────────────

class ComparisonScreen extends StatefulWidget {
  const ComparisonScreen({super.key});

  @override
  State<ComparisonScreen> createState() => _ComparisonScreenState();
}

class _ComparisonScreenState extends State<ComparisonScreen> {
  // ── Palette ──────────────────────────────────────────────────
  static const _bg     = Color(0xFF0D1020);
  static const _panel  = Color(0xFF171A2E);
  static const _panel2 = Color(0xFF211C3A);
  static const _border = Color(0xFF252845);
  static const _text   = Color(0xFFF7F4FF);
  static const _muted  = Color(0xFFB9AECF);
  static const _rose   = Color(0xFFFF6FAE);
  static const _purple = Color(0xFF9B8FFF);
  static const _teal   = Color(0xFF46D6C8);
  static const _blue   = Color(0xFF5DADEC);
  static const _amber  = Color(0xFFFFC857);
  static const _green  = Color(0xFF7EC87A);

  // ── Label lookup tables ──────────────────────────────────────
  static const _dayLabels = [
    'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'
  ];
  static const _monthLabels = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
  ];

  // ── State ────────────────────────────────────────────────────
  List<CheckInEntry> _allEntries = [];
  bool _loading = true;
  _Range _range = _Range.month;
  _View _view = _View.split;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      if (!Hive.isBoxOpen('checkins')) {
        await Hive.openBox<Map>('checkins');
      }
      final entries = await CheckInRepository().getAllEntries();
      if (mounted) {
        setState(() {
          _allEntries = entries;
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  // ── Data helpers ─────────────────────────────────────────────

  List<CheckInEntry> get _filteredEntries {
    final today = DateTime.now();
    final cutoff = DateTime(today.year, today.month, today.day)
        .subtract(Duration(days: _range.days));
    return _allEntries.where((e) => !e.date.isBefore(cutoff)).toList();
  }

  bool get _isWeekly => _range == _Range.threeMonths;

  int get _bucketCount => _isWeekly ? 13 : _range.days;

  List<_DataPoint> _buildPoints() {
    final today = DateTime.now();
    final todayMid = DateTime(today.year, today.month, today.day);
    final n = _bucketCount;
    final weekly = _isWeekly;

    final painSums  = List.filled(n, 0.0);
    final nerveSums = List.filled(n, 0.0);
    final medTaken  = List.filled(n, 0);
    final medTotal  = List.filled(n, 0);
    final counts    = List.filled(n, 0);

    for (final e in _filteredEntries) {
      final eDay = DateTime(e.date.year, e.date.month, e.date.day);
      final diffDays = todayMid.difference(eDay).inDays;
      if (diffDays < 0) continue;

      final idx = weekly
          ? (n - 1) - (diffDays ~/ 7)
          : (n - 1) - diffDays;
      if (idx < 0 || idx >= n) continue;

      painSums[idx]  += e.painRating;
      nerveSums[idx] += e.nerveSymptomRating;
      if (e.medicationTaken != null) {
        medTotal[idx]++;
        if (e.medicationTaken!) medTaken[idx]++;
      }
      counts[idx]++;
    }

    return List.generate(n, (i) {
      // Bucket start date — used for x-axis labels only
      final bucketDate = weekly
          ? todayMid.subtract(Duration(days: (n - 1 - i) * 7 + 6))
          : todayMid.subtract(Duration(days: n - 1 - i));

      return _DataPoint(
        index: i,
        xLabel: _formatLabel(bucketDate),
        avgPain:  counts[i] > 0 ? painSums[i]  / counts[i] : null,
        avgNerve: counts[i] > 0 ? nerveSums[i] / counts[i] : null,
        medRate:  medTotal[i] > 0 ? medTaken[i] / medTotal[i] : 0.0,
        hasMedData: medTotal[i] > 0,
        count: counts[i],
      );
    });
  }

  String _formatLabel(DateTime d) {
    switch (_range) {
      case _Range.week:
        return _dayLabels[d.weekday - 1];
      case _Range.month:
        return '${d.day}';
      case _Range.threeMonths:
        return '${d.day} ${_monthLabels[d.month - 1]}';
    }
  }

  // ── Chart spot / bar builders ─────────────────────────────────

  List<FlSpot> _painSpots(List<_DataPoint> pts) => pts
      .map((p) => p.avgPain != null
          ? FlSpot(p.index.toDouble(), p.avgPain!)
          : FlSpot.nullSpot)
      .toList();

  List<FlSpot> _nerveSpots(List<_DataPoint> pts) => pts
      .map((p) => p.avgNerve != null
          ? FlSpot(p.index.toDouble(), p.avgNerve!)
          : FlSpot.nullSpot)
      .toList();

  List<BarChartGroupData> _medBars(List<_DataPoint> pts) => pts
      .map((p) => BarChartGroupData(
            x: p.index,
            barRods: [
              BarChartRodData(
                toY: p.hasMedData ? p.medRate * 100 : 0.0,
                color: p.hasMedData
                    ? _teal
                    : _teal.withValues(alpha: 0.12),
                width: _barWidth,
                borderRadius: BorderRadius.circular(3),
              ),
            ],
          ))
      .toList();

  double get _barWidth {
    switch (_range) {
      case _Range.week:         return 24.0;
      case _Range.month:        return  8.0;
      case _Range.threeMonths:  return 16.0;
    }
  }

  double get _xLabelInterval {
    switch (_range) {
      case _Range.week:         return 1.0;
      case _Range.month:        return 5.0;
      case _Range.threeMonths:  return 2.0;
    }
  }

  // ── Trend calculation ─────────────────────────────────────────

  _TrendData _trend(List<double?> values) {
    final v = values.whereType<double>().toList();
    if (v.isEmpty) return const _TrendData();
    final mid = (v.length / 2).ceil();
    final firstSlice  = v.take(mid).toList();
    final secondSlice = v.skip(mid).toList();
    final avg = v.reduce((a, b) => a + b) / v.length;
    final firstAvg  = firstSlice.isNotEmpty
        ? firstSlice.reduce((a, b) => a + b) / firstSlice.length
        : null;
    final secondAvg = secondSlice.isNotEmpty
        ? secondSlice.reduce((a, b) => a + b) / secondSlice.length
        : null;
    return _TrendData(avg: avg, firstAvg: firstAvg, secondAvg: secondAvg);
  }

  // ── Build ─────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        foregroundColor: _text,
        title: const Text(
          'Comparison',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        elevation: 0,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: _blue))
          : _buildBody(),
    );
  }

  Widget _buildBody() {
    final pts    = _buildPoints();
    final hasData = _filteredEntries.isNotEmpty;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
      children: [
        _buildRangeRow(),
        const SizedBox(height: 16),
        if (!hasData)
          _buildEmptyState()
        else ...[
          _buildViewToggle(),
          const SizedBox(height: 20),
          if (_view == _View.split)
            _buildSplitView(pts)
          else
            _buildOverlaidView(pts),
          const SizedBox(height: 28),
          _buildSummarySection(pts),
        ],
      ],
    );
  }

  // ── Range & view controls ─────────────────────────────────────

  Widget _buildRangeRow() {
    return Row(
      children: _Range.values.map((r) {
        final sel = _range == r;
        return Padding(
          padding: const EdgeInsets.only(right: 8),
          child: GestureDetector(
            onTap: () => setState(() => _range = r),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
              decoration: BoxDecoration(
                color: sel
                    ? _blue.withValues(alpha: 0.18)
                    : _panel,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: sel
                      ? _blue.withValues(alpha: 0.55)
                      : _border,
                ),
              ),
              child: Text(
                r.label,
                style: TextStyle(
                  color: sel ? _blue : _muted,
                  fontSize: 13,
                  fontWeight: sel ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildViewToggle() {
    return Row(
      children: [
        _ViewBtn(
          icon: Icons.view_agenda_outlined,
          label: 'Split',
          selected: _view == _View.split,
          accentColor: _blue,
          onTap: () => setState(() => _view = _View.split),
        ),
        const SizedBox(width: 10),
        _ViewBtn(
          icon: Icons.layers_outlined,
          label: 'Overlaid',
          selected: _view == _View.overlaid,
          accentColor: _blue,
          onTap: () => setState(() => _view = _View.overlaid),
        ),
      ],
    );
  }

  // ── Empty state ───────────────────────────────────────────────

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.only(top: 48),
      child: Column(
        children: [
          Icon(
            Icons.show_chart_rounded,
            color: _muted.withValues(alpha: 0.35),
            size: 60,
          ),
          const SizedBox(height: 18),
          const Text(
            'No check-ins in this period',
            style: TextStyle(
              color: _text,
              fontSize: 17,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Log pain, nerve symptoms, and medication notes\n'
            'in the Back Pain module to start seeing trends here.',
            style: TextStyle(color: _muted, fontSize: 14, height: 1.55),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 28),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: _panel,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: _border),
            ),
            child: const Text(
              'Tip: The Back Pain module records pain intensity, nerve symptoms, '
              'and whether you took medication. All three appear as charts here '
              'once you have at least one entry.',
              style: TextStyle(color: _muted, fontSize: 13, height: 1.5),
            ),
          ),
        ],
      ),
    );
  }

  // ── Split view ────────────────────────────────────────────────

  Widget _buildSplitView(List<_DataPoint> pts) {
    final hasMed = pts.any((p) => p.hasMedData);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionLabel('PAIN INTENSITY', _rose),
        const SizedBox(height: 10),
        _buildLineCard(
          spots: _painSpots(pts),
          color: _rose,
          pts: pts,
        ),
        const SizedBox(height: 22),
        _sectionLabel('NERVE SYMPTOMS', _purple),
        const SizedBox(height: 10),
        _buildLineCard(
          spots: _nerveSpots(pts),
          color: _purple,
          pts: pts,
        ),
        if (hasMed) ...[
          const SizedBox(height: 22),
          _sectionLabel('MEDICATION TAKEN', _teal),
          const SizedBox(height: 10),
          _buildMedCard(pts),
        ],
      ],
    );
  }

  // ── Overlaid view ─────────────────────────────────────────────

  Widget _buildOverlaidView(List<_DataPoint> pts) {
    final hasMed = pts.any((p) => p.hasMedData);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionLabel('PAIN & NERVE SYMPTOMS', _blue),
        const SizedBox(height: 8),
        Row(
          children: [
            _legendDot(_rose,   'Pain intensity'),
            const SizedBox(width: 16),
            _legendDot(_purple, 'Nerve symptoms'),
          ],
        ),
        const SizedBox(height: 10),
        _buildOverlaidCard(pts),
        if (hasMed) ...[
          const SizedBox(height: 22),
          _sectionLabel('MEDICATION TAKEN', _teal),
          const SizedBox(height: 10),
          _buildMedCard(pts),
        ],
      ],
    );
  }

  Widget _legendDot(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 9, height: 9,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 5),
        Text(
          label,
          style: const TextStyle(color: _muted, fontSize: 12),
        ),
      ],
    );
  }

  // ── Chart cards ───────────────────────────────────────────────

  Widget _buildLineCard({
    required List<FlSpot> spots,
    required Color color,
    required List<_DataPoint> pts,
  }) {
    final n = pts.length;
    return _card(
      child: SizedBox(
        height: 165,
        child: LineChart(
          LineChartData(
            minX: 0,
            maxX: (n - 1).toDouble(),
            minY: 0,
            maxY: 10,
            gridData: FlGridData(
              show: true,
              drawVerticalLine: false,
              horizontalInterval: 5,
              getDrawingHorizontalLine: (_) => FlLine(
                color: _border.withValues(alpha: 0.7),
                strokeWidth: 1,
              ),
            ),
            borderData: FlBorderData(show: false),
            titlesData: _lineTitles(pts, interval: _xLabelInterval),
            lineBarsData: [
              _lineBar(spots: spots, color: color),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOverlaidCard(List<_DataPoint> pts) {
    final n = pts.length;
    return _card(
      child: SizedBox(
        height: 190,
        child: LineChart(
          LineChartData(
            minX: 0,
            maxX: (n - 1).toDouble(),
            minY: 0,
            maxY: 10,
            gridData: FlGridData(
              show: true,
              drawVerticalLine: false,
              horizontalInterval: 5,
              getDrawingHorizontalLine: (_) => FlLine(
                color: _border.withValues(alpha: 0.7),
                strokeWidth: 1,
              ),
            ),
            borderData: FlBorderData(show: false),
            titlesData: _lineTitles(pts, interval: _xLabelInterval),
            lineBarsData: [
              _lineBar(
                spots: _painSpots(pts),
                color: _rose,
                fillAlpha: 0.12,
              ),
              _lineBar(
                spots: _nerveSpots(pts),
                color: _purple,
                fillAlpha: 0.10,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMedCard(List<_DataPoint> pts) {
    final n = pts.length;
    return _card(
      child: SizedBox(
        height: 135,
        child: BarChart(
          BarChartData(
            minY: 0,
            maxY: 100,
            barGroups: _medBars(pts),
            gridData: FlGridData(
              show: true,
              drawVerticalLine: false,
              horizontalInterval: 50,
              getDrawingHorizontalLine: (_) => FlLine(
                color: _border.withValues(alpha: 0.7),
                strokeWidth: 1,
              ),
            ),
            borderData: FlBorderData(show: false),
            titlesData: FlTitlesData(
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  interval: 50,
                  reservedSize: 34,
                  getTitlesWidget: (v, _) => Text(
                    '${v.toInt()}%',
                    style: const TextStyle(color: _muted, fontSize: 10.5),
                  ),
                ),
              ),
              rightTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false)),
              topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false)),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  interval: _xLabelInterval,
                  reservedSize: 22,
                  getTitlesWidget: (v, _) {
                    final i = v.toInt();
                    if (i < 0 || i >= n) return const SizedBox.shrink();
                    final intInterval = _xLabelInterval.toInt();
                    if (i % intInterval != 0) return const SizedBox.shrink();
                    return Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        pts[i].xLabel,
                        style: const TextStyle(color: _muted, fontSize: 10),
                      ),
                    );
                  },
                ),
              ),
            ),
            barTouchData: BarTouchData(
              enabled: true,
              touchTooltipData: BarTouchTooltipData(
                getTooltipColor: (_) => _panel2,
                getTooltipItem: (group, groupIndex, rod, rodIndex) {
                  final p = pts[group.x.toInt()];
                  if (!p.hasMedData) return null;
                  return BarTooltipItem(
                    '${(rod.toY).round()}%',
                    const TextStyle(color: _teal, fontWeight: FontWeight.w600),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── fl_chart helpers ──────────────────────────────────────────

  FlTitlesData _lineTitles(List<_DataPoint> pts, {required double interval}) {
    final n = pts.length;
    final intInterval = interval.toInt();
    return FlTitlesData(
      leftTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          interval: 5,
          reservedSize: 28,
          getTitlesWidget: (v, _) => Text(
            v.toInt().toString(),
            style: const TextStyle(color: _muted, fontSize: 10.5),
          ),
        ),
      ),
      rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false)),
      topTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false)),
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          interval: interval,
          reservedSize: 22,
          getTitlesWidget: (v, _) {
            final i = v.toInt();
            if (i < 0 || i >= n) return const SizedBox.shrink();
            if (i % intInterval != 0) return const SizedBox.shrink();
            return Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                pts[i].xLabel,
                style: const TextStyle(color: _muted, fontSize: 10),
              ),
            );
          },
        ),
      ),
    );
  }

  LineChartBarData _lineBar({
    required List<FlSpot> spots,
    required Color color,
    double fillAlpha = 0.22,
  }) {
    return LineChartBarData(
      spots: spots,
      color: color,
      barWidth: 2.5,
      isCurved: true,
      curveSmoothness: 0.3,
      preventCurveOverShooting: true,
      dotData: FlDotData(
        show: true,
        checkToShowDot: (spot, _) => !spot.isNull(),
        getDotPainter: (_, __, ___, ____) => FlDotCirclePainter(
          radius: 3,
          color: color,
          strokeWidth: 1.5,
          strokeColor: _panel,
        ),
      ),
      belowBarData: BarAreaData(
        show: true,
        gradient: LinearGradient(
          colors: [
            color.withValues(alpha: fillAlpha),
            color.withValues(alpha: 0.0),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
    );
  }

  // ── Summary section ───────────────────────────────────────────

  Widget _buildSummarySection(List<_DataPoint> pts) {
    final painT  = _trend(pts.map((p) => p.avgPain).toList());
    final nerveT = _trend(pts.map((p) => p.avgNerve).toList());

    final medPts = pts.where((p) => p.hasMedData).toList();
    final medAdherence = medPts.isEmpty
        ? null
        : medPts.map((p) => p.medRate).reduce((a, b) => a + b) / medPts.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionLabel('TREND SUMMARY', _amber),
        const SizedBox(height: 12),

        _card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _summaryRow(
                icon: Icons.edit_note_rounded,
                color: _blue,
                label: 'Check-ins',
                value: '${_filteredEntries.length} '
                    'entr${_filteredEntries.length == 1 ? 'y' : 'ies'} '
                    'in ${_range.label}',
              ),

              if (painT.avg != null) ...[
                const _Divider(),
                _summaryRow(
                  icon: Icons.accessibility_new_rounded,
                  color: _rose,
                  label: 'Pain average',
                  value: '${painT.avg!.toStringAsFixed(1)} / 10',
                ),
                if (painT.firstAvg != null && painT.secondAvg != null)
                  _trendArrow(
                    first: painT.firstAvg!,
                    second: painT.secondAvg!,
                    lowerIsBetter: true,
                  ),
              ],

              if (nerveT.avg != null) ...[
                const _Divider(),
                _summaryRow(
                  icon: Icons.electric_bolt_rounded,
                  color: _purple,
                  label: 'Nerve average',
                  value: '${nerveT.avg!.toStringAsFixed(1)} / 10',
                ),
                if (nerveT.firstAvg != null && nerveT.secondAvg != null)
                  _trendArrow(
                    first: nerveT.firstAvg!,
                    second: nerveT.secondAvg!,
                    lowerIsBetter: true,
                  ),
              ],

              if (medAdherence != null) ...[
                const _Divider(),
                _summaryRow(
                  icon: Icons.medication_rounded,
                  color: _teal,
                  label: 'Medication adherence',
                  value: '${(medAdherence * 100).round()}% of logged days',
                ),
              ],

              const SizedBox(height: 4),
            ],
          ),
        ),

        const SizedBox(height: 14),

        // Coming-soon note
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: _panel2,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: _amber.withValues(alpha: 0.22)),
          ),
          child: const Row(
            children: [
              Icon(Icons.hourglass_top_rounded, color: _amber, size: 15),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Sleep quality, fatigue, mood, and nutrition data will '
                  'appear here once those modules gain persistent tracking.',
                  style: TextStyle(
                      color: _muted, fontSize: 12.5, height: 1.45),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 14),

        // Privacy note
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: _panel,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: _border),
          ),
          child: const Row(
            children: [
              Icon(Icons.lock_outline_rounded, color: _muted, size: 15),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'All chart data is read from your local records. '
                  'Nothing is uploaded, shared, or transmitted.',
                  style: TextStyle(
                      color: _muted, fontSize: 12.5, height: 1.4),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _summaryRow({
    required IconData icon,
    required Color color,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            width: 30, height: 30,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 15),
          ),
          const SizedBox(width: 12),
          Text(label,
              style: const TextStyle(color: _muted, fontSize: 13)),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
                color: _text, fontSize: 13, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _trendArrow({
    required double first,
    required double second,
    required bool lowerIsBetter,
  }) {
    final delta = second - first;
    final improving = lowerIsBetter ? delta < -0.25 : delta > 0.25;
    final worsening = lowerIsBetter ? delta > 0.25 : delta < -0.25;

    final Color arrowColor;
    final IconData arrowIcon;
    final String word;

    if (improving) {
      arrowColor = _green;
      arrowIcon  = Icons.trending_down_rounded;
      word       = 'Improving';
    } else if (worsening) {
      arrowColor = _rose;
      arrowIcon  = Icons.trending_up_rounded;
      word       = 'Worsening';
    } else {
      arrowColor = _amber;
      arrowIcon  = Icons.trending_flat_rounded;
      word       = 'Stable';
    }

    final deltaStr = delta >= 0
        ? '+${delta.toStringAsFixed(1)}'
        : delta.toStringAsFixed(1);

    return Padding(
      padding: const EdgeInsets.only(left: 42, bottom: 2, top: 1),
      child: Row(
        children: [
          Icon(arrowIcon, color: arrowColor, size: 15),
          const SizedBox(width: 5),
          Text(
            '$word  '
            '${first.toStringAsFixed(1)} → ${second.toStringAsFixed(1)}'
            '  ($deltaStr)',
            style: TextStyle(
              color: arrowColor,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // ── Shared layout helpers ─────────────────────────────────────

  Widget _card({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _panel,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _border),
      ),
      child: child,
    );
  }

  Widget _sectionLabel(String text, Color color) {
    return Text(
      text,
      style: TextStyle(
        color: color.withValues(alpha: 0.9),
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.1,
      ),
    );
  }
}

// ── Small reusable widgets ────────────────────────────────────────────────

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return const Divider(
      color: Color(0xFF252845),
      height: 18,
      thickness: 1,
    );
  }
}

class _ViewBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final Color accentColor;
  final VoidCallback onTap;

  const _ViewBtn({
    required this.icon,
    required this.label,
    required this.selected,
    required this.accentColor,
    required this.onTap,
  });

  static const _panel  = Color(0xFF171A2E);
  static const _border = Color(0xFF252845);
  static const _muted  = Color(0xFFB9AECF);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected
              ? accentColor.withValues(alpha: 0.15)
              : _panel,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected
                ? accentColor.withValues(alpha: 0.50)
                : _border,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: selected ? accentColor : _muted,
              size: 15,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: selected ? accentColor : _muted,
                fontSize: 13,
                fontWeight:
                    selected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
