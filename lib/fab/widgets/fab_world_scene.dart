import 'dart:math';
import 'package:flutter/material.dart';

class FabWorldScene extends StatefulWidget {
  const FabWorldScene({super.key});
  @override
  State<FabWorldScene> createState() => _FabWorldSceneState();
}

class _FabWorldSceneState extends State<FabWorldScene>
    with TickerProviderStateMixin {
  late AnimationController _starCtrl, _fireflyCtrl, _glowCtrl, _campCtrl, _eggCtrl;

  @override
  void initState() {
    super.initState();
    _starCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 3))..repeat(reverse: true);
    _fireflyCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 4))..repeat();
    _glowCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat(reverse: true);
    _campCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 600))..repeat(reverse: true);
    _eggCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 800))..repeat(reverse: true);
  }

  @override
  void dispose() {
    _starCtrl.dispose(); _fireflyCtrl.dispose(); _glowCtrl.dispose();
    _campCtrl.dispose(); _eggCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_starCtrl, _fireflyCtrl, _glowCtrl, _campCtrl, _eggCtrl]),
      builder: (context, child) => ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: CustomPaint(
          painter: _WorldPainter(
            starPhase: _starCtrl.value, fireflyPhase: _fireflyCtrl.value,
            glowPhase: _glowCtrl.value, campPhase: _campCtrl.value, eggWobble: _eggCtrl.value,
          ),
          child: const SizedBox.expand(),
        ),
      ),
    );
  }
}

class _WorldPainter extends CustomPainter {
  final double starPhase, fireflyPhase, glowPhase, campPhase, eggWobble;
  const _WorldPainter({required this.starPhase, required this.fireflyPhase,
    required this.glowPhase, required this.campPhase, required this.eggWobble});

  static const c1 = Color(0xFF0D0820);
  static const c2 = Color(0xFF1A0E3A);
  static const c3 = Color(0xFF2D1B5E);
  static const h1 = Color(0xFF1E3A2F);
  static const h2 = Color(0xFF2A4A3A);
  static const h3 = Color(0xFF3A6B4A);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width; final h = size.height;
    canvas.drawRect(Offset.zero & size, Paint()..shader =
      LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter,
        colors: [c1, c2, c3]).createShader(Offset.zero & size));
    final rng = Random(42);
    for (int i = 0; i < 55; i++) {
      final x = rng.nextDouble() * w; final y = rng.nextDouble() * h * 0.55;
      final t = (sin(starPhase * pi * 2 + i * 0.7) + 1) / 2;
      canvas.drawCircle(Offset(x, y), 0.8 + t * 1.2,
        Paint()..color = Colors.white.withOpacity(0.3 + t * 0.65));
    }
    final gr = 28.0 + glowPhase * 8;
    final mc = Offset(w * 0.78, h * 0.18);
    canvas.drawCircle(mc, gr, Paint()..shader =
      RadialGradient(colors: [const Color(0x55FFE066), Colors.transparent])
        .createShader(Rect.fromCircle(center: mc, radius: gr)));
    canvas.drawCircle(mc, 16, Paint()..color = const Color(0xFFFFE066));
    canvas.drawCircle(Offset(mc.dx - 5, mc.dy - 2), 13, Paint()..color = c2);
    void hill(double by, double amp, Color col, List<double> xs, List<double> ys) {
      final p = Path()..moveTo(0, h)..lineTo(0, by);
      for (int i = 0; i < xs.length; i++) {
        final x = xs[i]*w; final y = by+ys[i]*amp;
        if (i==0) { p.lineTo(x,y); } else {
          final px=xs[i-1]*w; final py=by+ys[i-1]*amp; final cx=(px+x)/2;
          p.cubicTo(cx,py,cx,y,x,y);
        }
      }
      p..lineTo(w,h)..close();
      canvas.drawPath(p, Paint()..color = col);
    }
    hill(h*.50,h*.16,h1,[0,.15,.35,.55,.75,.90,1],[0,-.09,.02,-.07,.04,-.05,0]);
    hill(h*.60,h*.18,h2,[0,.12,.30,.50,.70,.88,1],[0,.06,-.10,.04,-.08,.05,0]);
    hill(h*.70,h*.20,h3,[0,.10,.28,.48,.68,.86,1],[0,-.08,.10,-.06,.09,-.04,0]);
    final fp = Paint()..color = const Color(0xFF88FF66);
    final rng2 = Random(99);
    for (int i = 0; i < 14; i++) {
      final bx = rng2.nextDouble()*w; final by2 = h*.45+rng2.nextDouble()*h*.35;
      final fx = bx+sin(fireflyPhase*pi*2+i*1.1)*12;
      final fy = by2+cos(fireflyPhase*pi*2+i*.9)*6;
      final t = (sin(fireflyPhase*pi*4+i*2.3)+1)/2;
      canvas.drawCircle(Offset(fx,fy),5,Paint()..color=const Color(0xFF88FF66).withOpacity(.12+t*.18)..maskFilter=const MaskFilter.blur(BlurStyle.normal,6));
      canvas.drawCircle(Offset(fx,fy),1.4,fp..color=const Color(0xFF88FF66).withOpacity(.55+t*.45));
    }
    final cx2=w*.18; final cy2=h*.68;
    canvas.drawOval(Rect.fromCenter(center:Offset(cx2,cy2+2),width:40,height:10),
      Paint()..color=const Color(0xFFFF8C00).withOpacity(.18+campPhase*.12)..maskFilter=const MaskFilter.blur(BlurStyle.normal,18));
    final log=Paint()..color=const Color(0xFF5D3A1A);
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromCenter(center:Offset(cx2-4,cy2),width:18,height:5),const Radius.circular(2)),log);
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromCenter(center:Offset(cx2+4,cy2),width:18,height:5),const Radius.circular(2)),log);
    void flame(double x,double y,double ph,Color col,double ht){
      final f=ph*3;
      canvas.drawPath(Path()..moveTo(x-5,y)..quadraticBezierTo(x-3+f,y-ht*.5,x,y-ht)..quadraticBezierTo(x+3+f,y-ht*.5,x+5,y)..close(),Paint()..color=col.withOpacity(.85));
    }
    flame(cx2,cy2,campPhase,const Color(0xFFFF8C00),14);
    flame(cx2-4,cy2+2,campPhase*.8,const Color(0xFFFFE000),9);
    flame(cx2+4,cy2+2,campPhase*1.2,const Color(0xFFFF8C00),8);
    final ecx=w*.55; final ecy=h*.72;
    void egg(double ex,double ey,Color col,double rx){
      canvas.drawPath(Path()..moveTo(ex,ey-rx*1.35)..cubicTo(ex+rx*.9,ey-rx*1.35,ex+rx,ey+rx*.6,ex,ey+rx)..cubicTo(ex-rx,ey+rx*.6,ex-rx*.9,ey-rx*1.35,ex,ey-rx*1.35),Paint()..color=col);
    }
    egg(ecx-20,ecy-4,const Color(0xFF81C784),9);
    egg(ecx+18,ecy-2,const Color(0xFF64B5F6),9);
    egg(ecx,ecy-8,const Color(0xFFD4A843),9);
    final wb=sin(eggWobble*pi*2)*2.5;
    egg(ecx-2,ecy+4+wb*.3,const Color(0xFFD4A843),10);
    canvas.drawLine(Offset(ecx-2,ecy-6+wb*.2),Offset(ecx+2,ecy-1+wb*.2),Paint()..color=c3..strokeWidth=1.5..style=PaintingStyle.stroke);
    canvas.drawOval(Rect.fromCenter(center:Offset(ecx-2,ecy-16+wb*.2),width:11,height:9),Paint()..color=const Color(0xFF66BB6A));
    canvas.drawCircle(Offset(ecx+1,ecy-19+wb*.2),2.2,Paint()..color=Colors.black);
    canvas.drawCircle(Offset(ecx+1.6,ecy-19.5+wb*.2),.7,Paint()..color=Colors.white);
  }

  @override
  bool shouldRepaint(_WorldPainter old) => true;
}