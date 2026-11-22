import 'package:flutter/material.dart';
import 'package:invoz/features/documents/domain/document_model.dart';

/// Representation of a standardized dummy product item.
class DummyProductItem {
  final String title;
  final String description;
  final String hsn;
  final String itemCode;
  final double qty;
  final double rate;
  final double taxPercent;
  final double discountPercent;

  const DummyProductItem({
    required this.title,
    required this.description,
    this.hsn = '',
    this.itemCode = 'PRD-001',
    required this.qty,
    required this.rate,
    this.taxPercent = 12.0,
    this.discountPercent = 0.0,
  });

  double get taxableAmount => (qty * rate) * (1 - discountPercent / 100);
  double get taxAmount => taxableAmount * (taxPercent / 100);
  double get totalAmount => taxableAmount + taxAmount;

  // Formatted helpers
  String get qtyString => qty.toStringAsFixed(1);
  String get qtyIntString => qty.toInt().toString();
  String get rateRs => 'Rs. ${rate.toStringAsFixed(2)}';
  String get rateInr => '₹${rate.toStringAsFixed(2)}';
  String get rateUsd => '\$${rate.toStringAsFixed(2)}';
  String get amountRs => 'Rs. ${totalAmount.toStringAsFixed(2)}';
  String get amountInr => '₹${totalAmount.toStringAsFixed(2)}';
  String get amountUsd => '\$${totalAmount.toStringAsFixed(2)}';
  String get taxableRs => 'Rs. ${taxableAmount.toStringAsFixed(2)}';
  String get taxableInr => '₹${taxableAmount.toStringAsFixed(2)}';
  String get taxPercentString => '${taxPercent.toStringAsFixed(1)}%';
}

/// Centralized dummy data for all template previews.
/// Eliminates code duplication and ensures consistency across all preview templates.
/// All company and customer details are 100% fictional to avoid copyright or trademark issues.
class DummyTemplateData {
  DummyTemplateData._();

  // Company / From Information (Dummy company logo + Fictional company)
  static const String logoAsset = 'assets/icons/dummy_company_logo.png';
  static const double logoRadius = 8.0;

  static const String companyName = 'Acme Innovations Pvt. Ltd.';
  static const String companyEmail = 'contact@example.com';
  static const String companyPhone = '+1 555-0199';
  static const String companyAddress =
      '42 Business Park, Industrial Area, Metro City - 110001';
  static const String companyGstin = '27AAAAA0000A1Z5';
  static const String companyPan = 'AAAAA0000A';
  static const String companyWebsite = 'www.example.com';

  static const String companyContactLine =
      'contact@example.com  •  +1 555-0199';
  static const String companyFullAddress =
      'contact@example.com  •  +1 555-0199\n42 Business Park, Industrial Area, Metro City - 110001\nGSTIN: 27AAAAA0000A1Z5';

  // Client / Billed To Information (Fictional client)
  static const String clientName = 'Global Horizon Trading Co.';
  static const String clientEmail = 'accounts@example.com';
  static const String clientPhone = '+1 555-0144';
  static const String clientAddress =
      '742 Evergreen Street, North District, Cityville - 110025';
  static const String clientGstin = '29BBBBB0000B1Z5';
  static const String clientPan = 'BBBBB0000B';

  static const String clientContactLine =
      'accounts@example.com  •  +1 555-0144';
  static const String clientFullAddress =
      'accounts@example.com  •  +1 555-0144\n742 Evergreen Street, North District, Cityville - 110025\nGSTIN: 29BBBBB0000B1Z5';

  // Shipping / Shipped To Information (Fictional shipping location)
  static const String shippingName = 'Global Horizon Trading Co. (Warehouse)';
  static const String shippingAddress =
      'Plot 88, Logistics Terminal, Sector 4, Cityville - 110045';
  static const String shippingPhone = '+1 555-0144';
  static const String shippingFullAddress =
      'Plot 88, Logistics Terminal, Sector 4, Cityville - 110045\nPhone: +1 555-0144';

  // Dates & Metadata
  static const String issueDate = '28 Sep 2026';
  static const String paymentDate = '28 Sep 2026';
  static const String dueDate = '13 Oct 2026';
  static const String validUntil = '13 Oct 2026';
  static const String poNumber = 'PO-98234';
  static const String placeOfSupply = 'Metro City';
  static const String countryOfSupply = 'India';

  static String getDocNumber(DocumentType type) => '# ${type.prefix}2026-0001';
  static String getDocNumberPlain(DocumentType type) =>
      '${type.prefix}2026-0001';

  // 2 Dummy Products
  static const DummyProductItem item1 = DummyProductItem(
    title: 'Premium Protective Helmet',
    description: 'Matte finish, ISI certified',
    hsn: '6506',
    qty: 1.0,
    rate: 1000.00,
    taxPercent: 12.0,
    discountPercent: 0.0,
  );

  static const DummyProductItem item2 = DummyProductItem(
    title: 'Riding Safety Gloves',
    description: 'All-weather grip, touchscreen compatible',
    hsn: '6216',
    itemCode: 'PRD-002',
    qty: 2.0,
    rate: 500.00,
    taxPercent: 12.0,
    discountPercent: 0.0,
  );

  static const List<DummyProductItem> items = [item1, item2];

  // Financial Totals
  static const double subtotal = 2000.00;
  static const double taxTotal = 240.00; // 12% on 2000
  static const double discount = 0.00;
  static const double grandTotal = 2240.00;

  static const String subtotalRs = 'Rs. 2,000.00';
  static const String subtotalInr = '₹2,000.00';
  static const String subtotalUsd = '\$2,000.00';

  static const String taxRs = 'Rs. 240.00';
  static const String taxInr = '₹240.00';
  static const String taxUsd = '\$240.00';

  static const String grandTotalRs = 'Rs. 2,240.00';
  static const String grandTotalInr = '₹2,240.00';
  static const String grandTotalUsd = '\$2,240.00';

  static const String totalInWords = 'Two Thousand Two Hundred Forty Only';
  static const String totalInWordsInr =
      'Two Thousand Two Hundred Forty Rupees Only';

  // Fictional Bank & Payment Details
  static const String bankName = 'National Commercial Bank';
  static const String accountNumber = '12345678901234';
  static const String ifscCode = 'NCBK0001234';
  static const String upiId = 'merchant@sampleupi';
  static const String accountHolder = 'Acme Innovations Pvt. Ltd.';

  // Notes & Terms
  static const String notes =
      'Thank you for your business! Payment is due as specified above.';
  static const String terms =
      '1. Payment is due within 15 days of invoice date.\n2. Overdue interest @ 1.5% monthly will be charged on delayed payments.';

  // Quotation Specific Texts (Top and Bottom of Table)
  static String get quotationIntroTitle => 'Dear $clientName,';
  static const String quotationIntroBody =
      'Please find below a cost-breakdown for the quotation. Please consider this, and do not hesitate to contact us with any questions.';
  static const String quotationIntroClosing = 'Many thanks,';
  static String get quotationIntroSender => companyName;

  static const String quotationClosingMessage =
      'Many thanks for your custom! We look forward to doing business with you.';
  static const String quotationTerms =
      'Quotation terms: Valid up to 15 days from issue date.';

  // Signatory & Signature
  static const String signatureAsset = 'assets/icons/signature.png';
  static const String signatoryName = 'Alex Morgan';
  static const String signatoryTitle = 'Authorized Signature';
}

Widget buildDummyText(
  String text, {
  double size = 10,
  bool bold = false,
  Color color = Colors.black87,
  TextAlign align = TextAlign.left,
}) {
  return Text(
    text,
    textAlign: align,
    style: TextStyle(
      fontSize: size,
      fontWeight: bold ? FontWeight.bold : FontWeight.normal,
      color: color,
      height: 1.2,
    ),
  );
}

/// Reusable Company Logo Widget (uses dummy company logo with circular radius of 8)
Widget buildDummyLogo({
  double size = 44,
  double radius = DummyTemplateData.logoRadius,
  BoxFit fit = BoxFit.contain,
}) {
  return ClipRRect(
    borderRadius: BorderRadius.circular(radius),
    child: Image.asset(
      DummyTemplateData.logoAsset,
      width: size,
      height: size,
      fit: fit,
      errorBuilder: (_, _, _) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: const Color(0xFF0F172A),
          borderRadius: BorderRadius.circular(radius),
        ),
        alignment: Alignment.center,
        child: Icon(
          Icons.business_rounded,
          size: size * 0.6,
          color: Colors.white,
        ),
      ),
    ),
  );
}

/// Reusable Signature Widget
Widget buildDummySignature({
  double width = 80,
  double height = 32,
  Color lineColor = const Color(0xFF94A3B8),
  Color labelColor = const Color(0xFF64748B),
  String label = DummyTemplateData.signatoryTitle,
  String? name = DummyTemplateData.signatoryName,
  bool showName = false,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.center,
    mainAxisSize: MainAxisSize.min,
    children: [
      Image.asset(
        DummyTemplateData.signatureAsset,
        width: width,
        height: height,
        fit: BoxFit.contain,
      ),
      Container(width: width + 30, height: 1.5, color: lineColor),
      const SizedBox(height: 4),
      if (showName && name != null) ...[
        buildDummyText(name, size: 9.5, bold: true, color: labelColor),
        const SizedBox(height: 1),
      ],
      buildDummyText(label, size: 9, bold: true, color: labelColor),
    ],
  );
}

// /// Standalone dummy QR code box
// Widget buildDummyQrCode({double size = 58, double iconSize = 46}) {
//   return Container(
//     width: size,
//     height: size,
//     decoration: BoxDecoration(
//       color: Colors.white,
//       borderRadius: BorderRadius.circular(4),
//       border: Border.all(color: Colors.grey.shade400, width: 0.8),
//     ),
//     alignment: Alignment.center,
//     child: Icon(Icons.qr_code_2, size: iconSize, color: Colors.black87),
//   );
// }

/// Reusable Payment Details with QR Code
Widget buildDummyPaymentDetails({
  Color primary = Colors.black87,
  DocumentType? type,
  bool isDark = false,
}) {
  if (type == DocumentType.receipt) return const SizedBox();
  return Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Column(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: Colors.grey.shade400, width: 1),
            ),
            alignment: Alignment.center,
            child: const Icon(Icons.qr_code_2, size: 48, color: Colors.black87),
          ),
          const SizedBox(height: 4),
          buildDummyText(
            'Scan to Pay',
            size: 8,
            bold: true,
            color: isDark ? Colors.grey.shade400 : Colors.grey.shade700,
          ),
        ],
      ),
      const SizedBox(width: 14),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildDummyText(
              'PAYMENT DETAILS',
              bold: true,
              size: 9.5,
              color: primary,
            ),
            const SizedBox(height: 4),
            buildDummyText(
              'UPI: ${DummyTemplateData.upiId}',
              bold: true,
              size: 9.5,
            ),
            const SizedBox(height: 2),
            buildDummyText(
              'Bank: ${DummyTemplateData.bankName}',
              bold: true,
              size: 9.5,
            ),
            buildDummyText(
              'A/C: ${DummyTemplateData.accountNumber}',
              size: 9.5,
            ),
            buildDummyText(
              'IFSC: ${DummyTemplateData.ifscCode}',
              size: 8.5,
              color: isDark ? Colors.grey.shade400 : Colors.grey.shade700,
            ),
          ],
        ),
      ),
    ],
  );
}
