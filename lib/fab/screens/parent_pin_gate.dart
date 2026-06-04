import 'package:flutter/material.dart';
import '../models/family_account.dart';
import 'parent_dashboard_screen.dart';

// ─────────────────────────────────────────────────────────────
// ParentPinGate
//
// Wraps ParentDashboardScreen. If a parent PIN is set it shows
// a 4-dot PIN entry with shake-on-fail animation. If no PIN is
// set it goes straight through.
//
// Also used from FabHomeScreen skeleton-key button.
// ─────────────────────────────────────────────────────────────

class ParentPinGate extends StatefulWidget {
  const ParentPinGate({super.key});

  @override
  State<ParentPinGate> createState() => _ParentPinGateState();
}

class _ParentPinGateState extends State<ParentPinGate>
    with TickerProviderStateMixin {
  final List<String> _digits = [];
  String? _error;

  static const _purple = Color(0xFF6C63FF);
  static const _pink   = Color(0xFFFF6B8A);
  static const _bg     = Color(0xFF0D0820);

  late final AnimationController _shakeCtrl;
  late final Animation<double>   _shakeAnim;

  @override
  void initState() {
    super.initState();
    _shakeCtrl = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 420),
    );
    _shakeAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _shakeCtrl, curve: Curves.elasticIn),
    );

    // If no PIN set, skip straight through
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final account = FamilyAccount.current;
      if (account == null || !account.hasParentPin) _goThrough();
    });
  }

  @override
  void dispose() {
    _shakeCtrl.dispose();
    super.dispose();
  }

  void _tap(String d) {
    if (_digits.length >= 4) return;
    setState(() {
      _digits.add(d);
      _error = null;
    });
    if (_digits.length == 4) _check();
  }

  void _delete() {
    if (_digits.isEmpty) return;
    setState(() => _digits.removeLast());
  }

  void _check() {
    final account = FamilyAccount.current;
    final pin = _digits.join();
    if (account == null || account.checkParentPin(pin)) {
      _goThrough();
    } else {
      _shakeCtrl.forward(from: 0);
      setState(() {
        _digits.clear();
        _error = 'Wrong PIN. Try again.';
      });
    }
  }

  void _goThrough() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const ParentDashboardScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 12),
            Row(
              children: [
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.arrow_back_rounded,
                      color: Color(0xFFF0D6FF)),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const Spacer(),
            // Lock icon
            Container(
              width: 64, height: 64,
              decoration: BoxDecoration(
                color: _purple.withValues(alpha: 0.15),
                shape: BoxShape.circle,
                border: Border.all(color: _purple.withValues(alpha: 0.40)),
              ),
              child: const Icon(Icons.shield_rounded, color: _purple, size: 32),
            ),
            const SizedBox(height: 20),
            const Text(
              'Parent Dashboard',
              style: TextStyle(
                color: Color(0xFFF0D6FF),
                fontSize: 22,
                fontWeight: FontWeight.w800,
                fontFamily: 'DM Sans',
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Enter your 4-digit PIN',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.50),
                fontSize: 14,
                fontFamily: 'DM Sans',
              ),
            ),
            const SizedBox(height: 36),
            // PIN dots with shake
            AnimatedBuilder(
              animation: _shakeAnim,
              builder: (_, child) {
                final shake = _shakeAnim.value * 8 *
                    (_digits.isEmpty ? 0 : 1);
                return Transform.translate(
                  offset: Offset(
                      shake * (_shakeAnim.value % 2 == 0 ? 1 : -1), 0),
                  child: child,
                );
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(4, (i) {
                  final filled = i < _digits.length;
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 10),
                    width: 18, height: 18,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: filled
                          ? _purple
                          : Colors.white.withValues(alpha: 0.18),
                      border: Border.all(
                        color: filled
                            ? _purple
                            : Colors.white.withValues(alpha: 0.30),
                      ),
                    ),
                  );
                }),
              ),
            ),
            if (_error != null) ...[
              const SizedBox(height: 12),
              Text(
                _error!,
                style: const TextStyle(
                    color: _pink, fontSize: 13, fontFamily: 'DM Sans'),
              ),
            ],
            const SizedBox(height: 40),
            // Number pad
            _NumberPad(onTap: _tap, onDelete: _delete),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}

// ── Number pad ────────────────────────────────────────────────

class _NumberPad extends StatelessWidget {
  final void Function(String) onTap;
  final VoidCallback onDelete;
  const _NumberPad({required this.onTap, required this.onDelete});

  static const _keys = [
    ['1', '2', '3'],
    ['4', '5', '6'],
    ['7', '8', '9'],
    ['', '0', '⌫'],
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 56),
      child: Column(
        children: _keys.map((row) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: row.map((k) {
                if (k.isEmpty) return const SizedBox(width: 72, height: 56);
                return GestureDetector(
                  onTap: () => k == '⌫' ? onDelete() : onTap(k),
                  child: Container(
                    width: 72, height: 56,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.07),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Text(
                      k,
                      style: const TextStyle(
                        color: Color(0xFFF0D6FF),
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'DM Sans',
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          );
        }).toList(),
      ),
    );
  }
}
