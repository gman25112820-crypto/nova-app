import 'package:flutter/material.dart';

import '../models/tour_chapter.dart';
import '../models/tour_page.dart';
import '../widgets/fab_design_system.dart';
import 'fab_home_screen.dart';
import 'tour_chapter_runner_screen.dart';

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

  static const _welcomeWorldAction = 'welcome_world_runner';
  static const _gardenReplayAction = 'garden_replay';
  static const _myHouseAction = 'my_house_runner';
  static const _myRoomsAction = 'my_rooms_runner';
  static const _starsRewardsAction = 'stars_rewards_runner';
  static const _settingsPrivacyAction = 'settings_privacy_runner';

  static const List<TourChapter> _worldChapters = [
    TourChapter(
      id: 'welcome_world',
      title: 'Welcome to My World',
      description: 'Meet Eddie and see what kind of help is waiting here.',
      icon: Icons.waving_hand_rounded,
      collection: TourCollection.showMeMyWorld,
      readiness: TourReadiness.ready,
      actionId: _welcomeWorldAction,
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
      readiness: TourReadiness.ready,
      actionId: _myHouseAction,
    ),
    TourChapter(
      id: 'my_rooms',
      title: 'My Rooms',
      description: 'See what different rooms can be for.',
      icon: Icons.meeting_room_rounded,
      collection: TourCollection.showMeMyWorld,
      readiness: TourReadiness.ready,
      actionId: _myRoomsAction,
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
      readiness: TourReadiness.ready,
      actionId: _starsRewardsAction,
    ),
    TourChapter(
      id: 'settings_privacy',
      title: 'Settings and Privacy',
      description: 'Learn where replay help and privacy notes live.',
      icon: Icons.tune_rounded,
      collection: TourCollection.showMeMyWorld,
      readiness: TourReadiness.ready,
      actionId: _settingsPrivacyAction,
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

  static const List<TourPage> _welcomeWorldPages = [
    TourPage(
      id: 'welcome_world_1',
      title: 'Welcome to your world',
      body: 'This is a place to explore, play and find things that might help.',
      icon: Icons.auto_awesome_rounded,
      eddiePrompt:
          'We can look around together — or you can explore on your own.',
    ),
    TourPage(
      id: 'welcome_world_2',
      title: 'Choose what feels right',
      body:
          'You can visit any place you like. There is no wrong way to explore.',
      icon: Icons.explore_rounded,
      eddiePrompt: 'You never have to finish a tour.',
    ),
    TourPage(
      id: 'welcome_world_3',
      title: 'Help is always nearby',
      body: 'Tours & Help will show you around whenever you want.',
      icon: Icons.volunteer_activism_rounded,
      eddiePrompt: 'Come back any time and pick just one little thing.',
    ),
    TourPage(
      id: 'welcome_world_4',
      title: 'Ready when you are',
      body: 'You can visit the garden, look around the house, or stop here.',
      icon: Icons.favorite_rounded,
      eddiePrompt: 'What happens next is up to you.',
    ),
  ];

  static const List<TourPage> _myHousePages = [
    TourPage(
      id: 'my_house_1',
      title: 'Welcome to My House',
      body:
          'This is where you can find different rooms made for different kinds of moments.',
      icon: Icons.home_rounded,
      eddiePrompt: 'We can have a quick look without opening anything.',
    ),
    TourPage(
      id: 'my_house_2',
      title: 'Pick a room',
      body:
          'Each picture leads somewhere different. Some rooms are ready, and some are still being made.',
      icon: Icons.meeting_room_rounded,
      eddiePrompt: 'You can choose what feels useful today.',
    ),
    TourPage(
      id: 'my_house_3',
      title: 'Nothing is compulsory',
      body: 'You do not have to visit every room or finish anything.',
      icon: Icons.favorite_border_rounded,
      eddiePrompt:
          'Looking around, stopping or coming back later are all okay.',
    ),
    TourPage(
      id: 'my_house_4',
      title: "Explore when you're ready",
      body:
          'When this little tour ends, you can return to My House whenever you want.',
      icon: Icons.explore_rounded,
      eddiePrompt: "You're in charge of where you go next.",
    ),
  ];

  static const List<TourPage> _myRoomsPages = [
    TourPage(
      id: 'my_rooms_1',
      title: 'Your rooms',
      body:
          'Your house has different rooms for different things.\n\n'
          'You can choose whichever room feels right for you.',
      icon: Icons.meeting_room_rounded,
      eddiePrompt: 'Every room is different.',
    ),
    TourPage(
      id: 'my_rooms_2',
      title: 'Things to explore',
      body:
          'Some rooms help you rest.\n\n'
          'Some have games.\n\n'
          'Some have music.\n\n'
          'Some help you be creative.',
      icon: Icons.auto_awesome_rounded,
      eddiePrompt: 'You only need to choose one little thing.',
    ),
    TourPage(
      id: 'my_rooms_3',
      title: 'Choose your own way',
      body:
          "There isn't a right or wrong order.\n\n"
          'You can visit one room or lots of rooms.\n\n'
          'You can leave whenever you want.',
      icon: Icons.explore_rounded,
      eddiePrompt: 'You are always in charge.',
    ),
    TourPage(
      id: 'my_rooms_4',
      title: 'Come back anytime',
      body: 'Your house will still be here whenever you want to explore again.',
      icon: Icons.home_rounded,
      eddiePrompt: 'See you next time.',
    ),
  ];

  static const List<TourPage> _starsRewardsPages = [
    TourPage(
      id: 'stars_rewards_1',
      title: 'Your stars',
      body: 'Stars are a little way to celebrate things you do in your world.',
      icon: Icons.star_rounded,
      eddiePrompt:
          'They are here for fun - not to judge how well you are doing.',
    ),
    TourPage(
      id: 'stars_rewards_2',
      title: 'How stars work',
      body:
          'The app shows your star total. Stars can be added after some check-ins, games and garden discoveries.',
      icon: Icons.auto_awesome_rounded,
      eddiePrompt: 'You never need to rush or collect every star.',
    ),
    TourPage(
      id: 'stars_rewards_3',
      title: 'Rewards',
      body:
          'You can look at ducks and rewards. Some ducks use stars, and reward requests wait for a parent to approve.',
      icon: Icons.card_giftcard_rounded,
      eddiePrompt: 'You can look around and choose what feels fun.',
    ),
    TourPage(
      id: 'stars_rewards_4',
      title: 'Go at your own pace',
      body: 'Your stars will still be here when you come back.',
      icon: Icons.self_improvement_rounded,
      eddiePrompt: 'Stopping, exploring or doing something else are all okay.',
    ),
  ];

  static const List<TourPage> _settingsPrivacyPages = [
    TourPage(
      id: 'settings_privacy_1',
      title: 'Your settings',
      body: 'Settings can help make your world feel more comfortable for you.',
      icon: Icons.tune_rounded,
      eddiePrompt: 'You can look around without changing anything.',
    ),
    TourPage(
      id: 'settings_privacy_2',
      title: 'Make it feel right',
      body:
          'You can choose your name and avatar, change reminders, revisit your profile, and replay help.',
      icon: Icons.palette_rounded,
      eddiePrompt: 'Small changes can help your world feel more like yours.',
    ),
    TourPage(
      id: 'settings_privacy_3',
      title: 'Your information',
      body:
          'Some things you add to your world are personal, so they should only be viewed carefully.',
      icon: Icons.favorite_rounded,
      eddiePrompt:
          'You can ask a trusted grown-up if you are unsure about anything.',
    ),
    TourPage(
      id: 'settings_privacy_4',
      title: "The grown-ups' area",
      body:
          "Some settings and information are kept in a separate grown-ups' area.",
      icon: Icons.family_restroom_rounded,
      eddiePrompt: 'That area needs a grown-up to open it.',
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
    switch (chapter.actionId) {
      case _welcomeWorldAction:
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => const TourChapterRunnerScreen(
              title: 'Welcome to My World',
              pages: _welcomeWorldPages,
            ),
          ),
        );
        return;
      case _myHouseAction:
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => const TourChapterRunnerScreen(
              title: 'My House',
              pages: _myHousePages,
            ),
          ),
        );
        return;
      case _myRoomsAction:
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => const TourChapterRunnerScreen(
              title: 'My Rooms',
              pages: _myRoomsPages,
            ),
          ),
        );
        return;
      case _starsRewardsAction:
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => const TourChapterRunnerScreen(
              title: 'Stars and Rewards',
              pages: _starsRewardsPages,
            ),
          ),
        );
        return;
      case _settingsPrivacyAction:
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => const TourChapterRunnerScreen(
              title: 'Settings and Privacy',
              pages: _settingsPrivacyPages,
            ),
          ),
        );
        return;
      case _gardenReplayAction:
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (_) => const FabHomeScreen(replayTourOnLoad: true),
          ),
          (route) => false,
        );
        return;
      default:
        return;
    }
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
              child: Builder(
                builder: (context) {
                  final actionLabel = _actionLabel;
                  return Semantics(
                    button: true,
                    label: actionLabel,
                    child: FabSecondaryActionButton(
                      label: actionLabel,
                      icon: _actionIcon,
                      color: ToursHelpScreen._pink,
                      onTap: onAction!,
                    ),
                  );
                },
              ),
            ),
          ],
        ],
      ),
    );
  }

  String get _actionLabel {
    switch (chapter.actionId) {
      case ToursHelpScreen._welcomeWorldAction:
        return 'Start welcome tour';
      case ToursHelpScreen._gardenReplayAction:
        return 'Replay garden tour';
      case ToursHelpScreen._myHouseAction:
        return 'Start house tour';
      case ToursHelpScreen._myRoomsAction:
        return 'Start rooms tour';
      case ToursHelpScreen._starsRewardsAction:
        return 'Start stars tour';
      case ToursHelpScreen._settingsPrivacyAction:
        return 'Start settings tour';
      default:
        return 'Start';
    }
  }

  IconData get _actionIcon {
    switch (chapter.actionId) {
      case ToursHelpScreen._welcomeWorldAction:
        return Icons.play_arrow_rounded;
      case ToursHelpScreen._gardenReplayAction:
        return Icons.replay_rounded;
      case ToursHelpScreen._myHouseAction:
        return Icons.home_rounded;
      case ToursHelpScreen._myRoomsAction:
        return Icons.meeting_room_rounded;
      case ToursHelpScreen._starsRewardsAction:
        return Icons.star_rounded;
      case ToursHelpScreen._settingsPrivacyAction:
        return Icons.tune_rounded;
      default:
        return Icons.arrow_forward_rounded;
    }
  }

  _ReadinessView _readinessView(TourReadiness readiness) {
    if (chapter.actionId != null) {
      return const _ReadinessView('Ready now', ToursHelpScreen._teal);
    }
    switch (readiness) {
      case TourReadiness.ready:
        return const _ReadinessView('Not open yet', ToursHelpScreen._amber);
      case TourReadiness.comingSoon:
        return const _ReadinessView('Not open yet', ToursHelpScreen._amber);
      case TourReadiness.needsGrownUpHelp:
        return const _ReadinessView('Grown-ups area', ToursHelpScreen._pink);
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
