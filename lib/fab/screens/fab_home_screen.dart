import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../fab_theme.dart';
import '../screens/cooking_screen.dart';
import '../screens/duck_shop_screen.dart';
import '../screens/fab_brilliant_screen.dart';
import '../screens/fab_check_in_screen.dart';
import '../screens/fab_clinician_export_screen.dart';
import '../screens/fab_insights_screen.dart';
import '../screens/fab_settings_screen.dart';
import '../screens/pain_screen.dart';
import '../screens/parent_dashboard_screen.dart';
import '../screens/recovery_screen.dart';
import '../screens/rewards_screen.dart';
import '../screens/energy_screen.dart';
import '../screens/mood_screen.dart';
import '../screens/sleep_screen.dart';
import '../screens/worry_zone_screen.dart';
import '../models/family_account.dart';
import '../screens/house_interior_screen.dart';
import '../services/companion_service.dart';
import '../services/fab_stars_service.dart';
import '../services/profile_service.dart';
import '../widgets/calm_lagoon_scene.dart';
import '../widgets/chicken_lips_companion.dart';
import '../widgets/dino_garden_scene.dart';
import '../widgets/fab_world_scene.dart';
import '../widgets/fab_world_audio.dart';
import '../widgets/fab_world_theme.dart';
import '../widgets/safe_corner_scene.dart';
import '../widgets/sleep_nest_scene.dart';
import '../widgets/transition_banner.dart';

// ─────────────────────────────────────────────────────────────
// FAB HOME SCREEN v5.0
// Visual overhaul: zone cards, glowing moods, warm palette,
// styled nav bar with active pill, zone fade+scale transitions.
// ─────────────────────────────────────────────────────────────

class FabHomeScreen extends StatefulWidget {
  const FabHomeScreen({super.key});

  @override
  State<FabHomeScreen> createState() => _FabHomeScreenState();
}

class _FabHomeScreenState extends State<FabHomeScreen> {
  String _activeNavLabel        = 'Home';
  List<FabCondition> _conditions = [];
  late final FabWorldAudio _audio;
  late final FabWorldTheme _theme;
  bool _audioReady  = false;
  int  _starBalance = 0;

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
  static const _bgDeep   = Color(0xFF0F0520);
  static const _bgMid    = Color(0xFF1A0A2E);
  static const _card     = Color(0xFF2D1556);
  static const _purple   = Color(0xFF7B2FBE);
  static const _pink     = Color(0xFFE91E8C);
  static const _textPri  = Color(0xFFF0D6FF);
  static const _textSec  = Color(0xFF9D7ABF);
  static const _navActive = Color(0xFFD4A8FF);

  @override
  void initState() {
    super.initState();
    _conditions = ProfileService.profile?.conditions ?? [];
    _theme      = FabWorldTheme.fromCalendar();
    _audio      = FabWorldAudio();
    _initAudio();
    _loadMood();
    _loadStars();
    _loadCompanion();
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
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString('fab_mood_today');
    if (saved != null && mounted) setState(() => _selectedMood = saved);
  }

  Future<void> _saveMood(String mood) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('fab_mood_today', mood);
    setState(() => _selectedMood = mood);
  }

  @override
  void dispose() {
    _audio.dispose();
    super.dispose();
  }

  // ── Zone navigation (fade + scale) ───────────────────────────

  Route<void> _zoneRoute(Widget scene, Color bg) => PageRouteBuilder(
        pageBuilder: (_, anim, __) => Scaffold(
          backgroundColor: bg,
          body: SafeArea(
            child: Stack(
              children: [
                Positioned.fill(child: scene),
                Positioned(
                  top: 12,
                  left: 12,
                  child: Builder(
                    builder: (ctx) => GestureDetector(
                      onTap: () => Navigator.pop(ctx),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: const Color(0xFF2D1556).withValues(alpha: 0.70),
                          shape: BoxShape.circle,
                          boxShadow: const [
                            BoxShadow(color: Colors.black38, blurRadius: 8),
                          ],
                        ),
                        child: const Icon(
                          Icons.arrow_back_rounded,
                          color: _textPri,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        transitionsBuilder: (_, anim, __, child) => FadeTransition(
          opacity: anim,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.97, end: 1.0).animate(
              CurvedAnimation(parent: anim, curve: Curves.easeOutCubic),
            ),
            child: child,
          ),
        ),
        transitionDuration: const Duration(milliseconds: 320),
      );

  // ── Dynamic nav builder ───────────────────────────────────────

  List<_NavDef> _buildNavDefs() {
    void nav(Widget screen) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => screen)).then((_) {
        _loadStars();
        if (mounted) setState(() => _activeNavLabel = 'Home');
      });
    }

    return [
      _NavDef(Icons.home_rounded,     'Home',     () => setState(() => _activeNavLabel = 'Home')),
      _NavDef(Icons.favorite_rounded, 'Check In', () => nav(const PainScreen())),
      if (_conditions.contains(FabCondition.adhd))
        _NavDef(Icons.bolt_rounded, 'Focus', () => nav(const EnergyScreen())),
      if (_conditions.any((c) => c == FabCondition.autism || c == FabCondition.anxiety))
        _NavDef(Icons.cloud_queue_rounded, 'Worry', () => nav(const WorryZoneScreen())),
      if (_conditions.contains(FabCondition.sensory))
        _NavDef(Icons.sensors_rounded, 'Sensory', () => nav(const RecoveryScreen())),
      _NavDef(Icons.shield_rounded, 'Parent', () => nav(const ParentDashboardScreen())),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;
    return Scaffold(
      backgroundColor: _bgDeep,
      body: SafeArea(
        child: isLandscape
            ? _buildLandscapeLayout()
            : _buildPortraitLayout(),
      ),
      bottomNavigationBar: isLandscape ? null : _buildBottomNav(),
      floatingActionButton:   isLandscape ? null : _buildFAB(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  // ── Portrait layout ───────────────────────────────────────────
  Widget _buildPortraitLayout() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final sceneH = (constraints.maxHeight - 276).clamp(100.0, 400.0);
        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildTopBar(),
              _buildGreetingCard(),
              _buildTransitionBanner(),
              _buildWorldScene(sceneH),
              _buildSectionLabel('TODAY'),
              _buildMoodRow(),
              _buildSleepBar(),
              _buildCheckInCard(),
              _buildSectionLabel('YOUR WORLDS'),
              _buildZoneSection(),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }

  // ── Landscape layout: left scene | right scrollable cards ─────
  Widget _buildLandscapeLayout() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final sceneW = constraints.maxWidth * 0.45;
        final sceneH = constraints.maxHeight;
        return Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              width: sceneW,
              child: _buildWorldScene(sceneH),
            ),
            Expanded(
              child: ColoredBox(
                color: _bgMid,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildTopBar(),
                      _buildGreetingCard(),
                      _buildTransitionBanner(),
                      _buildSectionLabel('TODAY'),
                      _buildMoodRow(),
                      _buildSleepBar(),
                      _buildCheckInCard(),
                      _buildSectionLabel('YOUR WORLDS'),
                      _buildZoneSection(),
                      _buildLandscapeNav(),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // ── Section label ─────────────────────────────────────────────
  Widget _buildSectionLabel(String label) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Text(
        label,
        style: const TextStyle(
          color: _textSec,
          fontSize: 10,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.4,
          fontFamily: 'DM Sans',
        ),
      ),
    );
  }

  // ── Zone section — four porthole cards ───────────────────────
  Widget _buildZoneSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 1.25,
        children: [
          _buildZoneCard(
            name: 'Calm Lagoon',
            emoji: '🐢',
            gradient: [const Color(0xFF0A2E35), const Color(0xFF061820)],
            accent: const Color(0xFF4ECDC4),
            scene: const CalmLagoonScene(),
            bg: const Color(0xFF021A24),
          ),
          _buildZoneCard(
            name: 'Dino Garden',
            emoji: '🦕',
            gradient: [const Color(0xFF0A2E12), const Color(0xFF06180A)],
            accent: const Color(0xFF4CAF50),
            scene: const DinoGardenScene(),
            bg: const Color(0xFF0A1A0F),
          ),
          _buildZoneCard(
            name: 'Sleep Nest',
            emoji: '🌙',
            gradient: [const Color(0xFF05082E), const Color(0xFF040518)],
            accent: const Color(0xFF7C6AF5),
            scene: const SleepNestScene(),
            bg: const Color(0xFF050C1A),
          ),
          _buildZoneCard(
            name: 'Safe Corner',
            emoji: '🤗',
            gradient: [const Color(0xFF2E0A18), const Color(0xFF18060E)],
            accent: _pink,
            scene: const SafeCornerScene(),
            bg: const Color(0xFF0D1B3E),
          ),
        ],
      ),
    );
  }

  Widget _buildZoneCard({
    required String name,
    required String emoji,
    required List<Color> gradient,
    required Color accent,
    required Widget scene,
    required Color bg,
  }) {
    return GestureDetector(
      onTap: () => Navigator.push(context, _zoneRoute(scene, bg)),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: gradient,
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: accent.withValues(alpha: 0.55), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: accent.withValues(alpha: 0.22),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 44)),
            const SizedBox(height: 8),
            Text(
              name,
              style: const TextStyle(
                color: _textPri,
                fontSize: 12,
                fontWeight: FontWeight.w700,
                fontFamily: 'DM Sans',
              ),
            ),
          ],
        ),
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
          const Text(
            'Fabulously Me',
            style: TextStyle(
              color: _textPri,
              fontSize: 16,
              fontWeight: FontWeight.w600,
              fontFamily: 'DM Sans',
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
          // Chicken Lips avatar with glow
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
            child: const Center(
              child: Text('🐔', style: TextStyle(fontSize: 28)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Miss Chicken Lips',
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

  // ── Transition banner ─────────────────────────────────────────
  Widget _buildTransitionBanner() {
    final child = FamilyAccount.current?.children;
    if (child == null || child.isEmpty) return const SizedBox.shrink();
    return TransitionBanner(child: child.first);
  }

  // ── World scene ──────────────────────────────────────────────
  Widget _buildWorldScene(double height) {
    return SizedBox(
      height: height,
      child: Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Stack(
          children: [
            Positioned.fill(
              child: FabWorldScene(audio: _audioReady ? _audio : null),
            ),
            if (_companionGreeting != null)
              Positioned(
                left: 6,
                bottom: height * 0.10,
                child: ChickenLipsCompanion(
                  greeting: _companionGreeting!,
                ),
              ),
            Positioned(
              left: 0,
              top: height * 0.20,
              width: height * 0.38,
              height: height * 0.55,
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: () => Navigator.push(
                  context,
                  HouseInteriorScreen.route(HouseType.chicken),
                ),
              ),
            ),
            Positioned(
              right: 0,
              top: height * 0.15,
              width: height * 0.38,
              height: height * 0.55,
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: () => Navigator.push(
                  context,
                  HouseInteriorScreen.route(HouseType.giraffe),
                ),
              ),
            ),
          ],
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

  // ── Inline nav for landscape (replaces Scaffold bottomNav) ────
  Widget _buildLandscapeNav() {
    final defs = _buildNavDefs();
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 8, 12, 0),
      decoration: BoxDecoration(
        color: _bgDeep,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _purple.withValues(alpha: 0.20)),
      ),
      child: Row(
        children: defs.map((d) {
          final active = _activeNavLabel == d.label;
          return Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() => _activeNavLabel = d.label);
                d.onTap();
              },
              behavior: HitTestBehavior.opaque,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(d.icon,
                        color: active ? _navActive : const Color(0xFF7A5A9E), size: 20),
                    const SizedBox(height: 2),
                    Text(
                      d.label,
                      style: TextStyle(
                        color: active ? _navActive : const Color(0xFF7A5A9E),
                        fontSize: 9,
                        fontFamily: 'DM Sans',
                        fontWeight: active ? FontWeight.w700 : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // ── Bottom nav ───────────────────────────────────────────────
  Widget _buildBottomNav() {
    final defs = _buildNavDefs();

    return Container(
      height: 64,
      decoration: const BoxDecoration(
        color: _bgMid,
        border: Border(
          top: BorderSide(color: Color(0xFF2D1556)),
        ),
      ),
      child: Row(
        children: [
          Expanded(child: _buildNavButton(defs[0])),
          Expanded(child: _buildNavButton(defs[1])),
          const SizedBox(width: 72),
          for (final d in defs.sublist(2))
            Expanded(child: _buildNavButton(d)),
        ],
      ),
    );
  }

  Widget _buildNavButton(_NavDef def) {
    final active = _activeNavLabel == def.label;
    return GestureDetector(
      onTap: () {
        setState(() => _activeNavLabel = def.label);
        def.onTap();
      },
      behavior: HitTestBehavior.opaque,
      child: Center(
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: active
              ? BoxDecoration(
                  color: _navActive.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: _navActive.withValues(alpha: 0.25),
                      blurRadius: 10,
                    ),
                  ],
                )
              : null,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(def.icon,
                  color: active ? _navActive : const Color(0xFF7A5A9E), size: 22),
              const SizedBox(height: 3),
              Text(
                def.label,
                style: TextStyle(
                  color: active ? _navActive : const Color(0xFF7A5A9E),
                  fontSize: 10,
                  fontFamily: 'DM Sans',
                  fontWeight: active ? FontWeight.w700 : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── FAB ──────────────────────────────────────────────────────
  Widget _buildFAB() {
    return GestureDetector(
      onTap: _showFeelingFabHub,
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF7B2FBE), Color(0xFFE91E8C)],
          ),
          boxShadow: [
            BoxShadow(
              color: _pink.withValues(alpha: 0.45),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Icon(Icons.add_rounded, color: Colors.white, size: 28),
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
    final tiles = _tiles(context);

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF2D1556), Color(0xFF0F0520)],
        ),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 36, height: 4,
            decoration: BoxDecoration(
              color: Colors.white30,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'What do you want to log?',
            style: TextStyle(
              color: Color(0xFFF0D6FF),
              fontSize: 18,
              fontWeight: FontWeight.w800,
              fontFamily: 'DM Sans',
            ),
          ),
          const SizedBox(height: 20),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.35,
            children: tiles,
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  List<Widget> _tiles(BuildContext context) => [
    _HubTile(emoji: '😊', label: 'How do I feel',   accentColor: _pink,   onTap: () => onNavigate(const PainScreen())),
    _HubTile(emoji: '🌙', label: 'Sleep',            accentColor: _amber,  onTap: () => onNavigate(const SleepScreen())),
    _HubTile(emoji: '⚡', label: 'Energy',            accentColor: _teal,   onTap: () => onNavigate(const EnergyScreen())),
    _HubTile(emoji: '🌈', label: 'Mood',              accentColor: _purple, onTap: () => onNavigate(const MoodScreen())),
    _HubTile(emoji: '🩹', label: 'Recovery',          accentColor: _green,  onTap: () => onNavigate(const RecoveryScreen())),
    _HubTile(emoji: '✨', label: 'Brilliant Things',  accentColor: _amber,  onTap: () => onNavigate(const FabBrilliantScreen())),
    _HubTile(emoji: '🍽', label: 'Nutrition',         accentColor: _green,  onTap: () => onNavigate(const CookingScreen())),
    _HubTile(emoji: '🚀', label: 'Do it all at once', accentColor: _pink,   onTap: () => onNavigate(const FabCheckInScreen())),
    _HubTile(emoji: '🎁', label: 'Rewards',            accentColor: _amber,  onTap: () => onNavigate(const RewardsScreen())),
    _HubTile(emoji: '📊', label: 'Insights',          accentColor: _purple, onTap: () => onNavigate(const FabInsightsScreen())),
    _HubTile(emoji: '🩺', label: 'Clinician',         accentColor: _teal,   onTap: () => onNavigate(const FabClinicianExportScreen())),
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
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: accentColor.withValues(alpha: 0.45), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: accentColor.withValues(alpha: 0.14),
              blurRadius: 12,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 32)),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: accentColor,
                fontSize: 12,
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

// ── Nav definition ────────────────────────────────────────────

class _NavDef {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  _NavDef(this.icon, this.label, this.onTap);
}
