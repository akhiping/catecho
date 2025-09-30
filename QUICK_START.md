# 🚀 Quick Start Guide

## 🌐 Test Web App Locally (RIGHT NOW!)

```bash
cd neko-synth-diary
npm run dev
```

Open: `http://localhost:5173`

**What to test:**
1. Click ⚡ button to record
2. Allow microphone permission
3. Speak for a few seconds
4. Click stop
5. See entry in timeline
6. Click entry to view details
7. Try Premium page
8. Change theme in Settings

---

## 📱 Deploy Web App (5 Minutes)

### Option 1: Vercel (Easiest)

```bash
cd neko-synth-diary
npm i -g vercel
vercel login
vercel --prod
```

### Option 2: Netlify

```bash
cd neko-synth-diary
npm run build
# Upload dist/ folder to netlify.com
```

---

## 📲 Build Mobile App (On Mac)

### Flutter Setup

```bash
# Install Flutter (if not already)
git clone https://github.com/flutter/flutter.git -b stable
export PATH="$PATH:`pwd`/flutter/bin"

# Verify
flutter doctor
```

### iOS Build

```bash
cd /path/to/RevenueCat_Shipathon
flutter pub get
flutter build ios --release

# Or in Xcode
open ios/Runner.xcworkspace
```

### Android Build

```bash
flutter build appbundle --release
# Output: build/app/outputs/bundle/release/app-release.aab
```

---

## 🔑 Add API Keys (Optional)

### Web App

```bash
cd neko-synth-diary
cp .env.example .env
nano .env
```

Add:
```
VITE_REVENUECAT_API_KEY=your_key
```

### Flutter App

```bash
cd /path/to/RevenueCat_Shipathon
nano .env
```

Add:
```
REVENUECAT_IOS_API_KEY=appl_xxxxx
REVENUECAT_ANDROID_API_KEY=goog_xxxxx
```

---

## 🎯 What Works Right Now

### Web App ✅
- ✅ Voice recording with real microphone
- ✅ Waveform visualization
- ✅ Save to IndexedDB
- ✅ Mock AI transcription (realistic)
- ✅ Mock AI reflections
- ✅ Timeline with all entries
- ✅ Delete entries
- ✅ Beautiful pixel art UI
- ✅ Theme switcher (Cat/Dog/Rainforest)
- ✅ RevenueCat mock purchases

### Flutter App ✅
- ✅ Everything above (on iOS/Android)
- ✅ Real RevenueCat integration ready
- ✅ Daily quota system
- ✅ Premium gates
- ✅ Actual App Store ready builds

---

## 🐛 Troubleshooting

### Web: Microphone Not Working
- Must use HTTPS (or localhost)
- Check browser permissions
- Try Chrome (best support)

### Web: Build Fails
```bash
rm -rf node_modules
npm install
npm run build
```

### Flutter: Build Fails
```bash
flutter clean
flutter pub get
flutter build ios/appbundle
```

---

## 📁 File Structure (Quick Reference)

```
neko-synth-diary/
├── src/
│   ├── pages/           # Screens
│   ├── contexts/        # State (Entries, Subscription)
│   ├── services/        # Audio, AI, Billing
│   └── lib/db.ts        # IndexedDB
├── dist/                # Built app
└── package.json

RevenueCat_Shipathon/
├── lib/
│   ├── features/        # Screens
│   ├── providers/       # Riverpod
│   └── services/        # Audio, AI, Billing
├── android/             # Android config
├── ios/                 # iOS config
└── pubspec.yaml
```

---

## 🎨 Customization

### Change App Name

**Web**: Edit `neko-synth-diary/index.html`
**Mobile**: Edit `pubspec.yaml` name field

### Change Colors

**Web**: Edit `neko-synth-diary/src/index.css`
**Mobile**: Edit `lib/theme/theme.dart`

### Add Real AI

Add to `.env`:
```
VITE_TRANSCRIPTION_API_URL=https://your-api.com/transcribe
VITE_TRANSCRIPTION_API_KEY=your_key
```

Services will automatically use HTTP instead of mock!

---

## 🚢 Deploy Checklist

### Web App
- [ ] `npm run build` succeeds
- [ ] Test on localhost:5173
- [ ] Deploy to Vercel/Netlify
- [ ] Test microphone on HTTPS
- [ ] Share URL!

### Mobile App
- [ ] Add app icons
- [ ] Configure RevenueCat
- [ ] Build release
- [ ] Test on device
- [ ] Submit to stores

---

## 📞 Need Help?

1. **Web Issues**: See `neko-synth-diary/README.md`
2. **Mobile Issues**: See `APP_STORE_SUBMISSION.md`
3. **Deployment**: See `DEPLOYMENT_GUIDE.md`
4. **Everything**: See `PROJECT_SUMMARY.md`

---

## 🎉 You're Ready!

**Web app is working RIGHT NOW** - just run `npm run dev`

**Mobile app is ready** - just build and submit

**RevenueCat Shipathon Compliant** ✅

---

**Made with 🐱 - Good luck!** 