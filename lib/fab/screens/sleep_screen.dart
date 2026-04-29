import 'package:flutter/material.dart';
import 'dart:math';
import '../fab_theme.dart';

class SleepScreen extends StatefulWidget {
  const SleepScreen({super.key});
  @override
  State<SleepScreen> createState() => _SleepScreenState();
}

class _SleepScreenState extends State<SleepScreen> {
  TimeOfDay _bedtime = const TimeOfDay(hour: 22, minute: 30);
  TimeOfDay _wakeTime = const TimeOfDay(hour: 7, minute: 0);
  int _quality = 3;
  final List<String> _factors = [];
  final List<String> _dreams = [];
  bool _medication = false;
  bool _screenTime = false;
  bool _caffeine = false;
  final List<Map<String, dynamic>> _log = [];

  static const _qualityLabels = ['Terrible', 'Poor', 'Okay', 'Good', 'Great'];
  static const _qualityEmojis = ['😴', '😞', '😐', '🙂', '⭐'];

  static const _factorList = [
    'Noise', 'Too hot', 'Too cold', 'Anxiety', 'Pain',
    'Nightmares', 'Restless legs', 'Needing the toilet',
    'Intrusive thoughts', 'Partner/child woke me',
  ];

  double get _hoursSlept {
    final bedMinutes = _bedtime.hour * 60 + _bedtime.minute;
    var wakeMinutes = _wakeTime.hour * 60 + _wakeTime.minute;
    if (wakeMinutes <= bedMinutes) wakeMinutes += 24 * 60;
    return (wakeMinutes - bedMinutes) / 60.0;
  }

  Color _sleepColor() {
    final h = _hoursSlept;
    if (h < 5) return FabColors.rose;
    if (h < 6) return const Color(0xFFFF9800);
    if (h < 8) return FabColors.teal;
    return FabColors.gold;
  }

  String _sleepAdvice() {
    final h = _hoursSlept;
    if (h < 5) return 'Very low sleep. This will affect focus and mood significantly.';
    if (h < 6) return 'Below recommended. Try to get to bed 30 min earlier tonight.';
    if (h < 7) return 'Getting there. Most people need 7-9 hours.';
    if (h < 9) return 'Great sleep duration! Well done.';
    return 'Long sleep — could indicate fatigue or low mood. Worth noting.';
  }

  Future<void> _pickTime(bool isBedtime) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: isBedtime ? _bedtime : _wakeTime,
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.dark(
            primary: FabColors.pink,
            surface: FabColors.panel,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() {
        if (isBedtime) {
          _bedtime = picked;
        } else {
          _wakeTime = picked;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FabColors.bg,
      appBar: AppBar(
        backgroundColor: FabColors.mid,
        title: const Text('Sleep Tracker',
          style: TextStyle(color: FabColors.pink, fontSize: 16)),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

          // Sleep duration hero
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft, end: Alignment.bottomRight,
                colors: [FabColors.panel, FabColors.panel2],
              ),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: _sleepColor().withValues(alpha: 0.4), width: 1),
            ),
            child: Column(children: [
              const Text('LAST NIGHT', style: TextStyle(
                fontSize: 10, letterSpacing: 2, color: FabColors.muted)),
              const SizedBox(height: 8),
              Text(
                '${_hoursSlept.toStringAsFixed(1)}h',
                style: TextStyle(fontSize: 64, fontWeight: FontWeight.w700,
                  color: _sleepColor(), height: 1),
              ),
              Text(_sleepAdvice(),
                style: const TextStyle(fontSize: 12, color: FabColors.muted),
                textAlign: TextAlign.center),
              const SizedBox(height: 16),
              // Sleep arc visualisation
              SizedBox(
                height: 80,
                child: CustomPaint(
                  painter: _SleepArcPainter(
                    hours: _hoursSlept,
                    color: _sleepColor(),
                  ),
                  size: const Size(double.infinity, 80),
                ),
              ),
            ]),
          ),

          const SizedBox(height: 14),

          // Bedtime / wake time
          _section(
            title: 'Sleep times',
            child: Row(children: [
              Expanded(child: _timeButton(
                label: 'Bedtime',
                time: _bedtime,
                icon: '🌙',
                onTap: () => _pickTime(true),
              )),
              const SizedBox(width: 12),
              Expanded(child: _timeButton(
                label: 'Woke up',
                time: _wakeTime,
                icon: '☀️',
                onTap: () => _pickTime(false),
              )),
            ]),
          ),

          const SizedBox(height: 12),

          // Sleep quality
          _section(
            title: 'Sleep quality',
            child: Column(children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(5, (i) => GestureDetector(
                  onTap: () => setState(() => _quality = i + 1),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 52, height: 52,
                    decoration: BoxDecoration(
                      color: _quality == i + 1
                        ? FabColors.teal.withValues(alpha: 0.2) : FabColors.panel2,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: _quality == i + 1 ? FabColors.teal : Colors.transparent,
                        width: 2),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(_qualityEmojis[i], style: const TextStyle(fontSize: 18)),
                        Text('${i + 1}', style: TextStyle(fontSize: 9,
                          color: _quality == i + 1 ? FabColors.teal : FabColors.muted)),
                      ],
                    ),
                  ),
                )),
              ),
              const SizedBox(height: 6),
              Text(_qualityLabels[_quality - 1],
                style: const TextStyle(fontSize: 12, color: FabColors.muted)),
            ]),
          ),

          const SizedBox(height: 12),

          // Evening factors
          _section(
            title: 'Evening habits',
            child: Column(children: [
              _toggle('Took sleep medication', _medication,
                () => setState(() => _medication = !_medication), FabColors.teal),
              const SizedBox(height: 8),
              _toggle('Screen time in last hour', _screenTime,
                () => setState(() => _screenTime = !_screenTime), FabColors.rose),
              const SizedBox(height: 8),
              _toggle('Caffeine after 2pm', _caffeine,
                () => setState(() => _caffeine = !_caffeine), FabColors.gold),
            ]),
          ),

          const SizedBox(height: 12),

          // What disrupted sleep
          _section(
            title: 'What disrupted your sleep?',
            child: Wrap(
              spacing: 8, runSpacing: 8,
              children: _factorList.map((f) {
                final sel = _factors.contains(f);
                return GestureDetector(
                  onTap: () => setState(() =>
                    sel ? _factors.remove(f) : _factors.add(f)),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
                    decoration: BoxDecoration(
                      color: sel ? FabColors.rose.withValues(alpha: 0.18) : FabColors.panel2,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: sel ? FabColors.rose : const Color(0x1AFF8FAB),
                        width: sel ? 1 : 0.5),
                    ),
                    child: Text(f, style: TextStyle(fontSize: 11,
                      color: sel ? FabColors.rose : FabColors.muted)),
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 16),

          GestureDetector(
            onTap: () {
              setState(() {
                _log.insert(0, {
                  'date': DateTime.now(),
                  'hours': _hoursSlept,
                  'quality': _quality,
                  'factors': List.from(_factors),
                });
              });
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text('Sleep logged — ${_hoursSlept.toStringAsFixed(1)}h ✓'),
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
                  colors: [Color(0xFF7B4FFF), FabColors.pink]),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(child: Text('Log sleep',
                style: TextStyle(color: Colors.white, fontSize: 15,
                  fontWeight: FontWeight.w500))),
            ),
          ),

          // Sleep history
          if (_log.isNotEmpty) ...[
            const SizedBox(height: 20),
            const Text('SLEEP HISTORY', style: TextStyle(
              fontSize: 10, color: FabColors.muted, letterSpacing: 1.2)),
            const SizedBox(height: 8),
            ..._log.take(7).map((e) {
              final h = e['hours'] as double;
              final q = e['quality'] as int;
              final col = h < 6 ? FabColors.rose : h < 7 ? FabColors.gold : FabColors.teal;
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: FabColors.panel,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0x1EFF8FAB), width: 0.5),
                ),
                child: Row(children: [
                  Container(
                    width: 42, height: 42,
                    decoration: BoxDecoration(
                      color: col.withValues(alpha: 0.15), shape: BoxShape.circle),
                    child: Center(child: Text('${h.toStringAsFixed(1)}h',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700,
                        color: col))),
                  ),
                  const SizedBox(width: 10),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(_formatDate(e['date'] as DateTime),
                        style: const TextStyle(fontSize: 11, color: FabColors.muted)),
                      Row(children: List.generate(5, (i) => Text(
                        i < q ? '★' : '☆',
                        style: TextStyle(fontSize: 12,
                          color: i < q ? FabColors.gold : FabColors.muted),
                      ))),
                    ])),
                ]),
              );
            }),
          ],
        ]),
      ),
    );
  }

  Widget _timeButton({required String label, required TimeOfDay time,
    required String icon, required VoidCallback onTap}) {
    final h = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final m = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: FabColors.panel2,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0x1AFF8FAB), width: 0.5),
        ),
        child: Column(children: [
          Text(icon, style: const TextStyle(fontSize: 22)),
          const SizedBox(height: 4),
          Text('$h:$m $period', style: const TextStyle(
            fontSize: 18, fontWeight: FontWeight.w600, color: FabColors.text)),
          Text(label, style: const TextStyle(fontSize: 10, color: FabColors.muted)),
        ]),
      ),
    );
  }

  Widget _toggle(String label, bool value, VoidCallback onTap, Color color) =>
    GestureDetector(
      onTap: onTap,
      child: Row(children: [
        Container(
          width: 22, height: 22,
          decoration: BoxDecoration(
            color: value ? color.withValues(alpha: 0.2) : FabColors.panel2,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: value ? color : const Color(0x1AFF8FAB),
              width: value ? 1.5 : 0.5),
          ),
          child: value ? Icon(Icons.check, size: 14, color: color) : null,
        ),
        const SizedBox(width: 10),
        Text(label, style: const TextStyle(fontSize: 13, color: FabColors.text)),
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
      Text(title.toUpperCase(), style: const TextStyle(
        fontSize: 10, color: FabColors.pink, letterSpacing: 1.2)),
      const SizedBox(height: 10),
      child,
    ]),
  );

  String _formatDate(DateTime d) {
    final days = ['Mon','Tue','Wed','Thu','Fri','Sat','Sun'];
    return '${days[d.weekday - 1]} ${d.day}/${d.month}';
  }
}

class _SleepArcPainter extends CustomPainter {
  final double hours;
  final Color color;
  _SleepArcPainter({required this.hours, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height;
    final r = size.width * 0.38;

    // Background arc
    canvas.drawArc(
      Rect.fromCenter(center: Offset(cx, cy), width: r * 2, height: r * 2),
      pi, pi, false,
      Paint()
        ..color = FabColors.panel2
        ..strokeWidth = 10
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );

    // Sleep arc (max 10 hours = full arc)
    final fraction = (hours / 10.0).clamp(0.0, 1.0);
    canvas.drawArc(
      Rect.fromCenter(center: Offset(cx, cy), width: r * 2, height: r * 2),
      pi, pi * fraction, false,
      Paint()
        ..color = color
        ..strokeWidth = 10
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );

    // Hour markers
    for (int i = 0; i <= 10; i++) {
      final angle = pi + (pi * i / 10);
      final mx = cx + (r + 16) * cos(angle);
      final my = cy + (r + 16) * sin(angle);
      if (i % 2 == 0) {
        final tp = TextPainter(
          text: TextSpan(
            text: '${i}h',
            style: TextStyle(fontSize: 9,
              color: i == hours.round() ? color : FabColors.muted),
          ),
          textDirection: TextDirection.ltr,
        )..layout();
        tp.paint(canvas, Offset(mx - tp.width / 2, my - tp.height / 2));
      }
    }
  }

  @override
  bool shouldRepaint(_SleepArcPainter old) =>
    old.hours != hours || old.color != color;
}
