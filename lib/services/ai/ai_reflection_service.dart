import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

abstract class AIReflectionService {
  Future<String> generateReflection(String transcript, {String lens = 'default'});
}

class MockReflectionService implements AIReflectionService {
  final Map<String, List<String>> _mockReflections = {
    'default': [
      "This moment captures a beautiful slice of your inner world.",
      "Your thoughts reveal a mind that's actively growing and reflecting.",
      "There's wisdom in how you process your daily experiences.",
      "This reflection shows your capacity for deep introspection.",
      "Your perspective on life continues to evolve in meaningful ways.",
    ],
    'gratitude': [
      "Your words overflow with appreciation for life's gifts.",
      "This entry radiates thankfulness for the present moment.",
      "You're cultivating a heart that sees blessings everywhere.",
      "Gratitude transforms ordinary moments into extraordinary memories.",
      "Your thankful spirit illuminates the beauty in everyday experiences.",
    ],
    'growth': [
      "This reflection shows your commitment to personal development.",
      "You're embracing challenges as opportunities for growth.",
      "Your mindset is evolving in powerful and positive ways.",
      "This entry reveals someone who learns from every experience.",
      "Your journey of self-improvement continues to inspire.",
    ],
  };

  @override
  Future<String> generateReflection(String transcript, {String lens = 'default'}) async {
    // Simulate API delay
    await Future.delayed(Duration(milliseconds: 1500));
    
    final reflections = _mockReflections[lens] ?? _mockReflections['default']!;
    return (reflections..shuffle()).first;
  }
}

class HttpReflectionService implements AIReflectionService {
  final Dio _dio;
  final String? _baseUrl;
  final String? _apiKey;

  HttpReflectionService()
      : _dio = Dio(),
        _baseUrl = dotenv.env['AI_REFLECT_URL'],
        _apiKey = dotenv.env['AI_API_KEY'] {
    _dio.options = BaseOptions(
      connectTimeout: Duration(seconds: 30),
      receiveTimeout: Duration(seconds: 60),
      headers: {
        'Content-Type': 'application/json',
        if (_apiKey != null) 'Authorization': 'Bearer $_apiKey',
      },
    );
  }

  @override
  Future<String> generateReflection(String transcript, {String lens = 'default'}) async {
    if (_baseUrl == null || _baseUrl!.isEmpty) {
      // Fallback to mock if not configured
      final mockService = MockReflectionService();
      return mockService.generateReflection(transcript, lens: lens);
    }

    try {
      final response = await _dio.post(
        _baseUrl!,
        data: jsonEncode({
          'transcript': transcript,
          'lens': lens,
        }),
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        return data['reflection'] ?? 'Unable to generate reflection';
      } else {
        // Fallback to mock on error
        final mockService = MockReflectionService();
        return mockService.generateReflection(transcript, lens: lens);
      }
    } catch (e) {
      // Fallback to mock on error
      final mockService = MockReflectionService();
      return mockService.generateReflection(transcript, lens: lens);
    }
  }
}

class AIReflectionServiceFactory {
  static AIReflectionService create() {
    final baseUrl = dotenv.env['AI_REFLECT_URL'];
    if (baseUrl == null || baseUrl.isEmpty) {
      return MockReflectionService();
    }
    return HttpReflectionService();
  }
} 