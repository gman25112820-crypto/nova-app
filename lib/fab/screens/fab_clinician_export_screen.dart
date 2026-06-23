import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../fab_theme.dart';
import '../services/profile_service.dart';
import '../services/selected_child_service.dart';
import 'sleep_screen.dart' show SleepEntry;
import 'worry_zone_screen.dart' show WorryEntry;

// ─────────────────────────────────────────────────────────────
// FAB CLINICIAN EXPORT SCREEN
// Child-focused clinical PDF: worry check-ins, sleep summary,
// PDA flag breakdown, parent daily notes, weekly stats.
// Reads: Hive 'worries', SharedPrefs 'sleep_entries',
//        Hive 'parent_notes'. ProfileService for child identity.
// ─────────────────────────────────────────────────────────────

enum _DateRange { days7, days30, allTime }

class FabClinicianExportScreen extends StatefulWidget {
  const FabClinicianExportScreen({super.key});

  @override
  State<FabClinicianExportScreen> createState() =>
      _FabClinicianExportScreenState();
}

class _FabClinicianExportScreenState extends State<FabClinicianExportScreen> {
  _DateRange _range    = _DateRange.days7;
  bool       _loading  = true;
  bool       _building = false;

  List<WorryEntry> _allWorries = [];
  List<SleepEntry> _allSleep   = [];
  Map<String, String>       _parentNotes = {}; // entryId → note text
  Map<String, List<String>> _parentFlags = {}; // entryId → flag list
  Map<String, String>       _dailyNotes  = {}; // yyyy-MM-dd → note text

  // ── Light theme ──────────────────────────────────────────────
  static const _bg     = Color(0xFFF4F6FB);
  static const _white  = Colors.white;
  static const _text   = Color(0xFF1A1A2E);
  static const _muted  = Color(0xFF6B7080);
  static const _border = Color(0xFFE8ECF4);
  static const _purple = Color(0xFF6C63FF);
  static const _teal   = Color(0xFF00C9A7);
  static const _amber  = Color(0xFFFFB830);
  static const _green  = Color(0xFF4CAF50);

  static const _pdaFlags = [
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

  // ── Data loading ─────────────────────────────────────────────

  Future<void> _load() async {
    // Worry entries — Hive box (ascending date order for PDF), per-child key filter
    List<WorryEntry> worries = [];
    if (Hive.isBoxOpen('worries')) {
      final box        = Hive.box<Map>('worries');
      final worryChild = SelectedChildService.current ?? SelectedChildService.selectDefault();
      worries = box.keys.cast<String>()
          .where((k) => worryChild != null && k.startsWith('${worryChild.id}_'))
          .map((k) => WorryEntry.fromJson(Map<String, dynamic>.from(box.get(k)!)))
          .toList()
        ..sort((a, b) => a.date.compareTo(b.date));
    }

    // Sleep entries — SharedPreferences (per-child key)
    final prefs      = await SharedPreferences.getInstance();
    final sleepChild = SelectedChildService.current ?? SelectedChildService.selectDefault();
    final rawSleep   = prefs.getStringList('${sleepChild?.id ?? ''}_sleep_entries') ?? [];
    final sleep = rawSleep
        .map((s) => SleepEntry.fromJson(jsonDecode(s) as Map<String, dynamic>))
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));

    // Parent annotations — Hive 'parent_notes'
    final notes = <String, String>{};
    final flags = <String, List<String>>{};
    final daily = <String, String>{};

    if (Hive.isBoxOpen('parent_notes')) {
      final box         = Hive.box<String>('parent_notes');
      final notesChild  = SelectedChildService.current ?? SelectedChildService.selectDefault();
      final notesPrefix = notesChild != null ? '${notesChild.id}_' : null;
      for (final key in box.keys.cast<String>()) {
        if (notesPrefix == null || !key.startsWith(notesPrefix)) continue;
        final stripped = key.substring(notesPrefix.length);
        final value = box.get(key) ?? '';
        if (stripped.startsWith('note_')) {
          notes[stripped.substring(5)] = value;
        } else if (stripped.startsWith('flags_')) {
          flags[stripped.substring(6)] =
              List<String>.from(jsonDecode(value) as List);
        } else if (stripped.startsWith('daily_')) {
          daily[stripped.substring(6)] = value;
        }
      }
    }

    if (!mounted) return;
    setState(() {
      _allWorries  = worries;
      _allSleep    = sleep;
      _parentNotes = notes;
      _parentFlags = flags;
      _dailyNotes  = daily;
      _loading     = false;
    });
  }

  // ── Date-filtered views ──────────────────────────────────────

  DateTime get _cutoff {
    switch (_range) {
      case _DateRange.days7:   return DateTime.now().subtract(const Duration(days: 7));
      case _DateRange.days30:  return DateTime.now().subtract(const Duration(days: 30));
      case _DateRange.allTime: return DateTime(2000);
    }
  }

  List<WorryEntry> get _worries =>
      _allWorries.where((w) => w.date.isAfter(_cutoff)).toList();

  List<SleepEntry> get _sleep =>
      _allSleep.where((s) => s.date.isAfter(_cutoff)).toList();

  List<String> get _filteredDailyDates {
    final cutStr = _cutoff.toIso8601String().substring(0, 10);
    return _dailyNotes.keys
        .where((d) =>
            d.compareTo(cutStr) >= 0 &&
            (_dailyNotes[d]?.trim().isNotEmpty ?? false))
        .toList()
      ..sort();
  }

  // ── Derived stats ─────────────────────────────────────────────

  double get _avgWorryIntensity {
    final scored = _worries.where((w) => w.intensity > 0).toList();
    if (scored.isEmpty) return 0;
    return scored.map((w) => w.intensity).reduce((a, b) => a + b) /
        scored.length;
  }

  String get _avgSleepLabel {
    final valid =
        _sleep.where((s) => s.sleepDurationMinutes != null).toList();
    if (valid.isEmpty) return '—';
    final avg =
        valid.map((s) => s.sleepDurationMinutes!).reduce((a, b) => a + b) /
            valid.length;
    final h = avg ~/ 60;
    final m = (avg % 60).round();
    return m == 0 ? '${h}h' : '${h}h ${m}m';
  }

  Map<String, int> get _pdaFlagCounts {
    final counts = {for (final f in _pdaFlags) f: 0};
    for (final w in _worries) {
      for (final f in (_parentFlags[w.id] ?? [])) {
        if (counts.containsKey(f)) counts[f] = counts[f]! + 1;
      }
    }
    for (final s in _sleep) {
      for (final f in (_parentFlags[s.id] ?? [])) {
        if (counts.containsKey(f)) counts[f] = counts[f]! + 1;
      }
    }
    return counts;
  }

  int get _totalPdaFlags =>
      _pdaFlagCounts.values.fold(0, (a, b) => a + b);

  // ── PDF generation ────────────────────────────────────────────

  Future<void> _buildPdf() async {
    setState(() => _building = true);
    try {
      final doc      = pw.Document();
      final font     = await PdfGoogleFonts.interRegular();
      final fontBold = await PdfGoogleFonts.interBold();

      final profile    = ProfileService.profile;
      final childName  = profile?.name ?? 'Unknown';
      final childAge   = profile?.age  ?? 0;
      final condLabel  = profile == null || profile.conditions.isEmpty
          ? 'None recorded'
          : profile.conditions.map((c) => c.label).join(', ');

      final today     = _fmtDate(DateTime.now());
      final periodStr = _range == _DateRange.allTime
          ? 'All available data'
          : '${_fmtDate(_cutoff)} – $today';

      final worries    = _worries;
      final sleep      = _sleep;
      final flagCounts = _pdaFlagCounts;
      final dailyDates = _filteredDailyDates;

      doc.addPage(pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.symmetric(horizontal: 40, vertical: 36),
        theme: pw.ThemeData.withFont(base: font, bold: fontBold),
        header: (_) => _pdfHeader(fontBold, childName, today),
        footer: (ctx) => _pdfFooter(ctx, font),
        build: (ctx) => [

          // ── Child profile ─────────────────────────────────────
          _pdfSection('Child Profile', fontBold, PdfColors.indigo700),
          pw.SizedBox(height: 6),
          _pdfKvTable([
            ['Name',       childName],
            ['Age',        '$childAge years'],
            ['Conditions', condLabel],
            ['Report period', periodStr],
            ['Generated',  today],
          ], font, fontBold),
          pw.SizedBox(height: 18),

          // ── Worry check-ins ───────────────────────────────────
          _pdfSection(
            'Worry Check-ins  (${worries.length} entries)',
            fontBold, PdfColors.deepPurple700,
          ),
          pw.SizedBox(height: 6),
          if (worries.isEmpty)
            _pdfNoData('No worry entries in this period.', font)
          else
            _pdfWorryTable(worries, font, fontBold),
          pw.SizedBox(height: 18),

          // ── Sleep summary ─────────────────────────────────────
          _pdfSection(
            'Sleep Summary  (${sleep.length} nights)',
            fontBold, PdfColors.teal700,
          ),
          pw.SizedBox(height: 6),
          if (sleep.isEmpty)
            _pdfNoData('No sleep entries in this period.', font)
          else ...[
            _pdfSleepTable(sleep, font, fontBold),
            pw.SizedBox(height: 5),
            pw.Text(
              'Average sleep duration over period: $_avgSleepLabel',
              style: pw.TextStyle(
                  font: fontBold, fontSize: 9.5, color: PdfColors.teal800),
            ),
          ],
          pw.SizedBox(height: 18),

          // ── PDA flag summary ──────────────────────────────────
          _pdfSection(
            'PDA Observation Flags  (total: $_totalPdaFlags)',
            fontBold, PdfColors.orange700,
          ),
          pw.SizedBox(height: 6),
          _pdfFlagTable(flagCounts, font, fontBold),
          pw.SizedBox(height: 18),

          // ── Summary statistics ────────────────────────────────
          _pdfSection('Summary Statistics', fontBold, PdfColors.blueGrey700),
          pw.SizedBox(height: 6),
          _pdfKvTable([
            ['Worry check-ins logged',  '${worries.length}'],
            ['Avg worry intensity',
              _avgWorryIntensity > 0
                  ? '${_avgWorryIntensity.toStringAsFixed(1)} / 5'
                  : '—'],
            ['Sleep nights logged',     '${sleep.length}'],
            ['Avg sleep duration',      _avgSleepLabel],
            ['Total PDA flags raised',  '$_totalPdaFlags'],
          ], font, fontBold),
          pw.SizedBox(height: 18),

          // ── Parent daily notes ────────────────────────────────
          if (dailyDates.isNotEmpty) ...[
            _pdfSection(
                'Parent Daily Notes  (${dailyDates.length} entries)',
                fontBold, PdfColors.green700),
            pw.SizedBox(height: 6),
            _pdfDailyNotesTable(dailyDates, font, fontBold),
          ],
        ],
      ));

      final bytes = await doc.save();
      await Printing.sharePdf(
        bytes: bytes,
        filename: 'fab_clinician_report_${_today()}.pdf',
      );
      _snack('PDF exported successfully');
    } catch (e) {
      _snack('Export failed: $e', error: true);
    } finally {
      if (mounted) setState(() => _building = false);
    }
  }

  // ── PDF widgets ───────────────────────────────────────────────

  pw.Widget _pdfHeader(pw.Font fontBold, String childName, String date) {
    return pw.Container(
      padding: const pw.EdgeInsets.only(bottom: 10),
      decoration: const pw.BoxDecoration(
        border: pw.Border(
            bottom: pw.BorderSide(color: PdfColors.indigo200, width: 0.5)),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'Fabulously Me — Clinical Report',
                style: pw.TextStyle(
                    font: fontBold, fontSize: 12, color: PdfColors.indigo800),
              ),
              pw.Text(
                'Child: $childName',
                style: pw.TextStyle(fontSize: 9, color: PdfColors.grey600),
              ),
            ],
          ),
          pw.Text(
            'Generated $date',
            style: pw.TextStyle(fontSize: 9, color: PdfColors.grey500),
          ),
        ],
      ),
    );
  }

  pw.Widget _pdfFooter(pw.Context ctx, pw.Font font) {
    return pw.Container(
      padding: const pw.EdgeInsets.only(top: 6),
      decoration: const pw.BoxDecoration(
        border:
            pw.Border(top: pw.BorderSide(color: PdfColors.grey300, width: 0.5)),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            'Generated by Fabulously Me — for clinical use only',
            style: pw.TextStyle(font: font, fontSize: 8, color: PdfColors.grey500),
          ),
          pw.Text(
            'Page ${ctx.pageNumber} of ${ctx.pagesCount}',
            style: pw.TextStyle(font: font, fontSize: 8, color: PdfColors.grey500),
          ),
        ],
      ),
    );
  }

  pw.Widget _pdfSection(String title, pw.Font fontBold, PdfColor color) =>
      pw.Text(title,
          style: pw.TextStyle(font: fontBold, fontSize: 13, color: color));

  pw.Widget _pdfNoData(String msg, pw.Font font) => pw.Text(msg,
      style: pw.TextStyle(font: font, fontSize: 10, color: PdfColors.grey500));

  pw.Widget _pdfKvTable(
      List<List<String>> rows, pw.Font font, pw.Font fontBold) {
    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
      columnWidths: {
        0: const pw.FlexColumnWidth(2),
        1: const pw.FlexColumnWidth(3),
      },
      children: rows
          .map((row) => pw.TableRow(children: [
                _pdfCell(row[0], font: fontBold, fontSize: 9.5),
                _pdfCell(row[1], font: font, fontSize: 9.5),
              ]))
          .toList(),
    );
  }

  pw.Widget _pdfWorryTable(
      List<WorryEntry> entries, pw.Font font, pw.Font fontBold) {
    const headers = [
      'Date', 'Topic', 'Body sensations', 'Intensity', 'Sep. anxiety', 'Parent notes'
    ];
    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
      columnWidths: {
        0: const pw.FlexColumnWidth(1.2),
        1: const pw.FlexColumnWidth(1.2),
        2: const pw.FlexColumnWidth(2.0),
        3: const pw.FlexColumnWidth(0.9),
        4: const pw.FlexColumnWidth(1.2),
        5: const pw.FlexColumnWidth(2.3),
      },
      children: [
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColors.indigo50),
          children: headers
              .map((h) => _pdfCell(h,
                  font: fontBold,
                  fontSize: 8.5,
                  color: PdfColors.indigo900))
              .toList(),
        ),
        ...entries.asMap().entries.map((e) {
          final i     = e.key;
          final w     = e.value;
          final shade = i.isEven ? PdfColors.white : PdfColors.grey50;
          final note  = _parentNotes[w.id] ?? '';
          return pw.TableRow(
            decoration: pw.BoxDecoration(color: shade),
            children: [
              _pdfCell(_fmtDate(w.date), font: font, fontSize: 8.5),
              _pdfCell(w.topic, font: font, fontSize: 8.5),
              _pdfCell(
                  w.bodySensations.isEmpty
                      ? '—'
                      : w.bodySensations.join(', '),
                  font: font,
                  fontSize: 8.5),
              _pdfCell(
                  w.intensity == 0 ? '—' : '${w.intensity}/5',
                  font: font,
                  fontSize: 8.5),
              _pdfCell(w.separationAnxiety ?? '—', font: font, fontSize: 8.5),
              _pdfCell(note.isEmpty ? '—' : note, font: font, fontSize: 8.5),
            ],
          );
        }),
      ],
    );
  }

  pw.Widget _pdfSleepTable(
      List<SleepEntry> entries, pw.Font font, pw.Font fontBold) {
    const headers = ['Date', 'Bedtime', 'Wake time', 'Duration', 'Quality'];
    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
      columnWidths: {
        0: const pw.FlexColumnWidth(1.8),
        1: const pw.FlexColumnWidth(1.3),
        2: const pw.FlexColumnWidth(1.3),
        3: const pw.FlexColumnWidth(1.3),
        4: const pw.FlexColumnWidth(1.0),
      },
      children: [
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColors.teal50),
          children: headers
              .map((h) => _pdfCell(h,
                  font: fontBold,
                  fontSize: 8.5,
                  color: PdfColors.teal900))
              .toList(),
        ),
        ...entries.asMap().entries.map((e) {
          final i     = e.key;
          final s     = e.value;
          final shade = i.isEven ? PdfColors.white : PdfColors.grey50;
          return pw.TableRow(
            decoration: pw.BoxDecoration(color: shade),
            children: [
              _pdfCell(_fmtDate(s.date), font: font, fontSize: 8.5),
              _pdfCell(
                  s.bedtime != null ? _fmtHhmm(s.bedtime!) : '—',
                  font: font,
                  fontSize: 8.5),
              _pdfCell(
                  s.wakeTime != null ? _fmtHhmm(s.wakeTime!) : '—',
                  font: font,
                  fontSize: 8.5),
              _pdfCell(s.sleepDurationLabel ?? '—', font: font, fontSize: 8.5),
              _pdfCell('${s.stars}/5', font: font, fontSize: 8.5),
            ],
          );
        }),
      ],
    );
  }

  pw.Widget _pdfFlagTable(
      Map<String, int> counts, pw.Font font, pw.Font fontBold) {
    final total = counts.values.fold(0, (a, b) => a + b);
    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
      columnWidths: {
        0: const pw.FlexColumnWidth(4),
        1: const pw.FlexColumnWidth(1),
      },
      children: [
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColors.orange50),
          children: [
            _pdfCell('Flag type', font: fontBold, fontSize: 9, color: PdfColors.orange900),
            _pdfCell('Count',     font: fontBold, fontSize: 9, color: PdfColors.orange900),
          ],
        ),
        ...counts.entries.map((e) => pw.TableRow(children: [
          _pdfCell(e.key,      font: font, fontSize: 9),
          _pdfCell('${e.value}', font: font, fontSize: 9),
        ])),
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColors.grey100),
          children: [
            _pdfCell('Total', font: fontBold, fontSize: 9),
            _pdfCell('$total', font: fontBold, fontSize: 9),
          ],
        ),
      ],
    );
  }

  pw.Widget _pdfDailyNotesTable(
      List<String> dates, pw.Font font, pw.Font fontBold) {
    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
      columnWidths: {
        0: const pw.FlexColumnWidth(1.5),
        1: const pw.FlexColumnWidth(5),
      },
      children: [
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColors.green50),
          children: [
            _pdfCell('Date',  font: fontBold, fontSize: 9, color: PdfColors.green900),
            _pdfCell('Notes', font: fontBold, fontSize: 9, color: PdfColors.green900),
          ],
        ),
        ...dates.map((d) => pw.TableRow(children: [
          _pdfCell(_fmtDateStr(d), font: font, fontSize: 9),
          _pdfCell(_dailyNotes[d] ?? '', font: font, fontSize: 9),
        ])),
      ],
    );
  }

  pw.Widget _pdfCell(String text, {
    required pw.Font font,
    double fontSize = 10,
    PdfColor? color,
  }) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      child: pw.Text(
        text,
        style: pw.TextStyle(font: font, fontSize: fontSize, color: color),
      ),
    );
  }

  // ── Utilities ─────────────────────────────────────────────────

  String _fmtDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/'
      '${d.month.toString().padLeft(2, '0')}/'
      '${d.year}';

  String _fmtDateStr(String yyyyMMdd) {
    final p = yyyyMMdd.split('-');
    if (p.length != 3) return yyyyMMdd;
    return '${p[2]}/${p[1]}/${p[0]}';
  }

  String _fmtHhmm(String hhmm) {
    final parts  = hhmm.split(':');
    final h      = int.tryParse(parts[0]) ?? 0;
    final m      = int.tryParse(parts.length > 1 ? parts[1] : '0') ?? 0;
    final suffix = h < 12 ? 'AM' : 'PM';
    final dh     = h == 0 ? 12 : (h > 12 ? h - 12 : h);
    return '$dh:${m.toString().padLeft(2, '0')} $suffix';
  }

  String _today() {
    final n = DateTime.now();
    return '${n.year}-${n.month.toString().padLeft(2, '0')}'
        '-${n.day.toString().padLeft(2, '0')}';
  }

  void _snack(String msg, {bool error = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg, style: const TextStyle(fontFamily: 'DM Sans')),
      backgroundColor: error ? const Color(0xFFFF4D4D) : _teal,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      duration: const Duration(seconds: 4),
    ));
  }

  // ── Build ─────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final profile   = ProfileService.profile;
    final childName = profile?.name ?? 'Unknown';
    final childAge  = profile?.age  ?? 0;
    final hasData   = _worries.isNotEmpty || _sleep.isNotEmpty;

    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: _text, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Clinician Report',
          style: TextStyle(
            color: _text,
            fontSize: 17,
            fontWeight: FontWeight.w700,
            fontFamily: 'DM Sans',
          ),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: _purple))
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
              children: [
                _buildProfileCard(profile, childName, childAge),
                const SizedBox(height: 16),
                _buildRangeSelector(),
                const SizedBox(height: 16),
                _buildStatsRow(),
                const SizedBox(height: 20),
                _buildSectionRow(
                  icon: Icons.sentiment_dissatisfied_rounded,
                  color: _purple,
                  title: 'Worry check-ins',
                  count: '${_worries.length} entries',
                  detail: _avgWorryIntensity > 0
                      ? 'Avg intensity ${_avgWorryIntensity.toStringAsFixed(1)}/5'
                      : 'No intensity data',
                ),
                const SizedBox(height: 10),
                _buildSectionRow(
                  icon: Icons.bedtime_rounded,
                  color: _teal,
                  title: 'Sleep summary',
                  count: '${_sleep.length} nights',
                  detail: 'Avg duration: $_avgSleepLabel',
                ),
                const SizedBox(height: 10),
                _buildSectionRow(
                  icon: Icons.flag_rounded,
                  color: _amber,
                  title: 'PDA observation flags',
                  count: '$_totalPdaFlags flags',
                  detail: _pdaFlagCounts.entries
                      .where((e) => e.value > 0)
                      .map((e) => '${e.key}: ${e.value}')
                      .join(' · ')
                      .let((s) => s.isEmpty ? 'None flagged' : s),
                ),
                const SizedBox(height: 10),
                _buildSectionRow(
                  icon: Icons.edit_note_rounded,
                  color: _green,
                  title: 'Parent daily notes',
                  count: '${_filteredDailyDates.length} entries',
                  detail: '',
                ),
                const SizedBox(height: 24),
                _buildExportButton(hasData),
                const SizedBox(height: 14),
                _buildDisclaimer(),
              ],
            ),
    );
  }

  Widget _buildProfileCard(dynamic profile, String name, int age) {
    return Container(
      padding: const EdgeInsets.all(16),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: _purple.withValues(alpha: 0.10),
                shape: BoxShape.circle,
              ),
              child: const Center(child: Text('🐔', style: TextStyle(fontSize: 20))),
            ),
            const SizedBox(width: 12),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(name,
                  style: const TextStyle(
                    color: _text,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    fontFamily: 'DM Sans',
                  )),
              Text('$age years old',
                  style: const TextStyle(
                    color: _muted,
                    fontSize: 12,
                    fontFamily: 'DM Sans',
                  )),
            ]),
          ]),
          if (ProfileService.profile?.conditions.isNotEmpty ?? false) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: ProfileService.profile!.conditions.map((c) => Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: c.color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: c.color.withValues(alpha: 0.35)),
                ),
                child: Text(c.label,
                    style: TextStyle(
                      color: c.color,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'DM Sans',
                    )),
              )).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildRangeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Date range',
          style: TextStyle(
            color: _text,
            fontSize: 14,
            fontWeight: FontWeight.w700,
            fontFamily: 'DM Sans',
          ),
        ),
        const SizedBox(height: 8),
        Row(children: [
          _rangeChip('Last 7 days',  _DateRange.days7),
          const SizedBox(width: 8),
          _rangeChip('Last 30 days', _DateRange.days30),
          const SizedBox(width: 8),
          _rangeChip('All time',     _DateRange.allTime),
        ]),
      ],
    );
  }

  Widget _rangeChip(String label, _DateRange range) {
    final sel = _range == range;
    return GestureDetector(
      onTap: () => setState(() => _range = range),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: sel ? _purple : _white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: sel ? _purple : _border,
            width: sel ? 1.5 : 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: sel ? Colors.white : _muted,
            fontSize: 12,
            fontWeight: sel ? FontWeight.w700 : FontWeight.normal,
            fontFamily: 'DM Sans',
          ),
        ),
      ),
    );
  }

  Widget _buildStatsRow() {
    return Row(children: [
      _statChip('${_worries.length}',          'worries',    _purple),
      const SizedBox(width: 8),
      _statChip('${_sleep.length}',            'nights',     _teal),
      const SizedBox(width: 8),
      _statChip('$_totalPdaFlags',             'PDA flags',  _amber),
      const SizedBox(width: 8),
      _statChip('${_filteredDailyDates.length}','daily notes', _green),
    ]);
  }

  Widget _statChip(String value, String label, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.22)),
        ),
        child: Column(children: [
          Text(value,
              style: TextStyle(
                color: color,
                fontSize: 18,
                fontWeight: FontWeight.w800,
                fontFamily: 'DM Sans',
              )),
          Text(label,
              style: const TextStyle(
                color: _muted,
                fontSize: 9,
                fontFamily: 'DM Sans',
              )),
        ]),
      ),
    );
  }

  Widget _buildSectionRow({
    required IconData icon,
    required Color color,
    required String title,
    required String count,
    required String detail,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _border),
      ),
      child: Row(children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title,
                style: const TextStyle(
                  color: _text,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'DM Sans',
                )),
            if (detail.isNotEmpty)
              Text(detail,
                  style: const TextStyle(
                    color: _muted,
                    fontSize: 11,
                    fontFamily: 'DM Sans',
                  ),
                  overflow: TextOverflow.ellipsis),
          ]),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(count,
              style: TextStyle(
                color: color,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                fontFamily: 'DM Sans',
              )),
        ),
      ]),
    );
  }

  Widget _buildExportButton(bool hasData) {
    return GestureDetector(
      onTap: (hasData && !_building) ? _buildPdf : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          gradient: (hasData && !_building)
              ? const LinearGradient(
                  colors: [Color(0xFF6C63FF), Color(0xFF00C9A7)])
              : null,
          color: (hasData && !_building) ? null : const Color(0xFFE8ECF4),
          borderRadius: BorderRadius.circular(14),
          boxShadow: (hasData && !_building)
              ? [
                  BoxShadow(
                    color: _purple.withValues(alpha: 0.25),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Center(
          child: _building
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: Colors.white),
                )
              : Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(
                    Icons.picture_as_pdf_rounded,
                    color: hasData ? Colors.white : _muted,
                    size: 22,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    hasData
                        ? 'Download Clinician PDF'
                        : 'No data in selected period',
                    style: TextStyle(
                      color: hasData ? Colors.white : _muted,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'DM Sans',
                    ),
                  ),
                ]),
        ),
      ),
    );
  }

  Widget _buildDisclaimer() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _amber.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _amber.withValues(alpha: 0.22)),
      ),
      child: const Text(
        'This report is a personal tracking record for clinical reference only. '
        'It is not a medical diagnosis. All data is stored locally on-device '
        'and nothing is transmitted without your explicit action.',
        style: TextStyle(
          color: _muted,
          fontSize: 12,
          height: 1.5,
          fontFamily: 'DM Sans',
        ),
      ),
    );
  }
}

// ── Helper extension ──────────────────────────────────────────

extension _StrExt on String {
  T let<T>(T Function(String) fn) => fn(this);
}
