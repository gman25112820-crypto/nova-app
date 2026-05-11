import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nova_app/fab/screens/fab_home_screen.dart';

// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
// FAB ONBOARDING
// First run: child enters name, picks character
// Parent enters their name
// Saves to SharedPreferences, never shown again
// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

class FabOnboardingScreen extends StatefulWidget {
  const FabOnboardingScreen({super.key});

  @override
  State<FabOnboardingScreen> createState() => _FabOnboardingScreenState();
}

class _FabOnboardingScreenState extends State<FabOnboardingScreen>
    with TickerProviderStateMixin {
  int _step = 0;
  final TextEditingController _childNameCtrl = TextEditingController();
  final TextEditingController _parentNameCtrl = TextEditingController();
  int _selectedCharacter = 0;
  late final AnimationController _fadeCtrl;
  late final Animation<double> _fadeAnim;

  final List<Map<String, String>> _characters = [
    {'name': 'Miss Chicken Lips', 'asset': 'assets/images/chicken_lips.png', 'desc': 'Caring and always here for you'},
    {'name': 'Ollie Giraffe', 'asset': 'assets/images/characters/son_giraffe_2.png', 'desc': 'Curious and full of questions'},
    {'name': 'Theo Giraffe', 'asset': 'assets/images/characters/son_giraffe_1.png', 'desc': 'Calm and loves adventures'},
  ];

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 500));
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeIn);
    _fadeCtrl.forward();
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    _childNameCtrl.dispose();
    _parentNameCtrl.dispose();
    super.dispose();
  }

  Future<void> _finish() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('child_name', _childNameCtrl.text.trim());
    await prefs.setString('parent_name', _parentNameCtrl.text.trim());
    await prefs.setInt('selected_character', _selectedCharacter);
    await prefs.setBool('onboarding_done', true);

    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const FabHomeScreen()),
    );
  }

  void _next() {
    if (_step == 0 && _childNameCtrl.text.trim().isEmpty) return;
    if (_step < 2) {
      _fadeCtrl.reset();
      setState(() => _step++);
      _fadeCtrl.forward();
    } else {
      _finish();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0820),
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnim,
          child: Column(
            children: [
              _buildProgressDots(),
              Expanded(child: _buildStep()),
              _buildNextButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressDots() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(3, (i) {
          return AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: i == _step ? 24 : 8,
            height: 8,
            margin: const EdgeInsets.symmetric(horizontal: 3),
            decoration: BoxDecoration(
              color: i == _step
                  ? const Color(0xFFFF6FB0)
                  : Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(99),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildStep() {
    switch (_step) {
      case 0: return _buildChildNameStep();
      case 1: return _buildCharacterStep();
      case 2: return _buildParentNameStep();
      default: return const SizedBox.shrink();
    }
  }

  Widget _buildChildNameStep() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          Image.asset(
            'assets/images/chicken_lips.png',
            width: 100, height: 100, fit: BoxFit.contain,
          ),
          const SizedBox(height: 20),
          const Text(
            'Hello! I\'m Miss Chicken Lips ðŸ‘‹',
            style: TextStyle(
                color: Color(0xFFFF6FB7),
                fontSize: 22,
                fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 10),
          Text(
            'I\'m here to help you share how you\'re feeling every day. What\'s your name?',
            style: TextStyle(
                color: Colors.white.withValues(alpha: 0.65),
                fontSize: 15,
                height: 1.5),
          ),
          const SizedBox(height: 32),
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                  color: const Color(0xFFFF6FB7).withValues(alpha: 0.3)),
            ),
            child: TextField(
              controller: _childNameCtrl,
              style: const TextStyle(
                  color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700),
              textCapitalization: TextCapitalization.words,
              decoration: InputDecoration(
                hintText: 'My name is...',
                hintStyle: TextStyle(
                    color: Colors.white.withValues(alpha: 0.25), fontSize: 18),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.all(18),
              ),
              onSubmitted: (_) => _next(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCharacterStep() {
    final name = _childNameCtrl.text.trim();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          Text(
            'Hi $name! ðŸŒŸ',
            style: const TextStyle(
                color: Colors.white,
                fontSize: 26,
                fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          Text(
            'Pick your friend who will be with you every day:',
            style: TextStyle(
                color: Colors.white.withValues(alpha: 0.60),
                fontSize: 15),
          ),
          const SizedBox(height: 24),
          ...List.generate(_characters.length, (i) {
            final c = _characters[i];
            final selected = _selectedCharacter == i;
            return GestureDetector(
              onTap: () => setState(() => _selectedCharacter = i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: selected
                      ? const Color(0xFFFF6FB0).withValues(alpha: 0.12)
                      : Colors.white.withValues(alpha: 0.04),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: selected
                        ? const Color(0xFFFF6FB0)
                        : Colors.white.withValues(alpha: 0.08),
                    width: 2,
                  ),
                ),
                child: Row(children: [
                  Image.asset(c['asset']!,
                      width: 60, height: 60, fit: BoxFit.contain),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(c['name']!,
                            style: TextStyle(
                                color: selected
                                    ? const Color(0xFFFF6FB0)
                                    : Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.w800)),
                        const SizedBox(height: 3),
                        Text(c['desc']!,
                            style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.5),
                                fontSize: 12)),
                      ],
                    ),
                  ),
                  if (selected)
                    const Icon(Icons.check_circle,
                        color: Color(0xFFFF6FB0), size: 22),
                ]),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildParentNameStep() {
    final name = _childNameCtrl.text.trim();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          const Text('ðŸ‘‹', style: TextStyle(fontSize: 40)),
          const SizedBox(height: 16),
          Text(
            'One last thing...',
            style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 10),
          Text(
            'Who is the grown-up looking after $name? This helps us personalise the parent dashboard.',
            style: TextStyle(
                color: Colors.white.withValues(alpha: 0.60),
                fontSize: 15,
                height: 1.5),
          ),
          const SizedBox(height: 32),
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                  color: Colors.white.withValues(alpha: 0.12)),
            ),
            child: TextField(
              controller: _parentNameCtrl,
              style: const TextStyle(
                  color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700),
              textCapitalization: TextCapitalization.words,
              decoration: InputDecoration(
                hintText: 'My name is...',
                hintStyle: TextStyle(
                    color: Colors.white.withValues(alpha: 0.25), fontSize: 18),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.all(18),
              ),
              onSubmitted: (_) => _next(),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'You can skip this',
            style: TextStyle(
                color: Colors.white.withValues(alpha: 0.28), fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildNextButton() {
    final canProceed = _step == 0
        ? _childNameCtrl.text.trim().isNotEmpty
        : true;

    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 12, 28, 32),
      child: GestureDetector(
        onTap: canProceed ? _next : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: double.infinity,
          height: 56,
          decoration: BoxDecoration(
            gradient: canProceed
                ? const LinearGradient(
                    colors: [Color(0xFFFF6FB0), Color(0xFFFF4081)])
                : null,
            color: canProceed ? null : Colors.white.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Center(
            child: Text(
              _step == 2 ? 'Let\'s go! ðŸš€' : 'Next â†’',
              style: TextStyle(
                color: canProceed
                    ? Colors.white
                    : Colors.white.withValues(alpha: 0.25),
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

