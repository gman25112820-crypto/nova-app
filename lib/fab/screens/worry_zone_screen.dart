import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../services/fab_stars_service.dart';
import '../services/selected_child_service.dart';

// ─────────────────────────────────────────────────────────────
// WORRY ZONE SCREEN — Fabulously Me
// 5-step guided worry check-in. Saves WorryEntry to Hive 'worries'.
// ─────────────────────────────────────────────────────────────

// ── Model ────────────────────────────────────────────────────

class WorryEntry {
  final String id;
  final DateTime date;
  final String topic;              // School | Family | Friends | No worries
  final String? whatIf;            // null on No-worries path
  final List<String> bodySensations;
  final int intensity;             // 1–5; 0 for No-worries path
  final String? separationAnxiety; // Yes | Sometimes | No; null on skip

  const WorryEntry({
    required this.id,
    required this.date,
    required this.topic,
    this.whatIf,
    required this.bodySensations,
    required this.intensity,
    this.separationAnxiety,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'date': date.toIso8601String(),
        'topic': topic,
        'whatIf': whatIf,
        'bodySensations': bodySensations,
        'intensity': intensity,
        'separationAnxiety': separationAnxiety,
      };

  factory WorryEntry.fromJson(Map<String, dynamic> j) => WorryEntry(
        id: j['id'] as String,
        date: DateTime.parse(j['date'] as String),
        topic: j['topic'] as String,
        whatIf: j['whatIf'] as String?,
        bodySensations:
            List<String>.from((j['bodySensations'] as List?) ?? []),
        intensity: (j['intensity'] as num? ?? 0).toInt(),
        separationAnxiety: j['separationAnxiety'] as String?,
      );
}

// ── Screen ───────────────────────────────────────────────────

class WorryZoneScreen extends StatefulWidget {
  const WorryZoneScreen({super.key});

  @override
  State<WorryZoneScreen> createState() => _WorryZoneScreenState();
}

class _WorryZoneScreenState extends State<WorryZoneScreen>
    with SingleTickerProviderStateMixin {
  static const _bg     = Color(0xFF1A0A2E);
  static const _card   = Color(0xFF2D1B69);
  static const _purple = Color(0xFF6C63FF);
  static const _pink   = Color(0xFFFF6B8A);

  int _step = 0;

  String? _topic;
  String? _whatIf;
  final Set<String> _body = {};
  int _intensity = 0;
  String? _sepAnxiety;
  bool _saving = false;

  late final AnimationController _rewardCtrl;
  late final Animation<double> _rewardScale;

  static const _topicEmojis  = ['🏫', '👨‍👩‍👧', '👫', '😊'];
  static const _topicLabels  = ['School', 'Family', 'Friends', 'No worries'];
  static const _topicColors  = [
    Color(0xFFFF8C00),  // School — amber
    Color(0xFFE91E8C),  // Family — pink
    Color(0xFF4ECDC4),  // Friends — teal
    Color(0xFFFFD700),  // No worries — gold
  ];

  static const _whatIfs = [
    'What if something bad happens?',
    'What if someone is cross with me?',
    'What if I have to go somewhere new?',
  ];

  static const _bodyEmojis  = ['🤚', '🤢', '🔥', '💓', '😮‍💨', '🦵', '🌀'];
  static const _bodyLabels  = [
    'Sweaty hands',
    'Tummy ache',
    'Hot face',
    'Heart going fast',
    'Hard to breathe',
    'Shaky legs',
    "Can't stop thinking",
  ];

  static const _sepEmojis  = ['😨', '😐', '😊'];
  static const _sepLabels  = ['Yes', 'Sometimes', 'No'];

  @override
  void initState() {
    super.initState();
    _rewardCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _rewardScale = CurvedAnimation(
      parent: _rewardCtrl,
      curve: Curves.elasticOut,
    );
  }

  @override
  void dispose() {
    _rewardCtrl.dispose();
    super.dispose();
  }

  // ── Persistence ───────────────────────────────────────────

  Future<void> _save() async {
    if (_saving) return;
    setState(() => _saving = true);
    final entry = WorryEntry(
      id: 'worry_${DateTime.now().millisecondsSinceEpoch}',
      date: DateTime.now(),
      topic: _topic ?? 'No worries',
      whatIf: _whatIf,
      bodySensations: _body.toList(),
      intensity: _intensity,
      separationAnxiety: _sepAnxiety,
    );
    final child = SelectedChildService.current ?? SelectedChildService.selectDefault();
    final box = Hive.box<Map>('worries');
    await box.put('${child?.id ?? ''}_${entry.id}', entry.toJson());
    await FabStarsService.awardForPainEntry();
    if (!mounted) return;
    setState(() {
      _saving = false;
      _step = 5;
    });
    _rewardCtrl.forward();
  }

  Future<void> _skipToReward() async {
    _topic = 'No worries';
    await _save();
  }

  void _next() => setState(() => _step++);

  // ── Build ─────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: _step < 5
          ? AppBar(
              backgroundColor: _bg,
              iconTheme: const IconThemeData(color: Colors.white),
              elevation: 0,
              title: _buildProgressDots(),
              centerTitle: true,
            )
          : null,
      body: SafeArea(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 320),
          transitionBuilder: (child, anim) => FadeTransition(
            opacity: anim,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.06, 0),
                end: Offset.zero,
              ).animate(anim),
              child: child,
            ),
          ),
          child: _buildStep(),
        ),
      ),
    );
  }

  Widget _buildProgressDots() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (i) {
        final active = i == _step;
        final done   = i < _step;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 3),
          width: active ? 22 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: (done || active)
                ? _purple
                : Colors.white.withValues(alpha: 0.20),
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }

  Widget _buildStep() {
    switch (_step) {
      case 0:  return _buildStep0();
      case 1:  return _buildStep1();
      case 2:  return _buildStep2();
      case 3:  return _buildStep3();
      case 4:  return _buildStep4();
      default: return _buildReward();
    }
  }

  // ── Step 0: Topic — horizontal-scroll color-coded cards ──────

  Widget _buildStep0() {
    return SingleChildScrollView(
      key: const ValueKey(0),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "What's on your mind?",
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w800,
              fontFamily: 'DM Sans',
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Tap what feels right',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.55),
              fontSize: 14,
              fontFamily: 'DM Sans',
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 160,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _topicLabels.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (_, i) {
                final label     = _topicLabels[i];
                final emoji     = _topicEmojis[i];
                final color     = _topicColors[i];
                final noWorries = label == 'No worries';
                return GestureDetector(
                  onTap: () {
                    _topic = label;
                    if (noWorries) {
                      _skipToReward();
                    } else {
                      _next();
                    }
                  },
                  child: Container(
                    width: 130,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: color.withValues(alpha: 0.55),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: color.withValues(alpha: 0.18),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(emoji, style: const TextStyle(fontSize: 44)),
                        const SizedBox(height: 10),
                        Text(
                          label,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: color,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            fontFamily: 'DM Sans',
                          ),
                        ),
                        if (noWorries) ...[
                          const SizedBox(height: 4),
                          Text(
                            'Tap to skip',
                            style: TextStyle(
                              color: color.withValues(alpha: 0.65),
                              fontSize: 11,
                              fontFamily: 'DM Sans',
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ── Step 1: What if ───────────────────────────────────────

  Widget _buildStep1() {
    return _stepShell(
      key: const ValueKey(1),
      title: 'What are you worried about?',
      child: Column(
        children: _whatIfs.map((wif) {
          final sel = _whatIf == wif;
          return GestureDetector(
            onTap: () {
              setState(() => _whatIf = wif);
              Future.delayed(
                  const Duration(milliseconds: 260), _next);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: sel ? _purple.withValues(alpha: 0.22) : _card,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: sel
                      ? _purple
                      : Colors.white.withValues(alpha: 0.12),
                  width: sel ? 2 : 1,
                ),
              ),
              child: Row(children: [
                Text(sel ? '✅' : '🤔',
                    style: const TextStyle(fontSize: 22)),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    wif,
                    style: TextStyle(
                      color: sel ? Colors.white : Colors.white70,
                      fontSize: 15,
                      fontWeight:
                          sel ? FontWeight.w700 : FontWeight.w500,
                      fontFamily: 'DM Sans',
                    ),
                  ),
                ),
              ]),
            ),
          );
        }).toList(),
      ),
    );
  }

  // ── Step 2: Body feelings ─────────────────────────────────

  Widget _buildStep2() {
    return _stepShell(
      key: const ValueKey(2),
      title: 'My body feels...',
      subtitle: 'Tap everything you feel right now',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: List.generate(_bodyLabels.length, (i) {
              final label = _bodyLabels[i];
              final emoji = _bodyEmojis[i];
              final sel   = _body.contains(label);
              return GestureDetector(
                onTap: () => setState(() {
                  if (sel) {
                    _body.remove(label);
                  } else {
                    _body.add(label);
                  }
                }),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 160),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: sel
                        ? _purple.withValues(alpha: 0.22)
                        : _card,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: sel
                          ? _purple
                          : Colors.white.withValues(alpha: 0.15),
                      width: sel ? 1.5 : 1,
                    ),
                  ),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Text(emoji,
                        style: TextStyle(fontSize: sel ? 18 : 15)),
                    const SizedBox(width: 6),
                    Text(
                      label,
                      style: TextStyle(
                        color: sel ? _purple : Colors.white60,
                        fontSize: 13,
                        fontWeight: sel
                            ? FontWeight.w700
                            : FontWeight.normal,
                        fontFamily: 'DM Sans',
                      ),
                    ),
                  ]),
                ),
              );
            }),
          ),
          const SizedBox(height: 24),
          _nextButton(
            enabled: true,
            label: _body.isEmpty ? 'Skip' : 'Next',
          ),
        ],
      ),
    );
  }

  // ── Step 3: Intensity ─────────────────────────────────────

  Widget _buildStep3() {
    return _stepShell(
      key: const ValueKey(3),
      title: 'How worried are you?',
      subtitle: 'Tap the stars',
      child: Column(
        children: [
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(5, (i) {
              final n      = i + 1;
              final filled = n <= _intensity;
              return GestureDetector(
                onTap: () => setState(() => _intensity = n),
                child: Icon(
                  filled
                      ? Icons.star_rounded
                      : Icons.star_outline_rounded,
                  color: filled
                      ? const Color(0xFFFFD700)
                      : Colors.white24,
                  size: filled ? 56 : 44,
                ),
              );
            }),
          ),
          const SizedBox(height: 16),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: _intensity > 0
                ? Text(
                    _intensityLabel(_intensity),
                    key: ValueKey(_intensity),
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 15,
                      fontFamily: 'DM Sans',
                    ),
                  )
                : const SizedBox(height: 22),
          ),
          const SizedBox(height: 28),
          _nextButton(enabled: _intensity > 0),
        ],
      ),
    );
  }

  String _intensityLabel(int n) {
    const labels = [
      'Just a little',
      'A bit worried',
      'Quite worried',
      'Very worried',
      'Super worried',
    ];
    return labels[(n - 1).clamp(0, 4)];
  }

  // ── Step 4: Separation anxiety ────────────────────────────

  Widget _buildStep4() {
    return _stepShell(
      key: const ValueKey(4),
      title: 'Do you feel scared when someone leaves?',
      child: Column(
        children: [
          const SizedBox(height: 8),
          ...List.generate(_sepLabels.length, (i) {
            final label = _sepLabels[i];
            final emoji = _sepEmojis[i];
            final sel   = _sepAnxiety == label;
            return GestureDetector(
              onTap: () {
                setState(() => _sepAnxiety = label);
                Future.delayed(const Duration(milliseconds: 300), _save);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.symmetric(
                    vertical: 18, horizontal: 20),
                decoration: BoxDecoration(
                  color: sel ? _pink.withValues(alpha: 0.18) : _card,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: sel
                        ? _pink
                        : Colors.white.withValues(alpha: 0.12),
                    width: sel ? 2 : 1,
                  ),
                ),
                child: Row(children: [
                  Text(emoji,
                      style: TextStyle(fontSize: sel ? 32 : 26)),
                  const SizedBox(width: 16),
                  Text(
                    label,
                    style: TextStyle(
                      color: sel ? Colors.white : Colors.white70,
                      fontSize: 18,
                      fontWeight:
                          sel ? FontWeight.w700 : FontWeight.w500,
                      fontFamily: 'DM Sans',
                    ),
                  ),
                ]),
              ),
            );
          }),
          if (_saving) ...[
            const SizedBox(height: 20),
            const CircularProgressIndicator(color: _purple),
          ],
        ],
      ),
    );
  }

  // ── Reward ────────────────────────────────────────────────

  Widget _buildReward() {
    return Container(
      key: const ValueKey(5),
      color: _bg,
      child: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ScaleTransition(
                  scale: _rewardScale,
                  child: const Text('⭐',
                      style: TextStyle(fontSize: 84)),
                ),
                const SizedBox(height: 28),
                const Text(
                  'Well done!',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                    fontFamily: 'DM Sans',
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'You told someone how you feel.\nThat takes real courage! 💜',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.75),
                    fontSize: 16,
                    height: 1.55,
                    fontFamily: 'DM Sans',
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 18, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFD700).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: const Color(0xFFFFD700)
                          .withValues(alpha: 0.40),
                    ),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('⭐', style: TextStyle(fontSize: 18)),
                      SizedBox(width: 8),
                      Text(
                        '+1 Fab Star earned!',
                        style: TextStyle(
                          color: Color(0xFFFFD700),
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'DM Sans',
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: _purple,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text(
                      'Back to my world',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'DM Sans',
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Shared widgets ────────────────────────────────────────

  Widget _stepShell({
    required Key key,
    required String title,
    String? subtitle,
    required Widget child,
  }) {
    return SingleChildScrollView(
      key: key,
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w800,
              fontFamily: 'DM Sans',
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 6),
            Text(
              subtitle,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.55),
                fontSize: 14,
                fontFamily: 'DM Sans',
              ),
            ),
          ],
          const SizedBox(height: 24),
          child,
        ],
      ),
    );
  }

  Widget _nextButton({required bool enabled, String label = 'Next'}) {
    return SizedBox(
      width: double.infinity,
      child: FilledButton(
        style: FilledButton.styleFrom(
          backgroundColor: enabled ? _purple : Colors.white12,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14)),
        ),
        onPressed: enabled ? _next : null,
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            fontFamily: 'DM Sans',
          ),
        ),
      ),
    );
  }
}
