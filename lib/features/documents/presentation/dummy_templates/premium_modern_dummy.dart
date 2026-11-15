import 'package:flutter/material.dart';
import '../../domain/document_model.dart';
import 'dummy_template_utils.dart';

Widget buildPremiumModernDummy(DocumentType documentType) {
  final primary = const Color(0xFF2563EB); // Modern Pro Blue
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
                      '# ${documentType.prefix}2026-0001',
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
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerRight,
                      child: buildDummyText(
                        'Issue Date: 28 Sep 2026',
                        color: Colors.white70,
                      ),
                    ),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerRight,
                      child: buildDummyText(
                        documentType == DocumentType.proforma
                            ? 'Valid Until: 13 Oct 2026'
                            : 'Due Date: 13 Oct 2026',
                        color: Colors.white70,
                      ),
                    ),
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
                    Expanded(
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
                          Image.asset(
                            'assets/icons/applogo.png',
                            width: 32,
                            height: 32,
                          ),
                          const SizedBox(height: 4),
                          buildDummyText('Tesla Inc.', size: 12, bold: true),
                          buildDummyText(
                            'teslacom@gmail.com\n9876543210\nRoad no. 397, near weastern railways city, Ghatkopar USA\n- 1087221.',
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          buildDummyText(
                            'BILL TO:',
                            size: 10,
                            bold: true,
                            color: primary,
                          ),
                          const SizedBox(height: 4),
                          buildDummyText(
                            'Georgo graph LTD',
                            size: 12,
                            bold: true,
                          ),
                          buildDummyText(
                            'vajsisi@shjs.com\n9876543210\nHE wants personal loan for your help and more than\n400070',
                            align: TextAlign.right,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                // Table Header
                Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 6,
                    horizontal: 8,
                  ),
                  decoration: BoxDecoration(color: primary),
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
                // Table Row
                Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 6,
                    horizontal: 8,
                  ),
                  child: Row(
                    children: [
                      Expanded(flex: 3, child: buildDummyText('Helmate')),
                      Expanded(flex: 1, child: buildDummyText('1.0')),
                      Expanded(
                        flex: 2,
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: buildDummyText('Rs. 1,000.00'),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: buildDummyText('12.0%'),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: buildDummyText('Rs. 1,120.00'),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
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
                                  child: buildDummyText('Rs. 1,000.00'),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Expanded(child: buildDummyText('Tax')),
                            Expanded(
                              child: Align(
                                alignment: Alignment.centerRight,
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: buildDummyText('Rs. 120.00'),
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
                                    'Rs. 1,120.00',
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
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    border: Border(left: BorderSide(color: primary, width: 3)),
                  ),
                  child: buildDummyText('Thank you for your business!'),
                ),
                const Spacer(),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: buildDummyPaymentDetails(
                        type: documentType,
                        primary: primary,
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Image.asset(
                          'assets/icons/signature.png',
                          width: 80,
                          height: 30,
                        ),
                        Container(
                          width: 100,
                          height: 1.5,
                          color: Colors.black87,
                        ),
                        const SizedBox(height: 4),
                        buildDummyText(
                          'Authorized Signature',
                          color: Colors.grey.shade600,
                        ),
                      ],
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
