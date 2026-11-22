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
                        letterSpacing: 1.0,
                        height: 1.1,
                      ),
                    ),
                    Text(
                      DummyTemplateData.companyEmail,
                      style: const TextStyle(fontSize: 9, color: textMuted),
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
                    Text(
                      DummyTemplateData.getDocNumberPlain(documentType),
                      style: const TextStyle(
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
                      documentType == DocumentType.receipt
                          ? 'Payment Date'
                          : '${documentType.displayName} Date',
                      style: const TextStyle(fontSize: 11, color: textMuted),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      documentType == DocumentType.receipt
                          ? DummyTemplateData.paymentDate
                          : DummyTemplateData.issueDate,
                      style: const TextStyle(
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
                      'by',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: orange,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      DummyTemplateData.companyName,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: textDark,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      DummyTemplateData.companyAddress,
                      style: const TextStyle(
                        fontSize: 10,
                        color: Color(0xFF334155),
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Text(
                          'GSTIN  ',
                          style: TextStyle(
                            fontSize: 9.5,
                            fontWeight: FontWeight.bold,
                            color: textDark,
                          ),
                        ),
                        Text(
                          DummyTemplateData.companyGstin,
                          style: const TextStyle(
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
                      'to',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: orange,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      DummyTemplateData.clientName,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: textDark,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      DummyTemplateData.clientAddress,
                      style: const TextStyle(
                        fontSize: 10,
                        color: Color(0xFF334155),
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Text(
                          'GSTIN  ',
                          style: TextStyle(
                            fontSize: 9.5,
                            fontWeight: FontWeight.bold,
                            color: textDark,
                          ),
                        ),
                        Text(
                          DummyTemplateData.clientGstin,
                          style: const TextStyle(
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

        const SizedBox(height: 10),

        // Quotation Intro Message (Top of Table)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                DummyTemplateData.quotationIntroTitle,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: textDark,
                ),
              ),
              const SizedBox(height: 2),
              const Text(
                DummyTemplateData.quotationIntroBody,
                style: TextStyle(fontSize: 9, color: textDark, height: 1.25),
              ),
              const SizedBox(height: 2),
              const Text(
                DummyTemplateData.quotationIntroClosing,
                style: TextStyle(fontSize: 9, color: textDark),
              ),
              Text(
                DummyTemplateData.quotationIntroSender,
                style: const TextStyle(
                  fontSize: 9.5,
                  fontWeight: FontWeight.bold,
                  color: textDark,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),

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

        // 2 Alternating Table Rows
        _buildTableRow(
          '1. ${DummyTemplateData.item1.title}',
          DummyTemplateData.item1.qtyString,
          DummyTemplateData.item1.rateRs,
          DummyTemplateData.item1.amountRs,
          Colors.white,
          textDark,
        ),
        _buildTableRow(
          '2. ${DummyTemplateData.item2.title}',
          DummyTemplateData.item2.qtyString,
          DummyTemplateData.item2.rateRs,
          DummyTemplateData.item2.amountRs,
          cream,
          textDark,
        ),
        const SizedBox(height: 18),

        // Middle section: Terms on Left, Totals on Right
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left Column: Quotation Closing & Terms
            Expanded(
              flex: 5,
              child: Text(
                "",
                style: TextStyle(fontSize: 9.5, color: textDark, height: 1.35),
              ),
            ),
            const SizedBox(width: 24),

            // Right Column: Summary
            Expanded(
              flex: 4,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Sub Total
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Sub Total',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: textDark,
                        ),
                      ),
                      Text(
                        DummyTemplateData.subtotalRs,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: textDark,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),

                  // Tax (12%)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Tax (12%)',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: orange,
                        ),
                      ),
                      Text(
                        DummyTemplateData.taxRs,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: orange,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Total
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text(
                        'Total',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: textDark,
                        ),
                      ),
                      Text(
                        DummyTemplateData.grandTotalRs,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: textDark,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Total in words
                  // const Text(
                  //   'Invoice Total (in words)',
                  //   style: TextStyle(fontSize: 8.5, color: textMuted),
                  // ),
                  // const SizedBox(height: 2),
                  Text(
                    DummyTemplateData.totalInWordsInr,
                    style: const TextStyle(
                      fontSize: 9.5,
                      fontWeight: FontWeight.w600,
                      color: textDark,
                    ),
                  ),
                  // const SizedBox(height: 8),
                  Container(height: 0.8, color: const Color(0xFFE2E8F0)),
                ],
              ),
            ),
          ],
        ),

        const Spacer(),

        // Bottom Row: Payment Details on Left, Signature on Right
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              flex: 5,
              child: buildDummyPaymentDetails(
                type: documentType,
                primary: orange,
              ),
            ),
            const SizedBox(width: 24),
            Expanded(
              flex: 4,
              child: buildDummySignature(
                lineColor: const Color(0xFFCBD5E1),
                labelColor: textMuted,
                showName: true,
              ),
            ),
          ],
        ),

        const SizedBox(height: 14),

        // Bottom enquiry banner
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: cream,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Center(
            child: Text(
              DummyTemplateData.quotationTerms,
              style: TextStyle(
                fontSize: 9.5,
                fontWeight: FontWeight.bold,
                color: textDark,
                height: 1.35,
              ),
            ),
          ),
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
