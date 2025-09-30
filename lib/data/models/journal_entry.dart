import 'package:hive/hive.dart';

part 'journal_entry.g.dart';

@HiveType(typeId: 0)
class JournalEntry extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final DateTime createdAt;

  @HiveField(2)
  String? title;

  @HiveField(3)
  final String audioPath;

  @HiveField(4)
  final int durationMs;

  @HiveField(5)
  String? transcript;

  @HiveField(6)
  String? aiReflection;

  @HiveField(7)
  String? mood;

  @HiveField(8)
  bool isProcessed;

  @HiveField(9)
  bool isUploaded;

  JournalEntry({
    required this.id,
    required this.createdAt,
    this.title,
    required this.audioPath,
    required this.durationMs,
    this.transcript,
    this.aiReflection,
    this.mood,
    this.isProcessed = false,
    this.isUploaded = false,
  });

  JournalEntry copyWith({
    String? id,
    DateTime? createdAt,
    String? title,
    String? audioPath,
    int? durationMs,
    String? transcript,
    String? aiReflection,
    String? mood,
    bool? isProcessed,
    bool? isUploaded,
  }) {
    return JournalEntry(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      title: title ?? this.title,
      audioPath: audioPath ?? this.audioPath,
      durationMs: durationMs ?? this.durationMs,
      transcript: transcript ?? this.transcript,
      aiReflection: aiReflection ?? this.aiReflection,
      mood: mood ?? this.mood,
      isProcessed: isProcessed ?? this.isProcessed,
      isUploaded: isUploaded ?? this.isUploaded,
    );
  }

  @override
  String toString() {
    return 'JournalEntry(id: $id, createdAt: $createdAt, title: $title, durationMs: $durationMs, isProcessed: $isProcessed)';
  }
} 