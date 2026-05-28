import 'package:flutter/material.dart';
import '../models/child_profile.dart';
import '../models/family_account.dart';
import '../services/storage_service.dart';
import 'skeleton_key_screen.dart';
import 'little_ones_log_screen.dart';
import 'report_generator_screen.dart';
import 'what_helps_screen.dart';
import 'recipe_screen.dart';

// ─────────────────────────────────────────────────────────────
// FamilyDashboardScreen
//
// Parent-only hub. Lists every ChildProfile with:
//   - AgeMode, PIN status, logging streak, avg sleep, last log
//   - Auto-alert banner if 3+ poor sleep nights in last 7
//   - Buttons: Skeleton Key, Report (placeholder until Job 11)
//
// Also handles:
//   - First-run account creation
//   - Parent password setup (required for skeleton key)
//   - Add / remove child profiles
// ─────────────────────────────────────────────────────────────

class FamilyDashboardScreen extends StatefulWidget {
  const FamilyDashboardScreen({super.key});

  @override
  State<FamilyDashboardScreen> createState() => _FamilyDashboardScreenState();
}

class _FamilyDashboardScreenState extends State<FamilyDashboardScreen> {
  static const _bg     = Color(0xFF0D0820);
  static const _purple = Color(0xFF6C63FF);
  static const _amber  = Color(0xFFFFB830);
  static const _pink   = Color(0xFFFF6B8A);
  static const _teal   = Color(0xFF00C9A7);
  static const _card   = Color(0xFF120C28);

  FamilyAccount? _account;

  @override
  void initState() {
    super.initState();
    _account = FamilyAccount.current;
  }

  void _refresh() => setState(() => _account = FamilyAccount.current);

  // ── Stats ────────────────────────────────────────────────────

  int _streak(String childId) {
    List<Map<String, dynamic>> entries;
    try {
      entries = StorageService.allDataEntries(childId);
    } catch (_) {
      return 0;
    }
    if (entries.isEmpty) return 0;

    final days = <String>{};
    for (final e in entries) {
      final dt = DateTime.tryParse(e['timestamp'] as String? ?? '');
      if (dt != null) days.add(_dayKey(dt));
    }

    int streak = 0;
    var date = DateTime.now();
    while (days.contains(_dayKey(date))) {
      streak++;
      date = date.subtract(const Duration(days: 1));
    }
    return streak;
  }

  double? _avgSleep(String childId) {
    List<Map<String, dynamic>> sleepEntries;
    try {
      sleepEntries = StorageService.allDataEntries(childId)
          .where((e) => e['type'] == 'sleep')
          .toList();
    } catch (_) {
      return null;
    }
    if (sleepEntries.isEmpty) return null;
    final vals = sleepEntries
        .take(14)
        .map((e) => (e['hours'] as num?)?.toDouble())
        .whereType<double>()
        .toList();
    if (vals.isEmpty) return null;
    return vals.reduce((a, b) => a + b) / vals.length;
  }

  bool _poorSleepAlert(String childId) {
    List<Map<String, dynamic>> sleepEntries;
    try {
      sleepEntries = StorageService.allDataEntries(childId)
          .where((e) => e['type'] == 'sleep')
          .toList();
    } catch (_) {
      return false;
    }
    if (sleepEntries.length < 3) return false;
    int poor = 0;
    for (final e in sleepEntries.take(7)) {
      final quality = e['quality'] as String?;
      final hours   = (e['hours'] as num?)?.toDouble();
      if (quality == 'poor' || (hours != null && hours < 6)) poor++;
    }
    return poor >= 3;
  }

  DateTime? _lastLog(String childId) {
    List<Map<String, dynamic>> entries;
    try {
      entries = StorageService.allDataEntries(childId);
    } catch (_) {
      return null;
    }
    DateTime? latest;
    for (final e in entries) {
      final dt = DateTime.tryParse(e['timestamp'] as String? ?? '');
      if (dt != null && (latest == null || dt.isAfter(latest))) latest = dt;
    }
    return latest;
  }

  String _dayKey(DateTime dt) =>
      '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';

  String _relativeDate(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inDays == 0) return 'Today';
    if (diff.inDays == 1) return 'Yesterday';
    if (diff.inDays < 7)  return '${diff.inDays}d ago';
    return '${(diff.inDays / 7).floor()}w ago';
  }

  // ── Build ────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Family Hub',
          style: TextStyle(fontWeight: FontWeight.w700, fontFamily: 'DM Sans'),
        ),
        actions: [
          if (_account != null)
            IconButton(
              icon: const Icon(Icons.manage_accounts_outlined, size: 22),
              tooltip: 'Account settings',
              onPressed: _showAccountSettings,
            ),
        ],
      ),
      body: _account == null ? _buildNoAccount() : _buildDashboard(),
      floatingActionButton: _account == null
          ? null
          : FloatingActionButton.extended(
              onPressed: _showAddChild,
              backgroundColor: _purple,
              foregroundColor: Colors.white,
              icon: const Icon(Icons.person_add_rounded),
              label: const Text(
                'Add child',
                style: TextStyle(fontFamily: 'DM Sans', fontWeight: FontWeight.w600),
              ),
            ),
    );
  }

  Widget _buildNoAccount() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('👨‍👩‍👧', style: TextStyle(fontSize: 56)),
            const SizedBox(height: 20),
            const Text(
              'Set up Family Hub',
              style: TextStyle(
                color: Colors.white, fontSize: 22,
                fontWeight: FontWeight.w700, fontFamily: 'DM Sans',
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Create your family account to manage child profiles, '
              'track wellbeing, and access parent tools.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.55), fontSize: 14, height: 1.6,
              ),
            ),
            const SizedBox(height: 28),
            GestureDetector(
              onTap: _createAccount,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                      colors: [Color(0xFF6C63FF), Color(0xFF00C9A7)]),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Text(
                  'Create family account',
                  style: TextStyle(
                    color: Colors.white, fontSize: 16,
                    fontWeight: FontWeight.w700, fontFamily: 'DM Sans',
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboard() {
    final account  = _account!;
    final children = account.children;

    return CustomScrollView(
      slivers: [
        if (account.passwordHash == null)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: _buildPasswordWarning(),
            ),
          ),
        if (children.isEmpty)
          const SliverFillRemaining(child: _EmptyChildrenView())
        else ...[
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (_, i) => _buildChildCard(children[i]),
                childCount: children.length,
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 88)),
        ],
      ],
    );
  }

  Widget _buildPasswordWarning() {
    return GestureDetector(
      onTap: _showSetPassword,
      child: Container(
        margin: const EdgeInsets.only(bottom: 4),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: _amber.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _amber.withValues(alpha: 0.35)),
        ),
        child: Row(
          children: [
            const Icon(Icons.warning_amber_rounded, color: _amber, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Set a parent password to enable skeleton key emergency access.',
                style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.75), fontSize: 13),
              ),
            ),
            const SizedBox(width: 6),
            const Text(
              'Set up',
              style: TextStyle(
                  color: _amber, fontSize: 13, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChildCard(ChildProfile child) {
    final streak   = _streak(child.id);
    final avgSleep = _avgSleep(child.id);
    final lastLog  = _lastLog(child.id);
    final alert    = _poorSleepAlert(child.id);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: alert
              ? _pink.withValues(alpha: 0.45)
              : Colors.white.withValues(alpha: 0.08),
          width: alert ? 1.5 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ───────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
            child: Row(
              children: [
                Text(child.ageMode.emoji,
                    style: const TextStyle(fontSize: 28)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        child.name,
                        style: const TextStyle(
                          color: Colors.white, fontSize: 17,
                          fontWeight: FontWeight.w700, fontFamily: 'DM Sans',
                        ),
                      ),
                      Text(
                        '${child.ageMode.label} · ${child.age} yrs',
                        style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.45),
                            fontSize: 12),
                      ),
                    ],
                  ),
                ),
                _PinChip(child: child),
                const SizedBox(width: 4),
                IconButton(
                  icon: Icon(Icons.delete_outline_rounded,
                      color: Colors.white.withValues(alpha: 0.20),
                      size: 18),
                  onPressed: () => _confirmRemoveChild(child),
                  tooltip: 'Remove child',
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                      minWidth: 28, minHeight: 28),
                ),
              ],
            ),
          ),

          // ── Poor sleep alert ──────────────────────────────────
          if (alert)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: _pink.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(8),
                  border:
                      Border.all(color: _pink.withValues(alpha: 0.30)),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.bedtime_outlined, color: _pink, size: 14),
                    SizedBox(width: 6),
                    Text(
                      '3+ nights of poor sleep recently',
                      style: TextStyle(
                          color: _pink,
                          fontSize: 12,
                          fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
            ),

          // ── Stats ────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Wrap(
              spacing: 8,
              runSpacing: 6,
              children: [
                _StatChip(
                  icon: Icons.local_fire_department_rounded,
                  color: _amber,
                  label: streak > 0
                      ? '$streak day${streak == 1 ? '' : 's'}'
                      : '—',
                  tooltip: 'Logging streak',
                ),
                _StatChip(
                  icon: Icons.bedtime_rounded,
                  color: _purple,
                  label: avgSleep != null
                      ? '${avgSleep.toStringAsFixed(1)}h avg sleep'
                      : 'No sleep data',
                  tooltip: 'Average sleep (last 14 nights)',
                ),
                _StatChip(
                  icon: Icons.history_rounded,
                  color: _teal,
                  label:
                      lastLog != null ? _relativeDate(lastLog) : 'No logs',
                  tooltip: 'Last logged',
                ),
              ],
            ),
          ),

          Divider(
              color: Colors.white.withValues(alpha: 0.07), height: 1),

          // ── Actions ──────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (child.ageMode == AgeMode.littleOnes)
                  _ActionBtn(
                    label: 'Log',
                    icon: Icons.edit_note_rounded,
                    color: _purple,
                    onTap: () => _openLittleOnesLog(child),
                  )
                else
                  _ActionBtn(
                    label: 'Skeleton Key',
                    icon: Icons.key_rounded,
                    color: _amber,
                    onTap: () => _openSkeletonKey(child),
                  ),
                _ActionBtn(
                  label: 'Report',
                  icon: Icons.summarize_rounded,
                  color: _teal,
                  onTap: () => _openReport(child),
                ),
                _ActionBtn(
                  label: 'What helps',
                  icon: Icons.favorite_border_rounded,
                  color: _pink,
                  onTap: () => _openWhatHelps(child),
                ),
                _ActionBtn(
                  label: 'Meals',
                  icon: Icons.restaurant_rounded,
                  color: _amber,
                  onTap: () => _openMeals(child),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Actions ───────────────────────────────────────────────────

  Future<void> _createAccount() async {
    final account = FamilyAccount.create();
    await account.save();
    _refresh();
  }

  void _openLittleOnesLog(ChildProfile child) {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (_) => LittleOnesLogScreen(child: child)),
    );
  }

  void _openSkeletonKey(ChildProfile child) {
    if (_account?.passwordHash == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text(
            'Set a parent password first to use skeleton key access.'),
        behavior: SnackBarBehavior.floating,
      ));
      _showSetPassword();
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => SkeletonKeyScreen(child: child)),
    );
  }

  void _openWhatHelps(ChildProfile child) {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (_) => WhatHelpsScreen(child: child)),
    );
  }

  void _openMeals(ChildProfile child) {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (_) => RecipeScreen(child: child)),
    );
  }

  void _openReport(ChildProfile child) {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (_) => ReportGeneratorScreen(initialChild: child)),
    );
  }

  Future<void> _confirmRemoveChild(ChildProfile child) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF150D2E),
        title: Text(
          'Remove ${child.name}?',
          style: const TextStyle(color: Colors.white, fontFamily: 'DM Sans'),
        ),
        content: Text(
          'This will permanently delete all of ${child.name}\'s data. '
          'This cannot be undone.',
          style: TextStyle(color: Colors.white.withValues(alpha: 0.65)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: _pink),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      await StorageService.deleteChildBoxes(child.id);
      _account!.removeChild(child.id);
      await _account!.save();
      _refresh();
    }
  }

  void _showAccountSettings() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF150D2E),
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2)),
            ),
            const SizedBox(height: 16),
            const Text(
              'Account settings',
              style: TextStyle(
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.w700,
                fontFamily: 'DM Sans',
              ),
            ),
            const SizedBox(height: 8),
            ListTile(
              leading: const Icon(Icons.password_rounded, color: _purple),
              title: Text(
                _account?.passwordHash == null
                    ? 'Set parent password'
                    : 'Change parent password',
                style: const TextStyle(
                    color: Colors.white, fontFamily: 'DM Sans'),
              ),
              subtitle: Text(
                'Required for skeleton key emergency access',
                style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.40),
                    fontSize: 11),
              ),
              onTap: () {
                Navigator.pop(context);
                _showSetPassword();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showSetPassword() {
    final pwCtrl      = TextEditingController();
    final confirmCtrl = TextEditingController();
    bool obscure = true;
    String? err;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => AlertDialog(
          backgroundColor: const Color(0xFF150D2E),
          title: const Text(
            'Parent password',
            style: TextStyle(color: Colors.white, fontFamily: 'DM Sans'),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Unlocks emergency skeleton key access to your child\'s '
                'sleep, mood and health data.',
                style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.55),
                    fontSize: 12,
                    height: 1.5),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: pwCtrl,
                obscureText: obscure,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Password',
                  labelStyle: const TextStyle(color: Colors.white54),
                  enabledBorder: const OutlineInputBorder(
                      borderSide:
                          BorderSide(color: Color(0xFF2D2060))),
                  focusedBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: _purple)),
                  suffixIcon: IconButton(
                    icon: Icon(
                      obscure
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: Colors.white38,
                      size: 18,
                    ),
                    onPressed: () => setS(() => obscure = !obscure),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: confirmCtrl,
                obscureText: obscure,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Confirm password',
                  labelStyle: TextStyle(color: Colors.white54),
                  enabledBorder: OutlineInputBorder(
                      borderSide:
                          BorderSide(color: Color(0xFF2D2060))),
                  focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: _purple)),
                ),
              ),
              if (err != null) ...[
                const SizedBox(height: 8),
                Text(err!,
                    style: const TextStyle(
                        color: _pink, fontSize: 12)),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            TextButton(
              child: const Text('Save',
                  style: TextStyle(color: _purple)),
              onPressed: () async {
                if (pwCtrl.text.length < 6) {
                  setS(() => err =
                      'Password must be at least 6 characters.');
                  return;
                }
                if (pwCtrl.text != confirmCtrl.text) {
                  setS(() => err = 'Passwords don\'t match.');
                  return;
                }
                final account =
                    _account ?? FamilyAccount.create();
                account.setPassword(pwCtrl.text);
                await account.save();
                if (ctx.mounted) Navigator.pop(ctx);
                _refresh();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showAddChild() {
    final nameCtrl = TextEditingController();
    DateTime? dob;
    String? err;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF150D2E),
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => Padding(
          padding: EdgeInsets.fromLTRB(
            20,
            16,
            20,
            MediaQuery.of(ctx).viewInsets.bottom + 32,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(2)),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Add a child',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'DM Sans',
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: nameCtrl,
                style: const TextStyle(
                    color: Colors.white, fontFamily: 'DM Sans'),
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'Name',
                  labelStyle: TextStyle(color: Colors.white54),
                  enabledBorder: OutlineInputBorder(
                      borderSide:
                          BorderSide(color: Color(0xFF2D2060))),
                  focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: _purple)),
                ),
              ),
              const SizedBox(height: 14),
              GestureDetector(
                onTap: () async {
                  final picked = await showDatePicker(
                    context: ctx,
                    initialDate: DateTime.now()
                        .subtract(const Duration(days: 365 * 8)),
                    firstDate: DateTime(2010),
                    lastDate: DateTime.now(),
                    builder: (_, child) => Theme(
                      data: ThemeData.dark().copyWith(
                        colorScheme: const ColorScheme.dark(
                            primary: _purple),
                      ),
                      child: child!,
                    ),
                  );
                  if (picked != null) setS(() => dob = picked);
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 14),
                  decoration: BoxDecoration(
                    border: Border.all(
                        color: const Color(0xFF2D2060)),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.cake_outlined,
                          color: dob == null
                              ? Colors.white38
                              : _purple,
                          size: 18),
                      const SizedBox(width: 10),
                      Text(
                        dob == null
                            ? 'Date of birth'
                            : '${dob!.day}/${dob!.month}/${dob!.year}',
                        style: TextStyle(
                          color: dob == null
                              ? Colors.white54
                              : Colors.white,
                          fontFamily: 'DM Sans',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (err != null) ...[
                const SizedBox(height: 8),
                Text(err!,
                    style: const TextStyle(
                        color: _pink, fontSize: 12)),
              ],
              const SizedBox(height: 20),
              GestureDetector(
                onTap: () async {
                  if (nameCtrl.text.trim().isEmpty) {
                    setS(() => err = 'Please enter a name.');
                    return;
                  }
                  if (dob == null) {
                    setS(() =>
                        err = 'Please select a date of birth.');
                    return;
                  }
                  final child = ChildProfile(
                    id:   DateTime.now()
                        .millisecondsSinceEpoch
                        .toString(),
                    name: nameCtrl.text.trim(),
                    dob:  dob!,
                  );
                  final account = _account!;
                  account.addChild(child);
                  await account.save();
                  await StorageService.openChildBoxes(child.id);
                  if (ctx.mounted) Navigator.pop(ctx);
                  _refresh();
                },
                child: Container(
                  width: double.infinity,
                  height: 52,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                        colors: [
                          Color(0xFF6C63FF),
                          Color(0xFF00C9A7),
                        ]),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Center(
                    child: Text(
                      'Add child',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'DM Sans',
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Private helper widgets ────────────────────────────────────

class _EmptyChildrenView extends StatelessWidget {
  const _EmptyChildrenView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('🌱', style: TextStyle(fontSize: 48)),
          const SizedBox(height: 16),
          Text(
            'No children added yet.',
            style: TextStyle(
                color: Colors.white.withValues(alpha: 0.45), fontSize: 15),
          ),
          const SizedBox(height: 6),
          Text(
            'Tap "Add child" to get started.',
            style: TextStyle(
                color: Colors.white.withValues(alpha: 0.30), fontSize: 13),
          ),
        ],
      ),
    );
  }
}

class _PinChip extends StatelessWidget {
  final ChildProfile child;
  const _PinChip({required this.child});

  static const _purple = Color(0xFF6C63FF);

  @override
  Widget build(BuildContext context) {
    final hasPIN = child.pinEnabled;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: hasPIN
            ? _purple.withValues(alpha: 0.15)
            : Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: hasPIN
              ? _purple.withValues(alpha: 0.35)
              : Colors.white.withValues(alpha: 0.12),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            hasPIN ? Icons.lock_rounded : Icons.lock_open_rounded,
            color: hasPIN ? _purple : Colors.white38,
            size: 12,
          ),
          const SizedBox(width: 4),
          Text(
            hasPIN ? 'PIN set' : 'No PIN',
            style: TextStyle(
              color: hasPIN ? _purple : Colors.white38,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final String tooltip;
  const _StatChip({
    required this.icon,
    required this.color,
    required this.label,
    required this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withValues(alpha: 0.20)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 12),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                  color: color,
                  fontSize: 11,
                  fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionBtn extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _ActionBtn({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withValues(alpha: 0.30)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 14),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w600,
                fontFamily: 'DM Sans',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
