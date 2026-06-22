import 'package:flutter/material.dart';
import 'chicken_lips_widget.dart';
import '../services/companion_service.dart';

// ─────────────────────────────────────────────────────────────
// ChickenLipsCompanion
//
// Miss Chicken Lips as a living companion on the world scene.
// She sits near the left (Chicken family) house. Tap her to
// toggle a speech bubble with her personalised greeting.
//
// Auto-shows on first load after 1.5 s, dismisses after 7 s.
// State resets each session — she always greets fresh.
// ─────────────────────────────────────────────────────────────

class ChickenLipsCompanion extends StatefulWidget {
  final CompanionGreeting greeting;

  const ChickenLipsCompanion({super.key, required this.greeting});

  @override
  State<ChickenLipsCompanion> createState() => _ChickenLipsCompanionState();
}

class _ChickenLipsCompanionState extends State<ChickenLipsCompanion>
    with SingleTickerProviderStateMixin {

  bool _visible = false;
  late final AnimationController _ctrl;
  late final Animation<double> _scaleAnim;
  late final Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 380),
    );
    _scaleAnim = CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut);
    _fadeAnim  = CurvedAnimation(parent: _ctrl, curve: Curves.easeIn);

    // Auto-show after app settles
    Future.delayed(const Duration(milliseconds: 1600), () {
      if (mounted) _show();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _show() {
    setState(() => _visible = true);
    _ctrl.forward(from: 0);
    Future.delayed(const Duration(seconds: 7), () {
      if (mounted && _visible) _hide();
    });
  }

  void _hide() {
    _ctrl.reverse().then((_) {
      if (mounted) setState(() => _visible = false);
    });
  }

  void _onTap() => _visible ? _hide() : _show();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Speech bubble ────────────────────────────────────
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: _visible
                ? ScaleTransition(
                    key: const ValueKey('bubble'),
                    scale: _scaleAnim,
                    alignment: Alignment.bottomLeft,
                    child: FadeTransition(
                      opacity: _fadeAnim,
                      child: _SpeechBubble(text: widget.greeting.text),
                    ),
                  )
                : const SizedBox.shrink(key: ValueKey('empty')),
          ),
          // ── Character ────────────────────────────────────────
          ChickenLipsWidget(
            mood: widget.greeting.mood,
            scale: 0.36,
          ),
        ],
      ),
    );
  }
}

// ── Speech bubble ─────────────────────────────────────────────

class _SpeechBubble extends StatelessWidget {
  final String text;
  const _SpeechBubble({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6, left: 4),
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
      constraints: const BoxConstraints(maxWidth: 188),
      decoration: BoxDecoration(
        color: const Color(0xFF2D1B69).withValues(alpha: 0.96),
        borderRadius: const BorderRadius.only(
          topLeft:     Radius.circular(14),
          topRight:    Radius.circular(14),
          bottomRight: Radius.circular(14),
          bottomLeft:  Radius.circular(4),
        ),
        border: Border.all(
          color: const Color(0xFF6C63FF).withValues(alpha: 0.50),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6C63FF).withValues(alpha: 0.28),
            blurRadius: 18,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'EDDIE',
            style: TextStyle(
              color: Color(0xFFB39DDB),
              fontSize: 8,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontFamily: 'DM Sans',
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}
