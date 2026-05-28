import 'package:flutter/material.dart';
import '../models/child_profile.dart';
import '../models/family_account.dart';
import '../services/audit_log_service.dart';
import '../services/storage_service.dart';

// ─────────────────────────────────────────────────────────────
// SkeletonKeyScreen
//
// Parent enters their account password to access restricted
// child data in an emergency. Two-step:
//   1. Select reason
//   2. Enter parent password
//
// On success:
//   - Shows a filtered view of the child's data (sleep, mood,
//     health only — journal and Safe Corner always blocked)
//   - Writes an AuditLogEntry
//   - Child sees a notification badge on their next open
//
// Journal and Safe Corner are never shown here. The UI does not
// even offer to show them — they are hard-blocked by design.
// ─────────────────────────────────────────────────────────────

class SkeletonKeyScreen extends StatefulWidget {
  final ChildProfile child;
  const SkeletonKeyScreen({super.key, required this.child});

  @override
  State<SkeletonKeyScreen> createState() => _SkeletonKeyScreenState();
}

class _SkeletonKeyScreenState extends State<SkeletonKeyScreen> {
  SkeletonReason? _reason;
  final _passwordCtrl = TextEditingController();
  bool _obscure       = true;
  bool _loading       = false;
  String? _errorMsg;
  bool _unlocked      = false;
  List<Map<String, dynamic>> _entries = [];

  static const _bg     = Color(0xFF0D0820);
  static const _purple = Color(0xFF6C63FF);
  static const _amber  = Color(0xFFFFB830);
  static const _pink   = Color(0xFFFF6B8A);
  static const _teal   = Color(0xFF00C9A7);

  @override
  void dispose() {
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _tryUnlock() async {
    if (_reason == null) {
      setState(() => _errorMsg = 'Please select a reason first.');
      return;
    }
    final account = FamilyAccount.current;
    if (account == null || !account.checkPassword(_passwordCtrl.text)) {
      setState(() => _errorMsg = 'Incorrect password. Try again.');
      return;
    }

    setState(() => _loading = true);

    // Load restricted data entries
    final entries = StorageService.skeletonKeyDataEntries(
      widget.child.id,
      allowedTypes: StorageService.skeletonKeyAllowedTypes,
    );

    // Write audit log entry
    await AuditLogService.record(AuditLogEntry(
      childId:        widget.child.id,
      timestamp:      DateTime.now(),
      reason:         _reason!,
      sectionsViewed: StorageService.skeletonKeyAllowedTypes,
    ));

    setState(() {
      _loading  = false;
      _unlocked = true;
      _entries  = entries;
      _errorMsg = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(
          _unlocked ? 'Parent Access' : 'Skeleton Key',
          style: const TextStyle(fontWeight: FontWeight.w700, fontFamily: 'DM Sans'),
        ),
      ),
      body: _unlocked ? _buildDataView() : _buildUnlockFlow(),
    );
  }

  // ── Unlock flow ──────────────────────────────────────────────

  Widget _buildUnlockFlow() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildWarningBanner(),
          const SizedBox(height: 24),
          _buildChildBadge(),
          const SizedBox(height: 24),
          _buildReasonPicker(),
          const SizedBox(height: 24),
          _buildPasswordField(),
          if (_errorMsg != null) ...[
            const SizedBox(height: 10),
            Text(_errorMsg!, style: const TextStyle(color: _pink, fontSize: 13)),
          ],
          const SizedBox(height: 24),
          _buildUnlockButton(),
          const SizedBox(height: 20),
          _buildPrivacyNote(),
        ],
      ),
    );
  }

  Widget _buildWarningBanner() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _amber.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _amber.withValues(alpha: 0.35)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('🔑', style: TextStyle(fontSize: 20)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Parent emergency access',
                  style: TextStyle(
                    color: _amber,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    fontFamily: 'DM Sans',
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'This access will be logged and '
                  '${widget.child.name} will be notified when they next open the app. '
                  'Journal and Safe Corner entries are never shown here.',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.65),
                    fontSize: 12,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChildBadge() {
    return Row(
      children: [
        Container(
          width: 48, height: 48,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _purple.withValues(alpha: 0.15),
            border: Border.all(color: _purple.withValues(alpha: 0.35)),
          ),
          child: const Center(child: Text('🔒', style: TextStyle(fontSize: 22))),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.child.name,
                style: const TextStyle(
                  color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
            Text(widget.child.ageMode.label,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.45), fontSize: 12)),
          ],
        ),
      ],
    );
  }

  Widget _buildReasonPicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Why do you need access?',
          style: TextStyle(
            color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700,
            fontFamily: 'DM Sans',
          ),
        ),
        const SizedBox(height: 12),
        ...SkeletonReason.values.map((r) {
          final selected = _reason == r;
          return GestureDetector(
            onTap: () => setState(() => _reason = r),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 160),
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: selected
                    ? _purple.withValues(alpha: 0.18)
                    : Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: selected
                      ? _purple.withValues(alpha: 0.60)
                      : Colors.white.withValues(alpha: 0.10),
                  width: selected ? 1.5 : 1,
                ),
              ),
              child: Row(
                children: [
                  Text(r.emoji, style: const TextStyle(fontSize: 18)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      r.label,
                      style: TextStyle(
                        color: selected ? Colors.white : Colors.white70,
                        fontSize: 14,
                        fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                        fontFamily: 'DM Sans',
                      ),
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

  Widget _buildPasswordField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Your parent password',
          style: TextStyle(
            color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700,
            fontFamily: 'DM Sans',
          ),
        ),
        const SizedBox(height: 10),
        TextField(
          controller:  _passwordCtrl,
          obscureText: _obscure,
          style: const TextStyle(color: Colors.white, fontFamily: 'DM Sans'),
          decoration: InputDecoration(
            hintText: 'Enter your password',
            hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.30)),
            filled: true,
            fillColor: Colors.white.withValues(alpha: 0.06),
            contentPadding: const EdgeInsets.symmetric(
                horizontal: 16, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Color(0xFF2D2060)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Color(0xFF2D2060)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: _purple),
            ),
            suffixIcon: IconButton(
              icon: Icon(
                _obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                color: Colors.white38, size: 20,
              ),
              onPressed: () => setState(() => _obscure = !_obscure),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUnlockButton() {
    return GestureDetector(
      onTap: _loading ? null : _tryUnlock,
      child: Container(
        width: double.infinity,
        height: 54,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF6C63FF), Color(0xFF00C9A7)],
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(
          child: _loading
              ? const SizedBox(
                  width: 22, height: 22,
                  child: CircularProgressIndicator(
                      color: Colors.white, strokeWidth: 2.5))
              : const Text(
                  'Request access',
                  style: TextStyle(
                    color: Colors.white, fontSize: 16,
                    fontWeight: FontWeight.w700, fontFamily: 'DM Sans',
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildPrivacyNote() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.lock_outline_rounded, color: _teal, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Journal and Safe Corner entries are always private to '
              '${widget.child.name} — they will never appear here.',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.50),
                fontSize: 12, height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Unlocked data view ───────────────────────────────────────

  Widget _buildDataView() {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildAccessBadge(),
                const SizedBox(height: 20),
                _buildJournalBlockNotice(),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
        if (_entries.isEmpty)
          SliverFillRemaining(
            child: Center(
              child: Text(
                'No sleep, mood or health entries yet.',
                style: TextStyle(color: Colors.white.withValues(alpha: 0.40),
                    fontSize: 14),
              ),
            ),
          )
        else
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (_, i) => _buildEntryTile(_entries[i]),
              childCount: _entries.length,
            ),
          ),
        const SliverToBoxAdapter(child: SizedBox(height: 40)),
      ],
    );
  }

  Widget _buildAccessBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: _teal.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _teal.withValues(alpha: 0.30)),
      ),
      child: Row(
        children: [
          const Icon(Icons.verified_rounded, color: _teal, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Viewing: ${widget.child.name} — sleep, mood & health only. '
              'Access logged. ${widget.child.name} will be notified.',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.75),
                fontSize: 12, height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildJournalBlockNotice() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: _pink.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _pink.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          const Text('🔒', style: TextStyle(fontSize: 16)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Journal and Safe Corner are private to ${widget.child.name} '
              'and are never shown here.',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.60),
                fontSize: 12, height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEntryTile(Map<String, dynamic> entry) {
    final type      = entry['type'] as String? ?? 'log';
    final timestamp = entry['timestamp'] as String? ?? '';
    final dt        = DateTime.tryParse(timestamp);
    final typeColor = type == 'sleep' ? _purple
        : type == 'mood'  ? _pink
        : _teal;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: typeColor.withValues(alpha: 0.20)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: typeColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              type.toUpperCase(),
              style: TextStyle(
                color: typeColor, fontSize: 10, fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              entry['summary'] as String? ?? '—',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.80),
                fontSize: 13,
              ),
            ),
          ),
          if (dt != null)
            Text(
              '${dt.day}/${dt.month}',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.35),
                fontSize: 11,
              ),
            ),
        ],
      ),
    );
  }
}
