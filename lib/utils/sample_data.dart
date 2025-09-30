import '../data/models/journal_entry.dart';

class SampleData {
  static List<JournalEntry> getSampleEntries() {
    final now = DateTime.now();
    
    return [
      JournalEntry(
        id: '1',
        createdAt: now.subtract(Duration(hours: 2)),
        title: 'Morning Reflection',
        audioPath: '/mock/audio1.m4a',
        durationMs: 45000, // 45 seconds
        transcript: "Today started with a beautiful sunrise. I felt grateful for this new day and all the opportunities it brings. There's something magical about early mornings when the world is quiet and full of possibilities.",
        aiReflection: "Your words capture a beautiful appreciation for life's simple moments. This gratitude for new beginnings shows a mindset that's open to growth and wonder.",
        mood: 'Grateful',
        isProcessed: true,
        isUploaded: false,
      ),
      JournalEntry(
        id: '2',
        createdAt: now.subtract(Duration(days: 1, hours: 5)),
        title: 'Work Thoughts',
        audioPath: '/mock/audio2.m4a',
        durationMs: 62000, // 1 minute 2 seconds
        transcript: "Had a challenging meeting today but I think I handled it well. Sometimes conflict at work can be stressful, but I'm learning to stay calm and focused on solutions rather than problems.",
        aiReflection: "Your ability to reframe challenges as learning opportunities shows real emotional maturity. This growth mindset will serve you well in all areas of life.",
        mood: 'Reflective',
        isProcessed: true,
        isUploaded: false,
      ),
      JournalEntry(
        id: '3',
        createdAt: now.subtract(Duration(days: 2, hours: 3)),
        title: 'Weekend Plans',
        audioPath: '/mock/audio3.m4a',
        durationMs: 38000, // 38 seconds
        transcript: "Looking forward to the weekend! Planning to visit the farmers market and maybe try that new hiking trail. I love how weekends give us time to recharge and explore.",
        aiReflection: "Your excitement for simple pleasures and outdoor activities reflects a healthy balance between work and personal fulfillment. These moments of anticipation are precious.",
        mood: 'Excited',
        isProcessed: true,
        isUploaded: false,
      ),
      JournalEntry(
        id: '4',
        createdAt: now.subtract(Duration(days: 3, hours: 1)),
        audioPath: '/mock/audio4.m4a',
        durationMs: 25000, // 25 seconds
        transcript: "Quick thought before bed - grateful for family dinner tonight. Sometimes the simplest moments are the most meaningful.",
        aiReflection: "Family connections provide the foundation for a fulfilling life. Your recognition of these precious moments shows deep wisdom about what truly matters.",
        mood: 'Calm',
        isProcessed: true,
        isUploaded: false,
      ),
      JournalEntry(
        id: '5',
        createdAt: now.subtract(Duration(days: 7, hours: 4)),
        title: 'Processing...',
        audioPath: '/mock/audio5.m4a',
        durationMs: 52000, // 52 seconds
        transcript: null,
        aiReflection: null,
        mood: null,
        isProcessed: false, // This one is still processing
        isUploaded: false,
      ),
    ];
  }
  
  static void addSampleDataToRepository() {
    // This would be called during app initialization for testing
    // In a real app, this would be removed
  }
} 