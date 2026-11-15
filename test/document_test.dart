import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:invoz/core/utils/currency_formatter.dart';
import 'package:invoz/core/widgets/status_badge.dart';
import 'package:invoz/features/business_profile/domain/business_profile_model.dart';
import 'package:invoz/features/customers/domain/customer_model.dart';
import 'package:invoz/features/documents/domain/document_item_model.dart';
import 'package:invoz/features/documents/domain/document_model.dart';
import 'package:invoz/features/documents/domain/payment_record_model.dart';
import 'package:invoz/features/documents/presentation/dummy_template_widget.dart';
import 'package:invoz/features/pdf_engine/document_pdf_generator.dart';
import 'package:invoz/features/pdf_engine/template_registry.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  group('CurrencyFormatter Tests', () {
    test('formats Indian rupee numbering accurately', () {
      final formatted = CurrencyFormatter.format(150000.00);
      expect(formatted, contains('1,50,000.00'));
    });

    test('formats compact numbers for dashboards (full amount per user preference)', () {
      expect(CurrencyFormatter.formatCompact(150000.00), contains('1,50,000'));
      expect(CurrencyFormatter.formatCompact(25000000.00), contains('2,50,00,000'));
      expect(CurrencyFormatter.formatCompact(45000.00), contains('45,000'));
    });

    test('converts numbers to Indian Rupees in words', () {
      final words = CurrencyFormatter.toWords(150000.00);
      expect(words, equals('Rupees One Lakh Fifty Thousand Only'));

      final wordsWithPaise = CurrencyFormatter.toWords(1250.50);
      expect(
        wordsWithPaise,
        equals(
          'Rupees One Thousand Two Hundred and Fifty and Fifty Paise Only',
        ),
      );
    });
  });

  group('Document Item & Accounting Calculations', () {
    test(
      'calculates line item gross, discount, tax, and lineTotal accurately',
      () {
        const item = DocumentItem(
          id: 'item_1',
          documentId: 'doc_1',
          title: 'Consulting',
          quantity: 10,
          unitPrice: 1000.0,
          discountPercent: 10.0, // 10% off
          taxPercent: 18.0, // 18% GST
        );

        expect(item.grossAmount, equals(10000.0));
        expect(item.discountAmount, equals(1000.0));
        expect(item.taxableAmount, equals(9000.0));
        expect(item.taxAmount, equals(1620.0)); // 18% of 9000
        expect(item.lineTotal, equals(10620.0));
      },
    );

    test('calculates overall document total and round off adjustment', () {
      const item1 = DocumentItem(
        id: 'item_1',
        documentId: 'doc_1',
        title: 'Design Work',
        quantity: 1,
        unitPrice: 2500.40,
        taxPercent: 18.0,
      );

      final now = DateTime.now();
      final doc = DocumentModel(
        id: 'doc_1',
        docNumber: 'INV-2026-0001',
        docType: DocumentType.invoice,
        issueDate: now,
        dueDate: now.add(const Duration(days: 15)),
        items: [item1],
        createdAt: now,
        updatedAt: now,
      );

      expect(doc.subtotal, equals(2500.40));
      expect(doc.totalTaxAmount, closeTo(450.072, 0.001));
      // Total amount should be rounded to the nearest integer
      expect(doc.totalAmount, equals(doc.totalAmount.roundToDouble()));
    });

    test(
      'calculates payment status: draft, partial, paid, and balance due',
      () {
        final now = DateTime.now();
        const item = DocumentItem(
          id: 'item_1',
          documentId: 'doc_1',
          title: 'Product',
          quantity: 1,
          unitPrice: 1000.0,
          taxPercent: 0.0,
        );

        final unpaidDoc = DocumentModel(
          id: 'doc_1',
          docNumber: 'INV-2026-0001',
          docType: DocumentType.invoice,
          issueDate: now,
          dueDate: now.add(const Duration(days: 15)),
          status: DocumentStatus.sent,
          items: [item],
          payments: const [],
          createdAt: now,
          updatedAt: now,
        );

        expect(unpaidDoc.balanceDue, equals(1000.0));
        expect(unpaidDoc.calculatedStatus, equals(DocumentStatus.sent));

        // Partial payment
        final partialPayment = PaymentRecord(
          id: 'pay_1',
          documentId: 'doc_1',
          paymentDate: now,
          amount: 400.0,
          createdAt: now,
        );
        final partialDoc = unpaidDoc.copyWith(payments: [partialPayment]);
        expect(partialDoc.totalPaid, equals(400.0));
        expect(partialDoc.balanceDue, equals(600.0));
        expect(partialDoc.calculatedStatus, equals(DocumentStatus.partial));

        // Full payment
        final fullPayment = PaymentRecord(
          id: 'pay_2',
          documentId: 'doc_1',
          paymentDate: now,
          amount: 600.0,
          createdAt: now,
        );
        final paidDoc = unpaidDoc.copyWith(
          payments: [partialPayment, fullPayment],
        );
        expect(paidDoc.totalPaid, equals(1000.0));
        expect(paidDoc.balanceDue, equals(0.0));
        expect(paidDoc.calculatedStatus, equals(DocumentStatus.paid));
      },
    );
  });

  group('Template Registry & PDF Generation', () {
    test('Template Registry contains all 7 promised styles', () {
      expect(
        TemplateRegistry.allTemplates.length,
        7,
        reason: 'Should contain 7 template styles',
      );
      final ids = TemplateRegistry.allTemplates.map((t) => t.id).toList();
      expect(ids, contains('free_classic'));
      expect(ids, contains('premium_modern'));
      expect(ids, contains('cyan_quotation'));
      expect(ids, contains('warm_quotation'));
      expect(ids, contains('elegant_center'));
      expect(ids, contains('order_receipt'));
      expect(ids, contains('thermal_receipt'));
    });

    test('Template classification matches specification', () {
      final invoiceTemplates =
          TemplateRegistry.getTemplatesFor(DocumentType.invoice);
      final proformaTemplates =
          TemplateRegistry.getTemplatesFor(DocumentType.proforma);
      final receiptTemplates =
          TemplateRegistry.getTemplatesFor(DocumentType.receipt);
      final quotationTemplates =
          TemplateRegistry.getTemplatesFor(DocumentType.quotation);

      // Rule 1: Always same templates inside invoice and proforma
      final invoiceIds = invoiceTemplates.map((t) => t.id).toList();
      final proformaIds = proformaTemplates.map((t) => t.id).toList();
      expect(invoiceIds, equals(proformaIds));

      // Rule 2: Classic free & Modern free are invoice/proforma
      expect(invoiceIds, containsAll(['free_classic', 'premium_modern']));
      expect(invoiceIds.length, equals(2));

      // Rule 3: 3 templates in receipt: Elegant Center, Order Receipt, Thermal Print
      final receiptIds = receiptTemplates.map((t) => t.id).toList();
      expect(
        receiptIds,
        containsAll(['elegant_center', 'order_receipt', 'thermal_receipt']),
      );
      expect(receiptIds, isNot(contains('free_classic')));
      expect(receiptIds.length, equals(3));

      // Rule 4: 2 modern quotation templates for quotation
      expect(quotationTemplates.length, equals(2));
      expect(
        quotationTemplates.map((t) => t.id).toList(),
        containsAll(['warm_quotation', 'cyan_quotation']),
      );

      // Rule 5: Exactly 1 free template per category, rest are paid
      for (final type in DocumentType.values) {
        final list = TemplateRegistry.getTemplatesFor(type);
        final freeCount = list.where((t) => !t.isPremium).length;
        final paidCount = list.where((t) => t.isPremium).length;
        expect(freeCount, equals(1),
            reason: '$type should have exactly 1 free template');
        expect(paidCount, equals(list.length - 1),
            reason: '$type remaining templates should be paid');
      }
    });

    test('TemplateRegistry.resolveTemplateId handles aliases and document types', () {
      expect(
        TemplateRegistry.resolveTemplateId('modern_crimson', DocumentType.invoice),
        equals(TemplateRegistry.premiumModern),
      );
      expect(
        TemplateRegistry.resolveTemplateId('bold', DocumentType.invoice),
        equals(TemplateRegistry.premiumModern),
      );
      expect(
        TemplateRegistry.resolveTemplateId('minimal', DocumentType.invoice),
        equals(TemplateRegistry.freeClassic),
      );
      expect(
        TemplateRegistry.resolveTemplateId(null, DocumentType.quotation),
        equals(TemplateRegistry.cyanQuotation),
      );
      expect(
        TemplateRegistry.resolveTemplateId('warm_quotation', DocumentType.quotation),
        equals(TemplateRegistry.warmQuotation),
      );
      expect(
        TemplateRegistry.resolveTemplateId('cyan_quotation', DocumentType.quotation),
        equals(TemplateRegistry.cyanQuotation),
      );
      expect(
        TemplateRegistry.resolveTemplateId('compact', DocumentType.receipt),
        equals(TemplateRegistry.thermalReceipt),
      );
      expect(
        TemplateRegistry.resolveTemplateId('order', DocumentType.receipt),
        equals(TemplateRegistry.orderReceipt),
      );
      expect(
        TemplateRegistry.resolveTemplateId('elegant', DocumentType.receipt),
        equals(TemplateRegistry.elegantCenter),
      );
      expect(
        TemplateRegistry.resolveTemplateId('unknown', DocumentType.receipt),
        equals(TemplateRegistry.elegantCenter),
      );
      expect(
        TemplateRegistry.resolveTemplateId(null, DocumentType.proforma),
        equals(TemplateRegistry.freeClassic),
      );
    });

    test('generates valid PDF bytes across all templates', () async {
      final now = DateTime.now();
      final customer = Customer(
        id: 'cust_1',
        name: 'Acme Technologies',
        phone: '+91 9876543210',
        email: 'billing@acme.com',
        billingAddress: '42 MG Road, Bengaluru, Karnataka, 560001',
        gstin: '29ABCDE1234F1Z5',
        createdAt: now,
      );

      const profile = BusinessProfile(
        businessName: 'Apex Studio',
        phone: '+91 9811122233',
        email: 'contact@apex.in',
        address: '101 Cyber City, Gurugram, Haryana',
        gstin: '06AAAAA0000A1Z5',
      );

      const item1 = DocumentItem(
        id: 'i1',
        documentId: 'd1',
        title: 'Brand Identity Design',
        description: 'Complete guidelines, logos, and vector assets',
        quantity: 1,
        unit: 'project',
        unitPrice: 35000.0,
        taxPercent: 18.0,
        hsnSacCode: '998314',
      );

      const item2 = DocumentItem(
        id: 'i2',
        documentId: 'd1',
        title: 'Design Retainer',
        quantity: 2,
        unit: 'month',
        unitPrice: 15000.0,
        discountPercent: 5.0,
        taxPercent: 18.0,
        hsnSacCode: '998314',
      );

      final doc = DocumentModel(
        id: 'd1',
        docNumber: 'INV-2026-0001',
        docType: DocumentType.invoice,
        customerSnapshot: customer,
        issueDate: now,
        dueDate: now.add(const Duration(days: 15)),
        status: DocumentStatus.sent,
        items: [item1, item2],
        createdAt: now,
        updatedAt: now,
      );

      for (final template in TemplateRegistry.allTemplates) {
        final pdfBytes = await DocumentPdfGenerator.generate(
          document: doc,
          profile: profile,
      payments: [],
          templateId: template.id,
        );
        expect(pdfBytes.isNotEmpty, isTrue);
        // PDF header magic bytes "%PDF-"
        expect(String.fromCharCodes(pdfBytes.sublist(0, 5)), equals('%PDF-'));
      }
    });

    testWidgets('DummyTemplateWidget renders without crash for all templates', (tester) async {
      for (final t in TemplateRegistry.allTemplates) {
        for (final docType in DocumentType.values) {
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: SizedBox(
                  width: 300,
                  height: 400,
                  child: DummyTemplateWidget(
                    templateId: t.id,
                    documentType: docType,
                  ),
                ),
              ),
            ),
          );
        }
      }
    });
  });
}
