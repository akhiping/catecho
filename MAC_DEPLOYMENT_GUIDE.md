# 🍎 Mac Deployment Guide - CatEcho Journal

Complete step-by-step guide for building and submitting your app on the borrowed Mac.

---

## 📋 Prerequisites Checklist

Before you start, make sure you have:
- [ ] Apple Developer Account ($99/year) - Sign up at https://developer.apple.com
- [ ] Mac with Xcode installed
- [ ] Your GitHub repository access
- [ ] RevenueCat account

---

## Part 1: Initial Mac Setup (30 minutes)

### Step 1: Install Xcode
```bash
# Open App Store on Mac
# Search for "Xcode"
# Click "Get" or "Install" (it's free, ~12GB)
# Wait for installation (can take 20-30 minutes)

# After installation, open Xcode once to accept license
open -a Xcode
# Click "Agree" to the license agreement
```

### Step 2: Install Xcode Command Line Tools
```bash
xcode-select --install
# Click "Install" in the popup window
# Wait for completion (~5 minutes)
```

### Step 3: Install Homebrew (Mac Package Manager)
```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Follow the on-screen instructions
# Add to PATH if needed (it will tell you)
```

### Step 4: Install Flutter
```bash
# Download Flutter
cd ~/Downloads
curl -O https://storage.googleapis.com/flutter_infra_release/releases/stable/macos/flutter_macos_arm64_3.24.3-stable.zip

# Or for Intel Mac:
# curl -O https://storage.googleapis.com/flutter_infra_release/releases/stable/macos/flutter_macos_3.24.3-stable.zip

# Extract
unzip flutter_macos_*.zip
mv flutter ~/flutter

# Add to PATH
echo 'export PATH="$HOME/flutter/bin:$PATH"' >> ~/.zshrc
source ~/.zshrc

# Verify
flutter --version
```

### Step 5: Run Flutter Doctor
```bash
flutter doctor

# Install any missing dependencies it mentions
# Common fixes:
flutter doctor --android-licenses  # If you want Android too
```

---

## Part 2: Clone and Setup Project (10 minutes)

### Step 1: Clone Your Repository
```bash
cd ~/Documents
git clone git@github.com:akhiping/catecho.git
cd catecho
```

### Step 2: Install Flutter Dependencies
```bash
flutter pub get
```

### Step 3: Setup Environment Variables
```bash
# Create .env file
nano .env
```

Add these lines (replace with your actual keys):
```env
REVENUECAT_IOS_API_KEY=appl_xxxxxxxxxxxxxxxxx
REVENUECAT_ANDROID_API_KEY=goog_xxxxxxxxxxxxxxxxx
SENTRY_DSN=https://xxxxx@sentry.io/xxxxx
```

Press `Ctrl+X`, then `Y`, then `Enter` to save.

---

## Part 3: iOS App Store Setup (20 minutes)

### Step 1: Create App Store Connect App

1. Go to https://appstoreconnect.apple.com
2. Click "My Apps" → "+" → "New App"
3. Fill in:
   - **Platform**: iOS
   - **Name**: CatEcho Journal
   - **Primary Language**: English (U.S.)
   - **Bundle ID**: Create new → `com.akhiping.catecho` (or your preference)
   - **SKU**: `catecho-001`
   - **User Access**: Full Access
4. Click "Create"

### Step 2: Update iOS Bundle Identifier

```bash
# Open iOS project settings
open ios/Runner.xcworkspace
```

In Xcode:
1. Click on "Runner" (blue icon at top left)
2. Select "Runner" target
3. Go to "Signing & Capabilities" tab
4. Check "Automatically manage signing"
5. Select your Team (Apple Developer account)
6. Change Bundle Identifier to match what you created: `com.akhiping.catecho`
7. Ensure "Release" configuration is also set up

### Step 3: Configure App Icons

```bash
# You need a 1024x1024 app icon
# For now, you can use the existing placeholder or create one quickly
```

**Quick Icon Creation:**
1. Go to https://www.canva.com
2. Create 1024x1024 design with pixel cat
3. Download as PNG
4. Go to https://appicon.co
5. Upload your icon
6. Download iOS icons
7. Extract and replace in `ios/Runner/Assets.xcassets/AppIcon.appiconset/`

---

## Part 4: RevenueCat Configuration (15 minutes)

### Step 1: Create RevenueCat Project

1. Go to https://app.revenuecat.com
2. Create new project: "CatEcho Journal"
3. Add iOS app:
   - Bundle ID: `com.akhiping.catecho`
   - App name: CatEcho Journal
   - Click "Add app"

### Step 2: Add App Store Connect Shared Secret

1. In App Store Connect → App Store → App Information
2. Scroll to "App-Specific Shared Secret"
3. Click "Manage" → "Generate"
4. Copy the secret
5. In RevenueCat → Settings → Apps → iOS → Paste shared secret

### Step 3: Create Products in App Store Connect

1. Go to App Store Connect → Your App → Features → In-App Purchases
2. Create products:

**Subscriptions:**
- Click "+" → "Auto-Renewable Subscription"
- **Group Name**: Premium Access
- Create subscription group

For **Monthly**:
- **Product ID**: `premium_monthly`
- **Reference Name**: Monthly Premium
- **Subscription Duration**: 1 Month
- **Price**: $4.99
- **Localization**: Add English description

For **Annual**:
- **Product ID**: `premium_annual`
- **Reference Name**: Annual Premium
- **Subscription Duration**: 1 Year
- **Price**: $39.99
- **Localization**: Add English description

**Consumables:**
- Click "+" → "Consumable"

For **Bronze Pack**:
- **Product ID**: `memory_pack_bronze`
- **Reference Name**: Bronze Memory Pack
- **Price**: $0.99
- **Localization**: Add English description

Repeat for Silver ($2.99) and Gold ($4.99)

### Step 4: Configure RevenueCat Entitlements

1. In RevenueCat → Entitlements
2. Create entitlement: `premium`
3. Attach products:
   - `premium_monthly`
   - `premium_annual`

### Step 5: Update .env with RevenueCat Keys

```bash
nano .env
```

Add your iOS API key from RevenueCat dashboard.

---

## Part 5: Build iOS App (10 minutes)

### Step 1: Build for Testing

```bash
# Connect an iPhone (if available) or use simulator
flutter devices

# Run on device/simulator to test
flutter run
```

**Test these features:**
- [ ] Voice recording works
- [ ] Audio playback works
- [ ] Timeline displays entries
- [ ] Premium page opens
- [ ] Settings work

### Step 2: Build Release Version

```bash
# Build the iOS release
flutter build ios --release

# This creates the iOS app bundle
```

### Step 3: Create Archive in Xcode

```bash
# Open in Xcode
open ios/Runner.xcworkspace
```

In Xcode:
1. Select "Any iOS Device (arm64)" from device dropdown (top middle)
2. Go to Menu: Product → Archive
3. Wait for build (~5-10 minutes)
4. Archive Organizer will open automatically

---

## Part 6: Upload to App Store (15 minutes)

### In Xcode Archive Organizer:

1. Select your archive
2. Click "Distribute App"
3. Select "App Store Connect"
4. Click "Next"
5. Select "Upload"
6. Click "Next"
7. Leave options as default, click "Next"
8. Click "Automatically manage signing"
9. Click "Upload"
10. Wait for upload (~5-10 minutes)

You'll get a confirmation: "Upload Successful"

---

## Part 7: App Store Listing (30 minutes)

### Step 1: Add App Information

In App Store Connect → Your App:

**App Information:**
- **Subtitle**: Voice Journal with AI
- **Category**: Primary: Lifestyle, Secondary: Health & Fitness
- **Content Rights**: Check if you own rights

### Step 2: Create Screenshots

You need:
- 6.7" (iPhone 15 Pro Max): 3 screenshots minimum
- 5.5" (iPhone 8 Plus): 3 screenshots minimum

**Quick Screenshot Guide:**
```bash
# Run app in simulator
open -a Simulator
flutter run

# In simulator: Cmd+S to take screenshots
# They save to ~/Desktop

# Resize if needed using Preview app
```

Required screenshots:
1. **Timeline screen** - Show entries with pixel cat
2. **Recording screen** - Show waveform and Echo Cat
3. **Entry detail** - Show transcript and AI reflection

### Step 3: Write App Description

```
Transform your thoughts into memories with CatEcho Journal!

🎙️ VOICE JOURNALING
Record your daily thoughts, feelings, and experiences with just your voice. No typing required!

🤖 AI-POWERED INSIGHTS
Get personalized reflections and mood analysis powered by AI. Understand your emotional patterns.

🐱 RETRO AESTHETIC
Enjoy a unique pixel art interface with adorable cat mascots and vaporwave vibes.

✨ FEATURES
• Voice recording with real-time waveform visualization
• Automatic transcription of your entries
• AI mood analysis and personalized reflections (Premium)
• Beautiful retro-futuristic UI with multiple themes
• Timeline view of all your memories
• Local storage for complete privacy
• Dark mode support

🎁 PREMIUM FEATURES
• Unlimited journal entries (free tier: 1 per day)
• AI-powered mood insights and reflections
• Memory Lane throwbacks - revisit past entries
• Exclusive cat themes and customizations
• Advanced analytics and trends

📱 PRIVACY FIRST
Your voice recordings and entries are stored locally on your device. We respect your privacy.

💎 SUBSCRIPTION OPTIONS
• Monthly: $4.99/month
• Annual: $39.99/year (Save 33%!)
• Memory Packs: One-time purchases for extra entries

Download CatEcho Journal today and start your mindful journaling journey!
```

**Keywords:**
```
journal,voice,diary,ai,meditation,mindfulness,mental health,mood,therapy,wellness
```

**Support URL**: `https://github.com/akhiping/catecho`

**Privacy Policy URL**: Create simple one at https://www.privacypolicygenerator.info/

### Step 4: Add App Privacy Details

1. Click "Edit" next to "App Privacy"
2. Answer questions:
   - **Data Collection**: Yes (for audio recordings)
   - **Audio Data**: Collected, not linked to user, not used for tracking
   - **User Content**: Collected, not linked to user
3. Save

### Step 5: Submit for Review

1. Go to "App Store" tab
2. Click "+ VERSION" to create version 1.0
3. Fill in:
   - **What's New**: "Initial release of CatEcho Journal!"
   - Upload screenshots (drag and drop)
   - Add promotional text (optional)
4. In "Build" section:
   - Click "+" to select build
   - Choose the build you uploaded
   - Click "Done"
5. Fill out "General App Information"
6. Fill out "App Review Information"
   - Contact: Your email
   - Phone: Your phone
   - Notes: "Test account not needed. App works offline."
7. Click "Save"
8. Click "Submit for Review"

---

## Part 8: While Waiting for Review (Optional)

### Deploy Web Version

```bash
cd ~/Documents/catecho/neko-synth-diary

# Install Vercel CLI
npm i -g vercel

# Deploy
vercel --prod

# You'll get a URL like: https://catecho.vercel.app
```

### Create Google Play Store Listing (If You Want Android Too)

```bash
# Build Android
flutter build appbundle --release

# Output will be at:
# build/app/outputs/bundle/release/app-release.aab
```

Upload to Google Play Console (similar process to iOS)

---

## Part 9: Submit to RevenueCat Shipathon

### Required Information:

1. **App Name**: CatEcho Journal
2. **GitHub Repo**: https://github.com/akhiping/catecho
3. **Live Demo**: 
   - Web: https://catecho.vercel.app (if deployed)
   - iOS: App Store link (after approval)
4. **Description**: 
   ```
   CatEcho Journal is a retro-futuristic voice journaling app featuring:
   - Real-time voice recording with waveform visualization
   - AI-powered transcription and mood analysis
   - RevenueCat subscriptions ($4.99/mo, $39.99/yr) and consumables
   - Beautiful pixel art UI with vaporwave aesthetics
   - Cross-platform (Web + iOS)
   - Built in 5 days for the RevenueCat Shipathon!
   ```
5. **RevenueCat Integration**: 
   - 2 subscription products
   - 3 consumable products
   - Premium entitlement configured
6. **Tech Stack**: Flutter, React, RevenueCat, IndexedDB, Web Audio API

Submit at: https://www.revenuecat.com/shipathon (or wherever they specify)

---

## ⏱️ Timeline Summary

- ✅ **Mac Setup**: 30 minutes
- ✅ **Project Setup**: 10 minutes
- ✅ **App Store Setup**: 20 minutes
- ✅ **RevenueCat Config**: 15 minutes
- ✅ **Build App**: 10 minutes
- ✅ **Upload**: 15 minutes
- ✅ **App Store Listing**: 30 minutes
- ✅ **Web Deploy**: 10 minutes (optional)

**Total: ~2-3 hours** (most time is waiting for builds/uploads)

---

## 🆘 Troubleshooting

### Build Fails
```bash
flutter clean
flutter pub get
flutter build ios --release
```

### Signing Issues
- Make sure you're logged into Xcode with your Apple ID
- Check "Automatically manage signing" in Xcode
- Try creating a new certificate in developer.apple.com

### RevenueCat Not Working
- Verify product IDs match exactly
- Check shared secret is added
- Wait 2-3 hours after creating products (App Store delay)

### Upload Fails
- Check bundle identifier matches everywhere
- Ensure version number is correct
- Try archiving again

---

## 📞 Need Help?

- **Flutter Issues**: https://docs.flutter.dev
- **Xcode Issues**: https://developer.apple.com/support
- **RevenueCat**: https://docs.revenuecat.com
- **App Store**: https://developer.apple.com/app-store

---

## 🎉 Congratulations!

Once approved (usually 24-48 hours), CatEcho Journal will be live on the App Store!

**You'll have:**
- ✅ Live iOS app on App Store
- ✅ Live web app (if deployed)
- ✅ Complete codebase on GitHub
- ✅ RevenueCat integration working
- ✅ Shipathon submission complete

**Good luck! 🚀🐱✨** 