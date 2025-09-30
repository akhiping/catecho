# 🚀 CatEcho Journal - Deployment Guide

Complete guide for deploying both the web app and Flutter mobile app to production.

---

## 📦 Web App Deployment (Neko-Synth Diary)

### Prerequisites
- Node.js 16+ installed
- GitHub account (for version control)
- Hosting account (Vercel/Netlify recommended)

### 1. Prepare for Deployment

```bash
cd neko-synth-diary

# Install dependencies
npm install

# Create production environment file
cp .env.example .env

# Add your production API keys
nano .env
```

### 2. Environment Configuration

Update `.env` with production values:

```env
VITE_REVENUECAT_API_KEY=pk_xxxxxxxxxxxxxxx
VITE_TRANSCRIPTION_API_URL=https://your-api.com/transcribe
VITE_TRANSCRIPTION_API_KEY=your_key
VITE_REFLECTION_API_URL=https://your-api.com/reflect
VITE_REFLECTION_API_KEY=your_key
```

### 3. Build for Production

```bash
npm run build

# Test production build locally
npm run preview
```

### 4. Deploy to Vercel (Recommended)

#### Option A: Vercel CLI

```bash
# Install Vercel CLI
npm i -g vercel

# Login
vercel login

# Deploy
vercel --prod
```

#### Option B: Vercel Dashboard

1. Go to [vercel.com](https://vercel.com)
2. Click "Add New Project"
3. Import from Git or upload `dist/` folder
4. Configure:
   - **Framework**: Vite
   - **Build Command**: `npm run build`
   - **Output Directory**: `dist`
   - **Install Command**: `npm install`
5. Add environment variables in Settings → Environment Variables
6. Deploy!

### 5. Deploy to Netlify

#### Option A: Netlify CLI

```bash
# Install Netlify CLI
npm i -g netlify-cli

# Login
netlify login

# Deploy
netlify deploy --prod --dir=dist
```

#### Option B: Netlify Dashboard

1. Go to [netlify.com](https://netlify.com)
2. Drag and drop `dist/` folder
3. Or connect to Git repository
4. Configure build settings:
   - **Build command**: `npm run build`
   - **Publish directory**: `dist`
5. Add environment variables in Site settings → Environment
6. Deploy!

### 6. Custom Domain Setup

#### Vercel:
1. Go to Project Settings → Domains
2. Add your domain
3. Configure DNS records as shown
4. Wait for verification (5-60 minutes)

#### Netlify:
1. Go to Site settings → Domain management
2. Add custom domain
3. Update DNS records
4. Enable HTTPS (automatic)

### 7. Post-Deployment Checklist

- [ ] Test microphone permissions (requires HTTPS)
- [ ] Verify recording functionality
- [ ] Test audio playback
- [ ] Check RevenueCat integration
- [ ] Test on mobile browsers
- [ ] Verify AI transcription (if configured)
- [ ] Test all routes and navigation
- [ ] Check console for errors

---

## 📱 Flutter App Deployment (iOS & Android)

### Prerequisites
- Flutter SDK installed
- Xcode (for iOS) or Android Studio
- Apple Developer Account ($99/year)
- Google Play Console Account ($25 one-time)

### Part 1: iOS App Store

#### 1. Configure RevenueCat

```bash
cd RevenueCat_Shipathon

# Add RevenueCat API keys
nano .env
```

Update `.env`:
```
REVENUECAT_IOS_API_KEY=appl_xxxxxxxxxx
REVENUECAT_ANDROID_API_KEY=goog_xxxxxxxxxx
SENTRY_DSN=https://xxxxx@sentry.io/xxxxx
```

#### 2. Update iOS Configuration

Edit `ios/Runner/Info.plist`:

```xml
<key>CFBundleDisplayName</key>
<string>CatEcho Journal</string>

<key>CFBundleIdentifier</key>
<string>com.echojournal.app</string>

<key>CFBundleVersion</key>
<string>1</string>

<key>CFBundleShortVersionString</key>
<string>1.0.0</string>
```

#### 3. Create App Icons

Use [appicon.co](https://appicon.co) or similar:

1. Design 1024x1024 icon
2. Generate all sizes
3. Replace in `ios/Runner/Assets.xcassets/AppIcon.appiconset/`

#### 4. Build iOS App

```bash
# On Mac with Xcode
flutter build ios --release

# Or create archive in Xcode
open ios/Runner.xcworkspace
```

In Xcode:
1. Select "Any iOS Device"
2. Product → Archive
3. Wait for build to complete
4. Click "Distribute App"
5. Choose "App Store Connect"
6. Follow wizard

#### 5. Upload to App Store

1. Go to [App Store Connect](https://appstoreconnect.apple.com)
2. Create new app
3. Fill in metadata:
   - **Name**: CatEcho Journal
   - **Subtitle**: Voice Journal with AI
   - **Category**: Lifestyle / Health & Fitness
   - **Age Rating**: 4+
4. Upload screenshots (see APP_STORE_SUBMISSION.md)
5. Add description:

```
Transform your thoughts into memories with CatEcho Journal!

🎙️ VOICE JOURNALING
Record your daily thoughts, feelings, and experiences with just your voice.

🤖 AI-POWERED INSIGHTS
Get personalized reflections and mood analysis powered by AI.

🐱 RETRO AESTHETIC
Enjoy a unique pixel art interface with adorable cat mascots.

✨ FEATURES
• Voice recording with real-time waveform
• Automatic transcription
• AI mood analysis (Premium)
• Beautiful retro-futuristic UI
• Multiple themes
• Privacy-focused (local storage)

🎁 PREMIUM
Unlock unlimited entries, AI insights, and exclusive features!
```

6. Submit for review

### Part 2: Google Play Store

#### 1. Configure Android

Edit `android/app/build.gradle`:

```gradle
android {
    defaultConfig {
        applicationId "com.echojournal.app"
        minSdkVersion 21
        targetSdkVersion 34
        versionCode 1
        versionName "1.0.0"
    }
}
```

#### 2. Create Keystore

```bash
keytool -genkey -v -keystore ~/catecho-release.jks \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -alias catecho
```

Create `android/key.properties`:

```
storePassword=your_store_password
keyPassword=your_key_password
keyAlias=catecho
storeFile=/path/to/catecho-release.jks
```

#### 3. Build Android App

```bash
flutter build appbundle --release
```

Output: `build/app/outputs/bundle/release/app-release.aab`

#### 4. Upload to Google Play

1. Go to [Play Console](https://play.google.com/console)
2. Create new app
3. Fill in store listing:
   - **App name**: CatEcho Journal
   - **Short description**: Voice journal with AI insights
   - **Full description**: (same as iOS)
   - **Category**: Lifestyle
   - **Content rating**: ESRB Everyone
4. Upload App Bundle
5. Set up pricing & distribution
6. Submit for review

### Part 3: RevenueCat Products Setup

#### 1. Create Products in App Store Connect

**Subscriptions:**
- **premium_monthly**
  - Price: $4.99/month
  - Auto-renewable
  - Group: Premium Access

- **premium_annual**
  - Price: $39.99/year
  - Auto-renewable
  - Group: Premium Access

**Consumables:**
- **memory_pack_bronze** - $0.99
- **memory_pack_silver** - $2.99
- **memory_pack_gold** - $4.99

#### 2. Create Products in Google Play Console

Same products with equivalent pricing in local currency.

#### 3. Configure in RevenueCat

1. Go to [RevenueCat Dashboard](https://app.revenuecat.com)
2. Create project: "CatEcho Journal"
3. Add iOS App:
   - Bundle ID: `com.echojournal.app`
   - Shared Secret from App Store Connect
4. Add Android App:
   - Package Name: `com.echojournal.app`
   - Service Account JSON
5. Create Products:
   - Link iOS and Android product IDs
   - Set up Entitlements: `premium`
6. Create Offerings:
   - Default Offering
   - Add packages (monthly, annual, memory packs)

### Part 4: Testing

#### iOS TestFlight

1. In App Store Connect → TestFlight
2. Add internal testers
3. Upload build via Xcode
4. Wait for processing
5. Invite testers via email

#### Android Internal Testing

1. In Play Console → Internal testing
2. Create release
3. Upload AAB
4. Add tester emails
5. Share opt-in link

### Part 5: Post-Launch

#### Monitoring

1. **Sentry** - Track crashes and errors
2. **RevenueCat** - Monitor subscriptions
3. **App Store Connect** - Downloads and reviews
4. **Google Play Console** - Installs and ratings

#### Updates

```bash
# Bump version
# Update pubspec.yaml version: 1.0.0+1 → 1.0.1+2

# Build and upload
flutter build ios --release
flutter build appbundle --release

# Submit to stores
```

---

## 🔄 CI/CD Setup (Optional)

### GitHub Actions for Web

Create `.github/workflows/deploy.yml`:

```yaml
name: Deploy Web App

on:
  push:
    branches: [main]
    paths:
      - 'neko-synth-diary/**'

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: actions/setup-node@v3
        with:
          node-version: 18
      - name: Install and Build
        run: |
          cd neko-synth-diary
          npm install
          npm run build
      - name: Deploy to Vercel
        uses: amondnet/vercel-action@v20
        with:
          vercel-token: ${{ secrets.VERCEL_TOKEN }}
          vercel-org-id: ${{ secrets.VERCEL_ORG_ID }}
          vercel-project-id: ${{ secrets.VERCEL_PROJECT_ID }}
          working-directory: ./neko-synth-diary
```

### Fastlane for Mobile (iOS/Android)

Setup Fastlane for automated builds and uploads.

---

## 📊 Analytics & Monitoring

### Web Analytics

Add to `index.html`:

```html
<!-- Google Analytics -->
<script async src="https://www.googletagmanager.com/gtag/js?id=G-XXXXXXXXXX"></script>
<script>
  window.dataLayer = window.dataLayer || [];
  function gtag(){dataLayer.push(arguments);}
  gtag('js', new Date());
  gtag('config', 'G-XXXXXXXXXX');
</script>
```

### Mobile Analytics

Already configured with Sentry in Flutter app.

---

## ✅ Launch Checklist

### Web App
- [ ] Domain configured and SSL enabled
- [ ] Environment variables set
- [ ] RevenueCat integrated and tested
- [ ] Microphone permissions working
- [ ] Responsive on all devices
- [ ] SEO meta tags added
- [ ] Privacy policy published
- [ ] Terms of service published

### iOS App
- [ ] App icons added
- [ ] Screenshots uploaded
- [ ] Privacy policy URL added
- [ ] Support URL configured
- [ ] In-app purchases configured
- [ ] RevenueCat tested in sandbox
- [ ] TestFlight beta testing complete
- [ ] Submitted for review

### Android App
- [ ] App icons added
- [ ] Screenshots uploaded (multiple devices)
- [ ] Content rating completed
- [ ] Privacy policy URL added
- [ ] In-app purchases configured
- [ ] RevenueCat tested
- [ ] Internal testing complete
- [ ] Submitted for review

---

## 🆘 Troubleshooting

### Web Deployment Issues

**Build fails:**
```bash
rm -rf node_modules package-lock.json
npm install
npm run build
```

**Environment variables not working:**
- Ensure prefix is `VITE_`
- Rebuild after changing .env
- Check deployment platform env vars

### Mobile Deployment Issues

**iOS Build fails:**
- Update CocoaPods: `pod repo update`
- Clean: `flutter clean && flutter pub get`
- Check Xcode version compatibility

**Android Build fails:**
- Update Gradle: Edit `android/gradle/wrapper/gradle-wrapper.properties`
- Sync: `flutter pub get`
- Check Java version (use Java 11)

**RevenueCat not working:**
- Verify API keys are correct
- Check product IDs match exactly
- Test in sandbox mode first
- Ensure entitlements are configured

---

## 📞 Support

- **RevenueCat**: [docs.revenuecat.com](https://docs.revenuecat.com)
- **Flutter**: [docs.flutter.dev](https://docs.flutter.dev)
- **Vercel**: [vercel.com/docs](https://vercel.com/docs)
- **App Store**: [developer.apple.com](https://developer.apple.com)
- **Play Store**: [support.google.com/googleplay](https://support.google.com/googleplay)

---

**Good luck with your launch! 🚀🐱** 