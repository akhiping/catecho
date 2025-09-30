import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/audio/recorder_service.dart';

// Recorder service provider
final recorderServiceProvider = Provider<RecorderService>((ref) {
  final service = RecorderService();
  ref.onDispose(() => service.dispose());
  return service;
});

// Recording state stream provider
final recordingStateStreamProvider = StreamProvider<RecordingState>((ref) {
  final service = ref.watch(recorderServiceProvider);
  return service.stateStream;
});

// Amplitude stream provider
final amplitudeStreamProvider = StreamProvider<double>((ref) {
  final service = ref.watch(recorderServiceProvider);
  return service.amplitudeStream;
});

// Duration stream provider
final durationStreamProvider = StreamProvider<int>((ref) {
  final service = ref.watch(recorderServiceProvider);
  return service.durationStream;
});

// Recording provider
final recordingProvider = StateNotifierProvider<RecordingNotifier, RecordingProviderState>((ref) {
  return RecordingNotifier(ref.read(recorderServiceProvider));
});

class RecordingProviderState {
  final RecordingState recordingState;
  final double amplitude;
  final int durationMs;
  final bool hasPermission;
  final String? error;
  final RecordingResult? lastResult;

  const RecordingProviderState({
    this.recordingState = RecordingState.idle,
    this.amplitude = 0.0,
    this.durationMs = 0,
    this.hasPermission = false,
    this.error,
    this.lastResult,
  });

  RecordingProviderState copyWith({
    RecordingState? recordingState,
    double? amplitude,
    int? durationMs,
    bool? hasPermission,
    String? error,
    RecordingResult? lastResult,
  }) {
    return RecordingProviderState(
      recordingState: recordingState ?? this.recordingState,
      amplitude: amplitude ?? this.amplitude,
      durationMs: durationMs ?? this.durationMs,
      hasPermission: hasPermission ?? this.hasPermission,
      error: error,
      lastResult: lastResult ?? this.lastResult,
    );
  }

  bool get isRecording => recordingState == RecordingState.recording;
  bool get isPaused => recordingState == RecordingState.paused;
  bool get isIdle => recordingState == RecordingState.idle;
  bool get canRecord => hasPermission && isIdle;
}

class RecordingNotifier extends StateNotifier<RecordingProviderState> {
  final RecorderService _service;

  RecordingNotifier(this._service) : super(const RecordingProviderState()) {
    _initialize();
  }

  Future<void> _initialize() async {
    // Check permissions
    final hasPermission = await _service.hasPermission();
    state = state.copyWith(hasPermission: hasPermission);

    // Listen to streams
    _service.stateStream.listen((recordingState) {
      state = state.copyWith(recordingState: recordingState);
    });

    _service.amplitudeStream.listen((amplitude) {
      state = state.copyWith(amplitude: amplitude);
    });

    _service.durationStream.listen((durationMs) {
      state = state.copyWith(durationMs: durationMs);
    });
  }

  Future<bool> requestPermissions() async {
    try {
      final hasPermission = await _service.requestPermissions();
      state = state.copyWith(hasPermission: hasPermission);
      return hasPermission;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  Future<bool> startRecording() async {
    if (!state.canRecord) {
      if (!state.hasPermission) {
        final granted = await requestPermissions();
        if (!granted) return false;
      } else {
        return false;
      }
    }

    try {
      final success = await _service.startRecording();
      if (!success) {
        state = state.copyWith(error: 'Failed to start recording');
      } else {
        state = state.copyWith(error: null);
      }
      return success;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  Future<RecordingResult?> stopRecording() async {
    if (!state.isRecording) return null;

    try {
      final result = await _service.stopRecording();
      state = state.copyWith(
        lastResult: result,
        error: result.success ? null : result.error,
      );
      return result;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return null;
    }
  }

  Future<void> pauseRecording() async {
    if (!state.isRecording) return;

    try {
      await _service.pauseRecording();
      state = state.copyWith(error: null);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> resumeRecording() async {
    if (!state.isPaused) return;

    try {
      await _service.resumeRecording();
      state = state.copyWith(error: null);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
} 