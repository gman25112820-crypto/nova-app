import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';

class FabReadAloudSnapshot {
  final bool available;
  final String? activeId;

  const FabReadAloudSnapshot({
    required this.available,
    required this.activeId,
  });

  bool isActive(String id) => activeId == id;
}

class FabReadAloudService {
  FabReadAloudService._() {
    _tts.setCompletionHandler(_markStopped);
    _tts.setCancelHandler(_markStopped);
    _tts.setErrorHandler((_) {
      _available = false;
      _markStopped();
    });
    _checkAvailability();
  }

  static final FabReadAloudService instance = FabReadAloudService._();

  final FlutterTts _tts = FlutterTts();
  final ValueNotifier<FabReadAloudSnapshot> state =
      ValueNotifier<FabReadAloudSnapshot>(
    const FabReadAloudSnapshot(available: true, activeId: null),
  );

  bool _available = true;
  String? _activeId;

  Future<void> toggle({
    required String id,
    required String text,
  }) async {
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
    _activeId = id;
    _publish();

    try {
      await _tts.setSpeechRate(0.45);
      await _tts.setPitch(1.0);
      await _tts.speak(words);
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
