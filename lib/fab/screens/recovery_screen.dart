import 'package:flutter/material.dart';
import '../fab_theme.dart';

class RecoveryScreen extends StatefulWidget {
  const RecoveryScreen({super.key});
  @override
  State<RecoveryScreen> createState() => _RecoveryScreenState();
}

class _RecoveryScreenState extends State<RecoveryScreen> {
  // Sobriety tracking
  final DateTime _sobrietyStart = DateTime(2025, 1, 15);
  int _moodToday = -1;
  final List<String> _triggers = [];
  final List<String> _copingUsed = [];
  bool _meetingToday = false;
  bool _calledSponsor = false;
  String? _gratitude;
  final _gratCtrl = TextEditingController();
  final List<String> _dailyLog = [];

  static const _moods = ['😔', '😕', '😐', '🙂', '😊', '🌟'];
  static const _moodLabels = ['Low', 'Struggling', 'Neutral', 'Okay', 'Good', 'Great'];

  static const _triggerList = [
    'Stress', 'Loneliness', 'Boredom', 'Anxiety',
    'Social pressure', 'Bad news', 'Pain', 'Tiredness',
    'Arguments', 'Financial worries',
  ];

  static const _copingList = [
    'Called someone', 'Went for a walk', 'Breathed through it',
    'Distracted myself', 'Wrote it down', 'Meditated',
    'Made a cup of tea', 'Listened to music', 'Said a prayer',
    'Remembered my why',
  ];

  int get _daysSober {
    return DateTime.now().difference(_sobrietyStart).inDays;
  }

  String get _sobrietyMilestone {
    final d = _daysSober;
    if (d >= 365) return '${d ~/ 365} year${d ~/ 365 > 1 ? 's' : ''}';
    if (d >= 30) return '${d ~/ 30} month${d ~/ 30 > 1 ? 's' : ''}';
    if (d >= 7) return '${d ~/ 7} week${d ~/ 7 > 1 ? 's' : ''}';
    return '$d day${d != 1 ? 's' : ''}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FabColors.bg,
      appBar: AppBar(
        backgroundColor: FabColors.mid,
        title: const Text('Recovery', style: TextStyle(color: FabColors.pink, fontSize: 16)),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

          // Sobriety counter — hero card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft, end: Alignment.bottomRight,
                colors: [Color(0xFF26103F), Color(0xFF3D1A6E)],
              ),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: FabColors.gold.withValues(alpha: 0.3), width: 1),
            ),
            child: Column(children: [
              const Text('CLEAN & SOBER', style: TextStyle(
                fontSize: 11, letterSpacing: 2, color: FabColors.gold)),
              const SizedBox(height: 8),
              Text(
                '$_daysSober',
                style: const TextStyle(
                  fontSize: 72, fontWeight: FontWeight.w700, color: FabColors.gold, height: 1),
              ),
              Text(
                'days — $_sobrietyMilestone',
                style: const TextStyle(fontSize: 16, color: FabColors.text),
              ),
              const SizedBox(height: 12),
              // Weekly streak dots
              Row(mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(7, (i) {
                  final done = i < (_daysSober % 7 == 0 ? 7 : _daysSober % 7);
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: 28, height: 28,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: done ? FabColors.gold.withValues(alpha: 0.2) : FabColors.panel2,
                      border: Border.all(
                        color: done ? FabColors.gold : const Color(0x1AFF8FAB),
                        width: done ? 1.5 : 0.5,
                      ),
                    ),
                    child: Center(child: Text(
                      ['M','T','W','T','F','S','S'][i],
                      style: TextStyle(
                        fontSize: 10,
                        color: done ? FabColors.gold : FabColors.muted,
                        fontWeight: done ? FontWeight.w700 : FontWeight.normal,
                      ),
                    )),
                  );
                }),
              ),
            ]),
          ),

          const SizedBox(height: 14),

          // Today's mood
          _section(
            title: "How are you feeling today?",
            child: Column(children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(6, (i) => GestureDetector(
                  onTap: () => setState(() => _moodToday = i),
                  child: Column(children: [
                    Container(
                      width: 44, height: 44,
                      decoration: BoxDecoration(
                        color: _moodToday == i
                          ? FabColors.pink.withValues(alpha: 0.2) : FabColors.panel2,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: _moodToday == i ? FabColors.pink : Colors.transparent,
                          width: 1.5,
                        ),
                      ),
                      child: Center(child: Text(_moods[i], style: const TextStyle(fontSize: 20))),
                    ),
                    const SizedBox(height: 4),
                    Text(_moodLabels[i], style: TextStyle(
                      fontSize: 9,
                      color: _moodToday == i ? FabColors.pink : FabColors.muted,
                    )),
                  ]),
                )),
              ),
            ]),
          ),

          const SizedBox(height: 12),

          // Today's check-ins
          _section(
            title: 'Today\'s check-ins',
            child: Column(children: [
              _toggle(
                label: 'Attended a meeting',
                value: _meetingToday,
                onTap: () => setState(() => _meetingToday = !_meetingToday),
                color: FabColors.teal,
              ),
              const SizedBox(height: 8),
              _toggle(
                label: 'Called sponsor / support person',
                value: _calledSponsor,
                onTap: () => setState(() => _calledSponsor = !_calledSponsor),
                color: FabColors.pink,
              ),
            ]),
          ),

          const SizedBox(height: 12),

          // Triggers
          _section(
            title: 'Any triggers today?',
            child: Wrap(
              spacing: 8, runSpacing: 8,
              children: _triggerList.map((t) {
                final sel = _triggers.contains(t);
                return GestureDetector(
                  onTap: () => setState(() =>
                    sel ? _triggers.remove(t) : _triggers.add(t)),
                  child: _chip(t, sel, FabColors.rose),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 12),

          // Coping strategies
          _section(
            title: 'Coping strategies used',
            child: Wrap(
              spacing: 8, runSpacing: 8,
              children: _copingList.map((c) {
                final sel = _copingUsed.contains(c);
                return GestureDetector(
                  onTap: () => setState(() =>
                    sel ? _copingUsed.remove(c) : _copingUsed.add(c)),
                  child: _chip(c, sel, FabColors.teal),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 12),

          // Gratitude
          _section(
            title: 'One thing I\'m grateful for today',
            child: TextField(
              controller: _gratCtrl,
              style: const TextStyle(color: FabColors.text, fontSize: 13),
              decoration: InputDecoration(
                hintText: 'Even something small counts...',
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

          // Save
          GestureDetector(
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: const Text('Recovery check-in saved ✓'),
                backgroundColor: FabColors.teal.withValues(alpha: 0.9),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ));
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [FabColors.teal, Color(0xFF00A888)]),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(child: Text('Save today\'s check-in',
                style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w500))),
            ),
          ),

          const SizedBox(height: 20),

          // Crisis resources
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFF1A0A2E),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: FabColors.rose.withValues(alpha: 0.3), width: 0.8),
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('IF YOU\'RE STRUGGLING RIGHT NOW',
                style: TextStyle(fontSize: 10, color: FabColors.rose, letterSpacing: 1)),
              const SizedBox(height: 8),
              _crisisLine('Samaritans', '116 123', '24/7 free'),
              _crisisLine('FRANK drugs helpline', '0300 123 6600', '24/7'),
              _crisisLine('Alcoholics Anonymous', '0800 9177 650', 'Free'),
              _crisisLine('Narcotics Anonymous', '0300 999 1212', 'Free'),
            ]),
          ),
        ]),
      ),
    );
  }

  Widget _toggle({required String label, required bool value,
    required VoidCallback onTap, required Color color}) {
    return GestureDetector(
      onTap: onTap,
      child: Row(children: [
        Container(
          width: 24, height: 24,
          decoration: BoxDecoration(
            color: value ? color.withValues(alpha: 0.2) : FabColors.panel2,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: value ? color : const Color(0x1AFF8FAB), width: value ? 1.5 : 0.5),
          ),
          child: value ? Icon(Icons.check, size: 16, color: color) : null,
        ),
        const SizedBox(width: 10),
        Text(label, style: const TextStyle(fontSize: 13, color: FabColors.text)),
      ]),
    );
  }

  Widget _chip(String label, bool sel, Color col) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
    decoration: BoxDecoration(
      color: sel ? col.withValues(alpha: 0.18) : FabColors.panel2,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: sel ? col : const Color(0x1AFF8FAB), width: sel ? 1 : 0.5),
    ),
    child: Text(label, style: TextStyle(fontSize: 11, color: sel ? col : FabColors.muted)),
  );

  Widget _crisisLine(String name, String number, String hours) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Row(children: [
      Expanded(child: Text(name, style: const TextStyle(fontSize: 12, color: FabColors.text))),
      Text(number, style: const TextStyle(fontSize: 12, color: FabColors.rose, fontWeight: FontWeight.w500)),
      const SizedBox(width: 8),
      Text(hours, style: const TextStyle(fontSize: 10, color: FabColors.muted)),
    ]),
  );

  Widget _section({required String title, required Widget child}) => Container(
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

  @override
  void dispose() {
    _gratCtrl.dispose();
    super.dispose();
  }
}
