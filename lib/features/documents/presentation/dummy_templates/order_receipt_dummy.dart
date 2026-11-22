import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/document_model.dart';
import 'dummy_template_utils.dart';

Widget buildOrderReceiptDummy(
  DocumentType documentType, [
  BuildContext? context,
]) {
  final isDark =
      context != null && Theme.of(context).brightness == Brightness.dark;

  final cardBg = isDark ? AppColors.darkSurface : AppColors.surface;
  final textPrimary =
      isDark ? AppColors.darkTextPrimary : const Color(0xFF1E293B);
  final textSecondary =
      isDark ? AppColors.darkTextSecondary : const Color(0xFF64748B);
  final textMuted = isDark ? AppColors.darkTextMuted : const Color(0xFF94A3B8);
  final borderColor = isDark ? AppColors.darkBorder : const Color(0xFFCBD5E1);
  final linkColor = isDark ? AppColors.primaryDark : AppColors.primary;
  const greenBannerBg = Color(0xFF00A859);

  return Center(
    child: Container(
      width: 440,
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: borderColor.withValues(alpha: 0.6),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.08),
            offset: const Offset(0, 4),
            blurRadius: 16,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(28, 24, 28, 16),
              child: Column(
                children: [
                  // Dummy Company Logo with circular radius of 8
                  Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: buildDummyLogo(size: 44, radius: 8),
                  ),
                  Text(
                    'Thanks For Your Business!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      color: textPrimary,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    DummyTemplateData.companyName,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: textSecondary,
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Your order section
                  Text(
                    'Your ${documentType.displayName}',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${DummyTemplateData.getDocNumberPlain(documentType)} • Payment Date: ${DummyTemplateData.paymentDate}',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: textMuted,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 2 Dummy Product Items
                  for (final item in DummyTemplateData.items)
                    _buildItemRow(
                      '${item.title} (x${item.qtyIntString})',
                      item.amountRs,
                      textPrimary,
                    ),
                  const SizedBox(height: 8),

                  // Subtotals
                  _buildSubtotalRow(
                    'Subtotal',
                    DummyTemplateData.subtotalRs,
                    textSecondary,
                  ),
                  _buildSubtotalRow(
                    'Tax (12%)',
                    DummyTemplateData.taxRs,
                    textSecondary,
                  ),
                  const SizedBox(height: 8),

                  // Total with top & bottom borders
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    decoration: BoxDecoration(
                      border: Border.symmetric(
                        horizontal: BorderSide(
                          color: textPrimary,
                          width: 1.5,
                        ),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: textPrimary,
                          ),
                        ),
                        Text(
                          DummyTemplateData.grandTotalRs,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w900,
                            color: textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Your details section (Billed to)
                  Text(
                    'Your details',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: textPrimary,
                    ),
                  ),
                  const SizedBox(height: 14),

                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 100,
                        child: Text(
                          'Billed to',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: textPrimary,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          '${DummyTemplateData.clientName}\n${DummyTemplateData.clientAddress}\n${DummyTemplateData.clientEmail}',
                          style: TextStyle(
                            fontSize: 11,
                            height: 1.35,
                            color: textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Payment Details with QR Code
                  buildDummyPaymentDetails(
                    type: documentType,
                    primary: greenBannerBg,
                    isDark: isDark,
                  ),
                  const SizedBox(height: 14),

                  // Support help text
                  RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      style: TextStyle(
                        fontSize: 10.5,
                        color: textSecondary,
                        height: 1.3,
                      ),
                      children: [
                        const TextSpan(text: 'Need help? Contact us at '),
                        TextSpan(
                          text: DummyTemplateData.companyEmail,
                          style: TextStyle(
                            color: linkColor,
                            decoration: TextDecoration.underline,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Compact Invoz Promo Banner
            Container(
              color: greenBannerBg,
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 10,
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.receipt_long_rounded,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Text(
                          'Created with Invoz App',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: -0.2,
                          ),
                        ),
                        SizedBox(height: 1),
                        Text(
                          'Fast invoices & receipts for small businesses',
                          style: TextStyle(
                            fontSize: 9.5,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Text(
                      'Get Invoz',
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w800,
                        color: greenBannerBg,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Bottom footer
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Text(
                'Thanks for being a great customer.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w500,
                  color: textSecondary,
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

Widget _buildItemRow(String title, String price, Color textColor) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            title,
            style: TextStyle(fontSize: 12, color: textColor),
          ),
        ),
        Text(
          price,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: textColor,
          ),
        ),
      ],
    ),
  );
}

Widget _buildSubtotalRow(String title, String price, Color textColor) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 2.5),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(fontSize: 11, color: textColor),
        ),
        Text(
          price,
          style: TextStyle(fontSize: 11, color: textColor),
        ),
      ],
    ),
  );
}
