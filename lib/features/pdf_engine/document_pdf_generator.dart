import 'dart:io';
import 'package:flutter/services.dart';
import 'package:invoz/features/settings/domain/payment_detail_model.dart';
import 'package:pdf/pdf.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:http/http.dart' as http;
import '../../core/utils/currency_formatter.dart';
import '../../core/utils/date_formatter.dart';
import '../business_profile/domain/business_profile_model.dart';
import '../documents/domain/document_model.dart';
import 'template_registry.dart';

class DocumentPdfGenerator {
  DocumentPdfGenerator._();

  static final Map<String, Uint8List> _imageCache = {};

  static Future<Uint8List?> _fetchImageBytes(String path) async {
    if (path.isEmpty) return null;
    if (_imageCache.containsKey(path)) return _imageCache[path];

    try {
      String resolvedUrl = path;

      // Extremely fast gs:// caching using SharedPreferences
      if (path.startsWith('gs://')) {
        final prefs = await SharedPreferences.getInstance();
        final cacheKey = 'gs_url_$path';
        final cachedUrl = prefs.getString(cacheKey);

        if (cachedUrl != null && cachedUrl.isNotEmpty) {
          resolvedUrl = cachedUrl;
        } else {
          try {
            resolvedUrl = await FirebaseStorage.instance
                .refFromURL(path)
                .getDownloadURL();
            await prefs.setString(cacheKey, resolvedUrl);
          } catch (e) {
            return null;
          }
        }
      }

      if (resolvedUrl.startsWith('http')) {
        // Share EXACT cache with the UI's CachedNetworkImage to completely eliminate downloads
        try {
          final file = await DefaultCacheManager().getSingleFile(resolvedUrl);
          if (await file.exists()) {
            final bytes = await file.readAsBytes();
            _imageCache[path] = bytes;
            return bytes;
          }
        } catch (_) {}

        // Ultimate fallback
        final response = await http
            .get(Uri.parse(resolvedUrl))
            .timeout(const Duration(seconds: 5));
        if (response.statusCode == 200) {
          _imageCache[path] = response.bodyBytes;
          return response.bodyBytes;
        }
      } else {
        final file = File(resolvedUrl);
        if (await file.exists()) {
          final bytes = await file.readAsBytes();
          _imageCache[path] = bytes;
          return bytes;
        }
      }
    } catch (_) {}
    return null;
  }

  static Future<Uint8List> generate({
    required DocumentModel document,
    required BusinessProfile profile,
    required List<PaymentDetail> payments,
    String? templateId,
    PdfPageFormat? pageFormat,
  }) async {
    final pdf = pw.Document(
      title: '${document.docType.displayName} ${document.docNumber}',
      author: profile.businessName.isNotEmpty ? profile.businessName : 'invoz',
    );

    final String selectedTemplate = TemplateRegistry.resolveTemplateId(
      templateId ?? document.templateId,
      document.docType,
    );

    final Uint8List? logoBytes = profile.logoPath != null
        ? await _fetchImageBytes(profile.logoPath!)
        : null;
    final Uint8List? signatureBytes = profile.signaturePath != null
        ? await _fetchImageBytes(profile.signaturePath!)
        : null;
    final Uint8List? stampBytes = profile.stampPath != null
        ? await _fetchImageBytes(profile.stampPath!)
        : null;

    final isThermal = selectedTemplate == TemplateRegistry.thermalReceipt;
    final isOrderReceipt = selectedTemplate == TemplateRegistry.orderReceipt;

    final PdfPageFormat effectivePageFormat;
    final pw.EdgeInsets effectiveMargin;
    final pw.Widget Function(pw.Context)? effectiveFooter;

    if (isThermal) {
      final double calcThermalHeight =
          240.0 +
          (logoBytes != null ? 40.0 : 0.0) +
          (signatureBytes != null ? 50.0 : 0.0) +
          (document.items.length * 20.0) +
          (document.notes?.isNotEmpty == true ? 20.0 : 0.0) +
          (profile.address?.isNotEmpty == true ? 25.0 : 0.0);
      final double finalThermalHeight = calcThermalHeight < 280
          ? 280
          : calcThermalHeight;

      effectivePageFormat = PdfPageFormat(
        340,
        finalThermalHeight,
        marginAll: 0,
      );
      effectiveMargin = const pw.EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 10,
      );
      effectiveFooter = null;
    } else if (isOrderReceipt) {
      final double calcOrderHeight =
          440.0 +
          (logoBytes != null ? 40.0 : 0.0) +
          (signatureBytes != null ? 70.0 : 0.0) +
          (document.items.length * 28.0) +
          (document.customerSnapshot?.shippingAddress?.isNotEmpty == true
              ? 30.0
              : 0.0);
      final double finalOrderHeight = calcOrderHeight < 600
          ? 600
          : calcOrderHeight;

      effectivePageFormat = PdfPageFormat(440, finalOrderHeight, marginAll: 0);
      effectiveMargin = const pw.EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 10,
      );
      effectiveFooter = null;
    } else {
      effectivePageFormat = pageFormat ?? PdfPageFormat.a4;
      effectiveMargin = const pw.EdgeInsets.all(32);
      effectiveFooter = (context) => pw.Container(
        margin: const pw.EdgeInsets.only(top: 25, left: 5),
        child: pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.UrlLink(
              destination:
                  'https://play.google.com/store/apps/details?id=com.invoice.invoz',
              child: pw.Text(
                'Generated by Invoz App',
                style: pw.TextStyle(
                  fontSize: 9,
                  color: PdfColor.fromHex('#2563EB'),
                ),
              ),
            ),
            pw.Text(
              'Page ${context.pageNumber} of ${context.pagesCount}',
              style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey),
            ),
          ],
        ),
      );
    }

    pdf.addPage(
      pw.MultiPage(
        pageFormat: effectivePageFormat,
        margin: effectiveMargin,
        footer: effectiveFooter,
        build: (context) {
          if (selectedTemplate == TemplateRegistry.cyanQuotation) {
            return _buildCyanQuotation(
              context,
              document,
              profile,
              payments: payments,
              logoBytes: logoBytes,
              signatureBytes: signatureBytes,
              stampBytes: stampBytes,
            );
          }
          if (selectedTemplate == TemplateRegistry.warmQuotation) {
            return _buildWarmQuotation(
              context,
              document,
              profile,
              payments: payments,
              logoBytes: logoBytes,
              signatureBytes: signatureBytes,
              stampBytes: stampBytes,
            );
          }
          if (selectedTemplate == TemplateRegistry.thermalReceipt) {
            return _buildReceiptThermal(
              context,
              document,
              profile,
              payments: payments,
              logoBytes: logoBytes,
              signatureBytes: signatureBytes,
              stampBytes: stampBytes,
            );
          }
          if (selectedTemplate == TemplateRegistry.orderReceipt) {
            return _buildOrderReceipt(
              context,
              document,
              profile,
              payments: payments,
              logoBytes: logoBytes,
              signatureBytes: signatureBytes,
              stampBytes: stampBytes,
            );
          }
          if (selectedTemplate == TemplateRegistry.premiumModern) {
            return _buildPremiumModern(
              context,
              document,
              profile,
              payments: payments,
              logoBytes: logoBytes,
              signatureBytes: signatureBytes,
              stampBytes: stampBytes,
            );
          }
          if (selectedTemplate == TemplateRegistry.elegantCenter) {
            return _buildElegantCenter(
              context,
              document,
              profile,
              payments: payments,
              logoBytes: logoBytes,
              signatureBytes: signatureBytes,
              stampBytes: stampBytes,
            );
          }
          return _buildFreeClassic(
            context,
            document,
            profile,
            payments: payments,
            logoBytes: logoBytes,
            signatureBytes: signatureBytes,
            stampBytes: stampBytes,
          );
        },
      ),
    );

    return pdf.save();
  }

  static List<pw.Widget> _buildCyanQuotation(
    pw.Context context,
    DocumentModel doc,
    BusinessProfile profile, {
    required List<PaymentDetail> payments,
    Uint8List? logoBytes,
    Uint8List? signatureBytes,
    Uint8List? stampBytes,
  }) {
    String currency = profile.currencySymbol.isNotEmpty
        ? profile.currencySymbol
        : 'Rs.';
    if (currency == '\u20B9') {
      currency = 'Rs.';
    }

    final cyanPrimary = PdfColor.fromHex('#00A3E0');
    final cyanHeaderBg = PdfColor.fromHex('#E6F6F9');
    final textDark = PdfColor.fromHex('#1E293B');
    final textMuted = PdfColor.fromHex('#64748B');
    final borderColor = PdfColor.fromHex('#334155');

    final cName = doc.customerSnapshot?.name ?? 'Valued Customer';
    final cAddress = doc.customerSnapshot?.billingAddress ?? '';
    final bAddress = profile.address?.trim() ?? '';

    String placeOfSupply = 'Karnataka';
    if (bAddress.isNotEmpty) {
      final parts = bAddress.split(RegExp(r'[\n,]'));
      final nonEmpty =
          parts.map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
      if (nonEmpty.isNotEmpty) {
        placeOfSupply = nonEmpty.last;
      }
    }
    const countryOfSupply = 'India';

    String totalInWords = '';
    try {
      totalInWords = CurrencyFormatter.toWords(doc.totalAmount);
    } catch (_) {
      totalInWords = '${doc.totalAmount.toStringAsFixed(2)} $currency';
    }

    return [
      // Top Header: Logo + Brand on Left, "Quotation" on Right
      pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        crossAxisAlignment: pw.CrossAxisAlignment.center,
        children: [
          pw.Row(
            children: [
              if (logoBytes != null)
                pw.Container(
                  width: 38,
                  height: 38,
                  margin: const pw.EdgeInsets.only(right: 8),
                  child: pw.Image(
                    pw.MemoryImage(logoBytes),
                    fit: pw.BoxFit.contain,
                  ),
                )
              else
                pw.Container(
                  width: 38,
                  height: 38,
                  margin: const pw.EdgeInsets.only(right: 8),
                  decoration: pw.BoxDecoration(
                    color: cyanPrimary,
                    borderRadius:
                        const pw.BorderRadius.all(pw.Radius.circular(4)),
                  ),
                  child: pw.Center(
                    child: pw.Text(
                      profile.businessName.isNotEmpty
                          ? profile.businessName[0].toUpperCase()
                          : 'F',
                      style: pw.TextStyle(
                        color: PdfColors.white,
                        fontSize: 22,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                mainAxisSize: pw.MainAxisSize.min,
                children: [
                  pw.Text(
                    profile.businessName.isNotEmpty
                        ? profile.businessName.toUpperCase()
                        : 'FOOBAR LABS',
                    style: pw.TextStyle(
                      fontSize: 15,
                      fontWeight: pw.FontWeight.bold,
                      color: textDark,
                      letterSpacing: 0.8,
                    ),
                  ),
                ],
              ),
            ],
          ),
          pw.Text(
            doc.docType.displayName,
            style: pw.TextStyle(
              fontSize: 26,
              fontWeight: pw.FontWeight.normal,
              color: textDark,
              letterSpacing: -0.5,
            ),
          ),
        ],
      ),
      pw.SizedBox(height: 20),

      // Party Details & Metadata Row
      pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          // Quotation by
          pw.Expanded(
            flex: 5,
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'Quotation by',
                  style: pw.TextStyle(
                    fontSize: 11,
                    fontWeight: pw.FontWeight.bold,
                    color: textDark,
                  ),
                ),
                pw.SizedBox(height: 4),
                pw.Text(
                  profile.businessName.isNotEmpty
                      ? profile.businessName
                      : 'Foobar Labs',
                  style: pw.TextStyle(fontSize: 9.5, color: textDark),
                ),
                if (bAddress.isNotEmpty) ...[
                  pw.SizedBox(height: 2),
                  pw.Text(
                    bAddress,
                    style: pw.TextStyle(
                      fontSize: 9,
                      color: textMuted,
                      lineSpacing: 1.2,
                    ),
                  ),
                ],
                if (profile.gstin?.isNotEmpty == true) ...[
                  pw.SizedBox(height: 2),
                  pw.Text(
                    'GSTIN: ${profile.gstin!}',
                    style: pw.TextStyle(fontSize: 8.5, color: textMuted),
                  ),
                ],
              ],
            ),
          ),

          // Quotation to
          pw.Expanded(
            flex: 5,
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'Quotation to',
                  style: pw.TextStyle(
                    fontSize: 11,
                    fontWeight: pw.FontWeight.bold,
                    color: textDark,
                  ),
                ),
                pw.SizedBox(height: 4),
                pw.Text(
                  cName,
                  style: pw.TextStyle(fontSize: 9.5, color: textDark),
                ),
                if (cAddress.isNotEmpty) ...[
                  pw.SizedBox(height: 2),
                  pw.Text(
                    cAddress,
                    style: pw.TextStyle(
                      fontSize: 9,
                      color: textMuted,
                      lineSpacing: 1.2,
                    ),
                  ),
                ],
                if (doc.customerSnapshot?.gstin?.isNotEmpty == true) ...[
                  pw.SizedBox(height: 2),
                  pw.Text(
                    'GSTIN: ${doc.customerSnapshot!.gstin!}',
                    style: pw.TextStyle(fontSize: 8.5, color: textMuted),
                  ),
                ],
              ],
            ),
          ),

          // Metadata column
          pw.Expanded(
            flex: 5,
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.end,
              children: [
                pw.Row(
                  mainAxisSize: pw.MainAxisSize.min,
                  children: [
                    pw.Text('${doc.docType.displayName} No:  ',
                        style: pw.TextStyle(
                            fontSize: 9,
                            fontWeight: pw.FontWeight.bold,
                            color: textDark)),
                    pw.Text(doc.docNumber,
                        style: pw.TextStyle(fontSize: 9, color: textDark)),
                  ],
                ),
                pw.SizedBox(height: 2),
                if (doc.docType == DocumentType.receipt)
                  pw.Row(
                    mainAxisSize: pw.MainAxisSize.min,
                    children: [
                      pw.Text('Payment Date:  ',
                          style: pw.TextStyle(
                              fontSize: 9,
                              fontWeight: pw.FontWeight.bold,
                              color: textDark)),
                      pw.Text(DateFormatter.format(doc.issueDate),
                          style: pw.TextStyle(fontSize: 9, color: textDark)),
                    ],
                  )
                else ...[
                  pw.Row(
                    mainAxisSize: pw.MainAxisSize.min,
                    children: [
                      pw.Text(
                          doc.docType == DocumentType.quotation ||
                                  doc.docType == DocumentType.proforma
                              ? 'Issue Date:  '
                              : '${doc.docType.displayName} Date:  ',
                          style: pw.TextStyle(
                              fontSize: 9,
                              fontWeight: pw.FontWeight.bold,
                              color: textDark)),
                      pw.Text(DateFormatter.format(doc.issueDate),
                          style: pw.TextStyle(fontSize: 9, color: textDark)),
                    ],
                  ),
                  pw.SizedBox(height: 2),
                  pw.Row(
                    mainAxisSize: pw.MainAxisSize.min,
                    children: [
                      pw.Text(
                          doc.docType == DocumentType.quotation ||
                                  doc.docType == DocumentType.proforma
                              ? 'Valid Until:  '
                              : 'Due Date:  ',
                          style: pw.TextStyle(
                              fontSize: 9,
                              fontWeight: pw.FontWeight.bold,
                              color: textDark)),
                      pw.Text(DateFormatter.format(doc.dueDate),
                          style: pw.TextStyle(fontSize: 9, color: textDark)),
                    ],
                  ),
                ],
                pw.SizedBox(height: 6),
                pw.Row(
                  mainAxisSize: pw.MainAxisSize.min,
                  children: [
                    pw.Text('Country of supply:  ',
                        style: pw.TextStyle(
                            fontSize: 9,
                            fontWeight: pw.FontWeight.bold,
                            color: textDark)),
                    pw.Text(countryOfSupply,
                        style: pw.TextStyle(fontSize: 9, color: textDark)),
                  ],
                ),
                pw.SizedBox(height: 2),
                pw.Row(
                  mainAxisSize: pw.MainAxisSize.min,
                  children: [
                    pw.Text('Place of supply:  ',
                        style: pw.TextStyle(
                            fontSize: 9,
                            fontWeight: pw.FontWeight.bold,
                            color: textDark)),
                    pw.Text(placeOfSupply,
                        style: pw.TextStyle(fontSize: 9, color: textDark)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
      pw.SizedBox(height: 10),

      // Quotation Intro Message (Top of Table)
      pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Dear ${cName.isNotEmpty ? cName : "Valued Client"},',
            style: pw.TextStyle(
              fontSize: 9.5,
              fontWeight: pw.FontWeight.bold,
              color: textDark,
            ),
          ),
          pw.SizedBox(height: 2),
          pw.Text(
            'Please find below a cost-breakdown for the quotation. Please consider this, and do not hesitate to contact us with any questions.',
            style: const pw.TextStyle(
              fontSize: 8.5,
              color: textDark,
              lineSpacing: 1.25,
            ),
          ),
          pw.SizedBox(height: 2),
          pw.Text(
            'Many thanks,',
            style: const pw.TextStyle(fontSize: 8.5, color: textDark),
          ),
          pw.Text(
            profile.businessName.isNotEmpty
                ? profile.businessName
                : 'Acme Innovations',
            style: pw.TextStyle(
              fontSize: 9,
              fontWeight: pw.FontWeight.bold,
              color: textDark,
            ),
          ),
        ],
      ),
      pw.SizedBox(height: 10),

      // Items Table with Borders
      pw.Container(
        decoration: pw.BoxDecoration(
          border: pw.Border.all(color: borderColor, width: 0.8),
        ),
        child: pw.Column(
          children: [
            // Table Header
            pw.Container(
              color: cyanHeaderBg,
              padding:
                  const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              decoration: pw.BoxDecoration(
                border: pw.Border(
                  bottom: pw.BorderSide(color: borderColor, width: 0.8),
                ),
              ),
              child: pw.Row(
                children: [
                  pw.Expanded(
                    flex: 4,
                    child: pw.Text(
                      'Item #/Item description',
                      style: pw.TextStyle(
                        fontSize: 9,
                        fontWeight: pw.FontWeight.bold,
                        color: textDark,
                      ),
                    ),
                  ),
                  pw.Container(
                    width: 0.8,
                    height: 14,
                    color: borderColor,
                    margin: const pw.EdgeInsets.symmetric(horizontal: 4),
                  ),
                  pw.SizedBox(
                    width: 50,
                    child: pw.Text(
                      'Quantity',
                      textAlign: pw.TextAlign.center,
                      style: pw.TextStyle(
                        fontSize: 9,
                        fontWeight: pw.FontWeight.bold,
                        color: textDark,
                      ),
                    ),
                  ),
                  pw.Container(
                    width: 0.8,
                    height: 14,
                    color: borderColor,
                    margin: const pw.EdgeInsets.symmetric(horizontal: 4),
                  ),
                  pw.SizedBox(
                    width: 60,
                    child: pw.Text(
                      'Rate',
                      textAlign: pw.TextAlign.center,
                      style: pw.TextStyle(
                        fontSize: 9,
                        fontWeight: pw.FontWeight.bold,
                        color: textDark,
                      ),
                    ),
                  ),
                  pw.Container(
                    width: 0.8,
                    height: 14,
                    color: borderColor,
                    margin: const pw.EdgeInsets.symmetric(horizontal: 4),
                  ),
                  pw.SizedBox(
                    width: 55,
                    child: pw.Text(
                      'Discount',
                      textAlign: pw.TextAlign.center,
                      style: pw.TextStyle(
                        fontSize: 9,
                        fontWeight: pw.FontWeight.bold,
                        color: textDark,
                      ),
                    ),
                  ),
                  pw.Container(
                    width: 0.8,
                    height: 14,
                    color: borderColor,
                    margin: const pw.EdgeInsets.symmetric(horizontal: 4),
                  ),
                  pw.SizedBox(
                    width: 75,
                    child: pw.Text(
                      'Amount\n(After Discount)',
                      textAlign: pw.TextAlign.center,
                      style: pw.TextStyle(
                        fontSize: 8,
                        fontWeight: pw.FontWeight.bold,
                        color: textDark,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Item Rows
            ...doc.items.asMap().entries.map((entry) {
              final idx = entry.key;
              final item = entry.value;
              final hasBottom = idx < doc.items.length - 1;

              return pw.Container(
                padding: const pw.EdgeInsets.symmetric(
                    horizontal: 8, vertical: 6),
                decoration: pw.BoxDecoration(
                  border: hasBottom
                      ? pw.Border(
                          bottom:
                              pw.BorderSide(color: borderColor, width: 0.8),
                        )
                      : null,
                ),
                child: pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Expanded(
                      flex: 4,
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            item.title,
                            style: pw.TextStyle(
                              fontSize: 9,
                              fontWeight: pw.FontWeight.bold,
                              color: textDark,
                            ),
                          ),
                          if (item.description != null &&
                              item.description!.isNotEmpty) ...[
                            pw.SizedBox(height: 2),
                            pw.Text(
                              item.description!,
                              style: pw.TextStyle(
                                fontSize: 7.5,
                                color: textMuted,
                                lineSpacing: 1.2,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    pw.Container(
                      width: 0.8,
                      height: 14,
                      color: borderColor,
                      margin: const pw.EdgeInsets.symmetric(horizontal: 4),
                    ),
                    pw.SizedBox(
                      width: 50,
                      child: pw.Text(
                        item.quantity == item.quantity.roundToDouble()
                            ? item.quantity.toInt().toString()
                            : item.quantity.toString(),
                        textAlign: pw.TextAlign.center,
                        style: pw.TextStyle(fontSize: 9, color: textDark),
                      ),
                    ),
                    pw.Container(
                      width: 0.8,
                      height: 14,
                      color: borderColor,
                      margin: const pw.EdgeInsets.symmetric(horizontal: 4),
                    ),
                    pw.SizedBox(
                      width: 60,
                      child: pw.Text(
                        CurrencyFormatter.format(item.unitPrice,
                            symbol: currency),
                        textAlign: pw.TextAlign.center,
                        style: pw.TextStyle(fontSize: 9, color: textDark),
                      ),
                    ),
                    pw.Container(
                      width: 0.8,
                      height: 14,
                      color: borderColor,
                      margin: const pw.EdgeInsets.symmetric(horizontal: 4),
                    ),
                    pw.SizedBox(
                      width: 55,
                      child: pw.Text(
                        item.discountPercent > 0
                            ? '${item.discountPercent.toStringAsFixed(0)}%'
                            : '-',
                        textAlign: pw.TextAlign.center,
                        style: pw.TextStyle(fontSize: 9, color: textDark),
                      ),
                    ),
                    pw.Container(
                      width: 0.8,
                      height: 14,
                      color: borderColor,
                      margin: const pw.EdgeInsets.symmetric(horizontal: 4),
                    ),
                    pw.SizedBox(
                      width: 75,
                      child: pw.Text(
                        CurrencyFormatter.format(item.lineTotal,
                            symbol: currency),
                        textAlign: pw.TextAlign.center,
                        style: pw.TextStyle(
                          fontSize: 9,
                          fontWeight: pw.FontWeight.bold,
                          color: textDark,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
      pw.SizedBox(height: 16),

      // Bottom Section: Left Notes/Terms + Right Totals Table
      pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          // Left: Quotation Closing & Terms
          pw.Expanded(
            flex: 5,
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'Many thanks for your custom! We look forward to doing business with you.',
                  style: const pw.TextStyle(
                    fontSize: 8.5,
                    color: textDark,
                    lineSpacing: 1.25,
                  ),
                ),
                pw.SizedBox(height: 8),
                pw.Text(
                  doc.terms?.isNotEmpty == true
                      ? 'Quotation terms: ${doc.terms!}'
                      : 'Quotation terms: Valid up to 15 days from issue date.',
                  style: pw.TextStyle(
                    fontSize: 8.5,
                    fontWeight: pw.FontWeight.bold,
                    color: textDark,
                    lineSpacing: 1.25,
                  ),
                ),
              ],
            ),
          ),

          pw.SizedBox(width: 18),

          // Right: Totals Box & Signature
          pw.Expanded(
            flex: 4,
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.stretch,
              children: [
                // Totals Box
                pw.Container(
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: borderColor, width: 0.8),
                  ),
                  child: pw.Column(
                    children: [
                      // Subtotal
                      pw.Container(
                        padding: const pw.EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: pw.BoxDecoration(
                          border: pw.Border(
                            bottom: pw.BorderSide(
                                color: borderColor, width: 0.8),
                          ),
                        ),
                        child: pw.Row(
                          children: [
                            pw.Expanded(
                              child: pw.Text(
                                'Sub Total',
                                textAlign: pw.TextAlign.center,
                                style: pw.TextStyle(
                                  fontSize: 9.5,
                                  fontWeight: pw.FontWeight.bold,
                                  color: textDark,
                                ),
                              ),
                            ),
                            pw.Container(
                              width: 0.8,
                              height: 12,
                              color: borderColor,
                            ),
                            pw.Expanded(
                              child: pw.Text(
                                CurrencyFormatter.format(doc.subtotal,
                                    symbol: currency),
                                textAlign: pw.TextAlign.center,
                                style: pw.TextStyle(
                                  fontSize: 9.5,
                                  fontWeight: pw.FontWeight.bold,
                                  color: textDark,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Discount
                      if ((doc.overallDiscountAmount +
                              doc.itemDiscountsTotal) >
                          0)
                        pw.Container(
                          padding: const pw.EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: pw.BoxDecoration(
                            border: pw.Border(
                              bottom: pw.BorderSide(
                                  color: borderColor, width: 0.8),
                            ),
                          ),
                          child: pw.Row(
                            children: [
                              pw.Expanded(
                                child: pw.Text(
                                  'Discount',
                                  textAlign: pw.TextAlign.center,
                                  style: pw.TextStyle(
                                    fontSize: 9.5,
                                    fontWeight: pw.FontWeight.bold,
                                    color: textDark,
                                  ),
                                ),
                              ),
                              pw.Container(
                                width: 0.8,
                                height: 12,
                                color: borderColor,
                              ),
                              pw.Expanded(
                                child: pw.Text(
                                  '-${CurrencyFormatter.format(doc.overallDiscountAmount + doc.itemDiscountsTotal, symbol: currency)}',
                                  textAlign: pw.TextAlign.center,
                                  style: pw.TextStyle(
                                    fontSize: 9.5,
                                    fontWeight: pw.FontWeight.bold,
                                    color: textDark,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                      // Total Amount (Cyan Background, White Text)
                      pw.Container(
                        color: cyanPrimary,
                        padding: const pw.EdgeInsets.symmetric(
                            horizontal: 8, vertical: 5),
                        child: pw.Row(
                          children: [
                            pw.Expanded(
                              child: pw.Text(
                                'Total Amount',
                                textAlign: pw.TextAlign.center,
                                style: pw.TextStyle(
                                  fontSize: 10,
                                  fontWeight: pw.FontWeight.bold,
                                  color: PdfColors.white,
                                ),
                              ),
                            ),
                            pw.Container(
                              width: 0.8,
                              height: 12,
                              color: PdfColors.white,
                            ),
                            pw.Expanded(
                              child: pw.Text(
                                CurrencyFormatter.format(doc.totalAmount,
                                    symbol: currency),
                                textAlign: pw.TextAlign.center,
                                style: pw.TextStyle(
                                  fontSize: 10,
                                  fontWeight: pw.FontWeight.bold,
                                  color: PdfColors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),

      pw.Spacer(),

      // Bottom Row: Payment Details (Left) + Total In Words & Signature (Right)
      pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.end,
        children: [
          pw.Expanded(
            flex: 5,
            child: doc.includePaymentDetails
                ? _buildPaymentDetails(
                    doc,
                    payments,
                    profile,
                    primaryColor: cyanPrimary,
                  )
                : pw.SizedBox(),
          ),
          pw.SizedBox(width: 18),
          pw.Expanded(
            flex: 4,
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.stretch,
              children: [
                pw.Text(
                  'Invoice Total In Words:',
                  style: pw.TextStyle(fontSize: 8, color: textMuted),
                ),
                pw.SizedBox(height: 2),
                pw.Text(
                  totalInWords,
                  style: pw.TextStyle(
                    fontSize: 9,
                    fontWeight: pw.FontWeight.bold,
                    color: textDark,
                  ),
                ),
                pw.SizedBox(height: 14),
                pw.Center(
                  child: pw.Column(
                    children: [
                      if (signatureBytes != null && doc.showSignature)
                        pw.Container(
                          height: 38,
                          child: pw.Image(
                            pw.MemoryImage(signatureBytes),
                            fit: pw.BoxFit.contain,
                          ),
                        )
                      else
                        pw.Text(
                          'Authorized',
                          style: pw.TextStyle(
                            fontSize: 18,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColor.fromHex('#1E3A8A'),
                          ),
                        ),
                      pw.SizedBox(height: 2),
                      pw.Text(
                        'Authorized Signature',
                        style: pw.TextStyle(fontSize: 8.5, color: textDark),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),

      pw.SizedBox(height: 14),

      // Full Width Enquiry Box
      pw.Container(
        padding:
            const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: pw.BoxDecoration(
          border: pw.Border.all(color: borderColor, width: 0.8),
        ),
        child: pw.Center(
          child: pw.RichText(
            textAlign: pw.TextAlign.center,
            text: pw.TextSpan(
              style: pw.TextStyle(fontSize: 9, color: textDark),
              children: [
                const pw.TextSpan(text: 'For any enquiries, email us on '),
                pw.TextSpan(
                  text: profile.email?.isNotEmpty == true
                      ? profile.email!
                      : 'info@foobarlabs.com',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                ),
                const pw.TextSpan(text: ' or call us on '),
                pw.TextSpan(
                  text: profile.phone?.isNotEmpty == true
                      ? profile.phone!
                      : '+91 98765-43210',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                ),
              ],
            ),
          ),
        ),
      ),
    ];
  }

  static List<pw.Widget> _buildWarmQuotation(
    pw.Context context,
    DocumentModel doc,
    BusinessProfile profile, {
    required List<PaymentDetail> payments,
    Uint8List? logoBytes,
    Uint8List? signatureBytes,
    Uint8List? stampBytes,
  }) {
    String currency = profile.currencySymbol.isNotEmpty
        ? profile.currencySymbol
        : 'Rs.';
    if (currency == '\u20B9') {
      currency = 'Rs.';
    }

    final primaryOrange = PdfColor.fromHex('#F26522');
    final creamBg = PdfColor.fromHex('#FFF4EC');
    final textDark = PdfColor.fromHex('#1E293B');
    final textMuted = PdfColor.fromHex('#64748B');
    final greenColor = PdfColor.fromHex('#16A34A');

    final cName = doc.customerSnapshot?.name ?? 'Valued Customer';
    final cAddress = doc.customerSnapshot?.billingAddress ?? '';
    final cGstin = doc.customerSnapshot?.gstin ?? '';
    String cPan = '';
    if (cGstin.length == 15) {
      cPan = cGstin.substring(2, 12);
    } else if (doc.customerSnapshot?.cin?.isNotEmpty == true) {
      cPan = doc.customerSnapshot!.cin!;
    }

    final bAddress = profile.address?.trim() ?? '';
    final bGstin = profile.gstin?.trim() ?? '';
    final bPan = profile.pan?.trim() ?? '';

    String placeOfSupply = 'Karnataka';
    if (bAddress.isNotEmpty) {
      final parts = bAddress.split(RegExp(r'[\n,]'));
      final nonEmpty = parts
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();
      if (nonEmpty.isNotEmpty) {
        placeOfSupply = nonEmpty.last;
      }
    }
    const countryOfSupply = 'India';

    String totalInWords = '';
    try {
      totalInWords = CurrencyFormatter.toWords(doc.totalAmount);
    } catch (_) {
      totalInWords = '${doc.totalAmount.toStringAsFixed(2)} $currency';
    }

    int itemIndex = 0;

    return [
      // Top Title
      pw.Center(
        child: pw.Text(
          doc.docType.displayName,
          style: pw.TextStyle(
            fontSize: 24,
            fontWeight: pw.FontWeight.bold,
            color: primaryOrange,
          ),
        ),
      ),
      pw.SizedBox(height: 16),

      // Header Row
      pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        crossAxisAlignment: pw.CrossAxisAlignment.center,
        children: [
          // Business Logo/Name
          if (logoBytes != null)
            pw.Container(
              height: 40,
              width: 120,
              alignment: pw.Alignment.centerLeft,
              child: pw.Image(
                pw.MemoryImage(logoBytes),
                fit: pw.BoxFit.contain,
              ),
            )
          else
            pw.Row(
              children: [
                pw.Container(
                  width: 34,
                  height: 34,
                  decoration: const pw.BoxDecoration(
                    color: PdfColors.black,
                    borderRadius: pw.BorderRadius.all(pw.Radius.circular(4)),
                  ),
                  child: pw.Center(
                    child: pw.Text(
                      profile.businessName.isNotEmpty
                          ? profile.businessName[0].toUpperCase()
                          : 'Q',
                      style: pw.TextStyle(
                        color: PdfColors.white,
                        fontSize: 20,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                pw.SizedBox(width: 8),
                pw.Text(
                  profile.businessName.toUpperCase(),
                  style: pw.TextStyle(
                    fontSize: 16,
                    fontWeight: pw.FontWeight.bold,
                    color: textDark,
                    letterSpacing: 0.8,
                  ),
                ),
              ],
            ),

          // Quotation# and Date
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.Row(
                mainAxisSize: pw.MainAxisSize.min,
                children: [
                  pw.Text(
                    '${doc.docType.displayName}#',
                    style: pw.TextStyle(fontSize: 10, color: textMuted),
                  ),
                  pw.SizedBox(width: 14),
                  pw.Text(
                    doc.docNumber,
                    style: pw.TextStyle(
                      fontSize: 11,
                      fontWeight: pw.FontWeight.bold,
                      color: textDark,
                    ),
                  ),
                ],
              ),
              pw.SizedBox(height: 4),
              pw.Row(
                mainAxisSize: pw.MainAxisSize.min,
                children: [
                  pw.Text(
                    doc.docType == DocumentType.receipt
                        ? 'Payment Date'
                        : '${doc.docType.displayName} Date',
                    style: pw.TextStyle(fontSize: 10, color: textMuted),
                  ),
                  pw.SizedBox(width: 14),
                  pw.Text(
                    DateFormatter.format(doc.issueDate),
                    style: pw.TextStyle(
                      fontSize: 11,
                      fontWeight: pw.FontWeight.bold,
                      color: textDark,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
      pw.SizedBox(height: 16),

      // Two Info Cards
      pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          // Left Card: Quotation by
          pw.Expanded(
            child: pw.Container(
              padding: const pw.EdgeInsets.all(10),
              decoration: pw.BoxDecoration(
                color: creamBg,
                borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    '${doc.docType.displayName} by',
                    style: pw.TextStyle(
                      fontSize: 11,
                      fontWeight: pw.FontWeight.bold,
                      color: primaryOrange,
                    ),
                  ),
                  pw.SizedBox(height: 4),
                  pw.Text(
                    profile.businessName,
                    style: pw.TextStyle(
                      fontSize: 10.5,
                      fontWeight: pw.FontWeight.bold,
                      color: textDark,
                    ),
                  ),
                  if (bAddress.isNotEmpty) ...[
                    pw.SizedBox(height: 2),
                    pw.Text(
                      bAddress,
                      style: pw.TextStyle(
                        fontSize: 9.5,
                        color: textDark,
                        lineSpacing: 1.2,
                      ),
                    ),
                  ],
                  if (bGstin.isNotEmpty) ...[
                    pw.SizedBox(height: 4),
                    pw.Row(
                      children: [
                        pw.Text(
                          'GSTIN  ',
                          style: pw.TextStyle(
                            fontSize: 9,
                            fontWeight: pw.FontWeight.bold,
                            color: textDark,
                          ),
                        ),
                        pw.Text(
                          bGstin,
                          style: pw.TextStyle(fontSize: 9, color: textDark),
                        ),
                      ],
                    ),
                  ],
                  if (bPan.isNotEmpty) ...[
                    pw.Row(
                      children: [
                        pw.Text(
                          'PAN    ',
                          style: pw.TextStyle(
                            fontSize: 9,
                            fontWeight: pw.FontWeight.bold,
                            color: textDark,
                          ),
                        ),
                        pw.Text(
                          bPan,
                          style: pw.TextStyle(fontSize: 9, color: textDark),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
          pw.SizedBox(width: 14),

          // Right Card: Quotation to
          pw.Expanded(
            child: pw.Container(
              padding: const pw.EdgeInsets.all(10),
              decoration: pw.BoxDecoration(
                color: creamBg,
                borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    '${doc.docType.displayName} to',
                    style: pw.TextStyle(
                      fontSize: 11,
                      fontWeight: pw.FontWeight.bold,
                      color: primaryOrange,
                    ),
                  ),
                  pw.SizedBox(height: 4),
                  pw.Text(
                    cName,
                    style: pw.TextStyle(
                      fontSize: 10.5,
                      fontWeight: pw.FontWeight.bold,
                      color: textDark,
                    ),
                  ),
                  if (cAddress.isNotEmpty) ...[
                    pw.SizedBox(height: 2),
                    pw.Text(
                      cAddress,
                      style: pw.TextStyle(
                        fontSize: 9.5,
                        color: textDark,
                        lineSpacing: 1.2,
                      ),
                    ),
                  ],
                  if (cGstin.isNotEmpty) ...[
                    pw.SizedBox(height: 4),
                    pw.Row(
                      children: [
                        pw.Text(
                          'GSTIN  ',
                          style: pw.TextStyle(
                            fontSize: 9,
                            fontWeight: pw.FontWeight.bold,
                            color: textDark,
                          ),
                        ),
                        pw.Text(
                          cGstin,
                          style: pw.TextStyle(fontSize: 9, color: textDark),
                        ),
                      ],
                    ),
                  ],
                  if (cPan.isNotEmpty) ...[
                    pw.Row(
                      children: [
                        pw.Text(
                          'PAN    ',
                          style: pw.TextStyle(
                            fontSize: 9,
                            fontWeight: pw.FontWeight.bold,
                            color: textDark,
                          ),
                        ),
                        pw.Text(
                          cPan,
                          style: pw.TextStyle(fontSize: 9, color: textDark),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
      pw.SizedBox(height: 10),

      // Supply Row
      pw.Padding(
        padding: const pw.EdgeInsets.symmetric(horizontal: 4),
        child: pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Row(
              children: [
                pw.Text(
                  'Place of Supply    ',
                  style: pw.TextStyle(fontSize: 9.5, color: textMuted),
                ),
                pw.Text(
                  placeOfSupply,
                  style: pw.TextStyle(
                    fontSize: 9.5,
                    fontWeight: pw.FontWeight.bold,
                    color: textDark,
                  ),
                ),
              ],
            ),
            pw.Row(
              children: [
                pw.Text(
                  'Country of Supply    ',
                  style: pw.TextStyle(fontSize: 9.5, color: textMuted),
                ),
                pw.Text(
                  countryOfSupply,
                  style: pw.TextStyle(
                    fontSize: 9.5,
                    fontWeight: pw.FontWeight.bold,
                    color: textDark,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      pw.SizedBox(height: 10),

      // Quotation Intro Message (Top of Table)
      pw.Padding(
        padding: const pw.EdgeInsets.symmetric(horizontal: 4),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              'Dear ${cName.isNotEmpty ? cName : "Valued Client"},',
              style: pw.TextStyle(
                fontSize: 9.5,
                fontWeight: pw.FontWeight.bold,
                color: textDark,
              ),
            ),
            pw.SizedBox(height: 2),
            pw.Text(
              'Please find below a cost-breakdown for the quotation. Please consider this, and do not hesitate to contact us with any questions.',
              style: const pw.TextStyle(
                fontSize: 8.5,
                color: textDark,
                lineSpacing: 1.25,
              ),
            ),
            pw.SizedBox(height: 2),
            pw.Text(
              'Many thanks,',
              style: const pw.TextStyle(fontSize: 8.5, color: textDark),
            ),
            pw.Text(
              profile.businessName.isNotEmpty
                  ? profile.businessName
                  : 'Acme Innovations',
              style: pw.TextStyle(
                fontSize: 9,
                fontWeight: pw.FontWeight.bold,
                color: textDark,
              ),
            ),
          ],
        ),
      ),
      pw.SizedBox(height: 10),

      // Table Header
      pw.Container(
        decoration: pw.BoxDecoration(
          color: primaryOrange,
          borderRadius: const pw.BorderRadius.only(
            topLeft: pw.Radius.circular(4),
            topRight: pw.Radius.circular(4),
          ),
        ),
        padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        child: pw.Row(
          children: [
            pw.Expanded(
              flex: 5,
              child: pw.Text(
                'Item #/Item description',
                style: pw.TextStyle(
                  fontSize: 10,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.white,
                ),
              ),
            ),
            pw.Expanded(
              flex: 1,
              child: pw.Text(
                'Qty.',
                textAlign: pw.TextAlign.center,
                style: pw.TextStyle(
                  fontSize: 10,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.white,
                ),
              ),
            ),
            pw.Expanded(
              flex: 2,
              child: pw.Text(
                'Rate',
                textAlign: pw.TextAlign.right,
                style: pw.TextStyle(
                  fontSize: 10,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.white,
                ),
              ),
            ),
            pw.Expanded(
              flex: 2,
              child: pw.Text(
                'Amount',
                textAlign: pw.TextAlign.right,
                style: pw.TextStyle(
                  fontSize: 10,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.white,
                ),
              ),
            ),
          ],
        ),
      ),

      // Alternating Rows
      ...doc.items.map((item) {
        itemIndex++;
        final isEven = itemIndex % 2 == 0;
        final rowBg = isEven ? creamBg : PdfColors.white;
        return pw.Container(
          color: rowBg,
          padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          child: pw.Row(
            children: [
              pw.Expanded(
                flex: 5,
                child: pw.Text(
                  '$itemIndex. ${item.title}',
                  style: pw.TextStyle(fontSize: 9.5, color: textDark),
                ),
              ),
              pw.Expanded(
                flex: 1,
                child: pw.Text(
                  item.quantity.toString(),
                  textAlign: pw.TextAlign.center,
                  style: pw.TextStyle(fontSize: 9.5, color: textDark),
                ),
              ),
              pw.Expanded(
                flex: 2,
                child: pw.Text(
                  CurrencyFormatter.format(item.unitPrice, symbol: currency),
                  textAlign: pw.TextAlign.right,
                  style: pw.TextStyle(fontSize: 9.5, color: textDark),
                ),
              ),
              pw.Expanded(
                flex: 2,
                child: pw.Text(
                  CurrencyFormatter.format(item.lineTotal, symbol: currency),
                  textAlign: pw.TextAlign.right,
                  style: pw.TextStyle(fontSize: 9.5, color: textDark),
                ),
              ),
            ],
          ),
        );
      }),
      pw.SizedBox(height: 18),

      // Middle section: Quotation Terms on Left, Summary on Right
      pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          // Left: Quotation Closing & Terms
          pw.Expanded(
            flex: 5,
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'Many thanks for your custom! We look forward to doing business with you.',
                  style: const pw.TextStyle(
                    fontSize: 9,
                    color: textDark,
                    lineSpacing: 1.3,
                  ),
                ),
                pw.SizedBox(height: 8),
                pw.Text(
                  doc.terms?.isNotEmpty == true
                      ? 'Quotation terms: ${doc.terms!}'
                      : 'Quotation terms: Valid up to 15 days from issue date.',
                  style: pw.TextStyle(
                    fontSize: 9,
                    fontWeight: pw.FontWeight.bold,
                    color: textDark,
                    lineSpacing: 1.3,
                  ),
                ),
              ],
            ),
          ),
          pw.SizedBox(width: 20),

          // Right: Summary
          pw.Expanded(
            flex: 4,
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.stretch,
              children: [
                // Subtotal
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      'Sub Total',
                      style: pw.TextStyle(fontSize: 11, color: textDark),
                    ),
                    pw.Text(
                      CurrencyFormatter.format(doc.subtotal, symbol: currency),
                      style: pw.TextStyle(fontSize: 11, color: textDark),
                    ),
                  ],
                ),
                if (doc.overallDiscountAmount > 0) ...[
                  pw.SizedBox(height: 4),
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text(
                        'Discount',
                        style: pw.TextStyle(
                          fontSize: 11,
                          fontWeight: pw.FontWeight.bold,
                          color: greenColor,
                        ),
                      ),
                      pw.Text(
                        '-${CurrencyFormatter.format(doc.overallDiscountAmount, symbol: currency)}',
                        style: pw.TextStyle(
                          fontSize: 11,
                          fontWeight: pw.FontWeight.bold,
                          color: greenColor,
                        ),
                      ),
                    ],
                  ),
                ],
                if (doc.totalTaxAmount > 0) ...[
                  pw.SizedBox(height: 4),
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text(
                        'Tax',
                        style: pw.TextStyle(fontSize: 11, color: textDark),
                      ),
                      pw.Text(
                        CurrencyFormatter.format(
                          doc.totalTaxAmount,
                          symbol: currency,
                        ),
                        style: pw.TextStyle(fontSize: 11, color: textDark),
                      ),
                    ],
                  ),
                ],
                pw.SizedBox(height: 8),

                // Total
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Text(
                      'Total',
                      style: pw.TextStyle(
                        fontSize: 14,
                        fontWeight: pw.FontWeight.bold,
                        color: textDark,
                      ),
                    ),
                    pw.Text(
                      CurrencyFormatter.format(
                        doc.totalAmount,
                        symbol: currency,
                      ),
                      style: pw.TextStyle(
                        fontSize: 16,
                        fontWeight: pw.FontWeight.bold,
                        color: textDark,
                      ),
                    ),
                  ],
                ),
                pw.SizedBox(height: 6),

                // In words
                pw.Text(
                  '${doc.docType.displayName} Total (in words)',
                  style: pw.TextStyle(fontSize: 8, color: textMuted),
                ),
                pw.SizedBox(height: 1),
                pw.Text(
                  totalInWords,
                  style: pw.TextStyle(
                    fontSize: 9.5,
                    fontWeight: pw.FontWeight.bold,
                    color: textDark,
                  ),
                ),
                pw.SizedBox(height: 6),
                pw.Container(height: 0.8, color: PdfColor.fromHex('#E2E8F0')),
              ],
            ),
          ),
        ],
      ),

      pw.Spacer(),

      // Bottom Row: Payment Details on Left, Signature on Right
      pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.end,
        children: [
          pw.Expanded(
            flex: 5,
            child: doc.includePaymentDetails
                ? _buildPaymentDetails(
                    doc,
                    payments,
                    profile,
                    primaryColor: primaryOrange,
                  )
                : pw.SizedBox(),
          ),
          pw.SizedBox(width: 20),
          pw.Expanded(
            flex: 4,
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.end,
              crossAxisAlignment: pw.CrossAxisAlignment.end,
              children: [
                if (stampBytes != null && doc.showStamp)
                  pw.Padding(
                    padding: const pw.EdgeInsets.only(right: 14),
                    child: pw.Column(
                      children: [
                        pw.Container(
                          height: 38,
                          child: pw.Image(
                            pw.MemoryImage(stampBytes),
                            fit: pw.BoxFit.contain,
                          ),
                        ),
                        pw.SizedBox(height: 2),
                        pw.Text(
                          'Company Stamp',
                          style: pw.TextStyle(
                            fontSize: 8,
                            color: textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                if (signatureBytes != null && doc.showSignature)
                  pw.Column(
                    children: [
                      pw.Container(
                        height: 38,
                        child: pw.Image(
                          pw.MemoryImage(signatureBytes),
                          fit: pw.BoxFit.contain,
                        ),
                      ),
                      pw.SizedBox(height: 2),
                      pw.Text(
                        'Authorized Signature',
                        style: pw.TextStyle(fontSize: 8, color: textMuted),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),

      pw.SizedBox(height: 14),

      // Bottom Enquiry Banner
      if (profile.email?.isNotEmpty == true ||
          profile.phone?.isNotEmpty == true)
        pw.Container(
          padding: const pw.EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: pw.BoxDecoration(
            color: PdfColor.fromHex('#FFF7ED'),
            borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
          ),
          child: pw.Center(
            child: pw.RichText(
              text: pw.TextSpan(
                style: pw.TextStyle(fontSize: 9, color: textDark),
                children: [
                  const pw.TextSpan(text: 'For any enquiries, email us on '),
                  pw.TextSpan(
                    text: profile.email ?? '',
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  ),
                  const pw.TextSpan(text: ' or call us on '),
                  pw.TextSpan(
                    text: profile.phone ?? '',
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
        ),
    ];
  }

  static List<pw.Widget> _buildReceiptThermal(
    pw.Context context,
    DocumentModel doc,
    BusinessProfile profile, {
    required List<PaymentDetail> payments,
    Uint8List? logoBytes,
    Uint8List? signatureBytes,
    Uint8List? stampBytes,
  }) {
    String currency = profile.currencySymbol.isNotEmpty
        ? profile.currencySymbol
        : 'Rs.';
    if (currency == '\u20B9') {
      currency = 'Rs.';
    }
    final courier = pw.Font.courier();
    final courierBold = pw.Font.courierBold();

    pw.Widget dottedLine() => pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 4),
      child: pw.Text(
        '.' * 34,
        maxLines: 1,
        textAlign: pw.TextAlign.center,
        style: pw.TextStyle(
          font: courierBold,
          fontSize: 10,
          color: PdfColors.black,
          letterSpacing: 2,
        ),
      ),
    );

    pw.Widget sawtoothLine() => pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2),
      child: pw.CustomPaint(
        size: const PdfPoint(312, 6),
        painter: (PdfGraphics canvas, PdfPoint size) {
          const double toothWidth = 8.0;
          const double toothHeight = 5.0;
          final int teeth = (size.x / toothWidth).ceil();
          final double actualToothWidth = size.x / teeth;
          canvas.setColor(PdfColor.fromHex('#94A3B8'));
          canvas.setLineWidth(0.8);
          for (int i = 0; i < teeth; i++) {
            final double x = i * actualToothWidth;
            canvas.moveTo(x, 0);
            canvas.lineTo(x + actualToothWidth / 2, toothHeight);
            canvas.lineTo(x + actualToothWidth, 0);
            canvas.strokePath();
          }
        },
      ),
    );

    final bName = profile.businessName.isNotEmpty
        ? profile.businessName
        : 'BUSINESS NAME';
    final address = profile.address?.trim() ?? '';
    final phone = profile.phone?.trim() ?? '';

    String paidBy = 'Credit';
    if (doc.payments.isNotEmpty) {
      paidBy = doc.payments.first.paymentMethod;
    } else if (doc.totalPaid >= doc.totalAmount && doc.totalAmount > 0) {
      paidBy = 'Paid in Full';
    }

    return [
      sawtoothLine(),
      pw.SizedBox(height: 6),
      pw.Container(
        padding: const pw.EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.stretch,
          children: [
            if (logoBytes != null) ...[
              pw.Center(
                child: pw.Container(
                  height: 40,
                  child: pw.Image(
                    pw.MemoryImage(logoBytes),
                    fit: pw.BoxFit.contain,
                  ),
                ),
              ),
              pw.SizedBox(height: 8),
            ],
            pw.Text(
              bName.toUpperCase(),
              textAlign: pw.TextAlign.center,
              style: pw.TextStyle(
                font: courierBold,
                fontSize: 16,
                fontWeight: pw.FontWeight.bold,
                letterSpacing: 1.0,
              ),
            ),
            pw.SizedBox(height: 4),
            if (address.isNotEmpty)
              pw.Text(
                address,
                textAlign: pw.TextAlign.center,
                style: pw.TextStyle(font: courier, fontSize: 9.5, height: 1.2),
              ),
            if (phone.isNotEmpty)
              pw.Text(
                phone,
                textAlign: pw.TextAlign.center,
                style: pw.TextStyle(font: courier, fontSize: 9.5),
              ),
            pw.SizedBox(height: 10),

            dottedLine(),
            pw.SizedBox(height: 6),

            ...doc.items.map((item) {
              final itemTitle = item.quantity > 1
                  ? '${item.quantity.toInt()}x ${item.title}'
                  : item.title;
              final itemPrice = CurrencyFormatter.format(
                item.lineTotal,
                symbol: currency,
              );
              return pw.Padding(
                padding: const pw.EdgeInsets.symmetric(vertical: 2.5),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Expanded(
                      child: pw.Text(
                        itemTitle,
                        style: pw.TextStyle(font: courier, fontSize: 9.5),
                      ),
                    ),
                    pw.SizedBox(width: 8),
                    pw.Text(
                      itemPrice,
                      style: pw.TextStyle(font: courier, fontSize: 9.5),
                    ),
                  ],
                ),
              );
            }),

            pw.SizedBox(height: 10),

            pw.Padding(
              padding: const pw.EdgeInsets.symmetric(vertical: 2),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'Sub Total',
                    style: pw.TextStyle(font: courier, fontSize: 9.5),
                  ),
                  pw.Text(
                    CurrencyFormatter.format(doc.subtotal, symbol: currency),
                    style: pw.TextStyle(font: courier, fontSize: 9.5),
                  ),
                ],
              ),
            ),

            if (doc.totalTaxAmount > 0)
              pw.Padding(
                padding: const pw.EdgeInsets.symmetric(vertical: 2),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      'Sales Tax',
                      style: pw.TextStyle(font: courier, fontSize: 9.5),
                    ),
                    pw.Text(
                      CurrencyFormatter.format(
                        doc.totalTaxAmount,
                        symbol: currency,
                      ),
                      style: pw.TextStyle(font: courier, fontSize: 9.5),
                    ),
                  ],
                ),
              ),

            if ((doc.overallDiscountAmount + doc.itemDiscountsTotal) > 0)
              pw.Padding(
                padding: const pw.EdgeInsets.symmetric(vertical: 2),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      'Discount',
                      style: pw.TextStyle(font: courier, fontSize: 9.5),
                    ),
                    pw.Text(
                      '-${CurrencyFormatter.format(doc.overallDiscountAmount + doc.itemDiscountsTotal, symbol: currency)}',
                      style: pw.TextStyle(font: courier, fontSize: 9.5),
                    ),
                  ],
                ),
              ),

            pw.SizedBox(height: 6),
            dottedLine(),
            pw.SizedBox(height: 6),

            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  'TOTAL',
                  style: pw.TextStyle(
                    font: courierBold,
                    fontSize: 15,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.Text(
                  CurrencyFormatter.format(doc.totalAmount, symbol: currency),
                  style: pw.TextStyle(
                    font: courierBold,
                    fontSize: 15,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ],
            ),

            pw.SizedBox(height: 6),
            dottedLine(),
            pw.SizedBox(height: 6),

            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  'Paid By:',
                  style: pw.TextStyle(font: courier, fontSize: 10),
                ),
                pw.Text(
                  paidBy,
                  style: pw.TextStyle(font: courier, fontSize: 10),
                ),
              ],
            ),

            pw.SizedBox(height: 12),

            pw.Text(
              'Payment Date: ${DateFormatter.format(doc.issueDate)}',
              style: pw.TextStyle(font: courier, fontSize: 9),
            ),
            pw.Text(
              'Transaction ID: ${doc.docNumber}',
              style: pw.TextStyle(font: courier, fontSize: 9),
            ),
            if (profile.gstin != null && profile.gstin!.isNotEmpty)
              pw.Text(
                'Vendor ID: ${profile.gstin!}',
                style: pw.TextStyle(font: courier, fontSize: 9),
              )
            else if (profile.pan != null && profile.pan!.isNotEmpty)
              pw.Text(
                'Vendor ID: ${profile.pan!}',
                style: pw.TextStyle(font: courier, fontSize: 9),
              ),

            pw.SizedBox(height: 16),

            pw.Text(
              doc.notes?.isNotEmpty == true
                  ? doc.notes!
                  : 'Thank You For Supporting\nLocal Business!',
              textAlign: pw.TextAlign.center,
              style: pw.TextStyle(font: courier, fontSize: 10, height: 1.3),
            ),

            if (doc.showSignature && signatureBytes != null) ...[
              pw.SizedBox(height: 16),
              pw.Center(
                child: pw.Container(
                  height: 40,
                  child: pw.Image(pw.MemoryImage(signatureBytes)),
                ),
              ),
              pw.SizedBox(height: 4),
              pw.Text(
                'Authorized Signature',
                textAlign: pw.TextAlign.center,
                style: pw.TextStyle(font: courier, fontSize: 8),
              ),
            ],
          ],
        ),
      ),
      pw.SizedBox(height: 6),
      sawtoothLine(),
    ];
  }

  static List<pw.Widget> _buildFreeClassic(
    pw.Context context,
    DocumentModel doc,
    BusinessProfile profile, {
    required List<PaymentDetail> payments,
    Uint8List? logoBytes,
    Uint8List? signatureBytes,
    Uint8List? stampBytes,
  }) {
    final title = doc.docType.displayName.toUpperCase();
    final primaryColor = PdfColor.fromHex('#0F172A'); // Slate 900
    final secondaryColor = PdfColor.fromHex('#475569'); // Slate 600
    final mutedColor = PdfColor.fromHex('#64748B'); // Slate 500
    final borderColor = PdfColor.fromHex('#E2E8F0'); // Slate 200
    final bgLight = PdfColor.fromHex('#F8FAFC'); // Slate 50
    final badgeBg = PdfColor.fromHex('#F1F5F9'); // Slate 100

    final cName = doc.customerSnapshot?.name ?? 'Unknown Customer';
    final cEmail = doc.customerSnapshot?.email ?? '';
    final cPhone = doc.customerSnapshot?.phone ?? '';
    final cAddress = doc.customerSnapshot?.billingAddress ?? '';

    return [
      // Top Header
      pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Expanded(
            flex: 3,
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                if (logoBytes != null)
                  pw.Container(
                    height: 44,
                    width: 100,
                    alignment: pw.Alignment.centerLeft,
                    child: pw.Image(
                      pw.MemoryImage(logoBytes),
                      fit: pw.BoxFit.contain,
                    ),
                  ),
                pw.SizedBox(height: 8),
                pw.Text(
                  profile.businessName,
                  style: pw.TextStyle(
                    fontSize: 18,
                    fontWeight: pw.FontWeight.bold,
                    color: primaryColor,
                  ),
                ),
                pw.SizedBox(height: 4),
                if (profile.email != null && profile.email!.isNotEmpty)
                  pw.Text(
                    profile.email!,
                    style: pw.TextStyle(fontSize: 9.5, color: secondaryColor),
                  ),
                if (profile.phone != null && profile.phone!.isNotEmpty)
                  pw.Text(
                    profile.phone!,
                    style: pw.TextStyle(fontSize: 9.5, color: secondaryColor),
                  ),
                if (profile.address != null && profile.address!.isNotEmpty)
                  pw.Text(
                    profile.address!,
                    style: pw.TextStyle(fontSize: 9.5, color: secondaryColor),
                  ),
                if (profile.gstin != null && profile.gstin!.isNotEmpty)
                  pw.Text(
                    'GSTIN: ${profile.gstin!}',
                    style: pw.TextStyle(fontSize: 9.5, color: secondaryColor),
                  ),
              ],
            ),
          ),
          pw.Expanded(
            flex: 2,
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.end,
              children: [
                pw.Text(
                  title,
                  style: pw.TextStyle(
                    fontSize: 24,
                    fontWeight: pw.FontWeight.bold,
                    color: primaryColor,
                    letterSpacing: 1.5,
                  ),
                ),
                pw.SizedBox(height: 8),
                pw.Container(
                  padding: const pw.EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: pw.BoxDecoration(
                    color: badgeBg,
                    borderRadius: const pw.BorderRadius.all(
                      pw.Radius.circular(6),
                    ),
                    border: pw.Border.all(color: borderColor),
                  ),
                  child: pw.Text(
                    '# ${doc.docNumber}',
                    style: pw.TextStyle(
                      fontSize: 11,
                      fontWeight: pw.FontWeight.bold,
                      color: primaryColor,
                    ),
                  ),
                ),
                pw.SizedBox(height: 8),
                if (doc.docType == DocumentType.receipt)
                  pw.Row(
                    mainAxisSize: pw.MainAxisSize.min,
                    children: [
                      pw.Text(
                        'Payment Date: ',
                        style: pw.TextStyle(fontSize: 10, color: mutedColor),
                      ),
                      pw.Text(
                        DateFormatter.format(doc.issueDate),
                        style: pw.TextStyle(
                          fontSize: 10,
                          fontWeight: pw.FontWeight.bold,
                          color: primaryColor,
                        ),
                      ),
                    ],
                  )
                else ...[
                  pw.Row(
                    mainAxisSize: pw.MainAxisSize.min,
                    children: [
                      pw.Text(
                        'Issue Date: ',
                        style: pw.TextStyle(fontSize: 10, color: mutedColor),
                      ),
                      pw.Text(
                        DateFormatter.format(doc.issueDate),
                        style: pw.TextStyle(
                          fontSize: 10,
                          fontWeight: pw.FontWeight.bold,
                          color: primaryColor,
                        ),
                      ),
                    ],
                  ),
                  pw.SizedBox(height: 3),
                  pw.Row(
                    mainAxisSize: pw.MainAxisSize.min,
                    children: [
                      pw.Text(
                        doc.docType == DocumentType.proforma
                            ? 'Valid Until: '
                            : 'Due Date: ',
                        style: pw.TextStyle(fontSize: 10, color: mutedColor),
                      ),
                      pw.Text(
                        DateFormatter.format(doc.dueDate),
                        style: pw.TextStyle(
                          fontSize: 10,
                          fontWeight: pw.FontWeight.bold,
                          color: primaryColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),

      pw.SizedBox(height: 18),
      pw.Container(height: 1, color: borderColor),
      pw.SizedBox(height: 18),

      // Bill To & Total Due Card
      pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'BILLED TO',
                style: pw.TextStyle(
                  fontSize: 9,
                  fontWeight: pw.FontWeight.bold,
                  color: mutedColor,
                  letterSpacing: 1.0,
                ),
              ),
              pw.SizedBox(height: 4),
              pw.Text(
                cName,
                style: pw.TextStyle(
                  fontSize: 13,
                  fontWeight: pw.FontWeight.bold,
                  color: primaryColor,
                ),
              ),
              pw.SizedBox(height: 2),
              if (cEmail.isNotEmpty)
                pw.Text(
                  cEmail,
                  style: pw.TextStyle(fontSize: 9.5, color: secondaryColor),
                ),
              if (cPhone.isNotEmpty)
                pw.Text(
                  cPhone,
                  style: pw.TextStyle(fontSize: 9.5, color: secondaryColor),
                ),
              if (cAddress.isNotEmpty)
                pw.Text(
                  cAddress,
                  style: pw.TextStyle(fontSize: 9.5, color: secondaryColor),
                ),
            ],
          ),
          pw.Container(
            padding: const pw.EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: pw.BoxDecoration(
              color: bgLight,
              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
              border: pw.Border.all(color: borderColor),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.end,
              children: [
                pw.Text(
                  'TOTAL DUE',
                  style: pw.TextStyle(
                    fontSize: 8.5,
                    fontWeight: pw.FontWeight.bold,
                    color: mutedColor,
                  ),
                ),
                pw.SizedBox(height: 2),
                pw.Text(
                  CurrencyFormatter.format(doc.totalAmount, symbol: 'Rs.'),
                  style: pw.TextStyle(
                    fontSize: 15,
                    fontWeight: pw.FontWeight.bold,
                    color: primaryColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),

      pw.SizedBox(height: 22),

      // Table Header
      pw.Container(
        padding: const pw.EdgeInsets.symmetric(vertical: 8, horizontal: 10),
        decoration: pw.BoxDecoration(
          color: badgeBg,
          borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
          border: pw.Border.all(color: borderColor),
        ),
        child: pw.Row(
          children: [
            pw.Expanded(
              flex: 4,
              child: pw.Text(
                'DESCRIPTION',
                style: pw.TextStyle(
                  fontSize: 9,
                  fontWeight: pw.FontWeight.bold,
                  color: secondaryColor,
                ),
              ),
            ),
            pw.Expanded(
              flex: 1,
              child: pw.Align(
                alignment: pw.Alignment.center,
                child: pw.Text(
                  'QTY',
                  style: pw.TextStyle(
                    fontSize: 9,
                    fontWeight: pw.FontWeight.bold,
                    color: secondaryColor,
                  ),
                ),
              ),
            ),
            pw.Expanded(
              flex: 2,
              child: pw.Align(
                alignment: pw.Alignment.centerRight,
                child: pw.Text(
                  'UNIT PRICE',
                  style: pw.TextStyle(
                    fontSize: 9,
                    fontWeight: pw.FontWeight.bold,
                    color: secondaryColor,
                  ),
                ),
              ),
            ),
            pw.Expanded(
              flex: 1,
              child: pw.Align(
                alignment: pw.Alignment.centerRight,
                child: pw.Text(
                  'TAX',
                  style: pw.TextStyle(
                    fontSize: 9,
                    fontWeight: pw.FontWeight.bold,
                    color: secondaryColor,
                  ),
                ),
              ),
            ),
            pw.Expanded(
              flex: 2,
              child: pw.Align(
                alignment: pw.Alignment.centerRight,
                child: pw.Text(
                  'AMOUNT',
                  style: pw.TextStyle(
                    fontSize: 9,
                    fontWeight: pw.FontWeight.bold,
                    color: secondaryColor,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),

      // Table Items
      ...doc.items.map((item) {
        return pw.Container(
          padding: const pw.EdgeInsets.symmetric(vertical: 10, horizontal: 10),
          decoration: pw.BoxDecoration(
            border: pw.Border(bottom: pw.BorderSide(color: badgeBg)),
          ),
          child: pw.Row(
            children: [
              pw.Expanded(
                flex: 4,
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      item.title,
                      style: pw.TextStyle(
                        fontSize: 10.5,
                        fontWeight: pw.FontWeight.bold,
                        color: primaryColor,
                      ),
                    ),
                    if (item.description != null &&
                        item.description!.isNotEmpty)
                      pw.Padding(
                        padding: const pw.EdgeInsets.only(top: 2),
                        child: pw.Text(
                          item.description!,
                          style: pw.TextStyle(fontSize: 9, color: mutedColor),
                        ),
                      ),
                  ],
                ),
              ),
              pw.Expanded(
                flex: 1,
                child: pw.Align(
                  alignment: pw.Alignment.center,
                  child: pw.Text(
                    item.quantity.toString(),
                    style: pw.TextStyle(fontSize: 10, color: primaryColor),
                  ),
                ),
              ),
              pw.Expanded(
                flex: 2,
                child: pw.Align(
                  alignment: pw.Alignment.centerRight,
                  child: pw.Text(
                    CurrencyFormatter.format(item.unitPrice, symbol: 'Rs.'),
                    style: pw.TextStyle(fontSize: 10, color: primaryColor),
                  ),
                ),
              ),
              pw.Expanded(
                flex: 1,
                child: pw.Align(
                  alignment: pw.Alignment.centerRight,
                  child: pw.Text(
                    item.taxPercent > 0 ? '${item.taxPercent}%' : '-',
                    style: pw.TextStyle(fontSize: 10, color: secondaryColor),
                  ),
                ),
              ),
              pw.Expanded(
                flex: 2,
                child: pw.Align(
                  alignment: pw.Alignment.centerRight,
                  child: pw.Text(
                    CurrencyFormatter.format(item.lineTotal, symbol: 'Rs.'),
                    style: pw.TextStyle(
                      fontSize: 10.5,
                      fontWeight: pw.FontWeight.bold,
                      color: primaryColor,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      }),

      pw.SizedBox(height: 18),

      // Summary Card
      pw.Align(
        alignment: pw.Alignment.centerRight,
        child: pw.Container(
          width: 220,
          padding: const pw.EdgeInsets.all(12),
          decoration: pw.BoxDecoration(
            color: bgLight,
            borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
            border: pw.Border.all(color: borderColor),
          ),
          child: pw.Column(
            children: [
              _buildSummaryRow(
                'Subtotal',
                CurrencyFormatter.format(doc.subtotal, symbol: 'Rs.'),
                size: 10,
                color: secondaryColor,
              ),
              if (doc.totalTaxAmount > 0)
                _buildSummaryRow(
                  'Tax',
                  CurrencyFormatter.format(doc.totalTaxAmount, symbol: 'Rs.'),
                  size: 10,
                  color: secondaryColor,
                ),
              if ((doc.overallDiscountAmount + doc.itemDiscountsTotal) > 0)
                _buildSummaryRow(
                  'Discount',
                  '-${CurrencyFormatter.format(doc.overallDiscountAmount + doc.itemDiscountsTotal, symbol: 'Rs.')}',
                  size: 10,
                  color: secondaryColor,
                ),
              pw.SizedBox(height: 6),
              pw.Container(height: 1, color: borderColor),
              pw.SizedBox(height: 6),
              _buildSummaryRow(
                'Total',
                CurrencyFormatter.format(doc.totalAmount, symbol: 'Rs.'),
                isBold: true,
                size: 13,
                color: primaryColor,
              ),
              if (doc.totalPaid > 0) ...[
                pw.SizedBox(height: 4),
                _buildSummaryRow(
                  'Amount Paid',
                  CurrencyFormatter.format(doc.totalPaid, symbol: 'Rs.'),
                  size: 10,
                  color: secondaryColor,
                ),
                _buildSummaryRow(
                  'Balance Due',
                  CurrencyFormatter.format(doc.balanceDue, symbol: 'Rs.'),
                  isBold: true,
                  size: 11,
                  color: primaryColor,
                ),
              ],
            ],
          ),
        ),
      ),

      pw.SizedBox(height: 16),

      // Notes & Terms Callout
      if (doc.notes != null && doc.notes!.isNotEmpty)
        pw.Container(
          padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: pw.BoxDecoration(
            color: bgLight,
            border: pw.Border(left: pw.BorderSide(color: mutedColor, width: 3)),
          ),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'Notes & Terms:',
                style: pw.TextStyle(
                  fontSize: 9.5,
                  fontWeight: pw.FontWeight.bold,
                  color: primaryColor,
                ),
              ),
              pw.SizedBox(height: 2),
              pw.Text(
                doc.notes!,
                style: pw.TextStyle(fontSize: 9.5, color: secondaryColor),
              ),
            ],
          ),
        ),

      pw.Spacer(),

      // Payment Details & Signature
      pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        crossAxisAlignment: pw.CrossAxisAlignment.end,
        children: [
          pw.Expanded(
            child: _buildPaymentDetails(
              doc,
              payments,
              profile,
              primaryColor: primaryColor,
            ),
          ),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.end,
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              if (stampBytes != null && doc.showStamp)
                pw.Padding(
                  padding: const pw.EdgeInsets.only(right: 24),
                  child: pw.Column(
                    mainAxisAlignment: pw.MainAxisAlignment.end,
                    children: [
                      pw.Container(
                        width: 90,
                        height: 45,
                        alignment: pw.Alignment.bottomCenter,
                        child: pw.Image(
                          pw.MemoryImage(stampBytes),
                          fit: pw.BoxFit.contain,
                        ),
                      ),
                      pw.SizedBox(height: 6),
                      pw.Container(
                        width: 90,
                        child: pw.Divider(color: primaryColor, thickness: 1),
                      ),
                      pw.SizedBox(height: 4),
                      pw.Text(
                        'Company Stamp',
                        style: pw.TextStyle(fontSize: 10, color: primaryColor),
                      ),
                    ],
                  ),
                ),
              if (signatureBytes != null && doc.showSignature)
                pw.Column(
                  mainAxisAlignment: pw.MainAxisAlignment.end,
                  children: [
                    pw.Container(
                      width: 90,
                      height: 45,
                      alignment: pw.Alignment.bottomCenter,
                      child: pw.Image(
                        pw.MemoryImage(signatureBytes),
                        fit: pw.BoxFit.contain,
                      ),
                    ),
                    pw.SizedBox(height: 6),
                    pw.Container(
                      width: 90,
                      child: pw.Divider(color: primaryColor, thickness: 1),
                    ),
                    pw.SizedBox(height: 4),
                    pw.Text(
                      'Authorized Signature',
                      style: pw.TextStyle(fontSize: 10, color: primaryColor),
                    ),
                  ],
                ),
            ],
          ),
        ],
      ),
    ];
  }

  static List<pw.Widget> _buildPremiumModern(
    pw.Context context,
    DocumentModel doc,
    BusinessProfile profile, {
    required List<PaymentDetail> payments,
    Uint8List? logoBytes,
    Uint8List? signatureBytes,
    Uint8List? stampBytes,
  }) {
    final title = doc.docType.displayName.toUpperCase();
    final primaryColor = PdfColor.fromHex('#2563EB'); // Blue accent

    final cName = doc.customerSnapshot?.name ?? 'Unknown Customer';
    final cEmail = doc.customerSnapshot?.email ?? '';
    final cPhone = doc.customerSnapshot?.phone ?? '';
    final cAddress = doc.customerSnapshot?.billingAddress ?? '';

    return [
      pw.Container(
        padding: const pw.EdgeInsets.all(20),
        decoration: pw.BoxDecoration(
          color: primaryColor,
          borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
        ),
        child: pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  title,
                  style: pw.TextStyle(
                    fontSize: 28,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.white,
                  ),
                ),
                pw.SizedBox(height: 4),
                pw.Text(
                  '# ${doc.docNumber}',
                  style: const pw.TextStyle(
                    fontSize: 12,
                    color: PdfColors.white,
                  ),
                ),
              ],
            ),
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.end,
              children: [
                if (doc.docType == DocumentType.receipt)
                  pw.Text(
                    'Payment Date: ${DateFormatter.format(doc.issueDate)}',
                    style: const pw.TextStyle(
                      fontSize: 10,
                      color: PdfColors.white,
                    ),
                  )
                else ...[
                  pw.Text(
                    'Issue Date: ${DateFormatter.format(doc.issueDate)}',
                    style: const pw.TextStyle(
                      fontSize: 10,
                      color: PdfColors.white,
                    ),
                  ),
                  pw.Text(
                    doc.docType == DocumentType.proforma
                        ? 'Valid Until: ${DateFormatter.format(doc.dueDate)}'
                        : 'Due Date: ${DateFormatter.format(doc.dueDate)}',
                    style: const pw.TextStyle(
                      fontSize: 10,
                      color: PdfColors.white,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
      pw.SizedBox(height: 30),
      pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'FROM:',
                  style: pw.TextStyle(
                    fontSize: 10,
                    fontWeight: pw.FontWeight.bold,
                    color: primaryColor,
                  ),
                ),
                pw.SizedBox(height: 8),
                if (logoBytes != null)
                  pw.Container(
                    height: 40,
                    alignment: pw.Alignment.centerLeft,
                    child: pw.Image(pw.MemoryImage(logoBytes)),
                    margin: const pw.EdgeInsets.only(bottom: 8),
                  ),
                pw.Text(
                  profile.businessName,
                  style: pw.TextStyle(
                    fontSize: 12,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                if (profile.email != null && profile.email!.isNotEmpty)
                  pw.Text(
                    profile.email!,
                    style: const pw.TextStyle(fontSize: 10),
                  ),
                if (profile.phone != null && profile.phone!.isNotEmpty)
                  pw.Text(
                    profile.phone!,
                    style: const pw.TextStyle(fontSize: 10),
                  ),
                if (profile.address != null && profile.address!.isNotEmpty)
                  pw.Text(
                    profile.address!,
                    style: const pw.TextStyle(fontSize: 10),
                  ),
              ],
            ),
          ),
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.end,
              children: [
                pw.Text(
                  'BILL TO:',
                  style: pw.TextStyle(
                    fontSize: 10,
                    fontWeight: pw.FontWeight.bold,
                    color: primaryColor,
                  ),
                ),
                pw.SizedBox(height: 8),
                pw.Text(
                  cName,
                  style: pw.TextStyle(
                    fontSize: 12,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                if (cEmail.isNotEmpty)
                  pw.Text(cEmail, style: const pw.TextStyle(fontSize: 10)),
                if (cPhone.isNotEmpty)
                  pw.Text(cPhone, style: const pw.TextStyle(fontSize: 10)),
                if (cAddress.isNotEmpty)
                  pw.Text(cAddress, style: const pw.TextStyle(fontSize: 10)),
              ],
            ),
          ),
        ],
      ),
      pw.SizedBox(height: 30),
      _buildTable(doc, isPremium: true, primaryColor: primaryColor),
      pw.SizedBox(height: 20),
      pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.end,
        children: [
          pw.Container(
            width: 250,
            padding: const pw.EdgeInsets.all(12),
            decoration: pw.BoxDecoration(
              color: PdfColors.grey100,
              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.end,
              children: [
                _buildSummaryRow(
                  'Subtotal',
                  CurrencyFormatter.format(doc.subtotal, symbol: 'Rs.'),
                ),
                if (doc.totalTaxAmount > 0)
                  _buildSummaryRow(
                    'Tax',
                    CurrencyFormatter.format(doc.totalTaxAmount, symbol: 'Rs.'),
                  ),
                if ((doc.overallDiscountAmount + doc.itemDiscountsTotal) > 0)
                  _buildSummaryRow(
                    'Discount',
                    '-${CurrencyFormatter.format(doc.overallDiscountAmount + doc.itemDiscountsTotal, symbol: 'Rs.')}',
                  ),
                pw.Divider(color: PdfColors.grey400),
                _buildSummaryRow(
                  'Total',
                  CurrencyFormatter.format(doc.totalAmount, symbol: 'Rs.'),
                  isBold: true,
                  size: 16,
                  color: primaryColor,
                ),
                if (doc.totalPaid > 0) ...[
                  pw.SizedBox(height: 8),
                  _buildSummaryRow(
                    'Amount Paid',
                    CurrencyFormatter.format(doc.totalPaid, symbol: 'Rs.'),
                  ),
                  _buildSummaryRow(
                    'Balance Due',
                    CurrencyFormatter.format(doc.balanceDue, symbol: 'Rs.'),
                    isBold: true,
                    size: 12,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
      pw.SizedBox(height: 40),
      if (doc.notes != null && doc.notes!.isNotEmpty)
        pw.Container(
          padding: const pw.EdgeInsets.all(12),
          decoration: pw.BoxDecoration(
            border: pw.Border(
              left: pw.BorderSide(color: primaryColor, width: 3),
            ),
            color: PdfColors.grey50,
          ),
          child: pw.Text(doc.notes!, style: const pw.TextStyle(fontSize: 10)),
        ),
      pw.SizedBox(height: 40),
      pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        crossAxisAlignment: pw.CrossAxisAlignment.end,
        children: [
          pw.Expanded(
            child: _buildPaymentDetails(
              doc,
              payments,
              profile,
              primaryColor: primaryColor,
            ),
          ),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.end,
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              if (stampBytes != null && doc.showStamp)
                pw.Padding(
                  padding: const pw.EdgeInsets.only(right: 24),
                  child: pw.Column(
                    children: [
                      pw.Container(
                        width: 90,
                        height: 45,
                        alignment: pw.Alignment.bottomCenter,
                        child: pw.Image(
                          pw.MemoryImage(stampBytes),
                          fit: pw.BoxFit.contain,
                        ),
                      ),
                      pw.SizedBox(height: 4),
                      pw.Container(width: 90, height: 1.5, color: primaryColor),
                      pw.SizedBox(height: 4),
                      pw.Text(
                        'Company Stamp',
                        style: pw.TextStyle(fontSize: 10, color: primaryColor),
                      ),
                    ],
                  ),
                ),
              if (signatureBytes != null && doc.showSignature)
                pw.Column(
                  children: [
                    pw.Container(
                      width: 90,
                      height: 45,
                      alignment: pw.Alignment.bottomCenter,
                      child: pw.Image(
                        pw.MemoryImage(signatureBytes),
                        fit: pw.BoxFit.contain,
                      ),
                    ),
                    pw.Container(
                      width: 100,
                      child: pw.Divider(color: primaryColor),
                    ),
                    pw.Text(
                      'Authorized Signature',
                      style: pw.TextStyle(
                        fontSize: 10,
                        color: primaryColor,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ],
      ),
    ];
  }

  static pw.Widget _buildPaymentDetails(
    DocumentModel doc,
    List<PaymentDetail> payments,
    BusinessProfile profile, {
    PdfColor? primaryColor,
  }) {
    PaymentDetail? bankDetail;
    if (doc.selectedBankDetailId != null &&
        doc.selectedBankDetailId != 'none') {
      try {
        bankDetail = payments.firstWhere(
          (p) => p.id == doc.selectedBankDetailId,
        );
      } catch (_) {}
    }

    if (bankDetail == null && doc.selectedBankDetailId != 'none') {
      final banks = payments.where((p) => p.type == 'Bank').toList();
      if (banks.isNotEmpty) bankDetail = banks.first;
    }

    PaymentDetail? upiDetail;
    if (doc.selectedUpiDetailId != null && doc.selectedUpiDetailId != 'none') {
      try {
        upiDetail = payments.firstWhere((p) => p.id == doc.selectedUpiDetailId);
      } catch (_) {}
    }

    if (upiDetail == null && doc.selectedUpiDetailId != 'none') {
      final upis = payments.where((p) => p.type == 'UPI').toList();
      if (upis.isNotEmpty) upiDetail = upis.first;
    }

    final hasBank = bankDetail != null;
    final hasUpi = upiDetail != null;

    if (!doc.includePaymentDetails || doc.docType == DocumentType.receipt) {
      return pw.SizedBox();
    }
    if (!hasBank && !hasUpi) return pw.SizedBox();

    return pw.Container(
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Column(
            children: [
              pw.Container(
                width: 60,
                height: 60,
                padding: const pw.EdgeInsets.all(4),
                decoration: pw.BoxDecoration(
                  color: PdfColors.white,
                  borderRadius: const pw.BorderRadius.all(
                    pw.Radius.circular(6),
                  ),
                  border: pw.Border.all(color: PdfColors.grey400, width: 1),
                ),
                child: hasUpi
                    ? pw.BarcodeWidget(
                        barcode: pw.Barcode.qrCode(),
                        data:
                            'upi://pay?pa=${upiDetail.details}&pn=${Uri.encodeComponent(profile.businessName)}&am=${doc.totalAmount}',
                      )
                    : pw.BarcodeWidget(
                        barcode: pw.Barcode.qrCode(),
                        data: 'https://invoz-d9222.web.app',
                      ),
              ),
              pw.SizedBox(height: 4),
              pw.Text(
                'Scan to Pay',
                style: pw.TextStyle(
                  fontSize: 8,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.grey700,
                ),
              ),
            ],
          ),
          pw.SizedBox(width: 6),
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'PAYMENT DETAILS',
                  style: pw.TextStyle(
                    fontSize: 9,
                    fontWeight: pw.FontWeight.bold,
                    letterSpacing: 0.6,
                    color: primaryColor ?? PdfColors.grey800,
                  ),
                ),
                pw.SizedBox(height: 4),
                if (hasUpi)
                  pw.Text(
                    'UPI: ${upiDetail.details}',
                    style: pw.TextStyle(
                      fontSize: 8,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.grey700,
                    ),
                  ),

                if (hasBank) ...[
                  pw.Text(
                    'Bank: ${bankDetail.title}',
                    style: pw.TextStyle(
                      fontSize: 8,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.grey700,
                    ),
                  ),

                  pw.Text(
                    'A/C: ${bankDetail.details}',
                    style: pw.TextStyle(
                      fontSize: 8,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.grey700,
                    ),
                  ),
                  if (bankDetail.extra != null &&
                      bankDetail.extra!.trim().isNotEmpty)
                    pw.Text(
                      'IFSC: ${bankDetail.extra}',
                      style: pw.TextStyle(
                        fontSize: 8,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.grey700,
                      ),
                    ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildTable(
    DocumentModel doc, {
    required bool isPremium,
    PdfColor? primaryColor,
  }) {
    final headers = ['Item', 'Qty', 'Price', 'Tax', 'Total'];
    final data = doc.items.map((item) {
      return [
        item.title,
        item.quantity.toString(),
        CurrencyFormatter.format(item.unitPrice, symbol: 'Rs.'),
        item.taxPercent > 0 ? '${item.taxPercent}%' : '-',
        CurrencyFormatter.format(item.lineTotal, symbol: 'Rs.'),
      ];
    }).toList();

    if (isPremium) {
      return pw.TableHelper.fromTextArray(
        headers: headers,
        data: data,
        border: null,
        headerStyle: pw.TextStyle(
          color: PdfColors.white,
          fontWeight: pw.FontWeight.bold,
          fontSize: 10,
        ),
        headerDecoration: pw.BoxDecoration(
          color: primaryColor ?? PdfColors.blue,
        ),
        rowDecoration: const pw.BoxDecoration(
          border: pw.Border(
            bottom: pw.BorderSide(color: PdfColors.grey300, width: 0.5),
          ),
        ),
        cellStyle: const pw.TextStyle(fontSize: 10),
        cellAlignments: {
          0: pw.Alignment.centerLeft,
          1: pw.Alignment.center,
          2: pw.Alignment.centerRight,
          3: pw.Alignment.center,
          4: pw.Alignment.centerRight,
        },
      );
    } else {
      return pw.TableHelper.fromTextArray(
        headers: headers,
        data: data,
        border: const pw.TableBorder(
          bottom: pw.BorderSide(color: PdfColors.grey400),
          horizontalInside: pw.BorderSide(color: PdfColors.grey300),
        ),
        headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10),
        cellStyle: const pw.TextStyle(fontSize: 10),
        cellAlignments: {
          0: pw.Alignment.centerLeft,
          1: pw.Alignment.center,
          2: pw.Alignment.centerRight,
          3: pw.Alignment.center,
          4: pw.Alignment.centerRight,
        },
      );
    }
  }

  static pw.Widget _buildSummaryRow(
    String label,
    String value, {
    bool isBold = false,
    double size = 10,
    PdfColor? color,
  }) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            label,
            style: pw.TextStyle(
              fontSize: size,
              fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal,
              color: color,
            ),
          ),
          pw.Text(
            value,
            style: pw.TextStyle(
              fontSize: size,
              fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  static List<pw.Widget> _buildElegantCenter(
    pw.Context context,
    DocumentModel doc,
    BusinessProfile profile, {
    required List<PaymentDetail> payments,
    Uint8List? logoBytes,
    Uint8List? signatureBytes,
    Uint8List? stampBytes,
  }) {
    final title = doc.docType.displayName.toUpperCase();
    final primaryColor = PdfColor.fromHex('#0D47A1');
    final lightBlue = PdfColor.fromHex('#D6E4F0');
    String currency = profile.currencySymbol.isNotEmpty
        ? profile.currencySymbol
        : 'Rs.';
    if (currency == '\u20B9') {
      currency = 'Rs.';
    }

    final cName = doc.customerSnapshot?.name ?? 'Unknown Customer';
    final cEmail = doc.customerSnapshot?.email ?? '';

    return [
      pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.center,
        crossAxisAlignment: pw.CrossAxisAlignment.center,
        children: [
          if (logoBytes != null) ...[
            pw.ClipOval(
              child: pw.Container(
                width: 32,
                height: 32,
                child: pw.Image(
                  pw.MemoryImage(logoBytes),
                  fit: pw.BoxFit.cover,
                ),
              ),
            ),
            pw.SizedBox(width: 16),
          ],
          pw.Text(
            profile.businessName,
            style: pw.TextStyle(fontSize: 32, color: primaryColor),
          ),
        ],
      ),
      pw.SizedBox(height: 12),
      if (profile.address != null && profile.address!.isNotEmpty) ...[
        pw.Center(
          child: pw.Text(
            profile.address!,
            textAlign: pw.TextAlign.center,
            style: const pw.TextStyle(fontSize: 9.5, color: PdfColors.grey600),
          ),
        ),
        pw.SizedBox(height: 4),
      ],
      pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.center,
        children: [
          if (profile.phone != null && profile.phone!.isNotEmpty)
            pw.Text(
              profile.phone!,
              style: const pw.TextStyle(fontSize: 9.5, color: PdfColors.grey600),
            ),
          if (profile.phone != null &&
              profile.email != null &&
              profile.phone!.isNotEmpty &&
              profile.email!.isNotEmpty)
            pw.Text(
              '   |   ',
              style: const pw.TextStyle(fontSize: 9.5, color: PdfColors.grey600),
            ),
          if (profile.email != null && profile.email!.isNotEmpty)
            pw.Text(
              profile.email!,
              style: const pw.TextStyle(fontSize: 9.5, color: PdfColors.grey600),
            ),
        ],
      ),
      pw.SizedBox(height: 12),
      pw.Container(height: 2, color: lightBlue),
      pw.SizedBox(height: 32),
      pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'Paid By',
                style: pw.TextStyle(
                  color: primaryColor,
                  fontWeight: pw.FontWeight.bold,
                  fontSize: 11,
                ),
              ),
              pw.SizedBox(height: 6),
              pw.Text(cName, style: const pw.TextStyle(fontSize: 11)),
              pw.SizedBox(height: 6),
              if (cEmail.isNotEmpty)
                pw.Text(cEmail, style: const pw.TextStyle(fontSize: 11)),
            ],
          ),
          pw.Text(
            title,
            style: pw.TextStyle(
              color: primaryColor,
              fontWeight: pw.FontWeight.bold,
              fontSize: 28,
            ),
          ),
        ],
      ),
      pw.SizedBox(height: 32),
      pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.end,
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'Receipt Details',
                  style: pw.TextStyle(
                    color: primaryColor,
                    fontWeight: pw.FontWeight.bold,
                    fontSize: 11,
                  ),
                ),
                pw.SizedBox(height: 8),
                pw.Row(
                  children: [
                    pw.SizedBox(
                      width: 100,
                      child: pw.Text(
                        'Payment Date',
                        style: const pw.TextStyle(fontSize: 11),
                      ),
                    ),
                    pw.Text(
                      DateFormatter.format(doc.issueDate),
                      style: const pw.TextStyle(fontSize: 11),
                    ),
                  ],
                ),
              ],
            ),
          ),
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.Row(
                children: [
                  pw.SizedBox(
                    width: 80,
                    child: pw.Text(
                      '${doc.docType.displayName} #',
                      style: pw.TextStyle(
                        color: primaryColor,
                        fontWeight: pw.FontWeight.bold,
                        fontSize: 11,
                      ),
                    ),
                  ),
                  pw.Text(
                    doc.docNumber,
                    style: const pw.TextStyle(fontSize: 11),
                  ),
                ],
              ),
              if (doc.poNumber != null && doc.poNumber!.isNotEmpty) ...[
                pw.SizedBox(height: 6),
                pw.Row(
                  children: [
                    pw.SizedBox(
                      width: 80,
                      child: pw.Text(
                        'PO #',
                        style: pw.TextStyle(
                          color: primaryColor,
                          fontWeight: pw.FontWeight.bold,
                          fontSize: 11,
                        ),
                      ),
                    ),
                    pw.Text(
                      doc.poNumber!,
                      style: const pw.TextStyle(fontSize: 11),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ],
      ),
      pw.SizedBox(height: 24),
      pw.Container(
        decoration: pw.BoxDecoration(
          border: pw.Border.all(color: primaryColor),
        ),
        child: pw.Column(
          children: [
            pw.Container(
              color: primaryColor,
              padding: const pw.EdgeInsets.symmetric(
                vertical: 8,
                horizontal: 12,
              ),
              child: pw.Row(
                children: [
                  pw.Expanded(
                    flex: 1,
                    child: pw.Text(
                      'Quantity',
                      style: pw.TextStyle(
                        color: PdfColors.white,
                        fontWeight: pw.FontWeight.bold,
                        fontSize: 10,
                      ),
                    ),
                  ),
                  pw.Expanded(
                    flex: 3,
                    child: pw.Text(
                      'Description',
                      style: pw.TextStyle(
                        color: PdfColors.white,
                        fontWeight: pw.FontWeight.bold,
                        fontSize: 10,
                      ),
                    ),
                  ),
                  pw.Expanded(
                    flex: 2,
                    child: pw.Align(
                      alignment: pw.Alignment.centerRight,
                      child: pw.Text(
                        'Unit Price',
                        style: pw.TextStyle(
                          color: PdfColors.white,
                          fontWeight: pw.FontWeight.bold,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ),
                  pw.Expanded(
                    flex: 2,
                    child: pw.Align(
                      alignment: pw.Alignment.centerRight,
                      child: pw.Text(
                        'Amount',
                        style: pw.TextStyle(
                          color: PdfColors.white,
                          fontWeight: pw.FontWeight.bold,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            ...doc.items.map((item) {
              return pw.Padding(
                padding: const pw.EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 12,
                ),
                child: pw.Row(
                  children: [
                    pw.Expanded(
                      flex: 1,
                      child: pw.Align(
                        alignment: pw.Alignment.centerRight,
                        child: pw.Text(
                          item.quantity.toString(),
                          style: const pw.TextStyle(fontSize: 11),
                        ),
                      ),
                    ),
                    pw.SizedBox(width: 20),
                    pw.Expanded(
                      flex: 3,
                      child: pw.Text(
                        item.title,
                        style: const pw.TextStyle(fontSize: 11),
                      ),
                    ),
                    pw.Expanded(
                      flex: 2,
                      child: pw.Align(
                        alignment: pw.Alignment.centerRight,
                        child: pw.Text(
                          CurrencyFormatter.format(
                            item.unitPrice,
                            symbol: currency,
                          ),
                          style: const pw.TextStyle(fontSize: 11),
                        ),
                      ),
                    ),
                    pw.Expanded(
                      flex: 2,
                      child: pw.Align(
                        alignment: pw.Alignment.centerRight,
                        child: pw.Text(
                          CurrencyFormatter.format(
                            item.lineTotal,
                            symbol: currency,
                          ),
                          style: const pw.TextStyle(fontSize: 11),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
            pw.Container(height: 1, color: primaryColor),
            pw.Padding(
              padding: const pw.EdgeInsets.symmetric(
                vertical: 8,
                horizontal: 12,
              ),
              child: pw.Row(
                children: [
                  pw.Expanded(flex: 4, child: pw.SizedBox()),
                  pw.Expanded(
                    flex: 2,
                    child: pw.Text(
                      'Subtotal',
                      style: const pw.TextStyle(fontSize: 11),
                    ),
                  ),
                  pw.Expanded(
                    flex: 2,
                    child: pw.Align(
                      alignment: pw.Alignment.centerRight,
                      child: pw.Text(
                        CurrencyFormatter.format(
                          doc.subtotal,
                          symbol: currency,
                        ),
                        style: const pw.TextStyle(fontSize: 11),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (doc.totalTaxAmount > 0)
              pw.Padding(
                padding: const pw.EdgeInsets.symmetric(
                  vertical: 8,
                  horizontal: 12,
                ),
                child: pw.Row(
                  children: [
                    pw.Expanded(flex: 4, child: pw.SizedBox()),
                    pw.Expanded(
                      flex: 2,
                      child: pw.Text(
                        'Tax',
                        style: const pw.TextStyle(fontSize: 11),
                      ),
                    ),
                    pw.Expanded(
                      flex: 2,
                      child: pw.Align(
                        alignment: pw.Alignment.centerRight,
                        child: pw.Text(
                          CurrencyFormatter.format(
                            doc.totalTaxAmount,
                            symbol: currency,
                          ),
                          style: const pw.TextStyle(fontSize: 11),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            if (doc.overallDiscountAmount > 0)
              pw.Padding(
                padding: const pw.EdgeInsets.symmetric(
                  vertical: 8,
                  horizontal: 12,
                ),
                child: pw.Row(
                  children: [
                    pw.Expanded(flex: 4, child: pw.SizedBox()),
                    pw.Expanded(
                      flex: 2,
                      child: pw.Text(
                        'Discount',
                        style: const pw.TextStyle(fontSize: 11),
                      ),
                    ),
                    pw.Expanded(
                      flex: 2,
                      child: pw.Align(
                        alignment: pw.Alignment.centerRight,
                        child: pw.Text(
                          '-${CurrencyFormatter.format(doc.overallDiscountAmount, symbol: currency)}',
                          style: const pw.TextStyle(fontSize: 11),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            pw.Container(height: 1, color: primaryColor),
            pw.Container(
              color: lightBlue,
              padding: const pw.EdgeInsets.symmetric(
                vertical: 12,
                horizontal: 12,
              ),
              child: pw.Row(
                children: [
                  pw.Expanded(flex: 4, child: pw.SizedBox()),
                  pw.Expanded(
                    flex: 2,
                    child: pw.Text(
                      'Total',
                      style: pw.TextStyle(
                        color: primaryColor,
                        fontWeight: pw.FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  pw.Expanded(
                    flex: 2,
                    child: pw.Align(
                      alignment: pw.Alignment.centerRight,
                      child: pw.Text(
                        CurrencyFormatter.format(
                          doc.totalAmount,
                          symbol: currency,
                        ),
                        style: pw.TextStyle(
                          color: primaryColor,
                          fontWeight: pw.FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      pw.Spacer(),
      pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.end,
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                if (doc.notes != null && doc.notes!.isNotEmpty) ...[
                  pw.Text(
                    'Notes',
                    style: pw.TextStyle(
                      color: primaryColor,
                      fontWeight: pw.FontWeight.bold,
                      fontSize: 11,
                    ),
                  ),
                  pw.SizedBox(height: 4),
                  pw.Text(doc.notes!, style: const pw.TextStyle(fontSize: 11)),
                  pw.SizedBox(height: 16),
                ],
                _buildPaymentDetails(
                  doc,
                  payments,
                  profile,
                  primaryColor: primaryColor,
                ),
              ],
            ),
          ),
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              if (stampBytes != null && doc.showStamp)
                pw.Padding(
                  padding: const pw.EdgeInsets.only(right: 24),
                  child: pw.Column(
                    children: [
                      pw.Container(
                        width: 90,
                        height: 45,
                        alignment: pw.Alignment.bottomCenter,
                        child: pw.Image(
                          pw.MemoryImage(stampBytes),
                          fit: pw.BoxFit.contain,
                        ),
                      ),
                      pw.SizedBox(height: 4),
                      pw.Container(width: 90, height: 1.5, color: primaryColor),
                      pw.SizedBox(height: 4),
                      pw.Text(
                        'Company Stamp',
                        style: pw.TextStyle(fontSize: 10, color: primaryColor),
                      ),
                    ],
                  ),
                ),
              if (signatureBytes != null && doc.showSignature)
                pw.Column(
                  children: [
                    pw.Container(
                      width: 90,
                      height: 45,
                      alignment: pw.Alignment.bottomCenter,
                      child: pw.Image(
                        pw.MemoryImage(signatureBytes),
                        fit: pw.BoxFit.contain,
                      ),
                    ),
                    pw.Container(
                      width: 100,
                      child: pw.Divider(color: primaryColor),
                    ),
                    pw.Text(
                      'Authorized Signature',
                      style: pw.TextStyle(fontSize: 10, color: primaryColor),
                    ),
                  ],
                ),
            ],
          ),
        ],
      ),
    ];
  }

  static List<pw.Widget> _buildOrderReceipt(
    pw.Context context,
    DocumentModel doc,
    BusinessProfile profile, {
    required List<PaymentDetail> payments,
    Uint8List? logoBytes,
    Uint8List? signatureBytes,
    Uint8List? stampBytes,
  }) {
    String currency = profile.currencySymbol.isNotEmpty
        ? profile.currencySymbol
        : 'Rs.';
    if (currency == '\u20B9') {
      currency = 'Rs.';
    }

    final cName = doc.customerSnapshot?.name ?? 'Valued Customer';
    final cAddress = doc.customerSnapshot?.billingAddress ?? '';

    String paidBy = 'Credit';
    if (doc.payments.isNotEmpty) {
      paidBy = doc.payments.first.paymentMethod;
    } else if (doc.totalPaid >= doc.totalAmount && doc.totalAmount > 0) {
      paidBy = 'Paid in Full';
    }

    return [
      pw.Container(
        decoration: pw.BoxDecoration(
          color: PdfColors.white,
          borderRadius: const pw.BorderRadius.all(pw.Radius.circular(14)),
          border: pw.Border.all(color: PdfColor.fromHex('#CBD5E1'), width: 1),
        ),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.stretch,
          children: [
            pw.Padding(
              padding: const pw.EdgeInsets.fromLTRB(28, 22, 28, 16),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.center,
                children: [
                  // Company Logo
                  if (logoBytes != null)
                    pw.Container(
                      width: 44,
                      height: 44,
                      margin: const pw.EdgeInsets.only(bottom: 12),
                      child: pw.ClipOval(
                        child: pw.Image(
                          pw.MemoryImage(logoBytes),
                          fit: pw.BoxFit.contain,
                        ),
                      ),
                    )
                  else
                    pw.Container(
                      width: 42,
                      height: 42,
                      margin: const pw.EdgeInsets.only(bottom: 12),
                      decoration: pw.BoxDecoration(
                        color: PdfColor.fromHex('#F1F5F9'),
                        shape: pw.BoxShape.circle,
                        border: pw.Border.all(
                          color: PdfColor.fromHex('#CBD5E1'),
                          width: 1,
                        ),
                      ),
                      child: pw.Center(
                        child: pw.Text(
                          profile.businessName.isNotEmpty
                              ? profile.businessName[0].toUpperCase()
                              : 'B',
                          style: pw.TextStyle(
                            color: PdfColor.fromHex('#475569'),
                            fontSize: 18,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                      ),
                    ),

                  // Thanks for your business
                  pw.Text(
                    'Thanks For Your Business!',
                    textAlign: pw.TextAlign.center,
                    style: pw.TextStyle(
                      fontSize: 22,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColor.fromHex('#1E293B'),
                    ),
                  ),
                  pw.SizedBox(height: 14),

                  // Your order
                  pw.Text(
                    'Your order',
                    textAlign: pw.TextAlign.center,
                    style: pw.TextStyle(
                      fontSize: 15,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColor.fromHex('#1E293B'),
                    ),
                  ),
                  pw.SizedBox(height: 4),
                  pw.Text(
                    '${doc.docNumber}  •  Payment Date: ${DateFormatter.format(doc.issueDate)}',
                    textAlign: pw.TextAlign.center,
                    style: pw.TextStyle(
                      fontSize: 10,
                      color: PdfColor.fromHex('#94A3B8'),
                    ),
                  ),
                  pw.SizedBox(height: 14),

                  // Items list
                  ...doc.items.map((item) {
                    final itemTitle = item.quantity > 1
                        ? '${item.quantity.toInt()}x ${item.title}'
                        : item.title;
                    return pw.Padding(
                      padding: const pw.EdgeInsets.symmetric(vertical: 3),
                      child: pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Expanded(
                            child: pw.Text(
                              itemTitle,
                              style: pw.TextStyle(
                                fontSize: 11,
                                color: PdfColor.fromHex('#1E293B'),
                              ),
                            ),
                          ),
                          pw.Text(
                            CurrencyFormatter.format(
                              item.lineTotal,
                              symbol: currency,
                            ),
                            style: pw.TextStyle(
                              fontSize: 11,
                              fontWeight: pw.FontWeight.bold,
                              color: PdfColor.fromHex('#1E293B'),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),

                  pw.SizedBox(height: 8),

                  // Subtotal
                  pw.Padding(
                    padding: const pw.EdgeInsets.symmetric(vertical: 2),
                    child: pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text(
                          'Subtotal',
                          style: pw.TextStyle(
                            fontSize: 10.5,
                            color: PdfColor.fromHex('#64748B'),
                          ),
                        ),
                        pw.Text(
                          CurrencyFormatter.format(
                            doc.subtotal,
                            symbol: currency,
                          ),
                          style: pw.TextStyle(
                            fontSize: 10.5,
                            color: PdfColor.fromHex('#64748B'),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Tax
                  if (doc.totalTaxAmount > 0)
                    pw.Padding(
                      padding: const pw.EdgeInsets.symmetric(vertical: 2),
                      child: pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Text(
                            'Tax',
                            style: pw.TextStyle(
                              fontSize: 10.5,
                              color: PdfColor.fromHex('#64748B'),
                            ),
                          ),
                          pw.Text(
                            CurrencyFormatter.format(
                              doc.totalTaxAmount,
                              symbol: currency,
                            ),
                            style: pw.TextStyle(
                              fontSize: 10.5,
                              color: PdfColor.fromHex('#64748B'),
                            ),
                          ),
                        ],
                      ),
                    ),

                  // Other fee / shipping / discount
                  if (doc.shippingCharges > 0)
                    pw.Padding(
                      padding: const pw.EdgeInsets.symmetric(vertical: 2),
                      child: pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Text(
                            'Shipping Fee',
                            style: pw.TextStyle(
                              fontSize: 10.5,
                              color: PdfColor.fromHex('#64748B'),
                            ),
                          ),
                          pw.Text(
                            CurrencyFormatter.format(
                              doc.shippingCharges,
                              symbol: currency,
                            ),
                            style: pw.TextStyle(
                              fontSize: 10.5,
                              color: PdfColor.fromHex('#64748B'),
                            ),
                          ),
                        ],
                      ),
                    ),

                  if ((doc.overallDiscountAmount + doc.itemDiscountsTotal) > 0)
                    pw.Padding(
                      padding: const pw.EdgeInsets.symmetric(vertical: 2),
                      child: pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Text(
                            'Discount',
                            style: pw.TextStyle(
                              fontSize: 10.5,
                              color: PdfColor.fromHex('#64748B'),
                            ),
                          ),
                          pw.Text(
                            '-${CurrencyFormatter.format(doc.overallDiscountAmount + doc.itemDiscountsTotal, symbol: currency)}',
                            style: pw.TextStyle(
                              fontSize: 10.5,
                              color: PdfColor.fromHex('#64748B'),
                            ),
                          ),
                        ],
                      ),
                    ),

                  pw.SizedBox(height: 8),

                  // Total bar with top & bottom lines
                  pw.Container(
                    padding: const pw.EdgeInsets.symmetric(vertical: 6),
                    decoration: pw.BoxDecoration(
                      border: pw.Border.symmetric(
                        horizontal: pw.BorderSide(
                          color: PdfColor.fromHex('#1E293B'),
                          width: 1.5,
                        ),
                      ),
                    ),
                    child: pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text(
                          'Total',
                          style: pw.TextStyle(
                            fontSize: 14,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColor.fromHex('#1E293B'),
                          ),
                        ),
                        pw.Text(
                          CurrencyFormatter.format(
                            doc.totalAmount,
                            symbol: currency,
                          ),
                          style: pw.TextStyle(
                            fontSize: 14,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColor.fromHex('#1E293B'),
                          ),
                        ),
                      ],
                    ),
                  ),
                  pw.SizedBox(height: 18),

                  // Your details
                  pw.Text(
                    'Your details',
                    textAlign: pw.TextAlign.center,
                    style: pw.TextStyle(
                      fontSize: 15,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColor.fromHex('#1E293B'),
                    ),
                  ),
                  pw.SizedBox(height: 12),

                  // Details rows
                  pw.Row(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.SizedBox(
                        width: 100,
                        child: pw.Text(
                          'Shipping to',
                          style: pw.TextStyle(
                            fontSize: 11,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColor.fromHex('#1E293B'),
                          ),
                        ),
                      ),
                      pw.Expanded(
                        child: pw.Text(
                          '$cName${cAddress.isNotEmpty ? '\n$cAddress' : ''}',
                          style: pw.TextStyle(
                            fontSize: 10.5,
                            lineSpacing: 1.3,
                            color: PdfColor.fromHex('#64748B'),
                          ),
                        ),
                      ),
                    ],
                  ),
                  pw.SizedBox(height: 10),
                  pw.Row(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.SizedBox(
                        width: 100,
                        child: pw.Text(
                          'Billed to',
                          style: pw.TextStyle(
                            fontSize: 11,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColor.fromHex('#1E293B'),
                          ),
                        ),
                      ),
                      pw.Expanded(
                        child: pw.Text(
                          '$paidBy\nReceipt #${doc.docNumber}',
                          style: pw.TextStyle(
                            fontSize: 10.5,
                            lineSpacing: 1.3,
                            color: PdfColor.fromHex('#64748B'),
                          ),
                        ),
                      ),
                    ],
                  ),
                  pw.SizedBox(height: 14),

                  // Support help notice
                  pw.Text(
                    'Notice something wrong? Contact support (${profile.email?.isNotEmpty == true ? profile.email : (profile.phone?.isNotEmpty == true ? profile.phone : "support")}) and we\'ll be happy to help.',
                    textAlign: pw.TextAlign.center,
                    style: pw.TextStyle(
                      fontSize: 9.5,
                      color: PdfColor.fromHex('#64748B'),
                    ),
                  ),
                ],
              ),
            ),

            // Compact Invoz Promo Banner
            pw.UrlLink(
              destination:
                  'https://play.google.com/store/apps/details?id=com.invoice.invoz',
              child: pw.Container(
                color: PdfColor.fromHex('#00A859'),
                padding: const pw.EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: pw.CrossAxisAlignment.center,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      mainAxisSize: pw.MainAxisSize.min,
                      children: [
                        pw.Text(
                          'Created with Invoz App',
                          style: pw.TextStyle(
                            fontSize: 10.5,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.white,
                          ),
                        ),
                        pw.SizedBox(height: 1.5),
                        pw.Text(
                          'Fast Invoicing & Receipts on Google Play',
                          style: const pw.TextStyle(
                            fontSize: 8,
                            color: PdfColors.white,
                          ),
                        ),
                      ],
                    ),
                    pw.Container(
                      padding: const pw.EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 3.5,
                      ),
                      decoration: const pw.BoxDecoration(
                        color: PdfColors.white,
                        borderRadius: pw.BorderRadius.all(
                          pw.Radius.circular(10),
                        ),
                      ),
                      child: pw.Text(
                        'Get Invoz',
                        style: pw.TextStyle(
                          fontSize: 8.5,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColor.fromHex('#00A859'),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Signature inside the card if present
            if (doc.showSignature && signatureBytes != null) ...[
              pw.SizedBox(height: 10),
              pw.Center(
                child: pw.Container(
                  height: 38,
                  child: pw.Image(pw.MemoryImage(signatureBytes)),
                ),
              ),
              pw.SizedBox(height: 3),
              pw.Text(
                'Authorized Signature',
                textAlign: pw.TextAlign.center,
                style: const pw.TextStyle(
                  fontSize: 8,
                  color: PdfColors.grey700,
                ),
              ),
            ],

            // Footer (NO "View My Account" button per instruction)
            pw.Padding(
              padding: const pw.EdgeInsets.symmetric(vertical: 14),
              child: pw.Text(
                'Thanks for being a great customer.',
                textAlign: pw.TextAlign.center,
                style: pw.TextStyle(
                  fontSize: 10.5,
                  color: PdfColor.fromHex('#64748B'),
                ),
              ),
            ),
          ],
        ),
      ),
    ];
  }
}
