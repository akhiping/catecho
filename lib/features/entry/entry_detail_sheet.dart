import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/journal_entry.dart';
import '../../providers/entries_provider.dart';
import '../../routing/router.dart';
import '../../theme/theme.dart';

class EntryDetailSheet extends ConsumerWidget {
  final String entryId;

  const EntryDetailSheet({
    super.key,
    required this.entryId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entries = ref.watch(entriesProvider);
    final entry = entries.firstWhere(
      (e) => e.id == entryId,
      orElse: () => throw StateError('Entry not found'),
    );

    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(AppTheme.radiusLarge),
            ),
          ),
          child: Column(
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.symmetric(vertical: AppTheme.spacing2),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Theme.of(context).dividerColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              
              // Header
              _buildHeader(context, entry),
              
              // Content
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(AppTheme.spacing4),
                  child: _buildContent(context, entry),
                ),
              ),
              
              // Bottom actions
              _buildBottomActions(context, entry),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context, JournalEntry entry) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacing4),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).dividerColor,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.title ?? 'Voice Entry',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: AppTheme.spacing1),
                Text(
                  _formatDate(entry.createdAt),
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => AppRouter.pop(context),
            icon: const Icon(Icons.close),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context, JournalEntry entry) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Processing status
        if (!entry.isProcessed) _buildProcessingIndicator(context),
        
        // Transcript
        if (entry.transcript != null) ...[
          _buildSectionHeader(context, 'Transcript'),
          const SizedBox(height: AppTheme.spacing2),
          _buildTranscriptCard(context, entry.transcript!),
          const SizedBox(height: AppTheme.spacing6),
        ],
        
        // AI Reflection
        if (entry.aiReflection != null) ...[
          _buildSectionHeader(context, 'AI Reflection'),
          const SizedBox(height: AppTheme.spacing2),
          _buildReflectionCard(context, entry.aiReflection!),
          const SizedBox(height: AppTheme.spacing6),
        ],
        
        // Mood
        if (entry.mood != null) ...[
          _buildSectionHeader(context, 'Mood'),
          const SizedBox(height: AppTheme.spacing2),
          _buildMoodChip(context, entry.mood!),
          const SizedBox(height: AppTheme.spacing6),
        ],
        
        // Audio info
        _buildSectionHeader(context, 'Recording'),
        const SizedBox(height: AppTheme.spacing2),
        _buildAudioInfo(context, entry),
      ],
    );
  }

  Widget _buildProcessingIndicator(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppTheme.spacing6),
      padding: const EdgeInsets.all(AppTheme.spacing4),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(
                Theme.of(context).primaryColor,
              ),
            ),
          ),
          const SizedBox(width: AppTheme.spacing3),
          Text(
            'Processing your entry...',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _buildTranscriptCard(BuildContext context, String transcript) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppTheme.spacing4),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        boxShadow: AppTheme.lightShadow,
      ),
      child: Text(
        transcript,
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
          height: 1.6,
        ),
      ),
    );
  }

  Widget _buildReflectionCard(BuildContext context, String reflection) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppTheme.spacing4),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.primaryPurple.withOpacity(0.05),
            AppTheme.primaryTeal.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        border: Border.all(
          color: AppTheme.primaryPurple.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              gradient: AppTheme.primaryGradient,
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Icon(
              Icons.auto_awesome,
              color: Colors.white,
              size: 18,
            ),
          ),
          const SizedBox(width: AppTheme.spacing3),
          Expanded(
            child: Text(
              reflection,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontStyle: FontStyle.italic,
                height: 1.6,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMoodChip(BuildContext context, String mood) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacing4,
        vertical: AppTheme.spacing2,
      ),
      decoration: BoxDecoration(
        color: AppTheme.getMoodColor(mood).withOpacity(0.2),
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: AppTheme.getMoodColor(mood),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: AppTheme.spacing2),
          Text(
            mood,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w600,
              color: AppTheme.getMoodColor(mood).withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAudioInfo(BuildContext context, JournalEntry entry) {
    final duration = Duration(milliseconds: entry.durationMs);
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;

    return Container(
      padding: const EdgeInsets.all(AppTheme.spacing4),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        boxShadow: AppTheme.lightShadow,
      ),
      child: Row(
        children: [
          Icon(
            Icons.audiotrack,
            color: Theme.of(context).primaryColor,
            size: 24,
          ),
          const SizedBox(width: AppTheme.spacing3),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Duration: ${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: AppTheme.spacing1),
              Text(
                'Recorded ${_formatDate(entry.createdAt)}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActions(BuildContext context, JournalEntry entry) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacing4),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        border: Border(
          top: BorderSide(
            color: Theme.of(context).dividerColor,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () {
                // TODO: Implement play functionality
              },
              icon: const Icon(Icons.play_arrow),
              label: const Text('Play'),
            ),
          ),
          const SizedBox(width: AppTheme.spacing3),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () {
                // TODO: Implement edit functionality
              },
              icon: const Icon(Icons.edit),
              label: const Text('Edit'),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today at ${_formatTime(date)}';
    } else if (difference.inDays == 1) {
      return 'Yesterday at ${_formatTime(date)}';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  String _formatTime(DateTime date) {
    final hour = date.hour == 0 ? 12 : date.hour > 12 ? date.hour - 12 : date.hour;
    final minute = date.minute.toString().padLeft(2, '0');
    final period = date.hour < 12 ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }
} 