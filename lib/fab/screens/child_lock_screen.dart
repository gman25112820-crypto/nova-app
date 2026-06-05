import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/child_profile.dart';
import '../models/family_account.dart';

// ─────────────────────────────────────────────────────────────
// ChildLockScreen
//
// Shown when a child opens their profile and a PIN is set.
// Mode.enter  — enter PIN to unlock (skipped if idle timer ok)
// Mode.setup  — choose and confirm a new PIN
// Mode.change — enter old PIN, then choose new PIN
//
// PIN prefs stored in Hive box 'pin_prefs':
//   require_mode            → 'always' | 'idle_15'
//   last_unlock_{childId}   → epoch ms of last successful unlock
//
// Teen band: optional child-set PIN for private zones.
//   Stored in Hive box 'child_{id}_pin_prefs', key 'child_pin_hash'.
//   Parent skeleton key always overrides.
// ─────────────────────────────────────────────────────────────

const _kPinPrefsBox = 'pin_prefs';
const _kRequireModeKey = 'require_mode';

Future<bool> shouldShowPinFor(ChildProfile child) async {
  if (!child.pinEnabled) return false;
  final box = await Hive.openBox<dynamic>(_kPinPrefsBox);
  final mode = box.get(_kRequireModeKey, defaultValue: 'always') as String;
  if (mode == 'always') return true;
  // idle_15: skip if unlocked within last 15 minutes
  final lastKey = 'last_unlock_${child.id}';
  final lastEpoch = box.get(lastKey) as int?;
  if (lastEpoch == null) return true;
  final elapsed = DateTime.now().millisecondsSinceEpoch - lastEpoch;
  return elapsed > const Duration(minutes: 15).inMilliseconds;
}

Future<void> recordUnlock(String childId) async {
  final box = await Hive.openBox<dynamic>(_kPinPrefsBox);
  await box.put('last_unlock_$childId', DateTime.now().millisecondsSinceEpoch);
}

enum _LockMode { enter, setup, change }

class ChildLockScreen extends StatefulWidget {
  final ChildProfile child;

  /// [setup] = true when called from profile settings to create/change PIN.
  const ChildLockScreen({super.key, required this.child, this.setup = false});

  final bool setup;

  @override
  State<ChildLockScreen> createState() => _ChildLockScreenState();
}

class _ChildLockScreenState extends State<ChildLockScreen>
    with SingleTickerProviderStateMixin {

  late _LockMode _mode;
  String _digits = '';
  String _setupFirst = '';
  String? _errorMsg;
  late final AnimationController _shakeCtrl;
  late final Animation<double> _shakeAnim;

  // Require-mode preference (loaded async)
  String _requireMode = 'always';
  bool _prefsLoaded = false;

  static const _pink   = Color(0xFFFF6B8A);
  static const _purple = Color(0xFF6C63FF);
  static const _bg     = Color(0xFF0D0820);

  @override
  void initState() {
    super.initState();
    _mode = widget.setup
        ? (widget.child.pinEnabled ? _LockMode.change : _LockMode.setup)
        : _LockMode.enter;

    _shakeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _shakeAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _shakeCtrl, curve: Curves.elasticIn),
    );
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    final box = await Hive.openBox<dynamic>(_kPinPrefsBox);
    final mode = box.get(_kRequireModeKey, defaultValue: 'always') as String;
    if (mounted) setState(() { _requireMode = mode; _prefsLoaded = true; });
  }

  Future<void> _saveRequireMode(String mode) async {
    final box = await Hive.openBox<dynamic>(_kPinPrefsBox);
    await box.put(_kRequireModeKey, mode);
    if (mounted) setState(() => _requireMode = mode);
  }

  @override
  void dispose() {
    _shakeCtrl.dispose();
    super.dispose();
  }

  String get _prompt {
    switch (_mode) {
      case _LockMode.enter:
        return 'Enter your PIN';
      case _LockMode.setup:
        return _setupFirst.isEmpty ? 'Choose a 4-digit PIN' : 'Confirm your PIN';
      case _LockMode.change:
        return _setupFirst.isEmpty ? 'Enter your current PIN' : 'Choose a new PIN';
    }
  }

  void _onDigit(String d) {
    if (_digits.length >= 4) return;
    setState(() {
      _digits += d;
      _errorMsg = null;
    });
    if (_digits.length == 4) {
      Future.delayed(const Duration(milliseconds: 120), _evaluate);
    }
  }

  void _onDelete() {
    if (_digits.isEmpty) return;
    setState(() => _digits = _digits.substring(0, _digits.length - 1));
  }

  void _evaluate() {
    switch (_mode) {
      case _LockMode.enter:
        if (widget.child.checkPin(_digits)) {
          recordUnlock(widget.child.id);
          Navigator.of(context).pop(true);
        } else {
          _fail('Wrong PIN. Try again.');
        }

      case _LockMode.setup:
        if (_setupFirst.isEmpty) {
          setState(() {
            _setupFirst = _digits;
            _digits     = '';
          });
        } else if (_setupFirst == _digits) {
          widget.child.setPin(_digits);
          _persistAndPop('PIN set ✓');
        } else {
          _fail('PINs didn\'t match. Try again.');
          _setupFirst = '';
        }

      case _LockMode.change:
        if (_setupFirst.isEmpty) {
          // First step: verify current PIN
          if (widget.child.checkPin(_digits)) {
            setState(() {
              _setupFirst = 'verified';
              _digits     = '';
              _mode       = _LockMode.setup;
            });
          } else {
            _fail('Wrong PIN. Try again.');
          }
        }
    }
  }

  void _fail(String msg) {
    _shakeCtrl.forward(from: 0);
    setState(() {
      _errorMsg = msg;
      _digits   = '';
    });
  }

  Future<void> _persistAndPop(String msg) async {
    final account = FamilyAccount.current;
    if (account != null) await account.save();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: _purple.withValues(alpha: 0.9),
      behavior: SnackBarBehavior.floating,
    ));
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 48),
            _buildHeader(),
            const SizedBox(height: 40),
            _buildDots(),
            if (_errorMsg != null) ...[
              const SizedBox(height: 16),
              Text(
                _errorMsg!,
                style: const TextStyle(color: _pink, fontSize: 13),
              ),
            ],
            const Spacer(),
            _buildKeypad(),
            if (_prefsLoaded && _mode == _LockMode.setup) ...[
              const SizedBox(height: 16),
              _buildIdleModeToggle(),
              if (widget.child.ageMode == AgeMode.teen) ...[
                const SizedBox(height: 8),
                _buildTeenChildPinOption(),
              ],
            ],
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _purple.withValues(alpha: 0.15),
            border: Border.all(color: _purple.withValues(alpha: 0.35), width: 2),
          ),
          child: const Icon(Icons.lock_rounded, color: _purple, size: 32),
        ),
        const SizedBox(height: 20),
        Text(
          _prompt,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w700,
            fontFamily: 'DM Sans',
          ),
        ),
        const SizedBox(height: 4),
        Text(
          widget.child.name,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.45),
            fontSize: 14,
            fontFamily: 'DM Sans',
          ),
        ),
      ],
    );
  }

  Widget _buildDots() {
    return AnimatedBuilder(
      animation: _shakeAnim,
      builder: (_, __) {
        final shake = _shakeAnim.value * 6 * ((_digits.isEmpty ? 0 : 1));
        return Transform.translate(
          offset: Offset(shake * (_shakeAnim.value % 2 == 0 ? 1 : -1), 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(4, (i) {
              final filled = i < _digits.length;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                margin: const EdgeInsets.symmetric(horizontal: 10),
                width: filled ? 20 : 16,
                height: filled ? 20 : 16,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: filled ? _purple : Colors.transparent,
                  border: Border.all(
                    color: filled ? _purple : Colors.white38,
                    width: 2,
                  ),
                ),
              );
            }),
          ),
        );
      },
    );
  }

  Widget _buildIdleModeToggle() {
    final isIdle = _requireMode == 'idle_15';
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: GestureDetector(
        onTap: () => _saveRequireMode(isIdle ? 'always' : 'idle_15'),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
          ),
          child: Row(
            children: [
              Icon(
                isIdle ? Icons.timer_outlined : Icons.lock_rounded,
                color: _purple,
                size: 16,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  isIdle
                      ? 'Require PIN after 15 min idle'
                      : 'Require PIN every time',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.70),
                    fontSize: 12,
                    fontFamily: 'DM Sans',
                  ),
                ),
              ),
              Switch(
                value: isIdle,
                onChanged: (v) => _saveRequireMode(v ? 'idle_15' : 'always'),
                activeThumbColor: _purple,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTeenChildPinOption() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: _purple.withValues(alpha: 0.07),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _purple.withValues(alpha: 0.22)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.shield_outlined, color: _purple, size: 16),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                '${widget.child.name} can set their own PIN to protect their '
                'private journal and safe corner. Parent skeleton key always overrides.',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.65),
                  fontSize: 11,
                  fontFamily: 'DM Sans',
                  height: 1.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKeypad() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 48),
      child: Column(
        children: [
          for (final row in [
            ['1','2','3'],
            ['4','5','6'],
            ['7','8','9'],
            ['','0','⌫'],
          ])
            Row(
              children: row.map((k) => Expanded(
                child: k.isEmpty
                    ? const SizedBox()
                    : _KeypadButton(
                        label: k,
                        onTap: k == '⌫' ? _onDelete : () => _onDigit(k),
                      ),
              )).toList(),
            ),
        ],
      ),
    );
  }
}

class _KeypadButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _KeypadButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDelete = label == '⌫';
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.all(8),
        height: 64,
        decoration: BoxDecoration(
          color: isDelete
              ? Colors.transparent
              : Colors.white.withValues(alpha: 0.07),
          borderRadius: BorderRadius.circular(16),
          border: isDelete
              ? null
              : Border.all(color: Colors.white.withValues(alpha: 0.10)),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isDelete ? Colors.white54 : Colors.white,
              fontSize: isDelete ? 22 : 24,
              fontWeight: isDelete ? FontWeight.w400 : FontWeight.w600,
              fontFamily: 'DM Sans',
            ),
          ),
        ),
      ),
    );
  }
}
