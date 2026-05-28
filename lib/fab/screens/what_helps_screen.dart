import 'package:flutter/material.dart';
import '../models/child_profile.dart';
import '../services/storage_service.dart';

// ─────────────────────────────────────────────────────────────
// WhatHelpsScreen
//
// Child-facing coping profile. Three sections:
//   • Sensory helpers  — things that help regulate input
//   • What makes things harder — triggers to be aware of
//   • Calming things   — what helps when overwhelmed
//
// Pre-set chips are toggleable. Children can also add their own.
// Profile is stored in the child's data box under key 'what_helps'
// and feeds into the PDF report generator.
// ─────────────────────────────────────────────────────────────

class WhatHelpsScreen extends StatefulWidget {
  final ChildProfile child;
  const WhatHelpsScreen({super.key, required this.child});

  @override
  State<WhatHelpsScreen> createState() => _WhatHelpsScreenState();
}

class _WhatHelpsScreenState extends State<WhatHelpsScreen> {
  static const _bg     = Color(0xFF0D0820);
  static const _purple = Color(0xFF6C63FF);
  static const _amber  = Color(0xFFFFB830);
  static const _teal   = Color(0xFF00C9A7);
  static const _pink   = Color(0xFFFF6B8A);

  static const _presetSensory = [
    '🎧 Headphones', '🌟 Fidget toy', '💡 Dimmer lights',
    '🌿 Nature sounds', '🫂 Deep pressure / weighted blanket',
    '🧸 Comfort object', '🕶️ Sunglasses', '🎵 Music',
    '🫧 Bubble wrap', '🧤 Textured gloves',
  ];
  static const _presetTriggers = [
    '📢 Loud noises', '👥 Crowds or groups',
    '🔄 Changes to routine', '⏰ Being rushed',
    '🍽️ Certain food textures', '💡 Bright lights',
    '💬 Too many instructions', '🌡️ Being too hot or cold',
    '👕 Scratchy clothing', '😴 Being overtired',
  ];
  static const _presetCalming = [
    '🎵 Music', '🚶 Walking or moving', '🌬️ Deep breaths',
    '🎨 Drawing or colouring', '📚 Reading',
    '🐾 Animals or pets', '💧 Water (shower, rain, pool)',
    '🧩 Puzzles or LEGO', '🌿 Being outside', '🧘 Quiet space',
  ];
  static const _presetTransition = [
    '🎒 Familiar object in my bag', '🗺️ Same route to school each day',
    '🌿 Quiet time after school', '🎧 Sensory kit in my bag',
    '💬 Trusted adult to talk to', '📅 A visual timetable',
    '🏫 Visiting the new school first', '🌟 A comforting routine',
  ];

  Set<String> _sensory     = {};
  Set<String> _triggers    = {};
  Set<String> _calming     = {};
  Set<String> _transition  = {};
  List<String> _customSensory     = [];
  List<String> _customTriggers    = [];
  List<String> _customCalming     = [];
  List<String> _customTransition  = [];

  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    try {
      final data = StorageService.readData(widget.child.id, 'what_helps');
      if (data != null) {
        _sensory    = Set<String>.from(data['sensory']    as List? ?? []);
        _triggers   = Set<String>.from(data['triggers']   as List? ?? []);
        _calming    = Set<String>.from(data['calming']    as List? ?? []);
        _transition = Set<String>.from(data['transition'] as List? ?? []);
        _customSensory     = List<String>.from(data['customSensory']     as List? ?? []);
        _customTriggers    = List<String>.from(data['customTriggers']    as List? ?? []);
        _customCalming     = List<String>.from(data['customCalming']     as List? ?? []);
        _customTransition  = List<String>.from(data['customTransition']  as List? ?? []);
      }
    } catch (_) {}
    setState(() => _loaded = true);
  }

  Future<void> _save() async {
    await StorageService.writeData(widget.child.id, 'what_helps', {
      'type':             'what_helps',
      'sensory':          _sensory.toList(),
      'triggers':         _triggers.toList(),
      'calming':          _calming.toList(),
      'transition':       _transition.toList(),
      'customSensory':    _customSensory,
      'customTriggers':   _customTriggers,
      'customCalming':    _customCalming,
      'customTransition': _customTransition,
      'timestamp':        DateTime.now().toIso8601String(),
    });
  }

  void _toggle(Set<String> set, String item) {
    setState(() {
      set.contains(item) ? set.remove(item) : set.add(item);
    });
    _save();
  }

  void _addCustom(List<String> list, String item) {
    setState(() => list.add(item));
    _save();
  }

  void _removeCustom(List<String> list, String item) {
    setState(() => list.remove(item));
    _save();
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
              'What helps me',
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
      ),
      body: _loaded
          ? SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 40),
              child: Column(
                children: [
                  _buildIntroCard(),
                  const SizedBox(height: 20),
                  _buildSection(
                    title: 'Sensory helpers',
                    subtitle: 'Things that help you feel more comfortable',
                    emoji: '✨',
                    color: _teal,
                    presets: _presetSensory,
                    selected: _sensory,
                    custom: _customSensory,
                  ),
                  const SizedBox(height: 16),
                  _buildSection(
                    title: 'What makes things harder',
                    subtitle: 'Things that can be tricky for you',
                    emoji: '⚡',
                    color: _amber,
                    presets: _presetTriggers,
                    selected: _triggers,
                    custom: _customTriggers,
                  ),
                  const SizedBox(height: 16),
                  _buildSection(
                    title: 'Calming things',
                    subtitle: 'Things that help when you feel overwhelmed',
                    emoji: '🌸',
                    color: _purple,
                    presets: _presetCalming,
                    selected: _calming,
                    custom: _customCalming,
                  ),
                  const SizedBox(height: 16),
                  _buildSection(
                    title: 'School transition',
                    subtitle: 'Things that help with big changes at school',
                    emoji: '🏫',
                    color: _pink,
                    presets: _presetTransition,
                    selected: _transition,
                    custom: _customTransition,
                  ),
                  if (_hasSelections) ...[
                    const SizedBox(height: 24),
                    _buildSummaryCard(),
                  ],
                ],
              ),
            )
          : const Center(
              child: CircularProgressIndicator(color: _purple),
            ),
    );
  }

  bool get _hasSelections =>
      _sensory.isNotEmpty ||
      _triggers.isNotEmpty ||
      _calming.isNotEmpty ||
      _transition.isNotEmpty ||
      _customSensory.isNotEmpty ||
      _customTriggers.isNotEmpty ||
      _customCalming.isNotEmpty ||
      _customTransition.isNotEmpty;

  Widget _buildIntroCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _purple.withValues(alpha: 0.15),
            _teal.withValues(alpha: 0.08),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _purple.withValues(alpha: 0.25)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('💜', style: TextStyle(fontSize: 22)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Your coping profile — just for you. Tap the things that feel right. '
              'You can share this with people who support you.',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.70),
                fontSize: 13,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required String subtitle,
    required String emoji,
    required Color color,
    required List<String> presets,
    required Set<String> selected,
    required List<String> custom,
  }) {
    final allItems = [...presets, ...custom];
    final chosenCount = selected.length +
        custom.where((c) => selected.contains(c)).length;

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF120C28),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: selected.isNotEmpty || custom.isNotEmpty
              ? color.withValues(alpha: 0.25)
              : Colors.white.withValues(alpha: 0.07),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ──────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 4),
            child: Row(
              children: [
                Text(emoji, style: const TextStyle(fontSize: 22)),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          color: color,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'DM Sans',
                        ),
                      ),
                      Text(
                        subtitle,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.40),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                if (chosenCount > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '$chosenCount selected',
                      style: TextStyle(
                          color: color,
                          fontSize: 10,
                          fontWeight: FontWeight.w600),
                    ),
                  ),
              ],
            ),
          ),

          // ── Chips ────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ...allItems.map((item) {
                  final isCustom  = custom.contains(item);
                  final isChosen  = selected.contains(item);
                  return GestureDetector(
                    onTap:      () => _toggle(selected, item),
                    onLongPress: isCustom
                        ? () => _confirmRemoveCustom(custom, item)
                        : null,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 140),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 7),
                      decoration: BoxDecoration(
                        color: isChosen
                            ? color.withValues(alpha: 0.18)
                            : Colors.white.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isChosen
                              ? color.withValues(alpha: 0.55)
                              : Colors.white.withValues(alpha: 0.10),
                          width: isChosen ? 1.5 : 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            item,
                            style: TextStyle(
                              color: isChosen
                                  ? Colors.white
                                  : Colors.white60,
                              fontSize: 13,
                              fontFamily: 'DM Sans',
                            ),
                          ),
                          if (isChosen) ...[
                            const SizedBox(width: 4),
                            Icon(Icons.check_rounded,
                                color: color, size: 14),
                          ],
                        ],
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),

          // ── Add own ──────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
            child: TextButton.icon(
              onPressed: () =>
                  _showAddCustom(title, color, custom, selected),
              icon: Icon(Icons.add_rounded, color: color, size: 18),
              label: Text(
                'Add my own',
                style: TextStyle(
                    color: color,
                    fontFamily: 'DM Sans',
                    fontSize: 13),
              ),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 6),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddCustom(
    String sectionTitle,
    Color color,
    List<String> list,
    Set<String> selected,
  ) {
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
            const SizedBox(height: 14),
            Text(
              'Add to "$sectionTitle"',
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
              textCapitalization: TextCapitalization.sentences,
              style: const TextStyle(
                  color: Colors.white, fontFamily: 'DM Sans'),
              decoration: InputDecoration(
                hintText: 'Write your own thing…',
                hintStyle: TextStyle(
                    color: Colors.white.withValues(alpha: 0.30)),
                filled: true,
                fillColor: Colors.white.withValues(alpha: 0.05),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        const BorderSide(color: Color(0xFF2D2060))),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: color)),
              ),
            ),
            const SizedBox(height: 14),
            GestureDetector(
              onTap: () {
                final text = ctrl.text.trim();
                if (text.isEmpty) return;
                Navigator.pop(ctx);
                _addCustom(list, text);
                setState(() => selected.add(text));
                _save();
              },
              child: Container(
                width: double.infinity,
                height: 48,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                  border:
                      Border.all(color: color.withValues(alpha: 0.40)),
                ),
                child: Center(
                  child: Text(
                    'Add',
                    style: TextStyle(
                      color: color,
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

  Future<void> _confirmRemoveCustom(List<String> list, String item) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF150D2E),
        title: const Text('Remove item?',
            style: TextStyle(color: Colors.white, fontFamily: 'DM Sans')),
        content: Text(
          '"$item" will be removed from your list.',
          style: TextStyle(color: Colors.white.withValues(alpha: 0.65)),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel')),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              style: TextButton.styleFrom(foregroundColor: _pink),
              child: const Text('Remove')),
        ],
      ),
    );
    if (confirmed == true) _removeCustom(list, item);
  }

  Widget _buildSummaryCard() {
    int total = _sensory.length + _triggers.length + _calming.length + _transition.length;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _teal.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _teal.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          const Icon(Icons.check_circle_outline_rounded,
              color: _teal, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              '$total thing${total == 1 ? '' : 's'} selected across your coping profile. '
              'This will be included in any reports you share.',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.65),
                fontSize: 12,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
