import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nova_app/fab/screens/house_interior_screen.dart';

void main() {
  testWidgets('Little Ones house placeholder builds', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: HouseInteriorScreen(house: HouseType.littleOnes)),
    );

    expect(find.textContaining('Little Ones'), findsOneWidget);
    expect(find.text('Parent observation log'), findsOneWidget);
  });
}
