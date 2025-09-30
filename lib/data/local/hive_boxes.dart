import 'package:hive_flutter/hive_flutter.dart';
import '../models/journal_entry.dart';

class HiveBoxes {
  static const String entriesBoxName = 'entries';
  static const String dailyUsageBoxName = 'daily_usage';
  
  static Box<JournalEntry>? _entriesBox;
  static Box<int>? _dailyUsageBox;
  
  static Future<void> init() async {
    _entriesBox = await Hive.openBox<JournalEntry>(entriesBoxName);
    _dailyUsageBox = await Hive.openBox<int>(dailyUsageBoxName);
  }
  
  static Box<JournalEntry> get entries {
    if (_entriesBox == null) {
      throw Exception('Entries box not initialized. Call HiveBoxes.init() first.');
    }
    return _entriesBox!;
  }
  
  static Box<int> get dailyUsage {
    if (_dailyUsageBox == null) {
      throw Exception('Daily usage box not initialized. Call HiveBoxes.init() first.');
    }
    return _dailyUsageBox!;
  }
  
  static Future<void> close() async {
    await _entriesBox?.close();
    await _dailyUsageBox?.close();
  }
} 