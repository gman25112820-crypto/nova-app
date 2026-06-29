import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../screens/cooking_screen.dart';
import '../screens/duck_shop_screen.dart';
import '../screens/fab_brilliant_screen.dart';
import '../screens/fab_check_in_screen.dart';
import '../screens/fab_settings_screen.dart';
import '../screens/pain_screen.dart';
import '../screens/parent_pin_gate.dart';
import '../screens/recovery_screen.dart';
import '../screens/energy_screen.dart';
import '../screens/mood_screen.dart';
import '../screens/sleep_screen.dart';
import '../screens/house_interior_screen.dart';
import '../models/child_profile.dart';
import '../services/selected_child_service.dart';
import '../services/companion_service.dart';
import '../services/fab_stars_service.dart';
import '../widgets/chicken_lips_companion.dart';
import '../screens/dino_garden_screen.dart';
import '../screens/calm_lagoon_screen.dart';
import '../widgets/fab_world_scene.dart';
import '../widgets/fab_world_audio.dart';
import '../widgets/fab_world_theme.dart';
import '../screens/shared_garden_screen.dart';
import '../screens/sleep_nest_screen.dart';
import '../screens/safe_corner_living_room.dart';

// ─────────────────────────────────────────────────────────────
// FAB HOME SCREEN v5.0
// Visual overhaul: zone cards, glowing moods, warm palette,
// styled nav bar with active pill, zone fade+scale transitions.
// ─────────────────────────────────────────────────────────────

const bool kShowCompanion = false;
const bool kShowOldHouses = false;

class FabHomeScreen extends StatefulWidget {
  const FabHomeScreen({super.key});

  @override
  State<FabHomeScreen> createState() => _FabHomeScreenState();
}

class _FabHomeScreenState extends State<FabHomeScreen>
    with SingleTickerProviderStateMixin {
  late final FabWorldAudio _audio;
  late final FabWorldTheme _theme;
  bool _audioReady  = false;
  int  _starBalance = 0;
  bool _panelOpen   = false;

  // ── World scene glow + interactions ─────────────────────────
  final _worldSceneKey = GlobalKey();
  late AnimationController _glowCtrl;

  // ── Companion ────────────────────────────────────────────────
  CompanionGreeting? _companionGreeting;

  // ── Mood state ───────────────────────────────────────────────
  String? _selectedMood;
  static const _moods      = ['😄', '🙂', '😐', '😟', '😣'];
  static const _moodLabels = ['Great', 'Good', 'Okay', 'Low', 'Rough'];
  static const _moodColors = [
    Color(0xFFFFD700),  // Great — gold
    Color(0xFF4CAF50),  // Good — green
    Color(0xFF4ECDC4),  // Okay — teal
    Color(0xFFFFB830),  // Low — amber
    Color(0xFFE91E8C),  // Rough — pink-red
  ];

  // ── Palette ──────────────────────────────────────────────────
  static const _bgMid    = Color(0xFF1A0A2E);
  static const _card     = Color(0xFF2D1556);
  static const _purple   = Color(0xFF7B2FBE);
  static const _pink     = Color(0xFFE91E8C);
  static const _textPri  = Color(0xFFF0D6FF);
  static const _textSec  = Color(0xFF9D7ABF);

  @override
  void initState() {
    super.initState();
    _theme      = FabWorldTheme.fromCalendar();
    _audio      = FabWorldAudio();
    _initAudio();
    _loadMood();
    _loadStars();
    _loadCompanion();
    _glowCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
  }

  Future<void> _loadStars() async {
    final balance = await FabStarsService.getBalance();
    if (mounted) setState(() => _starBalance = balance);
  }

  Future<void> _loadCompanion() async {
    final greeting = await CompanionService.load();
    if (mounted) setState(() => _companionGreeting = greeting);
  }

  Future<void> _initAudio() async {
    await _audio.init(_theme);
    if (mounted) setState(() => _audioReady = true);
  }

  Future<void> _loadMood() async {
    final child = SelectedChildService.current ?? SelectedChildService.selectDefault();
    if (child == null) return;
    final today = DateTime.now().toIso8601String().substring(0, 10);
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString('${child.id}_mood_today_$today');
    if (saved != null && mounted) setState(() => _selectedMood = saved);
  }

  Future<void> _saveMood(String mood) async {
    final child = SelectedChildService.current ?? SelectedChildService.selectDefault();
    if (child != null) {
      final today = DateTime.now().toIso8601String().substring(0, 10);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('${child.id}_mood_today_$today', mood);
    }
    setState(() => _selectedMood = mood);
  }

  Color? get _moodTint {
    switch (_selectedMood) {
      case '😄': return const Color(0x55FFD27F); // Great — warm gold, gentle
      case '🙂': return const Color(0x44FFE0A3); // Good — soft warm, lighter
      case '😐': return null;                     // Okay — scene as-is (baseline)
      case '😟': return const Color(0x77FFA664); // Low — warm amber, cosy lamplight
      case '😣': return const Color(0x99FF9B57); // Rough — deeper warm amber, tucked-in
      default:   return null;
    }
  }

  @override
  void dispose() {
    _glowCtrl.dispose();
    _audio.dispose();
    super.dispose();
  }



  void _onMoonTap() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('🌙✨ The moon glows just for you!',
            style: TextStyle(fontFamily: 'DM Sans')),
        duration: Duration(seconds: 2),
        backgroundColor: Color(0xFF2D1556),
      ),
    );
  }

  void _onChimneyTap() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('🍪 Something smells delicious from the chimney…',
            style: TextStyle(fontFamily: 'DM Sans')),
        duration: Duration(seconds: 2),
        backgroundColor: Color(0xFF2D1556),
      ),
    );
  }

  void _onFireflyTap() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('✨ A firefly flickered hello!',
            style: TextStyle(fontFamily: 'DM Sans')),
        duration: Duration(seconds: 2),
        backgroundColor: Color(0xFF2D1556),
      ),
    );
  }

  void _onPathLongPress() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('🌿 The stone path leads somewhere magical…',
            style: TextStyle(fontFamily: 'DM Sans')),
        duration: Duration(seconds: 2),
        backgroundColor: Color(0xFF2D1556),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0820),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final screenH = constraints.maxHeight;
            final panelH  = _panelOpen ? screenH * 0.50 : 40.0;
            return Stack(
              children: [
                _buildWorldScene(screenH),
                Positioned(
                  left: 0, right: 0, bottom: 0,
                  child: _buildPanel(panelH),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  // ── Tap-to-toggle animated panel ─────────────────────────────
  Widget _buildPanel(double panelH) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
      height: panelH,
      clipBehavior: Clip.hardEdge,
      decoration: const BoxDecoration(
        color: _bgMid,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(color: Colors.black54, blurRadius: 20, offset: Offset(0, -4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header: tap pill to open, tap ↓ to close; skeleton key always visible.
          // MouseRegion forces web pointer recognition; outer GestureDetector +
          // inner InkWell ensure at least one fires on CanvasKit.
          MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => setState(() => _panelOpen = !_panelOpen),
              child: SizedBox(
                height: 40,
                child: Row(
                  children: [
                    Expanded(
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () => setState(() => _panelOpen = !_panelOpen),
                          child: Center(
                            child: _panelOpen
                                ? const Icon(Icons.keyboard_arrow_down_rounded,
                                    color: Colors.white54, size: 28)
                                : Container(
                                    width: 36, height: 4,
                                    decoration: BoxDecoration(
                                      color: Colors.white30,
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                  ),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 14),
                      child: GestureDetector(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const ParentPinGate()),
                        ),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.vpn_key_rounded,
                              color: Colors.white54, size: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Scrollable content — only visible when panel is open
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildGreetingCard(),
                  _buildMoodRow(),
                  _buildSleepBar(),
                  _buildCheckInCard(),
                  _FeelingFabHub(
                    onNavigate: (screen) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => screen),
                      ).then((_) => _loadStars());
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Top bar ──────────────────────────────────────────────────
  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 12, 0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: _purple.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: _purple.withValues(alpha: 0.35)),
            ),
            child: const Text(
              'NOVA',
              style: TextStyle(
                color: _purple,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.5,
                fontFamily: 'DM Sans',
              ),
            ),
          ),
          const SizedBox(width: 10),
          const Flexible(
            child: Text(
              'Fabulously Me',
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: _textPri,
                fontSize: 16,
                fontWeight: FontWeight.w600,
                fontFamily: 'DM Sans',
              ),
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const DuckShopScreen()),
            ).then((_) => _loadStars()),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFFFD700).withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFFFD700).withValues(alpha: 0.35)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('⭐', style: TextStyle(fontSize: 12)),
                  const SizedBox(width: 4),
                  Text(
                    '$_starBalance',
                    style: const TextStyle(
                      color: Color(0xFFFFD700),
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      fontFamily: 'DM Sans',
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: _card.withValues(alpha: 0.60),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              _seasonEmoji(_theme.season),
              style: const TextStyle(fontSize: 14),
            ),
          ),
          const SizedBox(width: 6),
          if (_audioReady) FabMuteButton(audio: _audio),
          GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const FabSettingsScreen()),
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white12),
              ),
              child: const Icon(Icons.settings_outlined, color: _textSec, size: 16),
            ),
          ),
          const SizedBox(width: 6),
          GestureDetector(
            onTap: () => _showFeelingFabHub(),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: _pink.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: _pink.withValues(alpha: 0.35)),
              ),
              child: const Text(
                '+ Feeling Fab',
                style: TextStyle(
                  color: _pink,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'DM Sans',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _seasonEmoji(FabSeason season) {
    switch (season) {
      case FabSeason.spring: return '🌸';
      case FabSeason.summer: return '☀️';
      case FabSeason.autumn: return '🍂';
      case FabSeason.winter: return '❄️';
    }
  }

  // ── Greeting card ────────────────────────────────────────────
  Widget _buildGreetingCard() {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 8, 12, 0),
      padding: const EdgeInsets.fromLTRB(14, 12, 12, 12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF2D1556), Color(0xFF1A0A2E)],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _purple.withValues(alpha: 0.35)),
        boxShadow: [
          BoxShadow(
            color: _purple.withValues(alpha: 0.20),
            blurRadius: 18,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Nurse Chicken Lips avatar with glow
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _pink.withValues(alpha: 0.12),
              boxShadow: [
                BoxShadow(
                  color: _pink.withValues(alpha: 0.30),
                  blurRadius: 16,
                  spreadRadius: 2,
                ),
              ],
              border: Border.all(color: _pink.withValues(alpha: 0.35), width: 1.5),
            ),
            child: ClipOval(
              child: Image.asset(
                'assets/images/characters/chicken_lips.png',
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  kCompanionName,
                  style: TextStyle(
                    color: _pink,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'DM Sans',
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  _greetingText(),
                  style: const TextStyle(
                    color: Color(0xFFC0A0E0),
                    fontSize: 12,
                    fontFamily: 'DM Sans',
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          if (_selectedMood != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(_selectedMood!, style: const TextStyle(fontSize: 20)),
            ),
        ],
      ),
    );
  }

  String _greetingText() {
    if (_companionGreeting != null) return _companionGreeting!.text;
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning! How are we feeling?';
    if (hour < 17) return 'Good afternoon! Ready to check in?';
    return 'Good evening! How has the day been?';
  }

  // ── World scene ──────────────────────────────────────────────
  Widget _buildWorldScene(double height,
      {Alignment sceneAlignment = Alignment.topCenter}) {
    return SizedBox(
      height: height,
      child: Padding(
        padding: const EdgeInsets.only(top: 4, bottom: 40), // collapsed panel height
        child: LayoutBuilder(
          builder: (context, constraints) {
            final w = constraints.maxWidth;
            final h = constraints.maxHeight;
            // Ground line matches FabWorldPainter: gY = h * 0.78
            final gY = h * 0.78;

            return Stack(
              clipBehavior: Clip.hardEdge,
              children: [

                // ── Animated scene content ──────────────────────
                Positioned.fill(
                  child: AnimatedBuilder(
                    animation: _glowCtrl,
                    builder: (_, __) {
                      final glow = _glowCtrl.value; // 0..1
                      return Stack(
                        clipBehavior: Clip.none,
                        children: [

                          // ── Background scene ──────────────────
                          Positioned.fill(
                            child: FabWorldScene(
                              key: _worldSceneKey,
                              audio: _audioReady ? _audio : null,
                              alignment: sceneAlignment,
                              moodTint: _moodTint,
                            ),
                          ),

                          // ── Companion greeting ─────────────────
                          if (kShowCompanion && _companionGreeting != null)
                            Positioned(
                              left: 6,
                              bottom: h * 0.10,
                              child: ChickenLipsCompanion(greeting: _companionGreeting!),
                            ),

                          // ══════════════════════════════════════
                          // EASTER EGGS
                          // ══════════════════════════════════════

                          // Moon / stars — top-right
                          Positioned(
                            left: w * 0.70,
                            top: 0,
                            width: w * 0.30,
                            height: h * 0.26,
                            child: GestureDetector(
                              behavior: HitTestBehavior.translucent,
                              onTap: _onMoonTap,
                            ),
                          ),

                          // Chimney — top-left above chicken house roof
                          Positioned(
                            left: w * 0.14,
                            top: 0,
                            width: w * 0.18,
                            height: h * 0.24,
                            child: GestureDetector(
                              behavior: HitTestBehavior.translucent,
                              onTap: _onChimneyTap,
                            ),
                          ),

                          // Fireflies — scattered in lower mid area
                          Positioned(
                            left: w * 0.08,
                            top: h * 0.42,
                            width: w * 0.84,
                            height: h * 0.30,
                            child: GestureDetector(
                              behavior: HitTestBehavior.translucent,
                              onTap: _onFireflyTap,
                            ),
                          ),

                          // Stone path long-press
                          Positioned(
                            left: w * 0.28,
                            top: gY - 10,
                            width: w * 0.40,
                            height: h * 0.16,
                            child: GestureDetector(
                              behavior: HitTestBehavior.translucent,
                              onLongPress: _onPathLongPress,
                            ),
                          ),

                          // ══════════════════════════════════════
                          // GATE — centre
                          // ══════════════════════════════════════

                          // Gate glow on posts
                          Positioned(
                            left: w * 0.50 - 20,
                            top: gY - 70,
                            child: Container(
                              width: 40,
                              height: 60,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFFFFD700)
                                        .withValues(alpha: 0.15 + 0.20 * glow),
                                    blurRadius: 18 + 12 * glow,
                                    spreadRadius: 4,
                                  ),
                                ],
                              ),
                            ),
                          ),

                          // Chicken house door glow
                          Positioned(
                            left: w * 0.22 - 14,
                            top: gY - 44,
                            child: Container(
                              width: 28,
                              height: 30,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(14),
                                boxShadow: [
                                  BoxShadow(
                                    color: _pink.withValues(alpha: 0.20 + 0.28 * glow),
                                    blurRadius: 16 + 10 * glow,
                                    spreadRadius: 3,
                                  ),
                                ],
                              ),
                            ),
                          ),

                          // Giraffe house door glow
                          Positioned(
                            left: w * 0.78 - 16,
                            top: gY - 68,
                            child: Container(
                              width: 32,
                              height: 44,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF4ECDC4)
                                        .withValues(alpha: 0.18 + 0.26 * glow),
                                    blurRadius: 16 + 10 * glow,
                                    spreadRadius: 3,
                                  ),
                                ],
                              ),
                            ),
                          ),

                        ],
                      );
                    },
                  ),
                ),

                // ── House tap zones — outside AnimatedBuilder so they are stable
                // hit targets not recreated on every glow tick (mobile fix).
                // opaque + transparent Container ensures reliable touch on CanvasKit.

                // DinoGarden — tree canopy/trunk (x0.14–0.34, y0.20–0.55)
                Positioned(
                  left: w * 0.14,
                  top: h * 0.20,
                  width: w * 0.20,
                  height: h * 0.35,
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => Navigator.push(context,
                        MaterialPageRoute(builder: (_) => const DinoGardenScreen())),
                    child: Container(color: Colors.transparent),
                  ),
                ),

                // CalmLagoon — pond, bottom-left
                Positioned(
                  left: w * 0.13, top: h * 0.65,
                  width: w * 0.22, height: h * 0.25,
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => Navigator.push(context,
                        MaterialPageRoute(builder: (_) => const CalmLagoonScreen())),
                    child: Container(color: Colors.transparent),
                  ),
                ),

                // Rest Nest — mossy hollow, right-of-centre
                Positioned(
                  left: w * 0.60,
                  top: h * 0.62,
                  width: w * 0.18,
                  height: h * 0.22,
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => Navigator.push(context,
                        MaterialPageRoute(builder: (_) => const SleepNestScreen())),
                    child: Container(color: Colors.transparent),
                  ),
                ),

                // Safe Spot — flower corner, lower-left
                Positioned(
                  left: 0,
                  top: h * 0.62,
                  width: w * 0.12,
                  height: h * 0.30,
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => Navigator.push(context,
                        MaterialPageRoute(builder: (_) => const SafeCornerLivingRoom())),
                    child: Container(color: Colors.transparent),
                  ),
                ),

                // Gate → SharedGarden — tightened to door only
                if (kShowOldHouses)
                Positioned(
                  left: w * 0.42, top: h * 0.40,
                  width: w * 0.14, height: h * 0.24,
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => Navigator.push(context,
                        MaterialPageRoute(builder: (_) => const SharedGardenScreen())),
                    child: Container(color: Colors.transparent),
                  ),
                ),

                // Chicken house — left: 5%, top: 10%, width: 35%, height: 70%
                if (kShowOldHouses)
                Positioned(
                  left: w * 0.05,
                  top: h * 0.10,
                  width: w * 0.35,
                  height: h * 0.70,
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      SelectedChildService.selectForAgeMode(AgeMode.middleYears);
                      Navigator.push(context, HouseInteriorScreen.route(HouseType.chicken));
                    },
                    child: Container(color: Colors.transparent),
                  ),
                ),

                // Giraffe house — left: 60%, top: 10%, width: 35%, height: 70%
                if (kShowOldHouses)
                Positioned(
                  left: w * 0.60,
                  top: h * 0.10,
                  width: w * 0.35,
                  height: h * 0.70,
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      SelectedChildService.selectForAgeMode(AgeMode.earlyYears);
                      Navigator.push(context, HouseInteriorScreen.route(HouseType.giraffe));
                    },
                    child: Container(color: Colors.transparent),
                  ),
                ),

                // Top bar — overlaid on scene, always on top
                Positioned(
                  top: 0, left: 0, right: 0,
                  child: _buildTopBar(),
                ),

                // Parent Zone — persistent chip, top-right below top bar
                Positioned(
                  top: 56, right: 12,
                  child: GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ParentPinGate()),
                    ),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white24),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.shield_rounded, color: Colors.white54, size: 13),
                          SizedBox(width: 4),
                          Text(
                            'Parent Zone',
                            style: TextStyle(
                              color: Colors.white54,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'DM Sans',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

              ],
            );
          },
        ),
      ),
    );
  }

  // ── Mood row ─────────────────────────────────────────────────
  Widget _buildMoodRow() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 2),
      child: Column(
        children: [
          const Text(
            'How are you feeling?',
            style: TextStyle(
              color: _textSec,
              fontSize: 12,
              fontFamily: 'DM Sans',
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(_moods.length, (i) {
              final selected = _selectedMood == _moods[i];
              return GestureDetector(
                onTap: () => _saveMood(_moods[i]),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: selected
                        ? _moodColors[i].withValues(alpha: 0.20)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: selected
                          ? _moodColors[i].withValues(alpha: 0.70)
                          : Colors.white.withValues(alpha: 0.10),
                      width: selected ? 1.5 : 1,
                    ),
                    boxShadow: selected
                        ? [
                            BoxShadow(
                              color: _moodColors[i].withValues(alpha: 0.35),
                              blurRadius: 14,
                              spreadRadius: 2,
                            ),
                          ]
                        : null,
                  ),
                  child: Column(
                    children: [
                      Text(_moods[i], style: TextStyle(fontSize: selected ? 22 : 18)),
                      const SizedBox(height: 2),
                      Text(
                        _moodLabels[i],
                        style: TextStyle(
                          color: selected ? _moodColors[i] : _textSec,
                          fontSize: 10,
                          fontFamily: 'DM Sans',
                          fontWeight: selected ? FontWeight.w700 : FontWeight.normal,
                        ),
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

  // ── Sleep quick-access bar ───────────────────────────────────
  Widget _buildSleepBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
      child: GestureDetector(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const SleepScreen()),
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xFF0D1A30),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFF7C6AF5).withValues(alpha: 0.40)),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF7C6AF5).withValues(alpha: 0.12),
                blurRadius: 10,
                offset: const Offset(-3, 0),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 3,
                height: 24,
                decoration: BoxDecoration(
                  color: const Color(0xFF7C6AF5),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 12),
              const Text('🌙', style: TextStyle(fontSize: 18)),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'Log your sleep',
                  style: TextStyle(
                    color: Color(0xFFC0A0E0),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'DM Sans',
                  ),
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: Color(0xFF7C6AF5), size: 20),
            ],
          ),
        ),
      ),
    );
  }

  // ── Check-in shortcut ─────────────────────────────────────────
  Widget _buildCheckInCard() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
      child: GestureDetector(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const FabCheckInScreen()),
        ).then((_) => _loadStars()),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                _pink.withValues(alpha: 0.14),
                _purple.withValues(alpha: 0.10),
              ],
            ),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: _pink.withValues(alpha: 0.40)),
            boxShadow: [
              BoxShadow(
                color: _pink.withValues(alpha: 0.15),
                blurRadius: 12,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: const Row(
            children: [
              Text('✨', style: TextStyle(fontSize: 18)),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Today\'s check-in',
                  style: TextStyle(
                    color: _pink,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'DM Sans',
                  ),
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: _pink, size: 20),
            ],
          ),
        ),
      ),
    );
  }

  // ── Feeling Fab Hub bottom sheet ─────────────────────────────
  void _showFeelingFabHub() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _FeelingFabHub(onNavigate: (Widget screen) {
        Navigator.pop(context);
        Navigator.push(context, MaterialPageRoute(builder: (_) => screen))
            .then((_) => _loadStars());
      }),
    );
  }

}

// ─────────────────────────────────────────────────────────────
// FEELING FAB HUB — bottom sheet with log-type tiles
// ─────────────────────────────────────────────────────────────
class _FeelingFabHub extends StatelessWidget {
  final void Function(Widget screen) onNavigate;

  const _FeelingFabHub({required this.onNavigate});

  static const _purple = Color(0xFF7B2FBE);
  static const _teal   = Color(0xFF4ECDC4);
  static const _amber  = Color(0xFFFFB830);
  static const _pink   = Color(0xFFE91E8C);
  static const _green  = Color(0xFF4CAF50);

  @override
  Widget build(BuildContext context) {
    return GridView(
      shrinkWrap: true,
      padding: const EdgeInsets.fromLTRB(8, 4, 8, 8),
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        mainAxisExtent: 55,
        crossAxisSpacing: 6,
        mainAxisSpacing: 6,
      ),
      children: _tiles(context),
    );
  }

  List<Widget> _tiles(BuildContext context) => [
    _HubTile(emoji: '😊', label: 'How do I feel',  accentColor: _pink,   onTap: () => onNavigate(const PainScreen())),
    _HubTile(emoji: '🌙', label: 'Sleep',           accentColor: _amber,  onTap: () => onNavigate(const SleepScreen())),
    _HubTile(emoji: '⚡', label: 'Energy',           accentColor: _teal,   onTap: () => onNavigate(const EnergyScreen())),
    _HubTile(emoji: '🌈', label: 'How I Feel',       accentColor: _purple, onTap: () => onNavigate(const MoodScreen())),
    _HubTile(emoji: '🩹', label: 'Recovery',         accentColor: _green,  onTap: () => onNavigate(const RecoveryScreen())),
    _HubTile(emoji: '✨', label: 'Brilliant',        accentColor: _amber,  onTap: () => onNavigate(const FabBrilliantScreen())),
    _HubTile(emoji: '🍽', label: 'Nutrition',        accentColor: _green,  onTap: () => onNavigate(const CookingScreen())),
    _HubTile(emoji: '🚀', label: 'Check-in',         accentColor: _pink,   onTap: () => onNavigate(const FabCheckInScreen())),
  ];
}

class _HubTile extends StatelessWidget {
  final String emoji;
  final String label;
  final Color accentColor;
  final VoidCallback onTap;

  const _HubTile({
    required this.emoji,
    required this.label,
    required this.accentColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1A1040),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: accentColor.withValues(alpha: 0.45), width: 1),
          boxShadow: [
            BoxShadow(
              color: accentColor.withValues(alpha: 0.10),
              blurRadius: 6,
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 2),
            Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: accentColor,
                fontSize: 9,
                fontWeight: FontWeight.w700,
                fontFamily: 'DM Sans',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

