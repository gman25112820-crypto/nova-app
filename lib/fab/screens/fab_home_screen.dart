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
import '../widgets/chicken_lips_companion.dart';
import '../widgets/fab_world_scene.dart';
import '../widgets/fab_world_audio.dart';
import '../widgets/fab_world_theme.dart';
import '../widgets/transition_banner.dart';

// ─────────────────────────────────────────────────────────────
// FAB HOME SCREEN v4.0
// World scene with full audio system, mute button, condition-aware bottom nav.
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
    Color(0xFF00C9A7),
    Color(0xFF6C63FF),
    Color(0xFFFFB830),
    Color(0xFFFF8C42),
    Color(0xFFFF6B8A),
  ];

  static const _purple = Color(0xFF6C63FF);

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
      backgroundColor: const Color(0xFF0D0820),
      body: SafeArea(
        child: isLandscape
            ? _buildLandscapeLayout()
            : _buildPortraitLayout(),
      ),
      // In landscape the nav is inlined in the right-panel scroll column.
      bottomNavigationBar: isLandscape ? null : _buildBottomNav(),
      floatingActionButton:   isLandscape ? null : _buildFAB(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  // ── Portrait layout (unchanged) ───────────────────────────────
  Widget _buildPortraitLayout() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final sceneH = (constraints.maxHeight - 276).clamp(100.0, 400.0);
        return SingleChildScrollView(
          child: Column(
            children: [
              _buildTopBar(),
              _buildGreetingCard(),
              _buildTransitionBanner(),
              _buildWorldScene(sceneH),
              _buildMoodRow(),
              _buildSleepBar(),
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
            // ── Left panel: world scene, explicit size ───────────
            SizedBox(
              width: sceneW,
              child: _buildWorldScene(sceneH),
            ),
            // ── Right panel: all cards, fully scrollable ─────────
            Expanded(
              child: ColoredBox(
                color: const Color(0xFF1A0A2E),
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildTopBar(),
                      _buildGreetingCard(),
                      _buildTransitionBanner(),
                      _buildMoodRow(),
                      _buildSleepBar(),
                      _buildCheckInCard(),
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
                color: Color(0xFF6C63FF),
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
              color: Colors.white,
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
              color: const Color(0xFF2D1B69).withValues(alpha: 0.60),
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
              child: const Icon(Icons.settings_outlined, color: Colors.white54, size: 16),
            ),
          ),
          const SizedBox(width: 6),
          GestureDetector(
            onTap: () => _showFeelingFabHub(),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: const Color(0xFFFF6B8A).withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFFF6B8A).withValues(alpha: 0.35)),
              ),
              child: const Text(
                '+ Feeling Fab',
                style: TextStyle(
                  color: Color(0xFFFF6B8A),
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
      padding: const EdgeInsets.fromLTRB(14, 10, 10, 10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF2D1B69).withValues(alpha: 0.92),
            const Color(0xFF1A1040).withValues(alpha: 0.85),
          ],
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _purple.withValues(alpha: 0.22)),
      ),
      child: Row(
        children: [
          Image.asset(
            'assets/images/chicken_lips.png',
            width: 52,
            height: 52,
            errorBuilder: (_, __, ___) => const SizedBox(width: 52, height: 52),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Miss Chicken Lips',
                  style: TextStyle(
                    color: Color(0xFFFF80AB),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'DM Sans',
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _greetingText(),
                  style: const TextStyle(
                    color: Colors.white60,
                    fontSize: 12,
                    fontFamily: 'DM Sans',
                  ),
                ),
              ],
            ),
          ),
          if (_selectedMood != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(_selectedMood!, style: const TextStyle(fontSize: 18)),
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
            // ── Miss Chicken Lips companion ──────────────────────
            if (_companionGreeting != null)
              Positioned(
                left: 6,
                bottom: height * 0.10,
                child: ChickenLipsCompanion(
                  greeting: _companionGreeting!,
                ),
              ),
            // ── Left house tap (Chicken family) ─────────────────
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
            // ── Right house tap (Giraffe family) ─────────────────
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
              color: Colors.white54,
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
                onTap: () {
                  _saveMood(_moods[i]);
                  // CHARACTER AUDIO — commented out for MVP
                  // if (_audioReady) _audio.onCharacterEvent('chicken_lips');
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: selected
                        ? _moodColors[i].withValues(alpha: 0.22)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: selected
                          ? _moodColors[i].withValues(alpha: 0.60)
                          : Colors.white12,
                      width: selected ? 1.5 : 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(_moods[i], style: TextStyle(fontSize: selected ? 22 : 18)),
                      const SizedBox(height: 2),
                      Text(
                        _moodLabels[i],
                        style: TextStyle(
                          color: selected ? _moodColors[i] : Colors.white38,
                          fontSize: 10,
                          fontFamily: 'DM Sans',
                          fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
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
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 6),
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
            border: Border.all(color: const Color(0xFF5DADEC).withValues(alpha: 0.30)),
          ),
          child: const Row(
            children: [
              Text('🌙', style: TextStyle(fontSize: 18)),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Log your sleep',
                  style: TextStyle(
                    color: Color(0xFF5DADEC),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'DM Sans',
                  ),
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: Color(0xFF5DADEC), size: 20),
            ],
          ),
        ),
      ),
    );
  }

  // ── Check-in shortcut (landscape only) ───────────────────────
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
            color: _purple.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: _purple.withValues(alpha: 0.28)),
          ),
          child: const Row(
            children: [
              Text('✨', style: TextStyle(fontSize: 18)),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Today\'s check-in',
                  style: TextStyle(
                    color: Color(0xFF6C63FF),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'DM Sans',
                  ),
                ),
              ),
              Icon(Icons.chevron_right_rounded,
                  color: Color(0xFF6C63FF), size: 20),
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
        color: const Color(0xFF0D0820),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _purple.withValues(alpha: 0.15)),
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
                        color: active ? _purple : Colors.white38, size: 20),
                    const SizedBox(height: 2),
                    Text(
                      d.label,
                      style: TextStyle(
                        color: active ? _purple : Colors.white38,
                        fontSize: 9,
                        fontFamily: 'DM Sans',
                        fontWeight: active
                            ? FontWeight.w600
                            : FontWeight.normal,
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
      decoration: BoxDecoration(
        color: const Color(0xFF0D0820).withValues(alpha: 0.96),
        border: Border(
          top: BorderSide(color: _purple.withValues(alpha: 0.15)),
        ),
      ),
      child: Row(
        children: [
          // Left of FAB: always Home + Check In
          Expanded(child: _buildNavButton(defs[0])),
          Expanded(child: _buildNavButton(defs[1])),
          const SizedBox(width: 72), // FAB spacer
          // Right of FAB: condition-specific screens + Parent
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
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(def.icon, color: active ? _purple : Colors.white38, size: 22),
          const SizedBox(height: 3),
          Text(
            def.label,
            style: TextStyle(
              color: active ? _purple : Colors.white38,
              fontSize: 10,
              fontFamily: 'DM Sans',
              fontWeight: active ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
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
            colors: [Color(0xFF6C63FF), Color(0xFF00C9A7)],
          ),
          boxShadow: [
            BoxShadow(
              color: _purple.withValues(alpha: 0.45),
              blurRadius: 12,
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
// Insights and Clinician live here since they moved out of the nav.
// ─────────────────────────────────────────────────────────────
class _FeelingFabHub extends StatelessWidget {
  final void Function(Widget screen) onNavigate;

  const _FeelingFabHub({required this.onNavigate});

  static const _purple = Color(0xFF6C63FF);
  static const _teal   = Color(0xFF00C9A7);
  static const _amber  = Color(0xFFFFB830);
  static const _pink   = Color(0xFFFF6B8A);
  static const _green  = Color(0xFF4CAF50);

  @override
  Widget build(BuildContext context) {
    final tiles = _tiles(context);

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF2D1B69), Color(0xFF0D0820)],
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
              color: Colors.white,
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
