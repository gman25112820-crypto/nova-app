import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nova_app/fab/models/child_profile.dart';
import 'package:nova_app/fab/screens/fab_home_screen.dart';
import 'package:nova_app/fab/screens/house_interior_screen.dart';
import 'package:nova_app/fab/screens/shared_garden_screen.dart';
import 'package:nova_app/fab/screens/sleep_nest_screen.dart';
import 'package:nova_app/fab/screens/underground_entrance_screen.dart';
import 'package:nova_app/fab/services/selected_child_service.dart';

DateTime _dobForAge(int age) {
  final now = DateTime.now();
  return DateTime(now.year - age, now.month, 1);
}

ChildProfile _childWithAge(int age) => ChildProfile(
  id: 'widget-child-$age',
  name: 'Child $age',
  dob: _dobForAge(age),
);

void main() {
  testWidgets('Little Ones house placeholder builds', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: HouseInteriorScreen(house: HouseType.littleOnes)),
    );

    expect(find.textContaining('Little Ones'), findsOneWidget);
    expect(find.text('Parent observation log'), findsOneWidget);
  });

  testWidgets('Underground entrance doorway opens age-aware house route', (
    tester,
  ) async {
    SelectedChildService.select(_childWithAge(13));

    await tester.pumpWidget(
      const MaterialApp(home: UndergroundEntranceScreen()),
    );

    expect(find.text('dig a new room?'), findsNothing);
    expect(find.text('Explore the rooms'), findsOneWidget);

    await tester.tap(find.byKey(const Key('underground-doorway')));
    await tester.pumpAndSettle();

    expect(find.textContaining('My Space'), findsOneWidget);
    expect(find.text('Not open yet'), findsWidgets);
  });

  testWidgets('Rest Nest remains an independent destination', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: SleepNestScreen()));

    expect(find.text('Rest Nest'), findsOneWidget);
    expect(find.byType(UndergroundEntranceScreen), findsNothing);

    await tester.pumpWidget(const SizedBox.shrink());
  });
  testWidgets('Shared Garden hub builds with expected activity availability', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: SharedGardenScreen()));

    expect(find.textContaining('Shared Garden'), findsOneWidget);
    expect(find.text('Create Together'), findsOneWidget);
    expect(find.text('Story Garden'), findsOneWidget);
    expect(find.text('Grow Together'), findsOneWidget);
    expect(find.text('Music Corner'), findsOneWidget);
    expect(find.text('Not open yet'), findsOneWidget);
  });

  testWidgets('Shared Garden activities remain navigable except Music Corner', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: SharedGardenScreen()));

    await tester.tap(find.text('Create Together'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Create Together'), findsOneWidget);
    Navigator.of(tester.element(find.byType(CreateTogetherScreen))).pop();
    await tester.pumpAndSettle();

    await tester.tap(find.text('Story Garden'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Story Garden'), findsOneWidget);
    Navigator.of(tester.element(find.byType(StoryGardenScreen))).pop();
    await tester.pumpAndSettle();

    await tester.tap(find.text('Grow Together'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Grow Together'), findsOneWidget);
    Navigator.of(tester.element(find.byType(GrowTogetherScreen))).pop();
    await tester.pumpAndSettle();

    await tester.tap(find.text('Music Corner'));
    await tester.pumpAndSettle();
    expect(find.byType(MusicCornerScreen), findsNothing);
    expect(find.textContaining('Shared Garden'), findsOneWidget);
  });

  testWidgets('live world Shared Garden destination points to the hub', (
    tester,
  ) async {
    expect(sharedGardenDestination(), isA<SharedGardenScreen>());

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => TextButton(
            onPressed: () => Navigator.push(context, sharedGardenRoute()),
            child: const Text('Open Shared Garden'),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open Shared Garden'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Shared Garden'), findsOneWidget);
  });
}
