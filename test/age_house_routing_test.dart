import 'package:flutter_test/flutter_test.dart';
import 'package:nova_app/fab/models/child_profile.dart';
import 'package:nova_app/fab/screens/house_interior_screen.dart';

DateTime _dobForAge(int age) {
  final now = DateTime.now();
  return DateTime(now.year - age, now.month, 1);
}

ChildProfile _childWithAge(int age) =>
    ChildProfile(id: 'child-$age', name: 'Child $age', dob: _dobForAge(age));

void main() {
  group('houseTypeForAge', () {
    test('maps age boundaries to the intended house type', () {
      const cases = <int, HouseType>{
        0: HouseType.littleOnes,
        3: HouseType.littleOnes,
        4: HouseType.giraffe,
        6: HouseType.giraffe,
        7: HouseType.chicken,
        9: HouseType.chicken,
        10: HouseType.olderKids,
        12: HouseType.olderKids,
        13: HouseType.teen,
        21: HouseType.teen,
      };

      for (final entry in cases.entries) {
        expect(
          houseTypeForAge(entry.key),
          entry.value,
          reason: 'age ${entry.key}',
        );
      }
    });
  });

  group('Underground doorway age destination', () {
    test('uses the selected child age to choose the eventual house route', () {
      const cases = <int, HouseType>{
        3: HouseType.littleOnes,
        4: HouseType.giraffe,
        7: HouseType.chicken,
        10: HouseType.olderKids,
        13: HouseType.teen,
      };

      for (final entry in cases.entries) {
        expect(
          houseTypeForAge(_childWithAge(entry.key).age),
          entry.value,
          reason: 'age ${entry.key}',
        );
      }
    });
  });
}
