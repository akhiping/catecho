# 📱 EchoJournal - App Store Submission Guide

## Overview
EchoJournal is a voice journaling app that transforms spoken thoughts into written entries with AI-powered insights. This guide covers the complete submission process for iOS App Store and Google Play Store.

---

## 🎯 RevenueCat Shipathon Requirements

✅ **Brand new app** (not an update)  
✅ **RevenueCat SDK integrated** for subscriptions and consumables  
✅ **Submission deadline**: September 30th, 2025  
✅ **Target platforms**: iOS and/or Android  

---

## 📋 Pre-Submission Checklist

### 1. RevenueCat Configuration

#### A. Create RevenueCat Account
1. Sign up at [revenuecat.com](https://www.revenuecat.com)
2. Create a new project: "EchoJournal"
3. Get your API keys:
   - iOS API Key
   - Android API Key

#### B. Configure Products

**Subscriptions:**
- `premium_monthly` - $4.99/month - "Premium Monthly"
- `premium_yearly` - $39.99/year - "Premium Yearly" (save 33%)

**Consumables (Memory Packs):**
- `pack_bronze` - $0.99 - "Bronze Memory Pack" - 5 AI reflections
- `pack_silver` - $2.99 - "Silver Memory Pack" - 15 AI reflections  
- `pack_gold` - $4.99 - "Gold Memory Pack" - 30 AI reflections

#### C. Configure Offerings
Create an offering called "default" with:
- Monthly package (premium_monthly)
- Annual package (premium_yearly)

#### D. Update Environment Variables
Update `.env` file:
```
REVENUECAT_IOS_KEY=your_ios_api_key_here
REVENUECAT_ANDROID_KEY=your_android_api_key_here
```

---

### 2. App Store Connect Setup (iOS)

#### A. Prerequisites
- Apple Developer Account ($99/year)
- Mac with Xcode installed
- Valid certificates and provisioning profiles

#### B. Create App in App Store Connect
1. Go to [App Store Connect](https://appstoreconnect.apple.com)
2. Create new app:
   - **Name**: EchoJournal
   - **Bundle ID**: com.echojournal.app
   - **SKU**: echo_journal_001
   - **Primary Language**: English

#### C. Configure In-App Purchases
Create subscriptions and consumables matching RevenueCat configuration:

**Auto-Renewable Subscriptions:**
- Product ID: `premium_monthly`
- Reference Name: Premium Monthly
- Duration: 1 Month
- Price: $4.99

- Product ID: `premium_yearly`
- Reference Name: Premium Yearly
- Duration: 1 Year
- Price: $39.99

**Consumables:**
- Product ID: `pack_bronze`, Price: $0.99
- Product ID: `pack_silver`, Price: $2.99
- Product ID: `pack_gold`, Price: $4.99

#### D. App Information
- **Category**: Health & Fitness
- **Subcategory**: Health & Fitness
- **Content Rights**: Check if using third-party content
- **Age Rating**: 4+

---

### 3. Google Play Console Setup (Android)

#### A. Prerequisites
- Google Play Developer Account ($25 one-time fee)
- Android keystore for signing

#### B. Create App
1. Go to [Google Play Console](https://play.google.com/console)
2. Create new app:
   - **App name**: EchoJournal
   - **Default language**: English
   - **App or game**: App
   - **Free or paid**: Free

#### C. Configure In-App Products
Go to Monetization > Products:

**Subscriptions:**
- Product ID: `premium_monthly`, Price: $4.99
- Product ID: `premium_yearly`, Price: $39.99

**In-app products:**
- Product ID: `pack_bronze`, Price: $0.99
- Product ID: `pack_silver`, Price: $2.99
- Product ID: `pack_gold`, Price: $4.99

---

### 4. App Assets

#### A. App Icons
Required sizes (generate using a tool like [appicon.co](https://appicon.co)):
- **iOS**: 1024x1024 (App Store), various sizes for device
- **Android**: 512x512 (Play Store), various densities

Create a simple, memorable icon with:
- Microphone symbol
- Modern gradient (blue to purple, matching app theme)
- Clean, minimal design

#### B. Screenshots
Required for both stores (use FlutLab emulator or actual devices):

**iOS:**
- 6.7" iPhone (1290 x 2796): 3-10 screenshots
- 5.5" iPhone (1242 x 2208): 3-10 screenshots

**Android:**
- Phone: 1080 x 1920 minimum, at least 2 screenshots

**Screenshot Content:**
1. Timeline with journal entries
2. Recording screen in action
3. Entry detail with AI reflection
4. Premium paywall
5. Settings screen

#### C. Store Listing

**App Name:**
```
EchoJournal - Voice Journal
```

**Short Description (80 chars):**
```
Transform your voice into meaningful journal entries with AI insights
```

**Long Description:**
```
🎙️ Speak Your Mind, See Your Story

EchoJournal makes journaling effortless. Just press record and speak - your thoughts are instantly transformed into beautifully formatted journal entries with AI-powered insights.

✨ KEY FEATURES

• Voice Recording: Capture your thoughts naturally by speaking
• AI Transcription: Automatic, accurate speech-to-text conversion
• Smart Reflections: Get AI-generated insights from your entries
• Memory Lane: Revisit meaningful moments with throwback features
• Mood Tracking: Automatic sentiment analysis of your entries
• Beautiful Timeline: View your journal in a clean, intuitive interface
• Dark Mode: Easy on the eyes, day or night
• Privacy First: Your entries are stored securely on your device

💎 PREMIUM FEATURES

Upgrade to Premium to unlock:
• Unlimited daily entries (vs 1 on free plan)
• AI-powered reflections and mood insights
• Memory Lane throwback feature
• Extended recording time
• Priority support

📝 PERFECT FOR

• Daily journaling and reflection
• Gratitude practice
• Mental health tracking
• Creative writing
• Thought organization
• Personal growth

🔒 YOUR PRIVACY MATTERS

Your journal entries are private and stored securely on your device. We never access or share your personal content.

Start your journaling journey today with EchoJournal!

---

Subscription Information:
• Monthly Premium: $4.99/month
• Yearly Premium: $39.99/year (save 33%)
• Payment charged to App Store/Google Play account
• Auto-renewal unless turned off 24 hours before period ends
• Manage in account settings

Privacy Policy: [Add your URL]
Terms of Service: [Add your URL]
```

**Keywords (iOS, comma-separated):**
```
journal,voice,audio,diary,reflection,ai,transcription,mood,meditation,gratitude
```

**Promotional Text (iOS, 170 chars):**
```
New: AI-powered mood insights help you understand your emotional patterns. Premium users get unlimited entries and advanced features!
```

---

### 5. Build and Submit

#### A. iOS Build Process

1. **Open Xcode**:
```bash
cd ios
open Runner.xcworkspace
```

2. **Configure signing**:
   - Select Runner target
   - Go to Signing & Capabilities
   - Choose your team
   - Ensure bundle ID matches: com.echojournal.app

3. **Update version**:
   - In pubspec.yaml: `version: 1.0.0+1`
   - In Xcode: Version 1.0.0, Build 1

4. **Build for release**:
```bash
flutter build ios --release
```

5. **Archive and upload**:
   - Product > Archive in Xcode
   - Distribute App > App Store Connect
   - Upload

6. **Submit for Review**:
   - Go to App Store Connect
   - Select your app > TestFlight
   - After testing, submit for review

#### B. Android Build Process

1. **Create keystore** (first time only):
```bash
keytool -genkey -v -keystore ~/echo-journal-key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias echo-journal
```

2. **Configure signing**:
Create `android/key.properties`:
```
storePassword=your_store_password
keyPassword=your_key_password
keyAlias=echo-journal
storeFile=/path/to/echo-journal-key.jks
```

3. **Update build.gradle**:
Add signing config to `android/app/build.gradle` (already configured in our project)

4. **Build AAB**:
```bash
flutter build appbundle --release
```

5. **Upload to Play Console**:
   - Go to Google Play Console
   - Select app > Production > Create new release
   - Upload `build/app/outputs/bundle/release/app-release.aab`
   - Fill in release notes
   - Submit for review

---

### 6. Testing Checklist

Before submission, test thoroughly:

- [ ] Voice recording works on real devices
- [ ] Audio playback functions correctly
- [ ] RevenueCat subscriptions can be purchased (sandbox)
- [ ] RevenueCat consumables can be purchased (sandbox)
- [ ] Restore purchases works
- [ ] Daily quota limits are enforced
- [ ] Premium features unlock after purchase
- [ ] Timeline displays entries correctly
- [ ] Entry details show full information
- [ ] Settings persist correctly
- [ ] Dark mode works properly
- [ ] App doesn't crash on background/foreground
- [ ] Permissions are requested properly
- [ ] Offline functionality works

---

### 7. Review Preparation

#### A. Demo Video
Prepare a short demo (1-2 minutes) showing:
1. Opening the app
2. Recording a voice entry
3. Viewing the transcription
4. Seeing AI reflection
5. Timeline navigation
6. Premium paywall (optional)

#### B. Test Account
Provide reviewers with:
- Email: reviewer@echojournal.com
- Password: ReviewTest123!
- Note: Pre-loaded with sample data

#### C. Review Notes
```
Thank you for reviewing EchoJournal!

To test recording:
1. Grant microphone permission when prompted
2. Tap the microphone FAB to start recording
3. Speak naturally for 5-10 seconds
4. Tap stop to save the entry
5. View your entry in the timeline

To test premium features:
1. Tap "Premium" in the app bar or settings
2. Use the test subscription (sandbox mode)
3. After purchase, unlimited entries and AI features unlock

The app uses RevenueCat for subscription management. All purchases are handled through official Apple/Google APIs.

No special configuration needed. Microphone permission is required for core functionality.
```

---

### 8. Post-Submission

#### A. Monitor Status
- Check App Store Connect / Play Console daily
- Respond to any reviewer questions within 24 hours

#### B. After Approval
- Announce on social media
- Submit to RevenueCat Shipathon
- Monitor analytics and crash reports
- Gather user feedback

#### C. RevenueCat Shipathon Submission
1. Go to RevenueCat Shipathon page
2. Submit your app store link
3. Provide required information:
   - App name
   - Store link
   - Description
   - Screenshot showing RevenueCat integration

---

## 🎉 Launch Day Checklist

- [ ] App is live on store(s)
- [ ] RevenueCat products are active
- [ ] Test real purchases (use test account)
- [ ] Submit to RevenueCat Shipathon
- [ ] Share on social media
- [ ] Monitor for crashes/bugs
- [ ] Respond to initial reviews

---

## 📞 Support Resources

- **RevenueCat Docs**: https://docs.revenuecat.com
- **Apple Developer**: https://developer.apple.com/support
- **Google Play Support**: https://support.google.com/googleplay/android-developer
- **Flutter Docs**: https://docs.flutter.dev

---

## 🚀 Quick Start for Testing

For immediate testing in FlutLab:
1. The app runs in mock mode on web
2. Recording is simulated with realistic behavior
3. RevenueCat uses test mode
4. All UI and navigation flows are functional

For real device testing:
1. Connect iOS/Android device
2. Run: `flutter run --release`
3. Test actual voice recording
4. Test sandbox purchases

---

Good luck with your submission! 🎊 