import 'package:flutter/material.dart';
import '../services/fab_stars_service.dart';

// ─────────────────────────────────────────────────────────────
// CalmBreathingGame
//
// Guided 4-2-6 breathing (in 4, hold 2, out 6 counts).
// Complete 3 rounds → earn 3 Fab Stars.
// Expanding/contracting circle follows the breath phase.
// Also works as a standalone regulation tool.
// ─────────────────────────────────────────────────────────────

enum _Phase { ready, breatheIn, hold, breatheOut, done }

class CalmBreathingGame extends StatefulWidget {
  const CalmBreathingGame({super.key});

  @override
  State<CalmBreathingGame> createState() => _CalmBreathingGameState();
}

class _CalmBreathingGameState extends State<CalmBreathingGame>
    with SingleTickerProviderStateMixin {
  static const _bg     = Color(0xFF021A24);
  static const _teal   = Color(0xFF00C9A7);
  static const _purple = Color(0xFF6C63FF);

  static const _totalRounds = 3;
  static const _inSecs      = 4;
  static const _holdSecs    = 2;
  static const _outSecs     = 6;

  late AnimationController _circleCtrl;
  late Animation<double>   _circleAnim;

  _Phase _phase  = _Phase.ready;
  int    _round  = 0;
  int    _countdown = 0;
  bool   _awarded   = false;
  int    _starsEarned = 0;

  @override
  void initState() {
    super.initState();
    _circleCtrl = AnimationController(vsync: this);
    _circleAnim = _circleCtrl.drive(
      Tween<double>(begin: 0.4, end: 1.0)
          .chain(CurveTween(curve: Curves.easeInOut)),
    );
  }

  @override
  void dispose() {
    _circleCtrl.dispose();
    super.dispose();
  }

  // ── Breath cycle ──────────────────────────────────────────────

  void _start() {
    setState(() {
      _phase = _Phase.breatheIn;
      _round = 1;
    });
    _runIn();
  }

  void _runIn() {
    if (!mounted) return;
    setState(() {
      _phase     = _Phase.breatheIn;
      _countdown = _inSecs;
    });
    _circleCtrl.duration = const Duration(seconds: _inSecs);
    _circleCtrl.forward(from: 0).then((_) => _runHold());
    _tickDown(_inSecs, () {});
  }

  void _runHold() {
    if (!mounted) return;
    setState(() {
      _phase     = _Phase.hold;
      _countdown = _holdSecs;
    });
    // circle stays expanded during hold
    Future.delayed(const Duration(seconds: _holdSecs), _runOut);
    _tickDown(_holdSecs, () {});
  }

  void _runOut() {
    if (!mounted) return;
    setState(() {
      _phase     = _Phase.breatheOut;
      _countdown = _outSecs;
    });
    _circleCtrl.duration = const Duration(seconds: _outSecs);
    _circleCtrl.reverse().then((_) => _nextRound());
    _tickDown(_outSecs, () {});
  }

  void _tickDown(int secs, VoidCallback onDone) {
    for (int i = 1; i <= secs; i++) {
      Future.delayed(Duration(seconds: i), () {
        if (!mounted) return;
        setState(() => _countdown = secs - i);
      });
    }
    Future.delayed(Duration(seconds: secs), onDone);
  }

  Future<void> _nextRound() async {
    if (!mounted) return;
    if (_round >= _totalRounds) {
      if (!_awarded) {
        _awarded = true;
        final result =
            await FabStarsService.awardForGame(3, '⭐ Calm breathing');
        if (!mounted) return;
        setState(() => _starsEarned = result.earned);
      }
      setState(() => _phase = _Phase.done);
      return;
    }
    setState(() => _round++);
    _runIn();
  }

  // ── Build ──────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          '🫁  Calm Breathing',
          style: TextStyle(
            fontFamily: 'DM Sans',
            fontWeight: FontWeight.w700,
            fontSize: 16,
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            children: [
              const SizedBox(height: 16),
              _buildRoundDots(),
              const Spacer(),
              _buildCircle(),
              const SizedBox(height: 32),
              _buildPhaseLabel(),
              const Spacer(),
              _buildButton(),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoundDots() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(_totalRounds, (i) {
        final done = i < _round - 1 ||
            (_round > i && _phase == _Phase.done);
        final active = i == _round - 1 && _phase != _Phase.done;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 6),
          width: active ? 24 : 16,
          height: 8,
          decoration: BoxDecoration(
            color: done || active
                ? _teal
                : Colors.white.withValues(alpha: 0.20),
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }

  Widget _buildCircle() {
    return AnimatedBuilder(
      animation: _circleAnim,
      builder: (_, __) {
        final scale = _phase == _Phase.ready ? 0.4 : _circleAnim.value;
        final size  = 240.0 * scale;
        return Center(
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _teal.withValues(alpha: 0.10),
              border: Border.all(
                color: _teal.withValues(alpha: 0.60),
                width: 3,
              ),
              boxShadow: [
                BoxShadow(
                  color: _teal.withValues(alpha: 0.25 * scale),
                  blurRadius: 60 * scale,
                  spreadRadius: 10 * scale,
                ),
              ],
            ),
            child: Center(
              child: _phase == _Phase.ready
                  ? null
                  : Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '$_countdown',
                          style: TextStyle(
                            color: _teal,
                            fontSize: 42 * scale.clamp(0.5, 1.0),
                            fontWeight: FontWeight.w300,
                            fontFamily: 'DM Sans',
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPhaseLabel() {
    final (label, sublabel, color) = switch (_phase) {
      _Phase.ready      => ('Ready to begin', 'Follow the circle', Colors.white70),
      _Phase.breatheIn  => ('Breathe in…', '$_inSecs counts', _teal),
      _Phase.hold       => ('Hold…', '$_holdSecs counts', _purple),
      _Phase.breatheOut => ('Breathe out…', '$_outSecs counts',
                             const Color(0xFFFF6B8A)),
      _Phase.done       => ('All done!',
                             _starsEarned > 0 ? '⭐ +$_starsEarned Fab Stars!' : '',
                             _teal),
    };

    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            color: color,
            fontSize: 24,
            fontWeight: FontWeight.w700,
            fontFamily: 'DM Sans',
          ),
        ),
        if (sublabel.isNotEmpty) ...[
          const SizedBox(height: 6),
          Text(
            sublabel,
            style: TextStyle(
              color: color.withValues(alpha: 0.70),
              fontSize: 14,
              fontFamily: 'DM Sans',
            ),
          ),
        ],
        if (_phase == _Phase.done && _starsEarned > 0) ...[
          const SizedBox(height: 16),
          Text(
            '⭐ +$_starsEarned Fab Stars!',
            style: const TextStyle(
              color: Color(0xFFFFD700),
              fontSize: 20,
              fontWeight: FontWeight.w800,
              fontFamily: 'DM Sans',
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildButton() {
    final (label, color, action) = switch (_phase) {
      _Phase.ready => ('Start breathing', _teal, _start),
      _Phase.done  => ('Do it again', _teal, _restart),
      _            => ('', _teal, () {}),
    };

    if (_phase != _Phase.ready && _phase != _Phase.done) {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        GestureDetector(
          onTap: action,
          child: Container(
            width: double.infinity,
            height: 52,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                  colors: [_teal, _purple]),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'DM Sans',
                ),
              ),
            ),
          ),
        ),
        if (_phase == _Phase.done) ...[
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: double.infinity,
              height: 44,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Center(
                child: Text(
                  'Back',
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 15,
                    fontFamily: 'DM Sans',
                  ),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  void _restart() {
    setState(() {
      _phase      = _Phase.ready;
      _round      = 0;
      _awarded    = false;
      _starsEarned = 0;
      _countdown  = 0;
    });
    _circleCtrl.value = 0;
  }
}
