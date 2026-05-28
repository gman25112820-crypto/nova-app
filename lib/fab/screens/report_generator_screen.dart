import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import '../models/child_profile.dart';
import '../models/family_account.dart';
import '../services/report_service.dart';

// ─────────────────────────────────────────────────────────────
// ReportGeneratorScreen
//
// Allows a parent to generate and share a PDF wellbeing report.
//
// Config options:
//   - Child (selected from FamilyAccount.children)
//   - Period: last 7 days / 30 days / 3 months
//   - Sections: Sleep, Mood, Health (all on by default)
//
// Journal is never included and not offered as a toggle.
// Footer of every generated PDF contains a self-reported
// data disclaimer.
// ─────────────────────────────────────────────────────────────

class ReportGeneratorScreen extends StatefulWidget {
  final ChildProfile? initialChild;
  const ReportGeneratorScreen({super.key, this.initialChild});

  @override
  State<ReportGeneratorScreen> createState() =>
      _ReportGeneratorScreenState();
}

class _ReportGeneratorScreenState extends State<ReportGeneratorScreen> {
  static const _bg     = Color(0xFF0D0820);
  static const _purple = Color(0xFF6C63FF);
  static const _amber  = Color(0xFFFFB830);
  static const _pink   = Color(0xFFFF6B8A);
  static const _teal   = Color(0xFF00C9A7);


  late ReportConfig _config;
  bool _generating = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    final account  = FamilyAccount.current;
    final children = account?.children ?? [];
    final child    = widget.initialChild
        ?? (children.isNotEmpty ? children.first : null);

    // If no child is available, we show an empty state.
    if (child == null) {
      _config = ReportConfig(
        child:  ChildProfile(
          id:   '',
          name: '',
          dob:  DateTime.now(),
        ),
        period: ReportPeriod.month,
      );
    } else {
      _config = ReportConfig(child: child, period: ReportPeriod.month);
    }
  }

  Future<void> _generate() async {
    if (_config.child.id.isEmpty) return;
    if (!_config.includeSleep &&
        !_config.includeMood &&
        !_config.includeHealth) {
      setState(() => _error = 'Select at least one section.');
      return;
    }
    setState(() {
      _generating = true;
      _error      = null;
    });
    try {
      final bytes = await ReportService.buildPdf(_config);
      if (!mounted) return;
      await Printing.sharePdf(
        bytes:    bytes,
        filename: 'wellbeing_${_config.child.name.toLowerCase().replaceAll(' ', '_')}_report.pdf',
      );
    } catch (e) {
      if (mounted) setState(() => _error = 'Failed to generate report: $e');
    } finally {
      if (mounted) setState(() => _generating = false);
    }
  }

  Future<void> _preview() async {
    if (_config.child.id.isEmpty) return;
    setState(() {
      _generating = true;
      _error      = null;
    });
    try {
      final bytes = await ReportService.buildPdf(_config);
      if (!mounted) return;
      setState(() => _generating = false);
      await Printing.layoutPdf(
        onLayout: (_) async => bytes,
        name:     'Wellbeing Report — ${_config.child.name}',
      );
    } catch (e) {
      if (mounted) {
        setState(() {
          _generating = false;
          _error      = 'Preview failed: $e';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final account  = FamilyAccount.current;
    final children = account?.children ?? [];

    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Generate Report',
          style: TextStyle(
              fontWeight: FontWeight.w700, fontFamily: 'DM Sans'),
        ),
      ),
      body: children.isEmpty
          ? _buildNoChildren()
          : SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoBanner(),
                  const SizedBox(height: 20),
                  _buildChildPicker(children),
                  const SizedBox(height: 20),
                  _buildPeriodPicker(),
                  const SizedBox(height: 20),
                  _buildSectionToggles(),
                  const SizedBox(height: 20),
                  _buildPrivacyNote(),
                  if (_error != null) ...[
                    const SizedBox(height: 12),
                    Text(_error!,
                        style: const TextStyle(
                            color: _pink, fontSize: 13)),
                  ],
                  const SizedBox(height: 24),
                  _buildButtons(),
                ],
              ),
            ),
    );
  }

  Widget _buildNoChildren() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('📊',
                style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.30),
                    fontSize: 48)),
            const SizedBox(height: 16),
            Text(
              'No child profiles yet.',
              style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.45),
                  fontSize: 15),
            ),
            const SizedBox(height: 8),
            Text(
              'Add a child in Family Hub first.',
              style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.30),
                  fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoBanner() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _purple.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _purple.withValues(alpha: 0.25)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('📋', style: TextStyle(fontSize: 18)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Generate a PDF report to share with teachers, therapists or doctors. '
              'Choose what to include — journal is always kept private.',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.65),
                fontSize: 12,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChildPicker(List<ChildProfile> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionLabel('Child'),
        const SizedBox(height: 10),
        ...children.map((child) {
          final selected = _config.child.id == child.id;
          return GestureDetector(
            onTap: () => setState(
                () => _config = ReportConfig(
                      child:          child,
                      period:         _config.period,
                      includeSleep:   _config.includeSleep,
                      includeMood:    _config.includeMood,
                      includeHealth:  _config.includeHealth,
                    )),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 140),
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: selected
                    ? _purple.withValues(alpha: 0.15)
                    : Colors.white.withValues(alpha: 0.04),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: selected
                      ? _purple.withValues(alpha: 0.50)
                      : Colors.white.withValues(alpha: 0.08),
                  width: selected ? 1.5 : 1,
                ),
              ),
              child: Row(
                children: [
                  Text(child.ageMode.emoji,
                      style: const TextStyle(fontSize: 20)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(child.name,
                            style: TextStyle(
                              color: selected
                                  ? Colors.white
                                  : Colors.white70,
                              fontWeight: selected
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                              fontFamily: 'DM Sans',
                            )),
                        Text(
                          '${child.ageMode.label} · ${child.age} yrs',
                          style: TextStyle(
                              color: Colors.white.withValues(
                                  alpha: 0.35),
                              fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                  if (selected)
                    const Icon(Icons.check_circle_rounded,
                        color: _purple, size: 18),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildPeriodPicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionLabel('Period'),
        const SizedBox(height: 10),
        Row(
          children: ReportPeriod.values.map((p) {
            final selected = _config.period == p;
            return Expanded(
              child: GestureDetector(
                onTap: () => setState(
                    () => _config = _config.copyWith(period: p)),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 140),
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: selected
                        ? _amber.withValues(alpha: 0.15)
                        : Colors.white.withValues(alpha: 0.04),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: selected
                          ? _amber.withValues(alpha: 0.50)
                          : Colors.white.withValues(alpha: 0.08),
                      width: selected ? 1.5 : 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        p == ReportPeriod.week
                            ? '7d'
                            : p == ReportPeriod.month
                                ? '30d'
                                : '3mo',
                        style: TextStyle(
                          color: selected ? _amber : Colors.white70,
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                          fontFamily: 'DM Sans',
                        ),
                      ),
                      Text(
                        p == ReportPeriod.week
                            ? 'Week'
                            : p == ReportPeriod.month
                                ? 'Month'
                                : '3 months',
                        style: TextStyle(
                          color: selected
                              ? _amber.withValues(alpha: 0.75)
                              : Colors.white38,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildSectionToggles() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionLabel('Include sections'),
        const SizedBox(height: 10),
        _buildToggle(
          label: 'Sleep logs',
          emoji: '🌙',
          color: _purple,
          value: _config.includeSleep,
          onChanged: (v) =>
              setState(() => _config = _config.copyWith(includeSleep: v)),
        ),
        _buildToggle(
          label: 'Mood logs',
          emoji: '💛',
          color: _pink,
          value: _config.includeMood,
          onChanged: (v) =>
              setState(() => _config = _config.copyWith(includeMood: v)),
        ),
        _buildToggle(
          label: 'Health logs',
          emoji: '🩺',
          color: _teal,
          value: _config.includeHealth,
          onChanged: (v) =>
              setState(() => _config = _config.copyWith(includeHealth: v)),
        ),
        _buildLockedRow(),
      ],
    );
  }

  Widget _buildToggle({
    required String label,
    required String emoji,
    required Color color,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: value
            ? color.withValues(alpha: 0.08)
            : Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: value
              ? color.withValues(alpha: 0.30)
              : Colors.white.withValues(alpha: 0.07),
        ),
      ),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 18)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: value ? Colors.white : Colors.white54,
                fontFamily: 'DM Sans',
                fontWeight: value ? FontWeight.w500 : FontWeight.normal,
              ),
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: color,
            activeTrackColor: color.withValues(alpha: 0.30),
            inactiveThumbColor: Colors.white38,
            inactiveTrackColor: Colors.white.withValues(alpha: 0.10),
          ),
        ],
      ),
    );
  }

  Widget _buildLockedRow() {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.02),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Row(
        children: [
          const Text('🔒', style: TextStyle(fontSize: 18)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Journal & Safe Corner — always private',
              style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.30),
                  fontFamily: 'DM Sans',
                  fontSize: 13),
            ),
          ),
          Icon(Icons.block_rounded,
              color: Colors.white.withValues(alpha: 0.15), size: 18),
        ],
      ),
    );
  }

  Widget _buildPrivacyNote() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: Colors.white.withValues(alpha: 0.07)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline_rounded,
              color: Colors.white.withValues(alpha: 0.30), size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'The PDF footer will note that data is self-reported by '
              '${_config.child.id.isNotEmpty ? _config.child.name : "the child"} '
              'via the Fabulously Me app.',
              style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.40),
                  fontSize: 11,
                  height: 1.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildButtons() {
    return Column(
      children: [
        GestureDetector(
          onTap: (_generating || _config.child.id.isEmpty)
              ? null
              : _generate,
          child: Container(
            width: double.infinity,
            height: 54,
            decoration: BoxDecoration(
              gradient: (_generating || _config.child.id.isEmpty)
                  ? null
                  : const LinearGradient(
                      colors: [Color(0xFF6C63FF), Color(0xFF00C9A7)]),
              color: (_generating || _config.child.id.isEmpty)
                  ? Colors.white.withValues(alpha: 0.07)
                  : null,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: _generating
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2.5),
                    )
                  : const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.share_rounded,
                            color: Colors.white, size: 18),
                        SizedBox(width: 8),
                        Text(
                          'Share / download PDF',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            fontFamily: 'DM Sans',
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        GestureDetector(
          onTap: (_generating || _config.child.id.isEmpty)
              ? null
              : _preview,
          child: Container(
            width: double.infinity,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                  color: Colors.white.withValues(alpha: 0.12)),
            ),
            child: const Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.preview_rounded,
                      color: Colors.white70, size: 18),
                  SizedBox(width: 8),
                  Text(
                    'Preview',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'DM Sans',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _sectionLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 15,
        fontWeight: FontWeight.w700,
        fontFamily: 'DM Sans',
      ),
    );
  }
}
