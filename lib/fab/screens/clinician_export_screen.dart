import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../core/models/check_in_entry.dart';
import '../../core/repositories/check_in_repository.dart';

// ─────────────────────────────────────────────────────────────
// CLINICIAN EXPORT SCREEN
// GP Summary + PIP Evidence PDF export.
// Reads from CheckInRepository. Excludes daily check-in stubs
// (id prefix 'checkin_') so stats reflect real pain entries only.
// PDF generation: pdf package. Download: Printing.sharePdf (web-safe).
// ─────────────────────────────────────────────────────────────

class ClinicianExportScreen extends StatefulWidget {
  const ClinicianExportScreen({super.key});

  @override
  State<ClinicianExportScreen> createState() => _ClinicianExportScreenState();
}

class _ClinicianExportScreenState extends State<ClinicianExportScreen> {
  final _repo = CheckInRepository();

  List<CheckInEntry> _pain   = []; // filtered: real pain entries only
  bool _loading  = true;
  bool _building = false;

  // ── Colours ─────────────────────────────────────────────────
  static const _bg     = Color(0xFF090C18);
  static const _panel  = Color(0xFF13172A);
  static const _text   = Color(0xFFF2EFFF);
  static const _muted  = Color(0xFFAAABC8);
  static const _blue   = Color(0xFF5DADEC);
  static const _purple = Color(0xFF8D6CFF);
  static const _amber  = Color(0xFFFFC857);
  static const _coral  = Color(0xFFFF6B6B);

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final entries = await _repo.getAllEntries();
    if (!mounted) return;
    setState(() {
      _pain = entries.where((e) => !e.id.startsWith('checkin_')).toList();
      _loading = false;
    });
  }

  // ── Derived stats (pain entries only) ───────────────────────

  double get _avgPain {
    if (_pain.isEmpty) return 0;
    return _pain.map((e) => e.painRating).reduce((a, b) => a + b) / _pain.length;
  }

  double get _avgNerve {
    if (_pain.isEmpty) return 0;
    return _pain.map((e) => e.nerveSymptomRating).reduce((a, b) => a + b) / _pain.length;
  }

  int get _peakPain => _pain.isEmpty ? 0 :
      _pain.map((e) => e.painRating).reduce((a, b) => a > b ? a : b);

  int get _highPainCount => _pain.where((e) => e.painRating >= 7).length;

  double get _highPainPct =>
      _pain.isEmpty ? 0 : (_highPainCount / _pain.length) * 100;

  DateTime? get _firstDate => _pain.isEmpty ? null : _pain.first.date;
  DateTime? get _lastDate  => _pain.isEmpty ? null : _pain.last.date;

  List<MapEntry<String, int>> _topN(
      Iterable<String> Function(CheckInEntry) fn, int n) {
    final counts = <String, int>{};
    for (final e in _pain) {
      for (final v in fn(e)) {
        counts[v] = (counts[v] ?? 0) + 1;
      }
    }
    return (counts.entries.toList()..sort((a, b) => b.value.compareTo(a.value)))
        .take(n).toList();
  }

  List<MapEntry<String, int>> get _topZones    => _topN((e) => e.painLocations, 5);
  List<MapEntry<String, int>> get _topSymptoms => _topN((e) => e.symptoms, 5);
  List<MapEntry<String, int>> get _topTriggers => _topN((e) => e.triggers, 5);

  /// Build weekly buckets for last 12 weeks (newest last).
  List<_Week> get _twelveWeeks {
    final now  = DateTime.now();
    final weeks = <_Week>[];
    for (int w = 11; w >= 0; w--) {
      final end   = now.subtract(Duration(days: w * 7));
      final start = end.subtract(const Duration(days: 6));
      final bucket = _pain.where((e) =>
          !e.date.isBefore(start) && !e.date.isAfter(end)).toList();
      weeks.add(_Week(
        label: '${start.day}/${start.month}',
        entries: bucket,
      ));
    }
    return weeks;
  }

  /// Derive a plain-English functional impact summary from trigger frequency.
  List<String> get _functionalImpact {
    final impacts = <String>[];
    final t = {for (final e in _topTriggers) e.key: e.value};
    if (t.containsKey('Sitting too long')) {
      impacts.add('Unable to sit for prolonged periods (${t['Sitting too long']}× recorded).');
    }
    if (t.containsKey('Standing too long')) {
      impacts.add('Difficulty standing for sustained periods (${t['Standing too long']}× recorded).');
    }
    if (t.containsKey('Walking')) {
      impacts.add('Walking is a consistent pain trigger (${t['Walking']}× recorded).');
    }
    if (t.containsKey('Bending')) {
      impacts.add('Bending and stooping significantly worsen symptoms (${t['Bending']}× recorded).');
    }
    if (t.containsKey('Lifting')) {
      impacts.add('Lifting exacerbates pain (${t['Lifting']}× recorded).');
    }
    if (t.containsKey('Poor sleep')) {
      impacts.add('Pain is disrupting sleep quality (${t['Poor sleep']}× recorded).');
    }
    if (impacts.isEmpty) {
      impacts.add('Specific functional triggers not yet recorded. See notes for detail.');
    }
    return impacts;
  }

  // ── PDF generation ───────────────────────────────────────────

  Future<void> _buildPdf() async {
    if (_pain.isEmpty) {
      _snack('No pain entries to export.', error: true);
      return;
    }
    setState(() => _building = true);

    try {
      final doc = pw.Document();
      final font      = await PdfGoogleFonts.interRegular();
      final fontBold  = await PdfGoogleFonts.interBold();
      final weeks     = _twelveWeeks;
      final impacts   = _functionalImpact;
      final dateRange = _firstDate == null
          ? 'No data'
          : '${_fmt(_firstDate!)} – ${_fmt(_lastDate!)}';

      doc.addPage(pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(36),
        theme: pw.ThemeData.withFont(base: font, bold: fontBold),
        header: (_) => _pdfHeader(fontBold, dateRange),
        footer: (ctx) => _pdfFooter(ctx, font),
        build: (ctx) => [

          // ── GP Summary ───────────────────────────────────────
          _pdfSectionTitle('GP Summary', fontBold, PdfColors.indigo700),
          pw.SizedBox(height: 8),
          _pdfKeyValueTable([
            ['Date range',         dateRange],
            ['Total pain entries', '${_pain.length}'],
            ['Average pain score', '${_avgPain.toStringAsFixed(1)} / 10'],
            ['Average nerve score','${_avgNerve.toStringAsFixed(1)} / 10'],
            ['Peak pain score',    '$_peakPain / 10'],
            ['High pain days (≥7)','$_highPainCount  (${_highPainPct.toStringAsFixed(0)}% of entries)'],
          ], font, fontBold),
          pw.SizedBox(height: 14),

          if (_topZones.isNotEmpty) ...[
            _pdfSubtitle('Most affected body zones', fontBold),
            pw.SizedBox(height: 4),
            _pdfBullets(_topZones.map((e) => '${e.key}  (${e.value}×)').toList(), font),
            pw.SizedBox(height: 10),
          ],

          if (_topSymptoms.isNotEmpty) ...[
            _pdfSubtitle('Most reported symptoms', fontBold),
            pw.SizedBox(height: 4),
            _pdfBullets(_topSymptoms.map((e) => '${e.key}  (${e.value}×)').toList(), font),
            pw.SizedBox(height: 10),
          ],

          if (_topTriggers.isNotEmpty) ...[
            _pdfSubtitle('Most reported triggers', fontBold),
            pw.SizedBox(height: 4),
            _pdfBullets(_topTriggers.map((e) => '${e.key}  (${e.value}×)').toList(), font),
            pw.SizedBox(height: 14),
          ],

          // ── PIP Evidence ─────────────────────────────────────
          pw.Divider(color: PdfColors.grey400),
          pw.SizedBox(height: 10),
          _pdfSectionTitle('PIP Evidence', fontBold, PdfColors.deepPurple700),
          pw.SizedBox(height: 8),

          _pdfKeyValueTable([
            ['High pain days (pain ≥ 7)',
             '$_highPainCount out of ${_pain.length} entries (${_highPainPct.toStringAsFixed(0)}%)'],
            ['Meets "majority of days" threshold (>50%)',
             _highPainPct > 50 ? 'YES — pain ≥ 7 on majority of recorded days'
                               : 'NOT YET — $_highPainCount / ${_pain.length} entries at ≥ 7'],
          ], font, fontBold),
          pw.SizedBox(height: 10),

          _pdfSubtitle('Functional impact (derived from recorded triggers)', fontBold),
          pw.SizedBox(height: 4),
          _pdfBullets(impacts, font),
          pw.SizedBox(height: 14),

          // ── 12-week timeline ─────────────────────────────────
          pw.Divider(color: PdfColors.grey400),
          pw.SizedBox(height: 10),
          _pdfSectionTitle('12-Week Pain Timeline', fontBold, PdfColors.teal700),
          pw.SizedBox(height: 8),

          _pdfTimelineTable(weeks, font, fontBold),

          pw.SizedBox(height: 10),
          pw.Text(
            'Pain and nerve scores are 0–10 self-reported. '
            'Empty weeks indicate no entries logged.',
            style: pw.TextStyle(font: font, fontSize: 8, color: PdfColors.grey600),
          ),
        ],
      ));

      final bytes = await doc.save();
      final fileName =
          'nova_clinical_report_${_today()}.pdf';
      await Printing.sharePdf(bytes: bytes, filename: fileName);
      _snack('PDF exported — $fileName');
    } catch (e) {
      _snack('Export failed: $e', error: true);
    } finally {
      if (mounted) setState(() => _building = false);
    }
  }

  // ── PDF widget helpers ───────────────────────────────────────

  pw.Widget _pdfHeader(pw.Font fontBold, String dateRange) {
    return pw.Container(
      padding: const pw.EdgeInsets.only(bottom: 8),
      decoration: const pw.BoxDecoration(
        border: pw.Border(bottom: pw.BorderSide(color: PdfColors.indigo200, width: 0.5)),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text('NOVA — Clinical Pain Report',
              style: pw.TextStyle(font: fontBold, fontSize: 11,
                  color: PdfColors.indigo800)),
          pw.Text('Generated ${_fmt(DateTime.now())}',
              style: pw.TextStyle(fontSize: 9, color: PdfColors.grey600)),
        ],
      ),
    );
  }

  pw.Widget _pdfFooter(pw.Context ctx, pw.Font font) {
    return pw.Container(
      padding: const pw.EdgeInsets.only(top: 6),
      decoration: const pw.BoxDecoration(
        border: pw.Border(top: pw.BorderSide(color: PdfColors.grey300, width: 0.5)),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text('Personal tracking record — not a clinical diagnosis.',
              style: pw.TextStyle(font: font, fontSize: 8, color: PdfColors.grey500)),
          pw.Text('Page ${ctx.pageNumber} of ${ctx.pagesCount}',
              style: pw.TextStyle(font: font, fontSize: 8, color: PdfColors.grey500)),
        ],
      ),
    );
  }

  pw.Widget _pdfSectionTitle(String title, pw.Font fontBold, PdfColor color) {
    return pw.Text(title,
        style: pw.TextStyle(font: fontBold, fontSize: 15, color: color));
  }

  pw.Widget _pdfSubtitle(String title, pw.Font fontBold) {
    return pw.Text(title,
        style: pw.TextStyle(font: fontBold, fontSize: 10, color: PdfColors.grey800));
  }

  pw.Widget _pdfBullets(List<String> items, pw.Font font) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: items.map((item) => pw.Padding(
        padding: const pw.EdgeInsets.only(bottom: 3, left: 10),
        child: pw.Row(children: [
          pw.Text('• ', style: pw.TextStyle(font: font, fontSize: 10)),
          pw.Flexible(child: pw.Text(item,
              style: pw.TextStyle(font: font, fontSize: 10))),
        ]),
      )).toList(),
    );
  }

  pw.Widget _pdfKeyValueTable(
      List<List<String>> rows, pw.Font font, pw.Font fontBold) {
    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
      columnWidths: {
        0: const pw.FlexColumnWidth(2),
        1: const pw.FlexColumnWidth(3),
      },
      children: rows.map((row) => pw.TableRow(children: [
        pw.Padding(
          padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 5),
          child: pw.Text(row[0],
              style: pw.TextStyle(font: fontBold, fontSize: 10)),
        ),
        pw.Padding(
          padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 5),
          child: pw.Text(row[1],
              style: pw.TextStyle(font: font, fontSize: 10)),
        ),
      ])).toList(),
    );
  }

  pw.Widget _pdfTimelineTable(
      List<_Week> weeks, pw.Font font, pw.Font fontBold) {
    final headers = ['Week', 'Entries', 'Avg Pain', 'Avg Nerve', 'Peak', 'High Pain Days'];
    final rows = weeks.map((w) {
      if (w.entries.isEmpty) {
        return [w.label, '0', '—', '—', '—', '0'];
      }
      final avgP = w.entries.map((e) => e.painRating).reduce((a, b) => a + b) /
          w.entries.length;
      final avgN = w.entries.map((e) => e.nerveSymptomRating).reduce((a, b) => a + b) /
          w.entries.length;
      final peak = w.entries.map((e) => e.painRating).reduce((a, b) => a > b ? a : b);
      final high = w.entries.where((e) => e.painRating >= 7).length;
      return [
        w.label,
        '${w.entries.length}',
        avgP.toStringAsFixed(1),
        avgN.toStringAsFixed(1),
        '$peak',
        '$high',
      ];
    }).toList();

    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
      children: [
        // Header row
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColors.indigo50),
          children: headers.map((h) => pw.Padding(
            padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 5),
            child: pw.Text(h,
                style: pw.TextStyle(font: fontBold, fontSize: 9,
                    color: PdfColors.indigo900)),
          )).toList(),
        ),
        // Data rows
        ...rows.asMap().entries.map((entry) {
          final shade = entry.key.isEven ? PdfColors.white : PdfColors.grey50;
          return pw.TableRow(
            decoration: pw.BoxDecoration(color: shade),
            children: entry.value.map((cell) => pw.Padding(
              padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 4),
              child: pw.Text(cell,
                  style: pw.TextStyle(font: font, fontSize: 9)),
            )).toList(),
          );
        }),
      ],
    );
  }

  // ── Utilities ────────────────────────────────────────────────

  String _fmt(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/'
      '${d.month.toString().padLeft(2, '0')}/'
      '${d.year}';

  String _today() {
    final n = DateTime.now();
    return '${n.year}-${n.month.toString().padLeft(2, '0')}'
        '-${n.day.toString().padLeft(2, '0')}';
  }

  void _snack(String msg, {bool error = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: error
          ? _coral.withValues(alpha: 0.9)
          : _blue.withValues(alpha: 0.9),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      duration: const Duration(seconds: 4),
    ));
  }

  // ── Build ────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        foregroundColor: _text,
        elevation: 0,
        title: const Text('Clinical PDF Export',
            style: TextStyle(fontWeight: FontWeight.w600)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () { setState(() => _loading = true); _load(); },
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: _blue))
          : ListView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
              children: [
                _buildHeader(),
                const SizedBox(height: 20),
                _buildStatsRow(),
                const SizedBox(height: 24),
                _buildSection(
                  icon: Icons.medical_information_rounded,
                  color: _blue,
                  title: 'GP Summary',
                  items: [
                    'Average pain score: ${_avgPain.toStringAsFixed(1)} / 10',
                    'Average nerve score: ${_avgNerve.toStringAsFixed(1)} / 10',
                    'Peak pain score: $_peakPain / 10',
                    if (_topZones.isNotEmpty)
                      'Top zone: ${_topZones.first.key}',
                    if (_topSymptoms.isNotEmpty)
                      'Top symptom: ${_topSymptoms.first.key}',
                    if (_topTriggers.isNotEmpty)
                      'Top trigger: ${_topTriggers.first.key}',
                  ],
                ),
                const SizedBox(height: 12),
                _buildSection(
                  icon: Icons.gavel_rounded,
                  color: _purple,
                  title: 'PIP Evidence',
                  items: [
                    'High pain days (≥ 7): $_highPainCount'
                        ' (${_highPainPct.toStringAsFixed(0)}%)',
                    _highPainPct > 50
                        ? '✓ Meets majority-of-days threshold'
                        : '✗ Below majority-of-days threshold so far',
                    ..._functionalImpact.take(3),
                  ],
                ),
                const SizedBox(height: 12),
                _buildSection(
                  icon: Icons.calendar_month_rounded,
                  color: _amber,
                  title: '12-Week Timeline',
                  items: _twelveWeeks
                      .where((w) => w.entries.isNotEmpty)
                      .map((w) {
                        final avg = w.entries
                                .map((e) => e.painRating)
                                .reduce((a, b) => a + b) /
                            w.entries.length;
                        return 'w/c ${w.label}: avg ${avg.toStringAsFixed(1)}'
                            '  (${w.entries.length} entries)';
                      })
                      .toList(),
                ),
                const SizedBox(height: 28),
                _buildDownloadButton(),
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
          colors: [Color(0xFF1A1E3A), Color(0xFF0D1020)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _blue.withValues(alpha: 0.28)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Clinical PDF Report',
            style: TextStyle(color: _text, fontSize: 20,
                fontWeight: FontWeight.w800)),
        const SizedBox(height: 6),
        Text(
          'GP Summary and PIP Evidence from your pain logs, '
          'exported as a formatted PDF ready for appointments.',
          style: TextStyle(color: _muted, fontSize: 13, height: 1.45),
        ),
        if (_firstDate != null) ...[
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: _blue.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: _blue.withValues(alpha: 0.25)),
            ),
            child: Text('${_fmt(_firstDate!)} – ${_fmt(_lastDate!)}',
                style: const TextStyle(color: _blue, fontSize: 12,
                    fontWeight: FontWeight.w600)),
          ),
        ],
      ]),
    );
  }

  Widget _buildStatsRow() {
    return Row(children: [
      _statChip('${_pain.length}',   'entries',  _blue),
      const SizedBox(width: 10),
      _statChip(_avgPain.toStringAsFixed(1), 'avg pain', _amber),
      const SizedBox(width: 10),
      _statChip('$_highPainCount',   'high days', _coral),
      const SizedBox(width: 10),
      _statChip('${_highPainPct.toStringAsFixed(0)}%', '≥7 days', _purple),
    ]);
  }

  Widget _statChip(String value, String label, Color color) {
    return Expanded(child: Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
      decoration: BoxDecoration(
        color: _panel,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.28)),
      ),
      child: Column(children: [
        Text(value,
            style: TextStyle(color: color, fontSize: 20,
                fontWeight: FontWeight.w800)),
        Text(label,
            style: const TextStyle(color: _muted, fontSize: 10)),
      ]),
    ));
  }

  Widget _buildSection({
    required IconData icon,
    required Color color,
    required String title,
    required List<String> items,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _panel,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.28)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 8),
          Text(title,
              style: TextStyle(color: color, fontSize: 14,
                  fontWeight: FontWeight.w700)),
        ]),
        const SizedBox(height: 10),
        ...items.map((item) => Padding(
          padding: const EdgeInsets.only(bottom: 5),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('• ', style: TextStyle(color: color, fontSize: 12)),
            Expanded(child: Text(item,
                style: const TextStyle(color: _text, fontSize: 12,
                    height: 1.4))),
          ]),
        )),
        if (items.isEmpty)
          Text('No data yet.',
              style: const TextStyle(color: _muted, fontSize: 12)),
      ]),
    );
  }

  Widget _buildDownloadButton() {
    final hasData = _pain.isNotEmpty;
    return GestureDetector(
      onTap: (hasData && !_building) ? _buildPdf : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          gradient: (hasData && !_building)
              ? const LinearGradient(
                  colors: [Color(0xFF5DADEC), Color(0xFF8D6CFF)])
              : null,
          color: (hasData && !_building) ? null : Colors.white10,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Center(
          child: _building
              ? const SizedBox(
                  width: 20, height: 20,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: Colors.white))
              : Row(mainAxisSize: MainAxisSize.min, children: [
                  const Icon(Icons.picture_as_pdf_rounded,
                      color: Colors.white, size: 20),
                  const SizedBox(width: 10),
                  Text(
                    hasData
                        ? 'Download Clinical PDF  (${_pain.length} entries)'
                        : 'No pain entries to export',
                    style: TextStyle(
                      color: hasData ? Colors.white
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
        'Personal tracking record for diagnostic reference only. '
        'Not a clinical diagnosis. All data is stored locally on-device. '
        'Nothing is transmitted without your explicit action.',
        style: TextStyle(color: _muted, fontSize: 12, height: 1.5),
      ),
    );
  }
}

// ── Internal data model ──────────────────────────────────────

class _Week {
  final String label;
  final List<CheckInEntry> entries;
  const _Week({required this.label, required this.entries});
}
