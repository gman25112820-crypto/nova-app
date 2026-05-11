import 'dart:math';
import 'package:flutter/material.dart';

class SafeCornerScene extends StatefulWidget {
  const SafeCornerScene({super.key});
  @override
  State<SafeCornerScene> createState() => _SafeCornerSceneState();
}

class _SafeCornerSceneState extends State<SafeCornerScene> with TickerProviderStateMixin {
  late AnimationController _glowCtrl;
  late AnimationController _floatCtrl;
  late AnimationController _sparkleCtrl;
  @override
  void initState() {
    super.initState();
    _glowCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat(reverse: true);
    _floatCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 3))..repeat(reverse: true);
    _sparkleCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 1))..repeat(reverse: true);
  }
  @override
  void dispose() {
    _glowCtrl.dispose(); _floatCtrl.dispose(); _sparkleCtrl.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_glowCtrl, _floatCtrl, _sparkleCtrl]),
      builder: (context, child) => ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: CustomPaint(
          painter: _SafeCornerPainter(glow: _glowCtrl.value, float: _floatCtrl.value, sparkle: _sparkleCtrl.value),
          child: const SizedBox.expand(),
        ),
      ),
    );
  }
}

class _SafeCornerPainter extends CustomPainter {
  final double glow, float, sparkle;
  const _SafeCornerPainter({required this.glow, required this.float, required this.sparkle});
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width; final h = size.height;
    canvas.drawRect(Offset.zero & size, Paint()..shader = LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [const Color(0xFF1A0A2E), const Color(0xFF2D1B4E), const Color(0xFF1A1035)]).createShader(Offset.zero & size));
    canvas.drawRect(Rect.fromLTWH(0, h*0.72, w, h*0.28), Paint()..color = const Color(0xFF2D1B4E));
    canvas.drawOval(Rect.fromCenter(center: Offset(w*0.4, h*0.82), width: w*0.55, height: h*0.16), Paint()..color = const Color(0xFF4A0E6B).withValues(alpha: 0.7));
    canvas.drawOval(Rect.fromCenter(center: Offset(w*0.4, h*0.82), width: w*0.4, height: h*0.10), Paint()..color = const Color(0xFF6A1E8B).withValues(alpha: 0.5));
    final rng = Random(33);
    for (int i = 0; i < 25; i++) {
      final t = (sin(sparkle*pi*2+i*0.8)+1)/2;
      canvas.drawCircle(Offset(rng.nextDouble()*w, rng.nextDouble()*h*0.5), 0.8+t*1.0, Paint()..color=Colors.white.withValues(alpha: 0.2+t*0.5));
    }
    final ox = w*0.75; final oy = h*0.3;
    canvas.drawCircle(Offset(ox,oy), 28+glow*8, Paint()..color=const Color(0xFFFFB6C1).withValues(alpha: 0.06+glow*0.06)..maskFilter=const MaskFilter.blur(BlurStyle.normal,20));
    canvas.drawCircle(Offset(ox,oy), 16+glow*3, Paint()..color=const Color(0xFFFFB6C1).withValues(alpha: 0.5+glow*0.3));
    canvas.drawCircle(Offset(ox,oy), 10, Paint()..color=Colors.white.withValues(alpha: 0.8));
    for (int i = 0; i < 6; i++) {
      final angle = i*pi/3 + sparkle*pi;
      final r = 22.0 + sin(sparkle*pi*2+i)*4;
      canvas.drawCircle(Offset(ox+cos(angle)*r, oy+sin(angle)*r), 1.5+sparkle, Paint()..color=const Color(0xFFFFD700).withValues(alpha: 0.4+sparkle*0.4));
    }
    void cushion(double cx, double cy, Color col, double scale) {
      canvas.drawOval(Rect.fromCenter(center: Offset(cx,cy), width: 28*scale, height: 18*scale), Paint()..color=col);
      canvas.drawOval(Rect.fromCenter(center: Offset(cx,cy), width: 20*scale, height: 12*scale), Paint()..color=col.withValues(alpha: 0.7));
      canvas.drawCircle(Offset(cx,cy), 2*scale, Paint()..color=Colors.white.withValues(alpha: 0.3));
    }
    cushion(w*0.15, h*0.75, const Color(0xFF7B1FA2), 1.0);
    cushion(w*0.32, h*0.78, const Color(0xFFAD1457), 0.85);
    cushion(w*0.22, h*0.70, const Color(0xFF4527A0), 0.7);
    for (int i = 0; i < 4; i++) {
      final hx = w*(0.1+i*0.2) + sin(float*pi*2+i*1.4)*8;
      final hy = h*(0.45+i*0.05) - float*h*0.08;
      final path = Path();
      path.moveTo(hx, hy+5); path.cubicTo(hx-8,hy-4,hx-8,hy-10,hx,hy-3); path.cubicTo(hx+8,hy-10,hx+8,hy-4,hx,hy+5);
      canvas.drawPath(path, Paint()..color=const Color(0xFFFF6B9D).withValues(alpha: 0.3+float*0.2));
    }
  }
  @override
  bool shouldRepaint(_SafeCornerPainter old) => true;
}