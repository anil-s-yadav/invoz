import 'package:flutter/material.dart';
import '../../domain/document_model.dart';

Widget buildCyanQuotationDummy(
  DocumentType documentType, [
  BuildContext? context,
]) {
  const cyanPrimary = Color(0xFF00A3E0);
  const cyanHeaderBg = Color(0xFFE6F6F9);
  const textDark = Color(0xFF1E293B);
  const textMuted = Color(0xFF64748B);
  const borderColor = Color(0xFF334155);
  const lightBorder = Color(0xFFCBD5E1);

  return Container(
    color: Colors.white,
    padding: const EdgeInsets.fromLTRB(36, 32, 36, 32),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Top Header: Logo + Brand on Left, "Quotation" on Right
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Business Logo + Foobar Labs
            Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: cyanPrimary,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Center(
                    child: Text(
                      'F',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Text(
                      'FOOBAR',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: textDark,
                        letterSpacing: 0.8,
                        height: 1.0,
                      ),
                    ),
                    Text(
                      'LABS',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: textDark,
                        letterSpacing: 0.8,
                        height: 1.0,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            // "Quotation" Title Right-Aligned
            Text(
              documentType.displayName,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w400,
                color: textDark,
                letterSpacing: -0.5,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        // Party Info + Metadata Row
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Quotation by
            Expanded(
              flex: 5,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Quotation by',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: textDark,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    'Foobar Labs',
                    style: TextStyle(fontSize: 10.5, color: textDark),
                  ),
                  SizedBox(height: 3),
                  Text(
                    '56-87, HSR Layout - Bengaluru,\nKarnataka, India - 560055',
                    style: TextStyle(fontSize: 10, color: textMuted, height: 1.3),
                  ),
                ],
              ),
            ),

            // Quotation to
            Expanded(
              flex: 5,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Quotation to',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: textDark,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    'Studio Den',
                    style: TextStyle(fontSize: 10.5, color: textDark),
                  ),
                  SizedBox(height: 3),
                  Text(
                    '305, 3rd Floor Orion mall, Bengaluru,\nKarnataka, India - 560055',
                    style: TextStyle(fontSize: 10, color: textMuted, height: 1.3),
                  ),
                ],
              ),
            ),

            // Invoice No / Dates / Supply
            Expanded(
              flex: 5,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _buildMetaRow('Invoice No:', '003'),
                  const SizedBox(height: 3),
                  _buildMetaRow('Invoice Date:', 'FEB 19, 2020'),
                  const SizedBox(height: 3),
                  _buildMetaRow('Due Date:', 'FEB 19, 2020'),
                  const SizedBox(height: 8),
                  _buildMetaRow('Country of supply:', 'India'),
                  const SizedBox(height: 3),
                  _buildMetaRow('Place of supply:', 'Karnataka'),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),

        // Bordered Items Table
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: borderColor, width: 1),
          ),
          child: Column(
            children: [
              // Header Row
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
                decoration: const BoxDecoration(
                  color: cyanHeaderBg,
                  border: Border(
                    bottom: BorderSide(color: borderColor, width: 1),
                  ),
                ),
                child: Row(
                  children: const [
                    Expanded(
                      flex: 4,
                      child: Text(
                        'Item #/Item description',
                        style: TextStyle(
                          fontSize: 9.5,
                          fontWeight: FontWeight.bold,
                          color: textDark,
                        ),
                      ),
                    ),
                    _TableBorderDivider(),
                    SizedBox(
                      width: 50,
                      child: Text(
                        'Quantity',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 9.5,
                          fontWeight: FontWeight.bold,
                          color: textDark,
                        ),
                      ),
                    ),
                    _TableBorderDivider(),
                    SizedBox(
                      width: 60,
                      child: Text(
                        'Rate',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 9.5,
                          fontWeight: FontWeight.bold,
                          color: textDark,
                        ),
                      ),
                    ),
                    _TableBorderDivider(),
                    SizedBox(
                      width: 55,
                      child: Text(
                        'Discount',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 9.5,
                          fontWeight: FontWeight.bold,
                          color: textDark,
                        ),
                      ),
                    ),
                    _TableBorderDivider(),
                    SizedBox(
                      width: 75,
                      child: Text(
                        'Amount\n(After Discount)',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 8.5,
                          fontWeight: FontWeight.bold,
                          color: textDark,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Item Row 1
              _buildTableRow(
                title: 'Basic Web Development',
                qty: '10',
                rate: '\u20B9 10,000',
                discount: '5%',
                amount: '\u20B9 9,500',
                hasBottomBorder: true,
              ),

              // Item Row 2
              _buildTableRow(
                title: 'Basic Web Development',
                description:
                    'Create and send unlimited professional invoices for free. Use our unique features to collect payments faster.',
                qty: '10',
                rate: '\u20B9 10,000',
                discount: '5%',
                amount: '\u20B9 9,500',
                hasBottomBorder: false,
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),

        // Bottom Section: Left Notes/Terms/Attachments + Right Summary Box
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left: Terms & Conditions + Additional Notes + Attachments
            Expanded(
              flex: 5,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Terms and Conditions',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: textDark,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    '1. Please pay within 15 days from the date of invoice, overdue interest @ 14% will be charged on delayed payments.\n2. Please quote invoice number when remitting funds.',
                    style: TextStyle(fontSize: 8.5, color: textDark, height: 1.3),
                  ),
                  SizedBox(height: 12),
                  Text(
                    'Additional Notes',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: textDark,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'It is a long established fact that a reader will be distracted by the readable content of a page when looking at its layout. The point of using Lorem Ipsum is that it has a more-or-less normal distribution of letters, as opposed to using \'Content here, content here.',
                    style: TextStyle(fontSize: 8.5, color: textDark, height: 1.3),
                  ),
                  SizedBox(height: 12),
                  Text(
                    'Attachments',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: textDark,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    '1. finename.png\n2. invoice%402x.png\n3. verified-bank%402x.png',
                    style: TextStyle(
                      fontSize: 8.5,
                      color: Color(0xFF1E293B),
                      decoration: TextDecoration.underline,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 20),

            // Right: Totals Box + In Words + Signature
            Expanded(
              flex: 4,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Totals Box with Borders
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: borderColor, width: 1),
                    ),
                    child: Column(
                      children: [
                        // Sub Total
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: const BoxDecoration(
                            border: Border(
                              bottom: BorderSide(color: borderColor, width: 1),
                            ),
                          ),
                          child: Row(
                            children: const [
                              Expanded(
                                child: Text(
                                  'Sub Total',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: textDark,
                                  ),
                                ),
                              ),
                              _VerticalDivider(),
                              Expanded(
                                child: Text(
                                  '\u20B920,000',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: textDark,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Discount(5%)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: const BoxDecoration(
                            border: Border(
                              bottom: BorderSide(color: borderColor, width: 1),
                            ),
                          ),
                          child: Row(
                            children: const [
                              Expanded(
                                child: Text(
                                  'Discount(5%)',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: textDark,
                                  ),
                                ),
                              ),
                              _VerticalDivider(),
                              Expanded(
                                child: Text(
                                  '\u20B91,000',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: textDark,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Total Amount Row (Cyan Background, White Text)
                        Container(
                          color: cyanPrimary,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          child: Row(
                            children: const [
                              Expanded(
                                child: Text(
                                  'Total Amount',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              _VerticalDivider(color: Colors.white),
                              Expanded(
                                child: Text(
                                  '\u20B919,000',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Invoice Total In Words
                  const Text(
                    'Invoice Total In Words:',
                    style: TextStyle(fontSize: 8.5, color: textMuted),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    'Nineteen Thousand Rupees Only',
                    style: TextStyle(
                      fontSize: 9.5,
                      fontWeight: FontWeight.bold,
                      color: textDark,
                    ),
                  ),
                  const SizedBox(height: 18),

                  // Authorized Signature
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Center(
                        child: Column(
                          children: [
                            Text(
                              'Sandy',
                              style: TextStyle(
                                fontFamily: 'cursive',
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF1E3A8A),
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                            const SizedBox(height: 2),
                            const Text(
                              'Authorized Signature',
                              style: TextStyle(fontSize: 9, color: textDark),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),

        const Spacer(),

        // Bottom Enquiry Box
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            border: Border.all(color: borderColor, width: 1),
          ),
          child: Center(
            child: RichText(
              textAlign: TextAlign.center,
              text: const TextSpan(
                style: TextStyle(fontSize: 9.5, color: textDark),
                children: [
                  TextSpan(text: 'For any enquiries, email us on '),
                  TextSpan(
                    text: 'info@foobarlabs.com',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(text: ' or call us on '),
                  TextSpan(
                    text: '+91 98765-43210',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    ),
  );
}

Widget _buildMetaRow(String label, String value) {
  return Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Text(
        '$label ',
        style: const TextStyle(
          fontSize: 9.5,
          fontWeight: FontWeight.w600,
          color: Color(0xFF1E293B),
        ),
      ),
      Text(
        value,
        style: const TextStyle(
          fontSize: 9.5,
          color: Color(0xFF1E293B),
        ),
      ),
    ],
  );
}

Widget _buildTableRow({
  required String title,
  String? description,
  required String qty,
  required String rate,
  required String discount,
  required String amount,
  required bool hasBottomBorder,
}) {
  const borderColor = Color(0xFF334155);
  const textDark = Color(0xFF1E293B);
  const textMuted = Color(0xFF64748B);

  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
    decoration: BoxDecoration(
      border: hasBottomBorder
          ? const Border(bottom: BorderSide(color: borderColor, width: 1))
          : null,
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 4,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 9.5,
                  fontWeight: FontWeight.bold,
                  color: textDark,
                ),
              ),
              if (description != null) ...[
                const SizedBox(height: 2),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 8,
                    color: textMuted,
                    height: 1.25,
                  ),
                ),
              ],
            ],
          ),
        ),
        const _TableBorderDivider(),
        SizedBox(
          width: 50,
          child: Text(
            qty,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 9.5, color: textDark),
          ),
        ),
        const _TableBorderDivider(),
        SizedBox(
          width: 60,
          child: Text(
            rate,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 9.5, color: textDark),
          ),
        ),
        const _TableBorderDivider(),
        SizedBox(
          width: 55,
          child: Text(
            discount,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 9.5, color: textDark),
          ),
        ),
        const _TableBorderDivider(),
        SizedBox(
          width: 75,
          child: Text(
            amount,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 9.5,
              fontWeight: FontWeight.bold,
              color: textDark,
            ),
          ),
        ),
      ],
    ),
  );
}

class _TableBorderDivider extends StatelessWidget {
  const _TableBorderDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 20,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      color: const Color(0xFF334155),
    );
  }
}

class _VerticalDivider extends StatelessWidget {
  final Color color;
  const _VerticalDivider({this.color = const Color(0xFF334155)});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 14,
      color: color,
    );
  }
}
