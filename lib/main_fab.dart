import 'package:flutter/material.dart';
import 'fab/fab_theme.dart';
import 'fab/widgets/chicken_lips_widget.dart';
import 'fab/widgets/fab_mood_bar.dart';
import 'fab/widgets/fab_world_painter.dart';
import 'fab/widgets/fab_characters_painter.dart';
import 'fab/screens/pain_screen.dart';
import 'fab/screens/recovery_screen.dart';
import 'fab/screens/nutrition_screen.dart';
import 'fab/screens/cooking_screen.dart';
import 'fab/screens/sleep_screen.dart';

void main() { runApp(const FabulouslyMeApp()); }

class FabulouslyMeApp extends StatelessWidget {
  const FabulouslyMeApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Fabulously Me',
    debugShowCheckedModeBanner: false,
    theme: FabTheme.theme,
    home: const HomeScreen(),
  );
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  ChickenLipsMood _mood = ChickenLipsMood.happy;
  late final AnimationController _worldAnim;

  @override
  void initState() {
    super.initState();
    _worldAnim = AnimationController(vsync: this, duration: const Duration(seconds: 20))..repeat();
  }

  @override
  void dispose() { _worldAnim.dispose(); super.dispose(); }

  void _push(Widget screen) => Navigator.push(context, MaterialPageRoute(builder: (_) => screen));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FabColors.bg,
      appBar: AppBar(
        backgroundColor: FabColors.mid, elevation: 0,
        title: Row(children: [
          ChickenLipsAvatar(mood: _mood, radius: 16),
          const SizedBox(width: 10),
          const Text('FABULOUSLY ME', style: TextStyle(color: FabColors.pink, fontSize: 15, fontWeight: FontWeight.w700, letterSpacing: 2)),
        ]),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 12),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(color: FabColors.gold.withOpacity(0.15), borderRadius: BorderRadius.circular(20), border: Border.all(color: FabColors.gold, width: 0.5)),
            child: const Text('FEELING FAB', style: TextStyle(color: FabColors.gold, fontSize: 9, fontWeight: FontWeight.w700, letterSpacing: 1.5)),
          ),
        ],
      ),
      body: Column(children: [
        SizedBox(
          height: 200,
          child: Stack(children: [
            AnimatedBuilder(
              animation: _worldAnim,
              builder: (_, __) => CustomPaint(
                painter: FabWorldPainter(animationValue: _worldAnim.value),
                size: Size(MediaQuery.of(context).size.width, 200),
              ),
            ),
            const FabCharactersWidget(),
          ]),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: FabColors.panel, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0x2EFF8FAB), width: 0.5)),
                child: Column(children: [
                  Row(children: [
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 400),
                      transitionBuilder: (child, anim) => ScaleTransition(scale: anim, child: child),
                      child: ChickenLipsWidget(key: ValueKey(_mood), mood: _mood, size: ChickenLipsSize.large, showSparkles: _mood == ChickenLipsMood.crowned || _mood == ChickenLipsMood.excited),
                    ),
                    const SizedBox(width: 16),
                    Expanded(child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: Text(_moodMessage, key: ValueKey(_mood), style: const TextStyle(color: FabColors.text, fontSize: 15, fontWeight: FontWeight.w500, height: 1.4)),
                    )),
                  ]),
                  const SizedBox(height: 14),
                  MoodBar(selected: _mood, onChanged: (m) => setState(() => _mood = m)),
                ]),
              ),
              const SizedBox(height: 16),
              const Text('QUICK LOG', style: TextStyle(fontSize: 10, color: FabColors.muted, letterSpacing: 1.5)),
              const SizedBox(height: 10),
              GridView.count(
                crossAxisCount: 2, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 10, crossAxisSpacing: 10, childAspectRatio: 2.2,
                children: [
                  _QuickBtn(icon: Icons.favorite_rounded, label: 'Pain Log', color: FabColors.rose, onTap: () => _push(const PainScreen())),
                  _QuickBtn(icon: Icons.healing_rounded, label: 'Recovery', color: FabColors.teal, onTap: () => _push(const RecoveryScreen())),
                  _QuickBtn(icon: Icons.restaurant_rounded, label: 'Nutrition', color: FabColors.gold, onTap: () => _push(const NutritionScreen())),
                  _QuickBtn(icon: Icons.nightlight_round, label: 'Sleep', color: FabColors.ice, onTap: () => _push(const SleepScreen())),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(color: FabColors.panel, borderRadius: BorderRadius.circular(14), border: Border.all(color: const Color(0x2EFF8FAB), width: 0.5)),
                child: Row(children: [
                  Container(width: 44, height: 44, decoration: BoxDecoration(color: FabColors.gold.withOpacity(0.15), shape: BoxShape.circle), child: const Center(child: Text('⭐', style: TextStyle(fontSize: 22)))),
                  const SizedBox(width: 12),
                  const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('Fab Stars', style: TextStyle(color: FabColors.text, fontSize: 14, fontWeight: FontWeight.w600)),
                    Text('Keep logging to earn stars!', style: TextStyle(color: FabColors.muted, fontSize: 12)),
                  ])),
                  const Text('0', style: TextStyle(color: FabColors.gold, fontSize: 22, fontWeight: FontWeight.w700)),
                ]),
              ),
            ]),
          ),
        ),
      ]),
    );
  }

  String get _moodMessage {
    switch (_mood) {
      case ChickenLipsMood.happy:   return 'Feeling fab today! 💜';
      case ChickenLipsMood.excited: return 'So much energy! ✨';
      case ChickenLipsMood.crowned: return 'Absolutely fabulous 👑';
      case ChickenLipsMood.neutral: return 'Just getting through it 💛';
      case ChickenLipsMood.sad:     return 'Rough day. That\'s okay 🌸';
      case ChickenLipsMood.sleepy:  return 'So tired... 😴';
    }
  }
}

class _QuickBtn extends StatelessWidget {
  final IconData icon; final String label; final Color color; final VoidCallback onTap;
  const _QuickBtn({required this.icon, required this.label, required this.color, required this.onTap});
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12), border: Border.all(color: color.withOpacity(0.3), width: 1)),
      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(icon, color: color, size: 18), const SizedBox(width: 8),
        Text(label, style: TextStyle(color: color, fontSize: 13, fontWeight: FontWeight.w600)),
      ]),
    ),
  );
}
