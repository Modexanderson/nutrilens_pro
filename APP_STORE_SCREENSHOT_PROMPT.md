# Reusable App Store Screenshot Generation Prompt

Use this prompt when starting a new app project and need to generate App Store screenshots.

---

## Prompt Template

```
I need you to help me generate professional App Store screenshots for my [APP_NAME] app. Here's what I need:

## 1. Demo Mode Setup
Create a demo mode system for the app that:
- Has a flag (kDemoMode) in main.dart to toggle demo mode on/off
- Loads realistic mock data for all screens (history, favorites, tracker, etc.)
- Uses real product images from working URLs (e.g., OpenFoodFacts)
- Shows a realistic scanning/capture scene (if applicable) with actual product images filling the screen
- Skips onboarding in demo mode

## 2. Screenshots Required
Take screenshots of these screens on BOTH phone and tablet emulators:
- [List your screens, e.g.:]
  1. Main feature screen (e.g., scanner showing product being scanned)
  2. Search/Browse screen WITH actual search results showing (not empty)
  3. Tracking/Dashboard screen with populated data
  4. Profile/History screen with items and images
  5. Detail screen showing full product/item information

## 3. Screenshot Requirements
- Android status bar must be COMPLETELY cropped out (not visible at all)
- Screenshots must show REALISTIC data (real product images, real search results)
- Scanner/Camera screens must show the actual item filling the viewfinder (not a placeholder)
- Search screens must have a search term entered and results displayed
- All product/item images must be loaded and visible

## 4. App Store Formatting
Create a Python script that:
- Crops out Android status bar completely
- Adds rounded corners (iPhone/iPad style)
- Adds drop shadow
- Places screenshot on gradient background matching app's primary color
- Adds caption and subtitle text at top
- Outputs correct sizes (Apple App Store accepted dimensions):
  - iPhone 6.7": 1284x2778 (or 1242x2688 for 6.5")
  - iPad 12.9": 2048x2732

## 5. Captions for Screenshots
[Customize these for your app:]
1. "[Main Feature Caption]" - "[Subtitle]"
2. "Search Products" - "Find millions of items"
3. "Track Progress" - "Monitor your data"
4. "View History" - "All your activity"
5. "Detailed Info" - "Know everything"

## 6. After Screenshots
- Set kDemoMode = false for production
- List files to delete after App Store submission

## Technical Notes
- I have Android emulators running (phone and tablet)
- You have access to ADB commands
- You can run Python scripts
- The app is built with [Flutter/React Native/etc.]
```

---

## Key Points to Remember

### What Makes a Good App Store Screenshot:
1. **Realistic scenes** - Show the app being used with real data
2. **No Android/test indicators** - Status bar must be cropped
3. **Populated screens** - Never show empty states
4. **Working features** - Search results, images loaded, data displayed
5. **Professional framing** - Rounded corners, shadows, gradient backgrounds

### Common Issues to Avoid:
- Empty search results (always show actual results)
- Placeholder images (use real product/item images)
- Android status bar visible (completely crop it out)
- Scanner showing just a barcode graphic (show the actual product being scanned)
- Missing iPad screenshots

### Demo Data Checklist:
- [ ] Products/items with real images from working URLs
- [ ] History populated with realistic entries
- [ ] Favorites with a few items
- [ ] Tracker/dashboard with realistic data
- [ ] User profile with sample preferences
- [ ] Search results that actually work (test which search terms return results)

### Python Script Requirements:
```python
# Key configurations
# Apple App Store accepted dimensions:
# - iPhone 6.7": 1284 x 2778px (portrait) or 2778 x 1284px (landscape)
# - iPhone 6.5": 1242 x 2688px (portrait) or 2688 x 1242px (landscape)
# - iPad 12.9": 2048 x 2732px (portrait) or 2732 x 2048px (landscape)
DEVICES = {
    "iphone_67": {
        "output_width": 1284,
        "output_height": 2778,
        "status_bar_crop": 110,  # Adjust based on device
        "corner_radius_ratio": 0.08,
        "phone_height_ratio": 0.62,
    },
    "ipad_129": {
        "output_width": 2048,
        "output_height": 2732,
        "status_bar_crop": 75,
        "corner_radius_ratio": 0.04,
        "phone_height_ratio": 0.70,
    }
}
```

---

## Files to Create for Demo Mode

1. **lib/services/demo_data_service.dart** - Loads all mock data
2. **lib/screens/demo_[feature]_screen.dart** - Demo version of main feature screen
3. **lib/screens/demo_home_screen.dart** - Home screen using demo components
4. **screenshots/create_appstore_screenshots.py** - Python script for processing

## Files to Delete After Screenshots

- lib/services/demo_data_service.dart
- lib/screens/demo_*.dart
- screenshots/ folder
- SCREENSHOT_INSTRUCTIONS.md
- This prompt file (if saved to project)

---

## Quick Command Reference

```bash
# List emulators
adb devices

# Clear app data
adb -s emulator-5554 shell pm clear com.your.app

# Install APK
adb -s emulator-5554 install -r path/to/app.apk

# Launch app
adb -s emulator-5554 shell am start -n com.your.app/.MainActivity

# Take screenshot
adb -s emulator-5554 exec-out screencap -p > screenshot.png

# Get UI element coordinates
adb -s emulator-5554 shell "uiautomator dump /data/local/tmp/ui.xml && cat /data/local/tmp/ui.xml"

# Tap on screen
adb -s emulator-5554 shell input tap X Y

# Type text
adb -s emulator-5554 shell input text "search term"
```
