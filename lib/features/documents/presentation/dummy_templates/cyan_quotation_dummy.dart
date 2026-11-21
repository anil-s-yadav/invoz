import 'package:flutter/material.dart';
import '../../domain/document_model.dart';
import 'dummy_template_utils.dart';

Widget buildCyanQuotationDummy(
  DocumentType documentType, [
  BuildContext? context,
]) {
  const cyanPrimary = Color(0xFF00A3E0);
  const cyanHeaderBg = Color(0xFFE6F6F9);
  const textDark = Color(0xFF1E293B);
  const textMuted = Color(0xFF64748B);
  const borderColor = Color(0xFF334155);

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
            // Business Logo + Company Name
            Row(
              children: [
                buildDummyLogo(size: 38, radius: 8),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      DummyTemplateData.companyName.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: textDark,
                        letterSpacing: 0.8,
                        height: 1.1,
                      ),
                    ),
                    Text(
                      DummyTemplateData.companyEmail,
                      style: const TextStyle(
                        fontSize: 9,
                        color: textMuted,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            // Document Title Right-Aligned
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
            // Quotation by (From)
            Expanded(
              flex: 5,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${documentType.displayName} by',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: textDark,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    DummyTemplateData.companyName,
                    style: const TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w600,
                      color: textDark,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    DummyTemplateData.companyAddress,
                    style: const TextStyle(
                      fontSize: 10,
                      color: textMuted,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'GSTIN: ${DummyTemplateData.companyGstin}',
                    style: const TextStyle(fontSize: 9, color: textMuted),
                  ),
                ],
              ),
            ),

            // Quotation to (Client)
            Expanded(
              flex: 5,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${documentType.displayName} to',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: textDark,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    DummyTemplateData.clientName,
                    style: const TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w600,
                      color: textDark,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    DummyTemplateData.clientAddress,
                    style: const TextStyle(
                      fontSize: 10,
                      color: textMuted,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'GSTIN: ${DummyTemplateData.clientGstin}',
                    style: const TextStyle(fontSize: 9, color: textMuted),
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
                  _buildMetaRow(
                    '${documentType.displayName} No:',
                    DummyTemplateData.getDocNumberPlain(documentType),
                  ),
                  const SizedBox(height: 3),
                  if (documentType == DocumentType.receipt)
                    _buildMetaRow(
                      'Payment Date:',
                      DummyTemplateData.paymentDate,
                    )
                  else ...[
                    _buildMetaRow(
                      '${documentType.displayName} Date:',
                      DummyTemplateData.issueDate,
                    ),
                    const SizedBox(height: 3),
                    _buildMetaRow(
                      documentType == DocumentType.proforma
                          ? 'Valid Until:'
                          : 'Due Date:',
                      documentType == DocumentType.proforma
                          ? DummyTemplateData.validUntil
                          : DummyTemplateData.dueDate,
                    ),
                  ],
                  const SizedBox(height: 6),
                  _buildMetaRow(
                    'Country of supply:',
                    DummyTemplateData.countryOfSupply,
                  ),
                  const SizedBox(height: 3),
                  _buildMetaRow(
                    'Place of supply:',
                    DummyTemplateData.placeOfSupply,
                  ),
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
                        'Tax',
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
                        'Amount',
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

              // 2 Dummy Product Rows
              _buildTableRow(
                title: DummyTemplateData.item1.title,
                description: DummyTemplateData.item1.description,
                qty: DummyTemplateData.item1.qtyString,
                rate: DummyTemplateData.item1.rateRs,
                tax: DummyTemplateData.item1.taxPercentString,
                amount: DummyTemplateData.item1.amountRs,
                hasBottomBorder: true,
              ),
              _buildTableRow(
                title: DummyTemplateData.item2.title,
                description: DummyTemplateData.item2.description,
                qty: DummyTemplateData.item2.qtyString,
                rate: DummyTemplateData.item2.rateRs,
                tax: DummyTemplateData.item2.taxPercentString,
                amount: DummyTemplateData.item2.amountRs,
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
            // Left: Terms & Conditions + Additional Notes + Payment Details
            Expanded(
              flex: 5,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Terms and Conditions',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: textDark,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    DummyTemplateData.terms,
                    style: const TextStyle(
                      fontSize: 8.5,
                      color: textDark,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Additional Notes',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: textDark,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    DummyTemplateData.notes,
                    style: const TextStyle(
                      fontSize: 8.5,
                      color: textDark,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 12),
                  buildDummyPaymentDetails(
                    type: documentType,
                    primary: cyanPrimary,
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
                                  DummyTemplateData.subtotalRs,
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

                        // Tax (12%)
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
                                  'Tax (12%)',
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
                                  DummyTemplateData.taxRs,
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
                                  DummyTemplateData.grandTotalRs,
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
                    DummyTemplateData.totalInWords,
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: textDark,
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Authorized Signature
                  buildDummySignature(
                    lineColor: borderColor,
                    labelColor: textDark,
                    showName: true,
                  ),
                ],
              ),
            ),
          ],
        ),

        const Spacer(),

        // Bottom Enquiry Box
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            border: Border.all(color: borderColor, width: 1),
          ),
          child: Center(
            child: RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: const TextStyle(fontSize: 9.5, color: textDark),
                children: [
                  const TextSpan(text: 'For any enquiries, email us on '),
                  TextSpan(
                    text: DummyTemplateData.companyEmail,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const TextSpan(text: ' or call us on '),
                  TextSpan(
                    text: DummyTemplateData.companyPhone,
                    style: const TextStyle(fontWeight: FontWeight.bold),
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
  required String tax,
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
            tax,
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
