import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/document_model.dart';

Widget buildReceiptThermalDummy(
  DocumentType documentType, [
  BuildContext? context,
]) {
  final isDark =
      context != null && Theme.of(context).brightness == Brightness.dark;

  final paperBg = isDark ? AppColors.darkSurface : AppColors.surface;
  final textPrimary = isDark
      ? AppColors.darkTextPrimary
      : AppColors.textPrimary;
  final textSecondary = isDark
      ? AppColors.darkTextSecondary
      : AppColors.textSecondary;
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
            // Business Name
            Text(
              'BUSINESS NAME',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Courier',
                fontSize: 22,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.2,
                color: textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              '1234 Main Street\nSuite 567\nCity Name, State 54321\n123-456-7890',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Courier',
                fontSize: 14,
                fontWeight: FontWeight.w600,
                height: 1.3,
                color: textSecondary,
              ),
            ),
            const SizedBox(height: 14),

            // Dotted separator
            _buildDottedLine(dividerColor),
            const SizedBox(height: 12),

            // Item list
            _buildDummyItemRow('Lorem ipsum', '\$1.25', textPrimary),
            _buildDummyItemRow('Dolor sit amet', '\$7.99', textPrimary),
            _buildDummyItemRow('Consectetur', '\$26.70', textPrimary),
            _buildDummyItemRow('Adipiscing elit', '\$15.49', textPrimary),
            _buildDummyItemRow('Sed semper', '\$18.79', textPrimary),
            _buildDummyItemRow('Accumsan ante', '\$42.99', textPrimary),
            _buildDummyItemRow('Non laoreet', '\$9.99', textPrimary),
            _buildDummyItemRow('Dui dapibus eu', '\$27.50', textPrimary),

            const SizedBox(height: 16),

            // Subtotals
            _buildDummyItemRow(
              'Sub Total',
              '\$150.70',
              textPrimary,
              isMedium: true,
            ),
            _buildDummyItemRow(
              'Sales Tax',
              '\$5.29',
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
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: textPrimary,
                    letterSpacing: 0.8,
                  ),
                ),
                Text(
                  '\$155.99',
                  style: TextStyle(
                    fontFamily: 'Courier',
                    fontSize: 22,
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
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: textSecondary,
                  ),
                ),
                Text(
                  'Credit',
                  style: TextStyle(
                    fontFamily: 'Courier',
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: textPrimary,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Meta details
            Text(
              '02/08/2022 09:36',
              style: TextStyle(
                fontFamily: 'Courier',
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: textSecondary,
              ),
            ),
            Text(
              'Transaction ID: 234-567890',
              style: TextStyle(
                fontFamily: 'Courier',
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: textSecondary,
              ),
            ),
            Text(
              'Vendor ID: 987654-321',
              style: TextStyle(
                fontFamily: 'Courier',
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: textSecondary,
              ),
            ),

            const SizedBox(height: 22),

            // Footer message
            Text(
              'Thank You For Supporting\nLocal Business!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Courier',
                fontSize: 15,
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
        Text(
          title,
          style: TextStyle(
            fontFamily: 'Courier',
            fontSize: isMedium ? 15 : 14.5,
            fontWeight: isMedium ? FontWeight.w700 : FontWeight.w500,
            color: textColor,
          ),
        ),
        Text(
          price,
          style: TextStyle(
            fontFamily: 'Courier',
            fontSize: isMedium ? 15 : 14.5,
            fontWeight: isMedium ? FontWeight.w700 : FontWeight.w500,
            color: textColor,
          ),
        ),
      ],
    ),
  );
}

class _ThermalSawtoothClipper extends CustomClipper<Path> {
  final double toothWidth;
  final double toothHeight;

  const _ThermalSawtoothClipper({
    this.toothWidth = 8.0,
    this.toothHeight = 5.0,
  });

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
    final actualBottomWidth = size.width / bottomTeeth;
    for (int i = bottomTeeth - 1; i >= 0; i--) {
      final x = i * actualBottomWidth;
      path.lineTo(x + actualBottomWidth / 2, size.height);
      path.lineTo(x, size.height - toothHeight);
    }

    // Left edge
    path.lineTo(0, toothHeight);

    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
