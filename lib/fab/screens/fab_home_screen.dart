import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nova_app/fab/widgets/fab_world_scene.dart';
import 'package:nova_app/fab/widgets/calm_lagoon_scene.dart';
import 'package:nova_app/fab/widgets/dino_garden_scene.dart';
import 'package:nova_app/fab/widgets/sleep_nest_scene.dart';
import 'package:nova_app/fab/widgets/safe_corner_scene.dart';
import 'package:nova_app/fab/widgets/chicken_lips_widget.dart';
import 'package:nova_app/fab/screens/fab_check_in_screen.dart';
import 'package:nova_app/fab/screens/fab_parent_dashboard.dart';
import 'package:nova_app/fab/screens/fab_parent_dashboard.dart';

class FabHomeScreen extends StatefulWidget {
  const FabHomeScreen({super.key});

  @override
  State<FabHomeScreen> createState() => _FabHomeScreenState();
}

class _FabHomeScreenState extends State<FabHomeScreen> {
  int _stars = 0;
  bool _checkedInToday = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now().toIso8601String().substring(0, 10);
    setState(() {
      _stars = prefs.getInt('fab_stars') ?? 0;
      _checkedInToday = prefs.getBool('checkin_done_$today') ?? false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0820),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildAppBar(),
              _buildChickenLipsPanel(),
              const SizedBox(height: 600, child: FabWorldScene()),
              _buildStarsBar(),
              _buildMetricCards(),
              _buildZoneCards(),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNav(context),
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFF6C3CE1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Text('NOVA',
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 13,
                  letterSpacing: 1.5)),
        ),
        const SizedBox(width: 10),
        const Text('Fabulously Me',
            style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 16)),
        const Spacer(),
        // Stars counter
        if (_stars > 0)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF2D1B5E),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                  color: const Color(0xFFFFEC48).withValues(alpha: 0.4)),
            ),
            child: Row(children: [
              const Text('â­', style: TextStyle(fontSize: 12)),
              const SizedBox(width: 4),
              Text('$_stars',
                  style: const TextStyle(
                      color: Color(0xFFFFEC48),
                      fontSize: 13,
                      fontWeight: FontWeight.w800)),
            ]),
          ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0x66FFDB27),
            border: Border.all(color: const Color(0x66FFDB27)),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Text('+ Feeling Fab',
              style: TextStyle(
                  color: Color(0xFFFFEC48),
                  fontSize: 10,
                  fontWeight: FontWeight.w600)),
        ),
      ]),
    );
  }

  Widget _buildChickenLipsPanel() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF2D1B5E), Color(0xFF1A0E3A)],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color: const Color(0xFFFF6FB7).withValues(alpha: 0.3)),
        ),
        child: Row(children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Miss Chicken Lips',
                      style: TextStyle(
                          color: Color(0xFFFF6FB7),
                          fontSize: 16,
                          fontWeight: FontWeight.w800)),
                  const SizedBox(height: 4),
                  Text(
                    _checkedInToday
                        ? 'Great job checking in today! ðŸ’›'
                        : 'Always here for you',
                    style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.7),
                        fontSize: 11)),
                ],
              ),
            ),
          ),
          Image.asset('assets/images/chicken_lips.png',
              width: 220, height: 220, fit: BoxFit.contain),
        ]),
      ),
    );
  }

  Widget _buildStarsBar() {
    if (_stars == 0) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1035),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
              color: const Color(0xFFFFEC48).withValues(alpha: 0.2)),
        ),
        child: Row(children: [
          const Text('â­', style: TextStyle(fontSize: 22)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _stars == 1
                      ? 'You have 1 star!'
                      : 'You have $_stars stars!',
                  style: const TextStyle(
                      color: Color(0xFFFFEC48),
                      fontSize: 14,
                      fontWeight: FontWeight.w800)),
                Text(
                  'Keep checking in to collect more',
                  style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.45),
                      fontSize: 11)),
              ],
            ),
          ),
          // Star progress dots
          Row(
            children: List.generate(5, (i) {
              return Container(
                width: 10,
                height: 10,
                margin: const EdgeInsets.symmetric(horizontal: 2),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: i < (_stars % 5)
                      ? const Color(0xFFFFEC48)
                      : Colors.white.withValues(alpha: 0.12),
                ),
              );
            }),
          ),
        ]),
      ),
    );
  }

  Widget _buildMetricCards() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Row(children: [
        Expanded(
            child: _metricCard('Mood', '7.2', const Color(0xFF8B5CF6))),
        const SizedBox(width: 8),
        Expanded(
            child: _metricCard('Pain', '4.1', const Color(0xFFFFEC48))),
        const SizedBox(width: 8),
        Expanded(
            child: _metricCard('Energy', '6.8', const Color(0xFFFFF59E))),
      ]),
    );
  }

  Widget _metricCard(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1035),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label,
            style: TextStyle(
                color: color, fontSize: 11, fontWeight: FontWeight.w600)),
        const SizedBox(height: 4),
        Text(value,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w800)),
      ]),
    );
  }

  Widget _buildZoneCards() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(children: [
        Row(children: [
          Expanded(
              child: _zoneCard('Calm Lagoon', 'Slow down and find calm',
                  const CalmLagoonScene())),
          const SizedBox(width: 12),
          Expanded(
              child: _zoneCard('Dino Garden', 'Explore and grow',
                  const DinoGardenScene())),
        ]),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(
              child: _zoneCard('Sleep Nest', 'Wind down and rest',
                  const SleepNestScene())),
          const SizedBox(width: 12),
          Expanded(
              child: _zoneCard(
                  'Safe Corner', 'A quiet space', const SafeCornerScene())),
        ]),
      ]),
    );
  }

  Widget _zoneCard(String title, String subtitle, Widget scene) {
    return Container(
      height: 180,
      decoration: BoxDecoration(
        color: const Color(0xFF1A1035),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white12),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(children: [
          Positioned.fill(child: scene),
          Positioned(
            bottom: 0, left: 0, right: 0,
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black87],
                ),
              ),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 13)),
                    Text(subtitle,
                        style: const TextStyle(
                            color: Colors.white54, fontSize: 10)),
                    const SizedBox(height: 4),
                    const Text('Enter Zone',
                        style: TextStyle(
                            color: Color(0xFF88FF66),
                            fontSize: 10,
                            fontWeight: FontWeight.w600)),
                  ]),
            ),
          ),
        ]),
      ),
    );
  }

  Widget _buildBottomNav(BuildContext context) {
    return Container(
      height: 70,
      decoration: const BoxDecoration(
        color: Color(0xFF0D0820),
        border: Border(top: BorderSide(color: Colors.white12)),
      ),
      child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _navItem('Home', true, false),
            GestureDetector(
              onTap: () async {
                await Navigator.of(context).push(
                  MaterialPageRoute(
                      builder: (_) => const FabCheckInScreen()),
                );
                _loadData();
              },
              child: _navItem('Check-In', false, _checkedInToday),
            ),
            Container(
              width: 48, height: 48,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                    colors: [Color(0xFF9C27B0), Color(0xFFE91E63)]),
              ),
              child: const Icon(Icons.add, color: Colors.white, size: 28),
            ),
            _navItem('Insights', false, false),
            GestureDetector(onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const FabParentDashboard())), child: _navItem('Clinician', false, false)),
          ]),
    );
  }

  Widget _navItem(String label, bool active, bool done) {
    return Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      done
          ? const Text('âœ…', style: TextStyle(fontSize: 18))
          : Icon(Icons.circle,
              color: active
                  ? const Color(0xFF9C27B0)
                  : Colors.white24,
              size: 20),
      Text(label,
          style: TextStyle(
              color: active
                  ? const Color(0xFF9C27B0)
                  : Colors.white54,
              fontSize: 10)),
    ]);
  }
}


