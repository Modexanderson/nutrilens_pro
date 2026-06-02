// lib/services/ad_service.dart

import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'dart:io';

class AdService {
  static AdService? _instance;
  static AdService get instance => _instance ??= AdService._();

  AdService._();

  // =====================================================
  // PRODUCTION AD UNIT IDs
  // iOS ad units from AdMob console (ca-app-pub-5507149125881523)
  // Android: CREATE AD UNITS IN ADMOB AND REPLACE BELOW
  // =====================================================
  static String get bannerAdUnitId {
    if (Platform.isAndroid) {
      // TODO: Create Android app in AdMob and add banner ad unit ID
      return 'ca-app-pub-3940256099942544/6300978111'; // TEST ID - Replace!
    } else if (Platform.isIOS) {
      return 'ca-app-pub-5507149125881523/5633453325';
    }
    throw UnsupportedError('Unsupported platform');
  }

  static String get interstitialAdUnitId {
    if (Platform.isAndroid) {
      // TODO: Create Android app in AdMob and add interstitial ad unit ID
      return 'ca-app-pub-3940256099942544/1033173712'; // TEST ID - Replace!
    } else if (Platform.isIOS) {
      return 'ca-app-pub-5507149125881523/4950927048';
    }
    throw UnsupportedError('Unsupported platform');
  }

  BannerAd? _bannerAd;
  InterstitialAd? _interstitialAd;
  bool _isInterstitialAdReady = false;

  // Banner Ad
  BannerAd createBannerAd() {
    _bannerAd = BannerAd(
      adUnitId: bannerAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          // Ad loaded successfully
        },
        onAdFailedToLoad: (ad, error) {
          FirebaseCrashlytics.instance.log('Banner ad failed to load: ${error.message}');
          ad.dispose();
        },
        onAdClicked: (ad) {
          FirebaseCrashlytics.instance.log('Banner ad clicked');
        },
      ),
    );

    _bannerAd!.load();
    return _bannerAd!;
  }

  void disposeBannerAd() {
    _bannerAd?.dispose();
    _bannerAd = null;
  }

  // Interstitial Ad
  Future<void> loadInterstitialAd() async {
    await InterstitialAd.load(
      adUnitId: interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _isInterstitialAdReady = true;

          _interstitialAd!.fullScreenContentCallback =
              FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
              _isInterstitialAdReady = false;
              loadInterstitialAd(); // Preload next ad
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              FirebaseCrashlytics.instance
                  .log('Interstitial failed to show: ${error.message}');
              ad.dispose();
              _isInterstitialAdReady = false;
              loadInterstitialAd();
            },
          );
        },
        onAdFailedToLoad: (error) {
          FirebaseCrashlytics.instance
              .log('Interstitial failed to load: ${error.message}');
          _isInterstitialAdReady = false;
        },
      ),
    );
  }

  void showInterstitialAd() {
    if (_isInterstitialAdReady && _interstitialAd != null) {
      _interstitialAd!.show();
      _isInterstitialAdReady = false;
      _interstitialAd = null;
    } else {
      loadInterstitialAd();
    }
  }

  void disposeInterstitialAd() {
    _interstitialAd?.dispose();
    _interstitialAd = null;
    _isInterstitialAdReady = false;
  }
}
