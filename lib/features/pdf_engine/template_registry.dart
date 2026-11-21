import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../documents/domain/document_model.dart';

class TemplateInfo {
  final String id;
  final String name;
  final String description;
  final IconData icon;
  final Color accentColor;
  final String thumbnailAssetPath;
  final bool isPremium;
  final List<DocumentType> supportedTypes;

  const TemplateInfo({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.accentColor,
    required this.thumbnailAssetPath,
    required this.isPremium,
    this.supportedTypes = const [
      DocumentType.invoice,
      DocumentType.quotation,
      DocumentType.proforma,
      DocumentType.receipt,
    ],
  });
}

class TemplateRegistry {
  TemplateRegistry._();

  static const String freeClassic = 'free_classic';
  static const String premiumModern = 'premium_modern';
  static const String elegantCenter = 'elegant_center';
  static const String orderReceipt = 'order_receipt';
  static const String thermalReceipt = 'thermal_receipt';
  static const String warmQuotation = 'warm_quotation';
  static const String cyanQuotation = 'cyan_quotation';
  static const String formalQuotation = 'formal_quotation';

  static const List<TemplateInfo> allTemplates = [
    TemplateInfo(
      id: freeClassic,
      name: 'Classic Free',
      description:
          'A clean, professional standard layout that covers all basics.',
      icon: Icons.article_outlined,
      accentColor: AppColors.textPrimary,
      thumbnailAssetPath: 'assets/images/templates/free_template_thumb.png',
      isPremium: false,
      supportedTypes: [
        DocumentType.invoice,
        DocumentType.proforma,
      ],
    ),
    TemplateInfo(
      id: premiumModern,
      name: 'Modern Style',
      description:
          'Sleek, colored headers with clean typography and card styling.',
      icon: Icons.auto_awesome,
      accentColor: AppColors.primary,
      thumbnailAssetPath: 'assets/images/templates/paid_template_thumb.png',
      isPremium: true,
      supportedTypes: [
        DocumentType.invoice,
        DocumentType.proforma,
      ],
    ),
    TemplateInfo(
      id: cyanQuotation,
      name: 'Clean Cyan',
      description:
          'Modern cyan quotation with bordered item tables, highlighted total, and enquiry banner.',
      icon: Icons.request_quote_outlined,
      accentColor: Color(0xFF00A3E0),
      thumbnailAssetPath: 'assets/images/templates/paid_template_thumb.png',
      isPremium: false,
      supportedTypes: [
        DocumentType.quotation,
      ],
    ),
    TemplateInfo(
      id: warmQuotation,
      name: 'Modern Quotation',
      description:
          'Clean orange header quotation layout with info cards and alternating item rows.',
      icon: Icons.request_quote_rounded,
      accentColor: Color(0xFFF26522),
      thumbnailAssetPath: 'assets/images/templates/paid_template_thumb.png',
      isPremium: true,
      supportedTypes: [
        DocumentType.quotation,
      ],
    ),
    TemplateInfo(
      id: formalQuotation,
      name: 'Formal Quotation',
      description:
          'Classic letterhead quotation with introductory letter, item table, and company seal.',
      icon: Icons.assignment_outlined,
      accentColor: Color(0xFF1E293B),
      thumbnailAssetPath: 'assets/images/templates/free_template_thumb.png',
      isPremium: false,
      supportedTypes: [
        DocumentType.quotation,
      ],
    ),
    TemplateInfo(
      id: elegantCenter,
      name: 'Elegant Center',
      description:
          'A beautiful centered layout with clean borders and modern typography.',
      icon: Icons.format_align_center,
      accentColor: Color(0xFF0D47A1),
      thumbnailAssetPath: 'assets/images/templates/elegant_center_thumb.png',
      isPremium: false,
      supportedTypes: [
        DocumentType.receipt,
      ],
    ),
    TemplateInfo(
      id: orderReceipt,
      name: 'Order Receipt',
      description:
          'Modern order confirmation receipt with brand header and promo banner.',
      icon: Icons.receipt_rounded,
      accentColor: Color(0xFF00A859),
      thumbnailAssetPath: 'assets/images/templates/order_receipt_thumb.png',
      isPremium: true,
      supportedTypes: [
        DocumentType.receipt,
      ],
    ),
    TemplateInfo(
      id: thermalReceipt,
      name: 'Thermal Print',
      description:
          'Classic cash register & thermal receipt slip with itemized list and transaction ID.',
      icon: Icons.receipt_long_rounded,
      accentColor: Color(0xFF1E293B),
      thumbnailAssetPath: 'assets/images/templates/thermal_receipt_thumb.png',
      isPremium: true,
      supportedTypes: [
        DocumentType.receipt,
      ],
    ),
  ];

  static String resolveTemplateId(String? id, DocumentType type) {
    final available = getTemplatesFor(type);
    if (available.isEmpty) return freeClassic;
    if (id == null || id.isEmpty) return available.first.id;

    // Direct match
    if (available.any((t) => t.id == id)) return id;

    // Aliases / Legacy mappings
    if (type == DocumentType.quotation) {
      if (id == warmQuotation) {
        return warmQuotation;
      }
      if (id == formalQuotation || id == 'formal' || id == 'letterhead') {
        return formalQuotation;
      }
      return cyanQuotation;
    } else if (type == DocumentType.receipt) {
      if (id == thermalReceipt || id == 'compact') {
        return thermalReceipt;
      }
      if (id == orderReceipt || id == 'order') {
        return orderReceipt;
      }
      return elegantCenter;
    } else {
      // Invoice & Proforma
      if (id == premiumModern || id == 'modern_crimson' || id == 'bold') {
        return premiumModern;
      }
      return freeClassic;
    }
  }

  static TemplateInfo getById(String id) {
    for (final t in allTemplates) {
      if (t.id == id) return t;
    }
    // Check aliases
    if (id == 'modern_crimson' || id == 'bold') {
      return allTemplates.firstWhere((t) => t.id == premiumModern);
    }
    if (id == 'compact') {
      return allTemplates.firstWhere((t) => t.id == thermalReceipt);
    }
    if (id == 'elegant') {
      return allTemplates.firstWhere((t) => t.id == elegantCenter);
    }
    if (id == 'order') {
      return allTemplates.firstWhere((t) => t.id == orderReceipt);
    }
    if (id == 'quotation' || id == 'warm_quotation') {
      return allTemplates.firstWhere((t) => t.id == warmQuotation);
    }
    if (id == formalQuotation || id == 'formal' || id == 'letterhead') {
      return allTemplates.firstWhere((t) => t.id == formalQuotation);
    }
    if (id == 'cyan_quotation' || id == 'cyan') {
      return allTemplates.firstWhere((t) => t.id == cyanQuotation);
    }
    return allTemplates.first;
  }

  static List<TemplateInfo> getTemplatesFor(DocumentType type) {
    return allTemplates.where((t) => t.supportedTypes.contains(type)).toList();
  }
}
