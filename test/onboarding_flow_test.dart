import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:nova_app/fab/fab_theme.dart';
import 'package:nova_app/fab/models/family_account.dart';
import 'package:nova_app/fab/screens/onboarding_screen.dart';
import 'package:nova_app/fab/services/profile_service.dart';
import 'package:nova_app/fab/services/selected_child_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late Directory hiveDir;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    hiveDir = await Directory.systemTemp.createTemp('nova_onboarding_test_');
    Hive.init(hiveDir.path);
    await Future.wait([
      Hive.openBox<Map>('profiles'),
      Hive.openBox<Map>('family_account'),
      Hive.openBox<Map>('moods'),
      Hive.openBox<Map>('sleep_fatigue'),
    ]);
    await ProfileService.init();
    await FamilyAccount.init();
  });

  tearDown(() async {
    await Hive.close();
    if (await hiveDir.exists()) {
      await hiveDir.delete(recursive: true);
    }
  });

  test(
    'onboarding completion saves profile, account, selected child, and completion flags',
    () async {
      final child = await saveFabOnboardingProfile(
        childName: 'Gareth Test Child',
        age: 10,
        avatarIndex: 1,
        avatarEmoji: 'giraffe',
        conditions: const [FabCondition.anxiety],
        updateExistingChild: false,
        markOnboardingComplete: true,
      );

      expect(ProfileService.profile?.name, 'Gareth Test Child');
      expect(ProfileService.profile?.age, 10);

      final account = FamilyAccount.current;
      expect(account, isNotNull);
      expect(account!.children, hasLength(1));
      expect(account.children.single.id, child.id);
      expect(account.children.single.name, 'Gareth Test Child');
      expect(SelectedChildService.current?.id, child.id);
      expect(Hive.isBoxOpen('child_${child.id}'), isTrue);
      expect(Hive.isBoxOpen('child_${child.id}_journal'), isTrue);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('child_name'), 'Gareth Test Child');
      expect(prefs.getInt('child_age'), 10);
      expect(prefs.getBool('onboarding_complete'), isTrue);
      expect(prefs.getBool('onboarding_done'), isTrue);
    },
  );
}
