# 🥗 NutriLens Pro

**Scan. Know. Choose Better.**

A professional Flutter food scanner app that retrieves detailed nutrition and product information using barcode scanning.

## ✨ Features

### Core Features
- 📸 **Barcode Scanning** - Camera-based barcode scanning with mobile_scanner
- 🔍 **Product Information** - Detailed nutrition facts, ingredients, allergens
- 📊 **Nutri-Score** - Visual nutrition grade from A to E
- 📜 **Scan History** - Save and review scanned products
- ⭐ **Favorites** - Mark and quickly access favorite products
- 🔎 **Search** - Find products by name or category
- 🎨 **Themes** - Light and dark mode support
- 💾 **Offline Cache** - Recent scans available offline
- 📤 **Share** - Share product information

### Monetization
- 📱 **Google AdMob** - Banner and interstitial ads
- 💰 **In-App Purchases** - Donation system via Apple/Google IAP

### Data Source
- 🌍 **Open Food Facts API** - Free, open-source food database with millions of products
- 🔄 **Real-time Data** - Up-to-date product information

## 🏗️ Architecture

```
nutrilens_pro/
├── lib/
│   ├── main.dart
│   ├── core/
│   │   ├── constants/
│   │   ├── theme/
│   │   │   └── app_theme.dart
│   │   └── utils/
│   ├── data/
│   │   ├── models/
│   │   │   ├── product_model.dart
│   │   │   └── product_model.g.dart
│   │   ├── services/
│   │   │   ├── api_service.dart
│   │   │   ├── storage_service.dart
│   │   │   ├── ad_service.dart
│   │   │   └── iap_service.dart
│   │   └── repositories/
│   └── presentation/
│       ├── screens/
│       │   ├── splash_screen.dart
│       │   ├── home_screen.dart
│       │   ├── scanner_screen.dart
│       │   ├── product_detail_screen.dart
│       │   ├── history_screen.dart
│       │   ├── favorites_screen.dart
│       │   └── settings_screen.dart
│       ├── widgets/
│       │   └── product_card.dart
│       └── providers/
└── assets/
```

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (>=3.0.0)
- Dart SDK (>=3.0.0)
- Android Studio / VS Code
- Xcode (for iOS)

### Installation

1. **Clone the repository**
```bash
git clone https://github.com/modexanderson/nutrilens_pro.git
cd nutrilens_pro
```

2. **Install dependencies**
```bash
flutter pub get
```

3. **Generate code**
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

4. **Run the app**
```bash
flutter run
```

## ⚙️ Configuration

### 1. Google AdMob Setup

#### Android

1. Add your AdMob App ID in `android/app/src/main/AndroidManifest.xml`:
```xml
<manifest>
    <application>
        <meta-data
            android:name="com.google.android.gms.ads.APPLICATION_ID"
            android:value="ca-app-pub-XXXXXXXXXXXXXXXX~YYYYYYYYYY"/>
    </application>
</manifest>
```

2. Update Ad Unit IDs in `lib/data/services/ad_service.dart`:
```dart
static String get bannerAdUnitId {
  if (Platform.isAndroid) {
    return 'ca-app-pub-XXXXXXXXXXXXXXXX/YYYYYYYYYY'; // Your banner ID
  }
  // ...
}
```

#### iOS

1. Add AdMob App ID in `ios/Runner/Info.plist`:
```xml
<key>GADApplicationIdentifier</key>
<string>ca-app-pub-XXXXXXXXXXXXXXXX~YYYYYYYYYY</string>
```

2. Add App Tracking Transparency:
```xml
<key>NSUserTrackingUsageDescription</key>
<string>This identifier will be used to deliver personalized ads to you.</string>
```

**Get your AdMob IDs:** https://apps.admob.com/

### 2. In-App Purchase Setup

#### Android (Google Play)

1. Create your app in Google Play Console
2. Set up In-App Products (Managed Products):
   - `donation_small` - $0.99
   - `donation_medium` - $2.99
   - `donation_large` - $4.99

3. Add billing permission in `android/app/src/main/AndroidManifest.xml`:
```xml
<uses-permission android:name="com.android.vending.BILLING" />
```

4. Configure your app's license key in Google Play Console

#### iOS (App Store)

1. Create your app in App Store Connect
2. Set up In-App Purchases (Consumable):
   - `donation_small` - $0.99
   - `donation_medium` - $2.99
   - `donation_large` - $4.99

3. Update Product IDs in `lib/data/services/iap_service.dart` if needed

**Resources:**
- Google Play: https://play.google.com/console
- App Store Connect: https://appstoreconnect.apple.com

### 3. Permissions

#### Android (`android/app/src/main/AndroidManifest.xml`)
```xml
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.INTERNET" />
```

#### iOS (`ios/Runner/Info.plist`)
```xml
<key>NSCameraUsageDescription</key>
<string>We need camera access to scan product barcodes</string>
```

## 📦 API Integration

The app uses **Open Food Facts API** - a free, open-source food database.

### API Endpoints

**Get Product by Barcode:**
```
GET https://world.openfoodfacts.org/api/v2/product/{barcode}
```

**Search Products:**
```
GET https://world.openfoodfacts.org/cgi/search.pl?search_terms={query}&json=true
```

### Example Response
```json
{
  "status": 1,
  "product": {
    "code": "3017620422003",
    "product_name": "Nutella",
    "brands": "Ferrero",
    "nutriments": {
      "energy-kcal_100g": 539,
      "proteins_100g": 6.3,
      "carbohydrates_100g": 57,
      "sugars_100g": 56,
      "fat_100g": 31
    },
    "nutriscore_grade": "e",
    "ingredients_text": "Sugar, Palm Oil, Hazelnuts...",
    "allergens_tags": ["en:nuts", "en:milk"]
  }
}
```

**API Documentation:** https://world.openfoodfacts.org/data

## 🎨 App Icon & Branding

### App Icon
Create app icons using Flutter Launcher Icons package:

1. Add your icon image to `assets/icons/app_icon.png` (1024x1024)
2. Run:
```bash
flutter pub run flutter_launcher_icons
```

### Splash Screen
The splash screen is defined in `lib/presentation/screens/splash_screen.dart`. Customize colors and logo as needed.

## 📱 Building for Release

### Android

1. **Create a keystore:**
```bash
keytool -genkey -v -keystore ~/nutrilens-key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias nutrilens
```

2. **Create `android/key.properties`:**
```properties
storePassword=your_password
keyPassword=your_password
keyAlias=nutrilens
storeFile=/path/to/nutrilens-key.jks
```

3. **Update `android/app/build.gradle`:**
```gradle
android {
    signingConfigs {
        release {
            keyAlias keystoreProperties['keyAlias']
            keyPassword keystoreProperties['keyPassword']
            storeFile keystoreProperties['storeFile'] ? file(keystoreProperties['storeFile']) : null
            storePassword keystoreProperties['storePassword']
        }
    }
    buildTypes {
        release {
            signingConfig signingConfigs.release
        }
    }
}
```

4. **Build APK/AAB:**
```bash
flutter build apk --release
# or
flutter build appbundle --release
```

### iOS

1. **Open Xcode:**
```bash
open ios/Runner.xcworkspace
```

2. **Configure signing** in Xcode with your Apple Developer account

3. **Build IPA:**
```bash
flutter build ipa --release
```

## 🧪 Testing

```bash
# Run tests
flutter test

# Run with coverage
flutter test --coverage

# Integration tests
flutter drive --target=test_driver/app.dart
```

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## 📧 Support

For support, email support@nutrilenspro.com or open an issue on GitHub.

## 🙏 Acknowledgments

- **Open Food Facts** - For providing the free food database API
- **Flutter Community** - For amazing packages and support
- **Contributors** - Thank you to all who have contributed!

## 📊 App Store Submission Checklist

### Before Submission

- [ ] Test on real devices (Android & iOS)
- [ ] Replace test AdMob IDs with production IDs
- [ ] Configure In-App Purchase products
- [ ] Add Privacy Policy URL
- [ ] Add Terms of Service URL
- [ ] Create App Store screenshots (multiple device sizes)
- [ ] Write compelling app description
- [ ] Prepare promotional graphics
- [ ] Test all features thoroughly
- [ ] Check for crashes and bugs
- [ ] Verify API key limits and quotas
- [ ] Review app permissions usage

### Google Play Requirements

- App must target Android API 33+
- Provide data safety information
- Complete store listing
- Upload APK/AAB with proper versioning

### App Store Requirements

- App must support iOS 12.0+
- Provide privacy policy
- Complete App Store listing
- Submit for review

## 🔮 Future Enhancements

- [ ] Nutrition goal tracking
- [ ] Alternative product suggestions
- [ ] Food diary/meal logging
- [ ] Barcode history export
- [ ] Multiple language support
- [ ] Allergy warnings & filters
- [ ] Custom product database
- [ ] Social features & sharing
- [ ] Widget support
- [ ] Apple Watch companion app

---

**Made with ❤️ for healthier food choices**

*NutriLens Pro - Scan. Know. Choose Better.*