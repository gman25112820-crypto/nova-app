import 'package:flutter/material.dart';

import '../../../core/models/check_in_entry.dart';
import '../../../core/repositories/check_in_repository.dart';
import '../../../core/services/export_service.dart';
import '../helpers/web_download.dart';

/// Clinical evidence export dashboard.
/// Reads all local [CheckInEntry] records, displays summary metrics,
/// and triggers browser downloads for CSV and HTML formats.
/// Download uses a platform-safe conditional — dart:html on web only.
class ExportScreen extends StatefulWidget {
  const ExportScreen({super.key});

  @override
  State<ExportScreen> createState() => _ExportScreenState();
}

class _ExportScreenState extends State<ExportScreen> {
  final CheckInRepository _repository = CheckInRepository();
  final ExportService _exportService = ExportService();

  List<CheckInEntry> _entries = [];
  bool _loading = true;

  static const Color _bg = Color(0xFF090C18);
  static const Color _panel = Color(0xFF13172A);
  static const Color _text = Color(0xFFF2EFFF);
  static const Color _muted = Color(0xFFAAABC8);
  static const Color _blue = Color(0xFF5DADEC);
  static const Color _purple = Color(0xFF8D6CFF);
  static const Color _coral = Color(0xFFFF6B6B);
  static const Color _amber = Color(0xFFFFC857);

  @override
  void initState() {
    super.initState();
    _loadEntries();
  }

  Future<void> _loadEntries() async {
    final List<CheckInEntry> entries = await _repository.getAllEntries();
    if (mounted) {
      setState(() {
        _entries = entries;
        _loading = false;
      });
    }
  }

  double get _avgNerve {
    if (_entries.isEmpty) return 0;
    return _entries
            .map((e) => e.nerveSymptomRating)
            .reduce((a, b) => a + b) /
        _entries.length;
  }

  double get _avgPain {
    if (_entries.isEmpty) return 0;
    return _entries.map((e) => e.painRating).reduce((a, b) => a + b) /
        _entries.length;
  }

  void _exportCsv() {
    if (_entries.isEmpty) {
      _snack('No entries to export.', isError: true);
      return;
    }
    final String csv = _exportService.generateCsv(_entries);
    final String fileName =
        'nova_pain_log_${_today()}.csv';
    triggerDownload(csv, fileName, 'text/csv');
    _snack('CSV exported — $fileName');
  }

  void _exportHtml() {
    if (_entries.isEmpty) {
      _snack('No entries to export.', isError: true);
      return;
    }
    final String html =
        _exportService.generateHtmlReport(_entries, 'Nova User');
    final String fileName =
        'nova_pain_report_${_today()}.html';
    triggerDownload(html, fileName, 'text/html');
    _snack('Report exported — $fileName');
  }

  void _snack(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError
            ? _coral.withValues(alpha: 0.9)
            : _blue.withValues(alpha: 0.9),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  String _today() {
    final DateTime now = DateTime.now();
    final String y = now.year.toString();
    final String m = now.month.toString().padLeft(2, '0');
    final String d = now.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        foregroundColor: _text,
        elevation: 0,
        title: const Text(
          'Evidence Export',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
              children: [
                _header(),
                const SizedBox(height: 20),
                _metricsRow(),
                const SizedBox(height: 24),
                _sectionLabel('EXPORT OPTIONS'),
                const SizedBox(height: 12),
                _exportButton(
                  icon: Icons.table_chart_outlined,
                  color: _blue,
                  title: 'Export CSV Spreadsheet',
                  subtitle:
                      'All ${_entries.length} entries as a structured '
                      'spreadsheet — open in Excel, Numbers, or Google Sheets.',
                  onTap: _exportCsv,
                ),
                const SizedBox(height: 12),
                _exportButton(
                  icon: Icons.print_outlined,
                  color: _purple,
                  title: 'Generate Print-Ready Report',
                  subtitle:
                      'Full HTML summary with metrics table — '
                      'suitable for GP appointments or PIP evidence.',
                  onTap: _exportHtml,
                ),
                const SizedBox(height: 24),
                _disclaimer(),
              ],
            ),
    );
  }

  Widget _header() {
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
          const Text(
            'Evidence Export',
            style: TextStyle(
              color: _text,
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Download your personal health records as a spreadsheet or '
            'a print-ready report for appointments and evidence conversations.',
            style: TextStyle(
              color: _muted,
              fontSize: 13.5,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }

  Widget _metricsRow() {
    return Row(
      children: [
        _metricCard(
          label: 'Total entries',
          value: '${_entries.length}',
          unit: 'logs',
          color: _blue,
        ),
        const SizedBox(width: 12),
        _metricCard(
          label: 'Avg pain',
          value: _entries.isEmpty ? '—' : _avgPain.toStringAsFixed(1),
          unit: '/ 10',
          color: _amber,
        ),
        const SizedBox(width: 12),
        _metricCard(
          label: 'Avg nerve',
          value: _entries.isEmpty ? '—' : _avgNerve.toStringAsFixed(1),
          unit: '/ 10',
          color: _coral,
        ),
      ],
    );
  }

  Widget _metricCard({
    required String label,
    required String value,
    required String unit,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
        decoration: BoxDecoration(
          color: _panel,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: 0.28)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                color: _muted,
                fontSize: 10.5,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.4,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: 26,
                fontWeight: FontWeight.w800,
              ),
            ),
            Text(
              unit,
              style: TextStyle(color: _muted, fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionLabel(String text) {
    return Text(
      text,
      style: TextStyle(
        color: _muted.withValues(alpha: 0.7),
        fontSize: 10.5,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.9,
      ),
    );
  }

  Widget _exportButton({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    final bool hasData = _entries.isNotEmpty;
    return GestureDetector(
      onTap: hasData ? onTap : null,
      child: Opacity(
        opacity: hasData ? 1.0 : 0.45,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _panel,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withValues(alpha: 0.30)),
          ),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: _text,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: _muted,
                        fontSize: 12.5,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.download_rounded,
                color: color.withValues(alpha: 0.7),
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _disclaimer() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _amber.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _amber.withValues(alpha: 0.28)),
      ),
      child: Text(
        'Personal tracking record for diagnostic reference only. '
        'Not a direct clinical diagnosis. '
        'Stored entirely locally on-device. '
        'No data is transmitted or shared without your explicit action.',
        style: TextStyle(
          color: _muted,
          fontSize: 12.5,
          height: 1.5,
        ),
      ),
    );
  }
}
