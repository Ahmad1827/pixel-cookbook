import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

class AudioService extends ChangeNotifier with WidgetsBindingObserver {
  final AudioPlayer _bgmPlayer = AudioPlayer();
  final AudioPlayer _sfxPlayer = AudioPlayer();
  bool _isMuted = false;

  AudioService() {
    WidgetsBinding.instance.addObserver(this);
    _init();
  }

  bool get isMuted => _isMuted;

  Future<void> _init() async {
    await _bgmPlayer.setReleaseMode(ReleaseMode.loop);
    await _sfxPlayer.setReleaseMode(ReleaseMode.release);
    _playBgm();
  }

  void _playBgm() {
    if (!_isMuted) {
      _bgmPlayer.setVolume(0.4);
      _bgmPlayer.play(AssetSource('audio/tavern_bgm.mp3'));
    }
  }

  void playCutSound() {
    if (!_isMuted) {
      // Plays the quick knife sound!
      _sfxPlayer.play(AssetSource('audio/cut.mp3'), volume: 1.0);
    }
  }

  void toggleMute() {
    _isMuted = !_isMuted;
    if (_isMuted) {
      _bgmPlayer.pause();
    } else {
      _playBgm();
    }
    notifyListeners();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused || 
        state == AppLifecycleState.inactive || 
        state == AppLifecycleState.hidden) {
      _bgmPlayer.pause(); // Stops music when app is minimized!
    } else if (state == AppLifecycleState.resumed) {
      if (!_isMuted) {
        _bgmPlayer.resume(); // Starts back up when opened
      }
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _bgmPlayer.dispose();
    _sfxPlayer.dispose();
    super.dispose();
  }
}