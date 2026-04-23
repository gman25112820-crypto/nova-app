import 'package:flutter/material.dart';
import 'fab/fab_theme.dart';
import 'fab/widgets/chicken_lips_widget.dart';
import 'fab/models/profile_model.dart';
import 'fab/models/duck_model.dart';

void main() => runApp(const NovaFabApp());

class NovaFabApp extends StatelessWidget {
  const NovaFabApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fabulously Me',
      debugShowCheckedModeBanner: false,
      theme: FabTheme.theme,
      home: const FabShell(),
    );
  }
}

class FabShell extends StatefulWidget {
  const FabShell({super.key});
  @override
  State<FabShell> createState() => _FabShellState();
}

class _FabShellState extends State<FabShell> {
  int _idx = 0;
  final _profile = ProfileModel(
    id: 'liam', name: 'Liam', age: 9,
    conditions: [FabCondition.adhd, FabCondition.sleep, FabCondition.autism],
    medication: 'Methylphenidate 10mg',
    fabStars: 247, currentStreak: 12, longestStreak: 15,
  );
  final _ducks = DuckCollection.all;
  final _checkins = <CheckInModel>[];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FabColors.bg,
      appBar: _buildBar(),
      body: IndexedStack(index: _idx, children: [
        _HomeScreen(profile: _profile,
          onPlay: () => setState(() => _idx = 1),
          onCheckIn: () => setState(() => _idx = 2),
          onReport: () => setState(() => _idx = 4)),
        const _Placeholder(label: 'Play and Sensory'),
        _CheckInScreen(profile: _profile, onSave: (c) => setState(() {
          _checkins.add(c);
          _profile.fabStars += c.starsEarned;
          _profile.lastCheckIn = c.date;
          _profile.currentStreak += 1;
        })),
        _RewardsScreen(profile: _profile, ducks: _ducks),
        const _Placeholder(label: 'Doctor Report'),
      ]),
      bottomNavigationBar: _buildNav(),
    );
  }

  PreferredSizeWidget _buildBar() => AppBar(
    backgroundColor: FabColors.mid,
    elevation: 0,
    title: Row(children: [
      const ChickenLipsAvatar(radius: 18),
      const SizedBox(width: 10),
      const Text('FABULOUSLY ME', style: TextStyle(
        color: FabColors.pink, fontSize: 14, letterSpacing: 2, fontWeight: FontWeight.w500)),
      const SizedBox(width: 8),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: const Color(0x1FFFD700),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0x4DFFD700), width: 0.5),
        ),
        child: const Text('FEELING FAB', style: TextStyle(fontSize: 8, color: FabColors.gold, letterSpacing: 2)),
      ),
      const Spacer(),
      Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
        Text(_profile.name, style: const TextStyle(fontSize: 11, color: FabColors.muted)),
        Text('${_profile.currentStreak} days', style: const TextStyle(fontSize: 11, color: FabColors.gold)),
      ]),
    ]),
    bottom: PreferredSize(
      preferredSize: const Size.fromHeight(0.5),
      child: Container(height: 0.5, color: const Color(0x2EFF8FAB)),
    ),
  );

  Widget _buildNav() => Container(
    color: FabColors.mid,
    child: SafeArea(child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
        _NBtn(icon: Icons.home, label: 'Home', active: _idx == 0, onTap: () => setState(() => _idx = 0)),
        _NBtn(icon: Icons.videogame_asset, label: 'Play', active: _idx == 1, onTap: () => setState(() => _idx = 1)),
        _NBtn(icon: Icons.access_time, label: 'Check-in', active: _idx == 2, onTap: () => setState(() => _idx = 2)),
        _NBtn(icon: Icons.star, label: 'Rewards', active: _idx == 3, onTap: () => setState(() => _idx = 3)),
        _NBtn(icon: Icons.description, label: 'Doctor', active: _idx == 4, onTap: () => setState(() => _idx = 4)),
      ]),
    )),
  );
}

class _NBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;
  const _NBtn({required this.icon, required this.label, required this.active, required this.onTap});
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Column(mainAxisSize: MainAxisSize.min, children: [
      Icon(icon, color: active ? FabColors.pink : FabColors.muted, size: 22),
      const SizedBox(height: 2),
      Text(label, style: TextStyle(fontSize: 10, color: active ? FabColors.pink : FabColors.muted)),
    ]),
  );
}class _HomeScreen extends StatelessWidget {
  final ProfileModel profile;
  final VoidCallback onPlay, onCheckIn, onReport;
  const _HomeScreen({required this.profile, required this.onPlay, required this.onCheckIn, required this.onReport});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(children: [
        Container(
          decoration: BoxDecoration(
            color: FabColors.panel,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0x2EFF8FAB), width: 0.5),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(children: [
            ChickenLipsWidget(
              mood: ChickenLipsMood.happy,
              size: ChickenLipsSize.large,
              showSparkles: profile.currentStreak > 7,
            ),
            const SizedBox(height: 10),
            Text('Morning, ${profile.name}!',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: FabColors.text)),
            const SizedBox(height: 4),
            const Text('How are you feeling today?',
              style: TextStyle(fontSize: 13, color: FabColors.muted)),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: ['sad','meh','ok','good','fab'].map((e) =>
                Container(
                  width: 52, height: 36,
                  decoration: BoxDecoration(
                    color: FabColors.panel2,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0x1AFF8FAB), width: 0.5),
                  ),
                  child: Center(child: Text(e, style: const TextStyle(fontSize: 11, color: FabColors.muted))),
                )
              ).toList(),
            ),
            const SizedBox(height: 10),
            Wrap(spacing: 6, children: profile.conditions.map((c) =>
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: c.color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: c.color.withOpacity(0.3), width: 0.5),
                ),
                child: Text(c.label, style: TextStyle(fontSize: 11, color: c.color)),
              )
            ).toList()),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              decoration: BoxDecoration(
                color: const Color(0x1FFFD700),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0x4DFFD700), width: 0.5),
              ),
              child: Text('${profile.currentStreak} day streak',
                style: const TextStyle(fontSize: 12, color: FabColors.gold)),
            ),
          ]),
        ),
        const SizedBox(height: 10),
        Row(children: [
          Expanded(child: _MC(value: '5.4h', label: 'avg sleep', color: FabColors.teal)),
          const SizedBox(width: 8),
          Expanded(child: _MC(value: '${profile.fabStars}', label: 'fab stars', color: FabColors.gold)),
          const SizedBox(width: 8),
          Expanded(child: _MC(value: '6.2', label: 'avg focus', color: FabColors.pink)),
        ]),
        const SizedBox(height: 10),
        _IC(tag: 'FABULOUSLY ME SAYS', text: 'Sleep under 6h last 3 nights — try the breathing bubble tonight!'),
        const SizedBox(height: 8),
        _IC(tag: 'PATTERN', text: 'Focus scores 1.8 higher on days you used sensory tools. Keep going!'),
        const SizedBox(height: 14),
        _B(label: 'Play and sensory tools', color: FabColors.rose, onTap: onPlay),
        const SizedBox(height: 8),
        _B(label: 'Daily check-in', color: FabColors.panel2, onTap: onCheckIn),
        const SizedBox(height: 8),
        _B(label: 'Doctor report', color: Colors.transparent,
          textColor: FabColors.gold,
          border: Border.all(color: const Color(0x4DFFD700), width: 0.5),
          onTap: onReport),
        const SizedBox(height: 20),
      ]),
    );
  }
}

class _MC extends StatelessWidget {
  final String value, label;
  final Color color;
  const _MC({required this.value, required this.label, required this.color});
  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(color: FabColors.panel, borderRadius: BorderRadius.circular(12),
      border: Border.all(color: const Color(0x1EFF8FAB), width: 0.5)),
    padding: const EdgeInsets.all(12),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500, color: color)),
      Text(label, style: const TextStyle(fontSize: 10, color: FabColors.muted)),
    ]),
  );
}

class _IC extends StatelessWidget {
  final String tag, text;
  const _IC({required this.tag, required this.text});
  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    decoration: BoxDecoration(color: const Color(0x12FF8FAB), borderRadius: BorderRadius.circular(12),
      border: Border.all(color: const Color(0x33FF8FAB), width: 0.5)),
    padding: const EdgeInsets.all(12),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(tag, style: const TextStyle(fontSize: 10, color: FabColors.pink, letterSpacing: 1)),
      const SizedBox(height: 4),
      Text(text, style: const TextStyle(fontSize: 12, color: FabColors.text, height: 1.5)),
    ]),
  );
}

class _B extends StatelessWidget {
  final String label;
  final Color color;
  final Color textColor;
  final Border? border;
  final VoidCallback onTap;
  const _B({required this.label, required this.color, required this.onTap, this.textColor = FabColors.text, this.border});
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 13),
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(12), border: border),
      child: Center(child: Text(label,
        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: textColor))),
    ),
  );
}class _CheckInScreen extends StatelessWidget {
  final ProfileModel profile;
  final void Function(CheckInModel) onSave;
  const _CheckInScreen({required this.profile, required this.onSave});

  @override
  Widget build(BuildContext context) => Center(
    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      const ChickenLipsWidget(mood: ChickenLipsMood.happy, size: ChickenLipsSize.medium),
      const SizedBox(height: 16),
      const Text('Check-in', style: TextStyle(fontSize: 16, color: FabColors.pink)),
      const SizedBox(height: 8),
      const Text('Full version coming soon', style: TextStyle(fontSize: 12, color: FabColors.muted)),
      const SizedBox(height: 16),
      GestureDetector(
        onTap: () {
          final c = CheckInModel(
            id: DateTime.now().toString(),
            profileId: profile.id,
            date: DateTime.now(),
            moodScore: 4,
            medicationTaken: true,
          );
          onSave(c);
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('+${c.starsEarned} stars earned!'),
            backgroundColor: FabColors.panel2,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ));
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          decoration: BoxDecoration(color: FabColors.rose, borderRadius: BorderRadius.circular(12)),
          child: const Text('Quick check-in', style: TextStyle(color: Colors.white, fontSize: 14)),
        ),
      ),
    ]),
  );
}

class _RewardsScreen extends StatelessWidget {
  final ProfileModel profile;
  final List<DuckModel> ducks;
  const _RewardsScreen({required this.profile, required this.ducks});

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    padding: const EdgeInsets.all(16),
    child: Column(children: [
      const ChickenLipsWidget(mood: ChickenLipsMood.crowned, size: ChickenLipsSize.large, showSparkles: true),
      const SizedBox(height: 8),
      const Text('FEELING FAB', style: TextStyle(fontSize: 12, color: FabColors.gold, letterSpacing: 4)),
      const SizedBox(height: 16),
      Container(
        decoration: BoxDecoration(color: FabColors.panel, borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0x33FFD700), width: 0.5)),
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          Text('${profile.fabStars}',
            style: const TextStyle(fontSize: 40, fontWeight: FontWeight.w500, color: FabColors.gold)),
          const Text('fab stars', style: TextStyle(fontSize: 13, color: FabColors.muted)),
          const SizedBox(height: 10),
          Row(mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(7, (i) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: Text(i < profile.currentStreak.clamp(0, 7) ? '★' : '☆',
                style: TextStyle(fontSize: 18,
                  color: i < profile.currentStreak.clamp(0, 7) ? FabColors.gold : FabColors.muted)),
            ))),
        ]),
      ),
      const SizedBox(height: 14),
      ...profile.rewards.map((r) => Container(
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(color: FabColors.panel, borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0x1EFF8FAB), width: 0.5)),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(children: [
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(r.label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: FabColors.text)),
            Text(r.description, style: const TextStyle(fontSize: 11, color: FabColors.muted)),
          ])),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: profile.fabStars >= r.cost ? const Color(0x1A00C9A7) : FabColors.panel2,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: profile.fabStars >= r.cost ? const Color(0x6600C9A7) : const Color(0x1AFF8FAB),
                width: 0.5),
            ),
            child: Text('${r.cost} stars',
              style: TextStyle(fontSize: 12,
                color: profile.fabStars >= r.cost ? FabColors.teal : FabColors.muted)),
          ),
        ]),
      )),
    ]),
  );
}

class _Placeholder extends StatelessWidget {
  final String label;
  const _Placeholder({required this.label});
  @override
  Widget build(BuildContext context) => Center(
    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      const ChickenLipsWidget(mood: ChickenLipsMood.neutral, size: ChickenLipsSize.medium),
      const SizedBox(height: 12),
      Text(label, style: const TextStyle(fontSize: 16, color: FabColors.pink)),
      const SizedBox(height: 6),
      const Text('Coming soon', style: TextStyle(fontSize: 12, color: FabColors.muted)),
    ]),
  );
}