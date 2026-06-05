import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/child_profile.dart';
import '../screens/transition_tips_screen.dart';
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
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => TransitionTipsScreen(
                          schoolYear: _result.schoolYear,
                        ),
                      ),
                    ),
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

}

