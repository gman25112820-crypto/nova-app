import 'package:flutter/foundation.dart';

@immutable
class FabState {
  final String mood;
  final int intensity;

  const FabState({
    this.mood = 'confident',
    this.intensity = 5,
  });

  FabState copyWith({String? mood, int? intensity}) => FabState(
        mood: mood ?? this.mood,
        intensity: intensity ?? this.intensity,
      );

  @override
  bool operator ==(Object other) =>
      other is FabState &&
      other.mood == mood &&
      other.intensity == intensity;

  @override
  int get hashCode => Object.hash(mood, intensity);
}
