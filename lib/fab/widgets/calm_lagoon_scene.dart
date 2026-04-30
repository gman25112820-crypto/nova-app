import 'dart:math';
import 'package:flutter/material.dart';

class CalmLagoonScene extends StatefulWidget {
  const CalmLagoonScene({super.key});
  @override
  State<CalmLagoonScene> createState() => _CalmLagoonSceneState();
}

class _CalmLagoonSceneState extends State<CalmLagoonScene> with TickerProviderStateMixin {
  late AnimationController _waveCtrl;
  late AnimationController _glowCtrl;
  late AnimationController _turtleCtrl;
  @override
  void initState() {
    super.initState();
    _waveCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 3))..repeat();
    _glowCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat(reverse: true);
    _turtleCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 6))..repeat();
  }
  @override
  void dispose() {
    _waveCtrl.dispose(); _glowCtrl.dispose(); _turtleCtrl.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_waveCtrl, _glowCtrl, _turtleCtrl]),
      builder: (context, child) => ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: CustomPaint(
          painter: _CalmLagoonPainter(wave: _waveCtrl.value, glow: _glowCtrl.value, turtle: _turtleCtrl.value),
          child: const SizedBox.expand(),
        ),
      ),
    );
  }
}

class _CalmLagoonPainter extends CustomPainter {
  final double wave, glow, turtle;
  const _CalmLagoonPainter({required this.wave, required this.glow, required this.turtle});
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width; final h = size.height;
    canvas.drawRect(Offset.zero & size, Paint()..shader = LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [const Color(0xFF0A1628), const Color(0xFF0D3B6E), const Color(0xFF1A6B8A)]).createShader(Offset.zero & size));
    final rng = Random(11);
    for (int i = 0; i < 30; i++) {
      final t = (sin(wave * pi * 2 + i * 0.9) + 1) / 2;
      canvas.drawCircle(Offset(rng.nextDouble()*w, rng.nextDouble()*h*0.4), 0.7+t*0.8, Paint()..color = Colors.white.withOpacity(0.3+t*0.5));
    }
    canvas.drawRect(Rect.fromLTWH(0, h*0.5, w, h*0.5), Paint()..shader = LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [const Color(0xFF1A6B8A), const Color(0xFF0D4060)]).createShader(Rect.fromLTWH(0, h*0.5, w, h*0.5)));
    for (int i = 0; i < 3; i++) {
      final waveY = h * (0.5 + i * 0.12);
      final waveOffset = sin(wave * pi * 2 + i * 1.2) * 6;
      final path = Path()..moveTo(0, waveY + waveOffset);
      for (double x = 0; x <= w; x += 20) { path.lineTo(x, waveY + sin((x/w + wave) * pi * 4 + i) * 4 + waveOffset); }
      path.lineTo(w, h); path.lineTo(0, h); path.close();
      canvas.drawPath(path, Paint()..color = const Color(0xFF2196F3).withOpacity(0.15 - i * 0.04));
    }
    final mx = w*0.75; final my = h*0.2;
    canvas.drawCircle(Offset(mx,my), 12+glow*3, Paint()..color = const Color(0xFFFFE066).withOpacity(0.9));
    canvas.drawCircle(Offset(mx-4,my-1), 10, Paint()..color = const Color(0xFF0D3B6E));
    final tx = w*0.15 + turtle*w*0.7;
    final ty = h*0.62 + sin(turtle*pi*4)*6;
    final body = Paint()..color = const Color(0xFF4CAF50);
    canvas.drawOval(Rect.fromCenter(center: Offset(tx,ty), width: 22, height: 14), body);
    canvas.drawOval(Rect.fromCenter(center: Offset(tx,ty-1), width: 16, height: 11), Paint()..color = const Color(0xFF2E7D32));
    canvas.drawCircle(Offset(tx+10,ty-2), 5, body);
    canvas.drawCircle(Offset(tx+12,ty-3), 1.2, Paint()..color = Colors.black);
    for (final pos in [[0.2,0.75,0.8],[0.65,0.8,1.0],[0.45,0.72,0.6]]) {
      canvas.drawOval(Rect.fromCenter(center: Offset(pos[0]*w, pos[1]*h), width: 20*pos[2], height: 14*pos[2]), Paint()..color = const Color(0xFF388E3C).withOpacity(0.85));
    }
  }
  @override
  bool shouldRepaint(_CalmLagoonPainter old) => true;
}