import 'dart:math';
import 'package:flutter/material.dart';
import 'fab_world_theme.dart';

// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
// FAB INTERACTION SYSTEM v1.0
//
// Manages character positions, zone assignments, and
// scheduled interactions across the world scene.
//
// Zone layout (normalised x positions):
//   leftHome   0.18  â€” Chicken family default
//   pool       0.38  â€” Swimming pool (left garden)
//   gate       0.51  â€” Gate / path meeting point
//   swings     0.60  â€” Swing set (right garden)
//   slide      0.56  â€” Slide (right garden)
//   rightHome  0.80  â€” Giraffe family default
//   forest     0.50  â€” Background (rare)
// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

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

// â”€â”€ Zone positions (normalised 0..1 x, ground-relative y) â”€â”€â”€â”€
const _zoneX = {
  FabZone.leftHome:  0.18,
  FabZone.pool:      0.38,
  FabZone.gate:      0.505,
  FabZone.swings:    0.595,
  FabZone.slide:     0.555,
  FabZone.rightHome: 0.80,
  FabZone.forest:    0.50,
};

// â”€â”€ Which zones each character is allowed to visit â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
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

// â”€â”€ Zone capacity (max characters at once) â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
const _zoneCapacity = {
  FabZone.leftHome:  4,
  FabZone.pool:      3,
  FabZone.gate:      4,
  FabZone.swings:    2,
  FabZone.slide:     2,
  FabZone.rightHome: 4,
  FabZone.forest:    2,
};

// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
// CHARACTER STATE
// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

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

// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
// INTERACTION SYSTEM
// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

class FabInteractionSystem {
  final FabWorldTheme theme;
  final _rng = Random();

  late final Map<FabCharacterId, FabCharacterState> characters;

  // Cooldown tracking
  double _lastInteractionTime = 0;
  double _nextInteractionDelay = 0;
  static const _minDelay = 12.0;  // seconds between interactions
  static const _maxDelay = 30.0;

  FabInteractionSystem({required this.theme}) {
    _initCharacters();
    _nextInteractionDelay = _minDelay + _rng.nextDouble() * (_maxDelay - _minDelay);
  }

  void _initCharacters() {
    // leftHome zone centre = 0.18. Chicken family clustered tight in front of left house.
    // rightHome zone centre = 0.80. Giraffe family clustered tight in front of right house.
    characters = {
      FabCharacterId.chickenLips: FabCharacterState(
        id: FabCharacterId.chickenLips,
        currentZone: FabZone.leftHome,
        currentX: 0.235,   // centre-right of chicken group
      ),
      FabCharacterId.daughter9: FabCharacterState(
        id: FabCharacterId.daughter9,
        currentZone: FabZone.leftHome,
        currentX: 0.195,
      ),
      FabCharacterId.daughter7: FabCharacterState(
        id: FabCharacterId.daughter7,
        currentZone: FabZone.leftHome,
        currentX: 0.162,
      ),
      FabCharacterId.teds: FabCharacterState(
        id: FabCharacterId.teds,
        currentZone: FabZone.leftHome,
        currentX: 0.128,   // shih tzu at near-left of house
      ),
      FabCharacterId.dadGiraffe: FabCharacterState(
        id: FabCharacterId.dadGiraffe,
        currentZone: FabZone.rightHome,
        currentX: 0.840,   // right of giraffe group
      ),
      FabCharacterId.theo: FabCharacterState(
        id: FabCharacterId.theo,
        currentZone: FabZone.rightHome,
        currentX: 0.800,
      ),
      FabCharacterId.ollie: FabCharacterState(
        id: FabCharacterId.ollie,
        currentZone: FabZone.rightHome,
        currentX: 0.762,
      ),
      FabCharacterId.eddie: FabCharacterState(
        id: FabCharacterId.eddie,
        currentZone: FabZone.rightHome,
        currentX: 0.726,   // jack russell at left of giraffe group
      ),
    };
  }

  // â”€â”€ Called every frame with elapsed time â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  void update(double worldPhase, double dt) {
    // Move characters toward targets
    for (final char in characters.values) {
      if (char.isMoving) {
        final speed = 0.18 * dt; // normalised units per second â€” snappier
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

  // â”€â”€ Trigger a random interaction â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
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

  // â”€â”€ Pool party â€” kids go to pool â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  void _triggerPoolParty() {
    if (theme.season == FabSeason.winter) {
      // Frozen pool â€” kids slide on ice instead
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

  // â”€â”€ Gate meeting â€” cross-family interaction â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
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

  // â”€â”€ Playground â€” kids on swings + slide â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
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

  // â”€â”€ Dog chase â€” Eddie and Teds run around â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  void _triggerDogChase() {
    final zones = [FabZone.pool, FabZone.gate, FabZone.swings];
    final zone = zones[_rng.nextInt(zones.length)];
    _sendTo(FabCharacterId.eddie, zone);
    _sendTo(FabCharacterId.teds, zone);
  }

  // â”€â”€ Kids roam â€” random kid goes somewhere â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
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

  // â”€â”€ Parent watch â€” parent moves to gate to watch kids â”€â”€â”€â”€
  void _triggerParentWatch() {
    if (_rng.nextBool()) {
      _sendTo(FabCharacterId.chickenLips, FabZone.gate);
    } else {
      _sendTo(FabCharacterId.dadGiraffe, FabZone.gate);
    }
  }

  // â”€â”€ Forest adventure â€” rare, older kids disappear briefly â”€
  void _triggerForestAdventure() {
    if (_rng.nextBool()) {
      _sendTo(FabCharacterId.ollie, FabZone.forest);
      if (_rng.nextBool()) _sendTo(FabCharacterId.daughter9, FabZone.forest);
    }
  }

  // â”€â”€ Send character to zone â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  void _sendTo(FabCharacterId id, FabZone zone) {
    final char = characters[id]!;
    if (char.currentZone == zone) return;

    // Check zone capacity
    final occupants = characters.values
        .where((c) => c.currentZone == zone || c.targetZone == zone)
        .length;
    if (occupants >= (_zoneCapacity[zone] ?? 2)) return;

    final baseX = _zoneX[zone]!;

    // Fan characters out within zone â€” each gets a different slot
    // so they never stack on top of each other
    final slotWidth = 0.055;
    final slot = occupants; // 0, 1, 2, 3...
    final sideSign = (slot % 2 == 0) ? 1.0 : -1.0;
    final slotOffset = sideSign * ((slot ~/ 2) + 1) * slotWidth;
    // Also add tiny random nudge for natural feel
    final nudge = (_rng.nextDouble() - 0.5) * 0.015;

    char.targetZone = zone;
    char.targetX = (baseX + slotOffset + nudge).clamp(0.04, 0.96);
    char.isMoving = true;
    char.pose = 'walking';
  }

  // â”€â”€ Pose for zone â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
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

  // â”€â”€ Get normalised x for character â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  double xOf(FabCharacterId id) => characters[id]!.currentX;
  bool flippedOf(FabCharacterId id) => characters[id]!.flipped;
  String poseOf(FabCharacterId id) => characters[id]!.pose;
  bool isMovingOf(FabCharacterId id) => characters[id]!.isMoving;

  // â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  // EPISODE SYSTEM â€” Cat vs Dog soap opera sequences
  // â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

  int _currentEpisode = 0;     // 0 = none running
  int _episodeStep = 0;
  double _episodeTimer = 0;
  double _episodeStepDuration = 0;
  double _nextEpisodeDelay = 0;
  double _episodeIdleTime = 0;
  static const _episodeMinDelay = 55.0;
  static const _episodeMaxDelay = 110.0;

  // Cat state callbacks â€” set by scene
  Function(int cat1Window, int cat2Window, double opacity1, double opacity2)?
      onCatStateChange;

  void initEpisodes() {
    _nextEpisodeDelay =
        _episodeMinDelay + _rng.nextDouble() * (_episodeMaxDelay - _episodeMinDelay);
  }

  void updateEpisodes(double dt) {
    if (_currentEpisode == 0) {
      _episodeIdleTime += dt;
      if (_episodeIdleTime >= _nextEpisodeDelay) {
        _episodeIdleTime = 0;
        _nextEpisodeDelay =
            _episodeMinDelay + _rng.nextDouble() * (_episodeMaxDelay - _episodeMinDelay);
        _tryStartEpisode();
      }
      return;
    }

    _episodeTimer += dt;
    if (_episodeTimer >= _episodeStepDuration) {
      _episodeTimer = 0;
      _episodeStep++;
      _runEpisodeStep(_currentEpisode, _episodeStep);
    }
  }

  void _tryStartEpisode() {
    // Only start if dogs are roughly home
    final tedsHome = characters[FabCharacterId.teds]!.currentZone == FabZone.leftHome;
    final eddieHome = characters[FabCharacterId.eddie]!.currentZone == FabZone.rightHome ||
        characters[FabCharacterId.eddie]!.currentZone == FabZone.leftHome;
    if (!tedsHome && !eddieHome) return;

    final episode = 1 + _rng.nextInt(5);
    _currentEpisode = episode;
    _episodeStep = 1;
    _episodeTimer = 0;
    _runEpisodeStep(episode, 1);
  }

  void _runEpisodeStep(int episode, int step) {
    switch (episode) {
      case 1: _episode1Taunt(step); break;
      case 2: _episode2Standoff(step); break;
      case 3: _episode3Drop(step); break;
      case 4: _episode4Chase(step); break;
      case 5: _episode5Ignore(step); break;
    }
  }

  void _endEpisode() {
    _currentEpisode = 0;
    _episodeStep = 0;
    // Return cats to default positions
    onCatStateChange?.call(0, 1, 1.0, 1.0);
    // Return dogs home
    _returnHome(FabCharacterId.teds);
    _returnHome(FabCharacterId.eddie);
  }

  void _returnHome(FabCharacterId id) {
    final char = characters[id]!;
    final homeZone = id == FabCharacterId.teds ||
            id == FabCharacterId.daughter7 ||
            id == FabCharacterId.daughter9 ||
            id == FabCharacterId.chickenLips
        ? FabZone.leftHome
        : FabZone.rightHome;
    final baseX = _zoneX[homeZone]!;
    final offset = (_rng.nextDouble() - 0.5) * 0.06;
    char.targetZone = homeZone;
    char.targetX = (baseX + offset).clamp(0.04, 0.96);
    char.isMoving = true;
    char.pose = 'walking';
  }

  // â”€â”€ Episode 1: The Taunt â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  // Cat leans out â†’ Teds approaches â†’ cat disappears â†’
  // Teds confused â†’ cat reappears in other window
  void _episode1Taunt(int step) {
    switch (step) {
      case 1: // Cat appears leaning out left window, Teds notices
        onCatStateChange?.call(0, -1, 1.0, 0.0);
        _episodeStepDuration = 4.0;
        break;
      case 2: // Teds walks toward house
        _sendTo(FabCharacterId.teds, FabZone.leftHome);
        final char = characters[FabCharacterId.teds]!;
        char.targetX = 0.14; // close to house wall
        _episodeStepDuration = 3.5;
        break;
      case 3: // Cat disappears!
        onCatStateChange?.call(-1, -1, 0.0, 0.0);
        _episodeStepDuration = 2.5;
        break;
      case 4: // Teds sits confused (stays put)
        _episodeStepDuration = 3.0;
        break;
      case 5: // Cat reappears in OTHER window behind Teds
        onCatStateChange?.call(-1, 1, 0.0, 1.0);
        _episodeStepDuration = 4.0;
        break;
      case 6: // Both cats now watching Teds
        onCatStateChange?.call(0, 1, 1.0, 1.0);
        _episodeStepDuration = 2.0;
        break;
      default: _endEpisode();
    }
  }

  // â”€â”€ Episode 2: The Standoff â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  // Both cats stare down â†’ Eddie runs up â†’ cats retreat â†’
  // Eddie struts â†’ cats reappear watching
  void _episode2Standoff(int step) {
    switch (step) {
      case 1: // Both cats in same window staring down
        onCatStateChange?.call(0, 0, 1.0, 1.0);
        _episodeStepDuration = 3.0;
        break;
      case 2: // Eddie charges over
        _sendTo(FabCharacterId.eddie, FabZone.leftHome);
        final char = characters[FabCharacterId.eddie]!;
        char.targetX = 0.16;
        _episodeStepDuration = 3.0;
        break;
      case 3: // Cats vanish
        onCatStateChange?.call(-1, -1, 0.0, 0.0);
        _episodeStepDuration = 2.5;
        break;
      case 4: // Eddie struts (stays put, looking proud)
        _episodeStepDuration = 3.5;
        break;
      case 5: // Cats peek back â€” different windows this time
        onCatStateChange?.call(1, 0, 1.0, 1.0);
        _episodeStepDuration = 3.0;
        break;
      case 6: // Eddie wanders off
        _returnHome(FabCharacterId.eddie);
        _episodeStepDuration = 2.0;
        break;
      default: _endEpisode();
    }
  }

  // â”€â”€ Episode 3: The Drop â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  // Cat leans out â†’ Teds and Eddie run over â†’ cat pulls back â†’
  // both dogs left staring at empty window
  void _episode3Drop(int step) {
    switch (step) {
      case 1: // Cat leans dangerously out of window
        onCatStateChange?.call(0, -1, 1.0, 0.0);
        _episodeStepDuration = 3.0;
        break;
      case 2: // Both dogs run over excitedly
        _sendTo(FabCharacterId.teds, FabZone.leftHome);
        _sendTo(FabCharacterId.eddie, FabZone.leftHome);
        final t = characters[FabCharacterId.teds]!;
        final e = characters[FabCharacterId.eddie]!;
        t.targetX = 0.13;
        e.targetX = 0.17;
        _episodeStepDuration = 3.5;
        break;
      case 3: // Cat pulls back safely
        onCatStateChange?.call(-1, -1, 0.0, 0.0);
        _episodeStepDuration = 3.0;
        break;
      case 4: // Dogs left staring at empty window
        _episodeStepDuration = 4.0;
        break;
      case 5: // Cat reappears in right window smugly
        onCatStateChange?.call(-1, 1, 0.0, 1.0);
        _episodeStepDuration = 3.0;
        break;
      default: _endEpisode();
    }
  }

  // â”€â”€ Episode 4: The Chase â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  // Cat appears on ground â†’ dogs give chase across scene â†’
  // cat disappears inside â†’ dogs at door confused
  void _episode4Chase(int step) {
    switch (step) {
      case 1: // Cat "escapes" to ground (window goes empty, cat appears near house)
        onCatStateChange?.call(-1, -1, 0.0, 0.0);
        _episodeStepDuration = 1.5;
        break;
      case 2: // Teds and Eddie chase across to gate area
        _sendTo(FabCharacterId.teds, FabZone.gate);
        _sendTo(FabCharacterId.eddie, FabZone.gate);
        _episodeStepDuration = 4.0;
        break;
      case 3: // Cat disappears back inside (windows light up again)
        onCatStateChange?.call(0, 1, 1.0, 1.0);
        _episodeStepDuration = 2.0;
        break;
      case 4: // Dogs at gate, confused, looking around
        _episodeStepDuration = 3.5;
        break;
      case 5: // Dogs slink home
        _returnHome(FabCharacterId.teds);
        _returnHome(FabCharacterId.eddie);
        _episodeStepDuration = 2.0;
        break;
      default: _endEpisode();
    }
  }

  // â”€â”€ Episode 5: The Ignore â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  // Dog sits below window â†’ cat visible completely ignoring â†’
  // cat slowly turns away â†’ dog gives up
  void _episode5Ignore(int step) {
    switch (step) {
      case 1: // Both cats in left window looking down
        onCatStateChange?.call(0, 0, 1.0, 1.0);
        _episodeStepDuration = 2.0;
        break;
      case 2: // Teds sits right below window
        final char = characters[FabCharacterId.teds]!;
        char.targetX = 0.133;
        char.isMoving = true;
        _episodeStepDuration = 3.0;
        break;
      case 3: // Cat 2 turns away (goes to right window, back to Teds)
        onCatStateChange?.call(0, 1, 1.0, 1.0);
        _episodeStepDuration = 4.0;
        break;
      case 4: // Cat 1 also disappears â€” total snub
        onCatStateChange?.call(-1, 1, 0.0, 1.0);
        _episodeStepDuration = 3.5;
        break;
      case 5: // Teds wanders off dejected
        _returnHome(FabCharacterId.teds);
        _episodeStepDuration = 2.0;
        break;
      case 6: // Cats reappear watching Teds leave
        onCatStateChange?.call(0, 1, 1.0, 1.0);
        _episodeStepDuration = 2.0;
        break;
      default: _endEpisode();
    }
  }

}
