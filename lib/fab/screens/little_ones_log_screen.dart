import 'package:flutter/material.dart';
import '../models/child_profile.dart';
import '../services/storage_service.dart';

// ─────────────────────────────────────────────────────────────
// LittleOnesLogScreen
//
// Parent observation log for children aged 0–4 (AgeMode.littleOnes).
// Four categories: Sleep · Sensory · Mood · Communication.
// Each has quick-tap observation chips — tap once to log immediately.
// All entries are timestamped and written to the child's data box.
//
// Entries are NOT shown via skeleton key (they are parent-entered,
// not child-entered, so the privacy rationale doesn't apply).
// ─────────────────────────────────────────────────────────────

class LittleOnesLogScreen extends StatefulWidget {
  final ChildProfile child;
  const LittleOnesLogScreen({super.key, required this.child});

  @override
  State<LittleOnesLogScreen> createState() => _LittleOnesLogScreenState();
}

class _LittleOnesLogScreenState extends State<LittleOnesLogScreen>
    with SingleTickerProviderStateMixin {

  static const _bg     = Color(0xFF0D0820);
  static const _card   = Color(0xFF120C28);

  static const _categories = [
    _LogCategory(
      id: 'sleep', label: 'Sleep', emoji: '🌙',
      color: Color(0xFF6C63FF),
      observations: [
        'Slept through',
        'Woke 1–2×',
        'Woke 3+ times',
        'Hard to settle',
        'Long nap',
        'Short nap',
        'Restless night',
      ],
    ),
    _LogCategory(
      id: 'sensory', label: 'Sensory', emoji: '✨',
      color: Color(0xFF00C9A7),
      observations: [
        'Sensitive to noise',
        'Sensitive to light',
        'Clothing bothered them',
        'Seeking sensory input',
        'Calm & regulated',
        'Overwhelmed',
        'Enjoyed textures',
      ],
    ),
    _LogCategory(
      id: 'mood', label: 'Mood', emoji: '💛',
      color: Color(0xFFFF6B8A),
      observations: [
        'Happy & settled',
        'Frustrated',
        'Tearful',
        'Excited',
        'Anxious',
        'Flat / withdrawn',
        'Content',
      ],
    ),
    _LogCategory(
      id: 'communication', label: 'Communication', emoji: '💬',
      color: Color(0xFFFFB830),
      observations: [
        'Used a new word',
        'Pointed & showed',
        'Made eye contact',
        'Used gestures',
        'Babbled lots',
        'Quiet day',
        'Responded to name',
      ],
    ),
  ];

  late TabController _tabCtrl;
  List<Map<String, dynamic>> _recent = [];
  String? _lastLogged;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: _categories.length, vsync: this);
    _loadRecent();
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  void _loadRecent() {
    List<Map<String, dynamic>> all;
    try {
      all = StorageService.allDataEntries(widget.child.id);
    } catch (_) {
      all = [];
    }
    final entries = all
        .where((e) => e['type'] == 'little_ones_log')
        .toList();
    entries.sort((a, b) {
      final ta = DateTime.tryParse(a['timestamp'] as String? ?? '') ??
          DateTime(0);
      final tb = DateTime.tryParse(b['timestamp'] as String? ?? '') ??
          DateTime(0);
      return tb.compareTo(ta);
    });
    setState(() => _recent = entries.take(20).toList());
  }

  Future<void> _log(String categoryId, String observation) async {
    final now = DateTime.now();
    final key = StorageService.entryKey();
    final cat = _categories.firstWhere((c) => c.id == categoryId);
    await StorageService.writeData(widget.child.id, key, {
      'type':        'little_ones_log',
      'category':    categoryId,
      'observation': observation,
      'timestamp':   now.toIso8601String(),
      'summary':     '${cat.label}: $observation',
    });
    setState(() => _lastLogged = observation);
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) setState(() => _lastLogged = null);
    _loadRecent();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Observation Log',
              style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontFamily: 'DM Sans',
                  fontSize: 17),
            ),
            Text(
              widget.child.name,
              style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.45),
                  fontSize: 12,
                  fontWeight: FontWeight.w400),
            ),
          ],
        ),
        bottom: TabBar(
          controller: _tabCtrl,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          indicatorColor: Colors.white,
          indicatorWeight: 2,
          labelStyle: const TextStyle(
              fontFamily: 'DM Sans', fontWeight: FontWeight.w600, fontSize: 13),
          unselectedLabelStyle: const TextStyle(
              fontFamily: 'DM Sans', fontWeight: FontWeight.w400, fontSize: 13),
          tabs: _categories
              .map((c) => Tab(text: '${c.emoji}  ${c.label}'))
              .toList(),
        ),
      ),
      body: Column(
        children: [
          // ── Success flash ────────────────────────────────────
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: _lastLogged != null
                ? _LoggedBanner(observation: _lastLogged!)
                : const SizedBox.shrink(),
          ),

          // ── Observation chips ─────────────────────────────────
          Expanded(
            child: TabBarView(
              controller: _tabCtrl,
              children: _categories.map((cat) {
                return SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: _buildObservationGrid(cat),
                );
              }).toList(),
            ),
          ),

          // ── Recent entries ───────────────────────────────────
          if (_recent.isNotEmpty) _buildRecentSection(),
        ],
      ),
    );
  }

  Widget _buildObservationGrid(_LogCategory cat) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tap to log ${cat.label.toLowerCase()} observation',
          style: TextStyle(
              color: Colors.white.withValues(alpha: 0.40), fontSize: 12),
        ),
        const SizedBox(height: 14),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: cat.observations.map((obs) {
            return _ObservationChip(
              label: obs,
              color: cat.color,
              onTap: () => _log(cat.id, obs),
            );
          }).toList(),
        ),
        const SizedBox(height: 12),
        _buildNoteButton(cat),
      ],
    );
  }

  Widget _buildNoteButton(_LogCategory cat) {
    return GestureDetector(
      onTap: () => _showFreeTextNote(cat),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(12),
          border:
              Border.all(color: Colors.white.withValues(alpha: 0.10)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.edit_note_rounded,
                color: Colors.white.withValues(alpha: 0.40), size: 18),
            const SizedBox(width: 8),
            Text(
              'Add a free note…',
              style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.40),
                  fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }

  void _showFreeTextNote(_LogCategory cat) {
    final ctrl = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF150D2E),
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(
            20, 16, 20, MediaQuery.of(ctx).viewInsets.bottom + 24),
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
                      borderRadius: BorderRadius.circular(2))),
            ),
            const SizedBox(height: 16),
            Text(
              '${cat.emoji} ${cat.label} note',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w700,
                fontFamily: 'DM Sans',
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: ctrl,
              autofocus: true,
              maxLines: 3,
              style: const TextStyle(color: Colors.white, fontFamily: 'DM Sans'),
              decoration: InputDecoration(
                hintText: 'What did you notice?',
                hintStyle: TextStyle(
                    color: Colors.white.withValues(alpha: 0.30)),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        const BorderSide(color: Color(0xFF2D2060))),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        BorderSide(color: cat.color)),
                filled: true,
                fillColor: Colors.white.withValues(alpha: 0.04),
              ),
            ),
            const SizedBox(height: 14),
            GestureDetector(
              onTap: () async {
                final text = ctrl.text.trim();
                if (text.isEmpty) return;
                Navigator.pop(ctx);
                await _log(cat.id, text);
              },
              child: Container(
                width: double.infinity,
                height: 48,
                decoration: BoxDecoration(
                  color: cat.color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: cat.color.withValues(alpha: 0.40)),
                ),
                child: Center(
                  child: Text(
                    'Log note',
                    style: TextStyle(
                      color: cat.color,
                      fontSize: 15,
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
    );
  }

  Widget _buildRecentSection() {
    return Container(
      constraints: const BoxConstraints(maxHeight: 220),
      decoration: BoxDecoration(
        color: _card,
        border: Border(
            top: BorderSide(
                color: Colors.white.withValues(alpha: 0.07))),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
            child: Text(
              'Recent observations',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.45),
                fontSize: 11,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
          ),
          Flexible(
            child: ListView.builder(
              padding:
                  const EdgeInsets.fromLTRB(12, 0, 12, 8),
              itemCount: _recent.length,
              itemBuilder: (_, i) => _buildRecentTile(_recent[i]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentTile(Map<String, dynamic> entry) {
    final catId  = entry['category'] as String? ?? '';
    final obs    = entry['observation'] as String? ?? '—';
    final tsStr  = entry['timestamp'] as String? ?? '';
    final dt     = DateTime.tryParse(tsStr);

    final cat = _categories.cast<_LogCategory?>().firstWhere(
        (c) => c?.id == catId,
        orElse: () => null);

    final color = cat?.color ?? Colors.white54;
    final emoji = cat?.emoji ?? '📝';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 14)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              obs,
              style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.75),
                  fontSize: 13),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              cat?.label ?? catId,
              style: TextStyle(
                  color: color,
                  fontSize: 10,
                  fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(width: 8),
          if (dt != null)
            Text(
              _formatTime(dt),
              style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.30),
                  fontSize: 11),
            ),
        ],
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final now  = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m ago';
    }
    if (diff.inHours < 24) {
      return '${diff.inHours}h ago';
    }
    return '${dt.day}/${dt.month}';
  }
}

// ── Logged flash banner ───────────────────────────────────────

class _LoggedBanner extends StatelessWidget {
  final String observation;
  const _LoggedBanner({required this.observation});

  @override
  Widget build(BuildContext context) {
    return Container(
      key: ValueKey(observation),
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      color: const Color(0xFF00C9A7).withValues(alpha: 0.12),
      child: Row(
        children: [
          const Icon(Icons.check_circle_rounded,
              color: Color(0xFF00C9A7), size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Logged: $observation',
              style: const TextStyle(
                  color: Color(0xFF00C9A7),
                  fontSize: 13,
                  fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Observation chip ──────────────────────────────────────────

class _ObservationChip extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _ObservationChip({
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
            horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.30)),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.85),
            fontSize: 13,
            fontFamily: 'DM Sans',
          ),
        ),
      ),
    );
  }
}

// ── Data model ────────────────────────────────────────────────

class _LogCategory {
  final String id;
  final String label;
  final String emoji;
  final Color color;
  final List<String> observations;

  const _LogCategory({
    required this.id,
    required this.label,
    required this.emoji,
    required this.color,
    required this.observations,
  });
}
