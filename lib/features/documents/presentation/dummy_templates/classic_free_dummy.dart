import 'package:flutter/material.dart';
import '../../domain/document_model.dart';
import 'dummy_template_utils.dart';

Widget buildClassicFreeDummy(DocumentType documentType) {
  const primarySlate = Color(0xFF0F172A); // Slate 900
  const secondarySlate = Color(0xFF475569); // Slate 600
  const mutedSlate = Color(0xFF64748B); // Slate 500
  const borderColor = Color(0xFFE2E8F0); // Slate 200
  const bgLight = Color(0xFFF8FAFC); // Slate 50
  const badgeBg = Color(0xFFF1F5F9); // Slate 100

  return Container(
    color: Colors.white,
    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 32),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Top Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 1,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  buildDummyLogo(size: 44, radius: 8),
                  const SizedBox(height: 10),
                  buildDummyText(
                    DummyTemplateData.companyName,
                    size: 18,
                    bold: true,
                    color: primarySlate,
                  ),
                  const SizedBox(height: 4),
                  buildDummyText(
                    DummyTemplateData.companyFullAddress,
                    color: secondarySlate,
                    size: 9.5,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              flex: 1,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerRight,
                    child: Text(
                      documentType.displayName.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        color: primarySlate,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: badgeBg,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: borderColor),
                    ),
                    child: buildDummyText(
                      DummyTemplateData.getDocNumber(documentType),
                      bold: true,
                      size: 11,
                      color: primarySlate,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (documentType == DocumentType.receipt)
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerRight,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          buildDummyText(
                            'Payment Date: ',
                            size: 10,
                            color: mutedSlate,
                          ),
                          buildDummyText(
                            DummyTemplateData.paymentDate,
                            size: 10,
                            bold: true,
                            color: primarySlate,
                          ),
                        ],
                      ),
                    )
                  else ...[
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerRight,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          buildDummyText(
                            'Issue Date: ',
                            size: 10,
                            color: mutedSlate,
                          ),
                          buildDummyText(
                            DummyTemplateData.issueDate,
                            size: 10,
                            bold: true,
                            color: primarySlate,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 3),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerRight,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          buildDummyText(
                            documentType == DocumentType.proforma
                                ? 'Valid Until: '
                                : 'Due Date: ',
                            size: 10,
                            color: mutedSlate,
                          ),
                          buildDummyText(
                            documentType == DocumentType.proforma
                                ? DummyTemplateData.validUntil
                                : DummyTemplateData.dueDate,
                            size: 10,
                            bold: true,
                            color: primarySlate,
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),
        Container(height: 1, color: borderColor),
        const SizedBox(height: 16),

        // Bill To & Summary Card Row
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Billed To
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  buildDummyText(
                    'BILLED TO',
                    size: 9,
                    bold: true,
                    color: mutedSlate,
                  ),
                  const SizedBox(height: 4),
                  buildDummyText(
                    DummyTemplateData.clientName,
                    size: 12,
                    bold: true,
                    color: primarySlate,
                  ),
                  const SizedBox(height: 2),
                  buildDummyText(
                    DummyTemplateData.clientContactLine,
                    size: 9,
                    color: secondarySlate,
                  ),
                  buildDummyText(
                    DummyTemplateData.clientAddress,
                    size: 9,
                    color: secondarySlate,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            // Total Due Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: bgLight,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: borderColor),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  buildDummyText(
                    documentType == DocumentType.proforma
                        ? 'TOTAL AMOUNT'
                        : 'TOTAL DUE',
                    size: 8.5,
                    bold: true,
                    color: mutedSlate,
                  ),
                  const SizedBox(height: 2),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: buildDummyText(
                      DummyTemplateData.grandTotalRs,
                      size: 15,
                      bold: true,
                      color: primarySlate,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),

        const SizedBox(height: 18),

        // Table Header
        Container(
          padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 10),
          decoration: BoxDecoration(
            color: badgeBg,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: borderColor),
          ),
          child: Row(
            children: [
              Expanded(
                flex: 4,
                child: buildDummyText(
                  'DESCRIPTION',
                  bold: true,
                  size: 9,
                  color: secondarySlate,
                ),
              ),
              Expanded(
                flex: 1,
                child: Align(
                  alignment: Alignment.center,
                  child: buildDummyText(
                    'QTY',
                    bold: true,
                    size: 9,
                    color: secondarySlate,
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Align(
                  alignment: Alignment.centerRight,
                  child: buildDummyText(
                    'UNIT PRICE',
                    bold: true,
                    size: 9,
                    color: secondarySlate,
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: Align(
                  alignment: Alignment.centerRight,
                  child: buildDummyText(
                    'TAX',
                    bold: true,
                    size: 9,
                    color: secondarySlate,
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Align(
                  alignment: Alignment.centerRight,
                  child: buildDummyText(
                    'AMOUNT',
                    bold: true,
                    size: 9,
                    color: secondarySlate,
                  ),
                ),
              ),
            ],
          ),
        ),

        // 2 Dummy Products
        for (final item in DummyTemplateData.items)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: badgeBg)),
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 4,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      buildDummyText(
                        item.title,
                        bold: true,
                        size: 10.5,
                        color: primarySlate,
                      ),
                      const SizedBox(height: 2),
                      buildDummyText(
                        item.description,
                        size: 8.5,
                        color: const Color(0xFF94A3B8),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Align(
                    alignment: Alignment.center,
                    child: buildDummyText(
                      item.qtyString,
                      size: 10.5,
                      color: primarySlate,
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: buildDummyText(
                      item.rateRs,
                      size: 10.5,
                      color: primarySlate,
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: buildDummyText(
                      item.taxPercentString,
                      size: 10.5,
                      color: secondarySlate,
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: buildDummyText(
                      item.amountRs,
                      bold: true,
                      size: 10.5,
                      color: primarySlate,
                    ),
                  ),
                ),
              ],
            ),
          ),

        const SizedBox(height: 14),

        // Summary Card
        Align(
          alignment: Alignment.centerRight,
          child: Container(
            width: 240,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: bgLight,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: borderColor),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: buildDummyText(
                        'Subtotal',
                        size: 10,
                        color: secondarySlate,
                      ),
                    ),
                    Expanded(
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: buildDummyText(
                            DummyTemplateData.subtotalRs,
                            size: 10,
                            color: primarySlate,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Expanded(
                      child: buildDummyText(
                        'Tax (12%)',
                        size: 10,
                        color: secondarySlate,
                      ),
                    ),
                    Expanded(
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: buildDummyText(
                            DummyTemplateData.taxRs,
                            size: 10,
                            color: primarySlate,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Container(height: 1, color: borderColor),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Expanded(
                      child: buildDummyText(
                        'Total',
                        bold: true,
                        size: 12,
                        color: primarySlate,
                      ),
                    ),
                    Expanded(
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: buildDummyText(
                            DummyTemplateData.grandTotalRs,
                            bold: true,
                            size: 13,
                            color: primarySlate,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 12),

        // Notes & Terms Callout
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: const BoxDecoration(
            color: bgLight,
            borderRadius: BorderRadius.all(Radius.circular(6)),
            border: Border(left: BorderSide(color: mutedSlate, width: 3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              buildDummyText(
                'Notes & Terms',
                bold: true,
                size: 9,
                color: primarySlate,
              ),
              const SizedBox(height: 2),
              buildDummyText(
                DummyTemplateData.notes,
                size: 9,
                color: secondarySlate,
              ),
            ],
          ),
        ),

        const Spacer(),

        // Payment Details & Signature
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: buildDummyPaymentDetails(
                type: documentType,
                primary: primarySlate,
              ),
            ),
            buildDummySignature(
              lineColor: const Color(0xFF94A3B8),
              labelColor: mutedSlate,
              showName: true,
            ),
          ],
        ),
      ],
    ),
  );
}
