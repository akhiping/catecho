import axios from 'axios';

export interface ReflectionResult {
  reflection: string;
  mood?: string;
  keywords?: string[];
}

// Mock reflection service
class MockReflectionService {
  async generateReflection(transcript: string): Promise<ReflectionResult> {
    // Simulate network delay
    await new Promise(resolve => setTimeout(resolve, 2000));
    
    const reflections = [
      {
        reflection: "Your thoughts show a sense of optimism and forward momentum. It's wonderful that you're taking time to reflect on your goals and aspirations.",
        mood: "happy",
        keywords: ["optimism", "goals", "growth"]
      },
      {
        reflection: "Deep conversations with friends can be so enriching. Your openness to reflection demonstrates emotional maturity and self-awareness.",
        mood: "thoughtful",
        keywords: ["friendship", "reflection", "growth"]
      },
      {
        reflection: "It's completely normal to question your path. What matters is that you're staying present and recognizing that progress isn't always linear.",
        mood: "thoughtful",
        keywords: ["uncertainty", "progress", "mindfulness"]
      },
      {
        reflection: "Gratitude for simple pleasures is a sign of mindfulness. These small moments of joy compound into a more fulfilling life.",
        mood: "happy",
        keywords: ["gratitude", "mindfulness", "joy"]
      },
      {
        reflection: "Acknowledging overwhelm is the first step to managing it. Remember that self-care isn't selfish - it's essential for your wellbeing.",
        mood: "chill",
        keywords: ["self-care", "overwhelm", "balance"]
      }
    ];
    
    return reflections[Math.floor(Math.random() * reflections.length)];
  }
}

// HTTP-based reflection service
class HttpReflectionService {
  private apiUrl: string;
  private apiKey: string;

  constructor(apiUrl: string, apiKey: string) {
    this.apiUrl = apiUrl;
    this.apiKey = apiKey;
  }

  async generateReflection(transcript: string): Promise<ReflectionResult> {
    try {
      const response = await axios.post(this.apiUrl, {
        transcript,
        options: {
          include_mood: true,
          include_keywords: true
        }
      }, {
        headers: {
          'Authorization': `Bearer ${this.apiKey}`,
          'Content-Type': 'application/json'
        }
      });

      return {
        reflection: response.data.reflection,
        mood: response.data.mood,
        keywords: response.data.keywords
      };
    } catch (error) {
      console.error('Reflection API error:', error);
      // Fallback to mock on error
      return new MockReflectionService().generateReflection(transcript);
    }
  }
}

export function createReflectionService() {
  const apiUrl = import.meta.env.VITE_REFLECTION_API_URL;
  const apiKey = import.meta.env.VITE_REFLECTION_API_KEY;

  if (apiUrl && apiKey) {
    return new HttpReflectionService(apiUrl, apiKey);
  }

  return new MockReflectionService();
}

export const reflectionService = createReflectionService(); 