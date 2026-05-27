import 'package:flutter/material.dart';
import '../models/duck_model.dart';
import '../models/profile_model.dart';
import '../services/fab_stars_service.dart';
import '../services/profile_service.dart';

// ─────────────────────────────────────────────────────────────
// DUCK SHOP SCREEN
// Purchase ducks with Fab Stars. Shows all 17 ducks in a grid.
// Owned ducks are highlighted; mystery ducks are hidden until bought.
// ─────────────────────────────────────────────────────────────

class DuckShopScreen extends StatefulWidget {
  const DuckShopScreen({super.key});

  @override
  State<DuckShopScreen> createState() => _DuckShopScreenState();
}

class _DuckShopScreenState extends State<DuckShopScreen> {
  int _balance     = 0;
  List<String> _ownedIds = [];
  bool _loading    = true;
  bool _purchasing = false;

  static const _bg     = Color(0xFF0D0820);
  static const _panel  = Color(0xFF1A1040);
  static const _text   = Color(0xFFF2EFFF);
  static const _muted  = Color(0xFF8A8EAB);
  static const _purple = Color(0xFF6C63FF);
  static const _gold   = Color(0xFFFFD700);
  static const _teal   = Color(0xFF00C9A7);
  static const _pink   = Color(0xFFFF6B8A);

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final balance = await FabStarsService.getBalance();
    final owned   = ProfileService.profile?.ownedDuckIds ?? ['classic', 'blush'];
    if (mounted) {
      setState(() {
        _balance   = balance;
        _ownedIds  = List<String>.from(owned);
        _loading   = false;
      });
    }
  }

  bool _isOwned(DuckModel d) => _ownedIds.contains(d.id);

  Future<void> _purchase(DuckModel duck) async {
    if (_purchasing) return;
    if (_isOwned(duck)) return;

    // Confirm dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: _panel,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Row(children: [
          const Text('🦆', style: TextStyle(fontSize: 24)),
          const SizedBox(width: 10),
          Text(
            duck.unlockType == DuckUnlockType.mystery ? 'Reveal duck?' : 'Buy ${duck.name}?',
            style: const TextStyle(color: _text, fontSize: 16, fontWeight: FontWeight.w700),
          ),
        ]),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          Text(
            duck.unlockType == DuckUnlockType.mystery
                ? 'Spend ${duck.starCost} ⭐ to reveal this mystery duck?'
                : 'Spend ${duck.starCost} ⭐ to unlock ${duck.name}?',
            style: const TextStyle(color: _muted, fontSize: 14),
          ),
          const SizedBox(height: 8),
          Text(
            'Balance after: ${_balance - duck.starCost} ⭐',
            style: TextStyle(
              color: _balance >= duck.starCost ? _teal : _pink,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ]),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel', style: TextStyle(color: _muted)),
          ),
          TextButton(
            onPressed: _balance >= duck.starCost
                ? () => Navigator.pop(ctx, true)
                : null,
            child: Text(
              _balance >= duck.starCost ? 'Buy!' : 'Not enough ⭐',
              style: TextStyle(
                color: _balance >= duck.starCost ? _teal : _muted,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    setState(() => _purchasing = true);
    final spent = await FabStarsService.spendStars(duck.starCost);
    if (!spent) {
      _snack('Not enough stars! 😢', error: true);
      setState(() => _purchasing = false);
      return;
    }

    // Update profile
    final profile = ProfileService.profile;
    if (profile != null && !profile.ownedDuckIds.contains(duck.id)) {
      profile.ownedDuckIds.add(duck.id);
      await ProfileService.save(profile);
    }

    final newBalance = await FabStarsService.getBalance();
    setState(() {
      _ownedIds.add(duck.id);
      _balance     = newBalance;
      _purchasing  = false;
    });
    _snack('🦆 ${duck.unlockType == DuckUnlockType.mystery ? 'Mystery duck revealed!' : '${duck.name} unlocked!'} ⭐');
  }

  void _snack(String msg, {bool error = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: error
          ? _pink.withValues(alpha: 0.9)
          : _teal.withValues(alpha: 0.9),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ));
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        backgroundColor: _bg,
        appBar: AppBar(
          backgroundColor: _bg,
          foregroundColor: _text,
          title: const Text('Duck Shop 🦆'),
        ),
        body: const Center(child: CircularProgressIndicator(color: _purple)),
      );
    }

    final ducks = DuckCollection.all;

    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        foregroundColor: _text,
        elevation: 0,
        title: const Text(
          'Duck Shop 🦆',
          style: TextStyle(fontWeight: FontWeight.w700, fontFamily: 'DM Sans'),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _gold.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: _gold.withValues(alpha: 0.40)),
            ),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              const Text('⭐', style: TextStyle(fontSize: 14)),
              const SizedBox(width: 5),
              Text(
                '$_balance',
                style: const TextStyle(
                  color: _gold,
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  fontFamily: 'DM Sans',
                ),
              ),
            ]),
          ),
        ],
      ),
      body: Column(
        children: [
          // Header banner
          Container(
            margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  _purple.withValues(alpha: 0.30),
                  _teal.withValues(alpha: 0.20),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: _purple.withValues(alpha: 0.30)),
            ),
            child: const Row(children: [
              Text('🦆', style: TextStyle(fontSize: 28)),
              SizedBox(width: 12),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(
                    'Your Duck Collection',
                    style: TextStyle(
                      color: _text,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'DM Sans',
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Earn stars by checking in every day. Spend them on ducks!',
                    style: TextStyle(color: _muted, fontSize: 12, height: 1.35),
                  ),
                ]),
              ),
            ]),
          ),
          const SizedBox(height: 8),
          // Stats row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(children: [
              _statChip(
                '${_ownedIds.length}/${ducks.length}',
                'owned',
                _teal,
              ),
              const SizedBox(width: 8),
              _statChip(
                '${ducks.where((d) => !_isOwned(d) && d.starCost <= _balance && d.starCost > 0).length}',
                'affordable',
                _purple,
              ),
            ]),
          ),
          const SizedBox(height: 12),
          // Grid
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.78,
              ),
              itemCount: ducks.length,
              itemBuilder: (ctx, i) => _DuckCard(
                duck: ducks[i],
                owned: _isOwned(ducks[i]),
                balance: _balance,
                purchasing: _purchasing,
                onPurchase: () => _purchase(ducks[i]),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statChip(String value, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.30)),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Text(
          value,
          style: TextStyle(color: color, fontSize: 13, fontWeight: FontWeight.w800),
        ),
        const SizedBox(width: 5),
        Text(
          label,
          style: const TextStyle(color: _muted, fontSize: 11),
        ),
      ]),
    );
  }
}

// ─────────────────────────────────────────────────────────────

class _DuckCard extends StatelessWidget {
  final DuckModel duck;
  final bool owned;
  final int balance;
  final bool purchasing;
  final VoidCallback onPurchase;

  const _DuckCard({
    required this.duck,
    required this.owned,
    required this.balance,
    required this.purchasing,
    required this.onPurchase,
  });

  static const _panel  = Color(0xFF1A1040);
  static const _text   = Color(0xFFF2EFFF);
  static const _muted  = Color(0xFF8A8EAB);
  static const _gold   = Color(0xFFFFD700);
  static const _teal   = Color(0xFF00C9A7);
  static const _pink   = Color(0xFFFF6B8A);
  static const _purple = Color(0xFF6C63FF);

  Color get _rarityColor {
    switch (duck.rarity) {
      case DuckRarity.common:    return _teal;
      case DuckRarity.rare:      return _purple;
      case DuckRarity.legendary: return _gold;
    }
  }

  String get _rarityLabel {
    switch (duck.rarity) {
      case DuckRarity.common:    return 'Common';
      case DuckRarity.rare:      return 'Rare';
      case DuckRarity.legendary: return 'Legendary';
    }
  }

  bool get _isMystery => duck.unlockType == DuckUnlockType.mystery && !owned;
  bool get _canAfford  => balance >= duck.starCost;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: (!owned && duck.starCost > 0 && !purchasing) ? onPurchase : null,
      child: Container(
        decoration: BoxDecoration(
          color: _panel,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: owned
                ? duck.accentColor.withValues(alpha: 0.55)
                : _rarityColor.withValues(alpha: 0.30),
            width: owned ? 1.5 : 1.0,
          ),
          boxShadow: owned
              ? [BoxShadow(color: duck.accentColor.withValues(alpha: 0.18), blurRadius: 10)]
              : null,
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Duck avatar
              _buildAvatar(),
              const SizedBox(height: 6),
              // Name
              Text(
                _isMystery ? '???' : duck.name,
                style: TextStyle(
                  color: _isMystery ? _muted : _text,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'DM Sans',
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 2),
              // Rarity badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: _rarityColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: _rarityColor.withValues(alpha: 0.35)),
                ),
                child: Text(
                  _rarityLabel,
                  style: TextStyle(
                    color: _rarityColor,
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              // Cost / owned / action button
              _buildActionArea(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: _isMystery
            ? const Color(0xFF2D1B69)
            : duck.bodyColor.withValues(alpha: 0.30),
        border: Border.all(
          color: _isMystery
              ? Colors.white12
              : duck.accentColor.withValues(alpha: 0.55),
          width: 2,
        ),
      ),
      child: Center(
        child: _isMystery
            ? const Text('❓', style: TextStyle(fontSize: 28))
            : Stack(
                alignment: Alignment.center,
                children: [
                  // Body blob
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: duck.bodyColor,
                    ),
                  ),
                  // Accent — beak/eye area
                  Positioned(
                    right: 6,
                    top: 8,
                    child: Container(
                      width: 12,
                      height: 8,
                      decoration: BoxDecoration(
                        color: duck.accentColor,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                  // Eye
                  const Positioned(
                    right: 10,
                    top: 6,
                    child: CircleAvatar(
                      radius: 3,
                      backgroundColor: Colors.black87,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildActionArea() {
    if (owned) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        decoration: BoxDecoration(
          color: _teal.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _teal.withValues(alpha: 0.40)),
        ),
        child: const Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.check_circle_rounded, color: _teal, size: 13),
          SizedBox(width: 5),
          Text('Owned',
              style: TextStyle(
                  color: _teal, fontSize: 11, fontWeight: FontWeight.w700)),
        ]),
      );
    }

    if (duck.starCost == 0) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        decoration: BoxDecoration(
          color: _gold.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Text('Starter',
            style: TextStyle(color: _gold, fontSize: 11, fontWeight: FontWeight.w600)),
      );
    }

    // Purchasable
    final affordable = _canAfford;
    return GestureDetector(
      onTap: onPurchase,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        decoration: BoxDecoration(
          color: affordable
              ? _purple.withValues(alpha: 0.20)
              : Colors.white.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: affordable
                ? _purple.withValues(alpha: 0.50)
                : Colors.white12,
          ),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          const Text('⭐', style: TextStyle(fontSize: 10)),
          const SizedBox(width: 4),
          Text(
            '${duck.starCost}',
            style: TextStyle(
              color: affordable ? _gold : _muted,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ]),
      ),
    );
  }
}
