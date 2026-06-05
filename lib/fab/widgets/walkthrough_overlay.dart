import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

// ─────────────────────────────────────────────────────────────
// WalkthroughOverlay
//
// Step-by-step spotlight walkthrough for child and parent sides.
// Each step highlights a target widget via GlobalKey cutout.
// Completion written to Hive box 'walkthrough' so it never
// repeats after first run.
//
// Usage:
//   await WalkthroughOverlay.showIfNeeded(context, WalkthroughType.child, steps);
//   await WalkthroughOverlay.showIfNeeded(context, WalkthroughType.parent, steps);
// ─────────────────────────────────────────────────────────────

enum WalkthroughType { child, parent }

enum WalkthroughPosition { above, below, left, right }

class WalkthroughStep {
  final GlobalKey targetKey;
  final String title;
  final String body;
  final WalkthroughPosition position;

  const WalkthroughStep({
    required this.targetKey,
    required this.title,
    required this.body,
    this.position = WalkthroughPosition.below,
  });
}

class WalkthroughOverlay {
  static const _boxName = 'walkthrough';

  static String _completedKey(WalkthroughType type) =>
      type == WalkthroughType.child ? 'child_complete' : 'parent_complete';

  static Future<bool> isComplete(WalkthroughType type) async {
    final box = await Hive.openBox<bool>(_boxName);
    return box.get(_completedKey(type)) ?? false;
  }

  static Future<void> _markComplete(WalkthroughType type) async {
    final box = await Hive.openBox<bool>(_boxName);
    await box.put(_completedKey(type), true);
  }

  // Call this from the screen's initState (after first frame).
  static Future<void> showIfNeeded(
    BuildContext context,
    WalkthroughType type,
    List<WalkthroughStep> steps,
  ) async {
    if (await isComplete(type)) return;
    if (!context.mounted) return;
    await Navigator.of(context).push<void>(
      PageRouteBuilder(
        opaque: false,
        barrierDismissible: false,
        pageBuilder: (_, __, ___) => _WalkthroughPage(
          type: type,
          steps: steps,
          onComplete: () => _markComplete(type),
        ),
      ),
    );
  }
}

// ── Internal page ─────────────────────────────────────────────

class _WalkthroughPage extends StatefulWidget {
  final WalkthroughType type;
  final List<WalkthroughStep> steps;
  final Future<void> Function() onComplete;

  const _WalkthroughPage({
    required this.type,
    required this.steps,
    required this.onComplete,
  });

  @override
  State<_WalkthroughPage> createState() => _WalkthroughPageState();
}

class _WalkthroughPageState extends State<_WalkthroughPage>
    with SingleTickerProviderStateMixin {
  int _index = 0;
  Rect? _targetRect;
  late final AnimationController _fadeCtrl;
  late final Animation<double> _fadeAnim;

  static const _purple = Color(0xFF6C63FF);
  static const _pink   = Color(0xFFFF6B8A);

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    WidgetsBinding.instance.addPostFrameCallback((_) => _updateTarget());
    _fadeCtrl.forward();
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    super.dispose();
  }

  void _updateTarget() {
    final step = widget.steps[_index];
    final ctx = step.targetKey.currentContext;
    if (ctx == null) {
      setState(() => _targetRect = null);
      return;
    }
    final box = ctx.findRenderObject() as RenderBox?;
    if (box == null) {
      setState(() => _targetRect = null);
      return;
    }
    final pos = box.localToGlobal(Offset.zero);
    setState(() {
      _targetRect = Rect.fromLTWH(pos.dx, pos.dy, box.size.width, box.size.height);
    });
  }

  Future<void> _next() async {
    if (_index < widget.steps.length - 1) {
      setState(() => _index++);
      WidgetsBinding.instance.addPostFrameCallback((_) => _updateTarget());
    } else {
      await _dismiss(complete: true);
    }
  }

  Future<void> _skip() => _dismiss(complete: true);

  Future<void> _dismiss({required bool complete}) async {
    await _fadeCtrl.reverse();
    if (complete) await widget.onComplete();
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final step = widget.steps[_index];
    return FadeTransition(
      opacity: _fadeAnim,
      child: Stack(
        children: [
          // Dim overlay with spotlight cutout
          CustomPaint(
            size: MediaQuery.of(context).size,
            painter: _SpotlightPainter(targetRect: _targetRect),
          ),
          // Tooltip card
          if (_targetRect != null)
            _buildTooltip(step)
          else
            _buildCentredTooltip(step),
          // Skip button top-right
          Positioned(
            top: MediaQuery.of(context).padding.top + 12,
            right: 16,
            child: GestureDetector(
              onTap: _skip,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'Skip',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                    fontFamily: 'DM Sans',
                  ),
                ),
              ),
            ),
          ),
          // Step counter bottom-left
          Positioned(
            bottom: MediaQuery.of(context).padding.bottom + 24,
            left: 20,
            child: Text(
              '${_index + 1} / ${widget.steps.length}',
              style: const TextStyle(
                color: Colors.white54,
                fontSize: 12,
                fontFamily: 'DM Sans',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTooltip(WalkthroughStep step) {
    final rect = _targetRect!;
    final screenH = MediaQuery.of(context).size.height;
    final screenW = MediaQuery.of(context).size.width;
    const cardW = 280.0;
    const cardPad = 16.0;

    double top;
    double left = (rect.left + rect.width / 2 - cardW / 2)
        .clamp(cardPad, screenW - cardW - cardPad);

    switch (step.position) {
      case WalkthroughPosition.below:
        top = (rect.bottom + 12).clamp(0, screenH - 160);
      case WalkthroughPosition.above:
        top = (rect.top - 140).clamp(0, screenH - 160);
      case WalkthroughPosition.left:
        top = rect.top;
        left = (rect.left - cardW - 12).clamp(cardPad, screenW - cardW - cardPad);
      case WalkthroughPosition.right:
        top = rect.top;
        left = (rect.right + 12).clamp(cardPad, screenW - cardW - cardPad);
    }

    return Positioned(
      top: top,
      left: left,
      width: cardW,
      child: _TooltipCard(
        step: step,
        isLast: _index == widget.steps.length - 1,
        onNext: _next,
        accent: _purple,
        accentButton: _pink,
      ),
    );
  }

  Widget _buildCentredTooltip(WalkthroughStep step) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: _TooltipCard(
          step: step,
          isLast: _index == widget.steps.length - 1,
          onNext: _next,
          accent: _purple,
          accentButton: _pink,
        ),
      ),
    );
  }
}

// ── Tooltip card ──────────────────────────────────────────────

class _TooltipCard extends StatelessWidget {
  final WalkthroughStep step;
  final bool isLast;
  final VoidCallback onNext;
  final Color accent;
  final Color accentButton;

  const _TooltipCard({
    required this.step,
    required this.isLast,
    required this.onNext,
    required this.accent,
    required this.accentButton,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
        decoration: BoxDecoration(
          color: const Color(0xFF1A0A2E),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: accent.withValues(alpha: 0.45)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.55),
              blurRadius: 20,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              step.title,
              style: const TextStyle(
                color: Color(0xFFF0D6FF),
                fontSize: 15,
                fontWeight: FontWeight.w700,
                fontFamily: 'DM Sans',
              ),
            ),
            const SizedBox(height: 6),
            Text(
              step.body,
              style: TextStyle(
                color: const Color(0xFFF0D6FF).withValues(alpha: 0.75),
                fontSize: 13,
                fontFamily: 'DM Sans',
                height: 1.5,
              ),
            ),
            const SizedBox(height: 14),
            Align(
              alignment: Alignment.centerRight,
              child: GestureDetector(
                onTap: onNext,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    color: accentButton.withValues(alpha: 0.20),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: accentButton.withValues(alpha: 0.50)),
                  ),
                  child: Text(
                    isLast ? 'Done ✓' : 'Next →',
                    style: TextStyle(
                      color: accentButton,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'DM Sans',
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Spotlight painter ─────────────────────────────────────────

class _SpotlightPainter extends CustomPainter {
  final Rect? targetRect;

  const _SpotlightPainter({this.targetRect});

  @override
  void paint(Canvas canvas, Size size) {
    final dimPaint = Paint()..color = Colors.black.withValues(alpha: 0.72);

    if (targetRect == null) {
      canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), dimPaint);
      return;
    }

    final padding = 8.0;
    final spotlight = targetRect!.inflate(padding);
    final rrect = RRect.fromRectAndRadius(spotlight, const Radius.circular(12));

    canvas.saveLayer(Rect.fromLTWH(0, 0, size.width, size.height), Paint());
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), dimPaint);
    canvas.drawRRect(
      rrect,
      Paint()
        ..blendMode = BlendMode.clear
        ..style = PaintingStyle.fill,
    );
    canvas.restore();

    // Spotlight border ring
    canvas.drawRRect(
      rrect,
      Paint()
        ..color = const Color(0xFF6C63FF).withValues(alpha: 0.80)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0,
    );
  }

  @override
  bool shouldRepaint(_SpotlightPainter old) => old.targetRect != targetRect;
}
