import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ─────────────────────────────────────────────────────────────
// SENCO REPORT SCREEN
// School wellbeing PDF export for SENCO / pastoral staff.
// Reads mood entries from SharedPreferences key 'fab_mood_entries'.
// Child name from SharedPreferences key 'child_name'.
// ─────────────────────────────────────────────────────────────

const _kPrefsKey   = 'fab_mood_entries';
const _kMoodLabels = ['Awful', 'Sad', 'Okay', 'Good', 'Amazing'];
const _kMoodEmojis = ['😢', '😟', '😐', '😊', '😄'];

class SencoReportScreen extends StatefulWidget {
  const SencoReportScreen({super.key});

  @override
  State<SencoReportScreen> createState() => _SencoReportScreenState();
}

class _SencoReportScreenState extends State<SencoReportScreen> {
  List<_MoodEntry> _entries = [];
  String _childName = 'Child';
  bool _loading  = true;
  bool _building = false;

  // ── Colours (matches parent dashboard) ──────────────────────
  static const _bg     = Color(0xFF0B0D1E);
  static const _panel  = Color(0xFF111527);
  static const _text   = Color(0xFFF2EFFF);
  static const _muted  = Color(0xFF8A8EAB);
  static const _blue   = Color(0xFF5DADEC);
  static const _purple = Color(0xFF9B7DFF);
  static const _amber  = Color(0xFFFFB830);
  static const _teal   = Color(0xFF00C9A7);
  static const _coral  = Color(0xFFFF4D4D);
  static const _green  = Color(0xFF4CAF50);

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs     = await SharedPreferences.getInstance();
    final childName = prefs.getString('child_name') ?? 'Child';
    final raw       = prefs.getString(_kPrefsKey);
    final entries   = <_MoodEntry>[];
    if (raw != null) {
      try {
        final list = jsonDecode(raw) as List<dynamic>;
        for (final item in list) {
          entries.add(_MoodEntry.fromJson(item as Map<String, dynamic>));
        }
        entries.sort((a, b) => a.timestamp.compareTo(b.timestamp));
      } catch (_) {}
    }
    if (!mounted) return;
    setState(() {
      _childName = childName;
      _entries   = entries;
      _loading   = false;
    });
  }

  // ── Derived stats ─────────────────────────────────────────────

  double get _avgMood {
    if (_entries.isEmpty) return 0;
    return _entries.map((e) => e.mood).reduce((a, b) => a + b) / _entries.length;
  }

  DateTime? get _firstDate => _entries.isEmpty ? null : _entries.first.timestamp;
  DateTime? get _lastDate  => _entries.isEmpty ? null : _entries.last.timestamp;

  Map<String, int> get _factorCounts {
    final counts = <String, int>{};
    for (final e in _entries) {
      for (final f in e.factors) {
        counts[f] = (counts[f] ?? 0) + 1;
      }
    }
    return counts;
  }

  List<int> get _moodDist {
    final dist = List.filled(5, 0);
    for (final e in _entries) {
      dist[e.mood]++;
    }
    return dist;
  }

  int get _schoolCount =>
      _entries.where((e) => e.factors.contains('School')).length;

  double get _schoolMoodAvg {
    final school = _entries.where((e) => e.factors.contains('School')).toList();
    if (school.isEmpty) return 0;
    return school.map((e) => e.mood).reduce((a, b) => a + b) / school.length;
  }

  // Day-of-week avg mood (index 0=Mon … 6=Sun)
  List<double?> get _dowAvg {
    final sums   = List.filled(7, 0.0);
    final counts = List.filled(7, 0);
    for (final e in _entries) {
      final dow = e.timestamp.weekday - 1;
      sums[dow]   += e.mood;
      counts[dow] += 1;
    }
    return List.generate(7, (i) => counts[i] == 0 ? null : sums[i] / counts[i]);
  }

  // 4 weekly buckets, oldest first
  List<_Week4> get _fourWeeks {
    final now = DateTime.now();
    return List.generate(4, (w) {
      final end   = now.subtract(Duration(days: w * 7));
      final start = end.subtract(const Duration(days: 6));
      final bucket = _entries.where((e) =>
          !e.timestamp.isBefore(start) && !e.timestamp.isAfter(end)).toList();
      return _Week4(label: '${_d(start)} – ${_d(end)}', entries: bucket);
    }).reversed.toList();
  }

  // Last 5 entries that have notes
  List<_MoodEntry> get _recentNotes =>
      _entries.where((e) => e.notes.isNotEmpty).toList().reversed.take(5).toList();

  // ── PDF generation ────────────────────────────────────────────

  Future<void> _buildPdf() async {
    if (_entries.isEmpty) {
      _snack('No wellbeing entries to export.', error: true);
      return;
    }
    setState(() => _building = true);
    try {
      final doc      = pw.Document();
      final font     = await PdfGoogleFonts.interRegular();
      final fontBold = await PdfGoogleFonts.interBold();

      final dateRange = _firstDate == null
          ? 'No data'
          : '${_d(_firstDate!)} – ${_d(_lastDate!)}';

      final dist      = _moodDist;
      final factors   = _factorCounts;
      final schoolCnt = _schoolCount;
      final schoolAvg = _schoolMoodAvg;
      final weeks     = _fourWeeks;
      final dow       = _dowAvg;
      final notes     = _recentNotes;

      doc.addPage(pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(36),
        theme: pw.ThemeData.withFont(base: font, bold: fontBold),
        header: (_) => _pdfHeader(fontBold, dateRange),
        footer: (ctx) => _pdfFooter(ctx, font),
        build: (ctx) => [

          _pdfDisclaimer(font),
          pw.SizedBox(height: 14),

          // ── Overview ─────────────────────────────────────────
          _pdfSection('Wellbeing Overview', fontBold, PdfColors.indigo700),
          pw.SizedBox(height: 8),
          _pdfKV([
            ['Child name',        _childName],
            ['Date range',        dateRange],
            ['Total log entries', '${_entries.length}'],
            ['Average mood',      '${_avgMood.toStringAsFixed(1)} / 4  (0=Awful, 4=Amazing)'],
            ['Most common mood',  _mostCommonLabel(dist)],
          ], font, fontBold),
          pw.SizedBox(height: 14),

          // ── Mood distribution ────────────────────────────────
          pw.Divider(color: PdfColors.grey300),
          pw.SizedBox(height: 10),
          _pdfSection('Mood Distribution', fontBold, PdfColors.deepPurple700),
          pw.SizedBox(height: 8),
          _pdfMoodDist(dist, font, fontBold),
          pw.SizedBox(height: 14),

          // ── School pattern ───────────────────────────────────
          pw.Divider(color: PdfColors.grey300),
          pw.SizedBox(height: 10),
          _pdfSection('School-Related Wellbeing Patterns', fontBold, PdfColors.teal700),
          pw.SizedBox(height: 8),
          _pdfKV([
            ['Entries where \'School\' was logged',
             '$schoolCnt of ${_entries.length} (${_entries.isEmpty ? 0 : (schoolCnt / _entries.length * 100).toStringAsFixed(0)}%)'],
            ['Average mood on school-related entries',
             schoolCnt > 0 ? '${schoolAvg.toStringAsFixed(1)} / 4' : 'No school entries'],
            ['Overall average mood',     '${_avgMood.toStringAsFixed(1)} / 4'],
            ['School vs overall pattern', _schoolImpactNote(schoolAvg)],
          ], font, fontBold),
          pw.SizedBox(height: 14),

          // ── Factor frequency ─────────────────────────────────
          pw.Divider(color: PdfColors.grey300),
          pw.SizedBox(height: 10),
          _pdfSection('Wellbeing Factors — Frequency', fontBold, PdfColors.orange700),
          pw.SizedBox(height: 8),
          _pdfFactorTable(factors, font, fontBold),
          pw.SizedBox(height: 14),

          // ── 4-week trend ─────────────────────────────────────
          pw.Divider(color: PdfColors.grey300),
          pw.SizedBox(height: 10),
          _pdfSection('4-Week Wellbeing Trend', fontBold, PdfColors.blue700),
          pw.SizedBox(height: 8),
          _pdfWeekTable(weeks, font, fontBold),
          pw.SizedBox(height: 14),

          // ── Day-of-week ──────────────────────────────────────
          pw.Divider(color: PdfColors.grey300),
          pw.SizedBox(height: 10),
          _pdfSection('Day-of-Week Mood Pattern', fontBold, PdfColors.blueGrey700),
          pw.SizedBox(height: 6),
          pw.Text(
            'Average mood score per day of the week. Lower scores on school days may indicate'
            ' school-related anxiety or fatigue patterns worth exploring.',
            style: pw.TextStyle(font: font, fontSize: 9, color: PdfColors.grey600),
          ),
          pw.SizedBox(height: 6),
          _pdfDowTable(dow, font, fontBold),
          pw.SizedBox(height: 14),

          // ── Child's own notes ────────────────────────────────
          if (notes.isNotEmpty) ...[
            pw.Divider(color: PdfColors.grey300),
            pw.SizedBox(height: 10),
            _pdfSection("Child's Own Words — Recent Notes", fontBold, PdfColors.pink700),
            pw.SizedBox(height: 6),
            pw.Text(
              'Verbatim notes entered by the child. May support pastoral conversations.',
              style: pw.TextStyle(font: font, fontSize: 9, color: PdfColors.grey600),
            ),
            pw.SizedBox(height: 8),
            ...notes.map((e) => pw.Padding(
              padding: const pw.EdgeInsets.only(bottom: 8),
              child: pw.Container(
                padding: const pw.EdgeInsets.all(10),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.grey300, width: 0.5),
                  borderRadius: pw.BorderRadius.circular(4),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      '${_d(e.timestamp)}  •  ${_kMoodLabels[e.mood]}'
                      '${e.factors.isEmpty ? '' : '  •  ${e.factors.join(', ')}'}',
                      style: pw.TextStyle(font: fontBold, fontSize: 9, color: PdfColors.grey700),
                    ),
                    pw.SizedBox(height: 4),
                    pw.Text(e.notes,
                        style: pw.TextStyle(font: font, fontSize: 10)),
                  ],
                ),
              ),
            )),
          ],

          pw.SizedBox(height: 10),
          _pdfSencoNote(font),
        ],
      ));

      final bytes    = await doc.save();
      final fileName = 'nova_senco_report_${_today()}.pdf';
      await Printing.sharePdf(bytes: bytes, filename: fileName);
      _snack('PDF exported — $fileName');
    } catch (e) {
      _snack('Export failed: $e', error: true);
    } finally {
      if (mounted) setState(() => _building = false);
    }
  }

  // ── PDF widget helpers ─────────────────────────────────────────

  pw.Widget _pdfHeader(pw.Font fontBold, String dateRange) {
    return pw.Container(
      padding: const pw.EdgeInsets.only(bottom: 8),
      decoration: const pw.BoxDecoration(
        border: pw.Border(
            bottom: pw.BorderSide(color: PdfColors.teal200, width: 0.5)),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text('NOVA — School Wellbeing Report (SENCO)',
              style: pw.TextStyle(
                  font: fontBold, fontSize: 11, color: PdfColors.teal800)),
          pw.Text('Generated ${_d(DateTime.now())}',
              style: pw.TextStyle(fontSize: 9, color: PdfColors.grey600)),
        ],
      ),
    );
  }

  pw.Widget _pdfFooter(pw.Context ctx, pw.Font font) {
    return pw.Container(
      padding: const pw.EdgeInsets.only(top: 6),
      decoration: const pw.BoxDecoration(
        border: pw.Border(
            top: pw.BorderSide(color: PdfColors.grey300, width: 0.5)),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
              'Personal wellbeing log — Nova App. Not a clinical or formal assessment.',
              style: pw.TextStyle(
                  font: font, fontSize: 8, color: PdfColors.grey500)),
          pw.Text('Page ${ctx.pageNumber} of ${ctx.pagesCount}',
              style: pw.TextStyle(
                  font: font, fontSize: 8, color: PdfColors.grey500)),
        ],
      ),
    );
  }

  pw.Widget _pdfDisclaimer(pw.Font font) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        color: PdfColors.amber50,
        border: pw.Border.all(color: PdfColors.amber300, width: 0.5),
        borderRadius: pw.BorderRadius.circular(4),
      ),
      child: pw.Text(
        'This report is a personal wellbeing log generated by the Nova App and completed by the child. '
        'It is not a clinical assessment, formal EHCP evidence, or medical report. '
        'Intended to support pastoral conversations and school-based wellbeing planning. '
        'All data entered by the child and stored locally on-device. Nothing transmitted externally.',
        style:
            pw.TextStyle(font: font, fontSize: 9, color: PdfColors.brown700),
      ),
    );
  }

  pw.Widget _pdfSencoNote(pw.Font font) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        color: PdfColors.teal50,
        border: pw.Border.all(color: PdfColors.teal300, width: 0.5),
        borderRadius: pw.BorderRadius.circular(4),
      ),
      child: pw.Text(
        'For SENCO / Pastoral Staff: Low mood patterns — particularly when School or Worried are '
        'cited as factors, or on weekday entries — may warrant a wellbeing check-in. '
        'This document does not replace a formal needs assessment, EHCP review, or referral process.',
        style: pw.TextStyle(font: font, fontSize: 9, color: PdfColors.teal900),
      ),
    );
  }

  pw.Widget _pdfSection(String title, pw.Font fontBold, PdfColor color) {
    return pw.Text(title,
        style: pw.TextStyle(font: fontBold, fontSize: 13, color: color));
  }

  pw.Widget _pdfKV(
      List<List<String>> rows, pw.Font font, pw.Font fontBold) {
    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
      columnWidths: {
        0: const pw.FlexColumnWidth(2.4),
        1: const pw.FlexColumnWidth(3),
      },
      children: rows
          .map((row) => pw.TableRow(children: [
                pw.Padding(
                  padding: const pw.EdgeInsets.symmetric(
                      horizontal: 8, vertical: 5),
                  child: pw.Text(row[0],
                      style: pw.TextStyle(font: fontBold, fontSize: 10)),
                ),
                pw.Padding(
                  padding: const pw.EdgeInsets.symmetric(
                      horizontal: 8, vertical: 5),
                  child: pw.Text(row[1],
                      style: pw.TextStyle(font: font, fontSize: 10)),
                ),
              ]))
          .toList(),
    );
  }

  pw.Widget _pdfMoodDist(
      List<int> dist, pw.Font font, pw.Font fontBold) {
    final total = _entries.length;
    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
      children: [
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColors.indigo50),
          children: ['Mood', 'Count', 'Percentage']
              .map((h) => pw.Padding(
                    padding: const pw.EdgeInsets.symmetric(
                        horizontal: 8, vertical: 5),
                    child: pw.Text(h,
                        style: pw.TextStyle(
                            font: fontBold,
                            fontSize: 9,
                            color: PdfColors.indigo900)),
                  ))
              .toList(),
        ),
        ...List.generate(5, (i) {
          final pct = total == 0 ? 0.0 : dist[i] / total * 100;
          return pw.TableRow(
            decoration: pw.BoxDecoration(
                color: i.isEven ? PdfColors.white : PdfColors.grey50),
            children: [
              pw.Padding(
                  padding: const pw.EdgeInsets.symmetric(
                      horizontal: 8, vertical: 4),
                  child: pw.Text('${_kMoodEmojis[i]}  ${_kMoodLabels[i]}',
                      style: pw.TextStyle(font: font, fontSize: 10))),
              pw.Padding(
                  padding: const pw.EdgeInsets.symmetric(
                      horizontal: 8, vertical: 4),
                  child: pw.Text('${dist[i]}',
                      style: pw.TextStyle(font: font, fontSize: 10))),
              pw.Padding(
                  padding: const pw.EdgeInsets.symmetric(
                      horizontal: 8, vertical: 4),
                  child: pw.Text('${pct.toStringAsFixed(0)}%',
                      style: pw.TextStyle(font: font, fontSize: 10))),
            ],
          );
        }),
      ],
    );
  }

  pw.Widget _pdfFactorTable(
      Map<String, int> factors, pw.Font font, pw.Font fontBold) {
    final sorted = factors.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    if (sorted.isEmpty) {
      return pw.Text('No factors recorded.',
          style: pw.TextStyle(
              font: font, fontSize: 10, color: PdfColors.grey500));
    }
    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
      columnWidths: {
        0: const pw.FlexColumnWidth(3),
        1: const pw.FlexColumnWidth(1.5),
      },
      children: [
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColors.orange50),
          children: ['Factor', 'Times logged']
              .map((h) => pw.Padding(
                    padding: const pw.EdgeInsets.symmetric(
                        horizontal: 8, vertical: 5),
                    child: pw.Text(h,
                        style: pw.TextStyle(
                            font: fontBold,
                            fontSize: 9,
                            color: PdfColors.deepOrange900)),
                  ))
              .toList(),
        ),
        ...sorted.asMap().entries.map((entry) {
          final i = entry.key;
          final e = entry.value;
          return pw.TableRow(
            decoration: pw.BoxDecoration(
                color: i.isEven ? PdfColors.white : PdfColors.grey50),
            children: [
              pw.Padding(
                  padding: const pw.EdgeInsets.symmetric(
                      horizontal: 8, vertical: 4),
                  child: pw.Text(e.key,
                      style: pw.TextStyle(font: font, fontSize: 10))),
              pw.Padding(
                  padding: const pw.EdgeInsets.symmetric(
                      horizontal: 8, vertical: 4),
                  child: pw.Text('${e.value}',
                      style: pw.TextStyle(font: font, fontSize: 10))),
            ],
          );
        }),
      ],
    );
  }

  pw.Widget _pdfWeekTable(
      List<_Week4> weeks, pw.Font font, pw.Font fontBold) {
    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
      children: [
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColors.blue50),
          children: ['Week', 'Entries', 'Avg Mood', 'Low Days']
              .map((h) => pw.Padding(
                    padding: const pw.EdgeInsets.symmetric(
                        horizontal: 8, vertical: 5),
                    child: pw.Text(h,
                        style: pw.TextStyle(
                            font: fontBold,
                            fontSize: 9,
                            color: PdfColors.blue900)),
                  ))
              .toList(),
        ),
        ...weeks.asMap().entries.map((entry) {
          final i = entry.key;
          final w = entry.value;
          final avg = w.entries.isEmpty
              ? '—'
              : (w.entries.map((e) => e.mood).reduce((a, b) => a + b) /
                      w.entries.length)
                  .toStringAsFixed(1);
          final low = w.entries.where((e) => e.mood <= 1).length;
          return pw.TableRow(
            decoration: pw.BoxDecoration(
                color: i.isEven ? PdfColors.white : PdfColors.grey50),
            children: [
              pw.Padding(
                  padding: const pw.EdgeInsets.symmetric(
                      horizontal: 8, vertical: 4),
                  child: pw.Text(w.label,
                      style: pw.TextStyle(font: font, fontSize: 9))),
              pw.Padding(
                  padding: const pw.EdgeInsets.symmetric(
                      horizontal: 8, vertical: 4),
                  child: pw.Text('${w.entries.length}',
                      style: pw.TextStyle(font: font, fontSize: 9))),
              pw.Padding(
                  padding: const pw.EdgeInsets.symmetric(
                      horizontal: 8, vertical: 4),
                  child: pw.Text(avg,
                      style: pw.TextStyle(font: font, fontSize: 9))),
              pw.Padding(
                  padding: const pw.EdgeInsets.symmetric(
                      horizontal: 8, vertical: 4),
                  child: pw.Text('$low',
                      style: pw.TextStyle(font: font, fontSize: 9))),
            ],
          );
        }),
      ],
    );
  }

  pw.Widget _pdfDowTable(List<double?> dow, pw.Font font, pw.Font fontBold) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
      children: [
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColors.blueGrey50),
          children: days
              .map((d) => pw.Padding(
                    padding: const pw.EdgeInsets.symmetric(
                        horizontal: 4, vertical: 5),
                    child: pw.Text(d,
                        style: pw.TextStyle(
                            font: fontBold,
                            fontSize: 9,
                            color: PdfColors.blueGrey900),
                        textAlign: pw.TextAlign.center),
                  ))
              .toList(),
        ),
        pw.TableRow(
          children: List.generate(7, (i) {
            final val = dow[i];
            return pw.Padding(
              padding:
                  const pw.EdgeInsets.symmetric(horizontal: 4, vertical: 4),
              child: pw.Text(
                  val == null ? '—' : val.toStringAsFixed(1),
                  style: pw.TextStyle(font: font, fontSize: 10),
                  textAlign: pw.TextAlign.center),
            );
          }),
        ),
      ],
    );
  }

  // ── Helpers ───────────────────────────────────────────────────

  String _mostCommonLabel(List<int> dist) {
    int max = 0, maxIdx = 2;
    for (int i = 0; i < 5; i++) {
      if (dist[i] > max) {
        max    = dist[i];
        maxIdx = i;
      }
    }
    return max == 0
        ? 'No data'
        : '${_kMoodEmojis[maxIdx]} ${_kMoodLabels[maxIdx]} ($max entries)';
  }

  String _schoolImpactNote(double schoolAvg) {
    if (_schoolCount == 0) return 'No school entries recorded';
    final diff = schoolAvg - _avgMood;
    if (diff < -0.3) {
      return 'Mood tends to be LOWER on school-related entries (−${diff.abs().toStringAsFixed(1)} vs average)';
    }
    if (diff > 0.3) {
      return 'Mood tends to be HIGHER on school-related entries (+${diff.toStringAsFixed(1)} vs average)';
    }
    return 'No significant difference vs overall average';
  }

  String _d(DateTime dt) =>
      '${dt.day.toString().padLeft(2, '0')}/'
      '${dt.month.toString().padLeft(2, '0')}/'
      '${dt.year}';

  String _today() {
    final n = DateTime.now();
    return '${n.year}-${n.month.toString().padLeft(2, '0')}-${n.day.toString().padLeft(2, '0')}';
  }

  void _snack(String msg, {bool error = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: error
          ? _coral.withValues(alpha: 0.9)
          : _teal.withValues(alpha: 0.9),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      duration: const Duration(seconds: 4),
    ));
  }

  // ── Build ─────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        foregroundColor: _text,
        elevation: 0,
        title: const Text('School Report (SENCO)',
            style: TextStyle(fontWeight: FontWeight.w600)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () {
              setState(() => _loading = true);
              _load();
            },
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: _teal))
          : ListView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
              children: [
                _buildHeader(),
                const SizedBox(height: 20),
                _buildStatsRow(),
                const SizedBox(height: 20),
                _buildMoodDist(),
                const SizedBox(height: 16),
                _buildSchoolSection(),
                const SizedBox(height: 16),
                _buildFactors(),
                const SizedBox(height: 28),
                _buildExportButton(),
                const SizedBox(height: 16),
                _buildDisclaimer(),
              ],
            ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0D2137), Color(0xFF0B0D1E)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _teal.withValues(alpha: 0.28)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('School Wellbeing Report',
            style: TextStyle(
                color: _text, fontSize: 20, fontWeight: FontWeight.w800)),
        const SizedBox(height: 6),
        Text(
          'Mood and wellbeing data for $_childName, formatted for SENCO and pastoral staff.',
          style: const TextStyle(color: _muted, fontSize: 13, height: 1.45),
        ),
        if (_firstDate != null) ...[
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: _teal.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: _teal.withValues(alpha: 0.25)),
            ),
            child: Text('${_d(_firstDate!)} – ${_d(_lastDate!)}',
                style: const TextStyle(
                    color: _teal,
                    fontSize: 12,
                    fontWeight: FontWeight.w600)),
          ),
        ],
      ]),
    );
  }

  Widget _buildStatsRow() {
    return Row(children: [
      _stat('${_entries.length}', 'entries', _blue),
      const SizedBox(width: 10),
      _stat(_avgMood.toStringAsFixed(1), 'avg mood', _purple),
      const SizedBox(width: 10),
      _stat('$_schoolCount', 'school\nmentions', _teal),
      const SizedBox(width: 10),
      _stat(
        _schoolCount > 0 ? _schoolMoodAvg.toStringAsFixed(1) : '—',
        'school\nmood avg',
        _amber,
      ),
    ]);
  }

  Widget _stat(String value, String label, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
        decoration: BoxDecoration(
          color: _panel,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.28)),
        ),
        child: Column(children: [
          Text(value,
              style: TextStyle(
                  color: color,
                  fontSize: 20,
                  fontWeight: FontWeight.w800)),
          const SizedBox(height: 4),
          Text(label,
              style: const TextStyle(color: _muted, fontSize: 10),
              textAlign: TextAlign.center),
        ]),
      ),
    );
  }

  Widget _buildMoodDist() {
    final dist  = _moodDist;
    final total = _entries.length;
    const barColors = [
      Color(0xFFFF4D4D),
      Color(0xFFFF8C42),
      Color(0xFFFFB830),
      Color(0xFF4CAF50),
      Color(0xFF00C9A7),
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _panel,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _purple.withValues(alpha: 0.28)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Row(children: [
          Icon(Icons.bar_chart_rounded, color: _purple, size: 18),
          SizedBox(width: 8),
          Text('Mood Distribution',
              style: TextStyle(
                  color: _purple,
                  fontSize: 14,
                  fontWeight: FontWeight.w700)),
        ]),
        const SizedBox(height: 14),
        ...List.generate(5, (i) {
          final pct = total == 0 ? 0.0 : dist[i] / total;
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(children: [
              SizedBox(
                width: 86,
                child: Text('${_kMoodEmojis[i]} ${_kMoodLabels[i]}',
                    style: const TextStyle(color: _text, fontSize: 12)),
              ),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: pct,
                    backgroundColor: Colors.white10,
                    valueColor:
                        AlwaysStoppedAnimation<Color>(barColors[i]),
                    minHeight: 10,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              SizedBox(
                width: 30,
                child: Text('${dist[i]}',
                    style: TextStyle(
                        color: barColors[i],
                        fontSize: 12,
                        fontWeight: FontWeight.w700),
                    textAlign: TextAlign.right),
              ),
            ]),
          );
        }),
      ]),
    );
  }

  Widget _buildSchoolSection() {
    final diff        = _schoolCount > 0 ? _schoolMoodAvg - _avgMood : 0.0;
    final impactColor = diff < -0.3 ? _coral : (diff > 0.3 ? _green : _muted);
    final impactText  = _schoolCount == 0
        ? 'School not yet cited as a factor'
        : diff < -0.3
            ? 'Mood is notably lower on school-related entries'
            : diff > 0.3
                ? 'Mood tends to be better on school-related entries'
                : 'No significant school-related mood difference';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _panel,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _teal.withValues(alpha: 0.28)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Row(children: [
          Icon(Icons.school_rounded, color: _teal, size: 18),
          SizedBox(width: 8),
          Text('School Pattern',
              style: TextStyle(
                  color: _teal,
                  fontSize: 14,
                  fontWeight: FontWeight.w700)),
        ]),
        const SizedBox(height: 12),
        _infoRow('School mentioned', '$_schoolCount entries', _teal),
        const SizedBox(height: 8),
        _infoRow(
          'Avg mood (school entries)',
          _schoolCount > 0 ? '${_schoolMoodAvg.toStringAsFixed(1)} / 4' : '—',
          _teal,
        ),
        const SizedBox(height: 8),
        _infoRow('Overall avg mood', '${_avgMood.toStringAsFixed(1)} / 4', _muted),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: impactColor.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(10),
            border:
                Border.all(color: impactColor.withValues(alpha: 0.30)),
          ),
          child: Text(impactText,
              style: TextStyle(
                  color: impactColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w600)),
        ),
      ]),
    );
  }

  Widget _infoRow(String label, String value, Color valueColor) {
    return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: const TextStyle(color: _muted, fontSize: 12)),
          Text(value,
              style: TextStyle(
                  color: valueColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w700)),
        ]);
  }

  Widget _buildFactors() {
    final sorted = _factorCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    if (sorted.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _panel,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _amber.withValues(alpha: 0.28)),
      ),
      child:
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Row(children: [
          Icon(Icons.tag_rounded, color: _amber, size: 18),
          SizedBox(width: 8),
          Text('Wellbeing Factors',
              style: TextStyle(
                  color: _amber,
                  fontSize: 14,
                  fontWeight: FontWeight.w700)),
        ]),
        const SizedBox(height: 12),
        ...sorted.map((e) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(children: [
                Expanded(
                    child: Text(e.key,
                        style: const TextStyle(
                            color: _text, fontSize: 12))),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    color: _amber.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: _amber.withValues(alpha: 0.30)),
                  ),
                  child: Text('${e.value}×',
                      style: const TextStyle(
                          color: _amber,
                          fontSize: 11,
                          fontWeight: FontWeight.w700)),
                ),
              ]),
            )),
      ]),
    );
  }

  Widget _buildExportButton() {
    final hasData = _entries.isNotEmpty;
    return GestureDetector(
      onTap: (hasData && !_building) ? _buildPdf : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          gradient: (hasData && !_building)
              ? const LinearGradient(
                  colors: [Color(0xFF00C9A7), Color(0xFF5DADEC)])
              : null,
          color: (hasData && !_building) ? null : Colors.white10,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Center(
          child: _building
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: Colors.white))
              : Row(mainAxisSize: MainAxisSize.min, children: [
                  const Icon(Icons.picture_as_pdf_rounded,
                      color: Colors.white, size: 20),
                  const SizedBox(width: 10),
                  Text(
                    hasData
                        ? 'Export School Report PDF  (${_entries.length} entries)'
                        : 'No wellbeing entries yet',
                    style: TextStyle(
                      color: hasData
                          ? Colors.white
                          : Colors.white.withValues(alpha: 0.35),
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
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
        border: Border.all(color: _amber.withValues(alpha: 0.25)),
      ),
      child: const Text(
        'Personal wellbeing log completed by the child. '
        'Not a clinical assessment, formal EHCP evidence, or medical report. '
        'For pastoral and SENCO conversations only. '
        'All data stored locally on-device — nothing transmitted externally.',
        style: TextStyle(color: _muted, fontSize: 12, height: 1.5),
      ),
    );
  }
}

// ── Internal data models ──────────────────────────────────────

class _MoodEntry {
  final DateTime timestamp;
  final int mood; // 0–4 (Awful → Amazing)
  final List<String> factors;
  final String notes;

  const _MoodEntry({
    required this.timestamp,
    required this.mood,
    required this.factors,
    required this.notes,
  });

  factory _MoodEntry.fromJson(Map<String, dynamic> json) => _MoodEntry(
        timestamp: DateTime.parse(json['timestamp'] as String),
        mood: (json['mood'] as int).clamp(0, 4),
        factors: List<String>.from(json['factors'] as List? ?? []),
        notes: json['notes'] as String? ?? '',
      );
}

class _Week4 {
  final String label;
  final List<_MoodEntry> entries;
  const _Week4({required this.label, required this.entries});
}
