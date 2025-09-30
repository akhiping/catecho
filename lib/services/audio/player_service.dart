import 'dart:async';
import 'package:just_audio/just_audio.dart';

enum PlayerState {
  idle,
  loading,
  playing,
  paused,
  stopped,
  error,
}

class PlayerService {
  final AudioPlayer _player = AudioPlayer();
  
  PlayerState _state = PlayerState.idle;
  String? _currentFilePath;
  
  final StreamController<PlayerState> _stateController = StreamController<PlayerState>.broadcast();
  final StreamController<Duration> _positionController = StreamController<Duration>.broadcast();
  final StreamController<Duration?> _durationController = StreamController<Duration?>.broadcast();

  Stream<PlayerState> get stateStream => _stateController.stream;
  Stream<Duration> get positionStream => _positionController.stream;
  Stream<Duration?> get durationStream => _durationController.stream;

  PlayerState get state => _state;
  String? get currentFilePath => _currentFilePath;
  Duration get position => _player.position;
  Duration? get duration => _player.duration;

  PlayerService() {
    _initializePlayer();
  }

  void _initializePlayer() {
    // Listen to player state changes
    _player.playerStateStream.listen((playerState) {
      switch (playerState.processingState) {
        case ProcessingState.idle:
          _setState(PlayerState.idle);
          break;
        case ProcessingState.loading:
        case ProcessingState.buffering:
          _setState(PlayerState.loading);
          break;
        case ProcessingState.ready:
          if (playerState.playing) {
            _setState(PlayerState.playing);
          } else {
            _setState(PlayerState.paused);
          }
          break;
        case ProcessingState.completed:
          _setState(PlayerState.stopped);
          break;
      }
    });

    // Listen to position changes
    _player.positionStream.listen((position) {
      _positionController.add(position);
    });

    // Listen to duration changes
    _player.durationStream.listen((duration) {
      _durationController.add(duration);
    });

    // Handle errors
    _player.playbackEventStream.listen(
      (event) {},
      onError: (Object e, StackTrace stackTrace) {
        _setState(PlayerState.error);
      },
    );
  }

  Future<bool> loadFile(String filePath) async {
    if (_currentFilePath == filePath && _state != PlayerState.idle) {
      return true;
    }

    try {
      _setState(PlayerState.loading);
      await _player.setFilePath(filePath);
      _currentFilePath = filePath;
      return true;
    } catch (e) {
      _setState(PlayerState.error);
      return false;
    }
  }

  Future<void> play([String? filePath]) async {
    if (filePath != null) {
      final loaded = await loadFile(filePath);
      if (!loaded) return;
    }

    if (_state == PlayerState.paused || _state == PlayerState.stopped) {
      await _player.play();
    } else if (_currentFilePath != null) {
      await _player.play();
    }
  }

  Future<void> pause() async {
    if (_state == PlayerState.playing) {
      await _player.pause();
    }
  }

  Future<void> stop() async {
    await _player.stop();
    _setState(PlayerState.stopped);
  }

  Future<void> seek(Duration position) async {
    await _player.seek(position);
  }

  Future<void> setSpeed(double speed) async {
    await _player.setSpeed(speed);
  }

  void _setState(PlayerState newState) {
    _state = newState;
    _stateController.add(_state);
  }

  void dispose() {
    _player.dispose();
    _stateController.close();
    _positionController.close();
    _durationController.close();
  }
} 