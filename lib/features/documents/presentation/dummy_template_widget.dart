import 'package:flutter/material.dart';
import '../../pdf_engine/template_registry.dart';
import '../domain/document_model.dart';
import 'dummy_templates/classic_free_dummy.dart';
import 'dummy_templates/premium_modern_dummy.dart';
import 'dummy_templates/elegant_center_dummy.dart';
import 'dummy_templates/order_receipt_dummy.dart';
import 'dummy_templates/receipt_thermal_dummy.dart';
import 'dummy_templates/warm_quotation_dummy.dart';
import 'dummy_templates/cyan_quotation_dummy.dart';
import 'dummy_templates/formal_quotation_dummy.dart';

class DummyTemplateWidget extends StatelessWidget {
  final String templateId;
  final DocumentType documentType;

  static const double a4Width = 595.0;
  static const double a4Height = 842.0;
  static const double receiptWidth = 440.0;

  const DummyTemplateWidget({
    super.key,
    required this.templateId,
    this.documentType = DocumentType.invoice,
  });

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      fit: BoxFit.contain,
      child: _buildTemplate(context),
    );
  }

  Widget _buildTemplate(BuildContext context) {
    final effectiveId = TemplateRegistry.resolveTemplateId(
      templateId,
      documentType,
    );
    switch (effectiveId) {
      case TemplateRegistry.cyanQuotation:
        return SizedBox(
          width: a4Width,
          height: a4Height,
          child: buildCyanQuotationDummy(documentType, context),
        );
      case TemplateRegistry.warmQuotation:
        return SizedBox(
          width: a4Width,
          height: a4Height,
          child: buildWarmQuotationDummy(documentType, context),
        );
      case TemplateRegistry.formalQuotation:
        return SizedBox(
          width: a4Width,
          height: a4Height,
          child: buildFormalQuotationDummy(documentType, context),
        );
      case TemplateRegistry.premiumModern:
        return SizedBox(
          width: a4Width,
          height: a4Height,
          child: buildPremiumModernDummy(documentType),
        );
      case TemplateRegistry.elegantCenter:
        return SizedBox(
          width: a4Width,
          height: a4Height,
          child: buildElegantCenterDummy(DocumentType.receipt),
        );
      case TemplateRegistry.orderReceipt:
        return SizedBox(
          width: receiptWidth,
          child: buildOrderReceiptDummy(documentType, context),
        );
      case TemplateRegistry.thermalReceipt:
        return SizedBox(
          width: receiptWidth,
          child: buildReceiptThermalDummy(documentType, context),
        );
      case TemplateRegistry.freeClassic:
      default:
        return SizedBox(
          width: a4Width,
          height: a4Height,
          child: buildClassicFreeDummy(documentType),
        );
    }
  }
}
