import 'dart:math';
import 'package:flutter/material.dart';
import 'fab_world_theme.dart';

// ─────────────────────────────────────────────────────────────
// FAB INTERACTION SYSTEM v1.0
//
// Manages character positions, zone assignments, and
// scheduled interactions across the world scene.
//
// Zone layout (normalised x positions):
//   leftHome   0.18  — Chicken family default
//   pool       0.38  — Swimming pool (left garden)
//   gate       0.51  — Gate / path meeting point
//   swings     0.60  — Swing set (right garden)
//   slide      0.56  — Slide (right garden)
//   rightHome  0.80  — Giraffe family default
//   forest     0.50  — Background (rare)
// ─────────────────────────────────────────────────────────────

enum FabZone {
  leftHome,
  pool,
  gate,
  swings,
  slide,
  rightHome,
  forest,
}

enum FabCharacterId {
  chickenLips,
  daughter9,
  daughter7,
  teds,
  dadGiraffe,
  theo,
  ollie,
  eddie,
}

// ── Zone positions (normalised 0..1 x, ground-relative y) ────
const _zoneX = {
  FabZone.leftHome:  0.18,
  FabZone.pool:      0.38,
  FabZone.gate:      0.505,
  FabZone.swings:    0.595,
  FabZone.slide:     0.555,
  FabZone.rightHome: 0.80,
  FabZone.forest:    0.50,
};

// ── Which zones each character is allowed to visit ───────────
const _allowedZones = {
  FabCharacterId.chickenLips: [
    FabZone.leftHome, FabZone.pool, FabZone.gate
  ],
  FabCharacterId.daughter9: [
    FabZone.leftHome, FabZone.pool, FabZone.swings,
    FabZone.slide, FabZone.gate, FabZone.forest
  ],
  FabCharacterId.daughter7: [
    FabZone.leftHome, FabZone.pool, FabZone.swings,
    FabZone.slide, FabZone.gate
  ],
  FabCharacterId.teds: [
    FabZone.leftHome, FabZone.pool, FabZone.gate,
    FabZone.swings, FabZone.rightHome
  ],
  FabCharacterId.dadGiraffe: [
    FabZone.rightHome, FabZone.gate, FabZone.pool
  ],
  FabCharacterId.theo: [
    FabZone.rightHome, FabZone.swings, FabZone.slide,
    FabZone.gate, FabZone.pool
  ],
  FabCharacterId.ollie: [
    FabZone.rightHome, FabZone.swings, FabZone.slide,
    FabZone.gate, FabZone.pool, FabZone.forest
  ],
  FabCharacterId.eddie: [
    FabZone.leftHome, FabZone.pool, FabZone.gate,
    FabZone.swings, FabZone.slide, FabZone.rightHome
  ],
};

// ── Zone capacity (max characters at once) ───────────────────
const _zoneCapacity = {
  FabZone.leftHome:  4,
  FabZone.pool:      3,
  FabZone.gate:      4,
  FabZone.swings:    2,
  FabZone.slide:     2,
  FabZone.rightHome: 4,
  FabZone.forest:    2,
};

// ─────────────────────────────────────────────────────────────
// CHARACTER STATE
// ─────────────────────────────────────────────────────────────

class FabCharacterState {
  final FabCharacterId id;
  FabZone currentZone;
  FabZone targetZone;
  double currentX;   // normalised 0..1
  double targetX;
  bool isMoving;
  bool flipped;      // facing left
  double arrivalTime; // world phase when arrived
  String pose;        // 'idle' | 'swim' | 'swing' | 'slide' | 'wave' | 'chat'

  FabCharacterState({
    required this.id,
    required this.currentZone,
    required this.currentX,
  })  : targetZone = currentZone,
        targetX = currentX,
        isMoving = false,
        flipped = false,
        arrivalTime = 0,
        pose = 'idle';
}

// ─────────────────────────────────────────────────────────────
// INTERACTION SYSTEM
// ─────────────────────────────────────────────────────────────

class FabInteractionSystem {
  final FabWorldTheme theme;
  final _rng = Random();

  late final Map<FabCharacterId, FabCharacterState> characters;

  // Cooldown tracking
  double _lastInteractionTime = 0;
  double _nextInteractionDelay = 0;
  static const _minDelay = 18.0;  // seconds between interactions
  static const _maxDelay = 45.0;

  FabInteractionSystem({required this.theme}) {
    _initCharacters();
    _nextInteractionDelay = _minDelay + _rng.nextDouble() * (_maxDelay - _minDelay);
  }

  void _initCharacters() {
    characters = {
      FabCharacterId.chickenLips: FabCharacterState(
        id: FabCharacterId.chickenLips,
        currentZone: FabZone.leftHome,
        currentX: _zoneX[FabZone.leftHome]! + 0.12,
      ),
      FabCharacterId.daughter9: FabCharacterState(
        id: FabCharacterId.daughter9,
        currentZone: FabZone.leftHome,
        currentX: _zoneX[FabZone.leftHome]! + 0.06,
      ),
      FabCharacterId.daughter7: FabCharacterState(
        id: FabCharacterId.daughter7,
        currentZone: FabZone.leftHome,
        currentX: _zoneX[FabZone.leftHome]! - 0.02,
      ),
      FabCharacterId.teds: FabCharacterState(
        id: FabCharacterId.teds,
        currentZone: FabZone.leftHome,
        currentX: _zoneX[FabZone.leftHome]! - 0.10,
      ),
      FabCharacterId.dadGiraffe: FabCharacterState(
        id: FabCharacterId.dadGiraffe,
        currentZone: FabZone.rightHome,
        currentX: _zoneX[FabZone.rightHome]! + 0.06,
      ),
      FabCharacterId.theo: FabCharacterState(
        id: FabCharacterId.theo,
        currentZone: FabZone.rightHome,
        currentX: _zoneX[FabZone.rightHome]! - 0.04,
      ),
      FabCharacterId.ollie: FabCharacterState(
        id: FabCharacterId.ollie,
        currentZone: FabZone.rightHome,
        currentX: _zoneX[FabZone.rightHome]! - 0.10,
      ),
      FabCharacterId.eddie: FabCharacterState(
        id: FabCharacterId.eddie,
        currentZone: FabZone.rightHome,
        currentX: _zoneX[FabZone.rightHome]! - 0.16,
      ),
    };
  }

  // ── Called every frame with elapsed time ──────────────────
  void update(double worldPhase, double dt) {
    // Move characters toward targets
    for (final char in characters.values) {
      if (char.isMoving) {
        final speed = 0.12 * dt; // normalised units per second
        final diff = char.targetX - char.currentX;
        char.flipped = diff < 0;

        if (diff.abs() < speed) {
          char.currentX = char.targetX;
          char.currentZone = char.targetZone;
          char.isMoving = false;
          char.arrivalTime = worldPhase;
          char.pose = _poseForZone(char.currentZone);
        } else {
          char.currentX += diff.sign * speed;
        }
      }
    }

    // Schedule next interaction
    _lastInteractionTime += dt;
    if (_lastInteractionTime >= _nextInteractionDelay) {
      _triggerInteraction();
      _lastInteractionTime = 0;
      _nextInteractionDelay = _minDelay + _rng.nextDouble() * (_maxDelay - _minDelay);
    }
  }

  // ── Trigger a random interaction ──────────────────────────
  void _triggerInteraction() {
    // Pick an interaction type
    final roll = _rng.nextDouble();

    if (roll < 0.20) {
      _triggerPoolParty();
    } else if (roll < 0.38) {
      _triggerGateMeeting();
    } else if (roll < 0.54) {
      _triggerPlayground();
    } else if (roll < 0.66) {
      _triggerDogChase();
    } else if (roll < 0.78) {
      _triggerKidsRoam();
    } else if (roll < 0.88) {
      _triggerParentWatch();
    } else {
      _triggerForestAdventure();
    }
  }

  // ── Pool party — kids go to pool ─────────────────────────
  void _triggerPoolParty() {
    if (theme.season == FabSeason.winter) {
      // Frozen pool — kids slide on ice instead
      _sendTo(FabCharacterId.daughter9, FabZone.pool);
      _sendTo(FabCharacterId.daughter7, FabZone.pool);
      return;
    }
    _sendTo(FabCharacterId.daughter9, FabZone.pool);
    _sendTo(FabCharacterId.daughter7, FabZone.pool);
    if (_rng.nextBool()) _sendTo(FabCharacterId.theo, FabZone.pool);
    if (_rng.nextDouble() < 0.4) _sendTo(FabCharacterId.teds, FabZone.pool);
    // Parents watch from home
    _sendTo(FabCharacterId.chickenLips, FabZone.pool);
  }

  // ── Gate meeting — cross-family interaction ───────────────
  void _triggerGateMeeting() {
    // Pick one from each family
    final leftChars = [
      FabCharacterId.chickenLips,
      FabCharacterId.daughter9,
      FabCharacterId.daughter7,
    ];
    final rightChars = [
      FabCharacterId.dadGiraffe,
      FabCharacterId.theo,
      FabCharacterId.ollie,
    ];
    _sendTo(leftChars[_rng.nextInt(leftChars.length)], FabZone.gate);
    _sendTo(rightChars[_rng.nextInt(rightChars.length)], FabZone.gate);
    if (_rng.nextDouble() < 0.5) _sendTo(FabCharacterId.eddie, FabZone.gate);
  }

  // ── Playground — kids on swings + slide ──────────────────
  void _triggerPlayground() {
    if (_rng.nextBool()) {
      _sendTo(FabCharacterId.daughter9, FabZone.swings);
      _sendTo(FabCharacterId.theo, FabZone.swings);
    } else {
      _sendTo(FabCharacterId.daughter7, FabZone.slide);
      _sendTo(FabCharacterId.ollie, FabZone.slide);
    }
    if (_rng.nextDouble() < 0.3) {
      _sendTo(FabCharacterId.daughter9, FabZone.swings);
      _sendTo(FabCharacterId.daughter7, FabZone.slide);
    }
  }

  // ── Dog chase — Eddie and Teds run around ────────────────
  void _triggerDogChase() {
    final zones = [FabZone.pool, FabZone.gate, FabZone.swings];
    final zone = zones[_rng.nextInt(zones.length)];
    _sendTo(FabCharacterId.eddie, zone);
    _sendTo(FabCharacterId.teds, zone);
  }

  // ── Kids roam — random kid goes somewhere ────────────────
  void _triggerKidsRoam() {
    final kids = [
      FabCharacterId.daughter9,
      FabCharacterId.daughter7,
      FabCharacterId.theo,
      FabCharacterId.ollie,
    ];
    final kid = kids[_rng.nextInt(kids.length)];
    final allowed = _allowedZones[kid]!
        .where((z) => z != characters[kid]!.currentZone)
        .toList();
    if (allowed.isNotEmpty) {
      _sendTo(kid, allowed[_rng.nextInt(allowed.length)]);
    }
  }

  // ── Parent watch — parent moves to gate to watch kids ────
  void _triggerParentWatch() {
    if (_rng.nextBool()) {
      _sendTo(FabCharacterId.chickenLips, FabZone.gate);
    } else {
      _sendTo(FabCharacterId.dadGiraffe, FabZone.gate);
    }
  }

  // ── Forest adventure — rare, older kids disappear briefly ─
  void _triggerForestAdventure() {
    if (_rng.nextBool()) {
      _sendTo(FabCharacterId.ollie, FabZone.forest);
      if (_rng.nextBool()) _sendTo(FabCharacterId.daughter9, FabZone.forest);
    }
  }

  // ── Send character to zone ────────────────────────────────
  void _sendTo(FabCharacterId id, FabZone zone) {
    final char = characters[id]!;
    if (char.currentZone == zone) return;

    // Check zone capacity
    final occupants = characters.values
        .where((c) => c.currentZone == zone || c.targetZone == zone)
        .length;
    if (occupants >= (_zoneCapacity[zone] ?? 2)) return;

    final baseX = _zoneX[zone]!;
    // Add small random offset so characters don't stack
    final offset = (_rng.nextDouble() - 0.5) * 0.04;

    char.targetZone = zone;
    char.targetX = (baseX + offset).clamp(0.05, 0.95);
    char.isMoving = true;
    char.pose = 'walking';
  }

  // ── Pose for zone ─────────────────────────────────────────
  String _poseForZone(FabZone zone) {
    switch (zone) {
      case FabZone.pool:      return 'swim';
      case FabZone.swings:    return 'swing';
      case FabZone.slide:     return 'slide';
      case FabZone.gate:      return 'wave';
      case FabZone.forest:    return 'explore';
      default:                return 'idle';
    }
  }

  // ── Get normalised x for character ───────────────────────
  double xOf(FabCharacterId id) => characters[id]!.currentX;
  bool flippedOf(FabCharacterId id) => characters[id]!.flipped;
  String poseOf(FabCharacterId id) => characters[id]!.pose;
  bool isMovingOf(FabCharacterId id) => characters[id]!.isMoving;
}
