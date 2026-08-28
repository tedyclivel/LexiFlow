// ignore_for_file: avoid_print
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// LexiFlow Sound Service
/// - ONE dedicated AudioPlayer for ambient music
/// - A small pool for short SFX
/// - Strict context ownership: each screen tells the service what to play
class SoundService {
  // ── Private State ───────────────────────────────────────────────────────────
  static final AudioPlayer _ambientPlayer = AudioPlayer();
  static final List<AudioPlayer> _sfxPool = List.generate(6, (_) => AudioPlayer());
  static int _sfxIndex = 0;

  static bool _musicEnabled = true;
  static bool _sfxEnabled = true;
  static double _musicVolume = 0.6;
  static double _sfxVolume = 0.8;

  // Track currently playing ambient to avoid redundant restarts
  static String? _currentAmbient;
  static bool _initialized = false;

  // ── Asset Paths ─────────────────────────────────────────────────────────────
  static const _hubAmbient    = 'sounds/hub_ambient.wav';
  static const _gridAmbient   = 'sounds/grid_ambient.wav';
  static const _blitzAmbient  = 'sounds/blitz_ambient.wav';
  static const _chaosAmbient  = 'sounds/chaos_ambient.wav';

  static const _click       = 'sounds/click.wav';
  static const _navigation  = 'sounds/navigation.wav';
  static const _wordFound   = 'sounds/word_found.wav';
  static const _error       = 'sounds/error.wav';
  static const _success     = 'sounds/success.wav';
  static const _coin        = 'sounds/coin_collect.wav';
  static const _letter      = 'sounds/letter_select.wav';
  static const _back        = 'sounds/back.wav';
  static const _hint        = 'sounds/hint.wav';
  static const _timerTick   = 'sounds/timer_tick.wav';

  // ── Initialization ──────────────────────────────────────────────────────────
  static Future<void> init() async {
    if (_initialized) return;
    _initialized = true;
    try {
      final prefs = await SharedPreferences.getInstance();
      _musicEnabled = prefs.getBool('music_enabled') ?? true;
      _sfxEnabled   = prefs.getBool('sfx_enabled') ?? true;
      _musicVolume  = prefs.getDouble('music_volume') ?? 0.6;
      _sfxVolume    = prefs.getDouble('sfx_volume') ?? 0.8;

      // Configure ambient player: loop forever, low-latency
      await _ambientPlayer.setReleaseMode(ReleaseMode.loop);
      await _ambientPlayer.setVolume(_musicEnabled ? _musicVolume : 0.0);

      // Configure SFX pool
      for (final p in _sfxPool) {
        await p.setReleaseMode(ReleaseMode.release);
        await p.setVolume(_sfxEnabled ? _sfxVolume : 0.0);
      }
      debugPrint('[SoundService] Initialized OK');
    } catch (e) {
      debugPrint('[SoundService] Init error: $e');
    }
  }

  // ── Public Getters ──────────────────────────────────────────────────────────
  static bool get musicEnabled => _musicEnabled;
  static bool get sfxEnabled   => _sfxEnabled;
  static double get musicVolume => _musicVolume;
  static double get sfxVolume  => _sfxVolume;

  // ── Ambient Music API ───────────────────────────────────────────────────────

  /// Play hub ambient (Auth screen, Main Menu, all Hub screens)
  static Future<void> playHubAmbient() async => _playAmbient(_hubAmbient);

  /// Play grid ambient (Solo / Multiplayer classic grids)
  static Future<void> playGridAmbient() async => _playAmbient(_gridAmbient);

  /// Play blitz ambient (Blitz mode grids)
  static Future<void> playBlitzAmbient() async => _playAmbient(_blitzAmbient);

  /// Play chaos ambient (Chaos mode grids)
  static Future<void> playChaosAmbient() async => _playAmbient(_chaosAmbient);

  /// Immediately stop ALL audio — call this on every screen exit before switching context
  static Future<void> stopAll() async {
    _currentAmbient = null;
    await _ambientPlayer.stop();
    for (final p in _sfxPool) {
      try { await p.stop(); } catch (_) {}
    }
    debugPrint('[SoundService] stopAll() called');
  }

  /// Stop only ambient music (keeps SFX running)
  static Future<void> stopAmbient() async {
    _currentAmbient = null;
    await _ambientPlayer.stop();
  }

  // ── SFX API ─────────────────────────────────────────────────────────────────
  static void playClick()        => _playSfx(_click);
  static void playNavigation()   => _playSfx(_navigation);
  static void playWordFound()    => _playSfx(_wordFound);
  static void playError()        => _playSfx(_error);
  static void playSuccess()      => _playSfx(_success);
  static void playCoinCollect()  => _playSfx(_coin);
  static void playLetterSelect({double pitch = 1.0}) => _playSfx(_letter, pitch: pitch);
  static void playBack()         => _playSfx(_back);
  static void playHint()         => _playSfx(_hint);
  static void playTimerTick()    => _playSfx(_timerTick);

  // ── Settings persistence ────────────────────────────────────────────────────
  static Future<void> toggleMusic() async {
    _musicEnabled = !_musicEnabled;
    await _ambientPlayer.setVolume(_musicEnabled ? _musicVolume : 0.0);
    if (!_musicEnabled) await _ambientPlayer.stop();
    else if (_currentAmbient != null) await _playAmbient(_currentAmbient!);
    final p = await SharedPreferences.getInstance();
    await p.setBool('music_enabled', _musicEnabled);
  }

  static Future<void> toggleSfx() async {
    _sfxEnabled = !_sfxEnabled;
    final vol = _sfxEnabled ? _sfxVolume : 0.0;
    for (final p in _sfxPool) { await p.setVolume(vol); }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('sfx_enabled', _sfxEnabled);
  }

  static Future<void> setMusicVolume(double v) async {
    _musicVolume = v.clamp(0.0, 1.0);
    await _ambientPlayer.setVolume(_musicEnabled ? _musicVolume : 0.0);
    final p = await SharedPreferences.getInstance();
    await p.setDouble('music_volume', _musicVolume);
  }

  static Future<void> setSfxVolume(double v) async {
    _sfxVolume = v.clamp(0.0, 1.0);
    final vol = _sfxEnabled ? _sfxVolume : 0.0;
    for (final p in _sfxPool) { await p.setVolume(vol); }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('sfx_volume', _sfxVolume);
  }

  // ── Private helpers ─────────────────────────────────────────────────────────
  static Future<void> _playAmbient(String path) async {
    if (!_musicEnabled) return;
    // Skip if already playing the same track
    if (_currentAmbient == path &&
        _ambientPlayer.state == PlayerState.playing) return;
    try {
      _currentAmbient = path;
      await _ambientPlayer.stop();
      await _ambientPlayer.setVolume(_musicVolume);
      await _ambientPlayer.play(AssetSource(path));
      debugPrint('[SoundService] Playing ambient: $path');
    } catch (e) {
      debugPrint('[SoundService] Ambient error ($path): $e');
      _currentAmbient = null;
    }
  }

  static Future<void> _playSfx(String path, {double pitch = 1.0}) async {
    if (!_sfxEnabled) return;
    try {
      final player = _sfxPool[_sfxIndex % _sfxPool.length];
      _sfxIndex++;
      await player.stop();
      await player.setVolume(_sfxVolume);
      await player.setPlaybackRate(pitch);
      await player.play(AssetSource(path));
    } catch (e) {
      debugPrint('[SoundService] SFX error ($path): $e');
    }
  }

  // ── Legacy aliases (to avoid breaking existing call-sites) ──────────────────
  static void startAmbientMusic()   => playHubAmbient();
  static void startHubAmbient()     => playHubAmbient();
  static void startGridAmbient()    => playGridAmbient();
  static void startBlitzAmbient()   => playBlitzAmbient();
  static void startChaosAmbient()   => playChaosAmbient();
  static void stopAmbientMusic()    => stopAmbient();
  static void stopAllScreenSounds() => stopAll();
  static void stopEverything()      => stopAll();
  static void stopTimerTick()       {}  // no-op: tick is a one-shot SFX now

  // Gameplay SFX aliases
  static void playVictory()    => playSuccess();
  static void playValidation() => playWordFound();
  static void playReward()     => playCoinCollect();
  static void playFeverStart() => playSuccess();
  static void playThaw()       => playClick();

  /// playLetterSelect with optional ignored pitch param
  static void playLetterSelectWithPitch({double pitch = 1.0}) => playLetterSelect();

  /// vibrateSelection: haptic feedback (ignored if vibration not available)
  static void vibrateSelection(int length) {
    // Vibration is handled by HapticService; just play a tick sound here
    _playSfx(_letter);
  }
}
