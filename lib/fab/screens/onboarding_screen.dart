import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../fab_theme.dart';
import '../models/profile_model.dart';
import '../services/profile_service.dart';
import 'fab_home_screen.dart';

// ─────────────────────────────────────────────────────────────
// ONBOARDING SCREEN
// 4-page PageView: Welcome → Who are you? → Your conditions → Meet Miss CL
// Saves child name, age, avatar to SharedPreferences.
// Constructs ProfileModel with conditions and persists to Hive 'profiles'.
// Sets onboarding_complete=true so it never shows again.
// ─────────────────────────────────────────────────────────────

class OnboardingScreen extends StatefulWidget {
  /// When [editMode] is true the screen is launched from Settings.
  /// _finish() pops instead of replacing with HomeScreen, and profile
  /// data is pre-populated from the saved profile on initState.
  const OnboardingScreen({super.key, this.editMode = false, this.initialPage = 0});

  final bool editMode;
  final int  initialPage;

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _pageCtrl = PageController();
  final _nameCtrl = TextEditingController();
  int _page                              = 0;
  int _age                               = 8;
  int _avatarIndex                       = 0;
  bool _isParentSetup                    = false;
  final Set<FabCondition> _selectedConditions  = {};

  static const _avatarEmojis = ['🐔', '🦒', '🦆', '🐢', '🐣', '⭐'];
  static const _avatarLabels = ['Chicken', 'Giraffe', 'Duck', 'Turtle', 'Chick', 'Star'];

  static const _bg    = Color(0xFF0D0820);
  static const _pink  = Color(0xFFFF6FB0);
  static const _pink2 = Color(0xFFFF4081);
  static const _purp  = Color(0xFF6C63FF);
  static const _gold  = Color(0xFFFFD700);

  static const _condTiles = [
    _CondTile(FabCondition.adhd,        '🧠', 'Busy Brain',     'Attention-deficit/hyperactivity disorder'),
    _CondTile(FabCondition.autism,      '🌟', 'My Autism',      'Autism spectrum / PDA profile'),
    _CondTile(FabCondition.dyspraxia,   '🤸', 'Wiggly Body',    'Developmental coordination disorder'),
    _CondTile(FabCondition.dyslexia,    '📚', 'Word Muddles',   'Reading and processing differences'),
    _CondTile(FabCondition.dyscalculia, '🔢', 'Number Puzzles', 'Maths processing differences'),
    _CondTile(FabCondition.tourettes,   '⚡', 'Tic Tacs',       'Tourette syndrome / tic disorder'),
    _CondTile(FabCondition.anxiety,     '💙', 'Big Feelings',   'Anxiety / emotional regulation'),
    _CondTile(FabCondition.sensory,     '🎧', 'Sensor Squad',   'Sensory processing differences'),
  ];

  @override
  void initState() {
    super.initState();
    if (widget.editMode) _loadExistingProfile();
    if (widget.initialPage > 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _pageCtrl.jumpToPage(widget.initialPage);
      });
    }
  }

  Future<void> _loadExistingProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final name   = prefs.getString('child_name') ?? '';
    final age    = prefs.getInt   ('child_age')  ?? 8;
    final avatar = prefs.getInt   ('child_avatar') ?? 0;
    final saved  = ProfileService.profile?.conditions ?? [];
    if (!mounted) return;
    setState(() {
      _nameCtrl.text = name;
      _age           = age;
      _avatarIndex   = avatar;
      _selectedConditions
        ..clear()
        ..addAll(saved);
    });
  }

  @override
  void dispose() {
    _pageCtrl.dispose();
    _nameCtrl.dispose();
    super.dispose();
  }

  void _goToPage(int page) {
    _pageCtrl.animateToPage(
      page,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }

  bool get _canAdvanceFromPage1 => _nameCtrl.text.trim().isNotEmpty;

  void _onNext() {
    if (_page == 0) {
      _goToPage(1);
    } else if (_page == 1) {
      if (!_canAdvanceFromPage1) return;
      _goToPage(2);
    } else if (_page == 2) {
      _goToPage(3);
    } else {
      _finish();
    }
  }

  Future<void> _finish() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('child_name',         _nameCtrl.text.trim());
    await prefs.setInt   ('child_age',           _age);
    await prefs.setInt   ('child_avatar',        _avatarIndex);
    await prefs.setString('child_avatar_emoji',  _avatarEmojis[_avatarIndex]);
    await prefs.setBool  ('onboarding_complete', true);
    await prefs.setBool  ('onboarding_done',     true);

    final profile = ProfileModel(
      id:         DateTime.now().millisecondsSinceEpoch.toString(),
      name:       _nameCtrl.text.trim(),
      age:        _age,
      conditions: _selectedConditions.toList(),
    );
    await ProfileService.save(profile);

    if (!mounted) return;
    if (widget.editMode) {
      Navigator.of(context).pop();
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const FabHomeScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 12),
            _buildDots(),
            Expanded(
              child: PageView(
                controller: _pageCtrl,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (p) => setState(() => _page = p),
                children: [
                  _buildPage1(),
                  _buildPage2(),
                  _buildConditionPage(),
                  _buildMeetPage(),
                ],
              ),
            ),
            _buildBottomButton(),
          ],
        ),
      ),
    );
  }

  // ── Progress dots ─────────────────────────────────────────────

  Widget _buildDots() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(4, (i) {
        final active = i == _page;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
          width: active ? 28 : 8,
          height: 8,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            color: active ? _pink : Colors.white.withValues(alpha: 0.18),
            borderRadius: BorderRadius.circular(99),
          ),
        );
      }),
    );
  }

  // ── Page 1 — Welcome ─────────────────────────────────────────

  Widget _buildPage1() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(28, 32, 28, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 130,
                height: 130,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(colors: [
                    _pink.withValues(alpha: 0.22),
                    _bg.withValues(alpha: 0),
                  ]),
                ),
              ),
              const Text('🐔', style: TextStyle(fontSize: 72)),
            ],
          ),
          const SizedBox(height: 28),
          ShaderMask(
            shaderCallback: (r) => const LinearGradient(
              colors: [_pink, _purp],
            ).createShader(r),
            child: const Text(
              'Fabulously Me',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 34,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.5,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('✨ ', style: TextStyle(fontSize: 16)),
              Text(
                'Feeling Fab',
                style: TextStyle(
                  color: _gold.withValues(alpha: 0.90),
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.5,
                ),
              ),
              const Text(' ✨', style: TextStyle(fontSize: 16)),
            ],
          ),
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: _pink.withValues(alpha: 0.22)),
            ),
            child: Column(
              children: [
                Text(
                  'Hi! I\'m Miss Chicken Lips 👋',
                  style: TextStyle(
                    color: _pink,
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'This is your safe place to share how you\'re feeling every day. '
                  'You\'ll earn Fab Stars ⭐ for checking in, and grown-ups can use '
                  'your entries to help you get the right support.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.68),
                    fontSize: 14,
                    height: 1.6,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Takes about 1 minute to set up',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.30),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  // ── Page 2 — Who's using the app? ────────────────────────────

  Widget _buildPage2() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(28, 32, 28, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Let\'s get to know you!',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Tell us a bit about yourself.',
            style: TextStyle(color: Colors.white.withValues(alpha: 0.50), fontSize: 14),
          ),
          const SizedBox(height: 28),
          _fieldLabel('What\'s your name?'),
          const SizedBox(height: 10),
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: _pink.withValues(alpha: 0.28)),
            ),
            child: TextField(
              controller: _nameCtrl,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
              textCapitalization: TextCapitalization.words,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: 'My name is...',
                hintStyle: TextStyle(
                  color: Colors.white.withValues(alpha: 0.22),
                  fontSize: 18,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.all(18),
              ),
            ),
          ),
          const SizedBox(height: 28),
          _fieldLabel('How old are you?'),
          const SizedBox(height: 12),
          _buildAgeSelector(),
          const SizedBox(height: 28),
          _fieldLabel('Pick your avatar!'),
          const SizedBox(height: 12),
          _buildAvatarPicker(),
        ],
      ),
    );
  }

  Widget _fieldLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 15,
        fontWeight: FontWeight.w700,
      ),
    );
  }

  Widget _buildAgeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () => setState(() {
            _isParentSetup = !_isParentSetup;
            _age = _isParentSetup ? 2 : 8;
          }),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: _isParentSetup
                  ? _purp.withValues(alpha: 0.18)
                  : Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: _isParentSetup ? _purp : Colors.white.withValues(alpha: 0.12),
                width: _isParentSetup ? 2 : 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _isParentSetup
                      ? Icons.check_circle_rounded
                      : Icons.circle_outlined,
                  color: _isParentSetup ? _purp : Colors.white.withValues(alpha: 0.35),
                  size: 18,
                ),
                const SizedBox(width: 8),
                Text(
                  'Setting this up for my child (under 5)',
                  style: TextStyle(
                    color: _isParentSetup ? _purp : Colors.white.withValues(alpha: 0.55),
                    fontSize: 13,
                    fontWeight: _isParentSetup ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 52,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _isParentSetup ? 5 : 12,
            itemBuilder: (_, i) {
              final age = _isParentSetup ? i : i + 5;
              final on  = age == _age;
              return GestureDetector(
                onTap: () => setState(() => _age = age),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  width: 48,
                  margin: const EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    color: on ? _pink.withValues(alpha: 0.18) : Colors.white.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: on ? _pink : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      '$age',
                      style: TextStyle(
                        color: on ? _pink : Colors.white.withValues(alpha: 0.55),
                        fontSize: 17,
                        fontWeight: on ? FontWeight.w800 : FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildAvatarPicker() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _avatarEmojis.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        mainAxisExtent: 140,
      ),
      itemBuilder: (_, i) {
        final on = _avatarIndex == i;
        return GestureDetector(
          onTap: () => setState(() => _avatarIndex = i),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            decoration: BoxDecoration(
              color: on ? _pink.withValues(alpha: 0.16) : Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: on ? _pink : Colors.white.withValues(alpha: 0.10),
                width: on ? 2 : 1,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _avatarEmojis[i],
                  style: TextStyle(fontSize: on ? 36 : 28),
                ),
                const SizedBox(height: 4),
                Text(
                  _avatarLabels[i],
                  style: TextStyle(
                    color: on ? _pink : Colors.white.withValues(alpha: 0.40),
                    fontSize: 11,
                    fontWeight: on ? FontWeight.w700 : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ── Page 3 — Condition picker ─────────────────────────────────

  Widget _buildConditionPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 28, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'What makes you, YOU?',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Tap everything that fits — you can pick more than one.',
            style: TextStyle(color: Colors.white.withValues(alpha: 0.50), fontSize: 13),
          ),
          const SizedBox(height: 3),
          Text(
            'A grown-up can help if you\'re not sure.',
            style: TextStyle(color: Colors.white.withValues(alpha: 0.32), fontSize: 12),
          ),
          const SizedBox(height: 20),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _condTiles.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 1.55,
            ),
            itemBuilder: (_, i) => _buildCondTile(_condTiles[i]),
          ),
          const SizedBox(height: 18),
          GestureDetector(
            onTap: () {
              setState(() => _selectedConditions.clear());
              _goToPage(3);
            },
            child: Center(
              child: Text(
                'None of these apply  →',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.36),
                  fontSize: 13,
                  decoration: TextDecoration.underline,
                  decorationColor: Colors.white.withValues(alpha: 0.20),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCondTile(_CondTile tile) {
    final selected = _selectedConditions.contains(tile.condition);
    final color    = tile.condition.color;
    return GestureDetector(
      onTap: () => setState(() {
        if (selected) {
          _selectedConditions.remove(tile.condition);
        } else {
          _selectedConditions.add(tile.condition);
        }
      }),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 8),
        decoration: BoxDecoration(
          color: selected
              ? color.withValues(alpha: 0.18)
              : Colors.white.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected
                ? color.withValues(alpha: 0.70)
                : Colors.white.withValues(alpha: 0.10),
            width: selected ? 2 : 1,
          ),
        ),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(tile.emoji, style: const TextStyle(fontSize: 26)),
                const SizedBox(height: 4),
                Text(
                  tile.childLabel,
                  style: TextStyle(
                    color: selected ? color : Colors.white.withValues(alpha: 0.85),
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  tile.parentHint,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.36),
                    fontSize: 10,
                    height: 1.3,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
            if (selected)
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                  child: const Icon(Icons.check_rounded, color: Colors.white, size: 14),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ── Page 4 — Meet Miss Chicken Lips ──────────────────────────

  Widget _buildMeetPage() {
    final name   = _nameCtrl.text.trim();
    final avatar = _avatarEmojis[_avatarIndex];

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(28, 32, 28, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _avatarBubble(avatar, _purp),
              const SizedBox(width: 16),
              const Text('🤝', style: TextStyle(fontSize: 28)),
              const SizedBox(width: 16),
              _avatarBubble('🐔', _pink),
            ],
          ),
          const SizedBox(height: 28),
          Text(
            name.isNotEmpty ? 'Hi $name, meet\nMiss Chicken Lips!' : 'Meet\nMiss Chicken Lips!',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.w800,
              height: 1.25,
            ),
          ),
          const SizedBox(height: 20),
          _featureTile(
            '📋',
            'Daily check-ins',
            'Each day, tell Miss Chicken Lips how you\'re feeling — mood, sleep, energy, and more.',
            _purp,
          ),
          const SizedBox(height: 10),
          _featureTile(
            '⭐',
            'Earn Fab Stars',
            'Every time you check in, you earn a Fab Star. Watch your collection grow!',
            _gold,
          ),
          const SizedBox(height: 10),
          _featureTile(
            '🩺',
            'Help grown-ups help you',
            'Your check-ins help parents and doctors understand how you\'re doing.',
            _pink,
          ),
          const SizedBox(height: 20),
          Text(
            'Everything stays private on your device 🔒',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.30),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _avatarBubble(String emoji, Color color) {
    return Container(
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withValues(alpha: 0.16),
        border: Border.all(color: color.withValues(alpha: 0.40), width: 2),
      ),
      child: Center(child: Text(emoji, style: const TextStyle(fontSize: 36))),
    );
  }

  Widget _featureTile(String emoji, String title, String body, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.18)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 26)),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: TextStyle(
                      color: color,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    )),
                const SizedBox(height: 4),
                Text(body,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.58),
                      fontSize: 12,
                      height: 1.5,
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Bottom button ─────────────────────────────────────────────

  Widget _buildBottomButton() {
    final isLast     = _page == 3;
    final isPage1    = _page == 1;
    final canProceed = isPage1 ? _canAdvanceFromPage1 : true;
    final label      = isLast
        ? (widget.editMode ? 'Save changes ✓' : 'Let\'s Go! 🚀')
        : (_page == 0 ? 'Start →' : 'Next →');

    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 12, 28, 32),
      child: GestureDetector(
        onTap: canProceed ? _onNext : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: double.infinity,
          height: 58,
          decoration: BoxDecoration(
            gradient: canProceed
                ? LinearGradient(
                    colors: isLast ? [_purp, _pink] : [_pink, _pink2],
                  )
                : null,
            color: canProceed ? null : Colors.white.withValues(alpha: 0.07),
            borderRadius: BorderRadius.circular(18),
            boxShadow: canProceed
                ? [
                    BoxShadow(
                      color: _pink.withValues(alpha: 0.30),
                      blurRadius: 14,
                      offset: const Offset(0, 4),
                    )
                  ]
                : null,
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: canProceed ? Colors.white : Colors.white.withValues(alpha: 0.25),
                fontSize: 17,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Condition tile data ───────────────────────────────────────

class _CondTile {
  final FabCondition condition;
  final String emoji;
  final String childLabel;
  final String parentHint;
  const _CondTile(this.condition, this.emoji, this.childLabel, this.parentHint);
}
