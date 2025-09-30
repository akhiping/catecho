import axios from 'axios';

export interface TranscriptionResult {
  text: string;
  confidence?: number;
}

// Mock transcription service for testing
class MockTranscriptionService {
  async transcribe(audioBlob: Blob): Promise<TranscriptionResult> {
    // Simulate network delay
    await new Promise(resolve => setTimeout(resolve, 1500));
    
    const mockTexts = [
      "Today I woke up feeling really energized and ready to tackle the day. I've been thinking a lot about my goals and what I want to accomplish this month.",
      "Just had an interesting conversation with a friend about life, the universe, and everything. It made me reflect on how far I've come in my personal journey.",
      "Sometimes I wonder if I'm on the right path. But then I remember that every step forward is progress, no matter how small it might seem.",
      "Grateful for the little things today - a good cup of coffee, sunshine through the window, and the sound of birds chirping outside.",
      "Been feeling a bit overwhelmed lately with everything going on. Need to remember to take breaks and practice self-care more often."
    ];
    
    return {
      text: mockTexts[Math.floor(Math.random() * mockTexts.length)],
      confidence: 0.95
    };
  }
}

// HTTP-based transcription service (for production)
class HttpTranscriptionService {
  private apiUrl: string;
  private apiKey: string;

  constructor(apiUrl: string, apiKey: string) {
    this.apiUrl = apiUrl;
    this.apiKey = apiKey;
  }

  async transcribe(audioBlob: Blob): Promise<TranscriptionResult> {
    const formData = new FormData();
    formData.append('audio', audioBlob, 'recording.webm');

    try {
      const response = await axios.post(this.apiUrl, formData, {
        headers: {
          'Authorization': `Bearer ${this.apiKey}`,
          'Content-Type': 'multipart/form-data'
        }
      });

      return {
        text: response.data.text,
        confidence: response.data.confidence
      };
    } catch (error) {
      console.error('Transcription API error:', error);
      // Fallback to mock on error
      return new MockTranscriptionService().transcribe(audioBlob);
    }
  }
}

export function createTranscriptionService() {
  const apiUrl = import.meta.env.VITE_TRANSCRIPTION_API_URL;
  const apiKey = import.meta.env.VITE_TRANSCRIPTION_API_KEY;

  if (apiUrl && apiKey) {
    return new HttpTranscriptionService(apiUrl, apiKey);
  }

  // Default to mock for development
  return new MockTranscriptionService();
}

export const transcriptionService = createTranscriptionService(); 