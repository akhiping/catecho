import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../data/models/journal_entry.dart';
import '../../../providers/revenuecat_provider.dart';
import '../../../services/audio/player_service.dart';
import '../../../theme/theme.dart';

class EntryCard extends ConsumerStatefulWidget {
  final JournalEntry entry;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const EntryCard({
    super.key,
    required this.entry,
    required this.onTap,
    required this.onDelete,
  });

  @override
  ConsumerState<EntryCard> createState() => _EntryCardState();
}

class _EntryCardState extends ConsumerState<EntryCard>
    with SingleTickerProviderStateMixin {
  PlayerService? _playerService;
  bool _isPlaying = false;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _playerService = PlayerService();
    _animationController = AnimationController(
      duration: AppTheme.animationMedium,
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _playerService?.stateStream.listen((state) {
      if (mounted) {
        setState(() {
          _isPlaying = state == PlayerState.playing;
        });
      }
    });
  }

  @override
  void dispose() {
    _playerService?.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isPremium = ref.watch(revenueCatProvider).isPremium;
    
    return ScaleTransition(
      scale: _scaleAnimation,
      child: Card(
        margin: EdgeInsets.zero,
        child: InkWell(
          onTap: () {
            _animationController.forward().then((_) {
              _animationController.reverse();
            });
            widget.onTap();
          },
          borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
          child: Padding(
            padding: const EdgeInsets.all(AppTheme.spacing4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context),
                const SizedBox(height: AppTheme.spacing3),
                _buildContent(context, isPremium),
                if (widget.entry.aiReflection != null && isPremium) ...[
                  const SizedBox(height: AppTheme.spacing3),
                  _buildAiReflection(context),
                ],
                const SizedBox(height: AppTheme.spacing3),
                _buildFooter(context, isPremium),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(AppTheme.spacing2),
          decoration: BoxDecoration(
            gradient: AppTheme.primaryGradient,
            borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
          ),
          child: Icon(
            widget.entry.isProcessed ? Icons.mic : Icons.hourglass_empty,
            color: Colors.white,
            size: 16,
          ),
        ),
        const SizedBox(width: AppTheme.spacing3),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.entry.title ?? 'Voice Entry',
                style: Theme.of(context).textTheme.headlineSmall,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                DateFormat('MMM d, h:mm a').format(widget.entry.createdAt),
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
        _buildPlayButton(),
        PopupMenuButton<String>(
          onSelected: (value) {
            switch (value) {
              case 'delete':
                _showDeleteConfirmation(context);
                break;
              case 'edit':
                // TODO: Implement edit title
                break;
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  Icon(Icons.edit_outlined, size: 18),
                  SizedBox(width: 8),
                  Text('Edit Title'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete_outline, size: 18, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Delete', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
          child: const Icon(Icons.more_vert, size: 20),
        ),
      ],
    );
  }

  Widget _buildContent(BuildContext context, bool isPremium) {
    if (!widget.entry.isProcessed) {
      return Container(
        padding: const EdgeInsets.all(AppTheme.spacing3),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(
                  Theme.of(context).primaryColor,
                ),
              ),
            ),
            const SizedBox(width: AppTheme.spacing2),
            Text(
              'Processing...',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      );
    }

    if (widget.entry.transcript == null || widget.entry.transcript!.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(AppTheme.spacing3),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.errorContainer.withOpacity(0.1),
          borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
        ),
        child: Text(
          'Transcription failed',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.error,
            fontStyle: FontStyle.italic,
          ),
        ),
      );
    }

    return Text(
      widget.entry.transcript!,
      style: Theme.of(context).textTheme.bodyLarge,
      maxLines: 3,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildAiReflection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacing3),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.primaryPurple.withOpacity(0.05),
            AppTheme.primaryTeal.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
        border: Border.all(
          color: AppTheme.primaryPurple.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              gradient: AppTheme.primaryGradient,
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Icon(
              Icons.auto_awesome,
              color: Colors.white,
              size: 14,
            ),
          ),
          const SizedBox(width: AppTheme.spacing2),
          Expanded(
            child: Text(
              widget.entry.aiReflection!,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontStyle: FontStyle.italic,
                color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.8),
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter(BuildContext context, bool isPremium) {
    return Row(
      children: [
        _buildDurationChip(context),
        if (widget.entry.mood != null && isPremium) ...[
          const SizedBox(width: AppTheme.spacing2),
          _buildMoodChip(context, widget.entry.mood!),
        ],
        const Spacer(),
        _buildWaveformPreview(),
      ],
    );
  }

  Widget _buildDurationChip(BuildContext context) {
    final duration = Duration(milliseconds: widget.entry.durationMs);
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacing2,
        vertical: AppTheme.spacing1,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
      ),
      child: Text(
        '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}',
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildMoodChip(BuildContext context, String mood) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacing2,
        vertical: AppTheme.spacing1,
      ),
      decoration: BoxDecoration(
        color: AppTheme.getMoodColor(mood).withOpacity(0.2),
        borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
      ),
      child: Text(
        mood,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          fontWeight: FontWeight.w600,
          color: AppTheme.getMoodColor(mood).withOpacity(0.8),
        ),
      ),
    );
  }

  Widget _buildWaveformPreview() {
    return Row(
      children: List.generate(8, (index) {
        final heights = [0.3, 0.7, 0.5, 0.9, 0.4, 0.6, 0.8, 0.2];
        return Container(
          width: 2,
          height: 16 * heights[index],
          margin: const EdgeInsets.only(right: 1),
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor.withOpacity(0.6),
            borderRadius: BorderRadius.circular(1),
          ),
        );
      }),
    );
  }

  Widget _buildPlayButton() {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).primaryColor.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Theme.of(context).primaryColor,
        shape: const CircleBorder(),
        child: InkWell(
          onTap: _togglePlayback,
          customBorder: const CircleBorder(),
          child: Container(
            padding: const EdgeInsets.all(AppTheme.spacing2),
            child: Icon(
              _isPlaying ? Icons.pause : Icons.play_arrow,
              color: Colors.white,
              size: 20,
            ),
          ),
        ),
      ),
    );
  }

  void _togglePlayback() async {
    if (_playerService == null) return;

    if (_isPlaying) {
      await _playerService!.pause();
    } else {
      await _playerService!.play(widget.entry.audioPath);
    }
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Entry'),
        content: const Text('Are you sure you want to delete this entry? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              widget.onDelete();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
} 