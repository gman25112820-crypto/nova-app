import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

// ─────────────────────────────────────────────────────────────
// SharedGardenScreen — full collaborative activities.
// Four activities: Create Together, Story Garden, Music Corner,
// Grow Together. Each is a full screen pushed on tap.
// ─────────────────────────────────────────────────────────────

class SharedGardenScreen extends StatelessWidget {
  const SharedGardenScreen({super.key});

  static const _teal = Color(0xFF4ECDC4);
  static const _bg = Color(0xFF0A1A0F);
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
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.08),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: _text,
                        size: 18,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    '🌿  Shared Garden',
                    style: TextStyle(
                      color: _text,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'DM Sans',
                    ),
                  ),
                ],
              ),
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
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xFF0E2E16), Color(0xFF0A1A0F)],
                        ),
                        border: Border.all(
                          color: _teal.withValues(alpha: 0.30),
                          width: 1.5,
                        ),
                      ),
                      child: const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('🌱🌸🌻🌿🦋', style: TextStyle(fontSize: 26)),
                            SizedBox(height: 6),
                            Text(
                              'A space that belongs to everyone',
                              style: TextStyle(
                                color: Color(0xFF7AA880),
                                fontSize: 13,
                                fontFamily: 'DM Sans',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    _GardenActivityCard(
                      emoji: '🎨',
                      title: 'Create Together',
                      subtitle: 'Draw something. No rules here.',
                      accent: const Color(0xFFFF6B8A),
                      destination: const CreateTogetherScreen(),
                    ),
                    const SizedBox(height: 12),
                    _GardenActivityCard(
                      emoji: '📖',
                      title: 'Story Garden',
                      subtitle: 'Build a story, one line at a time.',
                      accent: const Color(0xFFFFD700),
                      destination: const StoryGardenScreen(),
                    ),
                    const SizedBox(height: 12),
                    _GardenActivityCard(
                      emoji: '🎵',
                      title: 'Music Corner',
                      subtitle: 'Gentle sounds you control',
                      accent: const Color(0xFF6C63FF),
                      destination: const MusicCornerScreen(),
                    ),
                    const SizedBox(height: 12),
                    _GardenActivityCard(
                      emoji: '🌱',
                      title: 'Grow Together',
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
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.accent,
    this.destination,
  });
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: destination == null
          ? null
          : () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => destination!),
            ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        decoration: BoxDecoration(
          color: accent.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: accent.withValues(alpha: 0.30)),
        ),
        child: Row(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 34)),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Color(0xFFF0D6FF),
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'DM Sans',
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.50),
                      fontSize: 12,
                      fontFamily: 'DM Sans',
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: accent.withValues(alpha: 0.60),
              size: 14,
            ),
          ],
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════
// CREATE TOGETHER — paint canvas
// ════════════════════════════════════════════════════════════════

class CreateTogetherScreen extends StatefulWidget {
  const CreateTogetherScreen({super.key});
  @override
  State<CreateTogetherScreen> createState() => _CreateTogetherState();
}

class _CreateTogetherState extends State<CreateTogetherScreen> {
  final List<_Pt> _pts = [];
  Color _col = const Color(0xFFFF6B8A);
  double _sz = 14;
  bool _erasing = false;
  Offset? _cursor;
  final _canvasKey = GlobalKey();

  static const _palette = [
    Color(0xFFFF6B8A),
    Color(0xFFFFD700),
    Color(0xFF6C63FF),
    Color(0xFF4ECDC4),
    Color(0xFF4CAF50),
    Color(0xFFFF8C00),
    Color(0xFFF0D6FF),
    Color(0xFF00C9A7),
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
                        color: Colors.white.withValues(alpha: 0.08),
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
                    '🎨  Create Together',
                    style: TextStyle(
                      color: Color(0xFFF0D6FF),
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'DM Sans',
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: _undo,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.undo_rounded,
                            color: Color(0xFF9B8FFF),
                            size: 15,
                          ),
                          SizedBox(width: 5),
                          Text(
                            'Undo',
                            style: TextStyle(
                              color: Color(0xFF9B8FFF),
                              fontSize: 13,
                              fontFamily: 'DM Sans',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () => setState(() => _pts.clear()),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.delete_outline_rounded,
                            color: Color(0xFF9B8FFF),
                            size: 15,
                          ),
                          SizedBox(width: 5),
                          Text(
                            'Clear',
                            style: TextStyle(
                              color: Color(0xFF9B8FFF),
                              fontSize: 13,
                              fontFamily: 'DM Sans',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: MouseRegion(
                onHover: (e) {
                  final box =
                      _canvasKey.currentContext?.findRenderObject()
                          as RenderBox?;
                  if (box == null) return;
                  setState(() => _cursor = box.globalToLocal(e.position));
                },
                onExit: (_) => setState(() => _cursor = null),
                child: GestureDetector(
                  onPanUpdate: (d) {
                    final box =
                        _canvasKey.currentContext?.findRenderObject()
                            as RenderBox?;
                    if (box == null) return;
                    final local = box.globalToLocal(d.globalPosition);
                    setState(() {
                      _cursor = local;
                      _pts.add(
                        _Pt(
                          local,
                          _erasing ? const Color(0xFF1A0D30) : _col,
                          _sz,
                        ),
                      );
                    });
                  },
                  onPanEnd: (_) => setState(() => _pts.add(_Pt.sep())),
                  child: Container(
                    key: _canvasKey,
                    margin: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A0D30),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.10),
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: CustomPaint(
                        painter: _CanvasPainter(
                          _pts,
                          _cursor,
                          _sz,
                          _col,
                          _erasing,
                        ),
                        child: const SizedBox.expand(),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: _palette.map((c) {
                      final sel = c == _col;
                      return GestureDetector(
                        onTap: () => setState(() {
                          _col = c;
                          _erasing = false;
                        }),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          width: sel ? 34 : 28,
                          height: sel ? 34 : 28,
                          decoration: BoxDecoration(
                            color: c,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: sel ? Colors.white : Colors.transparent,
                              width: 2,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
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
                                  color: Colors.white.withValues(
                                    alpha: _sz == preset ? 0.90 : 0.45,
                                  ),
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                          ),
                        ),
                        if (preset != 24.0) const SizedBox(width: 16),
                      ],
                    ],
                  ),
                  const SizedBox(height: 10),
                  GestureDetector(
                    onTap: () => setState(() => _erasing = !_erasing),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
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
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.cleaning_services_rounded,
                            color: _erasing
                                ? Colors.white
                                : Colors.white.withValues(alpha: 0.45),
                            size: 15,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Eraser',
                            style: TextStyle(
                              color: _erasing
                                  ? Colors.white
                                  : Colors.white.withValues(alpha: 0.45),
                              fontSize: 13,
                              fontFamily: 'DM Sans',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Pt {
  final Offset? p;
  final Color c;
  final double s;
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
  @override
  void paint(Canvas canvas, Size size) {
    for (int i = 0; i < pts.length - 1; i++) {
      final a = pts[i];
      final b = pts[i + 1];
      if (a.isSep || b.isSep) continue;
      canvas.drawLine(
        a.p!,
        b.p!,
        Paint()
          ..color = a.c
          ..strokeWidth = a.s
          ..strokeCap = StrokeCap.round,
      );
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

  @override
  bool shouldRepaint(_CanvasPainter old) =>
      old.pts != pts ||
      old.cursor != cursor ||
      old.sz != sz ||
      old.col != col ||
      old.erasing != erasing;
}

// ════════════════════════════════════════════════════════════════
// STORY GARDEN — sentence chain
// ════════════════════════════════════════════════════════════════

class StoryGardenScreen extends StatefulWidget {
  const StoryGardenScreen({super.key});
  @override
  State<StoryGardenScreen> createState() => _StoryGardenState();
}

class _StoryGardenState extends State<StoryGardenScreen> {
  final List<String> _lines = ['Once upon a time, deep in a magical garden…'];
  final _ctrl = TextEditingController();
  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _add() {
    final t = _ctrl.text.trim();
    if (t.isEmpty) return;
    setState(() {
      _lines.add(t);
      _ctrl.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0A20),
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
                        color: const Color(0xFFFFD700).withValues(alpha: 0.12),
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
                    '📖  Story Garden',
                    style: TextStyle(
                      color: Color(0xFFF0D6FF),
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'DM Sans',
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => setState(() {
                      _lines.clear();
                      _lines.add('Once upon a time…');
                    }),
                    child: const Text(
                      'New',
                      style: TextStyle(
                        color: Color(0xFFFFD700),
                        fontSize: 12,
                        fontFamily: 'DM Sans',
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _lines.length,
                itemBuilder: (_, i) => Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: i == 0
                        ? const Color(0xFFFFD700).withValues(alpha: 0.10)
                        : Colors.white.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: i == 0
                          ? const Color(0xFFFFD700).withValues(alpha: 0.25)
                          : Colors.white.withValues(alpha: 0.08),
                    ),
                  ),
                  child: Text(
                    _lines[i],
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.80),
                      fontSize: 14,
                      fontFamily: 'DM Sans',
                      height: 1.5,
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _ctrl,
                      onSubmitted: (_) => _add(),
                      style: const TextStyle(
                        color: Color(0xFFF0D6FF),
                        fontFamily: 'DM Sans',
                      ),
                      decoration: InputDecoration(
                        hintText: 'Add the next line…',
                        hintStyle: TextStyle(
                          color: Colors.white.withValues(alpha: 0.35),
                          fontFamily: 'DM Sans',
                        ),
                        filled: true,
                        fillColor: Colors.white.withValues(alpha: 0.06),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: Colors.white.withValues(alpha: 0.12),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: Colors.white.withValues(alpha: 0.12),
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: _add,
                    child: Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFD700),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.add_rounded,
                        color: Colors.black87,
                        size: 24,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════
class MusicCornerSound {
  final String id;
  final String label;
  final IconData icon;
  final String assetPath;

  const MusicCornerSound({
    required this.id,
    required this.label,
    required this.icon,
    required this.assetPath,
  });
}

abstract class MusicCornerAudioController {
  Future<void> play(MusicCornerSound sound, {required double volume});
  Future<void> setVolume(double volume);
  Future<void> stop();
  Future<void> dispose();
}

class AssetMusicCornerAudioController implements MusicCornerAudioController {
  final AudioPlayer _player = AudioPlayer();

  AssetMusicCornerAudioController() {
    AudioLogger.logLevel = AudioLogLevel.none;
    _player.setReleaseMode(ReleaseMode.loop);
  }

  @override
  Future<void> play(MusicCornerSound sound, {required double volume}) async {
    await _player.stop();
    await _player.setReleaseMode(ReleaseMode.loop);
    await _player.setVolume(volume);
    await _player.play(AssetSource(sound.assetPath, mimeType: 'audio/wav'));
  }

  @override
  Future<void> setVolume(double volume) => _player.setVolume(volume);

  @override
  Future<void> stop() => _player.stop();

  @override
  Future<void> dispose() async {
    await _player.stop();
    await _player.dispose();
  }
}

class MusicCornerScreen extends StatefulWidget {
  final MusicCornerAudioController? audioController;

  const MusicCornerScreen({super.key, this.audioController});

  @override
  State<MusicCornerScreen> createState() => _MusicCornerScreenState();
}

class _MusicCornerScreenState extends State<MusicCornerScreen> {
  static const _sounds = [
    MusicCornerSound(
      id: 'bells',
      label: 'Floating bells',
      icon: Icons.notifications_none_rounded,
      assetPath: 'audio/music_corner_floating_bells.wav',
    ),
    MusicCornerSound(
      id: 'glow',
      label: 'Warm glow',
      icon: Icons.light_mode_rounded,
      assetPath: 'audio/music_corner_warm_glow.wav',
    ),
    MusicCornerSound(
      id: 'drops',
      label: 'Dream drops',
      icon: Icons.bubble_chart_rounded,
      assetPath: 'audio/music_corner_dream_drops.wav',
    ),
    MusicCornerSound(
      id: 'chimes',
      label: 'Soft chimes',
      icon: Icons.music_note_rounded,
      assetPath: 'audio/music_corner_soft_chimes.wav',
    ),
    MusicCornerSound(
      id: 'rhythm',
      label: 'Gentle rhythm',
      icon: Icons.favorite_rounded,
      assetPath: 'audio/music_corner_gentle_rhythm.wav',
    ),
    MusicCornerSound(
      id: 'plucks',
      label: 'Soft plucks',
      icon: Icons.graphic_eq_rounded,
      assetPath: 'audio/music_corner_soft_plucks.wav',
    ),
  ];

  late final MusicCornerAudioController _audio;
  MusicCornerSound? _activeSound;
  double _volume = 0.35;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _audio = widget.audioController ?? AssetMusicCornerAudioController();
  }

  @override
  void dispose() {
    _audio.dispose();
    super.dispose();
  }

  Future<void> _toggleSound(MusicCornerSound sound) async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      if (_activeSound?.id == sound.id) {
        await _audio.stop();
        if (mounted) setState(() => _activeSound = null);
      } else {
        await _audio.play(sound, volume: _volume);
        if (mounted) setState(() => _activeSound = sound);
      }
    } catch (_) {
      if (!mounted) return;
      setState(() => _activeSound = null);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("That sound couldn't play. Try another one."),
        ),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _stopSound() async {
    if (_busy) return;
    setState(() => _busy = true);
    await _audio.stop();
    if (mounted) {
      setState(() {
        _activeSound = null;
        _busy = false;
      });
    }
  }

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
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: const Color(0xFF6C63FF).withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: const Color(
                            0xFF6C63FF,
                          ).withValues(alpha: 0.30),
                        ),
                      ),
                      child: const Column(
                        children: [
                          Icon(
                            Icons.music_note_rounded,
                            color: Color(0xFF9B8FFF),
                            size: 42,
                          ),
                          SizedBox(height: 10),
                          Text(
                            'Tap a sound and see what feels nice.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Color(0xFFF0D6FF),
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                              fontFamily: 'DM Sans',
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _sounds.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 1.25,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                          ),
                      itemBuilder: (context, index) {
                        final sound = _sounds[index];
                        final active = _activeSound?.id == sound.id;
                        return _MusicSoundButton(
                          sound: sound,
                          active: active,
                          busy: _busy,
                          onTap: () => _toggleSound(sound),
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    GestureDetector(
                      key: const Key('music-corner-stop'),
                      onTap: _activeSound == null ? null : _stopSound,
                      child: Container(
                        height: 54,
                        decoration: BoxDecoration(
                          color: _activeSound == null
                              ? Colors.white.withValues(alpha: 0.06)
                              : const Color(0xFFFF6B8A).withValues(alpha: 0.16),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: _activeSound == null
                                ? Colors.white.withValues(alpha: 0.10)
                                : const Color(
                                    0xFFFF6B8A,
                                  ).withValues(alpha: 0.45),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.stop_circle_rounded,
                              color: _activeSound == null
                                  ? Colors.white.withValues(alpha: 0.35)
                                  : const Color(0xFFFFB3C1),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Stop sound',
                              style: TextStyle(
                                color: _activeSound == null
                                    ? Colors.white.withValues(alpha: 0.35)
                                    : const Color(0xFFFFD5DD),
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                fontFamily: 'DM Sans',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.10),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Gentle volume',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.70),
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              fontFamily: 'DM Sans',
                            ),
                          ),
                          Slider(
                            value: _volume,
                            min: 0.15,
                            max: 0.55,
                            activeColor: const Color(0xFF9B8FFF),
                            inactiveColor: Colors.white.withValues(alpha: 0.12),
                            onChanged: (value) {
                              setState(() => _volume = value);
                              if (_activeSound != null) {
                                _audio.setVolume(value);
                              }
                            },
                          ),
                        ],
                      ),
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

class _MusicSoundButton extends StatelessWidget {
  final MusicCornerSound sound;
  final bool active;
  final bool busy;
  final VoidCallback onTap;

  const _MusicSoundButton({
    required this.sound,
    required this.active,
    required this.busy,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final accent = active ? const Color(0xFF4ECDC4) : const Color(0xFF6C63FF);
    return GestureDetector(
      key: Key('music-sound-${sound.id}'),
      onTap: busy ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: accent.withValues(alpha: active ? 0.20 : 0.10),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: accent.withValues(alpha: active ? 0.65 : 0.30),
            width: active ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(sound.icon, color: accent, size: 30),
            const SizedBox(height: 8),
            Text(
              sound.label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFFF0D6FF),
                fontSize: 14,
                fontWeight: FontWeight.w800,
                fontFamily: 'DM Sans',
              ),
            ),
            const SizedBox(height: 4),
            Text(
              active ? 'Playing' : 'Tap to play',
              style: TextStyle(
                color: Colors.white.withValues(alpha: active ? 0.78 : 0.45),
                fontSize: 11,
                fontFamily: 'DM Sans',
              ),
            ),
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
  @override
  State<GrowTogetherScreen> createState() => _GrowTogetherState();
}

class _GrowTogetherState extends State<GrowTogetherScreen>
    with SingleTickerProviderStateMixin {
  int _waters = 0;
  late final AnimationController _grow;

  static const _stages = ['🌱', '🌿', '🍀', '🌸', '🌺', '🌻'];
  static const _messages = [
    'Just starting. Give it water and love.',
    'It is growing! You can see the leaves.',
    'Looking healthy! Every drop counts.',
    'Beautiful. Your care shows.',
    'In full bloom — just like you.',
    'You grew this. A whole flower, from nothing.',
  ];

  @override
  void initState() {
    super.initState();
    _grow = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
  }

  @override
  void dispose() {
    _grow.dispose();
    super.dispose();
  }

  void _water() {
    _grow.forward(from: 0);
    setState(() => _waters++);
  }

  @override
  Widget build(BuildContext context) {
    final stage = (_waters ~/ 3).clamp(0, _stages.length - 1);
    return Scaffold(
      backgroundColor: const Color(0xFF0A1A0F),
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
                        color: const Color(0xFF4ECDC4).withValues(alpha: 0.12),
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
                    '🌱  Grow Together',
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
            AnimatedBuilder(
              animation: _grow,
              builder: (_, __) => Transform.scale(
                scale: 1.0 + _grow.value * 0.08,
                child: Text(
                  _stages[stage],
                  style: const TextStyle(fontSize: 100),
                ),
              ),
            ),
            const SizedBox(height: 14),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                _messages[stage],
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFF7AA880),
                  fontSize: 14,
                  fontFamily: 'DM Sans',
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Waters: $_waters 💧',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.35),
                fontSize: 12,
                fontFamily: 'DM Sans',
              ),
            ),
            const SizedBox(height: 40),
            GestureDetector(
              onTap: _water,
              child: Container(
                width: 88,
                height: 88,
                decoration: BoxDecoration(
                  color: const Color(0xFF4ECDC4).withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFF4ECDC4).withValues(alpha: 0.50),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF4ECDC4).withValues(alpha: 0.25),
                      blurRadius: 24,
                    ),
                  ],
                ),
                child: const Center(
                  child: Text('💧', style: TextStyle(fontSize: 44)),
                ),
              ),
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}
