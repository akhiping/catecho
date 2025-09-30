import 'dart:async';
import 'package:hive/hive.dart';
import '../local/hive_boxes.dart';
import '../models/journal_entry.dart';

class EntriesRepository {
  Box<JournalEntry> get _box => HiveBoxes.entries;

  Stream<List<JournalEntry>> watchEntries() {
    return _box.watch().map((_) => getAllEntries());
  }

  List<JournalEntry> getAllEntries() {
    final entries = _box.values.toList();
    entries.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return entries;
  }

  JournalEntry? getEntry(String id) {
    return _box.values.firstWhere(
      (entry) => entry.id == id,
      orElse: () => throw StateError('Entry not found'),
    );
  }

  Future<void> saveEntry(JournalEntry entry) async {
    await _box.put(entry.id, entry);
  }

  Future<void> updateEntry(JournalEntry entry) async {
    await _box.put(entry.id, entry);
  }

  Future<void> deleteEntry(String id) async {
    await _box.delete(id);
  }

  Future<void> deleteAllEntries() async {
    await _box.clear();
  }

  List<JournalEntry> getEntriesForDate(DateTime date) {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));
    
    return _box.values
        .where((entry) => 
            entry.createdAt.isAfter(startOfDay) && 
            entry.createdAt.isBefore(endOfDay))
        .toList();
  }

  int getEntryCountForDate(DateTime date) {
    return getEntriesForDate(date).length;
  }

  JournalEntry? getRandomPastEntry({int minDaysAgo = 7}) {
    final cutoffDate = DateTime.now().subtract(Duration(days: minDaysAgo));
    final pastEntries = _box.values
        .where((entry) => entry.createdAt.isBefore(cutoffDate))
        .toList();
    
    if (pastEntries.isEmpty) return null;
    
    pastEntries.shuffle();
    return pastEntries.first;
  }
} 