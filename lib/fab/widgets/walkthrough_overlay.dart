import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

// ─────────────────────────────────────────────────────────────
// WalkthroughOverlay
//
// Step-by-step spotlight walkthrough for child and parent sides.
// Each step highlights a target widget via GlobalKey cutout.
// Completion written to Hive box 'walkthrough' so it never
// repeats after first run. Steps can optionally show a character
// portrait (e.g. Eddie) beside the message, speech-bubble style.
//
// Usage:
//   await WalkthroughOverlay.showIfNeeded(context, WalkthroughType.child, steps);
//   await WalkthroughOverlay.showIfNeeded(context, WalkthroughType.parent, steps);
//   await WalkthroughOverlay.showIfNeeded(context, WalkthroughType.gardenTour, steps);
//
// Replay regardless of completion state (e.g. a settings "Replay tour" row):
//   await WalkthroughOverlay.replay(context, WalkthroughType.gardenTour, steps);
// ─────────────────────────────────────────────────────────────

enum WalkthroughType { child, parent, gardenTour }

enum WalkthroughPosition { above, below, left, right }

class WalkthroughStep {
  final GlobalKey targetKey;
  final String title;
  final String body;
  final WalkthroughPosition position;
  final String? characterAsset;

  const WalkthroughStep({
    required this.targetKey,
    required this.title,
    required this.body,
    this.position = WalkthroughPosition.below,
    this.characterAsset,
  });
}

class WalkthroughOverlay {
  static const _boxName = 'walkthrough';

  static String _completedKey(WalkthroughType type) => '${type.name}_complete';

  static Future<bool> isComplete(WalkthroughType type) async {
    final box = await Hive.openBox<bool>(_boxName);
    return box.get(_completedKey(type)) ?? false;
  }

  static Future<void> _markComplete(WalkthroughType type) async {
    final box = await Hive.openBox<bool>(_boxName);
    await box.put(_completedKey(type), true);
  }

  // Call this from the screen's initState (after first frame).
  // No-ops once this type has already been completed or skipped.
  static Future<void> showIfNeeded(
    BuildContext context,
    WalkthroughType type,
    List<WalkthroughStep> steps,
  ) async {
    if (await isComplete(type)) return;
    if (!context.mounted) return;
    await _show(context, type, steps);
  }

  // Replays a walkthrough on demand regardless of completion state --
  // for a "Replay tour" entry point. Does not affect the stored
  // completion flag beyond re-marking it complete on finish/skip.
  static Future<void> replay(
    BuildContext context,
    WalkthroughType type,
    List<WalkthroughStep> steps,
  ) async {
    if (!context.mounted) return;
    await _show(context, type, steps);
  }

  static Future<void> _show(
    BuildContext context,
    WalkthroughType type,
    List<WalkthroughStep> steps,
  ) {
    return Navigator.of(context).push<void>(
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
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  int _index = 0;
  Rect? _targetRect;
  Size? _lastViewportSize;
  int _targetUpdateGeneration = 0;
  late final AnimationController _fadeCtrl;
  late final Animation<double> _fadeAnim;

  static const _purple = Color(0xFF6C63FF);
  static const _pink = Color(0xFFFF6B8A);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _scheduleTargetUpdate(frames: 2);
    _fadeCtrl.forward();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _fadeCtrl.dispose();
    super.dispose();
  }

  @override
  void didChangeMetrics() {
    _scheduleTargetUpdate(frames: 6);
  }

  void _scheduleTargetUpdate({int frames = 1}) {
    final generation = ++_targetUpdateGeneration;

    void sampleAfterFrame(int remaining) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted || generation != _targetUpdateGeneration) return;
        _updateTarget();
        if (remaining > 1) sampleAfterFrame(remaining - 1);
      });
    }

    sampleAfterFrame(frames);
  }

  void _updateTarget() {
    final step = widget.steps[_index];
    final ctx = step.targetKey.currentContext;
    if (ctx == null) {
      if (mounted) setState(() => _targetRect = null);
      return;
    }
    final box = ctx.findRenderObject() as RenderBox?;
    if (box == null) {
      if (mounted) setState(() => _targetRect = null);
      return;
    }
    final pos = box.localToGlobal(Offset.zero);
    if (!mounted) return;
    setState(() {
      _targetRect = Rect.fromLTWH(
        pos.dx,
        pos.dy,
        box.size.width,
        box.size.height,
      );
    });
  }

  Future<void> _next() async {
    if (_index < widget.steps.length - 1) {
      setState(() => _index++);
      _scheduleTargetUpdate(frames: 2);
    } else {
      await _dismiss(complete: true);
    }
  }

  void _back() {
    if (_index == 0) return;
    setState(() => _index--);
    _scheduleTargetUpdate(frames: 2);
  }

  Future<void> _skip() => _dismiss(complete: true);

  Future<void> _exploreOnMyOwn() => _dismiss(complete: true);

  Future<void> _dismiss({required bool complete}) async {
    await _fadeCtrl.reverse();
    if (complete) await widget.onComplete();
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final viewportSize = MediaQuery.sizeOf(context);
    if (_lastViewportSize != viewportSize) {
      _lastViewportSize = viewportSize;
      _scheduleTargetUpdate(frames: 6);
    }

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
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
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
    final media = MediaQuery.of(context);
    final screenH = media.size.height;
    final screenW = media.size.width;
    const cardPad = 16.0;
    const gap = 12.0;
    final safeTop = media.padding.top + cardPad;
    final safeBottom = screenH - media.padding.bottom - cardPad;
    final cardW = screenW < 312 ? screenW - (cardPad * 2) : 280.0;
    final maxCardH = (safeBottom - safeTop).clamp(120.0, screenH);
    final estimatedCardH = _index > 0 ? 220.0 : 188.0;

    double left = (rect.left + rect.width / 2 - cardW / 2).clamp(
      cardPad,
      screenW - cardW - cardPad,
    );

    double fitVertical(double preferredTop) {
      final maxTop = (safeBottom - estimatedCardH).clamp(safeTop, safeBottom);
      return preferredTop.clamp(safeTop, maxTop);
    }

    double placeBelow() => fitVertical(rect.bottom + gap);
    double placeAbove() => fitVertical(rect.top - estimatedCardH - gap);

    double top;
    switch (step.position) {
      case WalkthroughPosition.below:
        final belowTop = rect.bottom + gap;
        top = belowTop + estimatedCardH <= safeBottom ? belowTop : placeAbove();
      case WalkthroughPosition.above:
        final aboveTop = rect.top - estimatedCardH - gap;
        top = aboveTop >= safeTop ? aboveTop : placeBelow();
      case WalkthroughPosition.left:
        top = fitVertical(rect.top);
        left = (rect.left - cardW - gap).clamp(
          cardPad,
          screenW - cardW - cardPad,
        );
      case WalkthroughPosition.right:
        top = fitVertical(rect.top);
        left = (rect.right + gap).clamp(cardPad, screenW - cardW - cardPad);
    }

    return Positioned(
      top: top,
      left: left,
      width: cardW,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: maxCardH),
        child: _TooltipCard(
          step: step,
          isLast: _index == widget.steps.length - 1,
          canGoBack: _index > 0,
          onBack: _back,
          onNext: _next,
          onExplore: _exploreOnMyOwn,
          accent: _purple,
          accentButton: _pink,
        ),
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
          canGoBack: _index > 0,
          onBack: _back,
          onNext: _next,
          onExplore: _exploreOnMyOwn,
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
  final bool canGoBack;
  final VoidCallback onBack;
  final VoidCallback onNext;
  final VoidCallback onExplore;
  final Color accent;
  final Color accentButton;

  const _TooltipCard({
    required this.step,
    required this.isLast,
    required this.canGoBack,
    required this.onBack,
    required this.onNext,
    required this.onExplore,
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
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (step.characterAsset != null) ...[
                  ClipOval(
                    child: Image.asset(
                      step.characterAsset!,
                      width: 36,
                      height: 36,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: 10),
                ],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        step.title,
                        style: const TextStyle(
                          color: Color(0xFFB39DDB),
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.2,
                          fontFamily: 'DM Sans',
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        step.body,
                        style: TextStyle(
                          color: const Color(
                            0xFFF0D6FF,
                          ).withValues(alpha: 0.90),
                          fontSize: 13,
                          fontFamily: 'DM Sans',
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.end,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                _WalkthroughAction(
                  label: 'Explore on my own',
                  onTap: onExplore,
                  foreground: const Color(0xFFF0D6FF).withValues(alpha: 0.78),
                  background: Colors.white.withValues(alpha: 0.06),
                  border: Colors.white.withValues(alpha: 0.14),
                ),
                if (canGoBack)
                  _WalkthroughAction(
                    label: 'Back',
                    onTap: onBack,
                    foreground: const Color(0xFFF0D6FF).withValues(alpha: 0.82),
                    background: accent.withValues(alpha: 0.12),
                    border: accent.withValues(alpha: 0.30),
                  ),
                _WalkthroughAction(
                  label: isLast ? 'Done ✓' : 'Next →',
                  onTap: onNext,
                  foreground: accentButton,
                  background: accentButton.withValues(alpha: 0.20),
                  border: accentButton.withValues(alpha: 0.50),
                  isPrimary: true,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _WalkthroughAction extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final Color foreground;
  final Color background;
  final Color border;
  final bool isPrimary;

  const _WalkthroughAction({
    required this.label,
    required this.onTap,
    required this.foreground,
    required this.background,
    required this.border,
    this.isPrimary = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: isPrimary ? 20 : 14,
          vertical: 10,
        ),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: border),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: foreground,
            fontSize: 13,
            fontWeight: isPrimary ? FontWeight.w700 : FontWeight.w600,
            fontFamily: 'DM Sans',
          ),
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
