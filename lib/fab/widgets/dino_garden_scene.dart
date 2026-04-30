import 'dart:math';
import 'package:flutter/material.dart';

class DinoGardenScene extends StatefulWidget {
  const DinoGardenScene({super.key});
  @override
  State<DinoGardenScene> createState() => _DinoGardenSceneState();
}

class _DinoGardenSceneState extends State<DinoGardenScene> with TickerProviderStateMixin {
  late AnimationController _bounceCtrl;
  late AnimationController _eggCtrl;
  late AnimationController _leafCtrl;
  @override
  void initState() {
    super.initState();
    _bounceCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat(reverse: true);
    _eggCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 900))..repeat(reverse: true);
    _leafCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 4))..repeat();
  }
  @override
  void dispose() {
    _bounceCtrl.dispose(); _eggCtrl.dispose(); _leafCtrl.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_bounceCtrl, _eggCtrl, _leafCtrl]),
      builder: (context, child) => ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: CustomPaint(
          painter: _DinoGardenPainter(bounce: _bounceCtrl.value, egg: _eggCtrl.value, leaf: _leafCtrl.value),
          child: const SizedBox.expand(),
        ),
      ),
    );
  }
}

class _DinoGardenPainter extends CustomPainter {
  final double bounce, egg, leaf;
  const _DinoGardenPainter({required this.bounce, required this.egg, required this.leaf});
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width; final h = size.height;
    canvas.drawRect(Offset.zero & size, Paint()..shader = LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [const Color(0xFF1A2744), const Color(0xFF2D4A6B), const Color(0xFF3D6B4A)]).createShader(Offset.zero & size));
    canvas.drawRect(Rect.fromLTWH(0, h*0.65, w, h*0.35), Paint()..color = const Color(0xFF2E5A2E));
    canvas.drawRect(Rect.fromLTWH(0, h*0.75, w, h*0.25), Paint()..color = const Color(0xFF3A7A3A));
    canvas.drawRect(Rect.fromLTWH(0, h*0.85, w, h*0.15), Paint()..color = const Color(0xFF4A9A4A));
    void fern(double cx, double cy, double scale, double phase) {
      final p = Paint()..color = const Color(0xFF2E7D32)..strokeWidth = 1.5..style = PaintingStyle.stroke..strokeCap = StrokeCap.round;
      for (int i = -2; i <= 2; i++) {
        final angle = -pi/2 + i*0.4 + sin(phase*pi*2)*0.1;
        canvas.drawLine(Offset(cx,cy), Offset(cx+cos(angle)*18*scale, cy+sin(angle)*18*scale), p);
      }
    }
    fern(w*0.05, h*0.65, 0.8, leaf);
    fern(w*0.85, h*0.65, 1.0, leaf+0.3);
    fern(w*0.45, h*0.68, 0.6, leaf+0.6);
    final ecx = w*0.3; final ecy = h*0.72;
    final np = Paint()..color = const Color(0xFF5D4037)..style = PaintingStyle.stroke..strokeWidth = 2.5..strokeCap = StrokeCap.round;
    for (int i = -3; i <= 3; i++) { canvas.drawArc(Rect.fromCenter(center: Offset(ecx+i*4, ecy+4), width: 22, height: 9), 0, pi, false, np); }
    void drawEgg(double ex, double ey, Color col, double rx) {
      canvas.drawPath(Path()..moveTo(ex,ey-rx*1.35)..cubicTo(ex+rx*0.9,ey-rx*1.35,ex+rx,ey+rx*0.6,ex,ey+rx)..cubicTo(ex-rx,ey+rx*0.6,ex-rx*0.9,ey-rx*1.35,ex,ey-rx*1.35), Paint()..color=col);
    }
    drawEgg(ecx-14, ecy-6, const Color(0xFF81C784), 8);
    drawEgg(ecx+14, ecy-4, const Color(0xFF64B5F6), 8);
    final wb = sin(egg*pi*2)*3;
    drawEgg(ecx, ecy+2+wb*0.3, const Color(0xFFD4A843), 10);
    canvas.drawLine(Offset(ecx,ecy-10+wb*0.2), Offset(ecx+4,ecy-5+wb*0.2), Paint()..color=const Color(0xFF2D1B5E)..strokeWidth=1.5..style=PaintingStyle.stroke);
    canvas.drawOval(Rect.fromCenter(center: Offset(ecx, ecy-16+wb*0.2), width: 10, height: 8), Paint()..color = const Color(0xFF66BB6A));
    canvas.drawCircle(Offset(ecx+2, ecy-18+wb*0.2), 1.8, Paint()..color = Colors.black);
    canvas.drawCircle(Offset(ecx+2.5, ecy-18.4+wb*0.2), 0.6, Paint()..color = Colors.white);
    final bdy = h*0.58 - bounce*12;
    final body = Paint()..color = const Color(0xFF66BB6A);
    canvas.drawOval(Rect.fromCenter(center: Offset(w*0.68,bdy), width: 20, height: 14), body);
    canvas.drawOval(Rect.fromCenter(center: Offset(w*0.68+9,bdy-4), width: 14, height: 10), body);
    canvas.drawCircle(Offset(w*0.68+15,bdy-5), 1.8, Paint()..color = Colors.black);
    canvas.drawCircle(Offset(w*0.68+15.5,bdy-5.4), 0.6, Paint()..color = Colors.white);
    for (final fp in [[0.15,0.78],[0.75,0.76],[0.55,0.80]]) {
      final col = fp[0] > 0.5 ? const Color(0xFFFFD700) : const Color(0xFFFF6B9D);
      for (int i = 0; i < 5; i++) { final a = i*pi*2/5; canvas.drawCircle(Offset(fp[0]*w+cos(a)*5, fp[1]*h+sin(a)*5), 3.5, Paint()..color=col); }
      canvas.drawCircle(Offset(fp[0]*w, fp[1]*h), 3, Paint()..color = const Color(0xFFFFFF00));
    }
  }
  @override
  bool shouldRepaint(_DinoGardenPainter old) => true;
}