import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/local/hive_boxes.dart';
import '../data/repos/entries_repo.dart';
import 'revenuecat_provider.dart';

// Daily quota provider
final dailyQuotaProvider = StateNotifierProvider<DailyQuotaNotifier, DailyQuotaState>((ref) {
  return DailyQuotaNotifier(ref);
});

class DailyQuotaState {
  final int dailyLimit;
  final int usedToday;
  final bool canCreateEntry;
  final DateTime lastResetDate;

  const DailyQuotaState({
    this.dailyLimit = 1, // Free tier: 1 entry per day
    this.usedToday = 0,
    this.canCreateEntry = true,
    required this.lastResetDate,
  });

  DailyQuotaState copyWith({
    int? dailyLimit,
    int? usedToday,
    bool? canCreateEntry,
    DateTime? lastResetDate,
  }) {
    return DailyQuotaState(
      dailyLimit: dailyLimit ?? this.dailyLimit,
      usedToday: usedToday ?? this.usedToday,
      canCreateEntry: canCreateEntry ?? this.canCreateEntry,
      lastResetDate: lastResetDate ?? this.lastResetDate,
    );
  }

  int get remainingEntries => (dailyLimit - usedToday).clamp(0, dailyLimit);
  bool get hasReachedLimit => usedToday >= dailyLimit;
}

class DailyQuotaNotifier extends StateNotifier<DailyQuotaState> {
  final Ref _ref;
  final EntriesRepository _repository = EntriesRepository();

  DailyQuotaNotifier(this._ref) : super(DailyQuotaState(lastResetDate: DateTime.now())) {
    _initialize();
  }

  Future<void> _initialize() async {
    await _updateQuotaForToday();
    
    // Listen to RevenueCat changes to update limits
    _ref.listen(revenueCatProvider, (previous, next) {
      _updateLimitsBasedOnPremiumStatus(next.isPremium);
    });
  }

  Future<void> _updateQuotaForToday() async {
    final today = DateTime.now();
    final todayKey = _formatDateKey(today);
    
    // Check if we need to reset daily count
    final lastResetKey = _formatDateKey(state.lastResetDate);
    final needsReset = todayKey != lastResetKey;
    
    if (needsReset) {
      // Reset daily count
      await _resetDailyCount(today);
    }
    
    // Get today's usage
    final usedToday = _repository.getEntryCountForDate(today);
    
    // Check if user is premium
    final isPremium = await _ref.read(revenueCatProvider.notifier).isPremium();
    final dailyLimit = isPremium ? -1 : 1; // -1 means unlimited
    
    state = state.copyWith(
      dailyLimit: dailyLimit,
      usedToday: usedToday,
      canCreateEntry: isPremium || usedToday < 1,
      lastResetDate: today,
    );
  }

  Future<void> _resetDailyCount(DateTime date) async {
    final box = HiveBoxes.dailyUsage;
    final dateKey = _formatDateKey(date);
    await box.put(dateKey, 0);
  }

  void _updateLimitsBasedOnPremiumStatus(bool isPremium) {
    final dailyLimit = isPremium ? -1 : 1; // -1 means unlimited
    state = state.copyWith(
      dailyLimit: dailyLimit,
      canCreateEntry: isPremium || state.usedToday < 1,
    );
  }

  Future<bool> canCreateNewEntry() async {
    await _updateQuotaForToday();
    
    // Premium users have unlimited entries
    final isPremium = await _ref.read(revenueCatProvider.notifier).isPremium();
    if (isPremium) return true;
    
    // Free users: 1 entry per day
    return state.usedToday < 1;
  }

  Future<void> incrementUsage() async {
    final today = DateTime.now();
    final todayKey = _formatDateKey(today);
    final box = HiveBoxes.dailyUsage;
    
    final currentCount = box.get(todayKey, defaultValue: 0) ?? 0;
    await box.put(todayKey, currentCount + 1);
    
    // Update state
    await _updateQuotaForToday();
  }

  Future<void> decrementUsage() async {
    final today = DateTime.now();
    final todayKey = _formatDateKey(today);
    final box = HiveBoxes.dailyUsage;
    
    final currentCount = box.get(todayKey, defaultValue: 0) ?? 0;
    if (currentCount > 0) {
      await box.put(todayKey, currentCount - 1);
    }
    
    // Update state
    await _updateQuotaForToday();
  }

  Future<Map<String, int>> getUsageHistory({int days = 30}) async {
    final box = HiveBoxes.dailyUsage;
    final history = <String, int>{};
    final today = DateTime.now();
    
    for (int i = 0; i < days; i++) {
      final date = today.subtract(Duration(days: i));
      final dateKey = _formatDateKey(date);
      final count = box.get(dateKey, defaultValue: 0) ?? 0;
      history[dateKey] = count;
    }
    
    return history;
  }

  String _formatDateKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  Future<void> refreshQuota() async {
    await _updateQuotaForToday();
  }
} 