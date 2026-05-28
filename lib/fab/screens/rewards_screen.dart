import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/profile_model.dart';
import '../services/fab_stars_service.dart';
import '../services/profile_service.dart';

// ─────────────────────────────────────────────────────────────
// REWARDS SCREEN (child view)
// Shows the 4 default rewards. Child can request a reward spend.
// Requests are persisted to SharedPrefs ('fab_reward_requests')
// and visible to parents via ParentDashboardScreen.
// ─────────────────────────────────────────────────────────────

const kRewardRequestsKey = 'fab_reward_requests';

class RewardsScreen extends StatefulWidget {
  const RewardsScreen({super.key});

  @override
  State<RewardsScreen> createState() => _RewardsScreenState();
}

class _RewardsScreenState extends State<RewardsScreen> {
  int _balance = 0;
  List<RedeemableReward> _rewards = [];
  List<_RewardRequest> _requests = [];
  bool _loading = false;

  static const _bg     = Color(0xFF0D0820);
  static const _panel  = Color(0xFF1A1040);
  static const _text   = Color(0xFFF2EFFF);
  static const _muted  = Color(0xFF8A8EAB);
  static const _purple = Color(0xFF6C63FF);
  static const _gold   = Color(0xFFFFD700);
  static const _teal   = Color(0xFF00C9A7);
  static const _pink   = Color(0xFFFF6B8A);
  static const _amber  = Color(0xFFFFB830);

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final balance  = await FabStarsService.getBalance();
    final profile  = ProfileService.profile;
    final rewards  = profile?.rewards ?? _defaultRewards();
    final requests = await _loadRequests();
    if (!mounted) return;
    setState(() {
      _balance  = balance;
      _rewards  = rewards;
      _requests = requests;
      _loading  = false;
    });
  }

  List<RedeemableReward> _defaultRewards() => [
    RedeemableReward(id: 'screen30', label: 'Extra screen time', description: '30 minutes', cost: 100),
    RedeemableReward(id: 'dinner',   label: 'Choose dinner',     description: "Pick tonight's meal", cost: 200),
    RedeemableReward(id: 'stayup',   label: 'Stay up 30 mins late', description: 'Friday only',    cost: 300),
    RedeemableReward(id: 'treat',    label: 'Pick a treat',      description: 'From the shops',    cost: 250),
  ];

  Future<List<_RewardRequest>> _loadRequests() async {
    final prefs = await SharedPreferences.getInstance();
    final raw   = prefs.getStringList(kRewardRequestsKey) ?? [];
    return raw.map((s) {
      try {
        return _RewardRequest.fromJson(jsonDecode(s) as Map<String, dynamic>);
      } catch (_) {
        return null;
      }
    }).whereType<_RewardRequest>().toList();
  }

  Future<void> _saveRequests() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      kRewardRequestsKey,
      _requests.map((r) => jsonEncode(r.toJson())).toList(),
    );
  }

  bool _hasPendingRequest(String rewardId) =>
      _requests.any((r) => r.rewardId == rewardId && r.status == 'pending');

  Future<void> _requestReward(RedeemableReward reward) async {
    if (_balance < reward.cost) {
      _snack('Not enough stars! You need ${reward.cost} ⭐', error: true);
      return;
    }
    if (_hasPendingRequest(reward.id)) {
      _snack("You've already requested this! Wait for parent approval. 🌟");
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: _panel,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text(
          'Request reward?',
          style: TextStyle(color: _text, fontSize: 16, fontWeight: FontWeight.w700),
        ),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          Text(
            '${reward.label} — ${reward.description}',
            style: const TextStyle(color: _text, fontSize: 14),
          ),
          const SizedBox(height: 8),
          Text(
            'This will use ${reward.cost} ⭐ when your parent approves.',
            style: const TextStyle(color: _muted, fontSize: 12),
          ),
        ]),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel', style: TextStyle(color: _muted)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              'Request!',
              style: TextStyle(color: _teal, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    final request = _RewardRequest(
      id:        '${reward.id}_${DateTime.now().millisecondsSinceEpoch}',
      rewardId:  reward.id,
      label:     reward.label,
      cost:      reward.cost,
      requestedAt: DateTime.now(),
      status:    'pending',
    );
    setState(() => _requests.add(request));
    await _saveRequests();
    _snack('🌟 Request sent! Your parent will approve or decline.');
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
        appBar: AppBar(backgroundColor: _bg, foregroundColor: _text, title: const Text('Rewards 🌟')),
        body: const Center(child: CircularProgressIndicator(color: _purple)),
      );
    }

    final pending = _requests.where((r) => r.status == 'pending').toList();

    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        foregroundColor: _text,
        elevation: 0,
        title: const Text(
          'Rewards 🌟',
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
                  color: _gold, fontSize: 14, fontWeight: FontWeight.w800, fontFamily: 'DM Sans',
                ),
              ),
            ]),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
        children: [
          // Hero banner
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [_amber.withValues(alpha: 0.25), _purple.withValues(alpha: 0.20)],
              ),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: _amber.withValues(alpha: 0.30)),
            ),
            child: const Row(children: [
              Text('🎁', style: TextStyle(fontSize: 36)),
              SizedBox(width: 14),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(
                    'Spend your stars!',
                    style: TextStyle(
                      color: _text, fontSize: 16, fontWeight: FontWeight.w800, fontFamily: 'DM Sans',
                    ),
                  ),
                  SizedBox(height: 3),
                  Text(
                    'Request a reward and your parent can approve it.',
                    style: TextStyle(color: _muted, fontSize: 12, height: 1.4),
                  ),
                ]),
              ),
            ]),
          ),
          const SizedBox(height: 20),

          // Rewards grid
          const Text(
            'Available Rewards',
            style: TextStyle(
              color: _text, fontSize: 15, fontWeight: FontWeight.w700, fontFamily: 'DM Sans',
            ),
          ),
          const SizedBox(height: 12),
          ..._rewards.map((r) => _buildRewardCard(r)),

          // Pending requests
          if (pending.isNotEmpty) ...[
            const SizedBox(height: 24),
            const Text(
              'Pending Requests',
              style: TextStyle(
                color: _text, fontSize: 15, fontWeight: FontWeight.w700, fontFamily: 'DM Sans',
              ),
            ),
            const SizedBox(height: 12),
            ...pending.map(_buildPendingCard),
          ],

              if (_requests.any((r) => r.status == 'approved')) ...[
            const SizedBox(height: 24),
            const Text(
              '✅ Approved Rewards',
              style: TextStyle(
                color: _teal, fontSize: 15, fontWeight: FontWeight.w700, fontFamily: 'DM Sans',
              ),
            ),
            const SizedBox(height: 12),
            ..._requests
                .where((r) => r.status == 'approved')
                .map((r) => _buildHistoryCard(r, approved: true)),
          ],
        ],
      ),
    );
  }

  Widget _buildRewardCard(RedeemableReward reward) {
    final canAfford = _balance >= reward.cost;
    final pending   = _hasPendingRequest(reward.id);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _panel,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: pending
              ? _amber.withValues(alpha: 0.50)
              : canAfford
                  ? _purple.withValues(alpha: 0.35)
                  : Colors.white10,
        ),
      ),
      child: Row(children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: _amber.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: _amber.withValues(alpha: 0.30)),
          ),
          child: const Center(child: Text('🎁', style: TextStyle(fontSize: 24))),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(
              reward.label,
              style: const TextStyle(
                color: _text, fontSize: 14, fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              reward.description,
              style: const TextStyle(color: _muted, fontSize: 12),
            ),
            const SizedBox(height: 6),
            Row(children: [
              const Text('⭐', style: TextStyle(fontSize: 11)),
              const SizedBox(width: 3),
              Text(
                '${reward.cost} stars',
                style: TextStyle(
                  color: canAfford ? _gold : _muted,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ]),
          ]),
        ),
        const SizedBox(width: 10),
        // Action button
        if (pending)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              color: _amber.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _amber.withValues(alpha: 0.40)),
            ),
            child: const Text('⏳',
                style: TextStyle(fontSize: 16)),
          )
        else
          GestureDetector(
            onTap: canAfford ? () => _requestReward(reward) : null,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                gradient: canAfford
                    ? const LinearGradient(
                        colors: [Color(0xFF6C63FF), Color(0xFF00C9A7)],
                      )
                    : null,
                color: canAfford ? null : Colors.white.withValues(alpha: 0.07),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                canAfford ? 'Request' : '${reward.cost - _balance} more',
                style: TextStyle(
                  color: canAfford ? Colors.white : _muted,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
      ]),
    );
  }

  Widget _buildPendingCard(_RewardRequest r) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _panel,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _amber.withValues(alpha: 0.35)),
      ),
      child: Row(children: [
        const Text('⏳', style: TextStyle(fontSize: 22)),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(r.label,
                style: const TextStyle(color: _text, fontSize: 13, fontWeight: FontWeight.w600)),
            Text('Waiting for parent approval',
                style: const TextStyle(color: _muted, fontSize: 11)),
          ]),
        ),
        Text('${r.cost} ⭐',
            style: const TextStyle(color: _amber, fontSize: 12, fontWeight: FontWeight.w700)),
      ]),
    );
  }

  Widget _buildHistoryCard(_RewardRequest r, {required bool approved}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _panel,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: approved ? _teal.withValues(alpha: 0.30) : _pink.withValues(alpha: 0.30),
        ),
      ),
      child: Row(children: [
        Text(approved ? '✅' : '❌', style: const TextStyle(fontSize: 22)),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(r.label,
                style: const TextStyle(color: _text, fontSize: 13, fontWeight: FontWeight.w600)),
            Text(approved ? 'Approved!' : 'Declined',
                style: TextStyle(
                  color: approved ? _teal : _pink,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                )),
          ]),
        ),
        Text('${r.cost} ⭐',
            style: TextStyle(
              color: approved ? _teal : _muted,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            )),
      ]),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Data model for a reward request
// ─────────────────────────────────────────────────────────────

class RewardRequest {
  final String id;
  final String rewardId;
  final String label;
  final int cost;
  final DateTime requestedAt;
  String status; // 'pending' | 'approved' | 'declined'

  RewardRequest({
    required this.id,
    required this.rewardId,
    required this.label,
    required this.cost,
    required this.requestedAt,
    required this.status,
  });

  Map<String, dynamic> toJson() => {
    'id':          id,
    'rewardId':    rewardId,
    'label':       label,
    'cost':        cost,
    'requestedAt': requestedAt.toIso8601String(),
    'status':      status,
  };

  factory RewardRequest.fromJson(Map<String, dynamic> j) => RewardRequest(
    id:          j['id'] as String,
    rewardId:    j['rewardId'] as String,
    label:       j['label'] as String,
    cost:        (j['cost'] as num).toInt(),
    requestedAt: DateTime.parse(j['requestedAt'] as String),
    status:      j['status'] as String? ?? 'pending',
  );
}

// Private alias used internally
typedef _RewardRequest = RewardRequest;
