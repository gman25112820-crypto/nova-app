import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/child_profile.dart';
import '../services/age_prompt_engine.dart';

// ─────────────────────────────────────────────────────────────
// TransitionBanner
//
// Soft dismissable banner shown on the home screen when a child
// is in the Year 5-7 school transition window. Dismissal is
// stored in SharedPreferences (keyed by school year) so it
// reappears at the start of each new year group.
// ─────────────────────────────────────────────────────────────

class TransitionBanner extends StatefulWidget {
  final ChildProfile child;
  const TransitionBanner({super.key, required this.child});

  @override
  State<TransitionBanner> createState() => _TransitionBannerState();
}

class _TransitionBannerState extends State<TransitionBanner> {
  bool _dismissed = false;
  bool _ready     = false;
  late AgePromptResult _result;

  @override
  void initState() {
    super.initState();
    _result = AgePromptEngine.evaluate(widget.child.age);
    if (!_result.showTransitionBanner) {
      _ready = true;
      return;
    }
    _checkDismissed();
  }

  Future<void> _checkDismissed() async {
    final prefs = await SharedPreferences.getInstance();
    final key   = 'fab_transition_banner_y${_result.schoolYear}';
    if (mounted) {
      setState(() {
        _dismissed = prefs.getBool(key) ?? false;
        _ready     = true;
      });
    }
  }

  Future<void> _dismiss() async {
    final prefs = await SharedPreferences.getInstance();
    final key   = 'fab_transition_banner_y${_result.schoolYear}';
    await prefs.setBool(key, true);
    if (mounted) setState(() => _dismissed = true);
  }

  @override
  Widget build(BuildContext context) {
    if (!_ready || _dismissed || !_result.showTransitionBanner) {
      return const SizedBox.shrink();
    }

    final isYear7 = _result.schoolYear == 7;
    final accent  = isYear7
        ? const Color(0xFF00C9A7)
        : const Color(0xFF6C63FF);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Container(
        padding: const EdgeInsets.fromLTRB(14, 12, 10, 12),
        decoration: BoxDecoration(
          color: accent.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: accent.withValues(alpha: 0.28)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isYear7 ? '🏫' : '💜',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _result.bannerMessage ?? '',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'DM Sans',
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 6),
                  GestureDetector(
                    onTap: () => _showTips(context),
                    child: Text(
                      'Transition tips →',
                      style: TextStyle(
                        color: accent,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'DM Sans',
                      ),
                    ),
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: _dismiss,
              child: Padding(
                padding: const EdgeInsets.only(left: 8, top: 2),
                child: Icon(Icons.close_rounded,
                    color: Colors.white.withValues(alpha: 0.35), size: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showTips(BuildContext context) {
    final isYear7 = _result.schoolYear == 7;
    final tips = isYear7
        ? _year7Tips
        : _prepTips;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF150D2E),
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.65,
        maxChildSize: 0.90,
        builder: (_, ctrl) => ListView(
          controller: ctrl,
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
          children: [
            Center(
              child: Container(
                  width: 36,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(2))),
            ),
            Text(
              isYear7 ? '🏫 You\'ve got this!' : '💜 Getting ready',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w700,
                fontFamily: 'DM Sans',
              ),
            ),
            const SizedBox(height: 6),
            Text(
              isYear7
                  ? 'Tips for settling into secondary school'
                  : 'Thinking ahead — gentle ideas to prepare',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.50),
                fontSize: 13,
                fontFamily: 'DM Sans',
              ),
            ),
            const SizedBox(height: 20),
            ...tips.map((tip) => _TipCard(emoji: tip.$1, text: tip.$2)),
          ],
        ),
      ),
    );
  }

  static const _year7Tips = [
    ('🗺️', 'Visit the new school before term starts if you can — even a quick walk helps.'),
    ('🎒', 'Pack a small sensory kit: headphones, fidget toy, something familiar from home.'),
    ('🚶', 'Learn your route to school ahead of time — fewer surprises on day one.'),
    ('🌿', 'Plan a quiet wind-down after school — your brain will be working hard.'),
    ('💬', 'Tell a trusted adult if something is hard — you don\'t have to sort it alone.'),
    ('⭐', 'It\'s okay to find it tricky at first. Everyone does. You\'ll find your feet.'),
  ];

  static const _prepTips = [
    ('💜', 'Secondary school is a while away — you have loads of time to get ready.'),
    ('🗓️', 'It\'s normal to have questions or worries. You can talk to someone any time.'),
    ('🏫', 'You might get to visit your new school before you start — that really helps!'),
    ('🎒', 'Start thinking about what makes you feel safe and comfortable — that\'s useful to know.'),
    ('🌟', 'You\'re doing brilliantly — change can be exciting too.'),
  ];
}

// ── Tip card ──────────────────────────────────────────────────

class _TipCard extends StatelessWidget {
  final String emoji;
  final String text;
  const _TipCard({required this.emoji, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF6C63FF).withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: const Color(0xFF6C63FF).withValues(alpha: 0.18)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 18)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.80),
                fontSize: 13,
                fontFamily: 'DM Sans',
                height: 1.45,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
