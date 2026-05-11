import 'package:flutter/material.dart';
import 'fab_world_painter.dart';
import 'fab_characters_painter.dart';

class FabHomeScreen extends StatefulWidget {
  const FabHomeScreen({super.key});

  @override
  State<FabHomeScreen> createState() => _FabHomeScreenState();
}

class _FabHomeScreenState extends State<FabHomeScreen>
    with TickerProviderStateMixin {

  late AnimationController _worldController;

  @override
  void initState() {
    super.initState();
    _worldController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();
  }

  @override
  void dispose() {
    _worldController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBuilder(
        animation: _worldController,
        builder: (context, child) {
          return CustomPaint(
            painter: FabWorldPainter(
              animationValue: _worldController.value,
            ),
            child: const FabCharactersWidget(),
          );
        },
      ),
    );
  }
}
