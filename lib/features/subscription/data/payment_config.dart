import 'package:flutter/foundation.dart';

/// Centralized configuration for in-app payments.
class PaymentConfig {
  PaymentConfig._();

  /// Set to `false` when deploying to production with live Razorpay credentials.
  /// When `true`, the test key is used even in release builds (for Closed Testing).
  static const bool useTestKey = true;

  /// Razorpay Test Key ID
  static const String testKey = 'rzp_test_ThkLyPi706leO9';

  /// Razorpay Live Production Key ID (Replace with real live key when going to production)
  static const String liveKey = 'rzp_live_YOUR_PRODUCTION_KEY_HERE';

  /// Active key determined by the [useTestKey] flag and [kDebugMode]
  static String get razorpayKey => (useTestKey || kDebugMode) ? testKey : liveKey;
}
