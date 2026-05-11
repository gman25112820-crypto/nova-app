import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ─────────────────────────────────────────────────────────────
// FAB PARENT DASHBOARD
// Weekly mood, sleep, energy trends
// Good/hard things log
// Summary for school/CAMHS appointments
// ─────────────────────────────────────────────────────────────

class FabParentDashboard extends StatefulWidget {
  const FabParentDashboard({super.key});

  @override
  State<FabParentDashboard> createState() => _FabParentDashboardState();
}

class _FabParentDashboardState extends State<FabParentDashboard> {
  List<_DayData> _week = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadWeek();
  }

  Future<void> _loadWeek() async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();
    final days = <_DayData>[];

    for (int i = 6; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final key = date.toIso8601String().substring(0, 10);
      final done = prefs.getBool('checkin_done_$key') ?? false;

      days.add(_DayData(
        date: date,
        done: done,
        mood: done ? prefs.getInt('checkin_mood_$key') ?? -1 : -1,
        sleep: done ? prefs.getInt('checkin_sleep_$key') ?? -1 : -1,
        energy: done ? prefs.getInt('checkin_energy_$key') ?? -1 : -1,
        good: done ? prefs.getString('checkin_good_$key') ?? '' : '',
        hard: done ? prefs.getString('checkin_hard_$key') ?? '' : '',
      ));
    }

    setState(() {
      _week = days;
      _loading = false;
    });
  }

  int get _checkedInDays => _week.where((d) => d.done).length;

  double get _avgMood {
    final done = _week.where((d) => d.done && d.mood >= 0).toList();
    if (done.isEmpty) return 0;
    return done.map((d) => 4 - d.mood).reduce((a, b) => a + b) / done.length;
  }

  double get _avgSleep {
    final done = _week.where((d) => d.done && d.sleep >= 0).toList();
    if (done.isEmpty) return 0;
    return done.map((d) => 4 - d.sleep).reduce((a, b) => a + b) / done.length;
  }

  double get _avgEnergy {
    final done = _week.where((d) => d.done && d.energy >= 0).toList();
    if (done.isEmpty) return 0;
    return done.map((d) => 4 - d.energy).reduce((a, b) => a + b) / done.length;
  }

  String _moodLabel(int index) {
    const labels = ['Amazing', 'Good', 'Okay', 'Not great', 'Sad'];
    if (index < 0 || index >= labels.length) return '—';
    return labels[index];
  }

  String _sleepLabel(int index) {
    const labels = ['Brilliant', 'Good', 'Okay', 'Not great', 'Hard'];
    if (index < 0 || index >= labels.length) return '—';
    return labels[index];
  }

  String _energyLabel(int index) {
    const labels = ['Full power', 'Good', 'Some left', 'Low', 'Empty'];
    if (index < 0 || index >= labels.length) return '—';
    return labels[index];
  }

  String _dayLabel(DateTime d) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[d.weekday - 1];
  }

  Color _scoreColor(double score) {
    if (score >= 3.5) return const Color(0xFF4CAF50);
    if (score >= 2.5) return const Color(0xFFFFEC48);
    if (score >= 1.5) return const Color(0xFFFF9800);
    return const Color(0xFFFF5252);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0820),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            if (_loading)
              const Expanded(
                  child: Center(
                      child: CircularProgressIndicator(
                          color: Color(0xFFFF6FB0))))
            else
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildWeekSummary(),
                      const SizedBox(height: 16),
                      _buildAverageCards(),
                      const SizedBox(height: 16),
                      _buildWeekChart(),
                      const SizedBox(height: 16),
                      _buildDayLog(),
                      const SizedBox(height: 16),
                      _buildExportButton(),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Row(children: [
        GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: Container(
            width: 38, height: 38,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.arrow_back_ios_new,
                color: Colors.white, size: 16),
          ),
        ),
        const SizedBox(width: 14),
        const Text('Parent Dashboard',
            style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w700)),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: const Color(0xFF2D1B5E),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
                color: const Color(0xFFFF6FB7).withValues(alpha: 0.3)),
          ),
          child: const Text('This Week',
              style: TextStyle(
                  color: Color(0xFFFF6FB7),
                  fontSize: 11,
                  fontWeight: FontWeight.w700)),
        ),
      ]),
    );
  }

  Widget _buildWeekSummary() {
    final streakMsg = _checkedInDays == 7
        ? 'Perfect week! 🌟'
        : _checkedInDays >= 5
            ? 'Great week! 💛'
            : _checkedInDays >= 3
                ? 'Getting there 🌱'
                : 'Just getting started';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF2D1B5E), Color(0xFF1A0E3A)],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: const Color(0xFFFF6FB7).withValues(alpha: 0.25)),
      ),
      child: Row(children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(streakMsg,
                  style: const TextStyle(
                      color: Color(0xFFFF6FB7),
                      fontSize: 16,
                      fontWeight: FontWeight.w800)),
              const SizedBox(height: 4),
              Text(
                '$_checkedInDays of 7 days checked in this week',
                style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.6),
                    fontSize: 12)),
            ],
          ),
        ),
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 56, height: 56,
              child: CircularProgressIndicator(
                value: _checkedInDays / 7,
                backgroundColor: Colors.white.withValues(alpha: 0.1),
                valueColor: const AlwaysStoppedAnimation<Color>(
                    Color(0xFFFF6FB0)),
                strokeWidth: 5,
              ),
            ),
            Text('$_checkedInDays/7',
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w800)),
          ],
        ),
      ]),
    );
  }

  Widget _buildAverageCards() {
    return Row(children: [
      Expanded(
          child: _avgCard('Mood', _avgMood, '😊',
              const Color(0xFF8B5CF6))),
      const SizedBox(width: 8),
      Expanded(
          child: _avgCard('Sleep', _avgSleep, '🌙',
              const Color(0xFF3B82F6))),
      const SizedBox(width: 8),
      Expanded(
          child: _avgCard('Energy', _avgEnergy, '⚡',
              const Color(0xFFFFEC48))),
    ]);
  }

  Widget _avgCard(String label, double score, String emoji, Color color) {
    final pct = (score / 4).clamp(0.0, 1.0);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1035),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Column(children: [
        Text(emoji, style: const TextStyle(fontSize: 20)),
        const SizedBox(height: 6),
        Text(label,
            style: TextStyle(
                color: Colors.white.withValues(alpha: 0.5),
                fontSize: 10,
                fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(99),
          child: LinearProgressIndicator(
            value: pct,
            backgroundColor: Colors.white.withValues(alpha: 0.08),
            valueColor: AlwaysStoppedAnimation<Color>(
                _checkedInDays == 0 ? Colors.white24 : _scoreColor(score)),
            minHeight: 6,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          _checkedInDays == 0
              ? 'No data'
              : score >= 3.5
                  ? 'Great'
                  : score >= 2.5
                      ? 'Good'
                      : score >= 1.5
                          ? 'Mixed'
                          : 'Needs support',
          style: TextStyle(
              color: _checkedInDays == 0
                  ? Colors.white24
                  : _scoreColor(score),
              fontSize: 11,
              fontWeight: FontWeight.w700),
        ),
      ]),
    );
  }

  Widget _buildWeekChart() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1035),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('This week',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          Text('Mood each day',
              style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.4),
                  fontSize: 11)),
          const SizedBox(height: 20),
          SizedBox(
            height: 80,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: _week.map((day) {
                final score = day.done && day.mood >= 0
                    ? (4 - day.mood) / 4.0
                    : 0.0;
                final barColor = day.done
                    ? _scoreColor((4 - day.mood.clamp(0, 4)).toDouble())
                    : Colors.white.withValues(alpha: 0.08);
                final isToday = day.date.toIso8601String().substring(0, 10) ==
                    DateTime.now().toIso8601String().substring(0, 10);

                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 3),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        if (day.done)
                          Text(
                            ['😄','🙂','😐','😕','😢'][day.mood.clamp(0, 4)],
                            style: const TextStyle(fontSize: 12),
                          ),
                        const SizedBox(height: 4),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 400),
                          height: day.done ? (score * 56).clamp(8, 56) : 8,
                          decoration: BoxDecoration(
                            color: barColor,
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          _dayLabel(day.date),
                          style: TextStyle(
                              color: isToday
                                  ? const Color(0xFFFF6FB0)
                                  : Colors.white.withValues(alpha: 0.4),
                              fontSize: 9,
                              fontWeight: isToday
                                  ? FontWeight.w800
                                  : FontWeight.w400),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDayLog() {
    final daysWithData = _week.where((d) => d.done).toList().reversed.toList();

    if (daysWithData.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1035),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(
          child: Text(
            'No check-ins yet this week.\nCheck-ins will appear here.',
            textAlign: TextAlign.center,
            style: TextStyle(
                color: Colors.white.withValues(alpha: 0.35),
                fontSize: 13),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Daily log',
            style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w700)),
        const SizedBox(height: 10),
        ...daysWithData.map((day) => _dayCard(day)),
      ],
    );
  }

  Widget _dayCard(_DayData day) {
    final dateStr =
        '${day.date.day}/${day.date.month} — ${_dayLabel(day.date)}';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1035),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Text(dateStr,
                style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.5),
                    fontSize: 11,
                    fontWeight: FontWeight.w600)),
            const Spacer(),
            _pill(_moodLabel(day.mood), const Color(0xFF8B5CF6)),
            const SizedBox(width: 4),
            _pill(_sleepLabel(day.sleep), const Color(0xFF3B82F6)),
            const SizedBox(width: 4),
            _pill(_energyLabel(day.energy), const Color(0xFFFFEC48)),
          ]),
          if (day.good.isNotEmpty) ...[
            const SizedBox(height: 10),
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('✨ ',
                  style: TextStyle(fontSize: 12)),
              Expanded(
                child: Text(day.good,
                    style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.75),
                        fontSize: 12)),
              ),
            ]),
          ],
          if (day.hard.isNotEmpty) ...[
            const SizedBox(height: 6),
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('💙 ',
                  style: TextStyle(fontSize: 12)),
              Expanded(
                child: Text(day.hard,
                    style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.75),
                        fontSize: 12)),
              ),
            ]),
          ],
        ],
      ),
    );
  }

  Widget _pill(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(99),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Text(label,
          style: TextStyle(
              color: color, fontSize: 9, fontWeight: FontWeight.w700)),
    );
  }

  Widget _buildExportButton() {
    return GestureDetector(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('PDF export coming soon 📄'),
            backgroundColor: const Color(0xFF2D1B5E),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
          ),
        );
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1035),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color: const Color(0xFFFF6FB7).withValues(alpha: 0.25)),
        ),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          const Icon(Icons.picture_as_pdf_outlined,
              color: Color(0xFFFF6FB7), size: 20),
          const SizedBox(width: 10),
          const Text('Export for school / CAMHS appointment',
              style: TextStyle(
                  color: Color(0xFFFF6FB7),
                  fontSize: 13,
                  fontWeight: FontWeight.w700)),
        ]),
      ),
    );
  }
}

class _DayData {
  final DateTime date;
  final bool done;
  final int mood;
  final int sleep;
  final int energy;
  final String good;
  final String hard;

  _DayData({
    required this.date,
    required this.done,
    required this.mood,
    required this.sleep,
    required this.energy,
    required this.good,
    required this.hard,
  });
}
