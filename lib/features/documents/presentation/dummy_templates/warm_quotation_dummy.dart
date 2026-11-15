import 'package:flutter/material.dart';
import '../../domain/document_model.dart';
import 'dummy_template_utils.dart';

Widget buildWarmQuotationDummy(
  DocumentType documentType, [
  BuildContext? context,
]) {
  const orange = Color(0xFFF26522);
  const cream = Color(0xFFFFF4EC);
  const textDark = Color(0xFF1E293B);
  const textMuted = Color(0xFF64748B);
  const green = Color(0xFF16A34A);

  return Container(
    color: Colors.white,
    padding: const EdgeInsets.fromLTRB(36, 32, 36, 32),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Top Title
        Text(
          documentType.displayName,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: orange,
            letterSpacing: -0.2,
          ),
        ),
        const SizedBox(height: 16),

        // Header Row: Business Logo/Name on Left, Quotation# & Date on Right
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Business Logo + Name
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Center(
                    child: Text(
                      'F',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
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
                        letterSpacing: 1.0,
                        height: 1.0,
                      ),
                    ),
                    Text(
                      'LABS',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: textDark,
                        letterSpacing: 1.0,
                        height: 1.0,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            // Number & Date
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${documentType.displayName}#',
                      style: const TextStyle(fontSize: 11, color: textMuted),
                    ),
                    const SizedBox(width: 16),
                    const Text(
                      '004',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: textDark,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${documentType.displayName} Date',
                      style: const TextStyle(fontSize: 11, color: textMuted),
                    ),
                    const SizedBox(width: 16),
                    const Text(
                      'JUN 19, 2026',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: textDark,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Two Info Cards: Quotation by & Quotation to
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left Card: Quotation by
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: cream,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${documentType.displayName} by',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: orange,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Foobar Labs',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: textDark,
                      ),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      '56-87, HSR Layout - Bengaluru, Karnataka,\nIndia - 560055',
                      style: TextStyle(
                        fontSize: 10,
                        color: Color(0xFF334155),
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: const [
                        Text(
                          'GSTIN  ',
                          style: TextStyle(
                            fontSize: 9.5,
                            fontWeight: FontWeight.bold,
                            color: textDark,
                          ),
                        ),
                        Text(
                          '29ABCED1234F2Z5',
                          style: TextStyle(
                            fontSize: 9.5,
                            color: Color(0xFF334155),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: const [
                        Text(
                          'PAN    ',
                          style: TextStyle(
                            fontSize: 9.5,
                            fontWeight: FontWeight.bold,
                            color: textDark,
                          ),
                        ),
                        Text(
                          'ABCED1234F',
                          style: TextStyle(
                            fontSize: 9.5,
                            color: Color(0xFF334155),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 14),

            // Right Card: Quotation to
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: cream,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${documentType.displayName} to',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: orange,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Studio Den',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: textDark,
                      ),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      '305, 3rd Floor Orion mall, Bengaluru,\nKarnataka, India - 560055',
                      style: TextStyle(
                        fontSize: 10,
                        color: Color(0xFF334155),
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: const [
                        Text(
                          'GSTIN  ',
                          style: TextStyle(
                            fontSize: 9.5,
                            fontWeight: FontWeight.bold,
                            color: textDark,
                          ),
                        ),
                        Text(
                          '29VGCED1234K2Z6',
                          style: TextStyle(
                            fontSize: 9.5,
                            color: Color(0xFF334155),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: const [
                        Text(
                          'PAN    ',
                          style: TextStyle(
                            fontSize: 9.5,
                            fontWeight: FontWeight.bold,
                            color: textDark,
                          ),
                        ),
                        Text(
                          'VGCED1234K',
                          style: TextStyle(
                            fontSize: 9.5,
                            color: Color(0xFF334155),
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
        const SizedBox(height: 10),

        // Supply details row
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: const [
                  Text(
                    'Place of Supply    ',
                    style: TextStyle(fontSize: 10.5, color: textMuted),
                  ),
                  Text(
                    'Karnataka',
                    style: TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.bold,
                      color: textDark,
                    ),
                  ),
                ],
              ),
              Row(
                children: const [
                  Text(
                    'Country of Supply    ',
                    style: TextStyle(fontSize: 10.5, color: textMuted),
                  ),
                  Text(
                    'India',
                    style: TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.bold,
                      color: textDark,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Table Header
        Container(
          decoration: const BoxDecoration(
            color: orange,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(4),
              topRight: Radius.circular(4),
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: const [
              Expanded(
                flex: 5,
                child: Text(
                  'Item #/Item description',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: Text(
                  'Qty.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  'Rate',
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  'Amount',
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),

        // Alternating Table Rows
        _buildTableRow(
          '1. Basic Web Development',
          '1',
          'Rs. 10,000',
          'Rs. 10,000.00',
          Colors.white,
          textDark,
        ),
        _buildTableRow(
          '2. Logo Design',
          '1',
          'Rs. 1,000',
          'Rs. 1,000.00',
          cream,
          textDark,
        ),
        _buildTableRow(
          '3. Web Design',
          '1',
          'Rs. 50,000',
          'Rs. 50,000.00',
          Colors.white,
          textDark,
        ),
        _buildTableRow(
          '4. Full Stack Web development',
          '1',
          'Rs. 40,000',
          'Rs. 40,000.00',
          cream,
          textDark,
        ),
        const SizedBox(height: 18),

        // Bottom section: Terms & Notes on Left, Totals & Signature on Right
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left Column
            Expanded(
              flex: 5,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Terms and Conditions',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: orange,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    '1. Please pay within 15 days from the date of invoice, overdue interest @ 14% will be charged on delayed payments.\n2. Please quote invoice number when remitting funds.',
                    style: TextStyle(
                      fontSize: 9.5,
                      color: Color(0xFF475569),
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'Additional Notes',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: orange,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'It is a long established fact that a reader will be distracted by the readable content of a page when looking at its layout. The point of using Lorem Ipsum is that it has a more-or-less normal distribution of letters, as opposed to using \'Content here, content here.',
                    style: TextStyle(
                      fontSize: 9.5,
                      color: Color(0xFF475569),
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 16),
                  RichText(
                    text: const TextSpan(
                      style: TextStyle(fontSize: 10, color: textDark),
                      children: [
                        TextSpan(text: 'For any enquiries, email us on '),
                        TextSpan(
                          text: 'info@foobarlabs.com',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        TextSpan(text: ' or\ncall us on '),
                        TextSpan(
                          text: '+91 98765-43210',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 24),

            // Right Column: Summary & Signature
            Expanded(
              flex: 4,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Sub Total
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text(
                        'Sub Total',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: textDark,
                        ),
                      ),
                      Text(
                        'Rs. 101,000',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: textDark,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),

                  // Discount
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text(
                        'Discount(5%)',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: green,
                        ),
                      ),
                      Text(
                        '- Rs. 5,050',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: green,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Total
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: const [
                      Text(
                        'Total',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: textDark,
                        ),
                      ),
                      Text(
                        'Rs. 95,950',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: textDark,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Total in words
                  const Text(
                    'Invoice Total (in words)',
                    style: TextStyle(fontSize: 8.5, color: textMuted),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    'Ninety Thousand Nine Hundred Fifty Rupees Only',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: textDark,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(height: 0.8, color: const Color(0xFFE2E8F0)),

                  const SizedBox(height: 20),

                  // Authorized Signature
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Image.asset(
                        'assets/icons/signature.png',
                        height: 36,
                        fit: BoxFit.contain,
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'Authorized Signature',
                        style: TextStyle(fontSize: 9, color: textMuted),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

Widget _buildTableRow(
  String description,
  String qty,
  String rate,
  String amount,
  Color bgColor,
  Color textColor,
) {
  return Container(
    color: bgColor,
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
    child: Row(
      children: [
        Expanded(
          flex: 5,
          child: Text(
            description,
            style: TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w500,
              color: textColor,
            ),
          ),
        ),
        Expanded(
          flex: 1,
          child: Text(
            qty,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 10.5, color: textColor),
          ),
        ),
        Expanded(
          flex: 2,
          child: Text(
            rate,
            textAlign: TextAlign.right,
            style: TextStyle(fontSize: 10.5, color: textColor),
          ),
        ),
        Expanded(
          flex: 2,
          child: Text(
            amount,
            textAlign: TextAlign.right,
            style: TextStyle(fontSize: 10.5, color: textColor),
          ),
        ),
      ],
    ),
  );
}
