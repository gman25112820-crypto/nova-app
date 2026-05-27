import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/notification_service.dart';

// ─────────────────────────────────────────────────────────────
// FAB SETTINGS SCREEN
// Sections: Notifications, Display Preferences (name/avatar),
// About.
// ─────────────────────────────────────────────────────────────

class FabSettingsScreen extends StatefulWidget {
  const FabSettingsScreen({super.key});

  @override
  State<FabSettingsScreen> createState() => _FabSettingsScreenState();
}

class _FabSettingsScreenState extends State<FabSettingsScreen> {
  NotificationPrefs _notifPrefs = const NotificationPrefs();
  String _childName             = '';
  String _selectedAvatar        = '🦆';
  bool   _loading               = true;
  bool   _saving                = false;

  static const _bg     = Color(0xFF0D0820);
  static const _panel  = Color(0xFF1A1040);
  static const _text   = Color(0xFFF2EFFF);
  static const _muted  = Color(0xFF8A8EAB);
  static const _border = Color(0xFF2D2060);
  static const _purple = Color(0xFF6C63FF);
  static const _teal   = Color(0xFF00C9A7);
  static const _pink   = Color(0xFFFF6B8A);
  static const _amber  = Color(0xFFFFB830);

  static const _avatarOptions = [
    '🦆', '🐥', '🦋', '🐢', '🌈', '⭐', '🌙', '🔥',
    '💜', '🌸', '🎮', '🎨',
  ];

  final _nameCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final name   = prefs.getString('child_name') ?? '';
    final avatar = prefs.getString('child_avatar') ?? '🦆';
    if (!mounted) return;
    _nameCtrl.text = name;
    setState(() {
      _notifPrefs    = NotificationService.prefs;
      _childName     = name;
      _selectedAvatar = avatar;
      _loading       = false;
    });
  }

  Future<void> _saveName() async {
    final name = _nameCtrl.text.trim();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('child_name', name);
    setState(() => _childName = name);
    _snack('Name saved ✓');
  }

  Future<void> _saveAvatar(String emoji) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('child_avatar', emoji);
    setState(() => _selectedAvatar = emoji);
  }

  Future<void> _saveNotifs(NotificationPrefs p) async {
    if (_saving) return;
    setState(() => _saving = true);
    final native = await NotificationService.saveAndReschedule(p);
    setState(() {
      _notifPrefs = p;
      _saving     = false;
    });
    if (!native) {
      _snack(NotificationService.webFallbackMessage);
    } else {
      _snack('Reminders updated ✓');
    }
  }

  Future<void> _pickTime(
    BuildContext context,
    TimeOfDay initial,
    void Function(TimeOfDay) onPicked,
  ) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: initial,
      builder: (ctx, child) => Theme(
        data: ThemeData.dark().copyWith(
          colorScheme: const ColorScheme.dark(
            primary: _purple,
            surface: Color(0xFF1A1040),
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) onPicked(picked);
  }

  void _snack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: _teal.withValues(alpha: 0.9),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ));
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        backgroundColor: _bg,
        appBar: AppBar(backgroundColor: _bg, foregroundColor: _text, title: const Text('Settings')),
        body: const Center(child: CircularProgressIndicator(color: _purple)),
      );
    }

    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        foregroundColor: _text,
        elevation: 0,
        title: const Text(
          'Settings',
          style: TextStyle(fontWeight: FontWeight.w700, fontFamily: 'DM Sans'),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 40),
        children: [
          _buildDisplaySection(),
          const SizedBox(height: 20),
          _buildNotifSection(),
          const SizedBox(height: 20),
          _buildAboutSection(),
        ],
      ),
    );
  }

  // ── Display preferences ──────────────────────────────────

  Widget _buildDisplaySection() {
    return _Section(
      icon: Icons.person_rounded,
      title: 'Your Profile',
      accentColor: _pink,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Your name',
            style: TextStyle(color: _muted, fontSize: 12, fontFamily: 'DM Sans')),
        const SizedBox(height: 6),
        Row(children: [
          Expanded(
            child: TextField(
              controller: _nameCtrl,
              style: const TextStyle(color: _text, fontFamily: 'DM Sans'),
              decoration: InputDecoration(
                hintText: 'Enter your name...',
                hintStyle: const TextStyle(color: _muted),
                filled: true,
                fillColor: Colors.white.withValues(alpha: 0.06),
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: _border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: _border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: _purple),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: _saveName,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF6C63FF), Color(0xFF00C9A7)],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'Save',
                style: TextStyle(
                    color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ]),
        const SizedBox(height: 16),
        const Text('Your avatar emoji',
            style: TextStyle(color: _muted, fontSize: 12, fontFamily: 'DM Sans')),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _avatarOptions.map((emoji) {
            final selected = emoji == _selectedAvatar;
            return GestureDetector(
              onTap: () => _saveAvatar(emoji),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: selected ? _purple.withValues(alpha: 0.25) : Colors.white.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: selected ? _purple : Colors.white12,
                    width: selected ? 2.0 : 1.0,
                  ),
                ),
                child: Center(
                  child: Text(emoji, style: const TextStyle(fontSize: 22)),
                ),
              ),
            );
          }).toList(),
        ),
      ]),
    );
  }

  // ── Notifications ─────────────────────────────────────────

  Widget _buildNotifSection() {
    return _Section(
      icon: Icons.notifications_outlined,
      title: 'Reminders',
      accentColor: _amber,
      child: Column(children: [
        if (kIsWeb)
          Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: _amber.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: _amber.withValues(alpha: 0.30)),
            ),
            child: const Row(children: [
              Icon(Icons.info_outline, color: _amber, size: 16),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Push notifications are not supported in the browser. Install the app for real reminders.',
                  style: TextStyle(color: _amber, fontSize: 11, height: 1.4),
                ),
              ),
            ]),
          ),
        _notifRow(
          emoji: '⭐',
          label: 'Daily check-in',
          subtitle: 'Evening reminder to check in',
          enabled: _notifPrefs.checkInEnabled,
          time: _notifPrefs.checkInTime,
          onToggle: (v) => _saveNotifs(NotificationPrefs(
            checkInEnabled: v,
            checkInTime:    _notifPrefs.checkInTime,
            bedtimeEnabled: _notifPrefs.bedtimeEnabled,
            bedtimeTime:    _notifPrefs.bedtimeTime,
            morningEnabled: _notifPrefs.morningEnabled,
            morningTime:    _notifPrefs.morningTime,
          )),
          onTimeTap: () => _pickTime(context, _notifPrefs.checkInTime, (t) => _saveNotifs(NotificationPrefs(
            checkInEnabled: _notifPrefs.checkInEnabled,
            checkInTime:    t,
            bedtimeEnabled: _notifPrefs.bedtimeEnabled,
            bedtimeTime:    _notifPrefs.bedtimeTime,
            morningEnabled: _notifPrefs.morningEnabled,
            morningTime:    _notifPrefs.morningTime,
          ))),
        ),
        const Divider(color: Colors.white10, height: 24),
        _notifRow(
          emoji: '🌙',
          label: 'Bedtime log',
          subtitle: 'Reminder to log tonight\'s sleep',
          enabled: _notifPrefs.bedtimeEnabled,
          time: _notifPrefs.bedtimeTime,
          onToggle: (v) => _saveNotifs(NotificationPrefs(
            checkInEnabled: _notifPrefs.checkInEnabled,
            checkInTime:    _notifPrefs.checkInTime,
            bedtimeEnabled: v,
            bedtimeTime:    _notifPrefs.bedtimeTime,
            morningEnabled: _notifPrefs.morningEnabled,
            morningTime:    _notifPrefs.morningTime,
          )),
          onTimeTap: () => _pickTime(context, _notifPrefs.bedtimeTime, (t) => _saveNotifs(NotificationPrefs(
            checkInEnabled: _notifPrefs.checkInEnabled,
            checkInTime:    _notifPrefs.checkInTime,
            bedtimeEnabled: _notifPrefs.bedtimeEnabled,
            bedtimeTime:    t,
            morningEnabled: _notifPrefs.morningEnabled,
            morningTime:    _notifPrefs.morningTime,
          ))),
        ),
        const Divider(color: Colors.white10, height: 24),
        _notifRow(
          emoji: '🌅',
          label: 'Morning check-in',
          subtitle: 'Start the day with a mood check',
          enabled: _notifPrefs.morningEnabled,
          time: _notifPrefs.morningTime,
          onToggle: (v) => _saveNotifs(NotificationPrefs(
            checkInEnabled: _notifPrefs.checkInEnabled,
            checkInTime:    _notifPrefs.checkInTime,
            bedtimeEnabled: _notifPrefs.bedtimeEnabled,
            bedtimeTime:    _notifPrefs.bedtimeTime,
            morningEnabled: v,
            morningTime:    _notifPrefs.morningTime,
          )),
          onTimeTap: () => _pickTime(context, _notifPrefs.morningTime, (t) => _saveNotifs(NotificationPrefs(
            checkInEnabled: _notifPrefs.checkInEnabled,
            checkInTime:    _notifPrefs.checkInTime,
            bedtimeEnabled: _notifPrefs.bedtimeEnabled,
            bedtimeTime:    _notifPrefs.bedtimeTime,
            morningEnabled: _notifPrefs.morningEnabled,
            morningTime:    t,
          ))),
        ),
      ]),
    );
  }

  Widget _notifRow({
    required String emoji,
    required String label,
    required String subtitle,
    required bool enabled,
    required TimeOfDay time,
    required void Function(bool) onToggle,
    required VoidCallback onTimeTap,
  }) {
    return Row(children: [
      Text(emoji, style: const TextStyle(fontSize: 20)),
      const SizedBox(width: 12),
      Expanded(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label,
              style: TextStyle(
                color: enabled ? _text : _muted,
                fontSize: 13,
                fontWeight: FontWeight.w600,
                fontFamily: 'DM Sans',
              )),
          Text(subtitle,
              style: const TextStyle(color: _muted, fontSize: 11)),
        ]),
      ),
      if (enabled)
        GestureDetector(
          onTap: onTimeTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: _purple.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: _purple.withValues(alpha: 0.35)),
            ),
            child: Text(
              NotificationService.fmtTime(time),
              style: const TextStyle(
                  color: _purple, fontSize: 11, fontWeight: FontWeight.w700),
            ),
          ),
        ),
      Switch(
        value: enabled,
        onChanged: onToggle,
        activeColor: _teal,
        inactiveThumbColor: _muted,
        inactiveTrackColor: Colors.white12,
      ),
    ]);
  }

  // ── About ─────────────────────────────────────────────────

  Widget _buildAboutSection() {
    return _Section(
      icon: Icons.info_outline_rounded,
      title: 'About',
      accentColor: _teal,
      child: Column(children: [
        _aboutRow(Icons.favorite_rounded, _pink, 'Fabulously Me', 'Version 1.0.0'),
        const Divider(color: Colors.white10, height: 20),
        _aboutRow(Icons.lock_outline_rounded, _teal, 'Privacy', 'All your data stays on this device. Nothing is ever sent to anyone.'),
        const Divider(color: Colors.white10, height: 20),
        _aboutRow(Icons.star_rounded, _amber, 'Stars', 'Earn stars by checking in every day. Spend them in the Duck Shop!'),
        const Divider(color: Colors.white10, height: 20),
        _aboutRow(Icons.code_rounded, _purple, 'Built with ❤️', 'Made with Flutter'),
      ]),
    );
  }

  Widget _aboutRow(IconData icon, Color color, String title, String detail) {
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Icon(icon, color: color, size: 18),
      const SizedBox(width: 12),
      Expanded(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title,
              style: const TextStyle(
                  color: _text, fontSize: 13, fontWeight: FontWeight.w600, fontFamily: 'DM Sans')),
          const SizedBox(height: 2),
          Text(detail,
              style: const TextStyle(color: _muted, fontSize: 12, height: 1.4)),
        ]),
      ),
    ]);
  }
}

// ─────────────────────────────────────────────────────────────
// Section panel widget
// ─────────────────────────────────────────────────────────────

class _Section extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color accentColor;
  final Widget child;

  const _Section({
    required this.icon,
    required this.title,
    required this.accentColor,
    required this.child,
  });

  static const _panel  = Color(0xFF1A1040);
  static const _text   = Color(0xFFF2EFFF);
  static const _border = Color(0xFF2D2060);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _panel,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: accentColor.withValues(alpha: 0.25)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(icon, color: accentColor, size: 18),
          const SizedBox(width: 9),
          Text(
            title,
            style: TextStyle(
              color: accentColor,
              fontSize: 14,
              fontWeight: FontWeight.w700,
              fontFamily: 'DM Sans',
            ),
          ),
        ]),
        const SizedBox(height: 14),
        child,
      ]),
    );
  }
}
