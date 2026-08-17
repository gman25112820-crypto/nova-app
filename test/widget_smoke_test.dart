import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nova_app/fab/models/child_profile.dart';
import 'package:nova_app/fab/screens/house_interior_screen.dart';
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
}
