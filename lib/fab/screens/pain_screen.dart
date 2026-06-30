import 'package:flutter/material.dart';
import '../fab_theme.dart';
import '../services/fab_stars_service.dart';
import '../../core/models/check_in_entry.dart';
import '../../core/repositories/check_in_repository.dart';

// ─────────────────────────────────────────────────────────────
// PAIN SCREEN — child-friendly version
// Face scale replaces numeric slider.
// Simple body zones, kid-friendly symptoms, activity triggers.
// ─────────────────────────────────────────────────────────────

class PainScreen extends StatefulWidget {
  const PainScreen({super.key});
  @override
  State<PainScreen> createState() => _PainScreenState();
}

class _PainScreenState extends State<PainScreen> {
  final _repo    = CheckInRepository();
  final _noteCtrl = TextEditingController();

  // ── Face scale: index 0-4, maps to painRating 0,3,5,7,9 ──────
  static const _faces      = ['😊', '😐', '😕', '😢', '😭'];
  static const _faceLabels = ['No ouchies', 'A little bit', 'Some pain', 'Quite a lot', 'Really hurts'];
  static const _faceRatings = [0, 3, 5, 7, 9];
  int? _faceIndex;

  // ── Body zones ────────────────────────────────────────────────
  static const _zones = ['Head', 'Tummy', 'Back', 'Arm', 'Leg', 'Foot'];
  static const _zoneEmojis = ['🧠', '🫃', '🔙', '💪', '🦵', '🦶'];
  final Set<String> _locations = {};

  // ── Child-friendly symptoms ───────────────────────────────────
  static const _symptomOptions = ['Ouch', 'Burning', 'Achy', 'Stabby', 'Tight', 'Tired'];
  static const _symptomEmojis  = ['😣', '🔥', '😔', '⚡', '🪢', '😴'];
  final Set<String> _symptoms = {};

  // ── Activity triggers ─────────────────────────────────────────
  static const _activityOptions = ['Playing', 'Sitting', 'Sleeping', 'PE/Sports', 'Watching TV', 'Eating'];
  static const _activityEmojis  = ['🎮', '🪑', '😴', '⚽', '📺', '🍽️'];
  final Set<String> _triggers = {};

  bool _saving = false;
  List<CheckInEntry> _recent = [];

  @override
  void initState() {
    super.initState();
    _loadRecent();
  }

  @override
  void dispose() {
    _noteCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadRecent() async {
    final all = await _repo.getAllEntries();
    if (!mounted) return;
    // show only pain_ entries, not check-in stubs
    final pain = all.where((e) => e.id.startsWith('pain_')).toList()
      ..sort((a, b) => b.date.compareTo(a.date));
    setState(() => _recent = pain.take(5).toList());
  }

  Future<void> _save() async {
    if (_faceIndex == null) return;
    setState(() => _saving = true);
    await _repo.saveEntry(CheckInEntry(
      id:                 'pain_${DateTime.now().millisecondsSinceEpoch}',
      date:               DateTime.now(),
      painRating:         _faceRatings[_faceIndex!],
      nerveSymptomRating: 0,
      painLocations:      _locations.toList(),
      symptoms:           _symptoms.toList(),
      triggers:           _triggers.toList(),
      notes:              _noteCtrl.text.trim(),
    ));
    final award = await FabStarsService.awardForPainEntry();
    await _loadRecent();
    if (!mounted) return;
    setState(() {
      _saving    = false;
      _faceIndex = null;
      _locations.clear();
      _symptoms.clear();
      _triggers.clear();
      _noteCtrl.clear();
    });
    final msg = award.hasEarned ? award.snackMessage : 'Pain entry saved';
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: award.hasEarned ? const Color(0xFF2D1B5E) : FabColors.panel2,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      duration: const Duration(seconds: 3),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FabColors.bg,
      appBar: AppBar(
        backgroundColor: FabColors.mid,
        title: const Text('My Body',
            style: TextStyle(color: FabColors.pink, fontSize: 16)),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

          // ── Face scale ───────────────────────────────────────────
          _section(
            title: 'How much does it hurt?',
            child: _buildFaceScale(),
          ),

          const SizedBox(height: 12),

          // ── Body zones ───────────────────────────────────────────
          _section(
            title: 'Where does it hurt?',
            child: _buildZoneGrid(),
          ),

          const SizedBox(height: 12),

          // ── What does it feel like ───────────────────────────────
          _section(
            title: 'What does it feel like?',
            child: _buildEmojiChips(
              _symptomOptions,
              _symptomEmojis,
              _symptoms,
              FabColors.pink,
            ),
          ),

          const SizedBox(height: 12),

          // ── Activity triggers ────────────────────────────────────
          _section(
            title: 'What were you doing?',
            child: _buildEmojiChips(
              _activityOptions,
              _activityEmojis,
              _triggers,
              FabColors.teal,
            ),
          ),

          const SizedBox(height: 12),

          // ── Notes ────────────────────────────────────────────────
          _section(
            title: 'Anything else?',
            child: TextField(
              controller: _noteCtrl,
              maxLines: 3,
              style: const TextStyle(color: FabColors.text, fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Tell us anything else...',
                hintStyle: const TextStyle(color: FabColors.muted, fontSize: 13),
                filled: true,
                fillColor: FabColors.panel2,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          const SizedBox(height: 18),

          // ── Save button ──────────────────────────────────────────
          GestureDetector(
            onTap: (_saving || _faceIndex == null) ? null : _save,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: _faceIndex != null && !_saving
                    ? FabColors.rose
                    : FabColors.muted.withValues(alpha: 0.25),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(
                child: _saving
                    ? const SizedBox(
                        width: 20, height: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white))
                    : Text(
                        _faceIndex == null
                            ? 'Pick a face first 👆'
                            : 'Save my entry ⭐',
                        style: TextStyle(
                          color: _faceIndex != null
                              ? Colors.white
                              : FabColors.muted,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
          ),

          // ── Recent entries ───────────────────────────────────────
          if (_recent.isNotEmpty) ...[
            const SizedBox(height: 24),
            const Text('My recent entries',
                style: TextStyle(
                    fontSize: 13, color: FabColors.muted, letterSpacing: 1)),
            const SizedBox(height: 8),
            ..._recent.map((e) => _recentCard(e)),
          ],

          const SizedBox(height: 24),
        ]),
      ),
    );
  }

  // ── Face scale widget ─────────────────────────────────────────

  Widget _buildFaceScale() {
    return Column(children: [
      if (_faceIndex != null)
        Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: Text(
            _faceLabels[_faceIndex!],
            style: TextStyle(
              color: _faceColor(_faceIndex!),
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(_faces.length, (i) {
          final selected = _faceIndex == i;
          return GestureDetector(
            onTap: () => setState(() => _faceIndex = i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 58,
              height: 66,
              decoration: BoxDecoration(
                color: selected
                    ? _faceColor(i).withValues(alpha: 0.18)
                    : FabColors.panel2,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: selected ? _faceColor(i) : Colors.transparent,
                  width: 2,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _faces[i],
                    style: TextStyle(fontSize: selected ? 34 : 26),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    ]);
  }

  Color _faceColor(int i) {
    const colors = [
      Color(0xFF4CAF50),
      Color(0xFFFFEB3B),
      Color(0xFFFFB830),
      Color(0xFFFF7043),
      Color(0xFFFF1744),
    ];
    return colors[i.clamp(0, 4)];
  }

  // ── Body zone grid ────────────────────────────────────────────

  Widget _buildZoneGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _zones.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        mainAxisExtent: 76,
      ),
      itemBuilder: (_, i) {
        final zone = _zones[i];
        final on   = _locations.contains(zone);
        return GestureDetector(
          onTap: () => setState(() {
            if (on) { _locations.remove(zone); } else { _locations.add(zone); }
          }),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            decoration: BoxDecoration(
              color: on
                  ? FabColors.rose.withValues(alpha: 0.18)
                  : FabColors.panel2,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: on ? FabColors.rose : Colors.transparent,
                width: 1.5,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(_zoneEmojis[i], style: TextStyle(fontSize: on ? 28 : 24)),
                const SizedBox(height: 5),
                Text(
                  zone,
                  style: TextStyle(
                    color: on ? FabColors.rose : FabColors.muted,
                    fontSize: 13,
                    fontWeight: on ? FontWeight.w700 : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ── Emoji chip row ────────────────────────────────────────────

  Widget _buildEmojiChips(
    List<String> options,
    List<String> emojis,
    Set<String> selected,
    Color activeColor,
  ) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: List.generate(options.length, (i) {
        final opt = options[i];
        final on  = selected.contains(opt);
        return GestureDetector(
          onTap: () => setState(() {
            if (on) { selected.remove(opt); } else { selected.add(opt); }
          }),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: on
                  ? activeColor.withValues(alpha: 0.18)
                  : FabColors.panel2,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: on ? activeColor : Colors.transparent,
                width: 1.5,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(emojis[i], style: TextStyle(fontSize: on ? 17 : 14)),
                const SizedBox(width: 6),
                Text(
                  opt,
                  style: TextStyle(
                    color: on ? activeColor : FabColors.muted,
                    fontSize: 13,
                    fontWeight: on ? FontWeight.w700 : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  // ── Recent entry card ─────────────────────────────────────────

  Widget _recentCard(CheckInEntry e) {
    // map painRating back to nearest face
    final ratingToFace = {0: 0, 3: 1, 5: 2, 7: 3, 9: 4};
    final faceIdx = ratingToFace.entries
        .reduce((a, b) =>
            (a.key - e.painRating).abs() <= (b.key - e.painRating).abs() ? a : b)
        .value;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: FabColors.panel,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0x1EFF8FAB), width: 0.5),
      ),
      child: Row(children: [
        Text(_faces[faceIdx], style: const TextStyle(fontSize: 28)),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(_formatDate(e.date),
                style: const TextStyle(fontSize: 11, color: FabColors.muted)),
            if (e.painLocations.isNotEmpty)
              Text(e.painLocations.join(', '),
                  style: const TextStyle(fontSize: 13, color: FabColors.text),
                  overflow: TextOverflow.ellipsis),
            if (e.symptoms.isNotEmpty)
              Text(e.symptoms.join(' · '),
                  style: const TextStyle(fontSize: 11, color: FabColors.muted),
                  overflow: TextOverflow.ellipsis),
          ]),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: _faceColor(faceIdx).withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            _faceLabels[faceIdx],
            style: TextStyle(
              color: _faceColor(faceIdx),
              fontSize: 10,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ]),
    );
  }

  String _formatDate(DateTime d) {
    final now  = DateTime.now();
    final diff = now.difference(d).inDays;
    final hh   = d.hour.toString().padLeft(2, '0');
    final mm   = d.minute.toString().padLeft(2, '0');
    if (diff == 0) return 'Today $hh:$mm';
    if (diff == 1) return 'Yesterday $hh:$mm';
    return '${d.day}/${d.month} $hh:$mm';
  }

  Widget _section({required String title, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: FabColors.panel,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0x1EFF8FAB), width: 0.5),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title.toUpperCase(),
            style: const TextStyle(
                fontSize: 10, color: FabColors.pink, letterSpacing: 1.2)),
        const SizedBox(height: 10),
        child,
      ]),
    );
  }
}
