import 'dart:convert';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:nova_app/core/repositories/check_in_repository.dart';
import 'package:nova_app/core/services/export_service.dart';
import 'package:nova_app/features/export/helpers/web_download.dart';
import 'package:nova_app/main.dart';

// Native notification service — no-op stub on web.
import 'package:nova_app/fab/services/notification_service_native.dart'
    if (dart.library.html) 'package:nova_app/fab/services/notification_service_stub.dart'
    as notif_native;

// ─────────────────────────────────────────────────────────────────────────────
// Notification prefs model
// ─────────────────────────────────────────────────────────────────────────────

const String _kNotifPrefsKey = 'nova_notification_prefs';

class _NotifPrefs {
  bool painEnabled;
  int painHour;
  int painMinute;
  bool medEnabled;
  int medHour;
  int medMinute;
  bool sleepEnabled;
  int sleepHour;
  int sleepMinute;

  _NotifPrefs({
    this.painEnabled = true,
    this.painHour = 19,
    this.painMinute = 0,
    this.medEnabled = true,
    this.medHour = 8,
    this.medMinute = 0,
    this.sleepEnabled = true,
    this.sleepHour = 21,
    this.sleepMinute = 30,
  });

  factory _NotifPrefs.fromJson(Map<String, dynamic> j) => _NotifPrefs(
        painEnabled: j['painEnabled'] as bool? ?? true,
        painHour: j['painHour'] as int? ?? 19,
        painMinute: j['painMinute'] as int? ?? 0,
        medEnabled: j['medEnabled'] as bool? ?? true,
        medHour: j['medHour'] as int? ?? 8,
        medMinute: j['medMinute'] as int? ?? 0,
        sleepEnabled: j['sleepEnabled'] as bool? ?? true,
        sleepHour: j['sleepHour'] as int? ?? 21,
        sleepMinute: j['sleepMinute'] as int? ?? 30,
      );

  Map<String, dynamic> toJson() => {
        'painEnabled': painEnabled,
        'painHour': painHour,
        'painMinute': painMinute,
        'medEnabled': medEnabled,
        'medHour': medHour,
        'medMinute': medMinute,
        'sleepEnabled': sleepEnabled,
        'sleepHour': sleepHour,
        'sleepMinute': sleepMinute,
      };
}

// ─────────────────────────────────────────────────────────────────────────────
// Screen
// ─────────────────────────────────────────────────────────────────────────────

class NovaSettingsScreen extends StatefulWidget {
  const NovaSettingsScreen({super.key});

  @override
  State<NovaSettingsScreen> createState() => _NovaSettingsScreenState();
}

class _NovaSettingsScreenState extends State<NovaSettingsScreen> {
  // ── Palette ────────────────────────────────────────────────────────────────
  static const _bg     = Color(0xFF090C18);
  static const _panel  = Color(0xFF13172A);
  static const _border = Color(0xFF252845);
  static const _text   = Color(0xFFF2EFFF);
  static const _muted  = Color(0xFFAAABC8);
  static const _blue   = Color(0xFF5DADEC);
  static const _purple = Color(0xFF9B8FFF);
  static const _rose   = Color(0xFFFF6FAE);
  static const _teal   = Color(0xFF46D6C8);
  static const _amber  = Color(0xFFFFC857);
  static const _red    = Color(0xFFFF6B6B);

  // ── State ──────────────────────────────────────────────────────────────────
  _NotifPrefs _prefs = _NotifPrefs();
  double _textScale = 1.0;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final sp = await SharedPreferences.getInstance();
    final raw = sp.getString(_kNotifPrefsKey);
    final scale = sp.getDouble('nova_text_scale') ?? 1.0;
    if (mounted) {
      setState(() {
        if (raw != null) {
          try {
            _prefs = _NotifPrefs.fromJson(
                jsonDecode(raw) as Map<String, dynamic>);
          } catch (_) {
            _prefs = _NotifPrefs();
          }
        }
        _textScale = scale;
        _loading = false;
      });
    }
  }

  // ── Persistence + scheduling ───────────────────────────────────────────────

  Future<void> _savePrefs() async {
    final sp = await SharedPreferences.getInstance();
    await sp.setString(_kNotifPrefsKey, jsonEncode(_prefs.toJson()));
    if (!kIsWeb) {
      await _rescheduleAll();
    }
  }

  Future<void> _rescheduleAll() async {
    // Cancel only the three Nova notification IDs (10, 11, 12).
    await notif_native.cancelById(10);
    await notif_native.cancelById(11);
    await notif_native.cancelById(12);

    if (_prefs.painEnabled) {
      await notif_native.scheduleDailyNotification(
        id: 10,
        title: 'Nova — Pain check-in',
        body: 'How are you feeling today? Take a moment to log your pain.',
        hour: _prefs.painHour,
        minute: _prefs.painMinute,
      );
    }
    if (_prefs.medEnabled) {
      await notif_native.scheduleDailyNotification(
        id: 11,
        title: 'Nova — Medication reminder',
        body: 'Remember to take your medication today.',
        hour: _prefs.medHour,
        minute: _prefs.medMinute,
      );
    }
    if (_prefs.sleepEnabled) {
      await notif_native.scheduleDailyNotification(
        id: 12,
        title: 'Nova — Sleep log',
        body: 'How did you sleep? Log your rest before you wind down.',
        hour: _prefs.sleepHour,
        minute: _prefs.sleepMinute,
      );
    }
  }

  Future<void> _saveTextScale(double scale) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setDouble('nova_text_scale', scale);
    NovaApp.textScaleNotifier.value = scale;
    if (mounted) setState(() => _textScale = scale);
  }

  // ── Export helpers ─────────────────────────────────────────────────────────

  Future<void> _exportCsv() async {
    final entries = await CheckInRepository().getAllEntries();
    if (entries.isEmpty) { _snack('No entries to export.', error: true); return; }
    final csv = ExportService().generateCsv(entries);
    final name = 'nova_pain_log_${_today()}.csv';
    triggerDownload(csv, name, 'text/csv');
    _snack('CSV exported — $name');
  }

  Future<void> _exportHtml() async {
    final entries = await CheckInRepository().getAllEntries();
    if (entries.isEmpty) { _snack('No entries to export.', error: true); return; }
    final html = ExportService().generateHtmlReport(entries, 'Nova User');
    final name = 'nova_pain_report_${_today()}.html';
    triggerDownload(html, name, 'text/html');
    _snack('Report exported — $name');
  }

  // ── Danger-zone actions ────────────────────────────────────────────────────

  Future<void> _clearCheckins() async {
    final confirm = await _confirmDialog(
      'Clear check-in data?',
      'This will permanently delete all pain check-in entries. '
      'This cannot be undone.',
    );
    if (!confirm) return;
    await Hive.box<Map>('checkins').clear();
    _snack('All check-in entries deleted.');
  }

  Future<void> _clearProfile() async {
    final confirm = await _confirmDialog(
      'Clear Health Profile?',
      'This will delete your saved health profile including conditions, '
      'medications, and medical team. This cannot be undone.',
    );
    if (!confirm) return;
    final sp = await SharedPreferences.getInstance();
    await sp.remove('nova_health_profile');
    _snack('Health Profile cleared.');
  }

  Future<void> _clearBookmarks() async {
    final confirm = await _confirmDialog(
      'Clear advice bookmarks?',
      'All saved Advice Hub bookmarks will be removed.',
    );
    if (!confirm) return;
    final sp = await SharedPreferences.getInstance();
    await sp.remove('nova_advice_bookmarks');
    _snack('Bookmarks cleared.');
  }

  // ── UI helpers ─────────────────────────────────────────────────────────────

  Future<bool> _confirmDialog(String title, String body) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: _panel,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16)),
        title: Text(title,
            style: const TextStyle(color: _text, fontWeight: FontWeight.w600)),
        content: Text(body,
            style: const TextStyle(color: _muted, fontSize: 14, height: 1.5)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel',
                style: TextStyle(color: _muted)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete',
                style: TextStyle(color: _red, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  void _snack(String msg, {bool error = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor:
          error ? _red.withValues(alpha: 0.9) : _blue.withValues(alpha: 0.9),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      duration: const Duration(seconds: 3),
    ));
  }

  String _today() {
    final n = DateTime.now();
    return '${n.year}-${n.month.toString().padLeft(2,'0')}-${n.day.toString().padLeft(2,'0')}';
  }

  String _fmtTime(int h, int m) {
    final hh = h.toString().padLeft(2, '0');
    final mm = m.toString().padLeft(2, '0');
    return '$hh:$mm';
  }

  Future<void> _pickTime({
    required String label,
    required int hour,
    required int minute,
    required void Function(int h, int m) onPicked,
  }) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: hour, minute: minute),
      helpText: 'Set time for $label',
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: ColorScheme.dark(
            primary: _blue,
            onPrimary: _bg,
            surface: _panel,
            onSurface: _text,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null && mounted) {
      setState(() => onPicked(picked.hour, picked.minute));
      await _savePrefs();
    }
  }

  // ── Privacy policy text ────────────────────────────────────────────────────

  void _showPrivacyPolicy() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: _panel,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.7,
        maxChildSize: 0.95,
        minChildSize: 0.4,
        builder: (_, controller) => ListView(
          controller: controller,
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
          children: [
            Center(
              child: Container(
                width: 40, height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                    color: _border,
                    borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const Text('Privacy Policy',
                style: TextStyle(
                    color: _text, fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 16),
            const Text(
              'Nova Health is a local-only personal record tool.\n\n'
              'All data you enter — pain ratings, health profile, check-in history, notes — '
              'is stored exclusively on this device using Hive (local database) and '
              'SharedPreferences.\n\n'
              'No accounts are created. No data is transmitted to any server, cloud service, '
              'or third party. No analytics, crash reporting, or telemetry of any kind is collected.\n\n'
              'Exports (CSV, HTML, PDF) are generated on-device and shared only by your explicit action.\n\n'
              'Nova is a personal record tool, not a medical service. It does not diagnose '
              'conditions, prescribe treatment, or replace professional medical advice. Always '
              'consult your GP or specialist for clinical decisions.\n\n'
              'To delete your data, use the Data Management section in Settings. '
              'Uninstalling the app removes all local data permanently.',
              style: TextStyle(color: _muted, fontSize: 14, height: 1.65),
            ),
            const SizedBox(height: 24),
            const Text('Last updated: May 2026',
                style: TextStyle(color: _muted, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        foregroundColor: _text,
        elevation: 0,
        title: const Text('Settings',
            style: TextStyle(fontWeight: FontWeight.w600)),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 48),
              children: [
                // ── Notifications ──────────────────────────────────────────
                _sectionHeader(
                  icon: Icons.notifications_outlined,
                  color: _purple,
                  label: 'NOTIFICATIONS',
                ),
                if (kIsWeb)
                  _infoCard(
                    'Not available on web',
                    'Push notifications require the native Android or iOS app.',
                    Icons.info_outline_rounded,
                    _muted,
                  )
                else ...[
                  _notifRow(
                    icon: Icons.accessibility_new_rounded,
                    color: _rose,
                    label: 'Pain check-in reminder',
                    subtitle: 'Daily reminder to log your pain',
                    enabled: _prefs.painEnabled,
                    hour: _prefs.painHour,
                    minute: _prefs.painMinute,
                    onToggle: (v) {
                      setState(() => _prefs.painEnabled = v);
                      _savePrefs();
                    },
                    onTimeTap: () => _pickTime(
                      label: 'pain check-in',
                      hour: _prefs.painHour,
                      minute: _prefs.painMinute,
                      onPicked: (h, m) {
                        _prefs.painHour = h;
                        _prefs.painMinute = m;
                      },
                    ),
                  ),
                  _notifRow(
                    icon: Icons.medication_outlined,
                    color: _amber,
                    label: 'Medication reminder',
                    subtitle: 'Daily prompt to take your medication',
                    enabled: _prefs.medEnabled,
                    hour: _prefs.medHour,
                    minute: _prefs.medMinute,
                    onToggle: (v) {
                      setState(() => _prefs.medEnabled = v);
                      _savePrefs();
                    },
                    onTimeTap: () => _pickTime(
                      label: 'medication',
                      hour: _prefs.medHour,
                      minute: _prefs.medMinute,
                      onPicked: (h, m) {
                        _prefs.medHour = h;
                        _prefs.medMinute = m;
                      },
                    ),
                  ),
                  _notifRow(
                    icon: Icons.bedtime_outlined,
                    color: _blue,
                    label: 'Sleep log reminder',
                    subtitle: 'Evening prompt to record sleep quality',
                    enabled: _prefs.sleepEnabled,
                    hour: _prefs.sleepHour,
                    minute: _prefs.sleepMinute,
                    onToggle: (v) {
                      setState(() => _prefs.sleepEnabled = v);
                      _savePrefs();
                    },
                    onTimeTap: () => _pickTime(
                      label: 'sleep log',
                      hour: _prefs.sleepHour,
                      minute: _prefs.sleepMinute,
                      onPicked: (h, m) {
                        _prefs.sleepHour = h;
                        _prefs.sleepMinute = m;
                      },
                    ),
                  ),
                ],
                const SizedBox(height: 28),

                // ── Data Management ────────────────────────────────────────
                _sectionHeader(
                  icon: Icons.storage_outlined,
                  color: _teal,
                  label: 'DATA MANAGEMENT',
                ),
                if (kIsWeb) ...[
                  _actionTile(
                    icon: Icons.download_rounded,
                    color: _teal,
                    label: 'Export as CSV',
                    subtitle: 'Download your pain log as a spreadsheet',
                    onTap: _exportCsv,
                  ),
                  _actionTile(
                    icon: Icons.picture_as_pdf_rounded,
                    color: _blue,
                    label: 'Export as HTML report',
                    subtitle: 'Download a formatted health report',
                    onTap: _exportHtml,
                  ),
                ] else
                  _infoCard(
                    'Export via Clinician Report',
                    'Use the Clinician Report module in Nova Health to generate '
                    'and share a structured PDF.',
                    Icons.picture_as_pdf_rounded,
                    _blue,
                  ),
                const SizedBox(height: 12),
                _dangerTile(
                  icon: Icons.delete_sweep_rounded,
                  label: 'Clear check-in history',
                  subtitle: 'Delete all pain & nerve check-in entries',
                  onTap: _clearCheckins,
                ),
                _dangerTile(
                  icon: Icons.person_off_outlined,
                  label: 'Clear Health Profile',
                  subtitle: 'Remove your saved conditions, medications, and profile',
                  onTap: _clearProfile,
                ),
                _dangerTile(
                  icon: Icons.bookmark_remove_outlined,
                  label: 'Clear advice bookmarks',
                  subtitle: 'Remove all saved Advice Hub cards',
                  onTap: _clearBookmarks,
                ),
                const SizedBox(height: 28),

                // ── Preferences ────────────────────────────────────────────
                _sectionHeader(
                  icon: Icons.tune_rounded,
                  color: _amber,
                  label: 'PREFERENCES',
                ),
                _card(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Text size',
                          style: TextStyle(
                              color: _text,
                              fontWeight: FontWeight.w600,
                              fontSize: 15)),
                      const SizedBox(height: 4),
                      const Text(
                          'Adjusts text size across the whole app.',
                          style: TextStyle(color: _muted, fontSize: 13)),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          _scaleChip(label: 'Normal',     scale: 1.0),
                          const SizedBox(width: 10),
                          _scaleChip(label: 'Large',      scale: 1.2),
                          const SizedBox(width: 10),
                          _scaleChip(label: 'Extra Large', scale: 1.4),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                _card(
                  child: Row(
                    children: [
                      Container(
                        width: 36, height: 36,
                        decoration: BoxDecoration(
                          color: _muted.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.dark_mode_outlined,
                            color: _muted, size: 20),
                      ),
                      const SizedBox(width: 14),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Appearance',
                                style: TextStyle(
                                    color: _text,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 15)),
                            SizedBox(height: 2),
                            Text(
                                'Dark theme only — optimised for low-light use.',
                                style: TextStyle(color: _muted, fontSize: 13)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),

                // ── About ──────────────────────────────────────────────────
                _sectionHeader(
                  icon: Icons.info_outline_rounded,
                  color: _blue,
                  label: 'ABOUT',
                ),
                _card(
                  child: Column(
                    children: [
                      _aboutRow(
                        icon: Icons.apps_rounded,
                        color: _blue,
                        label: 'Version',
                        trailing: const Text(
                          'Nova 4.0.0',
                          style: TextStyle(color: _muted, fontSize: 13),
                        ),
                      ),
                      _divider(),
                      _aboutRow(
                        icon: Icons.shield_outlined,
                        color: _teal,
                        label: 'Privacy Policy',
                        onTap: _showPrivacyPolicy,
                        trailing: Icon(Icons.chevron_right_rounded,
                            color: _muted.withValues(alpha: 0.5), size: 20),
                      ),
                      _divider(),
                      _aboutRow(
                        icon: Icons.mail_outline_rounded,
                        color: _amber,
                        label: 'Send feedback',
                        onTap: _showFeedbackSheet,
                        trailing: Icon(Icons.chevron_right_rounded,
                            color: _muted.withValues(alpha: 0.5), size: 20),
                      ),
                      _divider(),
                      _aboutRow(
                        icon: Icons.article_outlined,
                        color: _purple,
                        label: 'Open-source licences',
                        onTap: () => showLicensePage(
                          context: context,
                          applicationName: 'Nova',
                          applicationVersion: '4.0.0',
                        ),
                        trailing: Icon(Icons.chevron_right_rounded,
                            color: _muted.withValues(alpha: 0.5), size: 20),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                const Center(
                  child: Text(
                    'Nova Health — personal pain management\n'
                    'All data stays on this device.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: Color(0xFF555875),
                        fontSize: 12,
                        height: 1.6),
                  ),
                ),
              ],
            ),
    );
  }

  // ── Build helpers ──────────────────────────────────────────────────────────

  Widget _sectionHeader({
    required IconData icon,
    required Color color,
    required String label,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.9,
            ),
          ),
        ],
      ),
    );
  }

  Widget _card({required Widget child}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _panel,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _border, width: 1),
      ),
      child: child,
    );
  }

  Widget _infoCard(String title, String body, IconData icon, Color color) {
    return _card(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        color: _text,
                        fontWeight: FontWeight.w600,
                        fontSize: 14)),
                const SizedBox(height: 4),
                Text(body,
                    style: const TextStyle(
                        color: _muted, fontSize: 13, height: 1.45)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _notifRow({
    required IconData icon,
    required Color color,
    required String label,
    required String subtitle,
    required bool enabled,
    required int hour,
    required int minute,
    required ValueChanged<bool> onToggle,
    required VoidCallback onTimeTap,
  }) {
    return _card(
      child: Row(
        children: [
          Container(
            width: 38, height: 38,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(
                        color: _text,
                        fontWeight: FontWeight.w600,
                        fontSize: 14.5)),
                const SizedBox(height: 2),
                Text(subtitle,
                    style: const TextStyle(color: _muted, fontSize: 12.5)),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: enabled ? onTimeTap : null,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: enabled
                          ? color.withValues(alpha: 0.12)
                          : _border.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: enabled
                            ? color.withValues(alpha: 0.3)
                            : _border,
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.schedule_rounded,
                          size: 14,
                          color: enabled ? color : _muted,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          _fmtTime(hour, minute),
                          style: TextStyle(
                            color: enabled ? color : _muted,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (enabled) ...[
                          const SizedBox(width: 4),
                          Icon(Icons.edit_rounded,
                              size: 11,
                              color: color.withValues(alpha: 0.7)),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: enabled,
            onChanged: onToggle,
            activeThumbColor: color,
            activeTrackColor: color.withValues(alpha: 0.3),
            inactiveThumbColor: _muted,
            inactiveTrackColor: _border,
          ),
        ],
      ),
    );
  }

  Widget _actionTile({
    required IconData icon,
    required Color color,
    required String label,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: _card(
        child: Row(
          children: [
            Container(
              width: 38, height: 38,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: const TextStyle(
                          color: _text,
                          fontWeight: FontWeight.w600,
                          fontSize: 14.5)),
                  const SizedBox(height: 2),
                  Text(subtitle,
                      style: const TextStyle(
                          color: _muted, fontSize: 12.5)),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded,
                color: _muted.withValues(alpha: 0.5), size: 20),
          ],
        ),
      ),
    );
  }

  Widget _dangerTile({
    required IconData icon,
    required String label,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: _card(
        child: Row(
          children: [
            Container(
              width: 38, height: 38,
              decoration: BoxDecoration(
                color: _red.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: _red, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: const TextStyle(
                          color: _red,
                          fontWeight: FontWeight.w600,
                          fontSize: 14.5)),
                  const SizedBox(height: 2),
                  Text(subtitle,
                      style: const TextStyle(
                          color: _muted, fontSize: 12.5)),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded,
                color: _red.withValues(alpha: 0.4), size: 20),
          ],
        ),
      ),
    );
  }

  Widget _scaleChip({required String label, required double scale}) {
    final selected = (_textScale - scale).abs() < 0.05;
    return GestureDetector(
      onTap: () => _saveTextScale(scale),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? _amber.withValues(alpha: 0.18) : _border.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected ? _amber.withValues(alpha: 0.6) : _border,
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? _amber : _muted,
            fontSize: 13,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
          ),
        ),
      ),
    );
  }

  Widget _aboutRow({
    required IconData icon,
    required Color color,
    required String label,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            Container(
              width: 34, height: 34,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(9),
              ),
              child: Icon(icon, color: color, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
                child: Text(label,
                    style: const TextStyle(
                        color: _text,
                        fontWeight: FontWeight.w500,
                        fontSize: 14.5))),
            if (trailing != null) trailing,
          ],
        ),
      ),
    );
  }

  Widget _divider() => Divider(
        color: _border,
        height: 1,
        thickness: 1,
      );

  void _showFeedbackSheet() {
    const email = 'feedback@nova-health.app';
    showModalBottomSheet(
      context: context,
      backgroundColor: _panel,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Send Feedback',
                style: TextStyle(
                    color: _text,
                    fontSize: 18,
                    fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            const Text(
              'Have a suggestion, spotted a bug, or want to share something? '
              'Drop us a message at the address below.',
              style: TextStyle(color: _muted, fontSize: 14, height: 1.5),
            ),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: () {
                Clipboard.setData(const ClipboardData(text: email));
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: const Text('Email address copied'),
                  backgroundColor: _blue.withValues(alpha: 0.9),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  duration: const Duration(seconds: 2),
                ));
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: _blue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: _blue.withValues(alpha: 0.3), width: 1),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.mail_outline_rounded,
                        color: _blue, size: 18),
                    const SizedBox(width: 10),
                    const Text(
                      email,
                      style: TextStyle(
                          color: _blue,
                          fontWeight: FontWeight.w600,
                          fontSize: 14),
                    ),
                    const SizedBox(width: 10),
                    Icon(Icons.copy_rounded,
                        color: _blue.withValues(alpha: 0.7),
                        size: 14),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
