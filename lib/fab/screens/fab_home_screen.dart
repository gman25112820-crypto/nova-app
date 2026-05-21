import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../screens/fab_clinician_screen.dart';
import '../screens/fab_insights_screen.dart';
import '../screens/pain_screen.dart';
import '../screens/parent_dashboard_screen.dart';
import '../screens/sleep_screen.dart';
import '../services/fab_stars_service.dart';
import '../widgets/fab_world_scene.dart';
import '../widgets/fab_world_audio.dart';
import '../widgets/fab_world_theme.dart';

// ─────────────────────────────────────────────────────────────
// FAB HOME SCREEN v3.0
// World scene with full audio system, mute button, bottom nav.
// ─────────────────────────────────────────────────────────────

class FabHomeScreen extends StatefulWidget {
  const FabHomeScreen({super.key});

  @override
  State<FabHomeScreen> createState() => _FabHomeScreenState();
}

class _FabHomeScreenState extends State<FabHomeScreen> {
  int _selectedIndex = 0;
  late final FabWorldAudio _audio;
  late final FabWorldTheme _theme;
  bool _audioReady = false;
  int _starBalance = 0;

  // ── Mood state ───────────────────────────────────────────────
  String? _selectedMood;
  static const _moods = ['😄', '🙂', '😐', '😟', '😣'];
  static const _moodLabels = ['Great', 'Good', 'Okay', 'Low', 'Rough'];
  static const _moodColors = [
    Color(0xFF00C9A7),
    Color(0xFF6C63FF),
    Color(0xFFFFB830),
    Color(0xFFFF8C42),
    Color(0xFFFF6B8A),
  ];

  // ── Nav items ────────────────────────────────────────────────
  static const _navItems = [
    (icon: Icons.home_rounded,             label: 'Home'),
    (icon: Icons.favorite_rounded,         label: 'Check In'),
    (icon: Icons.add_circle_rounded,       label: ''),           // FAB
    (icon: Icons.insights_rounded,         label: 'Insights'),
    (icon: Icons.medical_services_rounded, label: 'Clinician'),
    (icon: Icons.shield_rounded,           label: 'Parent'),
  ];

  @override
  void initState() {
    super.initState();
    _theme = FabWorldTheme.fromCalendar();
    _audio = FabWorldAudio();
    _initAudio();
    _loadMood();
    _loadStars();
  }

  Future<void> _loadStars() async {
    final balance = await FabStarsService.getBalance();
    if (mounted) setState(() => _starBalance = balance);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0820),
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(),
            _buildGreetingCard(),
            _buildWorldScene(),
            _buildMoodRow(),
            _buildSleepBar(),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
      floatingActionButton: _buildFAB(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  // ── Top bar ──────────────────────────────────────────────────
  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 12, 0),
      child: Row(
        children: [
          // Nova badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF6C63FF).withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: const Color(0xFF6C63FF).withValues(alpha: 0.35),
              ),
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
          // Star balance badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFFFD700).withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: const Color(0xFFFFD700).withValues(alpha: 0.35),
              ),
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
          const SizedBox(width: 6),
          // Season badge
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
          // Mute button
          if (_audioReady)
            FabMuteButton(audio: _audio),
          // Feeling Fab badge
          GestureDetector(
            onTap: () => _showVolumeSheet(),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: const Color(0xFFFF6B8A).withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: const Color(0xFFFF6B8A).withValues(alpha: 0.35),
                ),
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
        border: Border.all(
          color: const Color(0xFF6C63FF).withValues(alpha: 0.22),
        ),
      ),
      child: Row(
        children: [
          // Chicken Lips avatar — smaller
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
          // Mood quick-tap
          if (_selectedMood != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                _selectedMood!,
                style: const TextStyle(fontSize: 18),
              ),
            ),
        ],
      ),
    );
  }

  String _greetingText() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning! How are we feeling?';
    if (hour < 17) return 'Good afternoon! Ready to check in?';
    return 'Good evening! How has the day been?';
  }

  // ── World scene ──────────────────────────────────────────────
  Widget _buildWorldScene() {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.only(top: 4),
        child: FabWorldScene(
          audio: _audioReady ? _audio : null,
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
                  if (_audioReady) {
                    _audio.onCharacterEvent('chicken_lips');
                  }
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
                      Text(
                        _moods[i],
                        style: TextStyle(fontSize: selected ? 22 : 18),
                      ),
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
            border: Border.all(
              color: const Color(0xFF5DADEC).withValues(alpha: 0.30),
            ),
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
              Icon(Icons.chevron_right_rounded,
                  color: Color(0xFF5DADEC), size: 20),
            ],
          ),
        ),
      ),
    );
  }

  // ── Bottom nav ───────────────────────────────────────────────
  Widget _buildBottomNav() {
    return Container(
      height: 64,
      decoration: BoxDecoration(
        color: const Color(0xFF0D0820).withValues(alpha: 0.96),
        border: Border(
          top: BorderSide(
            color: const Color(0xFF6C63FF).withValues(alpha: 0.15),
          ),
        ),
      ),
      child: Row(
        children: List.generate(_navItems.length, (i) {
          if (i == 2) return const SizedBox(width: 72); // FAB space
          final item = _navItems[i];
          final active = _selectedIndex == i;
          return Expanded(
            child: GestureDetector(
              onTap: () {
                if (i == 1) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const PainScreen(),
                    ),
                  ).then((_) => _loadStars());
                  return;
                }
                if (i == 3) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const FabInsightsScreen(),
                    ),
                  );
                  return;
                }
                if (i == 4) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const FabClinicianScreen(),
                    ),
                  );
                  return;
                }
                if (i == 5) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ParentDashboardScreen(),
                    ),
                  );
                  return;
                }
                setState(() => _selectedIndex = i);
              },
              behavior: HitTestBehavior.opaque,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    item.icon,
                    color: active
                        ? const Color(0xFF6C63FF)
                        : Colors.white38,
                    size: 22,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    item.label,
                    style: TextStyle(
                      color: active
                          ? const Color(0xFF6C63FF)
                          : Colors.white38,
                      fontSize: 10,
                      fontFamily: 'DM Sans',
                      fontWeight: active ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  // ── FAB ──────────────────────────────────────────────────────
  Widget _buildFAB() {
    return GestureDetector(
      onTap: () => _navigateToBrilliant(),
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
              color: const Color(0xFF6C63FF).withValues(alpha: 0.45),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Icon(Icons.add_rounded, color: Colors.white, size: 28),
      ),
    );
  }

  void _navigateToBrilliant() {
    Navigator.pushNamed(context, '/brilliant').then((_) => _loadStars());
  }

  // ── Volume sheet ─────────────────────────────────────────────
  void _showVolumeSheet() {
    if (!_audioReady) return;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => FabVolumeSheet(audio: _audio),
    );
  }
}
