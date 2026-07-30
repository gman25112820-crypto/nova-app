import 'package:flutter/material.dart';

// ─────────────────────────────────────────────────────────────
// SharedGardenScreen — full collaborative activities.
// Four activities: Create Together, Story Garden, Music Corner,
// Grow Together. Each is a full screen pushed on tap.
// ─────────────────────────────────────────────────────────────

class SharedGardenScreen extends StatelessWidget {
  const SharedGardenScreen({super.key});

  static const _teal = Color(0xFF4ECDC4);
  static const _bg   = Color(0xFF0A1A0F);
  static const _text = Color(0xFFF0D6FF);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
              child: Row(children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 40, height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.08),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.arrow_back_ios_new_rounded,
                        color: _text, size: 18),
                  ),
                ),
                const SizedBox(width: 12),
                const Text('🌿  Shared Garden',
                    style: TextStyle(color: _text, fontSize: 18,
                        fontWeight: FontWeight.w700, fontFamily: 'DM Sans')),
              ]),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      height: 110,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft, end: Alignment.bottomRight,
                          colors: [Color(0xFF0E2E16), Color(0xFF0A1A0F)],
                        ),
                        border: Border.all(
                            color: _teal.withValues(alpha: 0.30), width: 1.5),
                      ),
                      child: const Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                        Text('🌱🌸🌻🌿🦋', style: TextStyle(fontSize: 26)),
                        SizedBox(height: 6),
                        Text('A space that belongs to everyone',
                            style: TextStyle(color: Color(0xFF7AA880),
                                fontSize: 13, fontFamily: 'DM Sans')),
                      ])),
                    ),
                    const SizedBox(height: 18),
                    _GardenActivityCard(
                      emoji: '🎨', title: 'Create Together',
                      subtitle: 'Draw something. No rules here.',
                      accent: const Color(0xFFFF6B8A),
                      destination: const CreateTogetherScreen(),
                    ),
                    const SizedBox(height: 12),
                    _GardenActivityCard(
                      emoji: '📖', title: 'Story Garden',
                      subtitle: 'Build a story, one line at a time.',
                      accent: const Color(0xFFFFD700),
                      destination: const StoryGardenScreen(),
                    ),
                    const SizedBox(height: 12),
                    _GardenActivityCard(
                      emoji: '🎵', title: 'Music Corner',
                      subtitle: 'Not open yet',
                      accent: const Color(0xFF6C63FF),
                    ),
                    const SizedBox(height: 12),
                    _GardenActivityCard(
                      emoji: '🌱', title: 'Grow Together',
                      subtitle: 'Water your plant. Watch it grow.',
                      accent: _teal,
                      destination: const GrowTogetherScreen(),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GardenActivityCard extends StatelessWidget {
  final String emoji, title, subtitle;
  final Color accent;
  final Widget? destination;
  const _GardenActivityCard({
    required this.emoji, required this.title, required this.subtitle,
    required this.accent, this.destination,
  });
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: destination == null
          ? null
          : () => Navigator.push(context,
              MaterialPageRoute(builder: (_) => destination!)),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        decoration: BoxDecoration(
          color: accent.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: accent.withValues(alpha: 0.30)),
        ),
        child: Row(children: [
          Text(emoji, style: const TextStyle(fontSize: 34)),
          const SizedBox(width: 16),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: const TextStyle(color: Color(0xFFF0D6FF),
                fontSize: 15, fontWeight: FontWeight.w700, fontFamily: 'DM Sans')),
            const SizedBox(height: 3),
            Text(subtitle, style: TextStyle(color: Colors.white.withValues(alpha: 0.50),
                fontSize: 12, fontFamily: 'DM Sans')),
          ])),
          Icon(Icons.arrow_forward_ios_rounded,
              color: accent.withValues(alpha: 0.60), size: 14),
        ]),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════
// CREATE TOGETHER — paint canvas
// ════════════════════════════════════════════════════════════════

class CreateTogetherScreen extends StatefulWidget {
  const CreateTogetherScreen({super.key});
  @override State<CreateTogetherScreen> createState() => _CreateTogetherState();
}

class _CreateTogetherState extends State<CreateTogetherScreen> {
  final List<_Pt> _pts = [];
  Color _col = const Color(0xFFFF6B8A);
  double _sz = 14;
  bool _erasing = false;
  Offset? _cursor;
  final _canvasKey = GlobalKey();

  static const _palette = [
    Color(0xFFFF6B8A), Color(0xFFFFD700), Color(0xFF6C63FF), Color(0xFF4ECDC4),
    Color(0xFF4CAF50), Color(0xFFFF8C00), Color(0xFFF0D6FF), Color(0xFF00C9A7),
  ];

  void _undo() {
    if (_pts.isEmpty) return;
    setState(() {
      if (_pts.last.isSep) _pts.removeLast();
      while (_pts.isNotEmpty && !_pts.last.isSep) {
        _pts.removeLast();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0520),
      body: SafeArea(child: Column(children: [
        Padding(padding: const EdgeInsets.fromLTRB(12, 8, 12, 8), child: Row(children: [
          GestureDetector(onTap: () => Navigator.pop(context),
            child: Container(width: 36, height: 36,
              decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.08), shape: BoxShape.circle),
              child: const Icon(Icons.arrow_back_rounded, color: Color(0xFFF0D6FF), size: 18))),
          const SizedBox(width: 10),
          const Text('🎨  Create Together', style: TextStyle(color: Color(0xFFF0D6FF), fontSize: 16, fontWeight: FontWeight.w700, fontFamily: 'DM Sans')),
          const Spacer(),
          GestureDetector(onTap: _undo,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.undo_rounded, color: Color(0xFF9B8FFF), size: 15),
                SizedBox(width: 5),
                Text('Undo', style: TextStyle(color: Color(0xFF9B8FFF), fontSize: 13, fontFamily: 'DM Sans')),
              ]),
            )),
          const SizedBox(width: 8),
          GestureDetector(onTap: () => setState(() => _pts.clear()),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.delete_outline_rounded, color: Color(0xFF9B8FFF), size: 15),
                SizedBox(width: 5),
                Text('Clear', style: TextStyle(color: Color(0xFF9B8FFF), fontSize: 13, fontFamily: 'DM Sans')),
              ]),
            )),
        ])),
        Expanded(child: MouseRegion(
          onHover: (e) {
            final box = _canvasKey.currentContext?.findRenderObject() as RenderBox?;
            if (box == null) return;
            setState(() => _cursor = box.globalToLocal(e.position));
          },
          onExit: (_) => setState(() => _cursor = null),
          child: GestureDetector(
          onPanUpdate: (d) {
            final box = _canvasKey.currentContext?.findRenderObject() as RenderBox?;
            if (box == null) return;
            final local = box.globalToLocal(d.globalPosition);
            setState(() {
              _cursor = local;
              _pts.add(_Pt(local, _erasing ? const Color(0xFF1A0D30) : _col, _sz));
            });
          },
          onPanEnd: (_) => setState(() => _pts.add(_Pt.sep())),
          child: Container(
            key: _canvasKey,
            margin: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: const Color(0xFF1A0D30),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withValues(alpha: 0.10))),
            child: ClipRRect(borderRadius: BorderRadius.circular(16),
              child: CustomPaint(
                painter: _CanvasPainter(_pts, _cursor, _sz, _col, _erasing),
                child: const SizedBox.expand())))))),
        Padding(padding: const EdgeInsets.fromLTRB(12, 8, 12, 12), child: Column(children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: _palette.map((c) {
            final sel = c == _col;
            return GestureDetector(onTap: () => setState(() { _col = c; _erasing = false; }),
              child: AnimatedContainer(duration: const Duration(milliseconds: 150),
                width: sel ? 34 : 28, height: sel ? 34 : 28,
                decoration: BoxDecoration(color: c, shape: BoxShape.circle,
                  border: Border.all(color: sel ? Colors.white : Colors.transparent, width: 2))));
          }).toList()),
          const SizedBox(height: 10),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            for (final preset in [6.0, 14.0, 24.0]) ...[
              GestureDetector(
                onTap: () => setState(() => _sz = preset),
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: _sz == preset
                        ? Colors.white.withValues(alpha: 0.12)
                        : Colors.transparent,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: _sz == preset
                          ? Colors.white.withValues(alpha: 0.40)
                          : Colors.transparent,
                      width: 1.5,
                    ),
                  ),
                  child: Center(
                    child: Container(
                      width: preset,
                      height: preset,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: _sz == preset ? 0.90 : 0.45),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),
              ),
              if (preset != 24.0) const SizedBox(width: 16),
            ],
          ]),
          const SizedBox(height: 10),
          GestureDetector(
            onTap: () => setState(() => _erasing = !_erasing),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: _erasing
                    ? Colors.white.withValues(alpha: 0.14)
                    : Colors.white.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: _erasing
                      ? Colors.white.withValues(alpha: 0.45)
                      : Colors.transparent,
                  width: 1.5,
                ),
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.cleaning_services_rounded,
                    color: _erasing ? Colors.white : Colors.white.withValues(alpha: 0.45),
                    size: 15),
                const SizedBox(width: 6),
                Text('Eraser',
                    style: TextStyle(
                      color: _erasing ? Colors.white : Colors.white.withValues(alpha: 0.45),
                      fontSize: 13,
                      fontFamily: 'DM Sans',
                    )),
              ]),
            ),
          ),
        ])),
      ])),
    );
  }
}

class _Pt {
  final Offset? p; final Color c; final double s;
  bool get isSep => p == null;
  const _Pt(this.p, this.c, this.s);
  _Pt.sep() : p = null, c = Colors.transparent, s = 0;
}

class _CanvasPainter extends CustomPainter {
  final List<_Pt> pts;
  final Offset? cursor;
  final double sz;
  final Color col;
  final bool erasing;
  _CanvasPainter(this.pts, this.cursor, this.sz, this.col, this.erasing);
  @override void paint(Canvas canvas, Size size) {
    for (int i = 0; i < pts.length - 1; i++) {
      final a = pts[i]; final b = pts[i + 1];
      if (a.isSep || b.isSep) continue;
      canvas.drawLine(a.p!, b.p!,
        Paint()..color = a.c..strokeWidth = a.s..strokeCap = StrokeCap.round);
    }
    if (cursor != null) {
      canvas.drawCircle(
        cursor!,
        sz / 2,
        Paint()
          ..color = (erasing ? Colors.white : col).withValues(alpha: 0.70)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5,
      );
    }
  }
  @override bool shouldRepaint(_CanvasPainter old) =>
      old.pts != pts || old.cursor != cursor || old.sz != sz ||
      old.col != col || old.erasing != erasing;
}

// ════════════════════════════════════════════════════════════════
// STORY GARDEN — sentence chain
// ════════════════════════════════════════════════════════════════

class StoryGardenScreen extends StatefulWidget {
  const StoryGardenScreen({super.key});
  @override State<StoryGardenScreen> createState() => _StoryGardenState();
}

class _StoryGardenState extends State<StoryGardenScreen> {
  final List<String> _lines = ['Once upon a time, deep in a magical garden…'];
  final _ctrl = TextEditingController();
  @override void dispose() { _ctrl.dispose(); super.dispose(); }

  void _add() {
    final t = _ctrl.text.trim();
    if (t.isEmpty) return;
    setState(() { _lines.add(t); _ctrl.clear(); });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0A20),
      body: SafeArea(child: Column(children: [
        Padding(padding: const EdgeInsets.fromLTRB(12, 8, 12, 8), child: Row(children: [
          GestureDetector(onTap: () => Navigator.pop(context),
            child: Container(width: 36, height: 36,
              decoration: BoxDecoration(color: const Color(0xFFFFD700).withValues(alpha: 0.12), shape: BoxShape.circle),
              child: const Icon(Icons.arrow_back_rounded, color: Color(0xFFF0D6FF), size: 18))),
          const SizedBox(width: 10),
          const Text('📖  Story Garden', style: TextStyle(color: Color(0xFFF0D6FF), fontSize: 16, fontWeight: FontWeight.w700, fontFamily: 'DM Sans')),
          const Spacer(),
          GestureDetector(onTap: () => setState(() { _lines.clear(); _lines.add('Once upon a time…'); }),
            child: const Text('New', style: TextStyle(color: Color(0xFFFFD700), fontSize: 12, fontFamily: 'DM Sans'))),
        ])),
        Expanded(child: ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: _lines.length,
          itemBuilder: (_, i) => Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: i == 0 ? const Color(0xFFFFD700).withValues(alpha: 0.10)
                           : Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: i == 0 ? const Color(0xFFFFD700).withValues(alpha: 0.25)
                             : Colors.white.withValues(alpha: 0.08))),
            child: Text(_lines[i], style: TextStyle(color: Colors.white.withValues(alpha: 0.80),
                fontSize: 14, fontFamily: 'DM Sans', height: 1.5))))),
        Padding(padding: const EdgeInsets.fromLTRB(16, 8, 16, 16), child: Row(children: [
          Expanded(child: TextField(controller: _ctrl, onSubmitted: (_) => _add(),
            style: const TextStyle(color: Color(0xFFF0D6FF), fontFamily: 'DM Sans'),
            decoration: InputDecoration(
              hintText: 'Add the next line…',
              hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.35), fontFamily: 'DM Sans'),
              filled: true, fillColor: Colors.white.withValues(alpha: 0.06),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.12))),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.12))),
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12)))),
          const SizedBox(width: 10),
          GestureDetector(onTap: _add,
            child: Container(width: 46, height: 46,
              decoration: BoxDecoration(color: const Color(0xFFFFD700), borderRadius: BorderRadius.circular(12)),
              child: const Icon(Icons.add_rounded, color: Colors.black87, size: 24))),
        ])),
      ])),
    );
  }
}


// ════════════════════════════════════════════════════════════════
// Music Corner stays visible while the audio asset is unavailable.
class MusicCornerScreen extends StatelessWidget {
  const MusicCornerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0820),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: const Color(0xFF6C63FF).withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.arrow_back_rounded,
                        color: Color(0xFFF0D6FF),
                        size: 18,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'Music Corner',
                    style: TextStyle(
                      color: Color(0xFFF0D6FF),
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'DM Sans',
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(),
            const Icon(
              Icons.music_note_rounded,
              color: Color(0xFF6C63FF),
              size: 52,
            ),
            const SizedBox(height: 14),
            const Text(
              'Not open yet',
              style: TextStyle(
                color: Color(0xFFF0D6FF),
                fontSize: 22,
                fontWeight: FontWeight.w800,
                fontFamily: 'DM Sans',
              ),
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}
// GROW TOGETHER — virtual plant
// ════════════════════════════════════════════════════════════════

class GrowTogetherScreen extends StatefulWidget {
  const GrowTogetherScreen({super.key});
  @override State<GrowTogetherScreen> createState() => _GrowTogetherState();
}

class _GrowTogetherState extends State<GrowTogetherScreen>
    with SingleTickerProviderStateMixin {
  int _waters = 0;
  late final AnimationController _grow;

  static const _stages   = ['🌱', '🌿', '🍀', '🌸', '🌺', '🌻'];
  static const _messages = [
    'Just starting. Give it water and love.',
    'It is growing! You can see the leaves.',
    'Looking healthy! Every drop counts.',
    'Beautiful. Your care shows.',
    'In full bloom — just like you.',
    'You grew this. A whole flower, from nothing.',
  ];

  @override void initState() { super.initState(); _grow = AnimationController(vsync: this, duration: const Duration(milliseconds: 350)); }
  @override void dispose() { _grow.dispose(); super.dispose(); }

  void _water() { _grow.forward(from: 0); setState(() => _waters++); }

  @override
  Widget build(BuildContext context) {
    final stage = (_waters ~/ 3).clamp(0, _stages.length - 1);
    return Scaffold(
      backgroundColor: const Color(0xFF0A1A0F),
      body: SafeArea(child: Column(children: [
        Padding(padding: const EdgeInsets.fromLTRB(12, 8, 12, 8), child: Row(children: [
          GestureDetector(onTap: () => Navigator.pop(context),
            child: Container(width: 36, height: 36,
              decoration: BoxDecoration(color: const Color(0xFF4ECDC4).withValues(alpha: 0.12), shape: BoxShape.circle),
              child: const Icon(Icons.arrow_back_rounded, color: Color(0xFFF0D6FF), size: 18))),
          const SizedBox(width: 10),
          const Text('🌱  Grow Together', style: TextStyle(color: Color(0xFFF0D6FF), fontSize: 16, fontWeight: FontWeight.w700, fontFamily: 'DM Sans')),
        ])),
        const Spacer(),
        AnimatedBuilder(animation: _grow, builder: (_, __) => Transform.scale(scale: 1.0 + _grow.value * 0.08,
          child: Text(_stages[stage], style: const TextStyle(fontSize: 100)))),
        const SizedBox(height: 14),
        Padding(padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Text(_messages[stage], textAlign: TextAlign.center,
            style: const TextStyle(color: Color(0xFF7AA880), fontSize: 14, fontFamily: 'DM Sans'))),
        const SizedBox(height: 8),
        Text('Waters: $_waters 💧', style: TextStyle(color: Colors.white.withValues(alpha: 0.35), fontSize: 12, fontFamily: 'DM Sans')),
        const SizedBox(height: 40),
        GestureDetector(onTap: _water,
          child: Container(width: 88, height: 88,
            decoration: BoxDecoration(
              color: const Color(0xFF4ECDC4).withValues(alpha: 0.15),
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFF4ECDC4).withValues(alpha: 0.50), width: 2),
              boxShadow: [BoxShadow(color: const Color(0xFF4ECDC4).withValues(alpha: 0.25), blurRadius: 24)]),
            child: const Center(child: Text('💧', style: TextStyle(fontSize: 44))))),
        const Spacer(),
      ])),
    );
  }
}
