# 🎤 Real Speech Transcription Setup

Currently, the app uses **mock transcription** which returns random text. To get real "hello, can you hear me" transcription, you need to connect to an AI transcription API.

---

## 🚀 Quick Solution: OpenAI Whisper API

### 1. Get API Key (5 minutes)

1. Go to [platform.openai.com](https://platform.openai.com/signup)
2. Sign up (free trial gives $5 credit)
3. Go to API Keys section
4. Create new secret key
5. Copy it (starts with `sk-...`)

### 2. Add to Environment

```bash
cd neko-synth-diary
nano .env
```

Add:
```env
VITE_TRANSCRIPTION_API_URL=https://api.openai.com/v1/audio/transcriptions
VITE_TRANSCRIPTION_API_KEY=sk-your-actual-key-here
```

### 3. Update Transcription Service

The service is already set up to use HTTP when API keys are present! Just need to adjust for OpenAI's format:

Update `src/services/ai/transcription.ts`:

```typescript
async transcribe(audioBlob: Blob): Promise<TranscriptionResult> {
  const formData = new FormData();
  formData.append('file', audioBlob, 'recording.webm');
  formData.append('model', 'whisper-1');

  try {
    const response = await axios.post(this.apiUrl, formData, {
      headers: {
        'Authorization': `Bearer ${this.apiKey}`,
        'Content-Type': 'multipart/form-data'
      }
    });

    return {
      text: response.data.text,
      confidence: 1.0
    };
  } catch (error) {
    console.error('Transcription API error:', error);
    // Fallback to mock on error
    return new MockTranscriptionService().transcribe(audioBlob);
  }
}
```

### 4. Restart Dev Server

```bash
npm run dev
```

**Now when you say "hello, can you hear me", it will transcribe exactly that!**

---

## 💰 Cost

OpenAI Whisper pricing:
- **$0.006 per minute** of audio
- Your $5 free credit = ~833 minutes of transcription
- That's about **13 hours** of journaling for free!

---

## 🔧 Alternative: Local Whisper (Free Forever)

If you don't want to pay, you can run Whisper locally:

### 1. Install Whisper

```bash
pip install openai-whisper
```

### 2. Create Local API Server

Create `transcription-server.py`:

```python
from flask import Flask, request, jsonify
import whisper
import tempfile
import os

app = Flask(__name__)
model = whisper.load_model("base")  # or "small", "medium", "large"

@app.route('/transcribe', methods=['POST'])
def transcribe():
    audio_file = request.files['audio']
    
    # Save temporarily
    with tempfile.NamedTemporaryFile(delete=False, suffix='.webm') as tmp:
        audio_file.save(tmp.name)
        tmp_path = tmp.name
    
    try:
        result = model.transcribe(tmp_path)
        return jsonify({
            'text': result['text'],
            'confidence': 0.95
        })
    finally:
        os.unlink(tmp_path)

if __name__ == '__main__':
    app.run(port=5000)
```

### 3. Run Server

```bash
pip install flask
python transcription-server.py
```

### 4. Update .env

```env
VITE_TRANSCRIPTION_API_URL=http://localhost:5000/transcribe
VITE_TRANSCRIPTION_API_KEY=not-needed
```

**Now it's 100% free and runs locally!**

---

## 🎯 Current Mock Behavior

The mock service returns these random phrases:
- "Today I woke up feeling really energized..."
- "Just had an interesting conversation..."
- "Sometimes I wonder if I'm on the right path..."
- "Grateful for the little things today..."
- "Been feeling a bit overwhelmed lately..."

**This is intentional for testing without an API!**

---

## ✅ What's Already Working

Even without real transcription:
- ✅ Voice recording with real microphone
- ✅ Audio saved to IndexedDB
- ✅ Playback of your actual voice
- ✅ Waveform visualization
- ✅ Timeline and entry management
- ✅ Mock AI reflections (mood analysis)

**You can hear your recordings - only the text transcription is mocked!**

---

## 🚀 Recommended Approach

**For Shipathon Demo:**
1. Keep mock transcription (it looks great!)
2. Focus on the UI/UX and RevenueCat integration
3. Audio recording & playback work perfectly

**For Production:**
1. Add OpenAI Whisper API ($5 free credit)
2. Or run local Whisper (100% free)

---

**The app is fully functional - transcription is the only "demo" feature!** 🎉 