# 🚀 NutriLens Pro - Complete Setup Guide

This guide will walk you through setting up **NutriLens Pro** from scratch to publishing on Google Play Store and Apple App Store.

## 📋 Table of Contents

1. [Prerequisites](#prerequisites)
2. [Initial Setup](#initial-setup)
3. [Google AdMob Configuration](#google-admob-configuration)
4. [In-App Purchase Setup](#in-app-purchase-setup)
5. [Android Release Build](#android-release-build)
6. [iOS Release Build](#ios-release-build)
7. [Testing Checklist](#testing-checklist)
8. [Store Submission](#store-submission)

---

## Prerequisites

### Required Software

- **Flutter SDK** (3.0.0 or higher)
  ```bash
  flutter --version
  ```

- **Android Studio** (for Android development)
  - Download: https://developer.android.com/studio

- **Xcode** (for iOS development, macOS only)
  - Download from Mac App Store

- **VS Code or Android Studio** (recommended IDEs)

### Required Accounts

1. **Google AdMob Account**
   - Sign up: https://admob.google.com/

2. **Google Play Console** (for Android)
   - Sign up: https://play.google.com/console/
   - One-time fee: $25

3. **Apple Developer Program** (for iOS)
   - Sign up: https://developer.apple.com/programs/
   - Annual fee: $99/year

---

## Initial Setup

### Step 1: Create Flutter Project

```bash
# Create new Flutter project
flutter create nutrilens_pro
cd nutrilens_pro

# Or clone this repository
git clone <your-repo-url>
cd nutrilens_pro
```

### Step 2: Copy All Files

Copy all the provided files to your project:

```
nutrilens_pro/
├── lib/
│   ├── main.dart
│   ├── core/
│   ├── data/
│   └── presentation/
├── android/
├── ios/
├── pubspec.yaml
└── README.md
```

### Step 3: Install Dependencies

```bash
# Get all packages
flutter pub get

# Generate code for Hive adapters
flutter pub run build_runner build --delete-conflicting-outputs
```

### Step 4: Verify Setup

```bash
# Check for issues
flutter doctor -v

# Run the app in debug mode
flutter run
```

---

## Google AdMob Configuration

### Step 1: Create AdMob Account

1. Go to https://admob.google.com/
2. Sign in with your Google account
3. Click **"Get Started"**
4. Accept the terms and conditions

### Step 2: Create an App in AdMob

1. In AdMob console, click **"Apps"** → **"Add App"**
2. Choose **"No"** for "Is your app listed on a supported app store?"
3. Enter app name: **NutriLens Pro**
4. Select platform: **Android** or **iOS**
5. Click **"Add"** - You'll get an **App ID**

**Example App ID format:**
- Android: `ca-app-pub-1234567890123456~0987654321`
- iOS: `ca-app-pub-1234567890123456~1234567890`

### Step 3: Create Ad Units

#### Banner Ad Unit

1. Go to **"Ad units"** → **"Add ad unit"**
2. Select **"Banner"**
3. Name: `NutriLens Banner`
4. Click **"Create ad unit"**
5. Copy the **Ad unit ID**

#### Interstitial Ad Unit

1. Go to **"Ad units"** → **"Add ad unit"**
2. Select **"Interstitial"**
3. Name: `NutriLens Interstitial`
4. Click **"Create ad unit"**
5. Copy the **Ad unit ID**

**Example Ad Unit ID format:**
- Banner: `ca-app-pub-1234567890123456/1234567890`
- Interstitial: `ca-app-pub-1234567890123456/0987654321`

### Step 4: Update Android Configuration

1. Open `android/app/src/main/AndroidManifest.xml`
2. Replace the test App ID with your actual App ID:

```xml
<meta-data
    android:name="com.google.android.gms.ads.APPLICATION_ID"
    android:value="ca-app-pub-XXXXXXXXXXXXXXXX~YYYYYYYYYY"/>
```

3. Open `lib/data/services/ad_service.dart`
4. Replace Ad Unit IDs:

```dart
static String get bannerAdUnitId {
  if (Platform.isAndroid) {
    return 'ca-app-pub-XXXXXXXXXXXXXXXX/YYYYYYYYYY'; // Your banner ID
  } else if (Platform.isIOS) {
    return 'ca-app-pub-XXXXXXXXXXXXXXXX/ZZZZZZZZZZ'; // Your iOS banner ID
  }
  throw UnsupportedError('Unsupported platform');
}

static String get interstitialAdUnitId {
  if (Platform.isAndroid) {
    return 'ca-app-pub-XXXXXXXXXXXXXXXX/AAAAAAAAAA'; // Your interstitial ID
  } else if (Platform.isIOS) {
    return 'ca-app-pub-XXXXXXXXXXXXXXXX/BBBBBBBBBB'; // Your iOS interstitial ID
  }
  throw UnsupportedError('Unsupported platform');
}
```

### Step 5: Update iOS Configuration

1. Open `ios/Runner/Info.plist`
2. Replace the AdMob App ID:

```xml
<key>GADApplicationIdentifier</key>
<string>ca-app-pub-XXXXXXXXXXXXXXXX~YYYYYYYYYY</string>
```

### Testing Ads

**Important:** Always use test IDs during development!

Test IDs are already in the code by default:
- Banner (Android): `ca-app-pub-3940256099942544/6300978111`
- Interstitial (Android): `ca-app-pub-3940256099942544/1033173712`
- Banner (iOS): `ca-app-pub-3940256099942544/2934735716`
- Interstitial (iOS): `ca-app-pub-3940256099942544/4411468910`

Replace with production IDs only before release!

---

## In-App Purchase Setup

### Google Play Store (Android)

#### Step 1: Create App in Google Play Console

1. Go to https://play.google.com/console/
2. Click **"Create app"**
3. Fill in app details:
   - App name: **NutriLens Pro**
   - Default language: English
   - App or game: App
   - Free or paid: Free

#### Step 2: Setup In-App Products

1. Go to **"Monetize"** → **"In-app products"** → **"Create product"**
2. Create three products:

**Product 1: Small Donation**
- Product ID: `donation_small`
- Name: `Small Donation`
- Description: `Support development with a small donation`
- Price: `$0.99`
- Status: Active

**Product 2: Medium Donation**
- Product ID: `donation_medium`
- Name: `Medium Donation`
- Description: `Support development with a medium donation`
- Price: `$2.99`
- Status: Active

**Product 3: Large Donation**
- Product ID: `donation_large`
- Name: `Large Donation`
- Description: `Support development with a large donation`
- Price: `$4.99`
- Status: Active

#### Step 3: Setup License Testers

1. Go to **"Setup"** → **"License testing"**
2. Add test Gmail accounts
3. Choose response: **"RESPOND_NORMALLY"**

### Apple App Store (iOS)

#### Step 1: Create App in App Store Connect

1. Go to https://appstoreconnect.apple.com/
2. Click **"My Apps"** → **"+"** → **"New App"**
3. Fill in app details:
   - Platform: iOS
   - Name: **NutriLens Pro**
   - Primary Language: English
   - Bundle ID: Create new (e.g., `com.yourcompany.nutrilens`)
   - SKU: `nutrilens-pro-001`

#### Step 2: Setup In-App Purchases

1. Go to your app → **"In-App Purchases"** → **"+"**
2. Select **"Consumable"**
3. Create three products:

**Product 1:**
- Reference Name: `Small Donation`
- Product ID: `donation_small`
- Price: Tier 1 ($0.99)

**Product 2:**
- Reference Name: `Medium Donation`
- Product ID: `donation_medium`
- Price: Tier 3 ($2.99)

**Product 3:**
- Reference Name: `Large Donation`
- Product ID: `donation_large`
- Price: Tier 5 ($4.99)

4. For each product, add:
   - Display name
   - Description
   - Review screenshot (optional)

#### Step 3: Setup Sandbox Testers

1. Go to **"Users and Access"** → **"Sandbox"** → **"Testers"**
2. Add test Apple IDs
3. Use these accounts to test purchases

### Update Product IDs in Code

If you used different product IDs, update `lib/data/services/iap_service.dart`:

```dart
static const String smallDonationId = 'donation_small';
static const String mediumDonationId = 'donation_medium';
static const String largeDonationId = 'donation_large';
```

---

## Android Release Build

### Step 1: Create Keystore

```bash
# Generate keystore
keytool -genkey -v -keystore ~/nutrilens-release-key.jks \
  -keyalg RSA -keysize 2048 -validity 10000 -alias nutrilens

# You'll be asked for:
# - Keystore password (remember this!)
# - Key password (can be same as keystore)
# - Your name, organization, location, etc.
```

### Step 2: Create key.properties

Create `android/key.properties`:

```properties
storePassword=YOUR_KEYSTORE_PASSWORD
keyPassword=YOUR_KEY_PASSWORD
keyAlias=nutrilens
storeFile=/Users/yourname/nutrilens-release-key.jks
```

**Important:** Add `key.properties` to `.gitignore`!

### Step 3: Update App Details

Edit `android/app/build.gradle`:

```gradle
defaultConfig {
    applicationId "com.yourcompany.nutrilens_pro" // Change this
    minSdk 21
    targetSdk 34
    versionCode 1
    versionName "1.0.0"
}
```

### Step 4: Build Release APK/AAB

```bash
# Build APK (for testing)
flutter build apk --release

# Build AAB (for Play Store)
flutter build appbundle --release
```

Output:
- APK: `build/app/outputs/flutter-apk/app-release.apk`
- AAB: `build/app/outputs/bundle/release/app-release.aab`

---

## iOS Release Build

### Step 1: Open Xcode

```bash
open ios/Runner.xcworkspace
```

### Step 2: Configure Signing

1. Select **Runner** in project navigator
2. Select **Runner** target
3. Go to **"Signing & Capabilities"**
4. Check **"Automatically manage signing"**
5. Select your **Team**
6. Bundle Identifier will auto-fill

### Step 3: Update Bundle Identifier

If needed, change bundle identifier in Xcode:
- Example: `com.yourcompany.nutrilenspro`

### Step 4: Update Version

In Xcode, update:
- Version: `1.0.0`
- Build: `1`

### Step 5: Build for Release

```bash
# Archive and build IPA
flutter build ipa --release
```

Output: `build/ios/archive/Runner.xcarchive`

### Step 6: Upload to App Store

1. Open Xcode
2. **Product** → **Archive**
3. Once archived, click **"Distribute App"**
4. Select **"App Store Connect"**
5. Follow the wizard to upload

---

## Testing Checklist

### Before Release Testing

- [ ] Replace all test AdMob IDs with production IDs
- [ ] Test on real Android device
- [ ] Test on real iOS device
- [ ] Test barcode scanning
- [ ] Test product detail display
- [ ] Test favorites functionality
- [ ] Test history functionality
- [ ] Test search functionality
- [ ] Test theme switching
- [ ] Test banner ads display
- [ ] Test interstitial ads show correctly
- [ ] Test all IAP products
- [ ] Test offline caching
- [ ] Test share functionality
- [ ] Check for memory leaks
- [ ] Check for crashes

### Performance Testing

- [ ] App launches in < 3 seconds
- [ ] Smooth scrolling (60 FPS)
- [ ] No lag during barcode scanning
- [ ] API calls complete quickly
- [ ] Images load efficiently

---

## Store Submission

### Google Play Store

#### Prepare Assets

1. **App Icon:** 512x512 PNG
2. **Feature Graphic:** 1024x500 PNG
3. **Screenshots:** 
   - Phone: At least 2 (max 8)
   - 7-inch tablet: At least 2
   - 10-inch tablet: At least 2
   - Sizes vary by device

#### Store Listing

1. **App name:** NutriLens Pro
2. **Short description:** (80 chars)
   > Scan food barcodes for instant nutrition info
3. **Full description:** (4000 chars)
   ```
   NutriLens Pro - Scan. Know. Choose Better.
   
   Make informed food choices with instant nutrition information!
   
   ✨ FEATURES:
   📸 Quick barcode scanning
   📊 Detailed nutrition facts
   ⭐ Nutri-Score ratings
   🔍 Ingredient lists
   ⚠️ Allergen warnings
   ❤️ Save favorites
   📜 Scan history
   🌙 Dark mode
   
   Powered by Open Food Facts - millions of products!
   
   Download now and start making healthier choices!
   ```

4. **Category:** Health & Fitness
5. **Tags:** nutrition, food scanner, barcode, health
6. **Contact details:** Your email
7. **Privacy policy URL:** https://yourwebsite.com/privacy

#### Content Rating

Complete the content rating questionnaire honestly.

#### Upload APK/AAB

1. Go to **"Production"** → **"Create new release"**
2. Upload your AAB file
3. Add release notes
4. Review and rollout

### Apple App Store

#### Prepare Assets

1. **App Icon:** 1024x1024 PNG (no alpha channel)
2. **Screenshots:**
   - iPhone 6.5": 1242x2688 or 1284x2778 (at least 3)
   - iPhone 5.5": 1242x2208 (at least 3)
   - iPad Pro 12.9": 2048x2732 (at least 3)

#### App Information

1. **Name:** NutriLens Pro
2. **Subtitle:** (30 chars)
   > Nutrition Barcode Scanner
3. **Description:**
   ```
   NutriLens Pro - Scan. Know. Choose Better.
   
   Make informed food choices with instant nutrition information!
   
   FEATURES:
   • Quick barcode scanning
   • Detailed nutrition facts with Nutri-Score
   • Complete ingredient lists
   • Allergen warnings
   • Save favorite products
   • Scan history tracking
   • Beautiful dark mode
   • Offline support
   
   Powered by Open Food Facts database with millions of products worldwide!
   
   PERFECT FOR:
   • Health-conscious consumers
   • People with dietary restrictions
   • Fitness enthusiasts
   • Anyone who wants to know what's in their food
   
   Download NutriLens Pro today and take control of your nutrition!
   ```

4. **Keywords:** nutrition,food,scanner,barcode,health,diet,calories,ingredients
5. **Category:** Primary: Health & Fitness
6. **Age Rating:** 4+

#### Privacy

1. Add privacy policy URL
2. Complete Privacy Nutrition label in App Store Connect

#### Submit for Review

1. Upload your build via Xcode or Transporter
2. Complete all app information
3. Submit for review
4. Wait 1-3 days for approval

---

## Post-Launch Checklist

- [ ] Monitor crash reports (Firebase Crashlytics recommended)
- [ ] Track app analytics
- [ ] Monitor AdMob earnings
- [ ] Respond to user reviews
- [ ] Plan feature updates
- [ ] Monitor API usage limits
- [ ] Update app regularly

---

## Troubleshooting

### Common Issues

**Issue: Ads not showing**
- Verify Ad Unit IDs are correct
- Check AdMob account is approved (can take 24-48 hours)
- Ensure app is in release mode
- Check internet connection

**Issue: IAP not working**
- Verify product IDs match exactly
- Ensure products are "Active" in console
- Use sandbox testers for testing
- Check app is signed correctly

**Issue: Barcode scanner not working**
- Verify camera permissions are granted
- Check device has a camera
- Test on real device (not simulator)

**Issue: API calls failing**
- Check internet connection
- Verify API endpoints are correct
- Check for rate limiting
- Ensure proper error handling

---

## Support & Resources

### Documentation
- Flutter: https://docs.flutter.dev/
- AdMob: https://developers.google.com/admob
- In-App Purchase: https://pub.dev/packages/in_app_purchase
- Open Food Facts API: https://world.openfoodfacts.org/data

### Communities
- Flutter Community: https://flutter.dev/community
- Stack Overflow: https://stackoverflow.com/questions/tagged/flutter

---

**Congratulations! 🎉**

You're now ready to launch NutriLens Pro to the world!

For questions or support, please open an issue on GitHub or contact support@nutrilenspro.com

**Happy scanning!** 📱✨