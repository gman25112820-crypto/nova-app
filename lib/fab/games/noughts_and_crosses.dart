import 'dart:math';
import 'package:flutter/material.dart';
import '../services/fab_stars_service.dart';
import '../widgets/chicken_lips_widget.dart';

// ─────────────────────────────────────────────────────────────
// NoughtsAndCrossesGame
//
// Player is X, Chicken Lips is O. Simple AI — winnable but not
// unbeatable (priority: win > block > centre > corner > random).
// Win → 5 stars, Draw → 2 stars, Loss → 0 stars.
// ─────────────────────────────────────────────────────────────

class NoughtsAndCrossesGame extends StatefulWidget {
  const NoughtsAndCrossesGame({super.key});

  @override
  State<NoughtsAndCrossesGame> createState() => _NoughtsAndCrossesGameState();
}

class _NoughtsAndCrossesGameState extends State<NoughtsAndCrossesGame>
    with SingleTickerProviderStateMixin {
  static const _purple = Color(0xFF6C63FF);
  static const _pink   = Color(0xFFFF6B8A);
  static const _teal   = Color(0xFF00C9A7);
  static const _bg     = Color(0xFF0D0820);
  static const _card   = Color(0xFF120C28);

  List<String> _board = List.filled(9, '');
  bool _playerTurn = true;
  String _status   = '';
  bool _gameOver   = false;
  ChickenMood _chickenMood = ChickenMood.happy;
  int _starsEarned = 0;

  late final AnimationController _winCtrl;
  late final Animation<double> _winScale;

  @override
  void initState() {
    super.initState();
    _winCtrl  = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    _winScale = CurvedAnimation(parent: _winCtrl, curve: Curves.elasticOut);
    _status = 'Your turn — you\'re X!';
  }

  @override
  void dispose() {
    _winCtrl.dispose();
    super.dispose();
  }

  // ── Game logic ────────────────────────────────────────────────

  void _onTap(int index) {
    if (!_playerTurn || _board[index].isNotEmpty || _gameOver) return;
    setState(() => _board[index] = 'X');

    final winner = _checkWinner(_board);
    if (winner != null) {
      _endGame(winner);
      return;
    }
    if (_isFull()) {
      _endGame('draw');
      return;
    }

    setState(() {
      _playerTurn = false;
      _status = 'Chicken Lips is thinking…';
    });

    Future.delayed(const Duration(milliseconds: 520), () {
      if (!mounted) return;
      final move = _aiMove(_board);
      setState(() => _board[move] = 'O');
      final w = _checkWinner(_board);
      if (w != null) {
        _endGame(w);
      } else if (_isFull()) {
        _endGame('draw');
      } else {
        setState(() {
          _playerTurn = true;
          _status = 'Your turn!';
        });
      }
    });
  }

  String? _checkWinner(List<String> b) {
    const lines = [
      [0, 1, 2], [3, 4, 5], [6, 7, 8],
      [0, 3, 6], [1, 4, 7], [2, 5, 8],
      [0, 4, 8], [2, 4, 6],
    ];
    for (final line in lines) {
      final s = b[line[0]];
      if (s.isNotEmpty && s == b[line[1]] && s == b[line[2]]) return s;
    }
    return null;
  }

  bool _isFull() => _board.every((c) => c.isNotEmpty);

  // Simple AI: win > block > centre > corner > random
  int _aiMove(List<String> b) {
    // 1. Win if possible
    final win = _findBestMove(b, 'O');
    if (win != null) return win;
    // 2. Block player win
    final block = _findBestMove(b, 'X');
    if (block != null) return block;
    // 3. Centre
    if (b[4].isEmpty) return 4;
    // 4. Random corner (adds some unpredictability)
    final corners = [0, 2, 6, 8].where((i) => b[i].isEmpty).toList();
    if (corners.isNotEmpty) return corners[Random().nextInt(corners.length)];
    // 5. Any empty
    return b.indexWhere((c) => c.isEmpty);
  }

  int? _findBestMove(List<String> b, String mark) {
    const lines = [
      [0, 1, 2], [3, 4, 5], [6, 7, 8],
      [0, 3, 6], [1, 4, 7], [2, 5, 8],
      [0, 4, 8], [2, 4, 6],
    ];
    for (final line in lines) {
      final cells = line.map((i) => b[i]).toList();
      if (cells.where((c) => c == mark).length == 2 &&
          cells.contains('')) {
        return line[cells.indexOf('')];
      }
    }
    return null;
  }

  Future<void> _endGame(String result) async {
    int stars = 0;
    String msg = '';
    ChickenMood mood = ChickenMood.happy;

    if (result == 'X') {
      stars = 5;
      msg   = 'You won! Amazing! 🎉';
      mood  = ChickenMood.sad;
    } else if (result == 'O') {
      msg  = 'Chicken Lips wins this one! 🐔';
      mood = ChickenMood.crowned;
    } else {
      stars = 2;
      msg   = 'It\'s a draw! Great game! 🤝';
      mood  = ChickenMood.wink;
    }

    AwardResult? award;
    if (stars > 0) {
      award = await FabStarsService.awardForGame(stars, '⭐ Game');
    }

    if (!mounted) return;
    setState(() {
      _gameOver     = true;
      _status       = msg;
      _chickenMood  = mood;
      _starsEarned  = award?.earned ?? 0;
    });
    _winCtrl.forward(from: 0);
  }

  void _reset() {
    setState(() {
      _board        = List.filled(9, '');
      _playerTurn   = true;
      _gameOver     = false;
      _status       = 'Your turn — you\'re X!';
      _chickenMood  = ChickenMood.happy;
      _starsEarned  = 0;
    });
    _winCtrl.reset();
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
          '🎮  Noughts & Crosses',
          style: TextStyle(
            fontFamily: 'DM Sans',
            fontWeight: FontWeight.w700,
            fontSize: 16,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              _buildChickenRow(),
              const SizedBox(height: 16),
              _buildStatusBar(),
              const SizedBox(height: 20),
              Center(
                child: SizedBox(
                  width: 300,
                  height: 300,
                  child: _buildBoard(),
                ),
              ),
              const SizedBox(height: 24),
              if (_gameOver) _buildResultPanel(),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChickenRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ChickenLipsWidget(mood: _chickenMood, scale: 0.28),
        const SizedBox(width: 14),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'MISS CHICKEN LIPS',
              style: TextStyle(
                color: Color(0xFFB39DDB),
                fontSize: 8,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.4,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              _chickenMoodLine(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontFamily: 'DM Sans',
                height: 1.3,
              ),
            ),
          ],
        ),
      ],
    );
  }

  String _chickenMoodLine() {
    if (_gameOver) {
      final w = _checkWinner(_board);
      if (w == 'X') return 'Well played — you got me! 😮';
      if (w == 'O') return 'Ha! Better luck next time! 😄';
      return 'A draw! You\'re tough to beat! 😌';
    }
    if (!_playerTurn) return 'Hmm, let me think…';
    return 'I\'m O, you\'re X. Let\'s play!';
  }

  Widget _buildStatusBar() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: _purple.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _purple.withValues(alpha: 0.28)),
      ),
      child: Text(
        _status,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Colors.white,
          fontFamily: 'DM Sans',
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildBoard() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
      ),
      itemCount: 9,
      itemBuilder: (_, i) => _buildCell(i),
    );
  }

  Widget _buildCell(int index) {
    final mark  = _board[index];
    final isX   = mark == 'X';
    final color = isX ? _purple : _pink;

    return GestureDetector(
      onTap: () => _onTap(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        decoration: BoxDecoration(
          color: mark.isEmpty
              ? _card
              : color.withValues(alpha: 0.14),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: mark.isEmpty
                ? Colors.white.withValues(alpha: 0.10)
                : color.withValues(alpha: 0.55),
            width: 1.5,
          ),
        ),
        child: Center(
          child: mark.isEmpty
              ? null
              : Text(
                  mark,
                  style: TextStyle(
                    color: color,
                    fontSize: 38,
                    fontWeight: FontWeight.w800,
                    fontFamily: 'DM Sans',
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildResultPanel() {
    return ScaleTransition(
      scale: _winScale,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: _card,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: _teal.withValues(alpha: 0.35)),
          boxShadow: [
            BoxShadow(
              color: _teal.withValues(alpha: 0.18),
              blurRadius: 20,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          children: [
            if (_starsEarned > 0) ...[
              Text(
                '⭐ +$_starsEarned Fab Stars!',
                style: const TextStyle(
                  color: Color(0xFFFFD700),
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  fontFamily: 'DM Sans',
                ),
              ),
              const SizedBox(height: 12),
            ],
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _ActionButton(
                  label: 'Play again',
                  color: _purple,
                  onTap: _reset,
                ),
                _ActionButton(
                  label: 'Done',
                  color: _teal,
                  onTap: () => Navigator.pop(context),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── Shared button widget ──────────────────────────────────────

class _ActionButton extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.16),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.50)),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: color,
            fontSize: 14,
            fontWeight: FontWeight.w700,
            fontFamily: 'DM Sans',
          ),
        ),
      ),
    );
  }
}
