import 'dart:io';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class TranscriptResult {
  final String text;
  final bool success;
  final String? error;

  TranscriptResult({
    required this.text,
    required this.success,
    this.error,
  });
}

abstract class AITranscriber {
  Future<TranscriptResult> transcribe(File audioFile);
}

class MockTranscriber implements AITranscriber {
  final List<String> _mockResponses = [
    "Today was a wonderful day. I felt grateful for all the small moments that brought me joy.",
    "I've been thinking about my goals lately. There's so much I want to accomplish this year.",
    "Sometimes I wonder what the future holds. But I'm learning to be present in the moment.",
    "Had an interesting conversation with a friend today. It made me reflect on what really matters.",
    "I'm feeling more confident about my decisions lately. Trust in myself is growing stronger.",
    "The weather was perfect today. It reminded me to appreciate the simple pleasures in life.",
    "I've been reading this amazing book that's changing my perspective on everything.",
    "Work has been challenging, but I'm learning so much. Growth often comes through difficulty."
  ];

  @override
  Future<TranscriptResult> transcribe(File audioFile) async {
    // Simulate API delay
    await Future.delayed(Duration(seconds: 2));
    
    final randomResponse = (_mockResponses..shuffle()).first;
    
    return TranscriptResult(
      text: randomResponse,
      success: true,
    );
  }
}

class HttpTranscriber implements AITranscriber {
  final Dio _dio;
  final String? _baseUrl;
  final String? _apiKey;

  HttpTranscriber()
      : _dio = Dio(),
        _baseUrl = dotenv.env['AI_TRANSCRIBE_URL'],
        _apiKey = dotenv.env['AI_API_KEY'] {
    _dio.options = BaseOptions(
      connectTimeout: Duration(seconds: 30),
      receiveTimeout: Duration(seconds: 60),
      headers: {
        if (_apiKey != null) 'Authorization': 'Bearer $_apiKey',
      },
    );
  }

  @override
  Future<TranscriptResult> transcribe(File audioFile) async {
    if (_baseUrl == null || _baseUrl!.isEmpty) {
      return TranscriptResult(
        text: '',
        success: false,
        error: 'AI transcription URL not configured',
      );
    }

    try {
      final formData = FormData.fromMap({
        'audio': await MultipartFile.fromFile(
          audioFile.path,
          filename: 'audio.${audioFile.path.split('.').last}',
        ),
      });

      final response = await _dio.post(
        _baseUrl!,
        data: formData,
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        return TranscriptResult(
          text: data['text'] ?? '',
          success: true,
        );
      } else {
        return TranscriptResult(
          text: '',
          success: false,
          error: 'HTTP ${response.statusCode}: ${response.statusMessage}',
        );
      }
    } catch (e) {
      return TranscriptResult(
        text: '',
        success: false,
        error: e.toString(),
      );
    }
  }
}

class AITranscriberFactory {
  static AITranscriber create() {
    final baseUrl = dotenv.env['AI_TRANSCRIBE_URL'];
    if (baseUrl == null || baseUrl.isEmpty) {
      return MockTranscriber();
    }
    return HttpTranscriber();
  }
} 