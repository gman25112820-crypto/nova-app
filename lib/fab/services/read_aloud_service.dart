import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';

class FabReadAloudSnapshot {
  final bool available;
  final String? activeId;

  const FabReadAloudSnapshot({required this.available, required this.activeId});

  bool isActive(String id) => activeId == id;
}

class FabReadAloudService {
  FabReadAloudService._({FabTextToSpeechDriver? tts, bool? isWeb})
    : _tts = tts ?? FabFlutterTextToSpeechDriver(FlutterTts()),
      _isWeb = isWeb ?? kIsWeb {
    _tts.setCompletionHandler(_markStopped);
    _tts.setCancelHandler(_markStopped);
    _tts.setErrorHandler((_) {
      _available = false;
      _markStopped();
    });
    _checkAvailability();
  }

  static final FabReadAloudService instance = FabReadAloudService._();

  @visibleForTesting
  FabReadAloudService.test({
    required FabTextToSpeechDriver tts,
    bool isWeb = false,
  }) : this._(tts: tts, isWeb: isWeb);

  final FabTextToSpeechDriver _tts;
  final bool _isWeb;
  final ValueNotifier<FabReadAloudSnapshot> state =
      ValueNotifier<FabReadAloudSnapshot>(
        const FabReadAloudSnapshot(available: true, activeId: null),
      );

  bool _available = true;
  String? _activeId;

  Future<void> toggle({required String id, required String text}) async {
    final words = text.trim();
    if (words.isEmpty || !_available) {
      _markStopped();
      return;
    }

    if (_activeId == id) {
      await stop();
      return;
    }

    await stop();

    try {
      await _tts.setSpeechRate(0.41);
      await _tts.setPitch(0.95);
      final result = await _tts.speak(words);
      if (result == false || result == 0) {
        _available = false;
        _markStopped();
        return;
      }
      _activeId = id;
      _publish();
    } catch (_) {
      _available = false;
      _markStopped();
    }
  }

  Future<void> stop() async {
    try {
      await _tts.stop();
    } catch (_) {
      _available = false;
    } finally {
      _markStopped();
    }
  }

  Future<void> _checkAvailability() async {
    if (_isWeb) {
      _available = true;
      _publish();
      return;
    }

    try {
      final languages = await _tts.getLanguages;
      _available = languages is List && languages.isNotEmpty;
    } catch (_) {
      _available = false;
    }
    _publish();
  }

  void _markStopped() {
    _activeId = null;
    _publish();
  }

  void _publish() {
    state.value = FabReadAloudSnapshot(
      available: _available,
      activeId: _activeId,
    );
  }
}

abstract class FabTextToSpeechDriver {
  void setCompletionHandler(VoidCallback callback);
  void setCancelHandler(VoidCallback callback);
  void setErrorHandler(ErrorHandler handler);
  Future<dynamic> setSpeechRate(double rate);
  Future<dynamic> setPitch(double pitch);
  Future<dynamic> speak(String text);
  Future<dynamic> stop();
  Future<dynamic> get getLanguages;
}

class FabFlutterTextToSpeechDriver implements FabTextToSpeechDriver {
  final FlutterTts _tts;

  FabFlutterTextToSpeechDriver(this._tts);

  @override
  void setCompletionHandler(VoidCallback callback) {
    _tts.setCompletionHandler(callback);
  }

  @override
  void setCancelHandler(VoidCallback callback) {
    _tts.setCancelHandler(callback);
  }

  @override
  void setErrorHandler(ErrorHandler handler) {
    _tts.setErrorHandler(handler);
  }

  @override
  Future<dynamic> setSpeechRate(double rate) => _tts.setSpeechRate(rate);

  @override
  Future<dynamic> setPitch(double pitch) => _tts.setPitch(pitch);

  @override
  Future<dynamic> speak(String text) => _tts.speak(text);

  @override
  Future<dynamic> stop() => _tts.stop();

  @override
  Future<dynamic> get getLanguages => _tts.getLanguages;
}
