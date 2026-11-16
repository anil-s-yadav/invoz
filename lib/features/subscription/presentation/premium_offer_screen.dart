import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/services/analytics_service.dart';
import '../../business_profile/bloc/business_profile_bloc.dart';
import '../../business_profile/bloc/business_profile_state.dart';
import '../data/subscription_repository.dart';
import '../domain/subscription_plan_model.dart';
import '../../subscriptions/bloc/subscription_bloc.dart';
import 'checkout_screen.dart';
import 'payment_success_screen.dart';
import 'subscription_screen.dart';

class PremiumOfferScreen extends StatefulWidget {
  const PremiumOfferScreen({super.key});

  static Future<void> show(BuildContext context) {
    return Navigator.of(context).push(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => const PremiumOfferScreen(),
      ),
    );
  }

  @override
  State<PremiumOfferScreen> createState() => _PremiumOfferScreenState();
}

class _PremiumOfferScreenState extends State<PremiumOfferScreen> {
  int _selectedDuration = 1; // 1: 1-Month Free Experience, 12: 1-Year (50% Off)
  bool _isProcessing = false;
  late Razorpay _razorpay;

  @override
  void initState() {
    super.initState();
    AnalyticsService.logPricingViewed();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  @override
  void dispose() {
    _razorpay.clear();
    super.dispose();
  }

  Future<void> _activateFreeTrial() async {
    setState(() => _isProcessing = true);
    final now = DateTime.now();
    final repo = SubscriptionRepository();

    final freePlan = SubscriptionPlanModel(
      id: 'welcome_free_${now.millisecondsSinceEpoch}',
      planName: 'Professional',
      price: 99.0,
      durationMonths: 1,
      discountPercentage: 1.0,
      discountAmount: 99.0,
      gstAmount: 0.0,
      finalAmount: 0.0,
      status: 'Active',
      transactionId: 'FREE_TRIAL_${now.millisecondsSinceEpoch}',
      paymentMethod: 'Welcome Offer',
      startDate: now,
      expiryDate: now.add(const Duration(days: 30)),
      autoRenew: false,
      createdAt: now,
      maxCompaniesAllowed: 3,
      maxClientsAllowed: -1,
      maxItemsAllowed: -1,
      maxDocumentsPerDay: -1,
      maxDevicesAllowed: 3,
      isAdFree: true,
      hasPremiumTemplates: true,
      hasAnalytics: true,
      isWelcomeOffer: true,
    );

    try {
      await repo.saveOrUpgradePlan(freePlan);
    } catch (_) {}

    if (!mounted) return;
    context.read<SubscriptionBloc>().add(ActivateSubscriptionEvent(freePlan));

    setState(() => _isProcessing = false);

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => PaymentSuccessScreen(plan: freePlan)),
    );
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    final now = DateTime.now();
    final repo = SubscriptionRepository();

    // 1-Year Professional Plan @ 50% discount = ₹594
    final paidPlan = SubscriptionPlanModel(
      id: 'pro_12m_${now.millisecondsSinceEpoch}',
      planName: 'Professional',
      price: 1188.0,
      durationMonths: 12,
      discountPercentage: 0.50,
      discountAmount: 594.0,
      gstAmount: 0.0,
      finalAmount: 594.0,
      status: 'Active',
      transactionId: response.paymentId ?? '${now.millisecondsSinceEpoch}',
      orderId: response.orderId,
      paymentSignature: response.signature,
      paymentMethod: 'Razorpay (Card/UPI/NetBanking)',
      startDate: now,
      expiryDate: now.add(const Duration(days: 365)),
      autoRenew: true,
      createdAt: now,
      maxCompaniesAllowed: 3,
      maxClientsAllowed: -1,
      maxItemsAllowed: -1,
      maxDocumentsPerDay: -1,
      maxDevicesAllowed: 3,
      isAdFree: true,
      hasPremiumTemplates: true,
      hasAnalytics: true,
      isWelcomeOffer: true,
    );

    try {
      await repo.saveOrUpgradePlan(paidPlan);
    } catch (_) {}

    if (!mounted) return;
    context.read<SubscriptionBloc>().add(ActivateSubscriptionEvent(paidPlan));

    setState(() => _isProcessing = false);

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => PaymentSuccessScreen(plan: paidPlan)),
    );
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    if (!mounted) return;
    setState(() => _isProcessing = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          response.message?.isNotEmpty == true
              ? 'Payment failed: ${response.message}'
              : 'Payment was cancelled or failed.',
        ),
        backgroundColor: Colors.red.shade700,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('External Wallet Selected: ${response.walletName}'),
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _handlePrimaryAction() {
    if (_isProcessing) return;

    if (_selectedDuration == 1) {
      // 100% FREE 1-Month Experience
      _activateFreeTrial();
    } else {
      // 1-Year Plan @ 50% Welcome Discount (₹594)
      _startPaidAnnualCheckout();
    }
  }

  void _startPaidAnnualCheckout() {
    setState(() => _isProcessing = true);
    String prefillEmail = '';
    String prefillContact = '';

    try {
      final profileState = context.read<BusinessProfileBloc>().state;
      if (profileState is BusinessProfileLoaded) {
        prefillEmail = profileState.profile.email ?? '';
        prefillContact = profileState.profile.phone ?? '';
      }
    } catch (_) {}

    prefillEmail = prefillEmail.trim();
    prefillContact = prefillContact.trim().replaceAll(RegExp(r'[^\d+]'), '');
    if (prefillContact.startsWith('+91') && prefillContact.length == 13) {
      prefillContact = prefillContact.substring(3);
    } else if (prefillContact.startsWith('91') && prefillContact.length == 12) {
      prefillContact = prefillContact.substring(2);
    } else if (prefillContact.startsWith('0') && prefillContact.length == 11) {
      prefillContact = prefillContact.substring(1);
    }

    final options = {
      'key': kDebugMode
          ? 'rzp_test_ThkLyPi706leO9'
          : 'rzp_live_YOUR_PRODUCTION_KEY_HERE',
      'amount': 59400, // ₹594 in paise (50% off ₹1,188)
      'name': 'Invoz App',
      'description': 'Professional 1-Year Plan (50% Welcome Offer)',
      'timeout': 120,
      'prefill': {'contact': prefillContact, 'email': prefillEmail},
      'theme': {'color': '#4F46E5'},
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      setState(() => _isProcessing = false);
      // Fallback if Razorpay plugin fails on web/desktop
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => const CheckoutScreen(
            planName: 'Professional',
            monthlyPrice: 99.0,
            hasWelcomeOffer: true,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final scaffoldBg = isDark ? AppColors.darkCanvas : const Color(0xFFF8FAFC);
    final cardBg = isDark ? AppColors.darkSurface : Colors.white;
    final textDark = isDark
        ? AppColors.darkTextPrimary
        : const Color(0xFF1E293B);
    final textMuted = isDark
        ? AppColors.darkTextSecondary
        : const Color(0xFF64748B);
    final borderColor = isDark ? AppColors.darkBorder : const Color(0xFFE2E8F0);

    return Scaffold(
      backgroundColor: scaffoldBg,

      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: AlignmentGeometry.topLeft,
              child: IconButton(
                icon: Icon(
                  Icons.close_rounded,
                  color: isDark
                      ? AppColors.darkTextPrimary
                      : const Color(0xFF1E293B),
                  size: 26,
                ),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
            // Scrollable Body
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // 1. HERO BANNER
                    Container(
                      padding: const EdgeInsets.fromLTRB(20, 22, 16, 22),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: isDark
                              ? [
                                  const Color(0xFF1E1B4B),
                                  const Color(0xFF1E293B),
                                  const Color(0xFF0F172A),
                                ]
                              : [
                                  const Color(0xFFE0E7FF),
                                  const Color(0xFFEEF2FF),
                                  const Color(0xFFF0F9FF),
                                ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(
                              alpha: isDark ? 0.3 : 0.04,
                            ),
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Left Text
                          Expanded(
                            flex: 6,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "We're building",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    color: isDark
                                        ? AppColors.darkTextPrimary
                                        : const Color(0xFF1E1B4B),
                                    letterSpacing: -0.3,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                const Text(
                                  "CONFIDENCE",
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w900,
                                    color: Color(0xFF4F46E5),
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  "to grow your business",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: isDark
                                        ? AppColors.darkTextPrimary
                                        : const Color(0xFF1E1B4B),
                                    letterSpacing: -0.3,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Right Invoz Logo Card
                          Expanded(
                            flex: 4,
                            child: Center(
                              child: Container(
                                width: 82,
                                height: 82,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(18),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(
                                        alpha: 0.08,
                                      ),
                                      blurRadius: 16,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(18),
                                  child: Image.asset(
                                    'assets/icons/applogo.png',
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // 2. OFFER DURATION SWITCHER (Sliding Capsule - No Blinking)
                    Container(
                      height: 48,
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF1E293B)
                            : const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isDark
                              ? const Color(0xFF334155)
                              : const Color(0xFFE2E8F0),
                          width: 1,
                        ),
                      ),
                      child: Stack(
                        children: [
                          // Smooth Sliding White Pill Indicator (No fade / No blink)
                          AnimatedAlign(
                            alignment: _selectedDuration == 1
                                ? Alignment.centerLeft
                                : Alignment.centerRight,
                            duration: const Duration(milliseconds: 200),
                            curve: Curves.fastOutSlowIn,
                            child: FractionallySizedBox(
                              widthFactor: 0.5,
                              heightFactor: 1.0,
                              child: Container(
                                margin: const EdgeInsets.all(3),
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? const Color(0xFF334155)
                                      : Colors.white,
                                  borderRadius: BorderRadius.circular(11),
                                  border: Border.all(
                                    color: isDark
                                        ? const Color(0xFF475569)
                                        : const Color(0xFFE2E8F0),
                                    width: 0.8,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(
                                        alpha: isDark ? 0.25 : 0.06,
                                      ),
                                      blurRadius: 4,
                                      offset: const Offset(0, 1.5),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),

                          // Two Transparent Touch Targets on Top
                          Row(
                            children: [
                              // Option 1: 1 Month Free
                              Expanded(
                                child: GestureDetector(
                                  behavior: HitTestBehavior.opaque,
                                  onTap: () {
                                    if (_selectedDuration != 1) {
                                      setState(() {
                                        _selectedDuration = 1;
                                      });
                                    }
                                  },
                                  child: Center(
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          '1 Month',
                                          style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: _selectedDuration == 1
                                                ? FontWeight.w800
                                                : FontWeight.w600,
                                            color: _selectedDuration == 1
                                                ? (isDark
                                                      ? Colors.white
                                                      : const Color(0xFF0F172A))
                                                : textMuted,
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 6,
                                            vertical: 2.5,
                                          ),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF10B981),
                                            borderRadius: BorderRadius.circular(
                                              6,
                                            ),
                                          ),
                                          child: const Text(
                                            '100% FREE',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 9.5,
                                              fontWeight: FontWeight.w900,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),

                              // Option 2: 1 Year (50% Off)
                              Expanded(
                                child: GestureDetector(
                                  behavior: HitTestBehavior.opaque,
                                  onTap: () {
                                    if (_selectedDuration != 12) {
                                      setState(() {
                                        _selectedDuration = 12;
                                      });
                                    }
                                  },
                                  child: Center(
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          '1 Year',
                                          style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: _selectedDuration == 12
                                                ? FontWeight.w800
                                                : FontWeight.w600,
                                            color: _selectedDuration == 12
                                                ? (isDark
                                                      ? Colors.white
                                                      : const Color(0xFF0F172A))
                                                : textMuted,
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 6,
                                            vertical: 2.5,
                                          ),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFEA580C),
                                            borderRadius: BorderRadius.circular(
                                              6,
                                            ),
                                          ),
                                          child: const Text(
                                            '60% OFF',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 9.5,
                                              fontWeight: FontWeight.w900,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // 3. MAIN OFFER CARD (Matches Screenshot Structure)
                    Container(
                      decoration: BoxDecoration(
                        color: cardBg,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: borderColor, width: 1),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(
                              alpha: isDark ? 0.3 : 0.04,
                            ),
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(20, 22, 20, 18),
                            child: Column(
                              children: [
                                Text(
                                  _selectedDuration == 1
                                      ? 'Unlock 1 Month Premium for'
                                      : 'Unlock 1 Year Premium for',
                                  style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w800,
                                    color: textDark,
                                    letterSpacing: -0.2,
                                  ),
                                ),
                                const SizedBox(height: 10),

                                // Giant Price
                                if (_selectedDuration == 1) ...[
                                  const Text(
                                    '₹ 0',
                                    style: TextStyle(
                                      fontSize: 58,
                                      fontWeight: FontWeight.w900,
                                      color: Color(
                                        0xFF6D28D9,
                                      ), // Vibrant purple
                                      height: 1.1,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        'Actual Price ',
                                        style: TextStyle(
                                          fontSize: 14.5,
                                          fontWeight: FontWeight.w600,
                                          color: textDark,
                                        ),
                                      ),
                                      Text(
                                        '₹99 ',
                                        style: TextStyle(
                                          fontSize: 14.5,
                                          decoration:
                                              TextDecoration.lineThrough,
                                          color: textMuted,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      Text(
                                        '₹49/month',
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w900,
                                          color: textDark,
                                        ),
                                      ),
                                    ],
                                  ),
                                  // const SizedBox(height: 4),
                                  // Text(
                                  //   'Cancel anytime',
                                  //   style: TextStyle(
                                  //     fontSize: 12,
                                  //     color: textMuted,
                                  //     fontWeight: FontWeight.w500,
                                  //   ),
                                  // ),
                                ] else ...[
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.baseline,
                                    textBaseline: TextBaseline.alphabetic,
                                    children: [
                                      const Text(
                                        '₹ 49',
                                        style: TextStyle(
                                          fontSize: 56,
                                          fontWeight: FontWeight.w900,
                                          color: Color(0xFF6D28D9),
                                          height: 1.1,
                                        ),
                                      ),
                                      Text(
                                        ' /month',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700,
                                          color: textMuted,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        'Billed annually ',
                                        style: TextStyle(
                                          fontSize: 14.5,
                                          fontWeight: FontWeight.w600,
                                          color: textDark,
                                        ),
                                      ),
                                      Text(
                                        '₹1,188 ',
                                        style: TextStyle(
                                          fontSize: 14.5,
                                          decoration:
                                              TextDecoration.lineThrough,
                                          color: textMuted,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      Text(
                                        '₹499/year',
                                        style: const TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w900,
                                          color: Color(0xFF047857),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ],
                            ),
                          ),

                          // Discount Coupon Strip
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? const Color(0xFF2A1520)
                                  : const Color(0xFFFFF1F2),
                              borderRadius: const BorderRadius.only(
                                bottomLeft: Radius.circular(19),
                                bottomRight: Radius.circular(19),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text(
                                  '🥳',
                                  style: TextStyle(fontSize: 18),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  _selectedDuration == 1
                                      ? 'INVOZWELCOME applied'
                                      : 'WELCOME50 applied',
                                  style: TextStyle(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w700,
                                    color: isDark
                                        ? const Color(0xFFFDA4AF)
                                        : const Color(0xFF9F1239),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFE11D48),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    _selectedDuration == 1
                                        ? '100% FREE'
                                        : '60% OFF',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // 4. INCLUDED PREMIUM BENEFITS (CONVINCE USER)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: cardBg,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: borderColor, width: 1),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(
                              alpha: isDark ? 0.3 : 0.04,
                            ),
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.star_rounded,
                                color: Color(0xFFF59E0B),
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Everything Included in Premium:',
                                style: TextStyle(
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w800,
                                  color: textDark,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          _buildFeatureItem(
                            'Unlimited Invoices, Quotations, Proforma & Receipts',
                            isDark: isDark,
                          ),
                          _buildFeatureItem(
                            'All Premium Templates Unlocked',
                            isDark: isDark,
                          ),
                          _buildFeatureItem(
                            '100% Ad-Free Experience',
                            isDark: isDark,
                          ),
                          _buildFeatureItem(
                            'Full Business Analytics & Financial Reports',
                            isDark: isDark,
                          ),
                          _buildFeatureItem(
                            'Multi-Device Instant Sync & Cloud Backup',
                            isDark: isDark,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // 5. ACCEPTED PAYMENT METHODS (Clean, Uncrowded & Borderless Items)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      // decoration: BoxDecoration(
                      //   color: cardBg,
                      //   borderRadius: BorderRadius.circular(16),
                      //   border: Border.all(color: borderColor, width: 1),
                      //   boxShadow: [
                      //     BoxShadow(
                      //       color: Colors.black.withValues(
                      //         alpha: isDark ? 0.2 : 0.03,
                      //       ),
                      //       blurRadius: 8,
                      //       offset: const Offset(0, 2),
                      //     ),
                      //   ],
                      // ),
                      child: Column(
                        children: [
                          // Row(
                          //   mainAxisAlignment: MainAxisAlignment.center,
                          //   children: [
                          //     const Icon(
                          //       Icons.lock_rounded,
                          //       size: 13,
                          //       color: Color(0xFF10B981),
                          //     ),
                          //     const SizedBox(width: 5),
                          //     Text(
                          //       '100% SECURE CHECKOUT • GLOBAL & INDIA',
                          //       style: TextStyle(
                          //         fontSize: 10.5,
                          //         fontWeight: FontWeight.w800,
                          //         letterSpacing: 0.5,
                          //         color: textMuted,
                          //       ),
                          //     ),
                          //   ],
                          // ),
                          // const SizedBox(height: 10),
                          // Clean uncrowded row without border containers
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _buildPaymentItem(
                                label: 'Cards',
                                iconWidget: const Icon(
                                  Icons.credit_card_rounded,
                                  size: 16,
                                  color: Color(0xFF2563EB),
                                ),
                                isDark: isDark,
                              ),
                              _buildPaymentItem(
                                label: 'GPay',
                                iconWidget: SizedBox(
                                  width: 15,
                                  height: 15,
                                  child: Image.asset(
                                    'assets/icons/google.png',
                                    fit: BoxFit.contain,
                                  ),
                                ),
                                isDark: isDark,
                              ),
                              _buildPaymentItem(
                                label: 'UPI',
                                iconWidget: Container(
                                  width: 15,
                                  height: 15,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFF5F259F),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Center(
                                    child: Text(
                                      'पे',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 8,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                                isDark: isDark,
                              ),
                              _buildPaymentItem(
                                label: 'NetBanking',
                                iconWidget: const Icon(
                                  Icons.account_balance_rounded,
                                  size: 15,
                                  color: Color(0xFF059669),
                                ),
                                isDark: isDark,
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Visa • Mastercard • Amex • UPI • 50+ Banks',
                            style: TextStyle(
                              fontSize: 10.5,
                              color: textMuted,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // const SizedBox(height: 16),

                    // // 6. GUARANTEED REFUND & AUTO-RENEW NOTICE
                    // Container(
                    //   padding: const EdgeInsets.symmetric(
                    //     horizontal: 16,
                    //     vertical: 10,
                    //   ),
                    //   decoration: BoxDecoration(
                    //     color: isDark
                    //         ? const Color(0xFF064E3B).withValues(alpha: 0.3)
                    //         : const Color(0xFFECFDF5),
                    //     borderRadius: BorderRadius.circular(12),
                    //     border: Border.all(
                    //       color: const Color(0xFF10B981).withValues(alpha: 0.3),
                    //       width: 1,
                    //     ),
                    //   ),
                    //   child: Row(
                    //     mainAxisAlignment: MainAxisAlignment.center,
                    //     children: [
                    //       const Icon(
                    //         Icons.verified_user_rounded,
                    //         color: Color(0xFF047857),
                    //         size: 16,
                    //       ),
                    //       const SizedBox(width: 6),
                    //       Text(
                    //         '100% SECURE CHECKOUT',

                    //         style: const TextStyle(
                    //           fontSize: 12.5,
                    //           fontWeight: FontWeight.bold,
                    //           color: Color(0xFF047857),
                    //         ),
                    //       ),
                    //     ],
                    //   ),
                    // ),
                    // const SizedBox(height: 8),

                    // Text(
                    //   _selectedDuration == 1
                    //       ? 'Enjoy 30 days of full premium experience for ₹0. Cancel anytime before renewal.'
                    //       : 'Billed annually with 50% Welcome Discount. Auto-renews unless cancelled.',
                    //   textAlign: TextAlign.center,
                    //   style: TextStyle(
                    //     fontSize: 11.5,
                    //     color: textMuted,
                    //     height: 1.3,
                    //   ),
                    // ),
                    const SizedBox(height: 10),

                    // 7. VIEW ALL PLANS LINK
                    Center(
                      child: TextButton(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const SubscriptionScreen(),
                            ),
                          );
                        },
                        child: Text(
                          'Compare all plans & pricing →',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: isDark
                                ? const Color(0xFF818CF8)
                                : const Color(0xFF4F46E5),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // 8. STICKY BOTTOM CHECKOUT BAR (Matches Screenshot Structure)
            Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
              decoration: BoxDecoration(
                color: cardBg,
                border: Border(top: BorderSide(color: borderColor, width: 1)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.08),
                    blurRadius: 16,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: SafeArea(
                top: false,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        // Left: Price & Status (Clean & Informational)
                        Expanded(
                          flex: 4,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                _selectedDuration == 1
                                    ? 'TOTAL TODAY'
                                    : 'ANNUAL PLAN',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  color: textMuted,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                _selectedDuration == 1 ? '₹0 FREE' : '₹499/yr',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w900,
                                  color: _selectedDuration == 1
                                      ? const Color(0xFF10B981)
                                      : (isDark
                                            ? Colors.white
                                            : const Color(0xFF0F172A)),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Right: Primary Action Button
                        Expanded(
                          flex: 6,
                          child: SizedBox(
                            height: 50,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(
                                  0xFFF95721,
                                ), // Bright Orange
                                foregroundColor: Colors.white,
                                elevation: 4,
                                shadowColor: const Color(
                                  0xFFF95721,
                                ).withValues(alpha: 0.45),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(25),
                                ),
                              ),
                              onPressed: _isProcessing
                                  ? null
                                  : _handlePrimaryAction,
                              child: _isProcessing
                                  ? const SizedBox(
                                      width: 22,
                                      height: 22,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.5,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                              Colors.white,
                                            ),
                                      ),
                                    )
                                  : Text(
                                      _selectedDuration == 1
                                          ? 'Claim 1-Month Free @ ₹0'
                                          : 'Get 1 Year Plan @ ₹499',
                                      style: const TextStyle(
                                        fontSize: 13.5,
                                        fontWeight: FontWeight.w900,
                                        letterSpacing: -0.2,
                                      ),
                                    ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Safety, Security & Trust Convince Text
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.verified_user_rounded,
                          size: 13,
                          color: Color(0xFF10B981),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          '100% Secure & Risk-Free  •  Cancel Anytime  •  256-Bit SSL',
                          style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w600,
                            color: textMuted,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureItem(String title, {required bool isDark}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 2),
            padding: const EdgeInsets.all(2),
            decoration: const BoxDecoration(
              color: Color(0xFF10B981),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_rounded,
              color: Colors.white,
              size: 11,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: isDark
                    ? AppColors.darkTextSecondary
                    : const Color(0xFF334155),
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // READ-ONLY BORDERLESS PAYMENT ITEMS
  Widget _buildPaymentItem({
    required String label,
    required Widget iconWidget,
    required bool isDark,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        iconWidget,
        const SizedBox(width: 5),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: isDark ? AppColors.darkTextPrimary : const Color(0xFF334155),
          ),
        ),
      ],
    );
  }
}
