import 'package:flutter/material.dart';
import '../../domain/document_model.dart';
import 'dummy_template_utils.dart';

Widget buildPremiumModernDummy(DocumentType documentType) {
  const primary = Color(0xFF2563EB); // Modern Pro Blue
  return Container(
    color: Colors.white,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Container(
          color: primary,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: buildDummyText(
                        documentType.displayName.toUpperCase(),
                        size: 24,
                        bold: true,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    buildDummyText(
                      DummyTemplateData.getDocNumber(documentType),
                      color: Colors.white,
                      size: 11,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    if (documentType == DocumentType.receipt)
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerRight,
                        child: buildDummyText(
                          'Payment Date: ${DummyTemplateData.paymentDate}',
                          color: Colors.white70,
                        ),
                      )
                    else ...[
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerRight,
                        child: buildDummyText(
                          'Issue Date: ${DummyTemplateData.issueDate}',
                          color: Colors.white70,
                        ),
                      ),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerRight,
                        child: buildDummyText(
                          documentType == DocumentType.proforma
                              ? 'Valid Until: ${DummyTemplateData.validUntil}'
                              : 'Due Date: ${DummyTemplateData.dueDate}',
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // From
                    Expanded(
                      flex: 5,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          buildDummyText(
                            'FROM:',
                            size: 10,
                            bold: true,
                            color: primary,
                          ),
                          const SizedBox(height: 4),
                          buildDummyLogo(size: 36, radius: 8),
                          const SizedBox(height: 4),
                          buildDummyText(
                            DummyTemplateData.companyName,
                            size: 12,
                            bold: true,
                          ),
                          buildDummyText(DummyTemplateData.companyFullAddress),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Bill To
                    Expanded(
                      flex: 5,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          buildDummyText(
                            'BILL TO:',
                            size: 10,
                            bold: true,
                            color: primary,
                          ),
                          const SizedBox(height: 4),
                          buildDummyText(
                            DummyTemplateData.clientName,
                            size: 12,
                            bold: true,
                          ),
                          buildDummyText(DummyTemplateData.clientFullAddress),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                // Table Header
                Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 6,
                    horizontal: 8,
                  ),
                  decoration: const BoxDecoration(color: primary),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: buildDummyText(
                          'Item',
                          bold: true,
                          color: Colors.white,
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: buildDummyText(
                          'Qty',
                          bold: true,
                          color: Colors.white,
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: buildDummyText(
                            'Price',
                            bold: true,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: buildDummyText(
                            'Tax',
                            bold: true,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: buildDummyText(
                            'Total',
                            bold: true,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // 2 Dummy Product Rows
                for (final item in DummyTemplateData.items)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 6,
                      horizontal: 8,
                    ),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: Colors.grey.shade200),
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              buildDummyText(item.title, bold: true),
                              buildDummyText(
                                item.description,
                                size: 8.5,
                                color: Colors.grey.shade500,
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: buildDummyText(item.qtyString),
                        ),
                        Expanded(
                          flex: 2,
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: buildDummyText(item.rateRs),
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: buildDummyText(item.taxPercentString),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: buildDummyText(item.amountRs, bold: true),
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 14),
                // Summary Box
                Align(
                  alignment: Alignment.centerRight,
                  child: Container(
                    width: 240,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(child: buildDummyText('Subtotal')),
                            Expanded(
                              child: Align(
                                alignment: Alignment.centerRight,
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: buildDummyText(
                                    DummyTemplateData.subtotalRs,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Expanded(child: buildDummyText('Tax (12%)')),
                            Expanded(
                              child: Align(
                                alignment: Alignment.centerRight,
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: buildDummyText(
                                    DummyTemplateData.taxRs,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: buildDummyText(
                                'Total',
                                bold: true,
                                size: 14,
                                color: primary,
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
                                    size: 14,
                                    color: primary,
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
                const SizedBox(height: 14),
                // Notes Callout
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    border: Border(left: BorderSide(color: primary, width: 3)),
                  ),
                  child: buildDummyText(DummyTemplateData.notes),
                ),
                const Spacer(),
                // Payment Details & Signature
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: buildDummyPaymentDetails(
                        type: documentType,
                        primary: primary,
                      ),
                    ),
                    buildDummySignature(
                      lineColor: Colors.black87,
                      labelColor: Colors.grey.shade600,
                      showName: true,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}
