import 'package:flutter/material.dart';

// ─────────────────────────────────────────────────────────────
// TransitionTipsScreen
//
// Full-screen resource hub shown when a child taps the Year 6–7
// transition banner. Contains practical, warm tips for moving
// schools. Designed for CanvasKit web — no DraggableScrollableSheet.
// ─────────────────────────────────────────────────────────────

class TransitionTipsScreen extends StatelessWidget {
  const TransitionTipsScreen({super.key, this.schoolYear = 6});

  final int schoolYear;

  static const _bg     = Color(0xFF0D0820);
  static const _purple = Color(0xFF6C63FF);
  static const _teal   = Color(0xFF00C9A7);

  bool get _isYear7 => schoolYear == 7;

  Color get _accent => _isYear7 ? _teal : _purple;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Color(0xFFF0D6FF)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          _isYear7 ? '🏫 You\'ve got this!' : '💜 Getting ready',
          style: const TextStyle(
            color: Color(0xFFF0D6FF),
            fontSize: 17,
            fontWeight: FontWeight.w700,
            fontFamily: 'DM Sans',
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _isYear7
                  ? 'Tips for settling into secondary school'
                  : 'Thinking ahead — gentle ideas to prepare',
              style: TextStyle(
                color: const Color(0xFFF0D6FF).withValues(alpha: 0.55),
                fontSize: 14,
                fontFamily: 'DM Sans',
              ),
            ),
            const SizedBox(height: 20),
            ...(_isYear7 ? _year7Tips : _prepTips)
                .map((t) => _TipCard(emoji: t.$1, text: t.$2, accent: _accent)),
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

class _TipCard extends StatelessWidget {
  final String emoji;
  final String text;
  final Color accent;

  const _TipCard({required this.emoji, required this.text, required this.accent});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: accent.withValues(alpha: 0.22)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: const Color(0xFFF0D6FF).withValues(alpha: 0.85),
                fontSize: 13,
                fontFamily: 'DM Sans',
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
