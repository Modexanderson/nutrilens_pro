# ⚡ NutriLens Pro - Quick Reference Guide

Quick commands and common tasks for development and deployment.

---

## 🛠️ Development Commands

### Setup & Installation

```bash
# Install dependencies
flutter pub get

# Generate code (Hive adapters, Riverpod providers)
flutter pub run build_runner build --delete-conflicting-outputs

# Watch for changes (auto-generate)
flutter pub run build_runner watch

# Clean and regenerate
flutter pub run build_runner clean
flutter pub run build_runner build --delete-conflicting-outputs
```

### Running the App

```bash
# Run on connected device
flutter run

# Run in release mode
flutter run --release

# Run on specific device
flutter devices  # List devices
flutter run -d <device_id>

# Run with flavor (if configured)
flutter run --flavor dev
flutter run --flavor prod
```

### Testing

```bash
# Run all tests
flutter test

# Run with coverage
flutter test --coverage

# Run specific test file
flutter test test/widget_test.dart

# Run integration tests
flutter drive --target=test_driver/app.dart
```

### Code Quality

```bash
# Analyze code
flutter analyze

# Format code
flutter format .

# Check outdated packages
flutter pub outdated

# Upgrade packages
flutter pub upgrade
```

---

## 📱 Build Commands

### Android

```bash
# Build APK (Debug)
flutter build apk --debug

# Build APK (Release)
flutter build apk --release

# Build APK (Split per ABI - smaller files)
flutter build apk --split-per-abi

# Build App Bundle (for Play Store)
flutter build appbundle --release

# Build with version
flutter build appbundle --build-name=1.0.1 --build-number=2
```

**Output Locations:**
- APK: `build/app/outputs/flutter-apk/app-release.apk`
- AAB: `build/app/outputs/bundle/release/app-release.aab`

### iOS

```bash
# Build iOS app
flutter build ios --release

# Build IPA
flutter build ipa --release

# Build with export options
flutter build ipa --export-options-plist=ExportOptions.plist

# Clean build
flutter clean
flutter build ios --release
```

**Output Location:**
- IPA: `build/ios/archive/Runner.xcarchive`

---

## 🔧 Common Tasks

### Update App Version

**pubspec.yaml**
```yaml
version: 1.0.1+2  # version_name+version_code
```

**Or via command:**
```bash
flutter build appbundle --build-name=1.0.1 --build-number=2
```

### Generate App Icons

1. Place icon at `assets/icons/app_icon.png` (1024x1024)
2. Run:
```bash
flutter pub run flutter_launcher_icons
```

### Add New Dependency

```bash
# Add package
flutter pub add package_name

# Add dev dependency
flutter pub add --dev package_name

# Remove package
flutter pub remove package_name
```

### Clean Project

```bash
# Flutter clean
flutter clean

# Delete build folders
rm -rf build/
rm -rf ios/Pods/
rm -rf ios/.symlinks/

# Full clean (Android)
cd android && ./gradlew clean && cd ..

# Full reset
flutter clean
flutter pub get
cd ios && pod install && cd ..
```

---

## 🐛 Debugging

### Debug Commands

```bash
# Enable verbose logging
flutter run -v

# Debug with DevTools
flutter run --observatory-port=8888
# Then open: http://localhost:8888

# Profile mode (for performance)
flutter run --profile

# Check app size
flutter build apk --analyze-size
flutter build ios --analyze-size
```

### Common Issues & Fixes

**Issue: "Could not resolve all dependencies"**
```bash
flutter clean
flutter pub get
```

**Issue: iOS build fails**
```bash
cd ios
pod deintegrate
pod install
cd ..
flutter clean
flutter run
```

**Issue: Gradle build fails**
```bash
cd android
./gradlew clean
cd ..
flutter clean
flutter run
```

**Issue: AdMob not showing ads**
- Check you're in release mode
- Verify Ad Unit IDs
- Wait 24-48 hours after account approval
- Check AdMob dashboard for status

**Issue: Barcode scanner black screen**
- Check camera permissions
- Test on real device (not simulator)
- Verify `permission_handler` setup

---

## 📦 Package Management

### Update Specific Package

```bash
flutter pub upgrade package_name
```

### Check Package Version

```bash
flutter pub deps
```

### Lock Dependencies

```bash
# Create pubspec.lock
flutter pub get

# Use exact versions
flutter pub upgrade --major-versions
```

---

## 🚀 Deployment Shortcuts

### Quick Android Release

```bash
# One-liner for Play Store
flutter clean && flutter pub get && flutter build appbundle --release
```

### Quick iOS Release

```bash
# One-liner for App Store
flutter clean && flutter pub get && flutter build ipa --release
```

### Beta Testing (Android)

```bash
# Build APK for beta testers
flutter build apk --release --split-per-abi
```

**Upload to:**
- Firebase App Distribution
- Google Play Internal Testing
- TestFlight (iOS)

---

## 📊 Performance Optimization

### Analyze App Size

```bash
# Check APK size breakdown
flutter build apk --analyze-size --target-platform android-arm64

# Check iOS size
flutter build ios --analyze-size
```

### Profile Performance

```bash
# Run in profile mode
flutter run --profile

# Generate performance overlay
flutter run --profile --trace-skia
```

### Memory Profiling

```bash
# Use DevTools
flutter pub global activate devtools
flutter pub global run devtools
```

---

## 🔐 Security Checklist

### Before Release

```bash
# Remove debug code
grep -r "print(" lib/
grep -r "TODO" lib/
grep -r "FIXME" lib/

# Check for hardcoded secrets
grep -r "api_key" lib/
grep -r "password" lib/
grep -r "secret" lib/
```

### Code Obfuscation (Optional)

```bash
# Build with obfuscation
flutter build apk --obfuscate --split-debug-info=build/debug-info

flutter build ios --obfuscate --split-debug-info=build/debug-info
```

---

## 📝 Git Workflow

### Initial Setup

```bash
git init
git add .
git commit -m "Initial commit: NutriLens Pro v1.0.0"
git branch -M main
git remote add origin <your-repo-url>
git push -u origin main
```

### Version Updates

```bash
# Create version tag
git tag -a v1.0.0 -m "Release version 1.0.0"
git push origin v1.0.0

# List tags
git tag
```

### Release Workflow

```bash
# Create release branch
git checkout -b release/1.0.0

# Make changes, test, then merge
git checkout main
git merge release/1.0.0
git tag v1.0.0
git push origin main --tags
```

---

## 🎯 AdMob Testing

### Test Ad Units (Keep for development)

```dart
// Android
Banner: 'ca-app-pub-3940256099942544/6300978111'
Interstitial: 'ca-app-pub-3940256099942544/1033173712'

// iOS
Banner: 'ca-app-pub-3940256099942544/2934735716'
Interstitial: 'ca-app-pub-3940256099942544/4411468910'
```

### Enable Test Devices

```dart
// In main.dart
MobileAds.instance.updateRequestConfiguration(
  RequestConfiguration(
    testDeviceIds: ['YOUR_DEVICE_ID'],
  ),
);
```

**Get Device ID from logs:**
```
flutter run
# Look for: "Use RequestConfiguration.Builder.setTestDeviceIds"
```

---

## 💰 IAP Testing

### Android Test Purchases

1. Add testers in Google Play Console
2. Use test Gmail accounts
3. Purchases won't be charged

### iOS Test Purchases

1. Create Sandbox testers in App Store Connect
2. Sign out of real Apple ID on device
3. Sign in with sandbox account when prompted
4. Purchases won't be charged

### Test IAP Flow

```bash
# Run in debug mode
flutter run

# Test purchase
# Use sandbox accounts
# Verify purchase completes
# Check console logs
```

---

## 📱 Device Testing

### Recommended Test Devices

**Android:**
- Samsung Galaxy (Popular brand)
- Google Pixel (Stock Android)
- Budget device (Low-end testing)

**iOS:**
- iPhone (Latest)
- iPhone (2-3 years old)
- iPad (Tablet testing)

### Test Matrix

| Feature | Android | iOS | Status |
|---------|---------|-----|--------|
| Barcode Scan | ✅ | ✅ | Working |
| Camera Permissions | ✅ | ✅ | Working |
| Banner Ads | ✅ | ✅ | Working |
| Interstitial Ads | ✅ | ✅ | Working |
| IAP | ✅ | ✅ | Working |
| Dark Mode | ✅ | ✅ | Working |
| Offline Mode | ✅ | ✅ | Working |

---

## 🔍 Useful Resources

### Documentation
- Flutter Docs: https://docs.flutter.dev
- Dart Docs: https://dart.dev/guides
- Material Design: https://m3.material.io

### Packages
- Pub.dev: https://pub.dev
- Flutter Gems: https://fluttergems.dev

### Community
- Flutter Discord: https://discord.gg/flutter
- Stack Overflow: https://stackoverflow.com/questions/tagged/flutter
- Reddit: https://reddit.com/r/flutterdev

### Tools
- DevTools: https://docs.flutter.dev/tools/devtools
- Firebase Console: https://console.firebase.google.com
- AdMob: https://apps.admob.com

---

## 🎓 Learning Resources

### Official
- Flutter Codelabs: https://docs.flutter.dev/codelabs
- Flutter YouTube: https://youtube.com/c/flutterdev
- Dart Language Tour: https://dart.dev/guides/language/language-tour

### API Documentation
- Open Food Facts: https://world.openfoodfacts.org/data
- AdMob: https://developers.google.com/admob
- In-App Purchase: https://pub.dev/packages/in_app_purchase

---

## ⚡ Pro Tips

### Speed Up Development

```bash
# Use hot reload (r) and hot restart (R) in terminal
flutter run
# Press 'r' for hot reload
# Press 'R' for hot restart
# Press 'p' to show performance overlay
```

### Multiple Environments

Create different configurations:
```dart
// lib/config/dev_config.dart
// lib/config/prod_config.dart
```

### Keyboard Shortcuts (VS Code)

- `Ctrl+Space`: Autocomplete
- `Ctrl+.`: Quick fixes
- `Shift+Alt+F`: Format document
- `F5`: Start debugging
- `Shift+F5`: Stop debugging

---

## 📋 Pre-Release Checklist

### Code
- [ ] All features working
- [ ] No console errors/warnings
- [ ] Code formatted
- [ ] No TODO comments
- [ ] Removed debug prints

### Testing
- [ ] Tested on real devices
- [ ] All user flows tested
- [ ] Edge cases handled
- [ ] Error states tested

### Configuration
- [ ] Production Ad IDs set
- [ ] IAP products configured
- [ ] App version updated
- [ ] Signing configured

### Assets
- [ ] App icon set
- [ ] Screenshots ready
- [ ] Store listing complete
- [ ] Privacy policy ready

### Release
- [ ] Build AAB/IPA
- [ ] Test release build
- [ ] Upload to stores
- [ ] Submit for review

---

## 🆘 Getting Help

### Stuck? Try:

1. **Read error message carefully**
2. **Search on Stack Overflow**
3. **Check package documentation**
4. **Ask on Flutter Discord**
5. **Check GitHub issues**

### Report Bug

```bash
# Include Flutter doctor output
flutter doctor -v

# Include build output
flutter run -v 2>&1 | tee log.txt
```

---

**Keep this guide handy during development!** 📌

For detailed information, refer to:
- `README.md` - Overview and features
- `SETUP_GUIDE.md` - Complete setup instructions
- `BRANDING_AND_ALTERNATIVES.md` - Branding options

**Happy coding!** 🚀