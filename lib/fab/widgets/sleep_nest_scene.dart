import 'dart:math';
import 'package:flutter/material.dart';

class SleepNestScene extends StatefulWidget {
  const SleepNestScene({super.key});
  @override
  State<SleepNestScene> createState() => _SleepNestSceneState();
}

class _SleepNestSceneState extends State<SleepNestScene> with TickerProviderStateMixin {
  late AnimationController _starCtrl;
  late AnimationController _glowCtrl;
  late AnimationController _breathCtrl;
  @override
  void initState() {
    super.initState();
    _starCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 4))..repeat(reverse: true);
    _glowCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 3))..repeat(reverse: true);
    _breathCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 5))..repeat(reverse: true);
  }
  @override
  void dispose() {
    _starCtrl.dispose(); _glowCtrl.dispose(); _breathCtrl.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_starCtrl, _glowCtrl, _breathCtrl]),
      builder: (context, child) => ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: CustomPaint(
          painter: _SleepNestPainter(star: _starCtrl.value, glow: _glowCtrl.value, breath: _breathCtrl.value),
          child: const SizedBox.expand(),
        ),
      ),
    );
  }
}

class _SleepNestPainter extends CustomPainter {
  final double star, glow, breath;
  const _SleepNestPainter({required this.star, required this.glow, required this.breath});
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width; final h = size.height;
    canvas.drawRect(Offset.zero & size, Paint()..shader = LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [const Color(0xFF050312), const Color(0xFF0D0820), const Color(0xFF1A0E3A)]).createShader(Offset.zero & size));
    final rng = Random(77);
    for (int i = 0; i < 60; i++) {
      final t = (sin(star*pi*2+i*0.6)+1)/2;
      canvas.drawCircle(Offset(rng.nextDouble()*w, rng.nextDouble()*h*0.7), 0.6+t*1.0, Paint()..color = Colors.white.withOpacity(0.2+t*0.6));
    }
    final mx = w*0.72; final my = h*0.22;
    final mr = 22.0 + glow*5;
    canvas.drawCircle(Offset(mx,my), mr+10, Paint()..color = const Color(0xFFFFE066).withOpacity(0.08+glow*0.06)..maskFilter=const MaskFilter.blur(BlurStyle.normal,14));
    canvas.drawCircle(Offset(mx,my), mr, Paint()..color = const Color(0xFFFFE8A0));
    canvas.drawCircle(Offset(mx-6,my-2), mr-3, Paint()..color = const Color(0xFF0D0820));
    final path1 = Path()..moveTo(0,h);
    for (double x = 0; x <= w; x += w/6) { path1.lineTo(x, h*0.62+sin(x/w*pi*2)*h*0.06); }
    path1..lineTo(w,h)..close();
    canvas.drawPath(path1, Paint()..color = const Color(0xFF1A1035));
    final path2 = Path()..moveTo(0,h);
    for (double x = 0; x <= w; x += w/6) { path2.lineTo(x, h*0.72+sin(x/w*pi*2+1)*h*0.05); }
    path2..lineTo(w,h)..close();
    canvas.drawPath(path2, Paint()..color = const Color(0xFF1E1540));
    final ncx = w*0.38; final ncy = h*0.78;
    final np = Paint()..color = const Color(0xFF5D4037).withOpacity(0.8)..style = PaintingStyle.stroke..strokeWidth = 2..strokeCap = StrokeCap.round;
    for (int i = -4; i <= 4; i++) { canvas.drawArc(Rect.fromCenter(center: Offset(ncx+i*6, ncy+4), width: 26, height: 12), 0, pi, false, np); }
    final bs = 1.0 + breath*0.06;
    canvas.save(); canvas.translate(ncx, ncy-8); canvas.scale(bs,bs); canvas.translate(-ncx, -(ncy-8));
    final body = Paint()..color = const Color(0xFFFFD54F);
    canvas.drawOval(Rect.fromCenter(center: Offset(ncx,ncy-8), width: 26, height: 16), body);
    canvas.drawOval(Rect.fromCenter(center: Offset(ncx+10,ncy-13), width: 14, height: 11), body);
    canvas.drawLine(Offset(ncx+13,ncy-13), Offset(ncx+17,ncy-13), Paint()..color=const Color(0xFF5D4037)..strokeWidth=1.5..strokeCap=StrokeCap.round);
    canvas.drawOval(Rect.fromCenter(center: Offset(ncx-2,ncy-8), width: 18, height: 8), Paint()..color=const Color(0xFFFFB300));
    canvas.drawPath(Path()..moveTo(ncx+16,ncy-12)..lineTo(ncx+21,ncy-11)..lineTo(ncx+16,ncy-10)..close(), Paint()..color=const Color(0xFFFF8F00));
    canvas.restore();
    final tp1 = TextPainter(text: TextSpan(text: 'z', style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 10)), textDirection: TextDirection.ltr)..layout();
    tp1.paint(canvas, Offset(ncx+20, ncy-22-sin(star*pi*2)*4));
    final tp2 = TextPainter(text: TextSpan(text: 'z', style: TextStyle(color: Colors.white.withOpacity(0.25), fontSize: 14)), textDirection: TextDirection.ltr)..layout();
    tp2.paint(canvas, Offset(ncx+30, ncy-32-sin(star*pi*2+1)*4));
    void lantern(double cx, double cy) {
      canvas.drawCircle(Offset(cx,cy), 10+glow*3, Paint()..color=const Color(0xFFFF8C00).withOpacity(0.08+glow*0.08)..maskFilter=const MaskFilter.blur(BlurStyle.normal,10));
      canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromCenter(center:Offset(cx,cy),width:10,height:14),const Radius.circular(4)), Paint()..color=const Color(0xFFFF8C00).withOpacity(0.6+glow*0.2));
      canvas.drawLine(Offset(cx,cy-7), Offset(cx,cy-14), Paint()..color=const Color(0xFF5D4037)..strokeWidth=1.5);
    }
    lantern(w*0.12, h*0.55);
    lantern(w*0.82, h*0.58);
  }
  @override
  bool shouldRepaint(_SleepNestPainter old) => true;
}