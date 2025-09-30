# 🐱 CatEcho Journal (Neko-Synth Diary)

A retro-futuristic voice journaling web app featuring pixelated cats, vaporwave aesthetics, and AI-powered insights.

## ✨ Features

### Core Functionality
- 🎙️ **Voice Recording**: Record journal entries with real-time waveform visualization
- 📝 **AI Transcription**: Automatic speech-to-text conversion (mock or API-based)
- 🤖 **AI Insights**: Get personalized reflections on your entries
- 💾 **Local Storage**: All data stored securely in IndexedDB
- 🎨 **Beautiful UI**: Retro-futuristic pixel art design with themes

### Premium Features (RevenueCat)
- ✨ **Unlimited Entries**: Free tier limited to daily quota
- 🔮 **AI Reflections**: Get mood analysis and insights
- 🎭 **Memory Lane**: Random throwback entries
- 🎨 **Exclusive Themes**: Dog and Rainforest mascots

## 🚀 Quick Start

### Prerequisites
- Node.js 16+ or Bun
- Modern browser with Web Audio API support

### Installation

```bash
# Clone and navigate
cd neko-synth-diary

# Install dependencies
npm install
# or
bun install

# Create environment file
cp .env.example .env

# Start development server
npm run dev
# or
bun dev
```

Visit `http://localhost:5173`

## 🔧 Configuration

### Environment Variables

Create a `.env` file:

```env
# RevenueCat (Optional - uses mock if not set)
VITE_REVENUECAT_API_KEY=your_key_here

# AI Services (Optional - uses mock services by default)
VITE_TRANSCRIPTION_API_URL=https://api.example.com/transcribe
VITE_TRANSCRIPTION_API_KEY=your_key

VITE_REFLECTION_API_URL=https://api.example.com/reflect
VITE_REFLECTION_API_KEY=your_key
```

### RevenueCat Setup

1. Create account at [RevenueCat](https://www.revenuecat.com/)
2. Set up products:
   - `premium_monthly` - $4.99/month
   - `premium_annual` - $39.99/year
   - `memory_pack_bronze` - $0.99
   - `memory_pack_silver` - $2.99
   - `memory_pack_gold` - $4.99
3. Add API key to `.env`

## 📱 Usage

### Recording an Entry

1. Click the ⚡ floating action button or "RECORD" button
2. Allow microphone permissions
3. Speak your thoughts
4. Click stop when finished
5. Entry is automatically saved and processed

### Viewing Entries

- **Timeline**: See all entries organized by date
- **Entry Detail**: Click any entry to view full transcript and AI insights
- **Delete**: Click trash icon to remove entries

### Premium Features

1. Navigate to **Premium** page
2. Choose subscription or memory pack
3. Complete purchase (simulated in development)
4. Unlock unlimited entries and AI insights

## 🏗️ Architecture

### Tech Stack

- **Frontend**: React 18 + TypeScript
- **Build**: Vite
- **UI**: TailwindCSS + Shadcn/ui
- **State**: React Context API
- **Storage**: Dexie (IndexedDB wrapper)
- **Audio**: Web Audio API + MediaRecorder
- **Payments**: RevenueCat
- **AI**: Pluggable services (mock or HTTP)

### Project Structure

```
src/
├── assets/               # Images and static files
├── components/
│   └── ui/              # Shadcn UI components
├── contexts/            # React contexts
│   ├── EntriesContext.tsx
│   ├── SubscriptionContext.tsx
│   └── ThemeContext.tsx
├── hooks/               # Custom hooks
├── lib/
│   └── db.ts           # Dexie database
├── pages/              # Route pages
│   ├── Index.tsx       # Landing
│   ├── Timeline.tsx    # Entries list
│   ├── Recorder.tsx    # Recording UI
│   ├── EntryDetail.tsx # Entry view
│   ├── Premium.tsx     # Paywall
│   └── Settings.tsx    # Settings
├── services/
│   ├── audio/
│   │   ├── recorder.ts # Recording service
│   │   └── player.ts   # Playback service
│   ├── ai/
│   │   ├── transcription.ts
│   │   └── reflection.ts
│   └── billing/
│       └── revenuecat.ts
└── App.tsx
```

### Key Services

#### Audio Recorder (`/services/audio/recorder.ts`)
- Real-time waveform analysis
- Amplitude monitoring
- Duration tracking
- WebM audio output

#### AI Services
- **Transcription**: Converts audio → text
- **Reflection**: Analyzes text → insights + mood
- Mock mode for development, HTTP for production

#### RevenueCat Integration
- Web-based subscription management
- Consumable purchases (memory packs)
- Customer info tracking

#### Database (Dexie/IndexedDB)
```typescript
interface JournalEntry {
  id: string;
  createdAt: Date;
  title: string;
  audioBlob: Blob;
  audioDuration: number;
  transcript?: string;
  aiReflection?: string;
  mood?: string;
  isProcessed: boolean;
  isUploaded: boolean;
}
```

## 🎨 Theming

### Available Themes
- **Cat** (Default): Cyan echo cat with headphones
- **Dog**: Purple dog mascot
- **Rainforest**: Green rainforest creature

Change in Settings > Customize > Cat Theme

### Design System
- **Colors**: Vaporwave cyberpunk palette
- **Fonts**: Pixel fonts (Press Start 2P, VT323)
- **Effects**: Scanlines, neon glow, CRT screen
- **Animations**: Pixel particles, pulse effects

## 🧪 Testing

```bash
# Run linter
npm run lint

# Build for production
npm run build

# Preview production build
npm run preview
```

## 📦 Deployment

### Vercel (Recommended)

```bash
# Install Vercel CLI
npm i -g vercel

# Deploy
vercel
```

### Netlify

```bash
# Install Netlify CLI
npm i -g netlify-cli

# Build and deploy
npm run build
netlify deploy --prod --dir=dist
```

### Manual Deployment

1. Build: `npm run build`
2. Upload `dist/` folder to hosting
3. Ensure SPA routing (redirect all to `index.html`)

## 🔐 Security & Privacy

- **Local-First**: All audio stored in browser IndexedDB
- **No Server Storage**: Audio never leaves device (unless API configured)
- **User Control**: Export and delete all data anytime

## 🐛 Troubleshooting

### Microphone Not Working
- Check browser permissions
- Ensure HTTPS (required for getUserMedia)
- Try different browser

### Build Errors
```bash
# Clear cache and reinstall
rm -rf node_modules dist
npm install
npm run build
```

### IndexedDB Issues
- Clear browser data for localhost
- Check browser console for errors
- Ensure browser supports IndexedDB

## 📝 License

MIT License - See LICENSE file

## 🙏 Acknowledgments

- RevenueCat for payment infrastructure
- Shadcn/ui for component library
- Web Audio API for recording capabilities
- OpenAI Whisper for transcription (optional)

## 🚀 Future Enhancements

- [ ] Cloud sync for entries
- [ ] Advanced analytics dashboard
- [ ] Social sharing
- [ ] Export to PDF/Audio
- [ ] Multi-language support
- [ ] Voice commands
- [ ] Mood tracking charts
- [ ] Journaling prompts

---

