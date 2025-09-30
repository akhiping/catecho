import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:ui';

import '../../providers/recording_provider.dart';
import '../../providers/entries_provider.dart';
import '../../providers/daily_quota_provider.dart';
import '../../routing/router.dart';
import '../../theme/theme.dart';
import '../../services/audio/recorder_service.dart';

class RecorderScreen extends ConsumerStatefulWidget {
  const RecorderScreen({super.key});

  @override
  ConsumerState<RecorderScreen> createState() => _RecorderScreenState();
}

class _RecorderScreenState extends ConsumerState<RecorderScreen>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _waveController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _waveController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _waveController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final recordingState = ref.watch(recordingProvider);
    final quotaState = ref.watch(dailyQuotaProvider);

    // Start/stop pulse animation based on recording state
    if (recordingState.isRecording && !_pulseController.isAnimating) {
      _pulseController.repeat(reverse: true);
    } else if (!recordingState.isRecording && _pulseController.isAnimating) {
      _pulseController.stop();
      _pulseController.reset();
    }

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Record Entry'),
        leading: IconButton(
          onPressed: () => AppRouter.pop(context),
          icon: const Icon(Icons.close),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.spacing6),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Recording status
              _buildRecordingStatus(context, recordingState),
              const SizedBox(height: AppTheme.spacing8),
              
              // Waveform visualization
              _buildWaveform(context, recordingState),
              const SizedBox(height: AppTheme.spacing8),
              
              // Timer
              _buildTimer(context, recordingState),
              const SizedBox(height: AppTheme.spacing12),
              
              // Record button
              _buildRecordButton(context, recordingState, quotaState),
              const SizedBox(height: AppTheme.spacing8),
              
              // Instructions
              _buildInstructions(context, recordingState),
              
              if (recordingState.error != null) ...[
                const SizedBox(height: AppTheme.spacing4),
                _buildError(context, recordingState.error!),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecordingStatus(BuildContext context, RecordingProviderState state) {
    String statusText;
    Color statusColor;
    
    switch (state.recordingState) {
      case RecordingState.recording:
        statusText = 'Recording...';
        statusColor = AppTheme.error;
        break;
      case RecordingState.paused:
        statusText = 'Paused';
        statusColor = AppTheme.warning;
        break;
      case RecordingState.stopped:
        statusText = 'Recording Complete';
        statusColor = AppTheme.success;
        break;
      default:
        statusText = 'Ready to Record';
        statusColor = Theme.of(context).textTheme.bodyMedium?.color ?? Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacing4,
        vertical: AppTheme.spacing2,
      ),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
      ),
      child: Text(
        statusText,
        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
          color: statusColor,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildWaveform(BuildContext context, RecordingProviderState state) {
    return Container(
      height: 100,
      width: double.infinity,
      padding: const EdgeInsets.all(AppTheme.spacing4),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        boxShadow: AppTheme.lightShadow,
      ),
      child: state.isRecording
          ? _buildLiveWaveform(context, state.amplitude)
          : _buildStaticWaveform(context),
    );
  }

  Widget _buildLiveWaveform(BuildContext context, double amplitude) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: List.generate(20, (index) {
        final height = (amplitude * 60 + 10).clamp(10.0, 70.0);
        return AnimatedContainer(
          duration: const Duration(milliseconds: 100),
          width: 3,
          height: height,
          decoration: BoxDecoration(
            gradient: AppTheme.primaryGradient,
            borderRadius: BorderRadius.circular(2),
          ),
        );
      }),
    );
  }

  Widget _buildStaticWaveform(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: List.generate(20, (index) {
        return Container(
          width: 3,
          height: 20,
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor.withOpacity(0.3),
            borderRadius: BorderRadius.circular(2),
          ),
        );
      }),
    );
  }

  Widget _buildTimer(BuildContext context, RecordingProviderState state) {
    final duration = Duration(milliseconds: state.durationMs);
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    
    return Text(
      '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}',
      style: Theme.of(context).textTheme.displayLarge?.copyWith(
        fontWeight: FontWeight.w300,
        fontFeatures: [const FontFeature.tabularFigures()],
      ),
    );
  }

  Widget _buildRecordButton(
    BuildContext context,
    RecordingProviderState recordingState,
    DailyQuotaState quotaState,
  ) {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: recordingState.isRecording ? _pulseAnimation.value : 1.0,
          child: GestureDetector(
            onTap: () => _handleRecordButtonTap(recordingState, quotaState),
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: recordingState.isRecording
                    ? LinearGradient(
                        colors: [AppTheme.error, AppTheme.error.withOpacity(0.8)],
                      )
                    : AppTheme.primaryGradient,
                boxShadow: [
                  BoxShadow(
                    color: (recordingState.isRecording ? AppTheme.error : AppTheme.primaryPurple)
                        .withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Icon(
                recordingState.isRecording ? Icons.stop : Icons.mic,
                color: Colors.white,
                size: 48,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildInstructions(BuildContext context, RecordingProviderState state) {
    String instruction;
    
    switch (state.recordingState) {
      case RecordingState.recording:
        instruction = 'Tap the button to stop recording';
        break;
      case RecordingState.paused:
        instruction = 'Tap to resume recording';
        break;
      default:
        instruction = 'Tap the microphone to start recording';
    }

    return Text(
      instruction,
      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
        color: Theme.of(context).textTheme.bodyMedium?.color,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildError(BuildContext context, String error) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacing4),
      decoration: BoxDecoration(
        color: AppTheme.error.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: AppTheme.error, size: 20),
          const SizedBox(width: AppTheme.spacing2),
          Expanded(
            child: Text(
              error,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.error,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleRecordButtonTap(
    RecordingProviderState recordingState,
    DailyQuotaState quotaState,
  ) async {
    final recordingNotifier = ref.read(recordingProvider.notifier);
    
    if (recordingState.isRecording) {
      // Stop recording
      final result = await recordingNotifier.stopRecording();
      if (result != null && result.success) {
        await _saveEntry(result);
      }
    } else {
      // Check quota before starting
      if (!quotaState.canCreateEntry) {
        AppRouter.goToPaywall(context);
        return;
      }
      
      // Start recording
      await recordingNotifier.startRecording();
    }
  }

  Future<void> _saveEntry(RecordingResult result) async {
    if (result.filePath == null) return;
    
    final entryActions = ref.read(entryActionsProvider);
    final quotaNotifier = ref.read(dailyQuotaProvider.notifier);
    
    try {
      // Create entry
      final entry = await entryActions.createEntry(
        audioPath: result.filePath!,
        durationMs: result.durationMs,
      );
      
      // Update quota
      await quotaNotifier.incrementUsage();
      
      // Process entry in background
      entryActions.processEntry(entry.id);
      
      // Navigate back
      AppRouter.pop(context);
      
      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Entry saved! Processing in background...'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save entry: $e'),
            backgroundColor: AppTheme.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }
} 