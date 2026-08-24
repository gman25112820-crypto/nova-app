import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:nova_app/fab/models/child_profile.dart';
import 'package:nova_app/fab/models/family_account.dart';
import 'package:nova_app/fab/services/read_aloud_service.dart';

DateTime dobForAge(int age) {
  final now = DateTime.now();
  return DateTime(now.year - age, now.month, 1);
}

class _FakeTextToSpeechDriver implements FabTextToSpeechDriver {
  _FakeTextToSpeechDriver({this.languages = const ['en-US']});

  final List<dynamic> languages;
  dynamic speakResult = 1;
  bool throwOnSpeak = false;
  int getLanguagesCalls = 0;
  int speakCalls = 0;
  int stopCalls = 0;
  int setSpeechRateCalls = 0;
  int setPitchCalls = 0;
  VoidCallback? completionHandler;
  VoidCallback? cancelHandler;
  ErrorHandler? errorHandler;

  @override
  void setCompletionHandler(VoidCallback callback) {
    completionHandler = callback;
  }

  @override
  void setCancelHandler(VoidCallback callback) {
    cancelHandler = callback;
  }

  @override
  void setErrorHandler(ErrorHandler handler) {
    errorHandler = handler;
  }

  @override
  Future<dynamic> setSpeechRate(double rate) async {
    setSpeechRateCalls++;
    return 1;
  }

  @override
  Future<dynamic> setPitch(double pitch) async {
    setPitchCalls++;
    return 1;
  }

  @override
  Future<dynamic> speak(String text) async {
    speakCalls++;
    if (throwOnSpeak) {
      throw StateError('speak failed');
    }
    return speakResult;
  }

  @override
  Future<dynamic> stop() async {
    stopCalls++;
    return 1;
  }

  @override
  Future<dynamic> get getLanguages async {
    getLanguagesCalls++;
    return languages;
  }
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

  group('FabReadAloudService', () {
    test(
      'web availability does not depend on non-empty getLanguages',
      () async {
        final tts = _FakeTextToSpeechDriver(languages: []);
        final service = FabReadAloudService.test(tts: tts, isWeb: true);
        await pumpEventQueue();

        expect(service.state.value.available, isTrue);
        expect(tts.getLanguagesCalls, 0);

        await service.toggle(id: 'rest-nest', text: 'Read this fixed text.');

        expect(tts.speakCalls, 1);
        expect(tts.setSpeechRateCalls, 1);
        expect(tts.setPitchCalls, 1);
        expect(service.state.value.isActive('rest-nest'), isTrue);
      },
    );

    test(
      'failed speak clears active state and marks TTS unavailable',
      () async {
        final tts = _FakeTextToSpeechDriver()..throwOnSpeak = true;
        final service = FabReadAloudService.test(tts: tts, isWeb: true);
        await pumpEventQueue();

        await service.toggle(
          id: 'shared-garden',
          text: 'Read this fixed text.',
        );

        expect(tts.speakCalls, 1);
        expect(service.state.value.available, isFalse);
        expect(service.state.value.activeId, isNull);
      },
    );

    test('constructing the service does not autoplay speech', () async {
      final tts = _FakeTextToSpeechDriver(languages: []);

      FabReadAloudService.test(tts: tts, isWeb: true);
      await pumpEventQueue();

      expect(tts.speakCalls, 0);
      expect(tts.stopCalls, 0);
    });
  });
}
