import 'package:flutter/material.dart';
import 'package:nova_app/fab/widgets/fab_world_scene.dart';
import 'package:nova_app/fab/widgets/calm_lagoon_scene.dart';
import 'package:nova_app/fab/widgets/dino_garden_scene.dart';
import 'package:nova_app/fab/widgets/sleep_nest_scene.dart';
import 'package:nova_app/fab/widgets/safe_corner_scene.dart';

class FabHomeScreen extends StatelessWidget {
  const FabHomeScreen({super.key});

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
              const SizedBox(height: 220, child: FabWorldScene()),
              _buildMetricCards(),
              _buildZoneCards(),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
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
          child: const Text('NOVA', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 1.5)),
        ),
        const SizedBox(width: 10),
        const Text('Fabulously Me', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16)),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0x66FFDB27),
            border: Border.all(color: const Color(0x66FFDB27)),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Text('+ Feeling Fab', style: TextStyle(color: Color(0xFFFFEC48), fontSize: 10, fontWeight: FontWeight.w600)),
        ),
      ]),
    );
  }

  Widget _buildMetricCards() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Row(children: [
        Expanded(child: _metricCard('Mood', '7.2', const Color(0xFF8B5CF6))),
        const SizedBox(width: 8),
        Expanded(child: _metricCard('Pain', '4.1', const Color(0xFFFFEC48))),
        const SizedBox(width: 8),
        Expanded(child: _metricCard('Energy', '6.8', const Color(0xFFFFF59E))),
      ]),
    );
  }

  Widget _metricCard(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1035),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800)),
      ]),
    );
  }
 Widget _buildZoneCards() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(children: [
        Row(children: [
          Expanded(child: _zoneCard('Calm Lagoon', 'Slow down and find calm', const CalmLagoonScene())),
          const SizedBox(width: 12),
          Expanded(child: _zoneCard('Dino Garden', 'Explore and grow', const DinoGardenScene())),
        ]),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(child: _zoneCard('Sleep Nest', 'Wind down and rest', const SleepNestScene())),
          const SizedBox(width: 12),
          Expanded(child: _zoneCard('Safe Corner', 'A quiet space', const SafeCornerScene())),
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
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13)),
                Text(subtitle, style: const TextStyle(color: Colors.white54, fontSize: 10)),
                const SizedBox(height: 4),
                const Text('Enter Zone', style: TextStyle(color: Color(0xFF88FF66), fontSize: 10, fontWeight: FontWeight.w600)),
              ]),
            ),
          ),
        ]),
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      height: 70,
      decoration: const BoxDecoration(
        color: Color(0xFF0D0820),
        border: Border(top: BorderSide(color: Colors.white12)),
      ),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
        _navItem('Home', true),
        _navItem('Check-In', false),
        Container(
          width: 48, height: 48,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(colors: [Color(0xFF9C27B0), Color(0xFFE91E63)]),
          ),
          child: const Icon(Icons.add, color: Colors.white, size: 28),
        ),
        _navItem('Insights', false),
        _navItem('Clinician', false),
      ]),
    );
  }

  Widget _navItem(String label, bool active) {
    return Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Icon(Icons.circle, color: active ? const Color(0xFF9C27B0) : Colors.white24, size: 20),
      Text(label, style: TextStyle(color: active ? const Color(0xFF9C27B0) : Colors.white54, fontSize: 10)),
    ]);
  }
}