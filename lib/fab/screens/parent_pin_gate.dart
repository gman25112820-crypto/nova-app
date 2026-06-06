import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
  bool _locked = false;
  DateTime? _lockUntil;

  static const _purple     = Color(0xFF6C63FF);
  static const _pink       = Color(0xFFFF6B8A);
  static const _bg         = Color(0xFF0D0820);
  static const _skeletonKey = '0000';   // emergency override PIN
  static const _maxAttempts = 3;
  static const _lockMins    = 5;

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

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final account = FamilyAccount.current;
      if (account == null || !account.hasParentPin) {
        _goThrough();
        return;
      }
      await _checkLockout();
    });
  }

  @override
  void dispose() {
    _shakeCtrl.dispose();
    super.dispose();
  }

  Future<void> _checkLockout() async {
    final prefs = await SharedPreferences.getInstance();
    final lockUntilMs = prefs.getInt('pin_lock_until');
    if (lockUntilMs != null) {
      final lockUntil = DateTime.fromMillisecondsSinceEpoch(lockUntilMs);
      if (DateTime.now().isBefore(lockUntil)) {
        if (mounted) setState(() { _locked = true; _lockUntil = lockUntil; });
        return;
      }
      // Lock expired — clear it
      await prefs.remove('pin_lock_until');
      await prefs.remove('pin_fail_count');
    }
  }

  Future<int> _failCount() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('pin_fail_count') ?? 0;
  }

  Future<void> _recordFail() async {
    final prefs = await SharedPreferences.getInstance();
    final count = (prefs.getInt('pin_fail_count') ?? 0) + 1;
    await prefs.setInt('pin_fail_count', count);
    if (count >= _maxAttempts) {
      final until = DateTime.now().add(const Duration(minutes: _lockMins));
      await prefs.setInt('pin_lock_until', until.millisecondsSinceEpoch);
      if (mounted) setState(() { _locked = true; _lockUntil = until; });
    }
  }

  Future<void> _clearFails() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('pin_fail_count');
    await prefs.remove('pin_lock_until');
  }

  void _tap(String d) {
    if (_locked || _digits.length >= 4) return;
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

  Future<void> _check() async {
    final account = FamilyAccount.current;
    final pin = _digits.join();

    // Skeleton key bypasses PIN
    if (pin == _skeletonKey) {
      await _clearFails();
      _goThrough();
      return;
    }

    if (account == null || account.checkParentPin(pin)) {
      await _clearFails();
      _goThrough();
    } else {
      _shakeCtrl.forward(from: 0);
      await _recordFail();
      final fails = await _failCount();
      final remaining = _maxAttempts - fails;
      if (mounted) {
        setState(() {
          _digits.clear();
          _error = _locked
              ? null
              : (remaining > 0 ? 'Wrong PIN — $remaining attempt${remaining == 1 ? "" : "s"} left.' : null);
        });
      }
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
    if (_locked) return _buildLockout();
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

  Widget _buildLockout() {
    final mins = _lockUntil != null
        ? _lockUntil!.difference(DateTime.now()).inMinutes + 1
        : _lockMins;
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 12),
            Row(children: [
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.arrow_back_rounded, color: Color(0xFFF0D6FF)),
                onPressed: () => Navigator.pop(context),
              ),
            ]),
            const Spacer(),
            const Text('🔒', style: TextStyle(fontSize: 56)),
            const SizedBox(height: 20),
            const Text(
              'Too many attempts',
              style: TextStyle(
                color: Color(0xFFF0D6FF),
                fontSize: 22,
                fontWeight: FontWeight.w800,
                fontFamily: 'DM Sans',
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Try again in $mins minute${mins == 1 ? "" : "s"}.',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.55),
                fontSize: 14,
                fontFamily: 'DM Sans',
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Emergency access: enter 0000',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.35),
                fontSize: 12,
                fontFamily: 'DM Sans',
              ),
            ),
            const SizedBox(height: 40),
            _NumberPad(
              onTap: (d) {
                setState(() => _digits.add(d));
                if (_digits.length == 4) {
                  if (_digits.join() == _skeletonKey) {
                    _clearFails().then((_) => _goThrough());
                  } else {
                    setState(() => _digits.clear());
                  }
                }
              },
              onDelete: () {
                if (_digits.isNotEmpty) setState(() => _digits.removeLast());
              },
            ),
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

// ─────────────────────────────────────────────────────────────
// ParentPinSetupScreen
//
// Two-step flow: enter new PIN → confirm PIN → save to Hive.
// Shown from settings when no PIN is set or to change it.
// ─────────────────────────────────────────────────────────────

class ParentPinSetupScreen extends StatefulWidget {
  const ParentPinSetupScreen({super.key});

  @override
  State<ParentPinSetupScreen> createState() => _ParentPinSetupState();
}

class _ParentPinSetupState extends State<ParentPinSetupScreen> {
  final List<String> _first = [];
  final List<String> _second = [];
  bool _confirming = false;
  String? _error;

  static const _purple = Color(0xFF6C63FF);
  static const _pink   = Color(0xFFFF6B8A);
  static const _teal   = Color(0xFF00C9A7);
  static const _bg     = Color(0xFF0D0820);

  List<String> get _active => _confirming ? _second : _first;

  void _tap(String d) {
    if (_active.length >= 4) return;
    setState(() {
      _active.add(d);
      _error = null;
    });
    if (_active.length == 4) _advance();
  }

  void _delete() {
    if (_active.isEmpty) return;
    setState(() => _active.removeLast());
  }

  void _advance() {
    if (!_confirming) {
      setState(() => _confirming = true);
      return;
    }
    if (_first.join() == _second.join()) {
      _save();
    } else {
      setState(() {
        _second.clear();
        _error = "PINs don't match — try again.";
      });
    }
  }

  Future<void> _save() async {
    final account = FamilyAccount.current;
    if (account == null) return;
    account.setParentPin(_first.join());
    await account.save();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('PIN set! Keep it safe.', style: TextStyle(fontFamily: 'DM Sans')),
        backgroundColor: Color(0xFF2D1556),
      ),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final digits = _active;
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 12),
            Row(children: [
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.arrow_back_rounded, color: Color(0xFFF0D6FF)),
                onPressed: () {
                  if (_confirming) {
                    setState(() { _confirming = false; _second.clear(); });
                  } else {
                    Navigator.pop(context);
                  }
                },
              ),
            ]),
            const Spacer(),
            Container(
              width: 64, height: 64,
              decoration: BoxDecoration(
                color: _purple.withValues(alpha: 0.15),
                shape: BoxShape.circle,
                border: Border.all(color: _purple.withValues(alpha: 0.40)),
              ),
              child: const Icon(Icons.lock_outline_rounded, color: _purple, size: 32),
            ),
            const SizedBox(height: 20),
            Text(
              _confirming ? 'Confirm your PIN' : 'Choose a 4-digit PIN',
              style: const TextStyle(
                color: Color(0xFFF0D6FF),
                fontSize: 22,
                fontWeight: FontWeight.w800,
                fontFamily: 'DM Sans',
              ),
            ),
            const SizedBox(height: 6),
            Text(
              _confirming ? 'Enter the same PIN again' : 'You will use this to access the Parent Zone',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.50),
                fontSize: 13,
                fontFamily: 'DM Sans',
              ),
            ),
            const SizedBox(height: 36),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(4, (i) {
                final filled = i < digits.length;
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 10),
                  width: 18, height: 18,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: filled ? _teal : Colors.white.withValues(alpha: 0.18),
                    border: Border.all(
                      color: filled ? _teal : Colors.white.withValues(alpha: 0.30),
                    ),
                  ),
                );
              }),
            ),
            if (_error != null) ...[
              const SizedBox(height: 12),
              Text(_error!, style: const TextStyle(color: _pink, fontSize: 13, fontFamily: 'DM Sans')),
            ],
            const SizedBox(height: 40),
            _NumberPad(onTap: _tap, onDelete: _delete),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}
