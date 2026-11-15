import 'package:flutter/material.dart';
import '../../pdf_engine/template_registry.dart';
import '../domain/document_model.dart';
import 'dummy_templates/classic_free_dummy.dart';
import 'dummy_templates/premium_modern_dummy.dart';
import 'dummy_templates/elegant_center_dummy.dart';
import 'dummy_templates/order_receipt_dummy.dart';
import 'dummy_templates/receipt_thermal_dummy.dart';

class DummyTemplateWidget extends StatelessWidget {
  final String templateId;
  final DocumentType documentType;

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
      case TemplateRegistry.premiumModern:
        return SizedBox(
          width: 595,
          height: 842,
          child: buildPremiumModernDummy(documentType),
        );
      case TemplateRegistry.elegantCenter:
        return SizedBox(
          width: 595,
          height: 842,
          child: buildElegantCenterDummy(documentType),
        );
      case TemplateRegistry.orderReceipt:
        return SizedBox(
          width: 440,
          child: buildOrderReceiptDummy(documentType, context),
        );
      case TemplateRegistry.thermalReceipt:
        return SizedBox(
          width: 440,
          child: buildReceiptThermalDummy(documentType, context),
        );
      case TemplateRegistry.freeClassic:
      default:
        return SizedBox(
          width: 595,
          height: 842,
          child: buildClassicFreeDummy(documentType),
        );
    }
  }
}
