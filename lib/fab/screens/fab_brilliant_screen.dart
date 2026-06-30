import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ─────────────────────────────────────────────────────────────
// BRILLIANT SCREEN
// Weekly strength-based reflection tool
// What's brilliant, what's not so brilliant, what would make
// things more brilliant — plus How Fabulous are you moment
// ─────────────────────────────────────────────────────────────

class FabBrilliantScreen extends StatefulWidget {
  const FabBrilliantScreen({super.key});

  @override
  State<FabBrilliantScreen> createState() => _FabBrilliantScreenState();
}

class _FabBrilliantScreenState extends State<FabBrilliantScreen>
    with TickerProviderStateMixin {
  int _step = 0;
  String _childName = 'You';
  final TextEditingController _brilliantCtrl = TextEditingController();
  final TextEditingController _notBrilliantCtrl = TextEditingController();
  final TextEditingController _moreBrilliantCtrl = TextEditingController();
  final List<String> _fabulousSelected = [];
  bool _done = false;

  late final AnimationController _celebCtrl;
  late final Animation<double> _celebAnim;

  final List<Map<String, String>> _fabulousTraits = [
    {'emoji': 'kind', 'label': 'Kind'},
    {'emoji': 'brave', 'label': 'Brave'},
    {'emoji': 'funny', 'label': 'Funny'},
    {'emoji': 'caring', 'label': 'Caring'},
    {'emoji': 'creative', 'label': 'Creative'},
    {'emoji': 'smart', 'label': 'Smart'},
    {'emoji': 'strong', 'label': 'Strong'},
    {'emoji': 'helpful', 'label': 'Helpful'},
    {'emoji': 'curious', 'label': 'Curious'},
    {'emoji': 'honest', 'label': 'Honest'},
    {'emoji': 'loving', 'label': 'Loving'},
    {'emoji': 'resilient', 'label': 'Resilient'},
  ];

  @override
  void initState() {
    super.initState();
    _celebCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _celebAnim = CurvedAnimation(parent: _celebCtrl, curve: Curves.elasticOut);
    _loadName();
  }

  Future<void> _loadName() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _childName = prefs.getString('child_name') ?? 'You';
    });
  }

  @override
  void dispose() {
    _celebCtrl.dispose();
    _brilliantCtrl.dispose();
    _notBrilliantCtrl.dispose();
    _moreBrilliantCtrl.dispose();
    super.dispose();
  }

  Future<void> _saveAndFinish() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now().toIso8601String().substring(0, 10);
    await prefs.setString('brilliant_good_$today', _brilliantCtrl.text.trim());
    await prefs.setString('brilliant_hard_$today', _notBrilliantCtrl.text.trim());
    await prefs.setString('brilliant_wish_$today', _moreBrilliantCtrl.text.trim());
    await prefs.setString('brilliant_traits_$today', _fabulousSelected.join(','));
    final stars = prefs.getInt('fab_stars') ?? 0;
    await prefs.setInt('fab_stars', stars + 1);
    setState(() => _done = true);
    _celebCtrl.forward();
  }

  void _next() {
    if (_step < 3) {
      setState(() => _step++);
    } else {
      _saveAndFinish();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_done) return _buildCelebration();

    return Scaffold(
      backgroundColor: const Color(0xFF0D0820),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            _buildProgressBar(),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (child, anim) => SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0.08, 0),
                    end: Offset.zero,
                  ).animate(CurvedAnimation(parent: anim, curve: Curves.easeOut)),
                  child: FadeTransition(opacity: anim, child: child),
                ),
                child: _buildStep(),
              ),
            ),
            _buildNextButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Row(children: [
        GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: Container(
            width: 38, height: 38,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.arrow_back_ios_new,
                color: Colors.white, size: 16),
          ),
        ),
        const SizedBox(width: 14),
        const Text('Good Things',
            style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w800)),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: const Color(0xFFFFEC48).withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(99),
          ),
          child: const Text('Weekly',
              style: TextStyle(
                  color: Color(0xFFFFEC48),
                  fontSize: 10,
                  fontWeight: FontWeight.w700)),
        ),
      ]),
    );
  }

  Widget _buildProgressBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: List.generate(4, (i) {
          return Expanded(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              height: 6,
              decoration: BoxDecoration(
                gradient: i <= _step
                    ? const LinearGradient(
                        colors: [Color(0xFFFFEC48), Color(0xFFFF9800)])
                    : null,
                color: i <= _step
                    ? null
                    : Colors.white.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(99),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildStep() {
    switch (_step) {
      case 0: return _buildBrilliantStep();
      case 1: return _buildNotBrilliantStep();
      case 2: return _buildMoreBrilliantStep();
      case 3: return _buildHowFabulousStep();
      default: return const SizedBox.shrink();
    }
  }

  Widget _buildBrilliantStep() {
    return Padding(
      key: const ValueKey('brilliant'),
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF1A3A1A),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                  color: const Color(0xFF4CAF50).withValues(alpha: 0.4)),
            ),
            child: Row(children: [
              const Text('House of\nGood Things',
                  style: TextStyle(
                      color: Color(0xFF4CAF50),
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      height: 1.3)),
              const Spacer(),
              Container(
                width: 48, height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFF4CAF50).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.home, color: Color(0xFF4CAF50), size: 28),
              ),
            ]),
          ),
          const SizedBox(height: 20),
          Text(
            'What\'s brilliant in your life right now, $_childName?',
            style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w800,
                height: 1.3),
          ),
          const SizedBox(height: 8),
          Text(
            'Things that make you happy, people you love, stuff you\'re proud of',
            style: TextStyle(
                color: Colors.white.withValues(alpha: 0.50),
                fontSize: 13,
                height: 1.4),
          ),
          const SizedBox(height: 20),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF4CAF50).withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                  color: const Color(0xFF4CAF50).withValues(alpha: 0.25)),
            ),
            child: TextField(
              controller: _brilliantCtrl,
              style: const TextStyle(color: Colors.white, fontSize: 16),
              maxLines: 5,
              decoration: InputDecoration(
                hintText: 'The brilliant things in my life are...',
                hintStyle: TextStyle(
                    color: Colors.white.withValues(alpha: 0.25), fontSize: 14),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.all(16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotBrilliantStep() {
    return Padding(
      key: const ValueKey('notbrilliant'),
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF3A1A1A),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                  color: const Color(0xFFFF5252).withValues(alpha: 0.4)),
            ),
            child: Row(children: [
              const Text('House of\nWorries',
                  style: TextStyle(
                      color: Color(0xFFFF5252),
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      height: 1.3)),
              const Spacer(),
              Container(
                width: 48, height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFFFF5252).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.home, color: Color(0xFFFF5252), size: 28),
              ),
            ]),
          ),
          const SizedBox(height: 20),
          const Text(
            'What\'s not so brilliant right now?',
            style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w800,
                height: 1.3),
          ),
          const SizedBox(height: 8),
          Text(
            'Worries, things that feel hard, stuff that\'s bothering you — it\'s safe to say it here',
            style: TextStyle(
                color: Colors.white.withValues(alpha: 0.50),
                fontSize: 13,
                height: 1.4),
          ),
          const SizedBox(height: 20),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFFF5252).withValues(alpha: 0.04),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                  color: const Color(0xFFFF5252).withValues(alpha: 0.20)),
            ),
            child: TextField(
              controller: _notBrilliantCtrl,
              style: const TextStyle(color: Colors.white, fontSize: 16),
              maxLines: 5,
              decoration: InputDecoration(
                hintText: 'Things that feel hard or worrying are...',
                hintStyle: TextStyle(
                    color: Colors.white.withValues(alpha: 0.25), fontSize: 14),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.all(16),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'You can skip this if you\'re not ready',
            style: TextStyle(
                color: Colors.white.withValues(alpha: 0.28), fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildMoreBrilliantStep() {
    return Padding(
      key: const ValueKey('morebrilliant'),
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A3A),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                  color: const Color(0xFF6FB7FF).withValues(alpha: 0.4)),
            ),
            child: Row(children: [
              const Text('House of\nDreams',
                  style: TextStyle(
                      color: Color(0xFF6FB7FF),
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      height: 1.3)),
              const Spacer(),
              Container(
                width: 48, height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFF6FB7FF).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.home, color: Color(0xFF6FB7FF), size: 28),
              ),
            ]),
          ),
          const SizedBox(height: 20),
          const Text(
            'What would make things more brilliant?',
            style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w800,
                height: 1.3),
          ),
          const SizedBox(height: 8),
          Text(
            'Wishes, hopes, things you\'d love to happen — dream big',
            style: TextStyle(
                color: Colors.white.withValues(alpha: 0.50),
                fontSize: 13,
                height: 1.4),
          ),
          const SizedBox(height: 20),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF6FB7FF).withValues(alpha: 0.04),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                  color: const Color(0xFF6FB7FF).withValues(alpha: 0.20)),
            ),
            child: TextField(
              controller: _moreBrilliantCtrl,
              style: const TextStyle(color: Colors.white, fontSize: 16),
              maxLines: 5,
              decoration: InputDecoration(
                hintText: 'Things that would make life more brilliant...',
                hintStyle: TextStyle(
                    color: Colors.white.withValues(alpha: 0.25), fontSize: 14),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.all(16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHowFabulousStep() {
    return SingleChildScrollView(
      key: const ValueKey('howfabulous'),
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF2D1B5E), Color(0xFF1A0E3A)],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                  color: const Color(0xFFFF6FB7).withValues(alpha: 0.4)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Image.asset('assets/images/chicken_lips.png',
                      width: 48, height: 48),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      '$_childName, you are absolutely fabulous. Pick the words that describe you:',
                      style: const TextStyle(
                          color: Color(0xFFFF6FB7),
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          height: 1.4),
                    ),
                  ),
                ]),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'How Fabulous Are You?',
            style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 6),
          Text(
            'Pick as many as feel true — they\'re all true',
            style: TextStyle(
                color: Colors.white.withValues(alpha: 0.50), fontSize: 13),
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _fabulousTraits.map((trait) {
              final selected = _fabulousSelected.contains(trait['label']);
              return GestureDetector(
                onTap: () {
                  setState(() {
                    if (selected) {
                      _fabulousSelected.remove(trait['label']);
                    } else {
                      _fabulousSelected.add(trait['label']!);
                    }
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    gradient: selected
                        ? const LinearGradient(
                            colors: [Color(0xFFFF6FB0), Color(0xFFFF4081)])
                        : null,
                    color: selected
                        ? null
                        : Colors.white.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(99),
                    border: Border.all(
                      color: selected
                          ? Colors.transparent
                          : Colors.white.withValues(alpha: 0.10),
                    ),
                  ),
                  child: Text(
                    trait['label']!,
                    style: TextStyle(
                      color: selected
                          ? Colors.white
                          : Colors.white.withValues(alpha: 0.60),
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildNextButton() {
    final isLast = _step == 3;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
      child: GestureDetector(
        onTap: _next,
        child: Container(
          width: double.infinity,
          height: 56,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
                colors: [Color(0xFFFFEC48), Color(0xFFFF9800)]),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Center(
            child: Text(
              isLast ? 'I am fabulous!' : 'Next',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCelebration() {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0820),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ScaleTransition(
                scale: _celebAnim,
                child: Image.asset(
                  'assets/images/chicken_lips.png',
                  width: 130, height: 130,
                ),
              ),
              const SizedBox(height: 24),
              ScaleTransition(
                scale: _celebAnim,
                child: Text(
                  '$_childName, you are brilliant!',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.w800),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 12),
              if (_fabulousSelected.isNotEmpty) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Text(
                    '$_childName is: ${_fabulousSelected.join(', ')}',
                    style: const TextStyle(
                        color: Color(0xFFFF6FB7),
                        fontSize: 15,
                        fontWeight: FontWeight.w600),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 12),
              ],
              Text(
                'You earned a star!',
                style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.55),
                    fontSize: 15),
              ),
              const SizedBox(height: 48),
              GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 40, vertical: 16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                        colors: [Color(0xFFFF6FB0), Color(0xFFFF4081)]),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Text(
                    'Back to home',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.w800),
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
