import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'fab_home_screen.dart';

// ─────────────────────────────────────────────────────────────
// ONBOARDING SCREEN
// 3-page PageView: Welcome → Who are you? → Meet Miss Chicken Lips
// Saves child name, age, avatar to SharedPreferences.
// Sets onboarding_complete=true so it never shows again.
// ─────────────────────────────────────────────────────────────

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _pageCtrl  = PageController();
  final _nameCtrl  = TextEditingController();
  int _page        = 0;
  int _age         = 8;
  int _avatarIndex = 0;

  // ── Avatar options ────────────────────────────────────────────
  static const _avatarEmojis  = ['🐔', '🦒', '🦆', '🐢', '🐣', '⭐'];
  static const _avatarLabels  = ['Chicken', 'Giraffe', 'Duck', 'Turtle', 'Chick', 'Star'];

  // ── Colours ───────────────────────────────────────────────────
  static const _bg    = Color(0xFF0D0820);
  static const _pink  = Color(0xFFFF6FB0);
  static const _pink2 = Color(0xFFFF4081);
  static const _purp  = Color(0xFF6C63FF);
  static const _gold  = Color(0xFFFFD700);

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
    } else {
      _finish();
    }
  }

  Future<void> _finish() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('child_name',      _nameCtrl.text.trim());
    await prefs.setInt   ('child_age',        _age);
    await prefs.setInt   ('child_avatar',     _avatarIndex);
    await prefs.setString('child_avatar_emoji', _avatarEmojis[_avatarIndex]);
    await prefs.setBool  ('onboarding_complete', true);
    // keep legacy flag in sync so existing code still works
    await prefs.setBool  ('onboarding_done',  true);

    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const FabHomeScreen()),
    );
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
                  _buildPage3(),
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
      children: List.generate(3, (i) {
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
          // Animated star burst around chicken lips
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

          // App name
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

          // Motto
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

          // Intro message bubble
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

          // Name field
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

          // Age selector
          _fieldLabel('How old are you?'),
          const SizedBox(height: 12),
          _buildAgeSelector(),

          const SizedBox(height: 28),

          // Avatar picker
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
    return SizedBox(
      height: 52,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 12, // ages 5-16
        itemBuilder: (_, i) {
          final age = i + 5;
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
        childAspectRatio: 1.15,
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

  // ── Page 3 — Meet Miss Chicken Lips ──────────────────────────

  Widget _buildPage3() {
    final name   = _nameCtrl.text.trim();
    final avatar = _avatarEmojis[_avatarIndex];

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(28, 32, 28, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Avatar + Chicken Lips side by side
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

          // Feature tiles
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
    final isLast    = _page == 2;
    final isPage1   = _page == 1;
    final canProceed = isPage1 ? _canAdvanceFromPage1 : true;
    final label = isLast ? 'Let\'s Go! 🚀' : (_page == 0 ? 'Start →' : 'Next →');

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
                    colors: isLast
                        ? [_purp, _pink]
                        : [_pink, _pink2],
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
