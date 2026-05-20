import 'package:flutter/material.dart';
import '../fab_theme.dart';
import '../../core/models/check_in_entry.dart';
import '../../core/repositories/check_in_repository.dart';

class PainScreen extends StatefulWidget {
  const PainScreen({super.key});
  @override
  State<PainScreen> createState() => _PainScreenState();
}

class _PainScreenState extends State<PainScreen> {
  final _repo = CheckInRepository();

  int _painLevel = 0;
  int _nerveLevel = 0;
  final List<String> _locations = [];
  final List<String> _symptoms = [];
  final List<String> _triggers = [];
  final _noteCtrl = TextEditingController();

  bool _saving = false;
  List<CheckInEntry> _recent = [];

  @override
  void initState() {
    super.initState();
    _loadRecent();
  }

  Future<void> _loadRecent() async {
    final all = await _repo.getAllEntries();
    if (!mounted) return;
    setState(() => _recent = all.reversed.take(5).toList());
  }

  Color _painColor(int level) {
    if (level == 0) return FabColors.muted;
    if (level <= 3) return FabColors.teal;
    if (level <= 6) return FabColors.gold;
    if (level <= 8) return FabColors.rose;
    return const Color(0xFFFF1744);
  }

  String _painLabel(int level) {
    if (level == 0) return 'None';
    if (level <= 2) return 'Mild';
    if (level <= 4) return 'Moderate';
    if (level <= 6) return 'Significant';
    if (level <= 8) return 'Severe';
    return 'Extreme';
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    final entry = CheckInEntry(
      id: 'pain_${DateTime.now().millisecondsSinceEpoch}',
      date: DateTime.now(),
      painRating: _painLevel,
      nerveSymptomRating: _nerveLevel,
      painLocations: List.from(_locations),
      symptoms: List.from(_symptoms),
      triggers: List.from(_triggers),
      notes: _noteCtrl.text.trim(),
    );
    await _repo.saveEntry(entry);
    await _loadRecent();
    if (!mounted) return;
    setState(() {
      _saving = false;
      _painLevel = 0;
      _nerveLevel = 0;
      _locations.clear();
      _symptoms.clear();
      _triggers.clear();
      _noteCtrl.clear();
    });
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: const Text('Pain entry saved'),
      backgroundColor: FabColors.panel2,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FabColors.bg,
      appBar: AppBar(
        backgroundColor: FabColors.mid,
        title: const Text('Pain Log',
            style: TextStyle(color: FabColors.pink, fontSize: 16)),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

          // ── Pain level ──────────────────────────────────────────
          _section(
            title: 'Pain Level Right Now',
            child: _ratingSlider(_painLevel, _painColor, _painLabel,
                (v) => setState(() => _painLevel = v)),
          ),

          const SizedBox(height: 12),

          // ── Nerve symptom level ─────────────────────────────────
          _section(
            title: 'Nerve Symptoms',
            child: _ratingSlider(_nerveLevel, _nerveColor, _nerveLabel,
                (v) => setState(() => _nerveLevel = v)),
          ),

          const SizedBox(height: 12),

          // ── Body location ───────────────────────────────────────
          _section(
            title: 'Where does it hurt?',
            child: _chips(
              items: CheckInEntry.generalLocations,
              selected: _locations,
              activeColor: FabColors.rose,
              onTap: (p) => setState(() =>
                  _locations.contains(p) ? _locations.remove(p) : _locations.add(p)),
            ),
          ),

          const SizedBox(height: 12),

          // ── Symptoms ────────────────────────────────────────────
          _section(
            title: 'What does it feel like?',
            child: _chips(
              items: CheckInEntry.knownSymptoms,
              selected: _symptoms,
              activeColor: FabColors.pink,
              onTap: (s) => setState(() =>
                  _symptoms.contains(s) ? _symptoms.remove(s) : _symptoms.add(s)),
            ),
          ),

          const SizedBox(height: 12),

          // ── Triggers ────────────────────────────────────────────
          _section(
            title: 'What triggered it?',
            child: _chips(
              items: CheckInEntry.knownTriggers,
              selected: _triggers,
              activeColor: FabColors.teal,
              onTap: (t) => setState(() =>
                  _triggers.contains(t) ? _triggers.remove(t) : _triggers.add(t)),
            ),
          ),

          const SizedBox(height: 12),

          // ── Notes ───────────────────────────────────────────────
          _section(
            title: 'Notes',
            child: TextField(
              controller: _noteCtrl,
              maxLines: 3,
              style: const TextStyle(color: FabColors.text, fontSize: 13),
              decoration: InputDecoration(
                hintText: 'Any other details...',
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

          const SizedBox(height: 16),

          // ── Save button ─────────────────────────────────────────
          GestureDetector(
            onTap: _saving ? null : _save,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: _saving ? FabColors.muted : FabColors.rose,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(child: _saving
                  ? const SizedBox(width: 18, height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Text('Log pain entry',
                      style: TextStyle(color: Colors.white, fontSize: 15,
                          fontWeight: FontWeight.w500))),
            ),
          ),

          // ── Recent persisted entries ────────────────────────────
          if (_recent.isNotEmpty) ...[
            const SizedBox(height: 20),
            const Text('Recent entries',
                style: TextStyle(
                    fontSize: 13, color: FabColors.muted, letterSpacing: 1)),
            const SizedBox(height: 8),
            ..._recent.map((e) => Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: FabColors.panel,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                    color: const Color(0x1EFF8FAB), width: 0.5),
              ),
              child: Row(children: [
                _ratingBadge(e.painRating),
                const SizedBox(width: 10),
                Expanded(child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Text(_formatDate(e.date),
                      style: const TextStyle(
                          fontSize: 11, color: FabColors.muted)),
                  if (e.painLocations.isNotEmpty)
                    Text(e.painLocations.join(', '),
                        style: const TextStyle(
                            fontSize: 12, color: FabColors.text)),
                  if (e.symptoms.isNotEmpty)
                    Text(e.symptoms.join(' · '),
                        style: const TextStyle(
                            fontSize: 11, color: FabColors.muted)),
                ])),
                if (e.nerveSymptomRating > 0) ...[
                  const SizedBox(width: 8),
                  _ratingBadge(e.nerveSymptomRating,
                      color: const Color(0xFF7C4DFF)),
                ],
              ]),
            )),
          ],
        ]),
      ),
    );
  }

  // ── Helpers ─────────────────────────────────────────────────────────────

  Widget _ratingSlider(
    int value,
    Color Function(int) colorFn,
    String Function(int) labelFn,
    ValueChanged<int> onChanged,
  ) {
    return Column(children: [
      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        Text('$value',
            style: TextStyle(
                fontSize: 64,
                fontWeight: FontWeight.w700,
                color: colorFn(value))),
        const SizedBox(width: 12),
        Text(labelFn(value),
            style: TextStyle(fontSize: 18, color: colorFn(value))),
      ]),
      Slider(
        value: value.toDouble(),
        min: 0, max: 10, divisions: 10,
        activeColor: colorFn(value),
        inactiveColor: FabColors.panel2,
        onChanged: (v) => onChanged(v.round()),
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(11, (i) => Text('$i',
            style: TextStyle(
                fontSize: 10,
                color: i == value ? colorFn(i) : FabColors.muted,
                fontWeight: i == value
                    ? FontWeight.w700
                    : FontWeight.normal))),
      ),
    ]);
  }

  Widget _chips({
    required List<String> items,
    required List<String> selected,
    required Color activeColor,
    required ValueChanged<String> onTap,
  }) {
    return Wrap(
      spacing: 8, runSpacing: 8,
      children: items.map((item) {
        final sel = selected.contains(item);
        return GestureDetector(
          onTap: () => onTap(item),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: sel
                  ? activeColor.withValues(alpha: 0.2)
                  : FabColors.panel2,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: sel ? activeColor : const Color(0x1AFF8FAB),
                width: sel ? 1 : 0.5,
              ),
            ),
            child: Text(item,
                style: TextStyle(
                    fontSize: 12,
                    color: sel ? activeColor : FabColors.muted)),
          ),
        );
      }).toList(),
    );
  }

  Widget _ratingBadge(int level, {Color? color}) {
    final c = color ?? _painColor(level);
    return Container(
      width: 36, height: 36,
      decoration: BoxDecoration(
          color: c.withValues(alpha: 0.15), shape: BoxShape.circle),
      child: Center(child: Text('$level',
          style: TextStyle(
              fontSize: 15, fontWeight: FontWeight.w700, color: c))),
    );
  }

  Color _nerveColor(int level) {
    if (level == 0) return FabColors.muted;
    if (level <= 3) return const Color(0xFF64B5F6);
    if (level <= 6) return const Color(0xFF7C4DFF);
    if (level <= 8) return const Color(0xFFAB47BC);
    return const Color(0xFFE040FB);
  }

  String _nerveLabel(int level) {
    if (level == 0) return 'None';
    if (level <= 2) return 'Mild';
    if (level <= 4) return 'Noticeable';
    if (level <= 6) return 'Significant';
    if (level <= 8) return 'Severe';
    return 'Extreme';
  }

  String _formatDate(DateTime d) {
    final now = DateTime.now();
    final diff = now.difference(d).inDays;
    final hh = d.hour.toString().padLeft(2, '0');
    final mm = d.minute.toString().padLeft(2, '0');
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

  @override
  void dispose() {
    _noteCtrl.dispose();
    super.dispose();
  }
}
