import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../data/models/journal_entry.dart';
import '../data/repos/entries_repo.dart';
import '../services/ai/ai_transcriber.dart';
import '../services/ai/ai_reflection_service.dart';
import '../services/audio/recorder_service.dart';
import 'revenuecat_provider.dart';

// Repository provider
final entriesRepositoryProvider = Provider<EntriesRepository>((ref) {
  return EntriesRepository();
});

// Entries stream provider
final entriesStreamProvider = StreamProvider<List<JournalEntry>>((ref) {
  final repository = ref.watch(entriesRepositoryProvider);
  return repository.watchEntries();
});

// Entries list provider
final entriesProvider = Provider<List<JournalEntry>>((ref) {
  final entriesAsync = ref.watch(entriesStreamProvider);
  return entriesAsync.when(
    data: (entries) => entries,
    loading: () => [],
    error: (_, __) => [],
  );
});

// Entry actions provider
final entryActionsProvider = Provider<EntryActions>((ref) {
  return EntryActions(ref);
});

class EntryActions {
  final Ref _ref;
  final _uuid = const Uuid();

  EntryActions(this._ref);

  EntriesRepository get _repository => _ref.read(entriesRepositoryProvider);

  Future<JournalEntry> createEntry({
    required String audioPath,
    required int durationMs,
    String? title,
  }) async {
    final entry = JournalEntry(
      id: _uuid.v4(),
      createdAt: DateTime.now(),
      title: title,
      audioPath: audioPath,
      durationMs: durationMs,
      isProcessed: false,
      isUploaded: false,
    );

    await _repository.saveEntry(entry);
    return entry;
  }

  Future<void> updateEntry(JournalEntry entry) async {
    await _repository.updateEntry(entry);
  }

  Future<void> deleteEntry(String entryId) async {
    final entry = _repository.getEntry(entryId);
    if (entry != null) {
      // Delete audio file
      final audioFile = File(entry.audioPath);
      if (await audioFile.exists()) {
        await audioFile.delete();
      }
      
      await _repository.deleteEntry(entryId);
    }
  }

  Future<void> processEntry(String entryId, {String? memoryPackLens}) async {
    final entry = _repository.getEntry(entryId);
    if (entry == null || entry.isProcessed) return;

    try {
      // Transcribe audio
      final transcriber = AITranscriberFactory.create();
      final audioFile = File(entry.audioPath);
      final transcriptResult = await transcriber.transcribe(audioFile);

      String? aiReflection;
      String? mood;

      // Generate AI reflection if premium or memory pack applied
      final isPremium = await _ref.read(revenueCatProvider.notifier).isPremium();
      if (isPremium || memoryPackLens != null) {
        final reflectionService = AIReflectionServiceFactory.create();
        final lens = memoryPackLens ?? 'default';
        aiReflection = await reflectionService.generateReflection(
          transcriptResult.text,
          lens: lens,
        );

        // Set mood based on lens or default for premium
        if (isPremium) {
          mood = _generateMoodFromTranscript(transcriptResult.text);
        }
      }

      // Update entry
      final updatedEntry = entry.copyWith(
        transcript: transcriptResult.success ? transcriptResult.text : null,
        aiReflection: aiReflection,
        mood: mood,
        isProcessed: true,
      );

      await _repository.updateEntry(updatedEntry);
    } catch (e) {
      // Mark as processed even if AI services fail, but keep transcript if available
      final transcriber = AITranscriberFactory.create();
      final audioFile = File(entry.audioPath);
      
      try {
        final transcriptResult = await transcriber.transcribe(audioFile);
        final updatedEntry = entry.copyWith(
          transcript: transcriptResult.success ? transcriptResult.text : 'Transcription failed',
          isProcessed: true,
        );
        await _repository.updateEntry(updatedEntry);
      } catch (_) {
        final updatedEntry = entry.copyWith(
          transcript: 'Processing failed',
          isProcessed: true,
        );
        await _repository.updateEntry(updatedEntry);
      }
    }
  }

  Future<void> applyMemoryPack(String entryId, String packType) async {
    final entry = _repository.getEntry(entryId);
    if (entry == null || entry.transcript == null) return;

    try {
      final reflectionService = AIReflectionServiceFactory.create();
      final aiReflection = await reflectionService.generateReflection(
        entry.transcript!,
        lens: packType,
      );

      final updatedEntry = entry.copyWith(
        aiReflection: aiReflection,
      );

      await _repository.updateEntry(updatedEntry);
    } catch (e) {
      // Handle error silently or show user feedback
    }
  }

  Future<void> updateEntryTitle(String entryId, String title) async {
    final entry = _repository.getEntry(entryId);
    if (entry == null) return;

    final updatedEntry = entry.copyWith(title: title);
    await _repository.updateEntry(updatedEntry);
  }

  String _generateMoodFromTranscript(String transcript) {
    final lowerTranscript = transcript.toLowerCase();
    
    // Simple mood detection based on keywords
    if (lowerTranscript.contains(RegExp(r'\b(grateful|thankful|blessed|appreciate|joy|happy|wonderful|amazing)\b'))) {
      return 'Grateful';
    } else if (lowerTranscript.contains(RegExp(r'\b(calm|peaceful|relaxed|serene|tranquil)\b'))) {
      return 'Calm';
    } else if (lowerTranscript.contains(RegExp(r'\b(motivated|inspired|determined|focused|driven)\b'))) {
      return 'Motivated';
    } else if (lowerTranscript.contains(RegExp(r'\b(excited|enthusiastic|energetic|thrilled)\b'))) {
      return 'Excited';
    } else if (lowerTranscript.contains(RegExp(r'\b(reflective|thoughtful|contemplative|pensive)\b'))) {
      return 'Reflective';
    } else {
      return 'Neutral';
    }
  }
} 