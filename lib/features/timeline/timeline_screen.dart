import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../data/models/journal_entry.dart';
import '../../data/repos/entries_repo.dart';
import '../../providers/entries_provider.dart';
import '../../providers/revenuecat_provider.dart';
import '../../routing/router.dart';
import '../../theme/theme.dart';
import 'widgets/entry_card.dart';

class TimelineScreen extends ConsumerWidget {
  const TimelineScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entries = ref.watch(entriesProvider);
    final revenueCatState = ref.watch(revenueCatProvider);
    
    return Scaffold(
      appBar: _buildAppBar(context, revenueCatState.isPremium),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(entriesStreamProvider);
        },
        child: entries.isEmpty 
            ? _buildEmptyState(context)
            : _buildTimelineContent(context, ref, entries, revenueCatState.isPremium),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, bool isPremium) {
    return AppBar(
      title: const Text('EchoJournal'),
      actions: [
        if (!isPremium)
          Container(
            margin: const EdgeInsets.only(right: AppTheme.spacing2),
            child: TextButton(
              onPressed: () => AppRouter.goToPaywall(context),
              style: TextButton.styleFrom(
                backgroundColor: AppTheme.primaryPurple.withOpacity(0.1),
                foregroundColor: AppTheme.primaryPurple,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppTheme.spacing3,
                  vertical: AppTheme.spacing1,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                ),
              ),
              child: const Text(
                'Premium',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        IconButton(
          onPressed: () => AppRouter.goToSettings(context),
          icon: const Icon(Icons.settings_outlined),
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(AppTheme.spacing8),
            decoration: BoxDecoration(
              gradient: AppTheme.primaryGradient,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.mic,
              size: 48,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: AppTheme.spacing6),
          Text(
            'Your Voice Journal Awaits',
            style: Theme.of(context).textTheme.displaySmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppTheme.spacing3),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacing8),
            child: Text(
              'Tap the microphone to record your first entry and start capturing your daily thoughts.',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context).textTheme.bodyMedium?.color,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: AppTheme.spacing8),
          ElevatedButton.icon(
            onPressed: () => AppRouter.goToRecorder(context),
            icon: const Icon(Icons.mic),
            label: const Text('Start Recording'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(
                horizontal: AppTheme.spacing6,
                vertical: AppTheme.spacing4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineContent(
    BuildContext context, 
    WidgetRef ref, 
    List<JournalEntry> entries, 
    bool isPremium,
  ) {
    return CustomScrollView(
      slivers: [
        // Throwback banner for premium users
        if (isPremium) _buildThrowbackBanner(context, ref),
        
        // Entries list
        SliverPadding(
          padding: const EdgeInsets.all(AppTheme.spacing4),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final entry = entries[index];
                final isFirstOfDay = _isFirstEntryOfDay(entries, index);
                
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (isFirstOfDay) _buildDateHeader(context, entry.createdAt),
                    EntryCard(
                      entry: entry,
                      onTap: () => AppRouter.goToEntryDetail(context, entry.id),
                      onDelete: () => _deleteEntry(ref, entry.id),
                    ),
                    const SizedBox(height: AppTheme.spacing4),
                  ],
                );
              },
              childCount: entries.length,
            ),
          ),
        ),
        
        // Bottom padding for FAB
        const SliverPadding(
          padding: EdgeInsets.only(bottom: 100),
        ),
      ],
    );
  }

  Widget _buildThrowbackBanner(BuildContext context, WidgetRef ref) {
    return Consumer(
      builder: (context, ref, child) {
        final repository = ref.read(entriesRepositoryProvider);
        final throwbackEntry = repository.getRandomPastEntry();
        
        if (throwbackEntry == null) return const SliverToBoxAdapter();
        
        final daysAgo = DateTime.now().difference(throwbackEntry.createdAt).inDays;
        
        return SliverToBoxAdapter(
          child: Container(
            margin: const EdgeInsets.all(AppTheme.spacing4),
            padding: const EdgeInsets.all(AppTheme.spacing4),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppTheme.primaryTeal.withOpacity(0.1),
                  AppTheme.primaryPurple.withOpacity(0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
              border: Border.all(
                color: AppTheme.primaryTeal.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: InkWell(
              onTap: () => AppRouter.goToEntryDetail(context, throwbackEntry.id),
              borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.history,
                        color: AppTheme.primaryTeal,
                        size: 20,
                      ),
                      const SizedBox(width: AppTheme.spacing2),
                      Text(
                        'Throwback from $daysAgo ${daysAgo == 1 ? 'day' : 'days'} ago',
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: AppTheme.primaryTeal,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppTheme.spacing2),
                  if (throwbackEntry.transcript != null)
                    Text(
                      throwbackEntry.transcript!.length > 100
                          ? '${throwbackEntry.transcript!.substring(0, 100)}...'
                          : throwbackEntry.transcript!,
                      style: Theme.of(context).textTheme.bodyMedium,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  if (throwbackEntry.aiReflection != null) ...[
                    const SizedBox(height: AppTheme.spacing2),
                    Container(
                      padding: const EdgeInsets.all(AppTheme.spacing2),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                      ),
                      child: Text(
                        throwbackEntry.aiReflection!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontStyle: FontStyle.italic,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDateHeader(BuildContext context, DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final entryDate = DateTime(date.year, date.month, date.day);
    
    String dateText;
    if (entryDate == today) {
      dateText = 'Today';
    } else if (entryDate == yesterday) {
      dateText = 'Yesterday';
    } else {
      dateText = DateFormat('MMMM d, y').format(date);
    }
    
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacing2,
        vertical: AppTheme.spacing4,
      ),
      child: Text(
        dateText,
        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
          color: Theme.of(context).textTheme.bodyMedium?.color,
        ),
      ),
    );
  }

  bool _isFirstEntryOfDay(List<JournalEntry> entries, int index) {
    if (index == 0) return true;
    
    final currentEntry = entries[index];
    final previousEntry = entries[index - 1];
    
    final currentDate = DateTime(
      currentEntry.createdAt.year,
      currentEntry.createdAt.month,
      currentEntry.createdAt.day,
    );
    final previousDate = DateTime(
      previousEntry.createdAt.year,
      previousEntry.createdAt.month,
      previousEntry.createdAt.day,
    );
    
    return currentDate != previousDate;
  }

  Future<void> _deleteEntry(WidgetRef ref, String entryId) async {
    final entryActions = ref.read(entryActionsProvider);
    await entryActions.deleteEntry(entryId);
  }
} 