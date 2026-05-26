import 'dart:convert';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/models/check_in_entry.dart';
import '../../core/repositories/check_in_repository.dart';
import 'clinician_export_screen.dart';
import 'worry_zone_screen.dart' show WorryEntry;
import 'sleep_screen.dart' show SleepEntry;

// ─────────────────────────────────────────────────────────────
// PARENT DASHBOARD SCREEN — light professional theme
// Sections: today's child entries (worry + sleep), weekly stats,
// zones/triggers, 7-day pain trend, high-pain alerts,
// recent entries, PDF export.
// ─────────────────────────────────────────────────────────────

class ParentDashboardScreen extends StatefulWidget {
  const ParentDashboardScreen({super.key});

  @override
  State<ParentDashboardScreen> createState() =>
      _ParentDashboardScreenState();
}

class _ParentDashboardScreenState extends State<ParentDashboardScreen> {
  final _repo = CheckInRepository();

  // Pain data
  List<CheckInEntry> _week   = [];
  List<CheckInEntry> _pain   = [];
  List<CheckInEntry> _recent = [];

  // Sleep & worry
  List<SleepEntry>  _todaySleep    = [];
  List<SleepEntry>  _weekSleep     = [];
  List<WorryEntry>  _todayWorries  = [];
  List<WorryEntry>  _weekWorries   = [];

  // Parent annotations keyed by entry id
  Map<String, String>       _parentNotes = {};
  Map<String, List<String>> _parentFlags = {};
  final Map<String, TextEditingController> _noteControllers = {};
  final TextEditingController _dailyNoteCtrl = TextEditingController();

  bool _loading = true;

  // ── Light theme palette ───────────────────────────────────
  static const _bg     = Color(0xFFF4F6FB);
  static const _white  = Colors.white;
  static const _text   = Color(0xFF1A1A2E);
  static const _muted  = Color(0xFF6B7080);
  static const _border = Color(0xFFE8ECF4);
  static const _purple = Color(0xFF6C63FF);
  static const _teal   = Color(0xFF00C9A7);
  static const _pink   = Color(0xFFFF6B8A);
  static const _amber  = Color(0xFFFFB830);
  static const _red    = Color(0xFFFF4D4D);
  static const _green  = Color(0xFF4CAF50);

  static const _pdaFlagOptions = [
    'Demand refused',
    'Transition difficulty',
    'Meltdown',
    'Masking observed',
  ];

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _dailyNoteCtrl.dispose();
    for (final ctrl in _noteControllers.values) {
      ctrl.dispose();
    }
    super.dispose();
  }

  // ── Data loading ──────────────────────────────────────────

  Future<void> _load() async {
    final all          = await _repo.getAllEntries();
    final sleepEntries = await _loadSleepEntries();
    final worryEntries = _loadWorryEntries();
    await _loadParentAnnotations();

    if (!mounted) return;

    final now     = DateTime.now();
    final cutoff  = now.subtract(const Duration(days: 7));
    final todayYMD = DateTime(now.year, now.month, now.day);

    bool isToday(DateTime d) =>
        d.year == todayYMD.year &&
        d.month == todayYMD.month &&
        d.day == todayYMD.day;

    final week  = all.where((e) => e.date.isAfter(cutoff)).toList();
    final pain  = week
        .where((e) => !e.id.startsWith('checkin_'))
        .toList();
    final allPain = all
        .where((e) => !e.id.startsWith('checkin_'))
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));

    setState(() {
      _week   = week;
      _pain   = pain;
      _recent = allPain.take(5).toList();

      _todaySleep   = sleepEntries.where((s) => isToday(s.date)).toList();
      _weekSleep    = sleepEntries.where((s) => s.date.isAfter(cutoff)).toList();
      _todayWorries = worryEntries.where((w) => isToday(w.date)).toList();
      _weekWorries  = worryEntries.where((w) => w.date.isAfter(cutoff)).toList();

      _loading = false;
    });

    _syncNoteControllers();
  }

  List<WorryEntry> _loadWorryEntries() {
    if (!Hive.isBoxOpen('worries')) return [];
    final box = Hive.box<Map>('worries');
    return box.values
        .map((m) => WorryEntry.fromJson(Map<String, dynamic>.from(m)))
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  Future<List<SleepEntry>> _loadSleepEntries() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList('sleep_entries') ?? [];
    return raw
        .map((s) =>
            SleepEntry.fromJson(jsonDecode(s) as Map<String, dynamic>))
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  Future<void> _loadParentAnnotations() async {
    if (!Hive.isBoxOpen('parent_notes')) return;
    final box      = Hive.box<String>('parent_notes');
    final newNotes = <String, String>{};
    final newFlags = <String, List<String>>{};

    for (final key in box.keys.cast<String>()) {
      final value = box.get(key) ?? '';
      if (key.startsWith('note_')) {
        newNotes[key.substring(5)] = value;
      } else if (key.startsWith('flags_')) {
        newFlags[key.substring(6)] =
            List<String>.from(jsonDecode(value) as List);
      }
    }

    _parentNotes = newNotes;
    _parentFlags = newFlags;

    final today = DateTime.now().toIso8601String().substring(0, 10);
    final savedDaily = box.get('daily_$today') ?? '';
    if (_dailyNoteCtrl.text != savedDaily) {
      _dailyNoteCtrl.text = savedDaily;
    }
  }

  void _syncNoteControllers() {
    for (final entry in _noteControllers.entries) {
      final saved = _parentNotes[entry.key] ?? '';
      if (entry.value.text != saved) entry.value.text = saved;
    }
  }

  TextEditingController _noteCtrl(String id) =>
      _noteControllers.putIfAbsent(
        id,
        () => TextEditingController(text: _parentNotes[id] ?? ''),
      );

  Future<void> _saveNote(String entryId, String note) async {
    _parentNotes[entryId] = note;
    final box = Hive.box<String>('parent_notes');
    await box.put('note_$entryId', note);
  }

  Future<void> _saveFlags(String entryId, List<String> flags) async {
    final box = Hive.box<String>('parent_notes');
    await box.put('flags_$entryId', jsonEncode(flags));
  }

  Future<void> _toggleFlag(String entryId, String flag) async {
    final current = List<String>.from(_parentFlags[entryId] ?? []);
    if (current.contains(flag)) {
      current.remove(flag);
    } else {
      current.add(flag);
    }
    setState(() => _parentFlags[entryId] = current);
    await _saveFlags(entryId, current);
  }

  Future<void> _saveDailyNote(String note) async {
    final today = DateTime.now().toIso8601String().substring(0, 10);
    final box = Hive.box<String>('parent_notes');
    await box.put('daily_$today', note);
  }

  // ── Derived stats ─────────────────────────────────────────

  double get _avgPain {
    if (_pain.isEmpty) return 0;
    return _pain.map((e) => e.painRating).reduce((a, b) => a + b) /
        _pain.length;
  }

  double get _avgNerve {
    if (_pain.isEmpty) return 0;
    return _pain
            .map((e) => e.nerveSymptomRating)
            .reduce((a, b) => a + b) /
        _pain.length;
  }

  int get _checkInCount =>
      _week.where((e) => e.id.startsWith('checkin_')).length;

  double get _avgWorryIntensity {
    final scored =
        _weekWorries.where((w) => w.intensity > 0).toList();
    if (scored.isEmpty) return 0;
    return scored.map((w) => w.intensity).reduce((a, b) => a + b) /
        scored.length;
  }

  String get _avgSleepDurationLabel {
    final valid = _weekSleep
        .where((s) => s.sleepDurationMinutes != null)
        .toList();
    if (valid.isEmpty) return '—';
    final avg = valid
            .map((s) => s.sleepDurationMinutes!)
            .reduce((a, b) => a + b) /
        valid.length;
    final h = avg ~/ 60;
    final m = (avg % 60).round();
    return m == 0 ? '${h}h' : '${h}h ${m}m';
  }

  int get _pdaFlagTotal {
    int count = 0;
    for (final flags in _parentFlags.values) {
      count += flags.length;
    }
    return count;
  }

  List<String> get _topZones {
    final freq = <String, int>{};
    for (final e in _pain) {
      for (final z in e.painLocations) {
        freq[z] = (freq[z] ?? 0) + 1;
      }
    }
    return (freq.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value)))
        .take(3)
        .map((e) => e.key)
        .toList();
  }

  List<String> get _topTriggers {
    final freq = <String, int>{};
    for (final e in _pain) {
      for (final t in e.triggers) {
        freq[t] = (freq[t] ?? 0) + 1;
      }
    }
    return (freq.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value)))
        .take(3)
        .map((e) => e.key)
        .toList();
  }

  List<FlSpot> get _painSpots {
    final spots = <FlSpot>[];
    for (int i = 6; i >= 0; i--) {
      final day    = DateTime.now().subtract(Duration(days: i));
      final dayStr = day.toIso8601String().substring(0, 10);
      final entries = _pain
          .where((e) =>
              e.date.toIso8601String().substring(0, 10) == dayStr)
          .toList();
      if (entries.isNotEmpty) {
        final avg =
            entries.map((e) => e.painRating).reduce((a, b) => a + b) /
                entries.length;
        spots.add(FlSpot((6 - i).toDouble(), avg));
      }
    }
    return spots;
  }

  List<CheckInEntry> get _highPainAlerts =>
      (_pain.where((e) => e.painRating >= 8).toList()
        ..sort((a, b) => b.date.compareTo(a.date)));

  // ── Build ─────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shadowColor: _border,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new,
              color: _text, size: 18),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Parent Dashboard',
          style: TextStyle(
              color: _text,
              fontSize: 17,
              fontWeight: FontWeight.w700,
              fontFamily: 'DM Sans'),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 14),
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: _purple.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                  color: _purple.withValues(alpha: 0.30)),
            ),
            child: const Text(
              'Last 7 days',
              style: TextStyle(
                  color: _purple,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'DM Sans'),
            ),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: _purple))
          : RefreshIndicator(
              color: _purple,
              onRefresh: () async {
                setState(() => _loading = true);
                await _load();
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTodaySection(),
                    const SizedBox(height: 20),
                    _buildWeeklyStats(),
                    const SizedBox(height: 20),
                    _buildSummaryCards(),
                    const SizedBox(height: 16),
                    _buildZonesTriggers(),
                    const SizedBox(height: 16),
                    _buildTrendChart(),
                    const SizedBox(height: 16),
                    if (_highPainAlerts.isNotEmpty) ...[
                      _buildAlerts(),
                      const SizedBox(height: 16),
                    ],
                    _buildRecentEntries(),
                    const SizedBox(height: 16),
                    _buildDailyNotes(),
                    const SizedBox(height: 16),
                    _buildPdfButton(),
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

  // ── Today's child entries ─────────────────────────────────

  Widget _buildTodaySection() {
    final hasEntries =
        _todayWorries.isNotEmpty || _todaySleep.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader("Today's entries"),
        const SizedBox(height: 10),
        if (!hasEntries)
          _emptyCard("No entries logged today yet.")
        else ...[
          ..._todayWorries.map(_buildWorryCard),
          ..._todaySleep.map(_buildSleepCard),
        ],
      ],
    );
  }

  Widget _buildWorryCard(WorryEntry e) {
    final flags = _parentFlags[e.id] ?? [];
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: _white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              width: 4,
              decoration: BoxDecoration(
                color: _purple,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(14),
                  bottomLeft: Radius.circular(14),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: _purple.withValues(alpha: 0.10),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '😟 Worry — ${e.topic}',
                          style: const TextStyle(
                            color: _purple,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            fontFamily: 'DM Sans',
                          ),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        _timeLabel(e.date),
                        style: const TextStyle(
                            color: _muted,
                            fontSize: 11,
                            fontFamily: 'DM Sans'),
                      ),
                    ]),
                    if (e.whatIf != null) ...[
                      const SizedBox(height: 6),
                      Text(
                        e.whatIf!,
                        style: const TextStyle(
                          color: _text,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'DM Sans',
                        ),
                      ),
                    ],
                    if (e.bodySensations.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Body: ${e.bodySensations.join(', ')}',
                        style: const TextStyle(
                            color: _muted,
                            fontSize: 12,
                            fontFamily: 'DM Sans'),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const SizedBox(height: 6),
                    Row(children: [
                      Row(
                        children: List.generate(5, (i) => Icon(
                          i < e.intensity
                              ? Icons.star_rounded
                              : Icons.star_outline_rounded,
                          color: i < e.intensity
                              ? const Color(0xFFFFD700)
                              : Colors.grey.shade300,
                          size: 16,
                        )),
                      ),
                      const SizedBox(width: 8),
                      if (e.separationAnxiety != null)
                        Text(
                          'Sep. anxiety: ${e.separationAnxiety}',
                          style: const TextStyle(
                              color: _muted,
                              fontSize: 11,
                              fontFamily: 'DM Sans'),
                        ),
                    ]),
                    const SizedBox(height: 10),
                    _buildPdaFlags(e.id, flags),
                    const SizedBox(height: 10),
                    _buildParentNotesField(e.id),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSleepCard(SleepEntry e) {
    final flags    = _parentFlags[e.id] ?? [];
    final duration = e.sleepDurationLabel;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: _white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              width: 4,
              decoration: BoxDecoration(
                color: _teal,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(14),
                  bottomLeft: Radius.circular(14),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: _teal.withValues(alpha: 0.10),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          '🌙 Sleep',
                          style: TextStyle(
                            color: _teal,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            fontFamily: 'DM Sans',
                          ),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        _timeLabel(e.date),
                        style: const TextStyle(
                            color: _muted,
                            fontSize: 11,
                            fontFamily: 'DM Sans'),
                      ),
                    ]),
                    const SizedBox(height: 8),
                    Row(children: [
                      if (e.bedtime != null)
                        _infoChip('🌙 ${_fmtTime(e.bedtime!)}', _teal),
                      if (e.bedtime != null) const SizedBox(width: 6),
                      if (e.wakeTime != null)
                        _infoChip('🌤 ${_fmtTime(e.wakeTime!)}', _teal),
                      if (duration != null) ...[
                        const SizedBox(width: 6),
                        _infoChip('⏱ $duration', _amber),
                      ],
                    ]),
                    const SizedBox(height: 6),
                    Row(
                      children: List.generate(5, (i) => Icon(
                        i < e.stars
                            ? Icons.star_rounded
                            : Icons.star_outline_rounded,
                        color: i < e.stars
                            ? const Color(0xFFFFD700)
                            : Colors.grey.shade300,
                        size: 16,
                      )),
                    ),
                    const SizedBox(height: 10),
                    _buildPdaFlags(e.id, flags),
                    const SizedBox(height: 10),
                    _buildParentNotesField(e.id),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoChip(String label, Color color) => Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: color,
            fontSize: 11,
            fontWeight: FontWeight.w600,
            fontFamily: 'DM Sans',
          ),
        ),
      );

  Widget _buildPdaFlags(String entryId, List<String> current) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'PDA OBSERVATION FLAGS',
          style: TextStyle(
              color: _muted,
              fontSize: 9,
              letterSpacing: 1.0,
              fontFamily: 'DM Sans'),
        ),
        const SizedBox(height: 6),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: _pdaFlagOptions.map((flag) {
            final sel = current.contains(flag);
            return GestureDetector(
              onTap: () => _toggleFlag(entryId, flag),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: sel
                      ? _amber.withValues(alpha: 0.15)
                      : _bg,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: sel ? _amber : _border,
                    width: sel ? 1.5 : 1,
                  ),
                ),
                child: Text(
                  flag,
                  style: TextStyle(
                    color: sel ? const Color(0xFFA0600A) : _muted,
                    fontSize: 11,
                    fontWeight: sel
                        ? FontWeight.w700
                        : FontWeight.normal,
                    fontFamily: 'DM Sans',
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildParentNotesField(String entryId) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'PARENT NOTES',
          style: TextStyle(
              color: _muted,
              fontSize: 9,
              letterSpacing: 1.0,
              fontFamily: 'DM Sans'),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: _noteCtrl(entryId),
          maxLines: 2,
          onChanged: (v) => _saveNote(entryId, v),
          style: const TextStyle(
              color: _text, fontSize: 13, fontFamily: 'DM Sans'),
          decoration: InputDecoration(
            hintText: 'Add your observations here...',
            hintStyle: TextStyle(
                color: _muted.withValues(alpha: 0.60), fontSize: 12),
            filled: true,
            fillColor: _bg,
            contentPadding: const EdgeInsets.symmetric(
                horizontal: 12, vertical: 8),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: _border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: _border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: _purple),
            ),
          ),
        ),
      ],
    );
  }

  // ── Weekly stats ──────────────────────────────────────────

  Widget _buildWeeklyStats() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader('Weekly summary'),
        const SizedBox(height: 10),
        Row(children: [
          Expanded(
            child: _statCard(
              label: 'Avg worry',
              value: _avgWorryIntensity > 0
                  ? _avgWorryIntensity.toStringAsFixed(1)
                  : '—',
              suffix: _avgWorryIntensity > 0 ? '/5' : '',
              color: _purple,
              icon: Icons.sentiment_dissatisfied_rounded,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _statCard(
              label: 'Avg sleep',
              value: _avgSleepDurationLabel,
              suffix: '',
              color: _teal,
              icon: Icons.bedtime_rounded,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _statCard(
              label: 'PDA flags',
              value: '$_pdaFlagTotal',
              suffix: '',
              color: _amber,
              icon: Icons.flag_rounded,
            ),
          ),
        ]),
      ],
    );
  }

  // ── Pain summary cards ────────────────────────────────────

  Widget _buildSummaryCards() {
    return Row(children: [
      Expanded(
        child: _statCard(
          label: 'Avg pain',
          value: _avgPain.toStringAsFixed(1),
          suffix: '/10',
          color: _painColor(_avgPain),
          icon: Icons.thermostat_rounded,
        ),
      ),
      const SizedBox(width: 10),
      Expanded(
        child: _statCard(
          label: 'Avg nerve',
          value: _avgNerve.toStringAsFixed(1),
          suffix: '/10',
          color: const Color(0xFF5DADEC),
          icon: Icons.electric_bolt_rounded,
        ),
      ),
      const SizedBox(width: 10),
      Expanded(
        child: _statCard(
          label: 'Check-ins',
          value: '$_checkInCount',
          suffix: '/7d',
          color: _green,
          icon: Icons.check_circle_rounded,
        ),
      ),
    ]);
  }

  Widget _statCard({
    required String label,
    required String value,
    required String suffix,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(height: 8),
        RichText(
          text: TextSpan(children: [
            TextSpan(
              text: value,
              style: TextStyle(
                color: color,
                fontSize: 20,
                fontWeight: FontWeight.w800,
                fontFamily: 'DM Sans',
              ),
            ),
            if (suffix.isNotEmpty)
              TextSpan(
                text: suffix,
                style: const TextStyle(
                    color: _muted,
                    fontSize: 11,
                    fontFamily: 'DM Sans'),
              ),
          ]),
        ),
        const SizedBox(height: 4),
        Text(label,
            style: const TextStyle(
                color: _muted, fontSize: 11, fontFamily: 'DM Sans')),
      ]),
    );
  }

  // ── Zones + triggers ──────────────────────────────────────

  Widget _buildZonesTriggers() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: _listPanel(
            'Most affected',
            Icons.location_on_rounded,
            const Color(0xFF5DADEC),
            _topZones,
            'No zones logged',
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _listPanel(
            'Top triggers',
            Icons.warning_amber_rounded,
            _amber,
            _topTriggers,
            'No triggers logged',
          ),
        ),
      ],
    );
  }

  Widget _listPanel(String title, IconData icon, Color color,
      List<String> items, String empty) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _border),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(icon, color: color, size: 15),
          const SizedBox(width: 6),
          Text(title,
              style: const TextStyle(
                  color: _text,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'DM Sans')),
        ]),
        const SizedBox(height: 10),
        if (items.isEmpty)
          Text(empty,
              style: const TextStyle(
                  color: _muted, fontSize: 11, fontFamily: 'DM Sans'))
        else
          ...items.asMap().entries.map((e) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(children: [
                  Container(
                    width: 18,
                    height: 18,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Center(
                      child: Text('${e.key + 1}',
                          style: TextStyle(
                              color: color,
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              fontFamily: 'DM Sans')),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(e.value,
                        style: const TextStyle(
                            color: _muted,
                            fontSize: 11,
                            fontFamily: 'DM Sans'),
                        overflow: TextOverflow.ellipsis),
                  ),
                ]),
              )),
      ]),
    );
  }

  // ── 7-day pain trend chart ────────────────────────────────

  Widget _buildTrendChart() {
    final spots = _painSpots;
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
      decoration: BoxDecoration(
        color: _white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _border),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(Icons.show_chart_rounded, color: _pink, size: 18),
          const SizedBox(width: 8),
          const Text('7-day pain trend',
              style: TextStyle(
                  color: _text,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'DM Sans')),
        ]),
        const SizedBox(height: 16),
        if (spots.isEmpty)
          SizedBox(
            height: 100,
            child: Center(
              child: Text('No pain entries in last 7 days',
                  style: TextStyle(
                      color: _muted.withValues(alpha: 0.70),
                      fontSize: 13,
                      fontFamily: 'DM Sans')),
            ),
          )
        else
          SizedBox(
            height: 120,
            child: LineChart(LineChartData(
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
                  color: _border,
                  strokeWidth: 1,
                ),
              ),
              borderData: FlBorderData(show: false),
              titlesData: FlTitlesData(
                leftTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false)),
                rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false)),
                topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false)),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (x, _) {
                      final day = DateTime.now()
                          .subtract(Duration(days: 6 - x.toInt()));
                      const labels = [
                        'Mon', 'Tue', 'Wed', 'Thu',
                        'Fri', 'Sat', 'Sun'
                      ];
                      return Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Text(labels[day.weekday - 1],
                            style: const TextStyle(
                                color: _muted,
                                fontSize: 9,
                                fontFamily: 'DM Sans')),
                      );
                    },
                    reservedSize: 22,
                  ),
                ),
              ),
              lineTouchData: LineTouchData(
                touchTooltipData: LineTouchTooltipData(
                  getTooltipColor: (_) => _white,
                  getTooltipItems: (spots) => spots
                      .map((s) => LineTooltipItem(
                            s.y.toStringAsFixed(1),
                            const TextStyle(
                              color: _pink,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              fontFamily: 'DM Sans',
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
                    getDotPainter: (spot, _, __, ___) =>
                        FlDotCirclePainter(
                      radius: 3.5,
                      color: spot.y >= 8 ? _red : _pink,
                      strokeWidth: 1.5,
                      strokeColor: _white,
                    ),
                  ),
                  belowBarData: BarAreaData(
                    show: true,
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        _pink.withValues(alpha: 0.12),
                        _pink.withValues(alpha: 0.00),
                      ],
                    ),
                  ),
                ),
              ],
            )),
          ),
      ]),
    );
  }

  // ── High-pain alerts ──────────────────────────────────────

  Widget _buildAlerts() {
    final alerts = _highPainAlerts;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _red.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _red.withValues(alpha: 0.25)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Icon(Icons.warning_rounded, color: _red, size: 18),
          const SizedBox(width: 8),
          Text(
            'High pain alert${alerts.length > 1 ? 's' : ''} — last 7 days',
            style: const TextStyle(
                color: _red,
                fontSize: 14,
                fontWeight: FontWeight.w700,
                fontFamily: 'DM Sans'),
          ),
        ]),
        const SizedBox(height: 4),
        Text(
          'Pain scored 8 or above — consider speaking to a clinician.',
          style: TextStyle(
              color: _red.withValues(alpha: 0.70),
              fontSize: 12,
              fontFamily: 'DM Sans'),
        ),
        const SizedBox(height: 12),
        ...alerts.map(_alertRow),
      ]),
    );
  }

  Widget _alertRow(CheckInEntry e) {
    final dateStr =
        '${_weekday(e.date.weekday)} ${e.date.day}/${e.date.month}';
    final top = e.symptoms.isNotEmpty
        ? e.symptoms.first
        : (e.painLocations.isNotEmpty ? e.painLocations.first : '');
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: _red.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _red.withValues(alpha: 0.20)),
      ),
      child: Row(children: [
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(dateStr,
                style: TextStyle(
                    color: _red.withValues(alpha: 0.80),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'DM Sans')),
            if (top.isNotEmpty)
              Text(top,
                  style: const TextStyle(
                      color: _muted,
                      fontSize: 11,
                      fontFamily: 'DM Sans'),
                  overflow: TextOverflow.ellipsis),
          ]),
        ),
        Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: _red.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            '${e.painRating}/10',
            style: const TextStyle(
                color: _red,
                fontSize: 14,
                fontWeight: FontWeight.w800,
                fontFamily: 'DM Sans'),
          ),
        ),
      ]),
    );
  }

  // ── Recent pain entries ───────────────────────────────────

  Widget _buildRecentEntries() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader('Recent pain entries'),
        const SizedBox(height: 10),
        if (_recent.isEmpty)
          _emptyCard('No pain entries logged yet.')
        else
          ..._recent.map(_entryRow),
      ],
    );
  }

  Widget _entryRow(CheckInEntry e) {
    final dateStr =
        '${_weekday(e.date.weekday)} ${e.date.day}/${e.date.month}/${e.date.year}';
    final topSymptom = e.symptoms.isNotEmpty
        ? e.symptoms.first
        : (e.painLocations.isNotEmpty ? e.painLocations.first : '—');
    final scoreColor = _painColor(e.painRating.toDouble());
    final isHigh     = e.painRating >= 8;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isHigh ? _red.withValues(alpha: 0.30) : _border,
        ),
      ),
      child: Row(children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: scoreColor.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: scoreColor.withValues(alpha: 0.25)),
          ),
          child: Center(
            child: Text(
              '${e.painRating}',
              style: TextStyle(
                  color: scoreColor,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  fontFamily: 'DM Sans'),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(dateStr,
                style: const TextStyle(
                    color: _muted, fontSize: 11, fontFamily: 'DM Sans')),
            const SizedBox(height: 3),
            Text(
              topSymptom,
              style: const TextStyle(
                  color: _text,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'DM Sans'),
              overflow: TextOverflow.ellipsis,
            ),
          ]),
        ),
        if (isHigh)
          const Icon(Icons.warning_amber_rounded, color: _red, size: 16),
      ]),
    );
  }

  // ── PDF button ────────────────────────────────────────────

  Widget _buildPdfButton() {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
            builder: (_) => const ClinicianExportScreen()),
      ),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF5DADEC), Color(0xFF6C63FF)],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: _purple.withValues(alpha: 0.20),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.picture_as_pdf_rounded,
                color: Colors.white, size: 22),
            SizedBox(width: 10),
            Text(
              'Generate GP / PIP PDF Report',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'DM Sans'),
            ),
          ],
        ),
      ),
    );
  }

  // ── Daily notes ───────────────────────────────────────────

  Widget _buildDailyNotes() {
    final now     = DateTime.now();
    final dateStr =
        '${_weekday(now.weekday)} ${now.day}/${now.month}/${now.year}';
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            const Icon(Icons.edit_note_rounded, color: _purple, size: 20),
            const SizedBox(width: 8),
            const Text(
              'Daily notes',
              style: TextStyle(
                color: _text,
                fontSize: 14,
                fontWeight: FontWeight.w700,
                fontFamily: 'DM Sans',
              ),
            ),
            const Spacer(),
            Text(
              dateStr,
              style: const TextStyle(
                color: _muted,
                fontSize: 11,
                fontFamily: 'DM Sans',
              ),
            ),
          ]),
          const SizedBox(height: 4),
          Text(
            'General observations not tied to a specific entry',
            style: TextStyle(
              color: _muted.withValues(alpha: 0.80),
              fontSize: 12,
              fontFamily: 'DM Sans',
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _dailyNoteCtrl,
            maxLines: 5,
            onChanged: _saveDailyNote,
            style: const TextStyle(
              color: _text,
              fontSize: 13,
              fontFamily: 'DM Sans',
              height: 1.5,
            ),
            decoration: InputDecoration(
              hintText:
                  'e.g. Transitions were difficult today, but the afternoon was calmer...',
              hintStyle: TextStyle(
                color: _muted.withValues(alpha: 0.60),
                fontSize: 12,
                fontFamily: 'DM Sans',
              ),
              filled: true,
              fillColor: _bg,
              contentPadding: const EdgeInsets.all(12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: _border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: _border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: _purple),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Dev: clear data ───────────────────────────────────────

  Future<void> _clearAllData() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Clear all test data?',
            style: TextStyle(
                color: _text,
                fontFamily: 'DM Sans',
                fontWeight: FontWeight.w700)),
        content: const Text(
          'Clears all Hive entries (checkins, worries) and sleep data. '
          'Cannot be undone.',
          style: TextStyle(color: _muted, fontFamily: 'DM Sans'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel',
                style: TextStyle(color: _muted, fontFamily: 'DM Sans')),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Clear',
                style: TextStyle(
                    color: _red,
                    fontFamily: 'DM Sans',
                    fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
    if (confirm != true || !mounted) return;
    if (Hive.isBoxOpen('checkins')) {
      await Hive.box<Map>('checkins').clear();
    }
    if (Hive.isBoxOpen('worries')) {
      await Hive.box<Map>('worries').clear();
    }
    if (Hive.isBoxOpen('parent_notes')) {
      await Hive.box<String>('parent_notes').clear();
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('sleep_entries');
    setState(() => _loading = true);
    await _load();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('All entries cleared',
          style: TextStyle(fontFamily: 'DM Sans')),
    ));
  }

  Widget _buildClearDataButton() {
    return GestureDetector(
      onTap: _clearAllData,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: _red.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _red.withValues(alpha: 0.25)),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.delete_sweep_rounded, color: _red, size: 18),
            SizedBox(width: 8),
            Text(
              'DEV — Clear all test data',
              style: TextStyle(
                  color: _red,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'DM Sans'),
            ),
          ],
        ),
      ),
    );
  }

  // ── Helpers ───────────────────────────────────────────────

  Widget _sectionHeader(String title) => Text(
        title,
        style: const TextStyle(
          color: _text,
          fontSize: 16,
          fontWeight: FontWeight.w800,
          fontFamily: 'DM Sans',
        ),
      );

  Widget _emptyCard(String message) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: _white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _border),
        ),
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(
              color: _muted, fontSize: 13, fontFamily: 'DM Sans'),
        ),
      );

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

  String _timeLabel(DateTime d) {
    final h = d.hour.toString().padLeft(2, '0');
    final m = d.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  String _fmtTime(String hhmm) {
    final parts = hhmm.split(':');
    final h = int.parse(parts[0]);
    final m = int.parse(parts[1]);
    final suffix   = h < 12 ? 'AM' : 'PM';
    final displayH = h == 0 ? 12 : (h > 12 ? h - 12 : h);
    return '$displayH:${m.toString().padLeft(2, '0')} $suffix';
  }
}
