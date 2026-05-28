import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../models/child_profile.dart';
import '../services/storage_service.dart';

// ─────────────────────────────────────────────────────────────
// ReportService
//
// Generates a PDF wellbeing report for a given child and period.
//
// Sections available:
//   sleep  — always offered, on by default
//   mood   — always offered, on by default
//   health — always offered, on by default
//
// Journal is NEVER included. It is not offered as a toggle.
// A "self-reported data" disclaimer appears in every footer.
// ─────────────────────────────────────────────────────────────

enum ReportPeriod { week, month, threeMonths }

extension ReportPeriodLabel on ReportPeriod {
  String get label {
    switch (this) {
      case ReportPeriod.week:        return 'Last 7 days';
      case ReportPeriod.month:       return 'Last 30 days';
      case ReportPeriod.threeMonths: return 'Last 3 months';
    }
  }

  Duration get duration {
    switch (this) {
      case ReportPeriod.week:        return const Duration(days: 7);
      case ReportPeriod.month:       return const Duration(days: 30);
      case ReportPeriod.threeMonths: return const Duration(days: 91);
    }
  }
}

class ReportConfig {
  final ChildProfile child;
  final ReportPeriod period;
  final bool includeSleep;
  final bool includeMood;
  final bool includeHealth;

  const ReportConfig({
    required this.child,
    required this.period,
    this.includeSleep  = true,
    this.includeMood   = true,
    this.includeHealth = true,
  });

  ReportConfig copyWith({
    ReportPeriod? period,
    bool? includeSleep,
    bool? includeMood,
    bool? includeHealth,
  }) => ReportConfig(
    child:          child,
    period:         period          ?? this.period,
    includeSleep:   includeSleep    ?? this.includeSleep,
    includeMood:    includeMood     ?? this.includeMood,
    includeHealth:  includeHealth   ?? this.includeHealth,
  );

  List<String> get activeSections => [
    if (includeSleep)  'sleep',
    if (includeMood)   'mood',
    if (includeHealth) 'health',
  ];
}

class ReportService {
  ReportService._();

  static Future<Uint8List> buildPdf(ReportConfig config) async {
    final now   = DateTime.now();
    final since = now.subtract(config.period.duration);

    // ── Fetch data ───────────────────────────────────────────
    final allEntries = StorageService.allDataEntries(config.child.id);
    final entries = allEntries.where((e) {
      final ts = DateTime.tryParse(e['timestamp'] as String? ?? '');
      if (ts == null) return false;
      if (ts.isBefore(since)) return false;
      final type = e['type'] as String? ?? '';
      return config.activeSections.contains(type);
    }).toList()
      ..sort((a, b) {
        final ta = DateTime.tryParse(a['timestamp'] as String? ?? '') ??
            DateTime(0);
        final tb = DateTime.tryParse(b['timestamp'] as String? ?? '') ??
            DateTime(0);
        return ta.compareTo(tb);
      });

    // ── Compute simple stats ────────────────────────────────
    final sleepEntries = entries.where((e) => e['type'] == 'sleep').toList();
    final moodEntries  = entries.where((e) => e['type'] == 'mood').toList();

    final sleepVals = sleepEntries
        .map((e) => (e['hours'] as num?)?.toDouble())
        .whereType<double>()
        .toList();
    final avgSleep = sleepVals.isEmpty
        ? null
        : sleepVals.reduce((a, b) => a + b) / sleepVals.length;

    // ── Colours ──────────────────────────────────────────────
    final purple  = PdfColor.fromHex('#6C63FF');
    final teal    = PdfColor.fromHex('#00C9A7');
    final pink    = PdfColor.fromHex('#FF6B8A');
    final amber   = PdfColor.fromHex('#FFB830');
    final dark    = PdfColor.fromHex('#0D0820');
    const white   = PdfColors.white;
    final grey    = PdfColor.fromHex('#8877AA');
    final lightBg = PdfColor.fromHex('#F4F0FC');

    // ── Build PDF ────────────────────────────────────────────
    final doc = pw.Document(
      title: 'Wellbeing Report — ${config.child.name}',
      author: 'Fabulously Me',
    );

    doc.addPage(pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(40),
      footer: (ctx) => _footer(ctx, config, grey, lightBg),
      build: (ctx) => [
        _header(config, dark, purple, white, teal, now),
        pw.SizedBox(height: 20),
        if (avgSleep != null || moodEntries.isNotEmpty)
          _summaryRow(avgSleep, moodEntries.length, sleepEntries.length,
              purple, teal, amber, lightBg),
        if (avgSleep != null || moodEntries.isNotEmpty)
          pw.SizedBox(height: 20),
        if (config.includeSleep && sleepEntries.isNotEmpty)
          ..._section('Sleep', sleepEntries, purple, lightBg),
        if (config.includeMood && moodEntries.isNotEmpty)
          ..._section('Mood', moodEntries, pink, lightBg),
        if (config.includeHealth)
          ..._section(
              'Health',
              entries.where((e) => e['type'] == 'health').toList(),
              teal,
              lightBg),
        if (entries.isEmpty) _emptyState(grey),
      ],
    ));

    return doc.save();
  }

  // ── PDF widgets ───────────────────────────────────────────

  static pw.Widget _header(
    ReportConfig config,
    PdfColor dark,
    PdfColor purple,
    PdfColor white,
    PdfColor teal,
    DateTime now,
  ) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(20),
      decoration: pw.BoxDecoration(
        color: dark,
        borderRadius: pw.BorderRadius.circular(12),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'Wellbeing Report',
                style: pw.TextStyle(
                  color: white,
                  fontSize: 22,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 4),
              pw.Text(
                config.child.name,
                style: pw.TextStyle(
                  color: teal,
                  fontSize: 15,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 2),
              pw.Text(
                '${config.child.ageMode.label} · ${config.child.age} years old',
                style: pw.TextStyle(color: white.shade(.6), fontSize: 11),
              ),
            ],
          ),
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.Text(
                config.period.label,
                style: pw.TextStyle(
                  color: purple,
                  fontSize: 12,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 4),
              pw.Text(
                'Generated ${_fmtDate(now)}',
                style: pw.TextStyle(color: white.shade(.5), fontSize: 10),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static pw.Widget _summaryRow(
    double? avgSleep,
    int moodCount,
    int sleepCount,
    PdfColor purple,
    PdfColor teal,
    PdfColor amber,
    PdfColor bg,
  ) {
    return pw.Row(
      children: [
        if (avgSleep != null)
          pw.Expanded(flex: 1, child: _StatBox(
            label: 'Avg sleep',
            value: '${avgSleep.toStringAsFixed(1)}h',
            color: purple,
            bg: bg,
          )),
        if (avgSleep != null) pw.SizedBox(width: 10),
        pw.Expanded(flex: 1, child: _StatBox(
          label: 'Sleep logs',
          value: '$sleepCount',
          color: teal,
          bg: bg,
        )),
        pw.SizedBox(width: 10),
        pw.Expanded(flex: 1, child: _StatBox(
          label: 'Mood logs',
          value: '$moodCount',
          color: amber,
          bg: bg,
        )),
      ],
    );
  }

  static List<pw.Widget> _section(
    String title,
    List<Map<String, dynamic>> entries,
    PdfColor color,
    PdfColor bg,
  ) {
    if (entries.isEmpty) return [];
    return [
      pw.Container(
        padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: pw.BoxDecoration(
          color: color.shade(.15),
          borderRadius: pw.BorderRadius.circular(8),
        ),
        child: pw.Text(
          title,
          style: pw.TextStyle(
            color: color,
            fontSize: 13,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
      ),
      pw.SizedBox(height: 6),
      ...entries.map((e) => _entryRow(e, color, bg)),
      pw.SizedBox(height: 16),
    ];
  }

  static pw.Widget _entryRow(
    Map<String, dynamic> entry,
    PdfColor color,
    PdfColor bg,
  ) {
    final summary = entry['summary'] as String?
        ?? entry['observation'] as String?
        ?? '—';
    final tsStr = entry['timestamp'] as String? ?? '';
    final dt    = DateTime.tryParse(tsStr);

    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 4),
      padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: pw.BoxDecoration(
        color: bg,
        borderRadius: pw.BorderRadius.circular(6),
      ),
      child: pw.Row(
        children: [
          pw.Expanded(
            child: pw.Text(summary,
                style: const pw.TextStyle(fontSize: 11)),
          ),
          if (dt != null)
            pw.Text(
              _fmtDate(dt),
              style: pw.TextStyle(
                  fontSize: 10, color: PdfColors.grey600),
            ),
        ],
      ),
    );
  }

  static pw.Widget _emptyState(PdfColor grey) {
    return pw.Center(
      child: pw.Padding(
        padding: const pw.EdgeInsets.all(32),
        child: pw.Text(
          'No data recorded in this period.',
          style: pw.TextStyle(color: grey, fontSize: 13),
        ),
      ),
    );
  }

  static pw.Widget _footer(
    pw.Context ctx,
    ReportConfig config,
    PdfColor grey,
    PdfColor bg,
  ) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 0, vertical: 6),
      decoration: pw.BoxDecoration(
        border: pw.Border(
            top: pw.BorderSide(color: grey.shade(.3), width: 0.5)),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Expanded(
            child: pw.Text(
              'Self-reported data — ${config.child.name} · Fabulously Me app. '
              'Journal and Safe Corner are not included in this report.',
              style: pw.TextStyle(color: grey, fontSize: 8, fontStyle: pw.FontStyle.italic),
            ),
          ),
          pw.Text(
            'Page ${ctx.pageNumber} of ${ctx.pagesCount}',
            style: pw.TextStyle(color: grey, fontSize: 8),
          ),
        ],
      ),
    );
  }

  static String _fmtDate(DateTime dt) =>
      '${dt.day.toString().padLeft(2, '0')}/'
      '${dt.month.toString().padLeft(2, '0')}/'
      '${dt.year}';
}

// ── Inline stat box widget for PDF ───────────────────────────

class _StatBox extends pw.StatelessWidget {
  final String label;
  final String value;
  final PdfColor color;
  final PdfColor bg;

  _StatBox({
    required this.label,
    required this.value,
    required this.color,
    required this.bg,
  });

  @override
  pw.Widget build(pw.Context context) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        color: bg,
        borderRadius: pw.BorderRadius.circular(8),
        border: pw.Border.all(color: color.shade(.3), width: 0.5),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(value,
              style: pw.TextStyle(
                color: color,
                fontSize: 18,
                fontWeight: pw.FontWeight.bold,
              )),
          pw.SizedBox(height: 2),
          pw.Text(label,
              style: pw.TextStyle(
                  color: PdfColors.grey600, fontSize: 10)),
        ],
      ),
    );
  }
}
