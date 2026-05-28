import 'package:flutter/material.dart';

// ─────────────────────────────────────────────────────────────
// SharedGardenScreen
//
// The neutral ground between the two family houses —
// a shared space for collaborative activities.
// ─────────────────────────────────────────────────────────────

class SharedGardenScreen extends StatelessWidget {
  const SharedGardenScreen({super.key});

  static const _bg     = Color(0xFF0A1A0F);
  static const _card   = Color(0xFF122010);
  static const _teal   = Color(0xFF4ECDC4);
  static const _gold   = Color(0xFFFFD700);
  static const _text   = Color(0xFFF0D6FF);
  static const _muted  = Color(0xFF7AA880);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Column(
          children: [
            // Back button row
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
                      child: const Icon(Icons.arrow_back_ios_new_rounded,
                          color: _text, size: 18),
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
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Hero garden scene
                    Container(
                      height: 200,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24),
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xFF0E2E16), Color(0xFF0A1A0F)],
                        ),
                        border: Border.all(
                            color: _teal.withValues(alpha: 0.30), width: 1.5),
                        boxShadow: [
                          BoxShadow(
                            color: _teal.withValues(alpha: 0.15),
                            blurRadius: 24,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('🌸🌿🌻', style: TextStyle(fontSize: 48)),
                            SizedBox(height: 12),
                            Text(
                              'Where both families meet',
                              style: TextStyle(
                                color: _teal,
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                fontFamily: 'DM Sans',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Coming soon activities
                    _activityCard('🎨', 'Create Together',
                        'Draw and colour as a family'),
                    const SizedBox(height: 12),
                    _activityCard('📖', 'Story Garden',
                        'Build stories one sentence at a time'),
                    const SizedBox(height: 12),
                    _activityCard('🎵', 'Music Corner',
                        'Share songs and sounds you love'),
                    const SizedBox(height: 12),
                    _activityCard('🌱', 'Grow Together',
                        'Plant kindness, watch it bloom'),

                    const SizedBox(height: 32),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: _gold.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: _gold.withValues(alpha: 0.20)),
                      ),
                      child: const Row(
                        children: [
                          Text('✨', style: TextStyle(fontSize: 18)),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'More shared activities coming soon',
                              style: TextStyle(
                                color: _gold,
                                fontSize: 13,
                                fontFamily: 'DM Sans',
                              ),
                            ),
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

  Widget _activityCard(String emoji, String title, String subtitle) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _teal.withValues(alpha: 0.18)),
      ),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 32)),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        color: _text,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'DM Sans')),
                const SizedBox(height: 2),
                Text(subtitle,
                    style: const TextStyle(
                        color: _muted,
                        fontSize: 12,
                        fontFamily: 'DM Sans')),
              ],
            ),
          ),
          Icon(Icons.lock_rounded, color: _muted.withValues(alpha: 0.50), size: 18),
        ],
      ),
    );
  }
}
