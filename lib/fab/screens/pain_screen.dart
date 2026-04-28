import 'package:flutter/material.dart';
import '../fab_theme.dart';

class PainScreen extends StatefulWidget {
  const PainScreen({super.key});
  @override
  State<PainScreen> createState() => _PainScreenState();
}

class _PainScreenState extends State<PainScreen> {
  int _painLevel = 0;
  final List<String> _locations = [];
  final List<String> _symptoms = [];
  String? _medication;
  final _noteCtrl = TextEditingController();
  final List<Map<String, dynamic>> _log = [];

  static const _bodyParts = [
    'Head', 'Neck', 'Shoulders', 'Chest', 'Back',
    'Arms', 'Hands', 'Stomach', 'Hips', 'Legs', 'Feet',
  ];

  static const _symptomList = [
    'Throbbing', 'Burning', 'Sharp', 'Dull ache',
    'Tightness', 'Numbness', 'Tingling', 'Pressure',
  ];

  static const _meds = [
    'None taken', 'Paracetamol', 'Ibuprofen', 'Codeine',
    'Tramadol', 'Morphine', 'Amitriptyline', 'Gabapentin', 'Other',
  ];

  Color _painColor(int level) {
    if (level == 0) return FabColors.muted;
    if (level <= 3) return FabColors.teal;
    if (level <= 6) return FabColors.gold;
    if (level <= 8) return FabColors.rose;
    return const Color(0xFFFF1744);
  }

  String _painLabel(int level) {
    if (level == 0) return 'No pain';
    if (level <= 2) return 'Mild';
    if (level <= 4) return 'Moderate';
    if (level <= 6) return 'Significant';
    if (level <= 8) return 'Severe';
    return 'Extreme';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FabColors.bg,
      appBar: AppBar(
        backgroundColor: FabColors.mid,
        title: const Text('Pain Log', style: TextStyle(color: FabColors.pink, fontSize: 16)),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

          // Pain scale
          _section(
            title: 'Pain Level Right Now',
            child: Column(children: [
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Text(
                  '$_painLevel',
                  style: TextStyle(
                    fontSize: 64, fontWeight: FontWeight.w700,
                    color: _painColor(_painLevel),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  _painLabel(_painLevel),
                  style: TextStyle(fontSize: 18, color: _painColor(_painLevel)),
                ),
              ]),
              Slider(
                value: _painLevel.toDouble(),
                min: 0, max: 10, divisions: 10,
                activeColor: _painColor(_painLevel),
                inactiveColor: FabColors.panel2,
                onChanged: (v) => setState(() => _painLevel = v.round()),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(11, (i) => Text(
                  '$i',
                  style: TextStyle(
                    fontSize: 10,
                    color: i == _painLevel ? _painColor(i) : FabColors.muted,
                    fontWeight: i == _painLevel ? FontWeight.w700 : FontWeight.normal,
                  ),
                )),
              ),
            ]),
          ),

          const SizedBox(height: 12),

          // Body location
          _section(
            title: 'Where does it hurt?',
            child: Wrap(
              spacing: 8, runSpacing: 8,
              children: _bodyParts.map((p) {
                final sel = _locations.contains(p);
                return GestureDetector(
                  onTap: () => setState(() =>
                    sel ? _locations.remove(p) : _locations.add(p)),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: sel ? FabColors.rose.withValues(alpha: 0.2) : FabColors.panel2,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: sel ? FabColors.rose : const Color(0x1AFF8FAB),
                        width: sel ? 1 : 0.5,
                      ),
                    ),
                    child: Text(p, style: TextStyle(
                      fontSize: 12,
                      color: sel ? FabColors.rose : FabColors.muted,
                    )),
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 12),

          // Symptom type
          _section(
            title: 'What does it feel like?',
            child: Wrap(
              spacing: 8, runSpacing: 8,
              children: _symptomList.map((s) {
                final sel = _symptoms.contains(s);
                return GestureDetector(
                  onTap: () => setState(() =>
                    sel ? _symptoms.remove(s) : _symptoms.add(s)),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: sel ? FabColors.pink.withValues(alpha: 0.2) : FabColors.panel2,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: sel ? FabColors.pink : const Color(0x1AFF8FAB),
                        width: sel ? 1 : 0.5,
                      ),
                    ),
                    child: Text(s, style: TextStyle(
                      fontSize: 12,
                      color: sel ? FabColors.pink : FabColors.muted,
                    )),
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 12),

          // Medication
          _section(
            title: 'Medication taken',
            child: Wrap(
              spacing: 8, runSpacing: 8,
              children: _meds.map((m) {
                final sel = _medication == m;
                return GestureDetector(
                  onTap: () => setState(() => _medication = m),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: sel ? FabColors.teal.withValues(alpha: 0.2) : FabColors.panel2,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: sel ? FabColors.teal : const Color(0x1AFF8FAB),
                        width: sel ? 1 : 0.5,
                      ),
                    ),
                    child: Text(m, style: TextStyle(
                      fontSize: 12,
                      color: sel ? FabColors.teal : FabColors.muted,
                    )),
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 12),

          // Notes
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

          // Log button
          GestureDetector(
            onTap: () {
              setState(() {
                _log.insert(0, {
                  'time': DateTime.now(),
                  'level': _painLevel,
                  'locations': List.from(_locations),
                  'symptoms': List.from(_symptoms),
                  'medication': _medication,
                  'note': _noteCtrl.text,
                });
              });
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: const Text('Pain entry logged ✓'),
                backgroundColor: FabColors.panel2,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ));
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: FabColors.rose,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(child: Text('Log pain entry',
                style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w500))),
            ),
          ),

          // Recent log
          if (_log.isNotEmpty) ...[
            const SizedBox(height: 20),
            const Text('Recent entries',
              style: TextStyle(fontSize: 13, color: FabColors.muted, letterSpacing: 1)),
            const SizedBox(height: 8),
            ..._log.take(5).map((e) => Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: FabColors.panel,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0x1EFF8FAB), width: 0.5),
              ),
              child: Row(children: [
                Container(
                  width: 36, height: 36,
                  decoration: BoxDecoration(
                    color: _painColor(e['level'] as int).withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Center(child: Text(
                    '${e['level']}',
                    style: TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w700,
                      color: _painColor(e['level'] as int),
                    ),
                  )),
                ),
                const SizedBox(width: 10),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(
                    _formatTime(e['time'] as DateTime),
                    style: const TextStyle(fontSize: 11, color: FabColors.muted),
                  ),
                  if ((e['locations'] as List).isNotEmpty)
                    Text(
                      (e['locations'] as List).join(', '),
                      style: const TextStyle(fontSize: 12, color: FabColors.text),
                    ),
                ])),
              ]),
            )),
          ],
        ]),
      ),
    );
  }

  String _formatTime(DateTime t) {
    final h = t.hour.toString().padLeft(2, '0');
    final m = t.minute.toString().padLeft(2, '0');
    return 'Today $h:$m';
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
          style: const TextStyle(fontSize: 10, color: FabColors.pink, letterSpacing: 1.2)),
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
