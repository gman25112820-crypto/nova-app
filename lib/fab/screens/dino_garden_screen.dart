import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/fab_stars_service.dart';

// ─────────────────────────────────────────────────────────────
// DinoGardenScreen
//
// Full interactive experience layered over dino_garden_bg.png.
// Background image is the Nano Banana scene (waterfall, ferns,
// mushrooms, golden light, purple sky).
//
// Interactive elements — all Positioned over the image:
//   Characters : Ollie 🦕, Baby Tricer 🦏, Brachio 🦕, Ptero 🦅
//   Easter eggs: 3 dino eggs, fossil dig (3 taps), secret butterfly
//   Secret path: 5 taps → waterfall parts → Secret Grotto
//   Ambient    : fireflies, butterflies, falling leaves, light shimmer
//   UI         : back button, title pill, energy check-in, star toast
// ─────────────────────────────────────────────────────────────

class DinoGardenScreen extends StatefulWidget {
  const DinoGardenScreen({super.key});

  @override
  State<DinoGardenScreen> createState() => _DinoGardenScreenState();
}

class _DinoGardenScreenState extends State<DinoGardenScreen>
    with TickerProviderStateMixin {

  // ── Controllers ──────────────────────────────────────────────
  late final AnimationController _idleCtrl;       // 4 s ambient loop
  late final AnimationController _glowCtrl;       // 1.5 s glow pulse
  late final AnimationController _pteroWingCtrl;  // 0.4 s wing flutter
  late final AnimationController _pteroSwoopCtrl; // 3 s one-shot swoop
  late final AnimationController _secretBflyCtrl; // 10 s one-shot sweep
  late final AnimationController _fossilRevealCtrl; // 0.6 s reveal

  // ── Character state ───────────────────────────────────────────
  bool _ollieMessage = false;
  bool _tricerVisible = true;
  bool _brachioSurprised = false;
  bool _pteroSwooping = false;

  // ── Easter egg state ─────────────────────────────────────────
  int  _fossilTaps = 0;
  bool _fossilRevealed = false;
  String _fossilEmoji = '🦴';
  static const _fossilTypes = ['🦴', '🐚', '🌿', '🦕', '🦖', '🐾'];

  final _eggsCollected = [false, false, false];
  bool _allEggsToasted = false;

  int  _pathTaps = 0;
  bool _grottoOpen = false;

  bool _secretBflyVisible = false;
  Timer? _bflyTimer;

  bool _rareGoldenCollected = false;

  // ── Toast ─────────────────────────────────────────────────────
  String _toastMsg = '';
  int    _toastStars = 0;
  bool   _toastVisible = false;
  Timer? _toastTimer;

  // ── Energy picker ─────────────────────────────────────────────
  bool    _energyPickerVisible = false;
  String? _energyChoice;

  // ── Firefly / leaf bases ──────────────────────────────────────
  static const _fireflyBases = [
    (0.15, 0.42), (0.36, 0.60), (0.55, 0.38),
    (0.72, 0.54), (0.24, 0.70), (0.82, 0.33),
  ];
  static const _bflyBases = [
    (0.18, 0.28), (0.62, 0.24), (0.42, 0.48),
  ];
  static const _leafBaseX = [0.08, 0.28, 0.62, 0.88];

  @override
  void initState() {
    super.initState();

    _idleCtrl = AnimationController(vsync: this,
        duration: const Duration(seconds: 4))..repeat();

    _glowCtrl = AnimationController(vsync: this,
        duration: const Duration(milliseconds: 1500))..repeat(reverse: true);

    _pteroWingCtrl = AnimationController(vsync: this,
        duration: const Duration(milliseconds: 400))..repeat(reverse: true);

    _pteroSwoopCtrl = AnimationController(vsync: this,
        duration: const Duration(seconds: 3));

    _secretBflyCtrl = AnimationController(vsync: this,
        duration: const Duration(seconds: 10));

    _fossilRevealCtrl = AnimationController(vsync: this,
        duration: const Duration(milliseconds: 600));

    _loadState();
    _scheduleSecretButterfly();
  }

  @override
  void dispose() {
    _idleCtrl.dispose();
    _glowCtrl.dispose();
    _pteroWingCtrl.dispose();
    _pteroSwoopCtrl.dispose();
    _secretBflyCtrl.dispose();
    _fossilRevealCtrl.dispose();
    _bflyTimer?.cancel();
    _toastTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadState() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _rareGoldenCollected = prefs.getBool('dino_golden_fossil') ?? false;
      for (int i = 0; i < 3; i++) {
        _eggsCollected[i] = prefs.getBool('dino_egg_$i') ?? false;
      }
    });
  }

  void _scheduleSecretButterfly() {
    _bflyTimer = Timer.periodic(const Duration(seconds: 45), (_) {
      if (!mounted) return;
      setState(() => _secretBflyVisible = true);
      _secretBflyCtrl.forward(from: 0).then((_) {
        if (mounted) setState(() => _secretBflyVisible = false);
      });
    });
  }

  void _toast(String msg, int stars) {
    setState(() { _toastMsg = msg; _toastStars = stars; _toastVisible = true; });
    _toastTimer?.cancel();
    _toastTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) setState(() => _toastVisible = false);
    });
  }

  Future<void> _award(int stars, String label, String msg) async {
    if (stars > 0) await FabStarsService.awardForGame(stars, label);
    _toast(msg, stars);
  }

  // ── Character interactions ────────────────────────────────────

  Future<void> _tapOllie() async {
    if (_ollieMessage) return;
    setState(() => _ollieMessage = true);
    await _award(3, '🦕 Ollie', "You're doing great today! 🦕 +3 stars");
    await Future.delayed(const Duration(seconds: 3));
    if (mounted) setState(() => _ollieMessage = false);
  }

  void _tapTricer() {
    setState(() => _tricerVisible = false);
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _tricerVisible = true);
    });
  }

  void _tapBrachio() {
    if (_brachioSurprised) return;
    setState(() => _brachioSurprised = true);
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _brachioSurprised = false);
    });
  }

  void _tapPtero() {
    if (_pteroSwooping) return;
    setState(() => _pteroSwooping = true);
    _pteroSwoopCtrl.forward(from: 0).then((_) {
      if (mounted) setState(() => _pteroSwooping = false);
    });
  }

  // ── Easter eggs ───────────────────────────────────────────────

  Future<void> _tapFossil() async {
    if (_fossilRevealed) return;
    final newCount = _fossilTaps + 1;
    setState(() => _fossilTaps = newCount);

    if (newCount < 3) {
      _toast('Keep digging… ${3 - newCount} more tap${(3 - newCount) == 1 ? '' : 's'}', 0);
      return;
    }

    final emoji = _fossilTypes[Random().nextInt(_fossilTypes.length)];
    setState(() { _fossilRevealed = true; _fossilEmoji = emoji; });
    _fossilRevealCtrl.forward(from: 0);
    await _award(5, '🦴 Fossil', 'You found a fossil! $emoji +5 stars');

    await Future.delayed(const Duration(seconds: 4));
    if (mounted) {
      setState(() { _fossilRevealed = false; _fossilTaps = 0; });
      _fossilRevealCtrl.reset();
    }
  }

  Future<void> _tapEgg(int index) async {
    if (_eggsCollected[index]) return;
    final prefs = await SharedPreferences.getInstance();
    setState(() => _eggsCollected[index] = true);
    await prefs.setBool('dino_egg_$index', true);

    if (_eggsCollected.every((e) => e) && !_allEggsToasted) {
      setState(() => _allEggsToasted = true);
      await _award(10, '🥚 All Eggs', 'Dino egg hunter! 🥚 +10 stars!');
    } else if (!_eggsCollected.every((e) => e)) {
      _toast('Dino egg collected! 🥚', 0);
    }
  }

  void _tapPath() {
    final taps = _pathTaps + 1;
    setState(() => _pathTaps = taps);
    if (taps >= 5 && !_grottoOpen) {
      setState(() => _grottoOpen = true);
      _toast('The waterfall parts… something glows behind it ✨', 0);
    }
  }

  void _tapGrotto() {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (_, anim, __) => SecretGrottoScreen(
          alreadyCollected: _rareGoldenCollected,
          onGoldenFossilCollected: () async {
            final prefs = await SharedPreferences.getInstance();
            await prefs.setBool('dino_golden_fossil', true);
            if (mounted) setState(() => _rareGoldenCollected = true);
            await FabStarsService.awardForGame(20, '🌟 Golden Fossil');
          },
        ),
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
        transitionDuration: const Duration(milliseconds: 600),
      ),
    );
  }

  void _tapSecretButterfly() {
    if (!_secretBflyVisible) return;
    _secretBflyCtrl.stop();
    setState(() => _secretBflyVisible = false);
    _award(2, '🦋 Butterfly', 'You caught a butterfly! 🦋 +2 stars');
  }

  // ── Build ──────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A1A0F),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final w = constraints.maxWidth;
          final h = constraints.maxHeight;
          return Stack(
            clipBehavior: Clip.hardEdge,
            children: [
              // ── Background image ──────────────────────────────
              Positioned.fill(
                child: Image.asset(
                  'assets/images/dino_garden_bg.png',
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) =>
                      const _FallbackBg(),
                ),
              ),

              // ── Light ray shimmer ─────────────────────────────
              _lightShimmer(w, h),

              // ── Ambient fireflies (6) ─────────────────────────
              ..._fireflies(w, h),

              // ── Ambient butterflies (3) ───────────────────────
              ..._ambientButterflies(w, h),

              // ── Falling leaves (4) ────────────────────────────
              ..._fallingLeaves(w, h),

              // ── Dino eggs ─────────────────────────────────────
              ..._dinoEggs(w, h),

              // ── Fossil dig spot ───────────────────────────────
              _fossilSpot(w, h),

              // ── Stone path tap zone ───────────────────────────
              _stonePath(w, h),

              // ── Grotto entrance ───────────────────────────────
              if (_grottoOpen) _grottoEntrance(w, h),

              // ── Baby Triceratops ──────────────────────────────
              if (_tricerVisible) _tricer(w, h),

              // ── Baby Brachiosaurus ────────────────────────────
              _brachio(w, h),

              // ── Pterodactyl ───────────────────────────────────
              _ptero(w, h),

              // ── Ollie ─────────────────────────────────────────
              _ollie(w, h),

              // ── Ollie speech bubble ───────────────────────────
              if (_ollieMessage) _ollieBubble(w, h),

              // ── Secret butterfly ──────────────────────────────
              if (_secretBflyVisible) _secretButterfly(w, h),

              // ── UI layer ──────────────────────────────────────
              _backButton(),
              _titlePill(w),
              _energyBtn(w, h),
              if (_energyPickerVisible) _energyPicker(w, h),
              if (_toastVisible) _starsToast(w, h),
            ],
          );
        },
      ),
    );
  }

  // ── Ambient layers ────────────────────────────────────────────

  Widget _lightShimmer(double w, double h) {
    return AnimatedBuilder(
      animation: _glowCtrl,
      builder: (_, __) => Positioned(
        left: w * 0.28,
        top: 0,
        child: Transform.rotate(
          angle: pi / 5,
          child: Container(
            width: w * 0.22,
            height: h * 0.55,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.white.withValues(alpha: _glowCtrl.value * 0.11),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _fireflies(double w, double h) {
    return List.generate(6, (i) => AnimatedBuilder(
      animation: Listenable.merge([_idleCtrl, _glowCtrl]),
      builder: (_, __) {
        final phase = i * pi / 3.0;
        final t = _idleCtrl.value;
        final bx = _fireflyBases[i].$1 * w;
        final by = _fireflyBases[i].$2 * h;
        final dx = 20.0 * sin(t * 2 * pi + phase);
        final dy = 15.0 * cos(t * 2 * pi + phase * 1.3);
        final opacity = (0.35 + 0.65 * sin(t * 4 * pi + phase)).clamp(0.0, 1.0);
        return Positioned(
          left: bx + dx - 4,
          top: by + dy - 4,
          child: Opacity(
            opacity: opacity,
            child: Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFFFD700),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFFD700).withValues(alpha: opacity * 0.80),
                    blurRadius: 10,
                    spreadRadius: 3,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    ));
  }

  List<Widget> _ambientButterflies(double w, double h) {
    return List.generate(3, (i) => AnimatedBuilder(
      animation: _idleCtrl,
      builder: (_, __) {
        final phase = i * 2 * pi / 3.0;
        final t = _idleCtrl.value;
        final bx = _bflyBases[i].$1 * w;
        final by = _bflyBases[i].$2 * h;
        final dx = 38.0 * sin(t * pi + phase);
        final dy = 18.0 * cos(t * pi * 0.7 + phase);
        return Positioned(
          left: bx + dx,
          top: by + dy,
          child: const Text('🦋', style: TextStyle(fontSize: 18)),
        );
      },
    ));
  }

  List<Widget> _fallingLeaves(double w, double h) {
    return List.generate(4, (i) => AnimatedBuilder(
      animation: _idleCtrl,
      builder: (_, __) {
        final phase = i * 0.25;
        final t = (_idleCtrl.value + phase) % 1.0;
        final lx = _leafBaseX[i] * w + 28.0 * sin(t * 4 * pi + phase * 2);
        final ly = t * (h + 50) - 40;
        return Positioned(
          left: lx,
          top: ly,
          child: Opacity(
            opacity: (1.0 - t * 0.6).clamp(0.0, 1.0),
            child: const Text('🍃', style: TextStyle(fontSize: 15)),
          ),
        );
      },
    ));
  }

  // ── Easter egg widgets ────────────────────────────────────────

  List<Widget> _dinoEggs(double w, double h) {
    // Egg positions: left fern, mushroom cluster, stream edge
    final positions = [
      (0.12, 0.58), (0.48, 0.52), (0.38, 0.78),
    ];
    final accent = [
      const Color(0xFF4ECDC4),
      const Color(0xFFE91E8C),
      const Color(0xFF7B2FBE),
    ];

    return List.generate(3, (i) {
      if (_eggsCollected[i]) return const SizedBox.shrink();
      return AnimatedBuilder(
        animation: _glowCtrl,
        builder: (_, __) => Positioned(
          left: positions[i].$1 * w - 16,
          top: positions[i].$2 * h - 16,
          child: GestureDetector(
            onTap: () => _tapEgg(i),
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: accent[i].withValues(alpha: 0.15),
                boxShadow: [
                  BoxShadow(
                    color: accent[i].withValues(alpha: 0.40 + 0.30 * _glowCtrl.value),
                    blurRadius: 12 + 6 * _glowCtrl.value,
                    spreadRadius: 3,
                  ),
                ],
              ),
              child: const Center(
                child: Text('🥚', style: TextStyle(fontSize: 18)),
              ),
            ),
          ),
        ),
      );
    });
  }

  Widget _fossilSpot(double w, double h) {
    return Positioned(
      left: w * 0.76 - 28,
      top: h * 0.80 - 16,
      child: GestureDetector(
        onTap: _tapFossil,
        child: SizedBox(
          width: 56,
          height: 32,
          child: _fossilRevealed
              ? ScaleTransition(
                  scale: CurvedAnimation(
                    parent: _fossilRevealCtrl,
                    curve: Curves.elasticOut,
                  ),
                  child: Text(
                    _fossilEmoji,
                    style: const TextStyle(fontSize: 36),
                  ),
                )
              : Container(
                  decoration: BoxDecoration(
                    color: Colors.brown.withValues(alpha: 0.30),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Colors.brown.withValues(alpha: 0.15),
                    ),
                  ),
                ),
        ),
      ),
    );
  }

  Widget _stonePath(double w, double h) {
    return Positioned(
      left: w * 0.38,
      top: h * 0.88,
      width: w * 0.24,
      height: h * 0.12,
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: _tapPath,
        child: const SizedBox.expand(),
      ),
    );
  }

  Widget _grottoEntrance(double w, double h) {
    return AnimatedBuilder(
      animation: _glowCtrl,
      builder: (_, __) => Positioned(
        left: w * 0.42 - 20,
        top: h * 0.28,
        child: GestureDetector(
          onTap: _tapGrotto,
          child: Container(
            width: 40,
            height: 60,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: RadialGradient(
                colors: [
                  const Color(0xFF7B2FBE).withValues(alpha: 0.55 + 0.25 * _glowCtrl.value),
                  const Color(0xFF7B2FBE).withValues(alpha: 0),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF7B2FBE).withValues(alpha: 0.60 + 0.25 * _glowCtrl.value),
                  blurRadius: 20,
                  spreadRadius: 4,
                ),
              ],
            ),
            child: const Center(
              child: Text('✨', style: TextStyle(fontSize: 20)),
            ),
          ),
        ),
      ),
    );
  }

  // ── Characters ────────────────────────────────────────────────

  Widget _tricer(double w, double h) {
    // Peek from behind left-side fern — clip so only horns + head show
    return Positioned(
      left: w * 0.03,
      top: h * 0.58,
      child: GestureDetector(
        onTap: _tapTricer,
        child: ClipRect(
          child: Align(
            alignment: Alignment.topCenter,
            heightFactor: 0.60,
            child: Text(
              '🦏',
              style: TextStyle(fontSize: 54 * (w / 430).clamp(0.75, 1.2)),
            ),
          ),
        ),
      ),
    );
  }

  Widget _brachio(double w, double h) {
    // Neck emerges from right treeline — clip bottom so body stays hidden
    return AnimatedBuilder(
      animation: _idleCtrl,
      builder: (_, __) {
        final sway = 0.03 * sin(_idleCtrl.value * 2 * pi);
        return Positioned(
          right: w * 0.01,
          top: h * 0.16,
          child: GestureDetector(
            onTap: _tapBrachio,
            child: Transform.rotate(
              alignment: Alignment.topCenter,
              angle: sway,
              child: ClipRect(
                child: Align(
                  alignment: Alignment.topCenter,
                  heightFactor: 0.72,
                  child: Text(
                    _brachioSurprised ? '😲' : '🦕',
                    style: TextStyle(fontSize: 68 * (w / 430).clamp(0.75, 1.2)),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _ptero(double w, double h) {
    // Perched in upper canopy — weight-shift when idle, swoops on tap
    return AnimatedBuilder(
      animation: Listenable.merge([_pteroWingCtrl, _pteroSwoopCtrl]),
      builder: (_, __) {
        double left = w * 0.55;
        double top  = h * 0.05;

        if (_pteroSwooping) {
          final t = _pteroSwoopCtrl.value;
          final swt = t < 0.5 ? t * 2 : (1 - t) * 2;
          final curve = Curves.easeInOut.transform(swt);
          left = w * 0.55 - curve * w * 0.44;
          top  = h * 0.05 + curve * h * 0.36;
        }

        // Perch: subtle vertical weight-shift, anchored at feet
        final perchScale = 0.94 + 0.06 * _pteroWingCtrl.value;
        return Positioned(
          left: left,
          top:  top,
          child: GestureDetector(
            onTap: _tapPtero,
            child: Transform(
              alignment: Alignment.bottomCenter,
              transform: Matrix4.diagonal3Values(1.0, perchScale, 1.0),
              child: Text(
                '🦅',
                style: TextStyle(fontSize: 44 * (w / 430).clamp(0.75, 1.2)),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _ollie(double w, double h) {
    // On the riverbank — large, centred, gentle breathing bounce
    return AnimatedBuilder(
      animation: _idleCtrl,
      builder: (_, __) {
        final bounce = 3.0 * sin(_idleCtrl.value * 2 * pi);
        final size = 80.0 * (w / 430).clamp(0.75, 1.2);
        return Positioned(
          left: w * 0.22,
          top:  h * 0.63 + bounce,
          child: GestureDetector(
            onTap: _tapOllie,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('🦕', style: TextStyle(fontSize: size)),
                // Ground shadow — makes him feel planted on the bank
                Container(
                  width: size * 0.72,
                  height: 6,
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.22),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _ollieBubble(double w, double h) {
    return Positioned(
      left: w * 0.08,
      top: h * 0.47,
      right: w * 0.08,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFF1A0A2E).withValues(alpha: 0.92),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFF4ECDC4).withValues(alpha: 0.50),
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF4ECDC4).withValues(alpha: 0.25),
              blurRadius: 16,
            ),
          ],
        ),
        child: const Text(
          "You're doing great today! 🦕",
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Color(0xFFF0D6FF),
            fontSize: 14,
            fontWeight: FontWeight.w600,
            height: 1.4,
          ),
        ),
      ),
    );
  }

  Widget _secretButterfly(double w, double h) {
    return AnimatedBuilder(
      animation: _secretBflyCtrl,
      builder: (_, __) {
        final t = _secretBflyCtrl.value;
        final bx = -60 + t * (w + 120);
        final by = h * 0.32 + 32 * sin(t * 4 * pi);
        return Positioned(
          left: bx,
          top: by,
          child: GestureDetector(
            onTap: _tapSecretButterfly,
            child: const Text('🦋', style: TextStyle(fontSize: 30)),
          ),
        );
      },
    );
  }

  // ── UI elements ───────────────────────────────────────────────

  Widget _backButton() {
    return Positioned(
      top: 44,
      left: 12,
      child: SafeArea(
        child: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFF2D1556).withValues(alpha: 0.72),
              shape: BoxShape.circle,
              boxShadow: const [
                BoxShadow(color: Colors.black26, blurRadius: 8),
              ],
            ),
            child: const Icon(
              Icons.arrow_back_rounded,
              color: Color(0xFFF0D6FF),
              size: 20,
            ),
          ),
        ),
      ),
    );
  }

  Widget _titlePill(double w) {
    return Positioned(
      top: 44,
      left: 0,
      right: 0,
      child: SafeArea(
        child: Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
            decoration: BoxDecoration(
              color: const Color(0xFF0A1A0F).withValues(alpha: 0.75),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: const Color(0xFF4CAF50).withValues(alpha: 0.40),
              ),
            ),
            child: const Text(
              'Dino Garden 🦕',
              style: TextStyle(
                color: Color(0xFFF0D6FF),
                fontSize: 14,
                fontWeight: FontWeight.w700,
                fontFamily: 'DM Sans',
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _energyBtn(double w, double h) {
    return Positioned(
      bottom: 28,
      right: 16,
      child: GestureDetector(
        onTap: () => setState(() => _energyPickerVisible = !_energyPickerVisible),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xFF0A2E12).withValues(alpha: 0.88),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: const Color(0xFF4CAF50).withValues(alpha: 0.50),
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF4CAF50).withValues(alpha: 0.20),
                blurRadius: 10,
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('🦕', style: TextStyle(fontSize: 16)),
              const SizedBox(width: 6),
              Text(
                _energyChoice != null
                    ? _energyChoice!
                    : "How's your energy?",
                style: const TextStyle(
                  color: Color(0xFFF0D6FF),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _energyPicker(double w, double h) {
    const opts = [
      ('🦖', 'Roaring!', 'Lots of energy'),
      ('🦕', 'Okay', 'Medium energy'),
      ('💤', 'Sleepy', 'Low energy'),
    ];
    return Positioned(
      bottom: 80,
      right: 16,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF0A1A0F).withValues(alpha: 0.92),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFF4CAF50).withValues(alpha: 0.40),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: opts.map((o) => GestureDetector(
            onTap: () async {
              setState(() {
                _energyChoice = '${o.$1} ${o.$2}';
                _energyPickerVisible = false;
              });
              final prefs = await SharedPreferences.getInstance();
              await prefs.setString(
                'dino_energy_${DateTime.now().toIso8601String().substring(0, 10)}',
                o.$2,
              );
              _toast('Energy: ${o.$2} noted! 🦕', 0);
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(o.$1, style: const TextStyle(fontSize: 22)),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(o.$2, style: const TextStyle(
                        color: Color(0xFFF0D6FF),
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      )),
                      Text(o.$3, style: const TextStyle(
                        color: Color(0xFF9D7ABF),
                        fontSize: 11,
                      )),
                    ],
                  ),
                ],
              ),
            ),
          )).toList(),
        ),
      ),
    );
  }

  Widget _starsToast(double w, double h) {
    return Positioned(
      bottom: 110,
      left: w * 0.12,
      right: w * 0.12,
      child: AnimatedOpacity(
        opacity: _toastVisible ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 300),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xFF1A0A2E).withValues(alpha: 0.94),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: const Color(0xFF4CAF50).withValues(alpha: 0.40),
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF4CAF50).withValues(alpha: 0.25),
                blurRadius: 16,
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_toastStars > 0) ...[
                Text(
                  '+$_toastStars ⭐',
                  style: const TextStyle(
                    color: Color(0xFFFFD700),
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(width: 8),
              ],
              Flexible(
                child: Text(
                  _toastMsg,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color(0xFFF0D6FF),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
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

// ─────────────────────────────────────────────────────────────
// Fallback background (shown when image asset is missing)
// ─────────────────────────────────────────────────────────────

class _FallbackBg extends StatelessWidget {
  const _FallbackBg();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF2A4A1A), Color(0xFF1A3A0A), Color(0xFF0A1A08)],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Secret Grotto Screen
//
// A hidden cave behind the Dino Garden waterfall.
// Accessible only after tapping the stone path 5 times.
// Contains Ollie's secret message, a sleeping baby dino,
// and a one-time Golden Fossil worth 20 Fab Stars.
// Never hinted at anywhere in the app.
// ─────────────────────────────────────────────────────────────

class SecretGrottoScreen extends StatefulWidget {
  final bool alreadyCollected;
  final Future<void> Function() onGoldenFossilCollected;

  const SecretGrottoScreen({
    super.key,
    required this.alreadyCollected,
    required this.onGoldenFossilCollected,
  });

  @override
  State<SecretGrottoScreen> createState() => _SecretGrottoScreenState();
}

class _SecretGrottoScreenState extends State<SecretGrottoScreen>
    with SingleTickerProviderStateMixin {

  late final AnimationController _glowCtrl;
  bool _fossilCollected = false;
  bool _messageVisible = false;
  bool _collectingFossil = false;

  @override
  void initState() {
    super.initState();
    _glowCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
    _fossilCollected = widget.alreadyCollected;

    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) setState(() => _messageVisible = true);
    });
  }

  @override
  void dispose() {
    _glowCtrl.dispose();
    super.dispose();
  }

  Future<void> _collectGoldenFossil() async {
    if (_fossilCollected || _collectingFossil) return;
    setState(() => _collectingFossil = true);
    await widget.onGoldenFossilCollected();
    if (mounted) setState(() { _fossilCollected = true; _collectingFossil = false; });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final w = constraints.maxWidth;
          final h = constraints.maxHeight;
          return Stack(
            children: [
              // ── Cave background ─────────────────────────────
              Positioned.fill(
                child: AnimatedBuilder(
                  animation: _glowCtrl,
                  builder: (_, __) => Container(
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        center: const Alignment(-0.1, 0.0),
                        radius: 0.80,
                        colors: [
                          const Color(0xFF120A28).withValues(alpha: 1.0),
                          const Color(0xFF020308),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // ── Purple ambient glow ─────────────────────────
              AnimatedBuilder(
                animation: _glowCtrl,
                builder: (_, __) => Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        center: Alignment.center,
                        radius: 0.65,
                        colors: [
                          const Color(0xFF7B2FBE).withValues(alpha: 0.12 + 0.08 * _glowCtrl.value),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // ── Crystal formations ──────────────────────────
              ..._buildCrystals(w, h),

              // ── Drip particles ──────────────────────────────
              ..._buildDrips(w, h),

              // ── Sleeping baby dino ──────────────────────────
              Positioned(
                left: w * 0.50 - 40,
                top: h * 0.52,
                child: AnimatedBuilder(
                  animation: _glowCtrl,
                  builder: (_, __) => Transform.scale(
                    scale: 0.95 + 0.05 * _glowCtrl.value,
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1A0A2E).withValues(alpha: 0.60),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text('💤',
                              style: TextStyle(fontSize: 14)),
                        ),
                        const SizedBox(height: 4),
                        const Text('🦕', style: TextStyle(fontSize: 52)),
                      ],
                    ),
                  ),
                ),
              ),

              // ── Ollie's message ─────────────────────────────
              if (_messageVisible)
                Positioned(
                  top: h * 0.12,
                  left: 20,
                  right: 20,
                  child: AnimatedOpacity(
                    opacity: 1.0,
                    duration: const Duration(milliseconds: 700),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1A0A2E).withValues(alpha: 0.92),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: const Color(0xFF7B2FBE).withValues(alpha: 0.50),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF7B2FBE).withValues(alpha: 0.28),
                            blurRadius: 24,
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(children: [
                            const Text('🦕',
                                style: TextStyle(fontSize: 22)),
                            const SizedBox(width: 8),
                            const Text(
                              'Ollie',
                              style: TextStyle(
                                color: Color(0xFF4ECDC4),
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ]),
                          const SizedBox(height: 10),
                          const Text(
                            'You found my secret place 🌟\n\nNot many people know about this.\nThis little one loves to nap here after\na long day in the garden.',
                            style: TextStyle(
                              color: Color(0xFFF0D6FF),
                              fontSize: 14,
                              height: 1.55,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

              // ── Golden fossil ───────────────────────────────
              if (!_fossilCollected)
                Positioned(
                  bottom: h * 0.10,
                  left: w * 0.50 - 36,
                  child: AnimatedBuilder(
                    animation: _glowCtrl,
                    builder: (_, __) => GestureDetector(
                      onTap: _collectGoldenFossil,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 72,
                            height: 72,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: const Color(0xFFFFD700).withValues(alpha: 0.12),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFFFFD700).withValues(
                                    alpha: 0.45 + 0.30 * _glowCtrl.value,
                                  ),
                                  blurRadius: 20 + 10 * _glowCtrl.value,
                                  spreadRadius: 4,
                                ),
                              ],
                            ),
                            child: const Center(
                              child: Text('🦴',
                                  style: TextStyle(fontSize: 38)),
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Golden Fossil  ✨  tap to collect',
                            style: TextStyle(
                              color: Color(0xFFFFD700),
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

              // ── Fossil collected state ──────────────────────
              if (_fossilCollected)
                Positioned(
                  bottom: h * 0.12,
                  left: 20,
                  right: 20,
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 18, vertical: 10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1A0A2E).withValues(alpha: 0.90),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: const Color(0xFFFFD700).withValues(alpha: 0.50),
                        ),
                      ),
                      child: Text(
                        widget.alreadyCollected
                            ? 'You already found the golden fossil 🌟'
                            : '⭐ +20 Fab Stars!  Golden fossil collected! 🌟',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Color(0xFFFFD700),
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),

              // ── Back button ─────────────────────────────────
              Positioned(
                top: 44,
                left: 12,
                child: SafeArea(
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: const Color(0xFF2D1556).withValues(alpha: 0.72),
                        shape: BoxShape.circle,
                        boxShadow: const [
                          BoxShadow(color: Colors.black38, blurRadius: 8),
                        ],
                      ),
                      child: const Icon(
                        Icons.arrow_back_rounded,
                        color: Color(0xFFF0D6FF),
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ),

              // ── Title ───────────────────────────────────────
              Positioned(
                top: 44,
                left: 0,
                right: 0,
                child: SafeArea(
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 7),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0A0318).withValues(alpha: 0.80),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: const Color(0xFF7B2FBE).withValues(alpha: 0.40),
                        ),
                      ),
                      child: const Text(
                        '✨  Secret Grotto',
                        style: TextStyle(
                          color: Color(0xFFF0D6FF),
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  List<Widget> _buildCrystals(double w, double h) {
    final defs = [
      (0.08, 0.72, 0.07, const Color(0xFF7B2FBE)),
      (0.22, 0.78, 0.05, const Color(0xFF4ECDC4)),
      (0.68, 0.68, 0.08, const Color(0xFF7B2FBE)),
      (0.82, 0.74, 0.06, const Color(0xFFE91E8C)),
      (0.42, 0.88, 0.04, const Color(0xFF4ECDC4)),
      (0.55, 0.75, 0.05, const Color(0xFF7B2FBE)),
    ];
    return defs.map((d) => AnimatedBuilder(
      animation: _glowCtrl,
      builder: (_, __) => Positioned(
        left: d.$1 * w,
        top: d.$2 * h,
        child: Container(
          width: d.$3 * w,
          height: d.$3 * w * 2.0,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                d.$4.withValues(alpha: 0.55 + 0.25 * _glowCtrl.value),
                d.$4.withValues(alpha: 0.05),
              ],
            ),
            borderRadius: const BorderRadius.vertical(
              top: Radius.elliptical(5, 12),
            ),
          ),
        ),
      ),
    )).toList();
  }

  List<Widget> _buildDrips(double w, double h) {
    // Simple animated drip dots on the cave walls
    return List.generate(4, (i) => AnimatedBuilder(
      animation: _glowCtrl,
      builder: (_, __) {
        final phase = i * 0.25;
        final t = (_glowCtrl.value + phase) % 1.0;
        return Positioned(
          left: [0.05, 0.88, 0.20, 0.75][i] * w,
          top: h * 0.30 + t * h * 0.20,
          child: Container(
            width: 4,
            height: 4,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF4ECDC4).withValues(alpha: 0.50 * t),
            ),
          ),
        );
      },
    ));
  }
}
