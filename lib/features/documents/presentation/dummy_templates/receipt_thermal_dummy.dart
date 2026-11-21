import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/document_model.dart';
import 'dummy_template_utils.dart';

Widget buildReceiptThermalDummy(
  DocumentType documentType, [
  BuildContext? context,
]) {
  final isDark =
      context != null && Theme.of(context).brightness == Brightness.dark;

  final paperBg = isDark ? AppColors.darkSurface : AppColors.surface;
  final textPrimary =
      isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
  final textSecondary =
      isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;
  final dividerColor = isDark ? AppColors.darkBorder : AppColors.borderStrong;
  final shadowColor = isDark
      ? Colors.black.withValues(alpha: 0.45)
      : AppColors.textPrimary.withValues(alpha: 0.12);

  return Center(
    child: PhysicalShape(
      clipper: const _ThermalSawtoothClipper(),
      color: paperBg,
      elevation: 4,
      shadowColor: shadowColor,
      child: Container(
        width: 380,
        padding: const EdgeInsets.fromLTRB(26, 20, 26, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Company Logo with circular radius of 8
            Center(
              child: buildDummyLogo(size: 38, radius: 8),
            ),
            const SizedBox(height: 8),

            // Business Name
            Text(
              DummyTemplateData.companyName.toUpperCase(),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Courier',
                fontSize: 20,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.2,
                color: textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${DummyTemplateData.companyAddress}\nPhone: ${DummyTemplateData.companyPhone}\nGSTIN: ${DummyTemplateData.companyGstin}',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Courier',
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                height: 1.3,
                color: textSecondary,
              ),
            ),
            const SizedBox(height: 12),

            // Dotted separator
            _buildDottedLine(dividerColor),
            const SizedBox(height: 10),

            // 2 Dummy Product Items
            _buildDummyItemRow(
              '1. ${DummyTemplateData.item1.title}',
              DummyTemplateData.item1.amountRs,
              textPrimary,
            ),
            _buildDummyItemRow(
              '2. ${DummyTemplateData.item2.title}',
              DummyTemplateData.item2.amountRs,
              textPrimary,
            ),

            const SizedBox(height: 14),

            // Subtotals
            _buildDummyItemRow(
              'Sub Total',
              DummyTemplateData.subtotalRs,
              textPrimary,
              isMedium: true,
            ),
            _buildDummyItemRow(
              'Tax (12%)',
              DummyTemplateData.taxRs,
              textPrimary,
              isMedium: true,
            ),

            const SizedBox(height: 8),
            _buildDottedLine(dividerColor),
            const SizedBox(height: 8),

            // TOTAL
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'TOTAL',
                  style: TextStyle(
                    fontFamily: 'Courier',
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: textPrimary,
                    letterSpacing: 0.8,
                  ),
                ),
                Text(
                  DummyTemplateData.grandTotalRs,
                  style: TextStyle(
                    fontFamily: 'Courier',
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: textPrimary,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),
            _buildDottedLine(dividerColor),
            const SizedBox(height: 8),

            // Paid By
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Paid By:',
                  style: TextStyle(
                    fontFamily: 'Courier',
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: textSecondary,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${DummyTemplateData.bankName} / UPI',
                    textAlign: TextAlign.right,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: 'Courier',
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: textPrimary,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Meta details
            Text(
              'Date: ${DummyTemplateData.issueDate}',
              style: TextStyle(
                fontFamily: 'Courier',
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: textSecondary,
              ),
            ),
            Text(
              '${documentType.displayName} No: ${DummyTemplateData.getDocNumberPlain(documentType)}',
              style: TextStyle(
                fontFamily: 'Courier',
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: textSecondary,
              ),
            ),
            Text(
              'Billed To: ${DummyTemplateData.clientName}',
              style: TextStyle(
                fontFamily: 'Courier',
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: textSecondary,
              ),
            ),
            Text(
              'Shipped To: ${DummyTemplateData.shippingName}',
              style: TextStyle(
                fontFamily: 'Courier',
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: textSecondary,
              ),
            ),

            const SizedBox(height: 14),

            // QR Code Scan to pay
            Center(
              child: Column(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: Colors.grey.shade400, width: 1),
                    ),
                    alignment: Alignment.center,
                    child: const Icon(Icons.qr_code_2, size: 44, color: Colors.black87),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    'UPI: ${DummyTemplateData.upiId}',
                    style: TextStyle(
                      fontFamily: 'Courier',
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: textSecondary,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            // Footer message
            Text(
              'Thank You For Supporting\nLocal Business!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Courier',
                fontSize: 14,
                fontWeight: FontWeight.w600,
                height: 1.35,
                color: textPrimary,
              ),
            ),
            const SizedBox(height: 6),
          ],
        ),
      ),
    ),
  );
}

Widget _buildDottedLine(Color color) {
  return Text(
    '.' * 55,
    maxLines: 1,
    overflow: TextOverflow.clip,
    style: TextStyle(
      fontFamily: 'Courier',
      fontSize: 13,
      fontWeight: FontWeight.w900,
      letterSpacing: 2.2,
      color: color,
    ),
  );
}

Widget _buildDummyItemRow(
  String title,
  String price,
  Color textColor, {
  bool isMedium = false,
}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 2.5),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontFamily: 'Courier',
              fontSize: isMedium ? 14 : 13.5,
              fontWeight: isMedium ? FontWeight.w700 : FontWeight.w500,
              color: textColor,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          price,
          style: TextStyle(
            fontFamily: 'Courier',
            fontSize: isMedium ? 14 : 13.5,
            fontWeight: isMedium ? FontWeight.w700 : FontWeight.w500,
            color: textColor,
          ),
        ),
      ],
    ),
  );
}

class _ThermalSawtoothClipper extends CustomClipper<Path> {
  static const double toothWidth = 8.0;
  static const double toothHeight = 5.0;

  const _ThermalSawtoothClipper();

  @override
  Path getClip(Size size) {
    final path = Path();

    // Start at top-left
    path.moveTo(0, toothHeight);

    // Top serrated teeth
    final topTeeth = (size.width / toothWidth).ceil();
    final actualToothWidth = size.width / topTeeth;
    for (int i = 0; i < topTeeth; i++) {
      final x = i * actualToothWidth;
      path.lineTo(x + actualToothWidth / 2, 0);
      path.lineTo(x + actualToothWidth, toothHeight);
    }

    // Right edge
    path.lineTo(size.width, size.height - toothHeight);

    // Bottom serrated teeth
    final bottomTeeth = (size.width / toothWidth).ceil();
    final actualBottomToothWidth = size.width / bottomTeeth;
    for (int i = bottomTeeth; i > 0; i--) {
      final x = i * actualBottomToothWidth;
      path.lineTo(x - actualBottomToothWidth / 2, size.height);
      path.lineTo(x - actualBottomToothWidth, size.height - toothHeight);
    }

    // Left edge
    path.lineTo(0, toothHeight);

    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
