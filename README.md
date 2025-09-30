# 🐱 CatEcho Journal (EchoJournal)

A retro-futuristic voice journaling app featuring pixelated cats, vaporwave aesthetics, and AI-powered insights. Built for the RevenueCat Shipathon.

## 🚀 Quick Start

**Web App (Works Right Now!)**
```bash
cd neko-synth-diary
npm install
npm run dev
# Open http://localhost:5173
```

**Flutter Mobile App**
```bash
flutter pub get
flutter run
```

## 📦 What's Inside This Repo

- ✅ **Web App** (`neko-synth-diary/`) - React/TypeScript, production ready
- ✅ **Flutter App** (`lib/`) - iOS/Android, App Store ready
- ✅ **RevenueCat Integration** - Subscriptions + consumables configured
- ✅ **AI Services** - Transcription + reflection (mock + API ready)
- ✅ **Beautiful UI** - Retro-futuristic pixel art design with themes

## 📖 Complete Documentation

- **[QUICK_START.md](QUICK_START.md)** - Get running in 5 minutes ⚡
- **[PROJECT_SUMMARY.md](PROJECT_SUMMARY.md)** - Complete project overview 📊
- **[DEPLOYMENT_GUIDE.md](DEPLOYMENT_GUIDE.md)** - Deploy to production 🚀
- **[APP_STORE_SUBMISSION.md](APP_STORE_SUBMISSION.md)** - Submit to app stores 📱
- **[DESIGN_SYSTEM.md](DESIGN_SYSTEM.md)** - Design specifications 🎨

---

## Features

### Free Tier
- 1 voice entry per day
- Audio transcription
- Local storage
- Basic playback

### Premium ($4.99/month or $29.99/year)
- Unlimited voice entries
- AI-powered reflections
- Mood detection and tracking
- Memory throwbacks (daily reminders of past entries)
- Custom themes
- Premium support

### Memory Packs (One-time purchases $1.99 each)
- **Gratitude Pack**: AI reflections focused on appreciation and thankfulness
- **Growth Pack**: Insights for personal development and learning

## Tech Stack

- **Framework**: Flutter 3.0+
- **State Management**: Riverpod
- **Local Storage**: Hive (offline-first)
- **Audio**: record + just_audio packages
- **Routing**: go_router
- **Payments**: RevenueCat
- **AI Services**: Pluggable architecture (mock/HTTP)
- **Design**: Custom Material 3 theme with light/dark mode

## Project Structure

```
lib/
├── app.dart                    # Main app widget
├── main.dart                   # App entry point
├── data/
│   ├── models/                 # Data models (JournalEntry)
│   ├── local/                  # Hive storage setup
│   └── repos/                  # Repository pattern
├── features/
│   ├── timeline/               # Home screen with entries
│   ├── recorder/               # Voice recording screen
│   ├── entry/                  # Entry detail view
│   ├── paywall/                # Subscription screen
│   ├── settings/               # App settings
│   └── onboarding/             # Welcome flow
├── providers/                  # Riverpod state management
├── services/
│   ├── audio/                  # Recording & playback
│   ├── ai/                     # Transcription & reflection
│   └── billing/                # RevenueCat integration
├── theme/                      # Design system
├── routing/                    # Navigation setup
└── utils/                      # Helper functions
```

## Getting Started

### Prerequisites

- Flutter 3.0 or later
- Dart 3.0 or later
- iOS 15.0+ / Android API 24+

### Installation

1. Clone the repository:
```bash
git clone <repository-url>
cd echo_journal
```

2. Install dependencies:
```bash
flutter pub get
```

3. Set up environment variables:
```bash
cp .env.example .env
# Edit .env with your API keys
```

4. Run the app:
```bash
flutter run
```

## Environment Variables

Create a `.env` file in the root directory:

```env
# AI Services (optional - will use mock services if not provided)
AI_TRANSCRIBE_URL=your_transcription_endpoint
AI_REFLECT_URL=your_reflection_endpoint  
AI_API_KEY=your_ai_api_key

# RevenueCat (required for production)
RC_API_KEY_IOS=your_revenuecat_ios_key
RC_API_KEY_ANDROID=your_revenuecat_android_key

# Sentry (optional)
SENTRY_DSN=your_sentry_dsn
```

## RevenueCat Setup

### 1. Create Products in App Store Connect / Google Play Console

#### iOS (App Store Connect)
- Monthly subscription: `com.echojournal.premium.monthly`
- Yearly subscription: `com.echojournal.premium.yearly`
- Gratitude pack: `com.echojournal.pack.gratitude`
- Growth pack: `com.echojournal.pack.growth`

#### Android (Google Play Console)
- Monthly subscription: `premium_monthly`
- Yearly subscription: `premium_yearly`
- Gratitude pack: `pack_gratitude`
- Growth pack: `pack_growth`

### 2. Configure RevenueCat Dashboard

1. Create a new app in RevenueCat
2. Add your iOS and Android app configurations
3. Create an Entitlement called `premium`
4. Create an Offering called `default` with your subscription packages
5. Add your consumable products for Memory Packs
6. Copy your API keys to the `.env` file

## AI Services Integration

The app uses a pluggable AI architecture that can work with various providers:

### Mock Services (Default)
- Provides realistic fake transcriptions and reflections
- Perfect for development and testing
- No API keys required

### HTTP Services
- Implement your own transcription and reflection endpoints
- Expected API format:

**Transcription Endpoint**
```
POST /transcribe
Content-Type: multipart/form-data
Authorization: Bearer <API_KEY>

Body: audio file

Response: { "text": "transcribed text" }
```

**Reflection Endpoint**
```
POST /reflect
Content-Type: application/json
Authorization: Bearer <API_KEY>

Body: { "transcript": "text", "lens": "default|gratitude|growth" }

Response: { "reflection": "AI-generated reflection" }
```

## Development

### Running Tests
```bash
flutter test
```

### Code Generation (if needed)
```bash
flutter pub run build_runner build
```

### Platform-Specific Setup

#### iOS
1. Add microphone permission to `ios/Runner/Info.plist`:
```xml
<key>NSMicrophoneUsageDescription</key>
<string>We use the microphone to record your voice journal entries.</string>
```

2. Update minimum deployment target to iOS 15.0 in Xcode

#### Android
1. Permissions are already configured in the pubspec.yaml
2. Minimum SDK is set to API 24 (Android 7.0)

## Architecture Decisions

### Offline-First
- All data stored locally using Hive
- App works without internet connection
- AI services gracefully fallback to mock when offline

### State Management
- Riverpod for reactive state management
- Separate providers for different concerns
- Stream-based updates for real-time UI

### Monetization
- RevenueCat for cross-platform subscription management
- Clear free vs premium feature separation
- Consumable Memory Packs for additional revenue

### Audio Handling
- High-quality recording with configurable bitrates
- Efficient playback with seek controls
- Waveform visualization during recording

## Privacy & Security

- All audio files stored locally on device
- Transcripts processed locally or via secure HTTPS endpoints
- No personal data collected without explicit consent
- Optional telemetry via Sentry (disabled by default)

## Release Checklist

- [ ] Update version in pubspec.yaml
- [ ] Test on physical devices (iOS/Android)
- [ ] Verify RevenueCat integration
- [ ] Test all premium features
- [ ] Update screenshots
- [ ] Review privacy policy
- [ ] Submit to app stores

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Support

For support, email support@echojournal.com or create an issue in this repository. 