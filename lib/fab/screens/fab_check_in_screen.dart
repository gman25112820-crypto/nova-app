import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/models/check_in_entry.dart';
import '../../core/repositories/check_in_repository.dart';
import '../services/fab_stars_service.dart';

// ─────────────────────────────────────────────────────────────
// FAB CHECK-IN SCREEN
// Child-friendly daily check-in journey
// Steps: mood → sleep → energy → one good thing → one hard thing
// Saves with SharedPreferences, awards a star on completion
// ─────────────────────────────────────────────────────────────

class FabCheckInScreen extends StatefulWidget {
  const FabCheckInScreen({super.key});

  @override
  State<FabCheckInScreen> createState() => _FabCheckInScreenState();
}

class _FabCheckInScreenState extends State<FabCheckInScreen>
    with TickerProviderStateMixin {
  int _step = 0;
  int? _mood;
  int? _sleep;
  int? _energy;
  final TextEditingController _goodCtrl = TextEditingController();
  final TextEditingController _hardCtrl = TextEditingController();
  bool _done = false;
  AwardResult? _award;

  late final AnimationController _starCtrl;
  late final Animation<double> _starAnim;

  @override
  void initState() {
    super.initState();
    _starCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _starAnim = CurvedAnimation(parent: _starCtrl, curve: Curves.elasticOut);
  }

  @override
  void dispose() {
    _starCtrl.dispose();
    _goodCtrl.dispose();
    _hardCtrl.dispose();
    super.dispose();
  }

  Future<void> _saveAndFinish() async {
    final now   = DateTime.now();
    final today = now.toIso8601String().substring(0, 10);

    // Legacy SharedPreferences keys — checkin_mood + checkin_done only (others were dead writes, removed)
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('checkin_mood_$today',  _mood ?? 0);
    await prefs.setBool('checkin_done_$today', true);

    // Persist to CheckInRepository so Insights can read it
    const moodLabels   = ['Amazing', 'Good', 'Okay', 'Not great', 'Sad'];
    const sleepLabels  = ['Brilliant', 'Pretty good', 'Okay', 'Not great', 'Really hard'];
    const energyLabels = ['Full power', 'Pretty good', 'Some left', 'Running low', 'Empty'];
    final good = _goodCtrl.text.trim();
    final hard = _hardCtrl.text.trim();
    final notes = [
      'Mood: ${moodLabels[(_mood ?? 2).clamp(0, 4)]}',
      'Sleep: ${sleepLabels[(_sleep ?? 2).clamp(0, 4)]}',
      'Energy: ${energyLabels[(_energy ?? 2).clamp(0, 4)]}',
      if (good.isNotEmpty) 'Good: $good',
      if (hard.isNotEmpty) 'Hard: $hard',
    ].join('\n');

    await CheckInRepository().saveEntry(CheckInEntry(
      id:                 'checkin_$today',
      date:               DateTime(now.year, now.month, now.day),
      painRating:         0,
      nerveSymptomRating: 0,
      painLocations:      const [],
      symptoms:           const [],
      triggers:           const [],
      notes:              notes,
    ));

    // Award Fab Stars via service
    final award = await FabStarsService.awardForCheckIn();

    setState(() {
      _done  = true;
      _award = award;
    });
    _starCtrl.forward();
  }

  void _next() {
    if (_step == 0 && _mood == null) return;
    if (_step == 1 && _sleep == null) return;
    if (_step == 2 && _energy == null) return;
    if (_step < 4) {
      setState(() => _step++);
    } else {
      _saveAndFinish();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_done) return _buildDoneScreen();

    return Scaffold(
      backgroundColor: const Color(0xFF0F0D20),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildProgressBar(),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 350),
                transitionBuilder: (child, anim) => SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0.12, 0),
                    end: Offset.zero,
                  ).animate(CurvedAnimation(parent: anim, curve: Curves.easeOut)),
                  child: FadeTransition(opacity: anim, child: child),
                ),
                child: _buildStep(),
              ),
            ),
            _buildNextButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              if (_step > 0) {
                setState(() => _step--);
              } else {
                Navigator.of(context).pop();
              }
            },
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.arrow_back_ios_new,
                  color: Colors.white, size: 16),
            ),
          ),
          const SizedBox(width: 14),
          const Text(
            'How are you today?',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: List.generate(5, (i) {
          return Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 3),
              height: 5,
              decoration: BoxDecoration(
                color: i <= _step
                    ? const Color(0xFFFF6FB0)
                    : Colors.white.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(99),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildStep() {
    switch (_step) {
      case 0:
        return _buildEmojiStep(
          key: const ValueKey('mood'),
          question: 'How are you feeling?',
          subtitle: 'Tap the face that matches',
          emojis: const ['😄', '🙂', '😐', '😕', '😢'],
          labels: const ['Amazing', 'Good', 'Okay', 'Not great', 'Sad'],
          selected: _mood,
          onSelect: (i) => setState(() => _mood = i),
        );
      case 1:
        return _buildEmojiStep(
          key: const ValueKey('sleep'),
          question: 'How did you sleep?',
          subtitle: 'Was last night good or tricky?',
          emojis: const ['😴', '🌙', '🌤️', '☁️', '⛈️'],
          labels: const ['Brilliant', 'Pretty good', 'Okay', 'Not great', 'Really hard'],
          selected: _sleep,
          onSelect: (i) => setState(() => _sleep = i),
        );
      case 2:
        return _buildEmojiStep(
          key: const ValueKey('energy'),
          question: 'How much energy do you have?',
          subtitle: 'How full is your battery?',
          emojis: const ['⚡', '🔋', '🌿', '🍂', '😴'],
          labels: const ['Full power', 'Pretty good', 'Some left', 'Running low', 'Empty'],
          selected: _energy,
          onSelect: (i) => setState(() => _energy = i),
        );
      case 3:
        return _buildTextStep(
          key: const ValueKey('good'),
          question: 'One good thing today',
          subtitle: 'Even something tiny counts 🌟',
          hint: 'I liked it when...',
          controller: _goodCtrl,
          emoji: '✨',
        );
      case 4:
        return _buildTextStep(
          key: const ValueKey('hard'),
          question: 'One hard thing today',
          subtitle: 'It\'s okay to say when something was tricky',
          hint: 'Something that felt hard was...',
          controller: _hardCtrl,
          emoji: '💙',
        );
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildEmojiStep({
    required Key key,
    required String question,
    required String subtitle,
    required List<String> emojis,
    required List<String> labels,
    required int? selected,
    required void Function(int) onSelect,
  }) {
    return Padding(
      key: key,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          Text(
            question,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.52),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 36),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(emojis.length, (i) {
              final isSelected = selected == i;
              return GestureDetector(
                onTap: () => onSelect(i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeOut,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFFFF6FB0).withValues(alpha: 0.20)
                        : Colors.white.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFFFF6FB0)
                          : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        emojis[i],
                        style: TextStyle(
                          fontSize: isSelected ? 38 : 30,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        labels[i],
                        style: TextStyle(
                          color: isSelected
                              ? const Color(0xFFFF6FB0)
                              : Colors.white.withValues(alpha: 0.45),
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildTextStep({
    required Key key,
    required String question,
    required String subtitle,
    required String hint,
    required TextEditingController controller,
    required String emoji,
  }) {
    return Padding(
      key: key,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          Text(
            emoji,
            style: const TextStyle(fontSize: 40),
          ),
          const SizedBox(height: 12),
          Text(
            question,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.52),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 28),
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.10),
              ),
            ),
            child: TextField(
              controller: controller,
              style: const TextStyle(color: Colors.white, fontSize: 16),
              maxLines: 4,
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: TextStyle(
                  color: Colors.white.withValues(alpha: 0.28),
                  fontSize: 15,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.all(16),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'You can skip this if you want',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.30),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNextButton() {
    final isLast = _step == 4;
    final canProceed = (_step == 0 && _mood != null) ||
        (_step == 1 && _sleep != null) ||
        (_step == 2 && _energy != null) ||
        _step == 3 ||
        _step == 4;

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 28),
      child: GestureDetector(
        onTap: canProceed ? _next : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: double.infinity,
          height: 56,
          decoration: BoxDecoration(
            gradient: canProceed
                ? const LinearGradient(
                    colors: [Color(0xFFFF6FB0), Color(0xFFFF4081)],
                  )
                : null,
            color: canProceed ? null : Colors.white.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Center(
            child: Text(
              isLast ? 'Finish ✨' : 'Next →',
              style: TextStyle(
                color: canProceed
                    ? Colors.white
                    : Colors.white.withValues(alpha: 0.30),
                fontSize: 17,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDoneScreen() {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0D20),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ScaleTransition(
                scale: _starAnim,
                child: const Text('⭐', style: TextStyle(fontSize: 80)),
              ),
              const SizedBox(height: 24),
              Text(
                _award != null && _award!.hasEarned
                    ? 'You earned ${_award!.earned} Fab Stars!'
                    : 'Check-in complete!',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 10),
              if (_award != null && _award!.hasEarned)
                Text(
                  _award!.breakdownText,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: const Color(0xFFFFD700).withValues(alpha: 0.90),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    height: 1.7,
                  ),
                ),
              const SizedBox(height: 8),
              if (_award != null)
                Text(
                  'Total: ${_award!.balance} ⭐',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.55),
                    fontSize: 14,
                  ),
                ),
              const SizedBox(height: 4),
              Text(
                'Well done for checking in today 💛',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.50),
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 48),
              GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 36, vertical: 16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFF6FB0), Color(0xFFFF4081)],
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Text(
                    'Back to home 🏠',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
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
