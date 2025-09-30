import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

enum RecordingState {
  idle,
  recording,
  paused,
  stopped,
}

class RecordingResult {
  final String? filePath;
  final int durationMs;
  final bool success;
  final String? error;

  RecordingResult({
    this.filePath,
    required this.durationMs,
    required this.success,
    this.error,
  });
}

class RecorderService {
  final AudioRecorder _recorder = AudioRecorder();
  
  RecordingState _state = RecordingState.idle;
  DateTime? _recordingStartTime;
  Timer? _amplitudeTimer;
  Timer? _durationTimer;
  
  // Mock mode for web/testing
  final bool _useMockMode = kIsWeb; // Automatically use mock on web
  String? _mockFilePath;
  
  final StreamController<RecordingState> _stateController = StreamController<RecordingState>.broadcast();
  final StreamController<double> _amplitudeController = StreamController<double>.broadcast();
  final StreamController<int> _durationController = StreamController<int>.broadcast();

  Stream<RecordingState> get stateStream => _stateController.stream;
  Stream<double> get amplitudeStream => _amplitudeController.stream;
  Stream<int> get durationStream => _durationController.stream;

  RecordingState get state => _state;

  Future<bool> requestPermissions() async {
    // Mock mode always grants permission
    if (_useMockMode) return true;
    
    final status = await Permission.microphone.request();
    return status == PermissionStatus.granted;
  }

  Future<bool> hasPermission() async {
    // Mock mode always has permission
    if (_useMockMode) return true;
    
    final status = await Permission.microphone.status;
    return status == PermissionStatus.granted;
  }

  Future<bool> startRecording() async {
    if (_state != RecordingState.idle) return false;

    // Mock mode for web/testing
    if (_useMockMode) {
      _recordingStartTime = DateTime.now();
      _mockFilePath = 'mock_recording_${DateTime.now().millisecondsSinceEpoch}.m4a';
      _setState(RecordingState.recording);
      _startAmplitudeMonitoring();
      _startDurationMonitoring();
      return true;
    }

    final hasPermission = await requestPermissions();
    if (!hasPermission) return false;

    try {
      final directory = await getApplicationDocumentsDirectory();
      final fileName = 'recording_${DateTime.now().millisecondsSinceEpoch}.m4a';
      final filePath = '${directory.path}/$fileName';

      await _recorder.start(
        const RecordConfig(
          encoder: AudioEncoder.aacLc,
          bitRate: 128000,
          sampleRate: 44100,
        ),
        path: filePath,
      );

      _recordingStartTime = DateTime.now();
      _setState(RecordingState.recording);
      _startAmplitudeMonitoring();
      _startDurationMonitoring();

      return true;
    } catch (e) {
      return false;
    }
  }

  Future<RecordingResult> stopRecording() async {
    if (_state != RecordingState.recording) {
      return RecordingResult(
        durationMs: 0,
        success: false,
        error: 'Not currently recording',
      );
    }

    try {
      String? filePath;
      
      // Mock mode for web/testing
      if (_useMockMode) {
        filePath = _mockFilePath;
        _stopMonitoring();
      } else {
        filePath = await _recorder.stop();
        _stopMonitoring();
      }
      
      final duration = _recordingStartTime != null 
          ? DateTime.now().difference(_recordingStartTime!).inMilliseconds
          : 0;

      _setState(RecordingState.stopped);
      _recordingStartTime = null;

      return RecordingResult(
        filePath: filePath,
        durationMs: duration,
        success: true,
      );
    } catch (e) {
      _stopMonitoring();
      _setState(RecordingState.idle);
      
      return RecordingResult(
        durationMs: 0,
        success: false,
        error: e.toString(),
      );
    }
  }

  Future<void> pauseRecording() async {
    if (_state != RecordingState.recording) return;

    try {
      if (!_useMockMode) {
        await _recorder.pause();
      }
      _setState(RecordingState.paused);
      _stopMonitoring();
    } catch (e) {
      // Handle error
    }
  }

  Future<void> resumeRecording() async {
    if (_state != RecordingState.paused) return;

    try {
      if (!_useMockMode) {
        await _recorder.resume();
      }
      _setState(RecordingState.recording);
      _startAmplitudeMonitoring();
      _startDurationMonitoring();
    } catch (e) {
      // Handle error
    }
  }

  void _setState(RecordingState newState) {
    _state = newState;
    _stateController.add(_state);
  }

  void _startAmplitudeMonitoring() {
    final random = Random();
    _amplitudeTimer = Timer.periodic(Duration(milliseconds: 100), (timer) async {
      if (_state == RecordingState.recording) {
        try {
          // Mock mode generates realistic waveform
          if (_useMockMode) {
            final mockAmplitude = 0.3 + (random.nextDouble() * 0.5); // 0.3-0.8 range
            _amplitudeController.add(mockAmplitude);
          } else {
            final amplitude = await _recorder.getAmplitude();
            final normalizedAmplitude = amplitude.current.clamp(-80.0, 0.0);
            final scaledAmplitude = (normalizedAmplitude + 80) / 80; // Scale to 0-1
            _amplitudeController.add(scaledAmplitude);
          }
        } catch (e) {
          _amplitudeController.add(0.0);
        }
      }
    });
  }

  void _startDurationMonitoring() {
    _durationTimer = Timer.periodic(Duration(milliseconds: 100), (timer) {
      if (_state != RecordingState.recording) {
        timer.cancel();
        return;
      }
      
      if (_recordingStartTime != null) {
        final duration = DateTime.now().difference(_recordingStartTime!).inMilliseconds;
        _durationController.add(duration);
        
        // Auto-stop at 60 seconds
        if (duration >= 60000) {
          stopRecording();
          timer.cancel();
        }
      }
    });
  }

  void _stopMonitoring() {
    _amplitudeTimer?.cancel();
    _amplitudeTimer = null;
    _durationTimer?.cancel();
    _durationTimer = null;
  }

  void dispose() {
    if (!_useMockMode) {
      _recorder.dispose();
    }
    _amplitudeTimer?.cancel();
    _durationTimer?.cancel();
    _stateController.close();
    _amplitudeController.close();
    _durationController.close();
  }
} 