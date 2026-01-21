# App Store Screenshot Instructions

## Current Status: DEMO MODE ENABLED

The app is currently in **demo mode** with mock data loaded for screenshots.

## How to Take Screenshots

### Step 1: Run the App on iOS Simulator
```bash
# Open iOS Simulator
open -a Simulator

# Or run via Flutter
flutter run -d "iPhone 15 Pro Max"
```

### Step 2: Screenshots to Take

Take screenshots of the following screens (use Cmd+S in Simulator):

1. **Scan Screen** (Tab 1)
   - Shows Nutella product being detected
   - Animated scanning line visible
   - Product preview card at bottom

2. **Product Detail Screen**
   - Tap the Nutella card in scan screen
   - Shows full nutrition info, Nutri-Score E badge
   - Shows allergen warnings

3. **Search Screen** (Tab 2)
   - Type "nutella" or "yogurt" to show search results

4. **Tracker Screen** (Tab 3)
   - Shows daily calorie progress
   - Breakfast/Lunch/Snack entries with food logged
   - Water intake progress

5. **Profile Screen** (Tab 4)
   - History tab: Shows scanned products
   - Favorites tab: Shows favorited healthy products
   - Settings tab: Shows app settings

### Step 3: Screenshot Locations

Screenshots are saved to:
- Mac: `~/Desktop` or `~/Pictures`
- Or use Simulator > File > Save Screen

### Screenshot Sizes Needed for App Store

| Device | Size (pixels) |
|--------|---------------|
| iPhone 6.7" (15 Pro Max) | 1290 x 2796 |
| iPhone 6.5" (11 Pro Max) | 1242 x 2688 |
| iPhone 5.5" (8 Plus) | 1242 x 2208 |
| iPad Pro 12.9" | 2048 x 2732 |

## After Taking Screenshots

### Step 4: Disable Demo Mode for Production

1. Open `lib/main.dart`
2. Change line 20:
   ```dart
   const bool kDemoMode = false; // <-- CHANGE TO false BEFORE RELEASE!
   ```

### Step 5: Delete Demo Files (Optional but Recommended)

Delete these files before final production build:
- `lib/services/demo_data_service.dart`
- `lib/screens/demo_scanner_screen.dart`
- `lib/screens/demo_home_screen.dart`
- `SCREENSHOT_INSTRUCTIONS.md` (this file)

Also remove from `lib/main.dart`:
- `import 'services/demo_data_service.dart';`
- `import 'screens/demo_home_screen.dart';`
- The demo mode check code

### Step 6: Clean User Data (if testing on real device)

If you ran the demo on a real device, clear the app data or reinstall to remove demo entries.

## Demo Data Contents

### History (8 products):
- Nutella (Ferrero)
- Coca-Cola Original Taste
- Greek Yogurt 0% Fat (Fage)
- Quaker Oats Old Fashioned
- Unsweetened Almond Milk (Almond Breeze)
- Barilla Spaghetti n.5
- KIND Dark Chocolate Bar
- Evian Natural Mineral Water

### Favorites (4 products):
- Greek Yogurt 0% Fat
- Quaker Oats
- Almond Milk
- Evian Water

### Today's Tracker:
- **Breakfast**: Oatmeal (227 kcal) + Greek Yogurt (92 kcal)
- **Lunch**: Spaghetti (359 kcal)
- **Snack**: KIND Bar (200 kcal)
- **Water**: 1.5L / 2L goal
- **Total**: ~878 kcal

## Creating App Store Screenshots with Frames

For professional screenshots with iPhone frames and captions, you can use:

1. **Screenshots App** (Mac App Store - Free)
2. **Previewed.app** (https://previewed.app)
3. **AppLaunchpad** (https://theapplaunchpad.com)
4. **Shotbot** (https://shotbot.io)

### Suggested Captions:
1. "Scan any barcode instantly"
2. "Get detailed nutrition info"
3. "Track your daily intake"
4. "Search millions of products"
5. "Monitor your health goals"
