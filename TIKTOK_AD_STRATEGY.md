# NutriLens Pro — TikTok Ad Strategy

## Video Structure (15-30 seconds)

### Hook (0-3 seconds) — Stop the scroll
The first 3 seconds decide everything. Use one of these:

| Hook Type | Example | Why It Works |
|-----------|---------|--------------|
| Shock/Curiosity | "I was eating this every day until I scanned it..." | Creates fear of missing out on info |
| POV | "POV: you find out what's actually in your food" | Relatable, native TikTok format |
| Direct Challenge | "Stop eating food you know nothing about" | Confrontational, makes people pause |
| Social Proof | "I stopped buying groceries without this app" | Implies lifestyle change |

**Best performers for health apps are shock/curiosity hooks.** Test 3-4 variations.

### Demo (3-15 seconds) — Show the magic
Quick screen recording of the app in action:
1. **Barcode scan** — camera pointing at a product, instant result (2-3 sec)
2. **Nutri-Score reveal** — the A/B/C/D/E grade appearing (satisfying visual)
3. **Allergen warning** — red banner popping up (emotional trigger)
4. **Tracker filling up** — daily progress bars moving (gamification feel)

Keep transitions fast. No slow panning. Match TikTok energy.

### HeyGen Presenter (15-25 seconds) — Human touch
- Avatar talks casually over split-screen (presenter + app recording)
- Script tone: friend recommending an app, NOT a commercial
- Example script: "Okay I literally scan everything before I buy it now. It takes 2 seconds and tells you every single thing that's in your food. Calories, allergens, Nutri-Score, everything. And it's free."
- Keep it under 15 seconds of talking

### CTA (last 3-5 seconds)
- Text overlay: **"Free on the App Store"** (removes friction)
- Show the NutriLens Pro app icon clearly
- Optional: "Link in bio" or let TikTok's app install button do the work

---

## HeyGen Production Tips

### Avatar Selection
- Young (20-30), relatable, casual appearance
- Matches TikTok's core demographic
- Avoid corporate/polished look — should feel organic

### Script Guidelines
- **DO**: Use "I", "literally", "honestly", conversational fillers
- **DO**: Mention it's free early
- **DON'T**: Use marketing speak ("revolutionary", "cutting-edge")
- **DON'T**: Read a list of features — tell a mini-story instead

### Example Scripts (pick one, customize)

**Script A — The Discovery**
> "Okay so I found this app that scans any barcode and tells you exactly what's in your food. Like the allergens, the nutrition score, everything. I've been using it for a week and honestly I'm shocked at what I was eating. It's called NutriLens Pro and it's free."

**Script B — The Habit**
> "This is my new grocery shopping habit. I scan everything before it goes in the cart. Takes literally 2 seconds. It shows you a grade from A to E so you know instantly if it's good or trash. Free app called NutriLens Pro."

**Script C — The Scare**
> "I scanned my favorite snack with this app and... yeah. Let's just say I don't eat it anymore. NutriLens Pro shows you everything — allergens, hidden sugars, the real nutrition facts. It's free, go check what you're actually eating."

### Video Format
- **Aspect ratio**: 9:16 (portrait, 1080x1920)
- **Duration**: 15-30 seconds (sweet spot for TikTok Spark Ads)
- **Captions**: Always add captions — 80% of TikTok is watched on mute
- **Music**: Use trending TikTok sounds if organic, or subtle background if paid ad

---

## TikTok Ads Manager Setup

### Campaign Settings
- **Objective**: App Installs
- **Optimization goal**: Install (not click)
- **Bid strategy**: Start with "Lowest cost" (let TikTok optimize)

### Targeting
- **Age**: 18-35 (primary), can test 25-44 for health-conscious parents
- **Interests**: Health & fitness, food & drink, cooking, wellness, diet
- **Behaviors**: App install intent, health app users
- **Locations**: US, UK, Canada, Australia (best Open Food Facts coverage)
- **Exclude**: Regions with poor Open Food Facts coverage (most scans will fail)

### Budget
| Phase | Daily Budget | Duration | Goal |
|-------|-------------|----------|------|
| Testing | $20-30/day | 5-7 days | Test 3-4 creatives, find winner |
| Scaling | $50-100/day | Ongoing | Scale winning creative |
| Refresh | — | Every 2-3 weeks | Swap in new creatives before fatigue |

### Creative Testing
- Upload 3-4 ad variations with different hooks
- Same demo footage, different opening lines
- After 5-7 days, kill the losers (CTR < 1%), scale the winners
- Refresh creatives every 2-3 weeks (TikTok ad fatigue is real)

### Key Metrics to Watch
| Metric | Target | What It Means |
|--------|--------|---------------|
| CTR | > 1% | Your hook is working |
| CPI (Cost per Install) | < $2 | Sustainable for ad-supported app |
| IPM (Installs per Mille) | > 5 | Good conversion rate |
| Day 1 Retention | > 30% | App delivers on the ad's promise |
| Day 7 Retention | > 15% | Push notifications working |

### ROAS Calculation
With AdMob banner + interstitial:
- Expected eCPM: $1-5 (US iOS)
- Average DAU sessions: 2-3
- Revenue per user per day: ~$0.005-0.02
- Break-even at $1 CPI: ~50-200 days per user
- **Key insight**: Retention is everything. Push notifications and habit loops are what make free+ads work.

---

## Post-Launch Optimization

### Week 1
- [ ] Monitor Crashlytics for any crashes from new users
- [ ] Check AdMob fill rate and eCPM
- [ ] Track which TikTok creative has best CTR
- [ ] Kill underperforming ad variations

### Week 2
- [ ] Check Day 7 retention rate
- [ ] A/B test push notification copy
- [ ] Scale winning creative to $50-100/day
- [ ] Create 2 new creative variations

### Ongoing
- [ ] Refresh ad creatives every 2-3 weeks
- [ ] Monitor Open Food Facts coverage for your target markets
- [ ] Respond to App Store reviews (shows up in search ranking)
- [ ] Track ARPU in Firebase Analytics (link AdMob to Firebase)

---

## App Store Optimization (helps organic installs from TikTok traffic)

### Keywords to target
- food scanner, barcode scanner, nutrition tracker, calorie counter
- nutri-score, allergen checker, food tracker, healthy eating

### Screenshots
Use the existing screenshots in `screenshots/appstore_ready/iphone/`:
- Scan screen — shows the core value prop
- Product detail — shows depth of information
- Tracker — shows daily habit loop
- Profile — shows personalization

### Description tips
- First line should match your TikTok ad message
- Mention "free" prominently
- Highlight: barcode scanning, allergen warnings, Nutri-Score, offline access
