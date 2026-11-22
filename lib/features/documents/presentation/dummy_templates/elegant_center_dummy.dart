import 'package:flutter/material.dart';
import '../../domain/document_model.dart';
import 'dummy_template_utils.dart';

Widget buildElegantCenterDummy([
  DocumentType documentType = DocumentType.receipt,
]) {
  const primary = Color(0xFF0D47A1);
  const lightBlue = Color(0xFFD6E4F0);

  return Container(
    color: Colors.white,
    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 40),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Centered Header: Dummy Company Logo (radius 8) + Company Name
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              buildDummyLogo(size: 38, radius: 8),
              const SizedBox(width: 14),
              Text(
                DummyTemplateData.companyName,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 28,
                  color: primary,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        // Centered Contact Information Row
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.location_on, size: 10, color: Colors.grey.shade600),
              const SizedBox(width: 4),
              buildDummyText(
                DummyTemplateData.companyAddress,
                color: Colors.grey.shade600,
              ),
              const SizedBox(width: 14),
              Icon(Icons.phone, size: 10, color: Colors.grey.shade600),
              const SizedBox(width: 4),
              buildDummyText(
                DummyTemplateData.companyPhone,
                color: Colors.grey.shade600,
              ),
              const SizedBox(width: 14),
              Icon(Icons.email, size: 10, color: Colors.grey.shade600),
              const SizedBox(width: 4),
              buildDummyText(
                DummyTemplateData.companyEmail,
                color: Colors.grey.shade600,
              ),
              const SizedBox(width: 14),
              Icon(Icons.language, size: 10, color: Colors.grey.shade600),
              const SizedBox(width: 4),
              buildDummyText(
                DummyTemplateData.companyWebsite,
                color: Colors.grey.shade600,
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Container(height: 1.5, color: lightBlue),
        const SizedBox(height: 24),

        // Party Info & Document Title
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  buildDummyText(
                    'Paid By',
                    color: primary,
                    bold: true,
                    size: 11,
                  ),
                  const SizedBox(height: 4),
                  buildDummyText(
                    DummyTemplateData.clientName,
                    size: 11,
                    bold: true,
                  ),
                  const SizedBox(height: 2),
                  buildDummyText(DummyTemplateData.clientEmail, size: 10),
                  buildDummyText(DummyTemplateData.clientAddress, size: 10),
                ],
              ),
            ),
            const SizedBox(width: 12),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.topRight,
              child: const Text(
                'RECEIPT',
                style: TextStyle(
                  fontSize: 26,
                  color: primary,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.5,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        // Dates & Document Number
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  buildDummyText(
                    'Receipt Details',
                    color: primary,
                    bold: true,
                    size: 11,
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      SizedBox(
                        width: 90,
                        child: buildDummyText('Payment Date:', size: 10.5),
                      ),
                      buildDummyText(
                        DummyTemplateData.paymentDate,
                        size: 10.5,
                        bold: true,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    SizedBox(
                      width: 90,
                      child: buildDummyText(
                        'Receipt #',
                        color: primary,
                        bold: true,
                        size: 11,
                      ),
                    ),
                    buildDummyText(
                      DummyTemplateData.getDocNumberPlain(DocumentType.receipt),
                      size: 11,
                      bold: true,
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 90,
                      child: buildDummyText('PO Number:', size: 10.5),
                    ),
                    buildDummyText(
                      DummyTemplateData.poNumber,
                      size: 10.5,
                      color: Colors.grey.shade700,
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 20),

        // 2 Products Table
        Container(
          decoration: BoxDecoration(border: Border.all(color: primary)),
          child: Column(
            children: [
              Container(
                color: primary,
                padding: const EdgeInsets.symmetric(
                  vertical: 8,
                  horizontal: 12,
                ),
                child: Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: buildDummyText(
                        'Quantity',
                        color: Colors.white,
                        bold: true,
                        size: 10,
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: buildDummyText(
                        'Description',
                        color: Colors.white,
                        bold: true,
                        size: 10,
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: buildDummyText(
                          'Unit Price',
                          color: Colors.white,
                          bold: true,
                          size: 10,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: buildDummyText(
                          'Amount',
                          color: Colors.white,
                          bold: true,
                          size: 10,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // 2 Dummy Products
              for (int i = 0; i < DummyTemplateData.items.length; i++) ...[
                if (i > 0) Container(height: 1, color: lightBlue),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 10,
                    horizontal: 12,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 1,
                        child: buildDummyText(
                          DummyTemplateData.items[i].qtyString,
                          size: 10.5,
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            buildDummyText(
                              DummyTemplateData.items[i].title,
                              bold: true,
                              size: 10.5,
                            ),
                            buildDummyText(
                              DummyTemplateData.items[i].description,
                              size: 8.5,
                              color: Colors.grey.shade600,
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: buildDummyText(
                            DummyTemplateData.items[i].rateRs,
                            size: 10.5,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: buildDummyText(
                            DummyTemplateData.items[i].amountRs,
                            bold: true,
                            size: 10.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              Container(height: 1, color: primary),

              // Subtotal
              Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 7,
                  horizontal: 12,
                ),
                child: Row(
                  children: [
                    const Expanded(flex: 4, child: SizedBox()),
                    Expanded(
                      flex: 2,
                      child: buildDummyText('Subtotal', size: 10.5),
                    ),
                    Expanded(
                      flex: 2,
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: buildDummyText(
                          DummyTemplateData.subtotalRs,
                          size: 10.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Tax
              Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 7,
                  horizontal: 12,
                ),
                child: Row(
                  children: [
                    const Expanded(flex: 4, child: SizedBox()),
                    Expanded(
                      flex: 2,
                      child: buildDummyText('Tax (12%)', size: 10.5),
                    ),
                    Expanded(
                      flex: 2,
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: buildDummyText(
                          DummyTemplateData.taxRs,
                          size: 10.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(height: 1, color: primary),
              // Total
              Container(
                color: lightBlue,
                padding: const EdgeInsets.symmetric(
                  vertical: 10,
                  horizontal: 12,
                ),
                child: Row(
                  children: [
                    const Expanded(flex: 4, child: SizedBox()),
                    Expanded(
                      flex: 2,
                      child: buildDummyText(
                        'Total',
                        color: primary,
                        bold: true,
                        size: 12,
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: buildDummyText(
                          DummyTemplateData.grandTotalRs,
                          color: primary,
                          bold: true,
                          size: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const Spacer(),

        // Bottom Notes, Payment Details & Signature
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  buildDummyText('Notes', color: primary, bold: true, size: 11),
                  const SizedBox(height: 4),
                  buildDummyText(DummyTemplateData.notes, size: 9.5),
                  const SizedBox(height: 12),
                  buildDummyPaymentDetails(
                    type: documentType,
                    primary: primary,
                  ),
                ],
              ),
            ),
            buildDummySignature(
              lineColor: primary,
              labelColor: primary,
              showName: true,
            ),
          ],
        ),
      ],
    ),
  );
}
