import 'package:flutter/material.dart';
import '../../domain/document_model.dart';
import 'dummy_template_utils.dart';

Widget buildFormalQuotationDummy(
  DocumentType documentType, [
  BuildContext? context,
]) {
  const borderColor = Color(0xFF64748B);
  const textDark = Color(0xFF0F172A);
  const textMuted = Color(0xFF475569);
  const tableHeaderBg = Color(0xFFF1F5F9);
  const cyanPrimary = Color(0xFF00A3E0);

  return Container(
    color: Colors.white,
    padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 30),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Top Header Row: Logo on Left, Quotation & Company on Right
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Left: Dummy Company Logo (radius 8)
            buildDummyLogo(size: 58, radius: 8),

            const SizedBox(width: 16),

            // Right: Quotation & Company Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text(
                    'Quotation',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: textDark,
                      letterSpacing: 0.2,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    DummyTemplateData.companyName,
                    textAlign: TextAlign.right,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: textDark,
                    ),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    'GSTIN: ${DummyTemplateData.companyGstin}',
                    textAlign: TextAlign.right,
                    style: const TextStyle(fontSize: 9, color: textMuted),
                  ),
                  Text(
                    DummyTemplateData.companyAddress,
                    textAlign: TextAlign.right,
                    style: const TextStyle(fontSize: 8.5, color: textMuted),
                  ),
                  Text(
                    'Mobile: ${DummyTemplateData.companyPhone}',
                    textAlign: TextAlign.right,
                    style: const TextStyle(fontSize: 8.5, color: textMuted),
                  ),
                  Text(
                    'Email Id: ${DummyTemplateData.companyEmail}',
                    textAlign: TextAlign.right,
                    style: const TextStyle(fontSize: 8.5, color: textMuted),
                  ),
                ],
              ),
            ),
          ],
        ),

        const SizedBox(height: 10),
        Container(height: 0.8, color: borderColor),
        const SizedBox(height: 10),

        // Parties & Metadata Row: 'To' on Left, 'Date / No / Grand Total' on Right
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Left: To Client
            Expanded(
              flex: 5,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'To',
                    style: TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.bold,
                      color: textDark,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    DummyTemplateData.clientName,
                    style: const TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.bold,
                      color: textDark,
                    ),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    'GSTIN: ${DummyTemplateData.clientGstin}',
                    style: const TextStyle(fontSize: 8.5, color: textMuted),
                  ),
                  Text(
                    'Mobile: ${DummyTemplateData.clientPhone}',
                    style: const TextStyle(fontSize: 8.5, color: textMuted),
                  ),
                  Text(
                    'Email Id: ${DummyTemplateData.clientEmail}',
                    style: const TextStyle(fontSize: 8.5, color: textMuted),
                  ),
                  Text(
                    DummyTemplateData.clientAddress,
                    style: const TextStyle(fontSize: 8.5, color: textMuted),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 16),

            // Right: Date, Quotation No, Grand Total
            Expanded(
              flex: 5,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      const Text(
                        'Date : ',
                        style: TextStyle(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w600,
                          color: textDark,
                        ),
                      ),
                      Text(
                        DummyTemplateData.issueDate,
                        style: const TextStyle(fontSize: 9.5, color: textDark),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      const Text(
                        'Quotation No. : ',
                        style: TextStyle(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w600,
                          color: textDark,
                        ),
                      ),
                      Text(
                        DummyTemplateData.getDocNumberPlain(
                          DocumentType.quotation,
                        ),
                        style: const TextStyle(fontSize: 9.5, color: textDark),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      const Text(
                        'Grand Total : ',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: textDark,
                        ),
                      ),
                      Text(
                        DummyTemplateData.grandTotalInr,
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: textDark,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),

        const SizedBox(height: 10),
        Container(height: 0.8, color: borderColor),
        const SizedBox(height: 8),

        // Quotation Intro Greeting Message
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              DummyTemplateData.quotationIntroTitle,
              style: const TextStyle(
                fontSize: 9.5,
                fontWeight: FontWeight.bold,
                color: textDark,
              ),
            ),
            const SizedBox(height: 2),
            const Text(
              DummyTemplateData.quotationIntroBody,
              style: TextStyle(fontSize: 8.5, color: textDark, height: 1.25),
            ),
            const SizedBox(height: 2),
            const Text(
              DummyTemplateData.quotationIntroClosing,
              style: TextStyle(fontSize: 8.5, color: textDark),
            ),
            Text(
              DummyTemplateData.quotationIntroSender,
              style: const TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.bold,
                color: textDark,
              ),
            ),
          ],
        ),

        const SizedBox(height: 8),
        Container(height: 0.8, color: borderColor),
        const SizedBox(height: 10),

        // Bordered Item Table with Attached Summary Rows
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: borderColor, width: 0.8),
          ),
          child: Column(
            children: [
              // Header Row
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
                decoration: const BoxDecoration(
                  color: tableHeaderBg,
                  border: Border(
                    bottom: BorderSide(color: borderColor, width: 0.8),
                  ),
                ),
                child: Row(
                  children: const [
                    SizedBox(
                      width: 36,
                      child: Text(
                        'S.No.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          color: textDark,
                        ),
                      ),
                    ),
                    _TableBorderDivider(),
                    SizedBox(
                      width: 60,
                      child: Text(
                        'Item Code',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          color: textDark,
                        ),
                      ),
                    ),
                    _TableBorderDivider(),
                    Expanded(
                      flex: 4,
                      child: Text(
                        'Item Details',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          color: textDark,
                        ),
                      ),
                    ),
                    _TableBorderDivider(),
                    SizedBox(
                      width: 55,
                      child: Text(
                        'Quantity',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          color: textDark,
                        ),
                      ),
                    ),
                    _TableBorderDivider(),
                    SizedBox(
                      width: 65,
                      child: Text(
                        'Price',
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          color: textDark,
                        ),
                      ),
                    ),
                    _TableBorderDivider(),
                    SizedBox(
                      width: 70,
                      child: Text(
                        'Total',
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          color: textDark,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // 2 Dummy Product Rows
              _buildProductRow(
                sNo: '1.',
                itemCode: DummyTemplateData.item1.itemCode,
                title: DummyTemplateData.item1.title,
                description: DummyTemplateData.item1.description,
                qty: '${DummyTemplateData.item1.qtyString} Units',
                price: DummyTemplateData.item1.rateInr,
                total: DummyTemplateData.item1.amountInr,
                hasBottomBorder: true,
              ),
              _buildProductRow(
                sNo: '2.',
                itemCode: DummyTemplateData.item2.itemCode,
                title: DummyTemplateData.item2.title,
                description: DummyTemplateData.item2.description,
                qty: '${DummyTemplateData.item2.qtyString} Units',
                price: DummyTemplateData.item2.rateInr,
                total: DummyTemplateData.item2.amountInr,
                hasBottomBorder: true,
              ),

              // Summary: Subtotal
              _buildSummaryRow(
                label: 'Subtotal',
                value: DummyTemplateData.subtotalInr,
                hasBottomBorder: true,
              ),

              // Summary: Total
              _buildSummaryRow(
                label: 'Total',
                value: DummyTemplateData.grandTotalInr,
                isBold: true,
                hasBottomBorder: false,
              ),
            ],
          ),
        ),

        const SizedBox(height: 10),

        // Quotation Closing & Terms
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              DummyTemplateData.quotationClosingMessage,
              style: TextStyle(fontSize: 8.5, color: textDark),
            ),
            SizedBox(height: 4),
            Text(
              DummyTemplateData.quotationTerms,
              style: TextStyle(
                fontSize: 8.5,
                fontWeight: FontWeight.w600,
                color: textDark,
              ),
            ),
          ],
        ),

        const Spacer(),

        // Bottom Section: Left Payment Details + Right In Words & Signature
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              flex: 5,
              child: buildDummyPaymentDetails(
                type: documentType,
                primary: cyanPrimary,
              ),
            ),
            buildDummySignature(
              lineColor: borderColor,
              labelColor: textDark,
              showName: true,
            ),
            const SizedBox(width: 20),
          ],
        ),

        const SizedBox(height: 12),
        Container(height: 0.8, color: borderColor),
        const SizedBox(height: 6),

        // Footer: Computer generated & Page count
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [
            Text(
              'This is generated by invoz App.',
              style: TextStyle(fontSize: 8, color: textMuted),
            ),
            Text(
              'Page 1 of 1',
              style: TextStyle(fontSize: 8, color: textMuted),
            ),
          ],
        ),
      ],
    ),
  );
}

Widget _buildProductRow({
  required String sNo,
  required String itemCode,
  required String title,
  required String description,
  required String qty,
  required String price,
  required String total,
  required bool hasBottomBorder,
}) {
  const borderColor = Color(0xFF64748B);
  const textDark = Color(0xFF0F172A);
  const textMuted = Color(0xFF475569);

  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
    decoration: BoxDecoration(
      border: hasBottomBorder
          ? const Border(bottom: BorderSide(color: borderColor, width: 0.8))
          : null,
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 36,
          child: Text(
            sNo,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 8.5, color: textDark),
          ),
        ),
        const _TableBorderDivider(),
        SizedBox(
          width: 60,
          child: Text(
            itemCode,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 8.5, color: textDark),
          ),
        ),
        const _TableBorderDivider(),
        Expanded(
          flex: 4,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 8.5,
                  fontWeight: FontWeight.bold,
                  color: textDark,
                ),
              ),
              if (description.isNotEmpty) ...[
                const SizedBox(height: 1),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 7.5,
                    color: textMuted,
                    height: 1.2,
                  ),
                ),
              ],
            ],
          ),
        ),
        const _TableBorderDivider(),
        SizedBox(
          width: 55,
          child: Text(
            qty,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 8.5, color: textDark),
          ),
        ),
        const _TableBorderDivider(),
        SizedBox(
          width: 65,
          child: Text(
            price,
            textAlign: TextAlign.right,
            style: const TextStyle(fontSize: 8.5, color: textDark),
          ),
        ),
        const _TableBorderDivider(),
        SizedBox(
          width: 70,
          child: Text(
            total,
            textAlign: TextAlign.right,
            style: const TextStyle(
              fontSize: 8.5,
              fontWeight: FontWeight.bold,
              color: textDark,
            ),
          ),
        ),
      ],
    ),
  );
}

Widget _buildSummaryRow({
  required String label,
  required String value,
  bool isBold = false,
  required bool hasBottomBorder,
}) {
  const borderColor = Color(0xFF64748B);
  const textDark = Color(0xFF0F172A);

  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 5),
    decoration: BoxDecoration(
      border: hasBottomBorder
          ? const Border(bottom: BorderSide(color: borderColor, width: 0.8))
          : null,
    ),
    child: Row(
      children: [
        const Spacer(),
        SizedBox(
          width: 70,
          child: Text(
            label,
            textAlign: TextAlign.right,
            style: TextStyle(
              fontSize: isBold ? 9.5 : 8.5,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: textDark,
            ),
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 75,
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: TextStyle(
              fontSize: isBold ? 9.5 : 8.5,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
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
      width: 0.8,
      height: 18,
      margin: const EdgeInsets.symmetric(horizontal: 2),
      color: const Color(0xFF64748B),
    );
  }
}
