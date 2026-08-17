import 'package:flutter_test/flutter_test.dart';
import 'package:nova_app/fab/models/child_profile.dart';
import 'package:nova_app/fab/models/family_account.dart';
import 'package:nova_app/fab/services/read_aloud_service.dart';

DateTime dobForAge(int age) {
  final now = DateTime.now();
  return DateTime(now.year - age, now.month, 1);
}

void main() {
  group('ChildProfile', () {
    test('derives age mode from date of birth', () {
      expect(
        ChildProfile(id: '0', name: 'Zero', dob: dobForAge(0)).ageMode,
        AgeMode.littleOnes,
      );
      expect(
        ChildProfile(id: '4', name: 'Four', dob: dobForAge(4)).ageMode,
        AgeMode.earlyYears,
      );
      expect(
        ChildProfile(id: '7', name: 'Seven', dob: dobForAge(7)).ageMode,
        AgeMode.middleYears,
      );
      expect(
        ChildProfile(id: '10', name: 'Ten', dob: dobForAge(10)).ageMode,
        AgeMode.preteen,
      );
      expect(
        ChildProfile(id: '13', name: 'Teen', dob: dobForAge(13)).ageMode,
        AgeMode.teen,
      );
    });

    test('serializes without storing raw PIN values', () {
      final child = ChildProfile(
        id: 'child-1',
        name: 'Ava',
        dob: DateTime(2018, 1, 1),
      )..setPin('1234');

      final json = child.toJson();
      final restored = ChildProfile.fromJson(json);

      expect(json.toString(), isNot(contains('1234')));
      expect(restored.name, 'Ava');
      expect(restored.checkPin('1234'), isTrue);
      expect(restored.checkPin('0000'), isFalse);
    });
  });

  group('FamilyAccount', () {
    test('checks password and parent PIN hashes without raw value storage', () {
      final account = FamilyAccount(id: 'family-1')
        ..setPassword('secret-pass')
        ..setParentPin('2468');

      final json = account.toJson();
      final restored = FamilyAccount.fromJson(json);

      expect(json.toString(), isNot(contains('secret-pass')));
      expect(json.toString(), isNot(contains('2468')));
      expect(restored.checkPassword('secret-pass'), isTrue);
      expect(restored.checkPassword('wrong'), isFalse);
      expect(restored.checkParentPin('2468'), isTrue);
      expect(restored.checkParentPin('1357'), isFalse);
    });
  });

  group('FabReadAloudSnapshot', () {
    test('reports active state by matching id only', () {
      const snapshot = FabReadAloudSnapshot(
        available: true,
        activeId: 'sleep-intro',
      );

      expect(snapshot.isActive('sleep-intro'), isTrue);
      expect(snapshot.isActive('other'), isFalse);
    });

    test('can represent unavailable idle state without platform TTS', () {
      const snapshot = FabReadAloudSnapshot(available: false, activeId: null);

      expect(snapshot.available, isFalse);
      expect(snapshot.isActive('anything'), isFalse);
    });
  });
}
