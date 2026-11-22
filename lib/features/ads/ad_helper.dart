import 'dart:io';
import 'package:flutter/foundation.dart';

class AdHelper {
  /// Set to `false` when publishing to production with live real ads.
  /// When `true`, official Google Test Ad unit IDs are always served,
  /// preventing invalid traffic penalties during closed testing.
  static const bool useTestAds = true;

  static String get bannerAdUnitId {
    if (kIsWeb) return '';
    if (useTestAds || kDebugMode) {
      if (Platform.isAndroid) {
        return 'ca-app-pub-3940256099942544/6300978111'; // Google Test Banner
      } else if (Platform.isIOS) {
        return 'ca-app-pub-3940256099942544/2934735716'; // Google Test Banner iOS
      }
    }
    if (Platform.isAndroid) {
      return 'ca-app-pub-3285536359619016/8770780103'; // Real Android Banner
    } else if (Platform.isIOS) {
      return 'ca-app-pub-3285536359619016/8770780103'; // Real iOS Banner
    }
    return '';
  }

  static String get interstitialAdUnitId {
    if (kIsWeb) return '';
    if (useTestAds || kDebugMode) {
      if (Platform.isAndroid) {
        return 'ca-app-pub-3940256099942544/1033173712'; // Google Test Interstitial
      } else if (Platform.isIOS) {
        return 'ca-app-pub-3940256099942544/4411468910'; // Google Test Interstitial iOS
      }
    }
    if (Platform.isAndroid) {
      return 'ca-app-pub-3285536359619016/8894069036'; // Real Android Interstitial
    } else if (Platform.isIOS) {
      return 'ca-app-pub-3285536359619016/8894069036'; // Real iOS Interstitial
    }
    return '';
  }
}

