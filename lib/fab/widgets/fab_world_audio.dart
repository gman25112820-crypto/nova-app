import 'dart:math';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'fab_world_theme.dart';

// ─────────────────────────────────────────────────────────────
// FAB WORLD AUDIO — Spatial Seasonal Soundscape v1.0
//
// Architecture:
//   _ambientPlayer   — looping background layer (season-driven)
//   _weatherPlayer   — looping weather layer (rain/wind/snow hush)
//   _nightPlayer     — looping night layer (crickets/owls/silence)
//   _sfxPool[]       — pool of one-shot players for character SFX
//
// Spatial panning: parallaxX (-1..1) biases left/right family
// volumes so the family you're "looking toward" is slightly louder.
//
// All asset paths follow:  assets/audio/<name>.mp3
// ─────────────────────────────────────────────────────────────

class FabWorldAudio {
  // ── Players ─────────────────────────────────────────────────
  final AudioPlayer _ambientPlayer  = AudioPlayer();
  final AudioPlayer _weatherPlayer  = AudioPlayer();
  final AudioPlayer _nightPlayer    = AudioPlayer();
  final List<AudioPlayer> _sfxPool  = List.generate(6, (_) => AudioPlayer());
  int _sfxIndex = 0;

  // ── State ────────────────────────────────────────────────────
  FabSeason? _currentSeason;
  bool _muted = false;
  bool _calmMode = false;        // strips back to single soft ambient
  double _masterVolume = 0.70;
  double _parallaxX = 0.0;       // -1..1, updated by scene

  // ── Cooldown tracking (prevent SFX spam) ────────────────────
  final Map<String, DateTime> _lastSfx = {};
  static const _sfxCooldown = Duration(seconds: 3);

  // ─────────────────────────────────────────────────────────────
  // INIT
  // ─────────────────────────────────────────────────────────────

  Future<void> init(FabWorldTheme theme) async {
    await _ambientPlayer.setReleaseMode(ReleaseMode.loop);
    await _weatherPlayer.setReleaseMode(ReleaseMode.loop);
    await _nightPlayer.setReleaseMode(ReleaseMode.loop);

    await _ambientPlayer.setVolume(0);
    await _weatherPlayer.setVolume(0);
    await _nightPlayer.setVolume(0);

    await _startSeason(theme);
  }

  // ─────────────────────────────────────────────────────────────
  // SEASON CHANGE
  // ─────────────────────────────────────────────────────────────

  Future<void> _startSeason(FabWorldTheme theme) async {
    if (_currentSeason == theme.season) return;
    _currentSeason = theme.season;

    // Fade out existing layers
    await _fadeOut(_ambientPlayer);
    await _fadeOut(_weatherPlayer);
    await _fadeOut(_nightPlayer);

    if (_muted) return;

    // Start new layers
    await _ambientPlayer.play(AssetSource(_ambientAsset(theme.season)));
    await _weatherPlayer.play(AssetSource(_weatherAsset(theme)));
    await _nightPlayer.play(AssetSource(_nightAsset(theme.season)));

    await _fadeIn(_ambientPlayer, _ambientVolume(theme));
    await _fadeIn(_weatherPlayer, _calmMode ? 0.0 : 0.22);
    await _fadeIn(_nightPlayer,   _calmMode ? 0.0 : 0.18);
  }

  // ─────────────────────────────────────────────────────────────
  // PARALLAX UPDATE — called every frame from scene
  // ─────────────────────────────────────────────────────────────

  void onParallaxUpdate(double parallaxX) {
    _parallaxX = parallaxX;
    _applyVolumes();
  }

  void _applyVolumes() {
    if (_muted) return;
    // Slight spatial bias — right-leaning parallax nudges
    // right-family (giraffe) ambient slightly louder and vice versa.
    // Effect is subtle — ±8% volume shift max.
    final bias = (_parallaxX * 0.08).clamp(-0.08, 0.08);
    final base = _masterVolume * (_calmMode ? 0.55 : 1.0);
    _ambientPlayer.setVolume((base - bias.abs() * 0.5).clamp(0, 1));
  }

  // ─────────────────────────────────────────────────────────────
  // CHARACTER SFX — called by scene when motion state fires
  // ─────────────────────────────────────────────────────────────

  Future<void> onCharacterEvent(String character) async {
    if (_muted || _calmMode) return;

    final asset = _characterSfxAsset(character);
    if (asset == null) return;

    // Cooldown check
    final last = _lastSfx[character];
    if (last != null && DateTime.now().difference(last) < _sfxCooldown) return;
    _lastSfx[character] = DateTime.now();

    final player = _sfxPool[_sfxIndex % _sfxPool.length];
    _sfxIndex++;

    // Spatial volume: character on left side louder when parallax left
    final isLeftFamily = ['chicken_lips', 'daughter_9', 'daughter_7', 'teds'].contains(character);
    final spatialVol = isLeftFamily
        ? (0.55 - _parallaxX * 0.15).clamp(0.1, 0.7)
        : (0.55 + _parallaxX * 0.15).clamp(0.1, 0.7);

    await player.setVolume(spatialVol * _masterVolume);
    await player.play(AssetSource(asset));
  }

  // ─────────────────────────────────────────────────────────────
  // SCENE EVENTS (gate open, firefly peak, season change, etc.)
  // ─────────────────────────────────────────────────────────────

  Future<void> onSceneEvent(FabSceneEvent event) async {
    if (_muted) return;
    final asset = _sceneEventAsset(event);
    if (asset == null) return;

    final player = _sfxPool[_sfxIndex % _sfxPool.length];
    _sfxIndex++;
    await player.setVolume(0.40 * _masterVolume);
    await player.play(AssetSource(asset));
  }

  // ─────────────────────────────────────────────────────────────
  // CONTROLS
  // ─────────────────────────────────────────────────────────────

  Future<void> setMuted(bool muted) async {
    _muted = muted;
    if (muted) {
      await _ambientPlayer.setVolume(0);
      await _weatherPlayer.setVolume(0);
      await _nightPlayer.setVolume(0);
    } else {
      _applyVolumes();
    }
  }

  Future<void> setCalmMode(bool calm) async {
    _calmMode = calm;
    if (calm) {
      await _fadeOut(_weatherPlayer);
      await _fadeOut(_nightPlayer);
      await _ambientPlayer.setVolume(_masterVolume * 0.45);
    } else {
      await _weatherPlayer.setVolume(0.22);
      await _nightPlayer.setVolume(0.18);
      _applyVolumes();
    }
  }

  void setMasterVolume(double v) {
    _masterVolume = v.clamp(0.0, 1.0);
    _applyVolumes();
  }

  bool get isMuted => _muted;
  bool get isCalmMode => _calmMode;
  double get masterVolume => _masterVolume;

  // ─────────────────────────────────────────────────────────────
  // DISPOSE
  // ─────────────────────────────────────────────────────────────

  Future<void> dispose() async {
    await _ambientPlayer.dispose();
    await _weatherPlayer.dispose();
    await _nightPlayer.dispose();
    for (final p in _sfxPool) {
      await p.dispose();
    }
  }

  // ─────────────────────────────────────────────────────────────
  // ASSET MAPPING
  // ─────────────────────────────────────────────────────────────

  String _ambientAsset(FabSeason season) {
    switch (season) {
      case FabSeason.spring: return 'audio/ambient_spring.mp3';
      case FabSeason.summer: return 'audio/ambient_summer.mp3';
      case FabSeason.autumn: return 'audio/ambient_autumn.mp3';
      case FabSeason.winter: return 'audio/ambient_winter.mp3';
    }
  }

  String _weatherAsset(FabWorldTheme theme) {
    switch (theme.weather) {
      case FabWeather.rain:  return 'audio/weather_rain.mp3';
      case FabWeather.snow:  return 'audio/weather_snow_hush.mp3';
      case FabWeather.windy: return 'audio/weather_wind.mp3';
      case FabWeather.clear: return 'audio/ambient_silence.mp3'; // silent loop
    }
  }

  String _nightAsset(FabSeason season) {
    switch (season) {
      case FabSeason.spring: return 'audio/night_spring.mp3';   // light crickets + owl
      case FabSeason.summer: return 'audio/night_summer.mp3';   // loud crickets + cicadas
      case FabSeason.autumn: return 'audio/night_autumn.mp3';   // wind + branch creak
      case FabSeason.winter: return 'audio/night_winter.mp3';   // deep silence + wind moan
    }
  }

  double _ambientVolume(FabWorldTheme theme) {
    // Winter ambient is quieter — the silence IS the effect
    if (theme.season == FabSeason.winter) return _masterVolume * 0.50;
    return _masterVolume * 0.72;
  }

  String? _characterSfxAsset(String character) {
    switch (character) {
      case 'chicken_lips':  return 'audio/sfx_cluck_soft.mp3';
      case 'daughter_9':    return 'audio/sfx_giggle.mp3';
      case 'daughter_7':    return 'audio/sfx_giggle_small.mp3';
      case 'teds':          return 'audio/sfx_shih_tzu_snuffle.mp3';
      case 'cat1':          return 'audio/sfx_purr.mp3';
      case 'cat2':          return 'audio/sfx_purr.mp3';
      case 'jack_russell':  return 'audio/sfx_bark_excite.mp3';
      case 'son_giraffe_1': return 'audio/sfx_giraffe_hum.mp3';
      case 'son_giraffe_2': return 'audio/sfx_giraffe_hum.mp3';
      case 'dad_giraffe':   return 'audio/sfx_giraffe_low.mp3';
      default:              return null;
    }
  }

  String? _sceneEventAsset(FabSceneEvent event) {
    switch (event) {
      case FabSceneEvent.gateMeeting:    return 'audio/sfx_gate_creak.mp3';
      case FabSceneEvent.fireflyPeak:    return 'audio/sfx_firefly_shimmer.mp3';
      case FabSceneEvent.firstSnowflake: return 'audio/sfx_first_snow.mp3';
      case FabSceneEvent.christmasLights:return 'audio/sfx_jingle_soft.mp3';
      case FabSceneEvent.autumnLeaf:     return 'audio/sfx_leaf_rustle.mp3';
      case FabSceneEvent.butterfly:      return 'audio/sfx_butterfly_flutter.mp3';
    }
  }

  // ─────────────────────────────────────────────────────────────
  // FADE HELPERS
  // ─────────────────────────────────────────────────────────────

  Future<void> _fadeOut(AudioPlayer player, {int steps = 12}) async {
    final cur = await player.getCurrentVolume() ?? 0.3;
    for (int i = steps; i >= 0; i--) {
      await player.setVolume(cur * i / steps);
      await Future.delayed(const Duration(milliseconds: 60));
    }
    await player.stop();
  }

  Future<void> _fadeIn(AudioPlayer player, double target, {int steps = 16}) async {
    for (int i = 1; i <= steps; i++) {
      await player.setVolume(target * i / steps);
      await Future.delayed(const Duration(milliseconds: 60));
    }
  }
}

// ─────────────────────────────────────────────────────────────
// EXTENSION on AudioPlayer — getCurrentVolume convenience
// ─────────────────────────────────────────────────────────────
extension _AudioPlayerVolume on AudioPlayer {
  Future<double?> getCurrentVolume() async => null; // placeholder; track manually if needed
}

// ─────────────────────────────────────────────────────────────
// SCENE EVENTS ENUM
// ─────────────────────────────────────────────────────────────
enum FabSceneEvent {
  gateMeeting,
  fireflyPeak,
  firstSnowflake,
  christmasLights,
  autumnLeaf,
  butterfly,
}

// ─────────────────────────────────────────────────────────────
// MUTE BUTTON WIDGET
// Sits in the AppBar next to the Feeling Fab badge.
// ─────────────────────────────────────────────────────────────
class FabMuteButton extends StatefulWidget {
  final FabWorldAudio audio;

  const FabMuteButton({super.key, required this.audio});

  @override
  State<FabMuteButton> createState() => _FabMuteButtonState();
}

class _FabMuteButtonState extends State<FabMuteButton> {
  @override
  Widget build(BuildContext context) {
    final muted = widget.audio.isMuted;
    return GestureDetector(
      onTap: () async {
        await widget.audio.setMuted(!muted);
        setState(() {});
      },
      onLongPress: () async {
        // Long press toggles calm mode
        await widget.audio.setCalmMode(!widget.audio.isCalmMode);
        setState(() {});
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.audio.isCalmMode ? '🌙 Calm mode on' : '🎵 Full sound on',
              style: const TextStyle(fontFamily: 'DM Sans'),
            ),
            duration: const Duration(seconds: 2),
            backgroundColor: const Color(0xFF2D1B69),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: const Color(0xFF2D1B69).withValues(alpha: 0.70),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: widget.audio.isCalmMode
                ? const Color(0xFF88CCFF).withValues(alpha: 0.60)
                : const Color(0xFF6C63FF).withValues(alpha: 0.40),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              muted
                  ? Icons.volume_off_rounded
                  : widget.audio.isCalmMode
                      ? Icons.bedtime_rounded
                      : Icons.volume_up_rounded,
              color: muted
                  ? Colors.white38
                  : widget.audio.isCalmMode
                      ? const Color(0xFF88CCFF)
                      : const Color(0xFF6C63FF),
              size: 15,
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// VOLUME SLIDER — shown in a bottom sheet from settings
// ─────────────────────────────────────────────────────────────
class FabVolumeSheet extends StatefulWidget {
  final FabWorldAudio audio;
  const FabVolumeSheet({super.key, required this.audio});

  @override
  State<FabVolumeSheet> createState() => _FabVolumeSheetState();
}

class _FabVolumeSheetState extends State<FabVolumeSheet> {
  late double _vol;

  @override
  void initState() {
    super.initState();
    _vol = widget.audio.masterVolume;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      decoration: const BoxDecoration(
        color: Color(0xFF1A1040),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'World Sounds',
            style: TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.w600,
              fontFamily: 'DM Sans',
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(Icons.volume_mute_rounded, color: Colors.white38, size: 18),
              Expanded(
                child: SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: const Color(0xFF6C63FF),
                    inactiveTrackColor: Colors.white12,
                    thumbColor: const Color(0xFF6C63FF),
                    overlayColor: const Color(0xFF6C63FF).withValues(alpha: 0.20),
                    trackHeight: 3,
                    thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
                  ),
                  child: Slider(
                    value: _vol,
                    min: 0,
                    max: 1,
                    onChanged: (v) {
                      setState(() => _vol = v);
                      widget.audio.setMasterVolume(v);
                    },
                  ),
                ),
              ),
              const Icon(Icons.volume_up_rounded, color: Colors.white38, size: 18),
            ],
          ),
          const SizedBox(height: 8),
          _toggleRow(
            icon: Icons.volume_off_rounded,
            label: 'Mute all sounds',
            value: widget.audio.isMuted,
            onChanged: (v) async {
              await widget.audio.setMuted(v);
              setState(() {});
            },
          ),
          const SizedBox(height: 4),
          _toggleRow(
            icon: Icons.bedtime_rounded,
            label: 'Calm mode (ambient only)',
            value: widget.audio.isCalmMode,
            color: const Color(0xFF88CCFF),
            onChanged: (v) async {
              await widget.audio.setCalmMode(v);
              setState(() {});
            },
          ),
        ],
      ),
    );
  }

  Widget _toggleRow({
    required IconData icon,
    required String label,
    required bool value,
    required ValueChanged<bool> onChanged,
    Color color = const Color(0xFF6C63FF),
  }) {
    return Row(
      children: [
        Icon(icon, color: color.withValues(alpha: 0.70), size: 17),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
              fontFamily: 'DM Sans',
            ),
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: color,
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
      ],
    );
  }
}
