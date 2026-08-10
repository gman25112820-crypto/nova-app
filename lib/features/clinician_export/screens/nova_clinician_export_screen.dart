import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/models/check_in_entry.dart';
import '../../../core/repositories/check_in_repository.dart';

// ─────────────────────────────────────────────────────────────────────────────
// NOVA CLINICIAN EXPORT SCREEN
//
// Pulls from:
//   • SharedPreferences 'nova_health_profile'  — personal / medical details
//   • Hive 'checkins' via CheckInRepository    — pain, nerve, medication logs
//
// Generates a structured A4 PDF suitable for GP appointments, pain clinic
// referrals, PIP evidence, or any care-team context where a written summary
// is useful.
//
// All data stays on device. Nothing is transmitted. Sharing is user-initiated
// via the device's native share sheet / print dialog.
// ─────────────────────────────────────────────────────────────────────────────

enum _ExportRange { days7, days30, days90, allTime }

class NovaClinicianExportScreen extends StatefulWidget {
  const NovaClinicianExportScreen({super.key});

  @override
  State<NovaClinicianExportScreen> createState() =>
      _NovaClinicianExportScreenState();
}

class _NovaClinicianExportScreenState
    extends State<NovaClinicianExportScreen> {
  // ── Palette (Nova dark) ──────────────────────────────────────
  static const _bg     = Color(0xFF0D1020);
  static const _panel  = Color(0xFF171A2E);
  static const _border = Color(0xFF252845);
  static const _text   = Color(0xFFF7F4FF);
  static const _muted  = Color(0xFFB9AECF);
  static const _blue   = Color(0xFF5DADEC);
  static const _purple = Color(0xFF8D6CFF);
  static const _rose   = Color(0xFFFF6FAE);
  static const _teal   = Color(0xFF46D6C8);
  static const _amber  = Color(0xFFFFC857);
  static const _green  = Color(0xFF7EC87A);

  // ── State ────────────────────────────────────────────────────
  _ExportRange          _range    = _ExportRange.days30;
  bool                  _loading  = true;
  bool                  _building = false;
  Map<String, dynamic>  _profile  = {};
  List<CheckInEntry>    _allEntries = [];

  // ── Label lookup ─────────────────────────────────────────────
  static const _monthLabels = [
    'Jan','Feb','Mar','Apr','May','Jun',
    'Jul','Aug','Sep','Oct','Nov','Dec',
  ];

  @override
  void initState() {
    super.initState();
    _load();
  }

  // ── Data loading ─────────────────────────────────────────────

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();

    // Health Profile
    final raw = prefs.getString('nova_health_profile');
    Map<String, dynamic> profile = {};
    if (raw != null) {
      try {
        profile = jsonDecode(raw) as Map<String, dynamic>;
      } catch (_) {}
    }

    // Check-in entries
    if (!Hive.isBoxOpen('checkins')) {
      await Hive.openBox<Map>('checkins');
    }
    final entries = await CheckInRepository().getAllEntries();

    if (!mounted) return;
    setState(() {
      _profile    = profile;
      _allEntries = entries;
      _loading    = false;
    });
  }

  // ── Date filtering ────────────────────────────────────────────

  DateTime get _cutoff {
    final now = DateTime.now();
    switch (_range) {
      case _ExportRange.days7:   return now.subtract(const Duration(days: 7));
      case _ExportRange.days30:  return now.subtract(const Duration(days: 30));
      case _ExportRange.days90:  return now.subtract(const Duration(days: 90));
      case _ExportRange.allTime: return DateTime(2000);
    }
  }

  String get _rangeLabel {
    switch (_range) {
      case _ExportRange.days7:   return 'Last 7 days';
      case _ExportRange.days30:  return 'Last 30 days';
      case _ExportRange.days90:  return 'Last 3 months';
      case _ExportRange.allTime: return 'All available data';
    }
  }

  List<CheckInEntry> get _entries =>
      _allEntries.where((e) => e.date.isAfter(_cutoff)).toList()
        ..sort((a, b) => a.date.compareTo(b.date));

  // ── Derived stats ─────────────────────────────────────────────

  double get _avgPain {
    final e = _entries;
    if (e.isEmpty) return 0;
    return e.map((x) => x.painRating).reduce((a, b) => a + b) / e.length;
  }

  double get _avgNerve {
    final e = _entries;
    if (e.isEmpty) return 0;
    return e.map((x) => x.nerveSymptomRating).reduce((a, b) => a + b) /
        e.length;
  }

  /// Returns 0.0–1.0 adherence fraction, or null if no entries have
  /// the medicationTaken field set.
  double? get _medAdherence {
    final withMed =
        _entries.where((e) => e.medicationTaken != null).toList();
    if (withMed.isEmpty) return null;
    final taken = withMed.where((e) => e.medicationTaken!).length;
    return taken / withMed.length;
  }

  /// Returns (firstHalfAvg, secondHalfAvg) based on chronological halves.
  (double?, double?) _halves(List<double> vals) {
    if (vals.isEmpty) return (null, null);
    final mid  = (vals.length / 2).ceil();
    final fst  = vals.take(mid).toList();
    final snd  = vals.skip(mid).toList();
    return (
      fst.reduce((a, b) => a + b) / fst.length,
      snd.isEmpty ? null : snd.reduce((a, b) => a + b) / snd.length,
    );
  }

  Map<String, int> _frequency(Iterable<List<String>> lists) {
    final counts = <String, int>{};
    for (final list in lists) {
      for (final item in list) {
        counts[item] = (counts[item] ?? 0) + 1;
      }
    }
    final sorted = counts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return Map.fromEntries(sorted);
  }

  /// Averages [getter] across [entries], skipping nulls.
  /// Returns null if no entry has this field set.
  double? _avgOf(
      List<CheckInEntry> entries, int? Function(CheckInEntry) getter) {
    final vals = entries.map(getter).whereType<int>().toList();
    if (vals.isEmpty) return null;
    return vals.reduce((a, b) => a + b) / vals.length;
  }

  // ── Profile helpers ───────────────────────────────────────────

  String _pStr(String key) =>
      (_profile[key] as String?)?.trim() ?? '';

  List<String> _pList(String key) =>
      List<String>.from((_profile[key] as List?) ?? []);

  List<String> get _allConditions =>
      [..._pList('conditions'), ..._pList('customConditions')];

  List<String> get _allAllergies =>
      [..._pList('allergies'), ..._pList('customAllergies')];

  List<String> get _allAccess =>
      [..._pList('accessNeeds'), ..._pList('customAccess')];

  // ── Date formatting ───────────────────────────────────────────

  String _fmtDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')} '
      '${_monthLabels[d.month - 1]} '
      '${d.year}';

  String _fmtDateShort(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/'
      '${d.month.toString().padLeft(2, '0')}/'
      '${d.year}';

  String _today() {
    final n = DateTime.now();
    return '${n.year}-${n.month.toString().padLeft(2, '0')}'
        '-${n.day.toString().padLeft(2, '0')}';
  }

  // ── PDF generation ────────────────────────────────────────────

  Future<void> _buildPdf() async {
    setState(() => _building = true);
    try {
      final doc      = pw.Document();
      final font     = await PdfGoogleFonts.interRegular();
      final fontBold = await PdfGoogleFonts.interBold();
      final fontItal = await PdfGoogleFonts.interItalic();

      final entries    = _entries;
      final today      = _fmtDate(DateTime.now());
      final periodStr  = _range == _ExportRange.allTime
          ? 'All available records'
          : '${_fmtDate(_cutoff)} – $today';

      final name       = _pStr('name');
      final dob        = _pStr('dob');
      final pronouns   = _pStr('pronouns');
      final gpName     = _pStr('gpName');
      final gpPractice = _pStr('gpPractice');
      final gpPhone    = _pStr('gpPhone');
      final specName   = _pStr('specName');
      final specRole   = _pStr('specRole');
      final eName      = _pStr('emergencyName');
      final ePhone     = _pStr('emergencyPhone');
      final profNotes  = _pStr('notes');

      final conditions = _allConditions;
      final medications = _pList('medications');
      final allergies  = _allAllergies;
      final access     = _allAccess;

      final avgPain    = _avgPain;
      final avgNerve   = _avgNerve;
      final medAd      = _medAdherence;

      final painVals   = entries.map((e) => e.painRating.toDouble()).toList();
      final nerveVals  = entries
          .map((e) => e.nerveSymptomRating.toDouble())
          .toList();

      final (painF, painS)  = _halves(painVals);
      final (nerveF, nerveS) = _halves(nerveVals);

      final symptomFreq  = _frequency(entries.map((e) => e.symptoms));
      final triggerFreq  = _frequency(entries.map((e) => e.triggers));
      final locationFreq = _frequency(entries.map((e) => e.painLocations));

      final noteEntries = entries
          .where((e) => e.notes.trim().isNotEmpty)
          .toList();

      final avgMobility = _avgOf(entries, (e) => e.mobilityScore);
      final avgWalking  = _avgOf(entries, (e) => e.walkingTolerance);
      final avgSitting  = _avgOf(entries, (e) => e.sittingTolerance);
      final avgStanding = _avgOf(entries, (e) => e.standingTolerance);

      final helpedFreq = _frequency(
          entries.where((e) => e.helped != null).map((e) => e.helped!));
      final safeStepFreq = _frequency(entries
          .where((e) => e.safeNextStep != null)
          .map((e) => [e.safeNextStep!]));

      final flareEntries = entries
          .where((e) => (e.flareNotes ?? '').trim().isNotEmpty)
          .toList();
      final medicationNoteEntries = entries
          .where((e) => (e.medicationNotes ?? '').trim().isNotEmpty)
          .toList();
      final sleepNoteEntries = entries
          .where((e) => (e.sleepNotes ?? '').trim().isNotEmpty)
          .toList();
      final gpNoteEntries = entries
          .where((e) => (e.gpNotes ?? '').trim().isNotEmpty)
          .toList();
      final evidenceNoteEntries = entries
          .where((e) => (e.evidenceNotes ?? '').trim().isNotEmpty)
          .toList();

      final hasFunctionalImpactData = avgMobility != null ||
          avgWalking != null ||
          avgSitting != null ||
          avgStanding != null ||
          helpedFreq.isNotEmpty ||
          safeStepFreq.isNotEmpty ||
          flareEntries.isNotEmpty ||
          medicationNoteEntries.isNotEmpty ||
          sleepNoteEntries.isNotEmpty ||
          gpNoteEntries.isNotEmpty ||
          evidenceNoteEntries.isNotEmpty;

      // ── Build document ──────────────────────────────────────

      doc.addPage(pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.symmetric(horizontal: 44, vertical: 38),
        theme: pw.ThemeData.withFont(base: font, bold: fontBold),
        header: (ctx) => _pdfHeader(
          fontBold: fontBold,
          font: font,
          name: name.isNotEmpty ? name : 'Patient',
          today: today,
        ),
        footer: (ctx) => _pdfFooter(ctx, font),
        build: (ctx) => [

          // ── 1. Patient Details ──────────────────────────────
          _pdfSectionTitle('1. Patient Details', fontBold,
              PdfColors.blueGrey800),
          pw.SizedBox(height: 6),
          _pdfKvTable(font: font, fontBold: fontBold, rows: [
            ['Full name / preferred name',
              name.isNotEmpty ? name : '—'],
            ['Date of birth',   dob.isNotEmpty       ? dob        : '—'],
            ['Pronouns',        pronouns.isNotEmpty  ? pronouns   : '—'],
            ['Report period',   periodStr],
            ['Date generated',  today],
          ]),
          pw.SizedBox(height: 18),

          // ── 2. Conditions & Medications ─────────────────────
          _pdfSectionTitle('2. Conditions & Medications', fontBold,
              PdfColors.indigo700),
          pw.SizedBox(height: 6),
          _pdfKvTable(font: font, fontBold: fontBold, rows: [
            ['Conditions / diagnoses',
              conditions.isEmpty ? 'None recorded' : conditions.join(', ')],
            ['Current medications',
              medications.isEmpty
                  ? 'None recorded'
                  : medications.join('\n')],
          ]),
          pw.SizedBox(height: 18),

          // ── 3. Allergies, Sensitivities & Access Needs ──────
          _pdfSectionTitle(
              '3. Allergies, Sensitivities & Access Needs',
              fontBold, PdfColors.orange700),
          pw.SizedBox(height: 6),
          _pdfKvTable(font: font, fontBold: fontBold, rows: [
            ['Allergies / sensitivities',
              allergies.isEmpty ? 'None recorded' : allergies.join(', ')],
            ['Accessibility / adjustments needed',
              access.isEmpty ? 'None recorded' : access.join(', ')],
          ]),
          pw.SizedBox(height: 18),

          // ── 4. Medical Team ─────────────────────────────────
          _pdfSectionTitle('4. Medical Team', fontBold,
              PdfColors.teal700),
          pw.SizedBox(height: 6),
          _pdfKvTable(font: font, fontBold: fontBold, rows: [
            ['GP name',          gpName.isNotEmpty     ? gpName     : '—'],
            ['GP practice',      gpPractice.isNotEmpty ? gpPractice : '—'],
            ['GP phone',         gpPhone.isNotEmpty    ? gpPhone    : '—'],
            ['Specialist',
              specName.isNotEmpty
                  ? (specRole.isNotEmpty
                      ? '$specName ($specRole)'
                      : specName)
                  : '—'],
            ['Emergency contact',
              eName.isNotEmpty
                  ? (ePhone.isNotEmpty ? '$eName — $ePhone' : eName)
                  : '—'],
          ]),
          pw.SizedBox(height: 18),

          // ── 5. Check-in Summary Statistics ──────────────────
          _pdfSectionTitle(
              '5. Check-in Summary  (${entries.length} entries — $periodStr)',
              fontBold, PdfColors.red700),
          pw.SizedBox(height: 6),
          _pdfKvTable(font: font, fontBold: fontBold, rows: [
            ['Total check-ins logged',    '${entries.length}'],
            ['Average pain intensity',
              entries.isEmpty
                  ? '—'
                  : '${avgPain.toStringAsFixed(1)} / 10'],
            ['Average nerve symptom score',
              entries.isEmpty
                  ? '—'
                  : '${avgNerve.toStringAsFixed(1)} / 10'],
            if (medAd != null)
              ['Medication adherence',
                '${(medAd * 100).round()}% of logged days'],
            ['Pain trend (first half → second half)',
              _trendText(painF, painS, lowerIsBetter: true)],
            ['Nerve trend (first half → second half)',
              _trendText(nerveF, nerveS, lowerIsBetter: true)],
          ]),
          pw.SizedBox(height: 18),

          // ── 6. Functional Impact & Daily Living ──────────────
          if (hasFunctionalImpactData) ...[
            _pdfSectionTitle('6. Functional Impact & Daily Living',
                fontBold, PdfColors.teal700),
            pw.SizedBox(height: 6),
            if (avgMobility != null ||
                avgWalking != null ||
                avgSitting != null ||
                avgStanding != null) ...[
              _pdfKvTable(font: font, fontBold: fontBold, rows: [
                if (avgMobility != null)
                  ['Mobility limitation',
                    '${avgMobility.toStringAsFixed(1)} / 10 average'],
                if (avgWalking != null)
                  ['Walking limitation',
                    '${avgWalking.toStringAsFixed(1)} / 10 average'],
                if (avgSitting != null)
                  ['Sitting limitation',
                    '${avgSitting.toStringAsFixed(1)} / 10 average'],
                if (avgStanding != null)
                  ['Standing limitation',
                    '${avgStanding.toStringAsFixed(1)} / 10 average'],
              ]),
              pw.SizedBox(height: 12),
            ],
            if (helpedFreq.isNotEmpty) ...[
              _pdfFreqTable(
                title: 'What helped',
                data: helpedFreq,
                font: font,
                fontBold: fontBold,
                headerColor: PdfColors.teal50,
                headerTextColor: PdfColors.teal900,
                total: entries.length,
              ),
              pw.SizedBox(height: 12),
            ],
            if (safeStepFreq.isNotEmpty) ...[
              _pdfFreqTable(
                title: 'Safe next step chosen',
                data: safeStepFreq,
                font: font,
                fontBold: fontBold,
                headerColor: PdfColors.blueGrey50,
                headerTextColor: PdfColors.blueGrey900,
                total: entries.length,
              ),
              pw.SizedBox(height: 12),
            ],
            if (flareEntries.isNotEmpty) ...[
              _pdfNotesTable(
                  entries: flareEntries,
                  font: font,
                  fontBold: fontBold,
                  getText: (e) => e.flareNotes!,
                  columnLabel: 'Flare-up notes'),
              pw.SizedBox(height: 12),
            ],
            if (medicationNoteEntries.isNotEmpty) ...[
              _pdfNotesTable(
                  entries: medicationNoteEntries,
                  font: font,
                  fontBold: fontBold,
                  getText: (e) => e.medicationNotes!,
                  columnLabel: 'Medication notes (Back Pain log)'),
              pw.SizedBox(height: 12),
            ],
            if (sleepNoteEntries.isNotEmpty) ...[
              _pdfNotesTable(
                  entries: sleepNoteEntries,
                  font: font,
                  fontBold: fontBold,
                  getText: (e) => e.sleepNotes!,
                  columnLabel: 'Sleep impact notes'),
              pw.SizedBox(height: 12),
            ],
            if (gpNoteEntries.isNotEmpty) ...[
              _pdfNotesTable(
                  entries: gpNoteEntries,
                  font: font,
                  fontBold: fontBold,
                  getText: (e) => e.gpNotes!,
                  columnLabel: 'Appointment / GP notes'),
              pw.SizedBox(height: 12),
            ],
            if (evidenceNoteEntries.isNotEmpty) ...[
              _pdfNotesTable(
                  entries: evidenceNoteEntries,
                  font: font,
                  fontBold: fontBold,
                  getText: (e) => e.evidenceNotes!,
                  columnLabel: 'Evidence / support notes'),
              pw.SizedBox(height: 12),
            ],
            pw.SizedBox(height: 6),
          ],

          // ── 7. Check-in Log ──────────────────────────────────
          _pdfSectionTitle(
              '7. Check-in Log',
              fontBold, PdfColors.red700),
          pw.SizedBox(height: 6),
          if (entries.isEmpty)
            _pdfNoData('No check-in entries in this period.', font, fontItal)
          else
            _pdfCheckinTable(
                entries: entries,
                font: font,
                fontBold: fontBold),
          pw.SizedBox(height: 18),

          // ── 8. Symptom & Trigger Frequency ──────────────────
          if (symptomFreq.isNotEmpty || triggerFreq.isNotEmpty) ...[
            _pdfSectionTitle('8. Symptom & Trigger Frequency',
                fontBold, PdfColors.purple700),
            pw.SizedBox(height: 6),
            pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Expanded(
                  child: _pdfFreqTable(
                    title: 'Symptoms',
                    data: symptomFreq,
                    font: font,
                    fontBold: fontBold,
                    headerColor: PdfColors.purple50,
                    headerTextColor: PdfColors.purple900,
                    total: entries.length,
                  ),
                ),
                pw.SizedBox(width: 10),
                pw.Expanded(
                  child: _pdfFreqTable(
                    title: 'Triggers',
                    data: triggerFreq,
                    font: font,
                    fontBold: fontBold,
                    headerColor: PdfColors.orange50,
                    headerTextColor: PdfColors.orange900,
                    total: entries.length,
                  ),
                ),
                pw.SizedBox(width: 10),
                pw.Expanded(
                  child: _pdfFreqTable(
                    title: 'Pain Locations',
                    data: locationFreq,
                    font: font,
                    fontBold: fontBold,
                    headerColor: PdfColors.red50,
                    headerTextColor: PdfColors.red900,
                    total: entries.length,
                  ),
                ),
              ],
            ),
            pw.SizedBox(height: 18),
          ],

          // ── 9. Personal notes ────────────────────────────────
          if (noteEntries.isNotEmpty) ...[
            _pdfSectionTitle(
                '9. Personal Notes from Check-ins'
                '  (${noteEntries.length} entries with notes)',
                fontBold, PdfColors.blueGrey700),
            pw.SizedBox(height: 6),
            _pdfNotesTable(
                entries: noteEntries,
                font: font,
                fontBold: fontBold,
                getText: (e) => e.notes,
                columnLabel: 'Notes'),
            pw.SizedBox(height: 18),
          ],

          // ── 10. Profile notes ────────────────────────────────
          if (profNotes.isNotEmpty) ...[
            _pdfSectionTitle('10. Profile Notes', fontBold,
                PdfColors.blueGrey700),
            pw.SizedBox(height: 6),
            pw.Container(
              padding: const pw.EdgeInsets.all(10),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(
                    color: PdfColors.grey300, width: 0.5),
                borderRadius: pw.BorderRadius.circular(4),
              ),
              child: pw.Text(profNotes,
                  style: pw.TextStyle(
                      font: fontItal,
                      fontSize: 9,
                      color: PdfColors.grey700)),
            ),
            pw.SizedBox(height: 18),
          ],

          // ── Disclaimer ───────────────────────────────────────
          pw.Container(
            padding: const pw.EdgeInsets.all(10),
            decoration: pw.BoxDecoration(
              color: PdfColors.amber50,
              border: pw.Border.all(
                  color: PdfColors.amber200, width: 0.5),
              borderRadius: pw.BorderRadius.circular(4),
            ),
            child: pw.Text(
              'IMPORTANT: This document is a personal tracking record '
              'generated by Nova Health on the patient\'s own device. '
              'It is provided for clinical reference and appointment '
              'preparation only. It does not constitute a medical '
              'diagnosis, assessment, or clinical report. '
              'All data was entered by the patient and has not been '
              'reviewed or verified by a medical professional.',
              style: pw.TextStyle(
                  font: fontItal,
                  fontSize: 8,
                  color: PdfColors.brown700),
            ),
          ),
        ],
      ));

      final bytes = await doc.save();
      await Printing.sharePdf(
        bytes: bytes,
        filename: 'nova_clinical_report_${_today()}.pdf',
      );
      if (mounted) _snack('PDF ready — use your device\'s share options to save or print');
    } catch (e) {
      if (mounted) _snack('Export failed: $e', error: true);
    } finally {
      if (mounted) setState(() => _building = false);
    }
  }

  // ── PDF widget helpers ────────────────────────────────────────

  pw.Widget _pdfHeader({
    required pw.Font fontBold,
    required pw.Font font,
    required String name,
    required String today,
  }) {
    return pw.Container(
      padding: const pw.EdgeInsets.only(bottom: 10),
      decoration: const pw.BoxDecoration(
        border: pw.Border(
          bottom: pw.BorderSide(color: PdfColors.blueGrey300, width: 0.8),
        ),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'Nova Health — Clinical Reference Report',
                style: pw.TextStyle(
                    font: fontBold,
                    fontSize: 13,
                    color: PdfColors.blueGrey900),
              ),
              pw.Text(
                'Patient: $name',
                style: pw.TextStyle(
                    font: font,
                    fontSize: 9,
                    color: PdfColors.blueGrey600),
              ),
            ],
          ),
          pw.Text(
            'Generated $today',
            style: pw.TextStyle(
                font: font,
                fontSize: 9,
                color: PdfColors.grey500),
          ),
        ],
      ),
    );
  }

  pw.Widget _pdfFooter(pw.Context ctx, pw.Font font) {
    return pw.Container(
      padding: const pw.EdgeInsets.only(top: 6),
      decoration: const pw.BoxDecoration(
        border: pw.Border(
          top: pw.BorderSide(color: PdfColors.grey300, width: 0.5),
        ),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            'Nova Health — personal tracking record — not a clinical document',
            style: pw.TextStyle(
                font: font,
                fontSize: 7.5,
                color: PdfColors.grey500),
          ),
          pw.Text(
            'Page ${ctx.pageNumber} of ${ctx.pagesCount}',
            style: pw.TextStyle(
                font: font,
                fontSize: 7.5,
                color: PdfColors.grey500),
          ),
        ],
      ),
    );
  }

  pw.Widget _pdfSectionTitle(
      String title, pw.Font fontBold, PdfColor color) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(title,
            style:
                pw.TextStyle(font: fontBold, fontSize: 12, color: color)),
        pw.SizedBox(height: 3),
        pw.Container(height: 1, color: color.flatten()),
      ],
    );
  }

  pw.Widget _pdfNoData(String msg, pw.Font font, pw.Font fontItal) {
    return pw.Text(msg,
        style: pw.TextStyle(
            font: fontItal,
            fontSize: 9.5,
            color: PdfColors.grey500));
  }

  pw.Widget _pdfKvTable({
    required pw.Font font,
    required pw.Font fontBold,
    required List<List<String>> rows,
  }) {
    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
      columnWidths: {
        0: const pw.FlexColumnWidth(2.8),
        1: const pw.FlexColumnWidth(5.2),
      },
      children: rows
          .map((r) => pw.TableRow(children: [
                _pdfCell(r[0],
                    font: fontBold,
                    fontSize: 9.5,
                    bgColor: PdfColors.grey50),
                _pdfCell(r[1], font: font, fontSize: 9.5),
              ]))
          .toList(),
    );
  }

  pw.Widget _pdfCheckinTable({
    required List<CheckInEntry> entries,
    required pw.Font font,
    required pw.Font fontBold,
  }) {
    const headers = [
      'Date', 'Pain', 'Nerve', 'Med', 'Locations', 'Symptoms', 'Notes'
    ];
    const widths = {
      0: pw.FlexColumnWidth(1.6), // Date
      1: pw.FlexColumnWidth(0.7), // Pain
      2: pw.FlexColumnWidth(0.7), // Nerve
      3: pw.FlexColumnWidth(0.7), // Med
      4: pw.FlexColumnWidth(1.8), // Locations
      5: pw.FlexColumnWidth(2.0), // Symptoms
      6: pw.FlexColumnWidth(3.5), // Notes
    };

    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
      columnWidths: widths,
      children: [
        pw.TableRow(
          decoration:
              const pw.BoxDecoration(color: PdfColors.blueGrey50),
          children: headers
              .map((h) => _pdfCell(h,
                  font: fontBold,
                  fontSize: 8,
                  color: PdfColors.blueGrey800))
              .toList(),
        ),
        ...entries.asMap().entries.map((e) {
          final i   = e.key;
          final en  = e.value;
          final bg  = i.isEven ? PdfColors.white : PdfColors.grey50;
          final med = en.medicationTaken == null
              ? '—'
              : (en.medicationTaken! ? 'Yes' : 'No');
          final notes = en.notes.trim().isEmpty
              ? '—'
              : en.notes.trim().length > 90
                  ? '${en.notes.trim().substring(0, 90)}…'
                  : en.notes.trim();

          return pw.TableRow(
            decoration: pw.BoxDecoration(color: bg),
            children: [
              _pdfCell(_fmtDateShort(en.date),
                  font: font, fontSize: 8),
              _pdfCell('${en.painRating}/10',
                  font: fontBold,
                  fontSize: 8,
                  color: _painColor(en.painRating)),
              _pdfCell('${en.nerveSymptomRating}/10',
                  font: fontBold,
                  fontSize: 8,
                  color: _nerveColor(en.nerveSymptomRating)),
              _pdfCell(med, font: font, fontSize: 8),
              _pdfCell(
                  en.painLocations.isEmpty
                      ? '—'
                      : en.painLocations.join(', '),
                  font: font,
                  fontSize: 8),
              _pdfCell(
                  en.symptoms.isEmpty ? '—' : en.symptoms.join(', '),
                  font: font,
                  fontSize: 8),
              _pdfCell(notes, font: font, fontSize: 8),
            ],
          );
        }),
      ],
    );
  }

  pw.Widget _pdfFreqTable({
    required String title,
    required Map<String, int> data,
    required pw.Font font,
    required pw.Font fontBold,
    required PdfColor headerColor,
    required PdfColor headerTextColor,
    required int total,
  }) {
    final rows = data.entries.take(10).toList();
    if (rows.isEmpty) {
      return pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(title,
              style: pw.TextStyle(
                  font: fontBold,
                  fontSize: 8.5,
                  color: headerTextColor)),
          pw.SizedBox(height: 4),
          pw.Text('None recorded.',
              style: pw.TextStyle(font: font, fontSize: 8)),
        ],
      );
    }
    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
      columnWidths: {
        0: const pw.FlexColumnWidth(4),
        1: const pw.FlexColumnWidth(1),
        2: const pw.FlexColumnWidth(1.2),
      },
      children: [
        pw.TableRow(
          decoration: pw.BoxDecoration(color: headerColor),
          children: [
            _pdfCell(title,
                font: fontBold,
                fontSize: 8,
                color: headerTextColor),
            _pdfCell('n',
                font: fontBold,
                fontSize: 8,
                color: headerTextColor),
            _pdfCell('%',
                font: fontBold,
                fontSize: 8,
                color: headerTextColor),
          ],
        ),
        ...rows.map((r) => pw.TableRow(children: [
              _pdfCell(r.key, font: font, fontSize: 7.5),
              _pdfCell('${r.value}', font: font, fontSize: 7.5),
              _pdfCell(
                  total > 0
                      ? '${(r.value / total * 100).round()}%'
                      : '—',
                  font: font,
                  fontSize: 7.5),
            ])),
      ],
    );
  }

  pw.Widget _pdfNotesTable({
    required List<CheckInEntry> entries,
    required pw.Font font,
    required pw.Font fontBold,
    required String Function(CheckInEntry) getText,
    required String columnLabel,
  }) {
    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
      columnWidths: {
        0: const pw.FlexColumnWidth(1.6),
        1: const pw.FlexColumnWidth(8.4),
      },
      children: [
        pw.TableRow(
          decoration:
              const pw.BoxDecoration(color: PdfColors.blueGrey50),
          children: [
            _pdfCell('Date',
                font: fontBold,
                fontSize: 8.5,
                color: PdfColors.blueGrey700),
            _pdfCell(columnLabel,
                font: fontBold,
                fontSize: 8.5,
                color: PdfColors.blueGrey700),
          ],
        ),
        ...entries.asMap().entries.map((e) {
          final i  = e.key;
          final en = e.value;
          final bg = i.isEven ? PdfColors.white : PdfColors.grey50;
          return pw.TableRow(
            decoration: pw.BoxDecoration(color: bg),
            children: [
              _pdfCell(_fmtDateShort(en.date),
                  font: fontBold, fontSize: 8.5),
              _pdfCell(getText(en).trim(),
                  font: font, fontSize: 8.5),
            ],
          );
        }),
      ],
    );
  }

  pw.Widget _pdfCell(
    String text, {
    required pw.Font font,
    double fontSize = 9.5,
    PdfColor? color,
    PdfColor? bgColor,
  }) {
    final cell = pw.Padding(
      padding:
          const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          font: font,
          fontSize: fontSize,
          color: color,
        ),
      ),
    );
    if (bgColor != null) {
      return pw.Container(color: bgColor, child: cell);
    }
    return cell;
  }

  // Colour-code pain/nerve scores in the PDF table
  PdfColor _painColor(int v) {
    if (v <= 3) return PdfColors.green700;
    if (v <= 6) return PdfColors.orange700;
    return PdfColors.red700;
  }

  PdfColor _nerveColor(int v) {
    if (v <= 3) return PdfColors.teal700;
    if (v <= 6) return PdfColors.purple700;
    return PdfColors.deepPurple700;
  }

  String _trendText(double? first, double? second,
      {required bool lowerIsBetter}) {
    if (first == null || second == null) return '—';
    final delta = second - first;
    final improving = lowerIsBetter ? delta < -0.2 : delta > 0.2;
    final worsening = lowerIsBetter ? delta > 0.2 : delta < -0.2;
    final word = improving
        ? 'Improving'
        : worsening
            ? 'Worsening'
            : 'Stable';
    final deltaStr =
        delta >= 0 ? '+${delta.toStringAsFixed(1)}' : delta.toStringAsFixed(1);
    return '${first.toStringAsFixed(1)} → ${second.toStringAsFixed(1)}'
        '  ($deltaStr)  $word';
  }

  // ── Snackbar ──────────────────────────────────────────────────

  void _snack(String msg, {bool error = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor:
          error ? _rose.withValues(alpha: 0.9) : _teal.withValues(alpha: 0.9),
      behavior: SnackBarBehavior.floating,
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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
        title: const Text(
          'Clinician Report',
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
    final entries   = _entries;
    final hasData   = entries.isNotEmpty;
    final name      = _pStr('name');
    final conditions = _allConditions;
    final meds      = _pList('medications');
    final medAd     = _medAdherence;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 48),
      children: [
        // ── Header banner ─────────────────────────────────────
        _buildHeader(),
        const SizedBox(height: 20),

        // ── Patient profile summary card ──────────────────────
        _buildProfileCard(name, conditions, meds),
        const SizedBox(height: 16),

        // ── Date range selector ───────────────────────────────
        _buildRangeRow(),
        const SizedBox(height: 16),

        // ── Stats row ─────────────────────────────────────────
        _buildStatsRow(entries, medAd),
        const SizedBox(height: 20),

        // ── Contents summary ──────────────────────────────────
        _sectionLabel('REPORT CONTENTS', _muted),
        const SizedBox(height: 10),
        _buildContentsRows(entries, medAd),
        const SizedBox(height: 24),

        // ── Export button ─────────────────────────────────────
        _buildExportButton(hasData),
        const SizedBox(height: 14),

        // ── Disclaimer ────────────────────────────────────────
        _buildDisclaimer(),
      ],
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Container(
              width: 38, height: 38,
              decoration: BoxDecoration(
                color: _blue.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                  Icons.picture_as_pdf_rounded, color: _blue, size: 20),
            ),
            const SizedBox(width: 12),
            const Text(
              'Clinician Report',
              style: TextStyle(
                color: _text,
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
          ]),
          const SizedBox(height: 10),
          const Text(
            'Generates a structured PDF combining your Health Profile '
            'and check-in history. Suitable for GP appointments, pain '
            'clinic referrals, or PIP evidence conversations.',
            style: TextStyle(color: _muted, fontSize: 13, height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileCard(
      String name, List<String> conditions, List<String> meds) {
    final hasProfile = name.isNotEmpty ||
        conditions.isNotEmpty ||
        meds.isNotEmpty;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _panel,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _purple.withValues(alpha: 0.22)),
      ),
      child: hasProfile
          ? Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Container(
                  width: 36, height: 36,
                  decoration: BoxDecoration(
                    color: _purple.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.person_outline_rounded,
                      color: _purple, size: 18),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name.isNotEmpty ? name : 'Name not set',
                      style: const TextStyle(
                        color: _text,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (conditions.isNotEmpty)
                      Text(
                        '${conditions.length} condition'
                        '${conditions.length == 1 ? '' : 's'} recorded',
                        style: const TextStyle(
                            color: _muted, fontSize: 12),
                      ),
                  ],
                ),
              ]),
              if (conditions.isNotEmpty) ...[
                const SizedBox(height: 12),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: conditions.take(6).map((c) => Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: _purple.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color: _purple.withValues(alpha: 0.30)),
                    ),
                    child: Text(c,
                        style: const TextStyle(
                            color: _purple,
                            fontSize: 11.5,
                            fontWeight: FontWeight.w500)),
                  )).toList(),
                ),
                if (conditions.length > 6)
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      '+${conditions.length - 6} more',
                      style: const TextStyle(
                          color: _muted, fontSize: 11.5),
                    ),
                  ),
              ],
            ])
          : Row(children: [
              Icon(Icons.info_outline_rounded,
                  color: _amber.withValues(alpha: 0.7), size: 16),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'Health Profile is empty — the PDF personal details '
                  'section will show "—". Fill in your profile for a '
                  'complete report.',
                  style: TextStyle(
                      color: _muted, fontSize: 13, height: 1.4),
                ),
              ),
            ]),
    );
  }

  Widget _buildRangeRow() {
    const options = [
      (_ExportRange.days7,   '7 days'),
      (_ExportRange.days30,  '30 days'),
      (_ExportRange.days90,  '3 months'),
      (_ExportRange.allTime, 'All time'),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionLabel('DATE RANGE', _muted),
        const SizedBox(height: 10),
        Row(
          children: options.map((opt) {
            final (range, label) = opt;
            final sel = _range == range;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: GestureDetector(
                onTap: () => setState(() => _range = range),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 13, vertical: 7),
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
                    label,
                    style: TextStyle(
                      color: sel ? _blue : _muted,
                      fontSize: 12.5,
                      fontWeight: sel
                          ? FontWeight.w600
                          : FontWeight.w400,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildStatsRow(List<CheckInEntry> entries, double? medAd) {
    return Row(children: [
      _statChip(
        value: '${entries.length}',
        label: 'check-ins',
        color: _blue,
      ),
      const SizedBox(width: 8),
      _statChip(
        value: entries.isEmpty ? '—' : _avgPain.toStringAsFixed(1),
        label: 'avg pain',
        color: _rose,
      ),
      const SizedBox(width: 8),
      _statChip(
        value: entries.isEmpty ? '—' : _avgNerve.toStringAsFixed(1),
        label: 'avg nerve',
        color: _purple,
      ),
      if (medAd != null) ...[
        const SizedBox(width: 8),
        _statChip(
          value: '${(medAd * 100).round()}%',
          label: 'medication',
          color: _teal,
        ),
      ],
    ]);
  }

  Widget _statChip({
    required String value,
    required String label,
    required Color color,
  }) {
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
                  fontSize: 20,
                  fontWeight: FontWeight.w800)),
          const SizedBox(height: 2),
          Text(label,
              style: const TextStyle(
                  color: _muted,
                  fontSize: 9.5)),
        ]),
      ),
    );
  }

  Widget _buildContentsRows(
      List<CheckInEntry> entries, double? medAd) {
    final allCond = _allConditions;
    final meds    = _pList('medications');
    final name    = _pStr('name');
    final notesCount =
        entries.where((e) => e.notes.trim().isNotEmpty).length;

    return Column(children: [
      _contentsRow(
        icon: Icons.person_outline_rounded,
        color: _blue,
        title: 'Patient Details',
        detail: name.isNotEmpty
            ? name
            : 'Name not set — fill in Health Profile',
      ),
      const SizedBox(height: 8),
      _contentsRow(
        icon: Icons.medical_information_outlined,
        color: _purple,
        title: 'Conditions & Medications',
        detail: allCond.isEmpty && meds.isEmpty
            ? 'None recorded'
            : [
                if (allCond.isNotEmpty)
                  '${allCond.length} condition'
                      '${allCond.length == 1 ? '' : 's'}',
                if (meds.isNotEmpty)
                  '${meds.length} medication'
                      '${meds.length == 1 ? '' : 's'}',
              ].join(' · '),
      ),
      const SizedBox(height: 8),
      _contentsRow(
        icon: Icons.warning_amber_outlined,
        color: _amber,
        title: 'Allergies & Access Needs',
        detail: _allAllergies.isEmpty && _allAccess.isEmpty
            ? 'None recorded'
            : [
                if (_allAllergies.isNotEmpty)
                  '${_allAllergies.length} allerg'
                      '${_allAllergies.length == 1 ? 'y' : 'ies'}',
                if (_allAccess.isNotEmpty)
                  '${_allAccess.length} access need'
                      '${_allAccess.length == 1 ? '' : 's'}',
              ].join(' · '),
      ),
      const SizedBox(height: 8),
      _contentsRow(
        icon: Icons.local_hospital_outlined,
        color: _teal,
        title: 'Medical Team',
        detail: _pStr('gpName').isNotEmpty
            ? 'GP: ${_pStr('gpName')}'
            : 'Not recorded',
      ),
      const SizedBox(height: 8),
      _contentsRow(
        icon: Icons.show_chart_rounded,
        color: _rose,
        title: 'Check-in Log & Trend Analysis',
        detail: entries.isEmpty
            ? 'No entries in ${_rangeLabel.toLowerCase()}'
            : '${entries.length} entries · '
                '${_rangeLabel.toLowerCase()}',
      ),
      const SizedBox(height: 8),
      _contentsRow(
        icon: Icons.bar_chart_rounded,
        color: _green,
        title: 'Symptom & Trigger Frequency',
        detail: entries.isEmpty
            ? 'No data in selected range'
            : 'Top symptoms, triggers and locations',
      ),
      if (notesCount > 0) ...[
        const SizedBox(height: 8),
        _contentsRow(
          icon: Icons.notes_rounded,
          color: _muted,
          title: 'Personal Notes',
          detail: '$notesCount entr'
              '${notesCount == 1 ? 'y' : 'ies'} with notes',
        ),
      ],
    ]);
  }

  Widget _contentsRow({
    required IconData icon,
    required Color color,
    required String title,
    required String detail,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _panel,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.20)),
      ),
      child: Row(children: [
        Container(
          width: 34, height: 34,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(9),
          ),
          child: Icon(icon, color: color, size: 17),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: const TextStyle(
                      color: _text,
                      fontSize: 13,
                      fontWeight: FontWeight.w600)),
              if (detail.isNotEmpty)
                Text(detail,
                    style: const TextStyle(
                        color: _muted, fontSize: 11.5),
                    overflow: TextOverflow.ellipsis),
            ],
          ),
        ),
        Icon(Icons.check_circle_outline_rounded,
            color: color.withValues(alpha: 0.45), size: 16),
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
                  colors: [Color(0xFF5DADEC), Color(0xFF46D6C8)],
                )
              : null,
          color: (hasData && !_building)
              ? null
              : _panel,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: (hasData && !_building)
                ? Colors.transparent
                : _border,
          ),
          boxShadow: (hasData && !_building)
              ? [
                  BoxShadow(
                    color: _blue.withValues(alpha: 0.25),
                    blurRadius: 14,
                    offset: const Offset(0, 4),
                  )
                ]
              : null,
        ),
        child: Center(
          child: _building
              ? const SizedBox(
                  width: 22, height: 22,
                  child: CircularProgressIndicator(
                      strokeWidth: 2.5, color: Colors.white),
                )
              : Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(
                    Icons.picture_as_pdf_rounded,
                    color:
                        hasData ? Colors.white : _muted,
                    size: 22,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    hasData
                        ? 'Generate & Share PDF'
                        : 'No check-ins in selected period',
                    style: TextStyle(
                      color: hasData ? Colors.white : _muted,
                      fontSize: 15.5,
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
        border: Border.all(color: _amber.withValues(alpha: 0.22)),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline_rounded, color: _amber, size: 15),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'This report is a personal tracking record for clinical '
              'reference only. It is not a medical diagnosis. All data '
              'is stored locally on this device and nothing is '
              'transmitted without your explicit action.',
              style: TextStyle(
                  color: _muted, fontSize: 12.5, height: 1.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionLabel(String text, Color color) {
    return Text(
      text,
      style: TextStyle(
        color: color.withValues(alpha: 0.7),
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.1,
      ),
    );
  }
}
