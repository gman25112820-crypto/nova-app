import 'package:flutter/material.dart';

import '../models/tour_chapter.dart';
import 'fab_home_screen.dart';

class ToursHelpScreen extends StatelessWidget {
  const ToursHelpScreen({super.key});

  static const _bg = Color(0xFF0D0820);
  static const _panel = Color(0xFF1A1040);
  static const _panelAlt = Color(0xFF21104A);
  static const _text = Color(0xFFF2EFFF);
  static const _muted = Color(0xFFB9AED6);
  static const _soft = Color(0xFF8A8EAB);
  static const _purple = Color(0xFF6C63FF);
  static const _pink = Color(0xFFFF6B8A);
  static const _teal = Color(0xFF00C9A7);
  static const _amber = Color(0xFFFFB830);

  static const _gardenReplayAction = 'garden_replay';

  static const List<TourChapter> _worldChapters = [
    TourChapter(
      id: 'welcome_world',
      title: 'Welcome to My World',
      description: 'Meet Eddie and see what kind of help is waiting here.',
      icon: Icons.waving_hand_rounded,
      collection: TourCollection.showMeMyWorld,
      readiness: TourReadiness.comingSoon,
    ),
    TourChapter(
      id: 'garden',
      title: 'Garden',
      description: 'Replay Eddie showing you the garden places.',
      icon: Icons.local_florist_rounded,
      collection: TourCollection.showMeMyWorld,
      readiness: TourReadiness.ready,
      actionId: _gardenReplayAction,
    ),
    TourChapter(
      id: 'my_house',
      title: 'My House',
      description: 'Find out how the house rooms fit together.',
      icon: Icons.home_rounded,
      collection: TourCollection.showMeMyWorld,
      readiness: TourReadiness.comingSoon,
    ),
    TourChapter(
      id: 'my_rooms',
      title: 'My Rooms',
      description: 'Eddie is checking which rooms are ready to show.',
      icon: Icons.meeting_room_rounded,
      collection: TourCollection.showMeMyWorld,
      readiness: TourReadiness.comingSoon,
    ),
    TourChapter(
      id: 'burrow',
      title: 'The Burrow',
      description: 'This quiet doorway will get its own gentle hello later.',
      icon: Icons.nights_stay_rounded,
      collection: TourCollection.showMeMyWorld,
      readiness: TourReadiness.comingSoon,
    ),
    TourChapter(
      id: 'stars_rewards',
      title: 'Stars and Rewards',
      description: 'See where stars and reward wishes live.',
      icon: Icons.star_rounded,
      collection: TourCollection.showMeMyWorld,
      readiness: TourReadiness.comingSoon,
    ),
    TourChapter(
      id: 'settings_privacy',
      title: 'Settings and Privacy',
      description: 'Learn where replay help and privacy notes live.',
      icon: Icons.tune_rounded,
      collection: TourCollection.showMeMyWorld,
      readiness: TourReadiness.comingSoon,
    ),
    TourChapter(
      id: 'grownups_bit',
      title: "The Grown-ups' Bit",
      description: 'Some tools are just for grown-ups and stay in their area.',
      icon: Icons.family_restroom_rounded,
      collection: TourCollection.showMeMyWorld,
      readiness: TourReadiness.needsGrownUpHelp,
    ),
  ];

  static const List<TourChapter> _howChapters = [
    TourChapter(
      id: 'how_i_feel',
      title: 'How I Feel',
      description: 'Practice finding a feeling without saving anything yet.',
      icon: Icons.emoji_emotions_rounded,
      collection: TourCollection.showMeHow,
      readiness: TourReadiness.needsGrownUpHelp,
    ),
    TourChapter(
      id: 'my_energy',
      title: 'My Energy',
      description: 'Eddie will help this become a just-for-practice try.',
      icon: Icons.battery_charging_full_rounded,
      collection: TourCollection.showMeHow,
      readiness: TourReadiness.needsGrownUpHelp,
    ),
    TourChapter(
      id: 'sleep_rest',
      title: 'Sleep and Rest',
      description: 'A practice version needs to be made before this opens.',
      icon: Icons.bedtime_rounded,
      collection: TourCollection.showMeHow,
      readiness: TourReadiness.needsGrownUpHelp,
    ),
    TourChapter(
      id: 'my_body',
      title: 'My Body',
      description: 'Eddie will keep this gentle and just-for-practice first.',
      icon: Icons.accessibility_new_rounded,
      collection: TourCollection.showMeHow,
      readiness: TourReadiness.needsGrownUpHelp,
    ),
    TourChapter(
      id: 'worries_notes',
      title: 'Worries and Notes',
      description: 'This needs a private practice space before it opens.',
      icon: Icons.edit_note_rounded,
      collection: TourCollection.showMeHow,
      readiness: TourReadiness.needsGrownUpHelp,
    ),
    TourChapter(
      id: 'food_drink',
      title: 'Food and Drink',
      description: 'Eddie is waiting until this is ready to show safely.',
      icon: Icons.restaurant_rounded,
      collection: TourCollection.showMeHow,
      readiness: TourReadiness.needsGrownUpHelp,
    ),
    TourChapter(
      id: 'activities',
      title: 'Activities',
      description: 'Play rooms are ready, but Eddie still needs a tour path.',
      icon: Icons.extension_rounded,
      collection: TourCollection.showMeHow,
      readiness: TourReadiness.comingSoon,
    ),
    TourChapter(
      id: 'looking_back',
      title: 'Looking Back at My Entries',
      description: 'Eddie will show this after the practice bits are ready.',
      icon: Icons.auto_stories_rounded,
      collection: TourCollection.showMeHow,
      readiness: TourReadiness.comingSoon,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        foregroundColor: _text,
        elevation: 0,
        title: const Text(
          'Tours & Help',
          style: TextStyle(fontWeight: FontWeight.w800, fontFamily: 'DM Sans'),
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final wide = constraints.maxWidth >= 820;
          final contentWidth = wide ? 1040.0 : constraints.maxWidth;
          return ListView(
            padding: EdgeInsets.fromLTRB(
              wide ? 28 : 16,
              12,
              wide ? 28 : 16,
              40,
            ),
            children: [
              Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: contentWidth),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const _EddieIntro(),
                      const SizedBox(height: 20),
                      _TourSection(
                        title: 'Show Me My World',
                        subtitle:
                            'Garden places, rooms, stars and grown-up areas.',
                        accent: _teal,
                        chapters: _worldChapters,
                        onAction: (chapter) => _handleAction(context, chapter),
                      ),
                      const SizedBox(height: 20),
                      _TourSection(
                        title: 'Show Me How',
                        subtitle:
                            'Practice tours will help you try things safely.',
                        accent: _amber,
                        chapters: _howChapters,
                        onAction: (chapter) => _handleAction(context, chapter),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _handleAction(BuildContext context, TourChapter chapter) {
    if (chapter.actionId != _gardenReplayAction) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (_) => const FabHomeScreen(replayTourOnLoad: true),
      ),
      (route) => false,
    );
  }
}

class _EddieIntro extends StatelessWidget {
  const _EddieIntro();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [ToursHelpScreen._panelAlt, ToursHelpScreen._panel],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: ToursHelpScreen._purple.withValues(alpha: 0.30),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.08),
              border: Border.all(
                color: ToursHelpScreen._pink.withValues(alpha: 0.35),
              ),
            ),
            clipBehavior: Clip.antiAlias,
            child: Image.asset(
              'assets/images/characters/jack_russell.png',
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Eddie can help',
                  style: TextStyle(
                    color: ToursHelpScreen._text,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    fontFamily: 'DM Sans',
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  "Pick anything you'd like to explore. You can stop whenever you want.",
                  style: TextStyle(
                    color: ToursHelpScreen._muted,
                    fontSize: 13,
                    height: 1.45,
                    fontFamily: 'DM Sans',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TourSection extends StatelessWidget {
  final String title;
  final String subtitle;
  final Color accent;
  final List<TourChapter> chapters;
  final ValueChanged<TourChapter> onAction;

  const _TourSection({
    required this.title,
    required this.subtitle,
    required this.accent,
    required this.chapters,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ToursHelpScreen._panel,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: accent.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.auto_awesome_rounded, color: accent, size: 18),
              const SizedBox(width: 9),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: accent,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    fontFamily: 'DM Sans',
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(
              color: ToursHelpScreen._soft,
              fontSize: 12,
              height: 1.4,
              fontFamily: 'DM Sans',
            ),
          ),
          const SizedBox(height: 14),
          LayoutBuilder(
            builder: (context, constraints) {
              final columns = constraints.maxWidth >= 760 ? 2 : 1;
              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: chapters.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: columns,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  mainAxisExtent: 142,
                ),
                itemBuilder: (_, index) {
                  final chapter = chapters[index];
                  return _ChapterCard(
                    chapter: chapter,
                    accent: accent,
                    onAction: chapter.actionId == null
                        ? null
                        : () => onAction(chapter),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}

class _ChapterCard extends StatelessWidget {
  final TourChapter chapter;
  final Color accent;
  final VoidCallback? onAction;

  const _ChapterCard({
    required this.chapter,
    required this.accent,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final readiness = _readinessView(chapter.readiness);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.045),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.16),
                  shape: BoxShape.circle,
                ),
                child: Icon(chapter.icon, color: accent, size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      chapter.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: ToursHelpScreen._text,
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        fontFamily: 'DM Sans',
                      ),
                    ),
                    const SizedBox(height: 6),
                    _StatusPill(label: readiness.label, color: readiness.color),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Expanded(
            child: Text(
              chapter.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: ToursHelpScreen._muted,
                fontSize: 12,
                height: 1.35,
                fontFamily: 'DM Sans',
              ),
            ),
          ),
          if (onAction != null) ...[
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: Semantics(
                button: true,
                label: 'Replay garden tour',
                child: InkWell(
                  onTap: onAction,
                  borderRadius: BorderRadius.circular(999),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: ToursHelpScreen._pink.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(
                        color: ToursHelpScreen._pink.withValues(alpha: 0.42),
                      ),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.replay_rounded,
                          color: ToursHelpScreen._pink,
                          size: 15,
                        ),
                        SizedBox(width: 6),
                        Text(
                          'Replay garden tour',
                          style: TextStyle(
                            color: ToursHelpScreen._pink,
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            fontFamily: 'DM Sans',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  _ReadinessView _readinessView(TourReadiness readiness) {
    if (chapter.actionId != null) {
      return const _ReadinessView('Ready now', ToursHelpScreen._teal);
    }
    switch (readiness) {
      case TourReadiness.ready:
        return const _ReadinessView('Coming soon', ToursHelpScreen._amber);
      case TourReadiness.comingSoon:
        return const _ReadinessView('Coming soon', ToursHelpScreen._amber);
      case TourReadiness.needsGrownUpHelp:
        return const _ReadinessView('Being made gently', ToursHelpScreen._pink);
    }
  }
}

class _StatusPill extends StatelessWidget {
  final String label;
  final Color color;

  const _StatusPill({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.32)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w800,
          fontFamily: 'DM Sans',
        ),
      ),
    );
  }
}

class _ReadinessView {
  final String label;
  final Color color;

  const _ReadinessView(this.label, this.color);
}
