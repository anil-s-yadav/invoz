import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:invoz/features/ads/ad_banner_widget.dart';
import '../../../core/constants/app_colors.dart';
import '../../business_profile/bloc/business_profile_bloc.dart';
import '../../business_profile/bloc/business_profile_state.dart';
import '../../business_profile/domain/business_profile_model.dart';
import '../../documents/domain/document_model.dart';
import '../../documents/presentation/template_preview_screen.dart';
import '../../documents/presentation/widgets/template_thumbnail_card.dart';
import '../../pdf_engine/template_registry.dart';
import '../data/template_settings_repository.dart';

class DefaultTemplatesScreen extends StatefulWidget {
  final int initialIndex;

  const DefaultTemplatesScreen({super.key, this.initialIndex = 0});

  @override
  State<DefaultTemplatesScreen> createState() => _DefaultTemplatesScreenState();
}

class _DefaultTemplatesScreenState extends State<DefaultTemplatesScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  static final _repo = TemplateSettingsRepository();

  static const List<DocumentType> _types = [
    DocumentType.invoice,
    DocumentType.quotation,
    DocumentType.receipt,
    DocumentType.proforma,
  ];

  static const Map<DocumentType, Color> _typeColors = {
    DocumentType.invoice: AppColors.primary,
    DocumentType.quotation: Color(0xFFF26522),
    DocumentType.receipt: Color(0xFF10B981),
    DocumentType.proforma: Color(0xFF0284C7),
  };

  static const Map<DocumentType, IconData> _typeIcons = {
    DocumentType.invoice: Icons.receipt_long_rounded,
    DocumentType.quotation: Icons.request_quote_rounded,
    DocumentType.receipt: Icons.task_alt_rounded,
    DocumentType.proforma: Icons.description_rounded,
  };

  static const Map<DocumentType, String> _defaultFallbacks = {
    DocumentType.invoice: TemplateRegistry.freeClassic,
    DocumentType.quotation: TemplateRegistry.freeClassic,
    DocumentType.receipt: TemplateRegistry.elegantCenter,
    DocumentType.proforma: TemplateRegistry.freeClassic,
  };

  static const SliverGridDelegateWithFixedCrossAxisCount _gridDelegate =
      SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.72,
        crossAxisSpacing: 16,
        mainAxisSpacing: 20,
      );

  // Cached template lists per document type to avoid redundant registry filtering on every build
  static final Map<DocumentType, List<TemplateInfo>> _cachedTemplates = {
    for (final type in _types) type: TemplateRegistry.getTemplatesFor(type),
  };

  late Map<DocumentType, String> _defaults;

  @override
  void initState() {
    super.initState();
    _defaults = Map<DocumentType, String>.from(_defaultFallbacks);
    _tabController = TabController(
      length: _types.length,
      vsync: this,
      initialIndex: widget.initialIndex.clamp(0, _types.length - 1),
    );
    _loadDefaults();
  }

  Future<void> _loadDefaults() async {
    try {
      final results = await Future.wait(
        _types.map((type) => _repo.getDefaultTemplate(type)),
      );
      if (!mounted) return;
      setState(() {
        _defaults = {
          for (int i = 0; i < _types.length; i++) _types[i]: results[i],
        };
      });
    } catch (e) {
      debugPrint('Error loading default templates: $e');
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  static Color _getDocumentColor(DocumentType type) =>
      _typeColors[type] ?? AppColors.primary;

  static IconData _getDocumentIcon(DocumentType type) =>
      _typeIcons[type] ?? Icons.receipt_long_rounded;

  String _resolveCurrentDefaultId(
    DocumentType type,
    List<TemplateInfo> templates,
  ) {
    final savedId = _defaults[type];
    if (savedId != null && savedId.isNotEmpty) {
      return TemplateRegistry.resolveTemplateId(savedId, type);
    }
    if (type == DocumentType.receipt) {
      return TemplateRegistry.elegantCenter;
    }
    return templates.isNotEmpty
        ? templates.first.id
        : TemplateRegistry.freeClassic;
  }

  Future<void> _setDefault(DocumentType type, TemplateInfo template) async {
    if (_defaults[type] == template.id) return;

    // Optimistic local state update for instant UI feedback
    setState(() {
      _defaults = Map<DocumentType, String>.from(_defaults)
        ..[type] = template.id;
    });

    try {
      await _repo.setDefaultTemplate(type, template.id);
    } catch (e) {
      debugPrint('Failed to save default template: $e');
    }

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${template.name} set as default for ${type.displayName}',
        ),
        duration: const Duration(seconds: 2),
        backgroundColor: AppColors.statusPaidText,
      ),
    );
  }

  void _openPreview({
    required BuildContext context,
    required TemplateInfo template,
    required DocumentType type,
    required BusinessProfile profile,
    required bool isDefault,
  }) {
    TemplatePreviewScreen.show(
      context: context,
      template: template,
      documentType: type,
      profile: profile,
      isDefault: isDefault,
      onSetDefault: () => _setDefault(type, template),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkCanvas : AppColors.canvas,
      appBar: AppBar(
        title: Text(
          'Default Templates',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
            letterSpacing: -0.3,
          ),
        ),
        centerTitle: true,
        backgroundColor: isDark ? AppColors.darkCanvas : AppColors.canvas,
        foregroundColor: isDark
            ? AppColors.darkTextPrimary
            : AppColors.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(54),
          child: Container(
            height: 42,
            margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurface : const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDark ? AppColors.darkBorder : const Color(0xFFE2E8F0),
                width: 0.8,
              ),
            ),
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                color: isDark ? AppColors.darkSurfaceVariant : Colors.white,
                borderRadius: BorderRadius.circular(9),
                border: Border.all(
                  color: isDark
                      ? AppColors.darkBorder
                      : AppColors.border.withValues(alpha: 0.4),
                  width: 0.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.06),
                    blurRadius: 4,
                    offset: const Offset(0, 1.5),
                  ),
                ],
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              dividerColor: Colors.transparent,
              splashFactory: NoSplash.splashFactory,
              overlayColor: WidgetStateProperty.all(Colors.transparent),
              labelColor: isDark ? AppColors.primaryDark : AppColors.primary,
              unselectedLabelColor: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.textSecondary,
              labelStyle: const TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.2,
              ),
              unselectedLabelStyle: const TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                letterSpacing: -0.2,
              ),
              tabs: const [
                Tab(text: 'Invoice'),
                Tab(text: 'Quotation'),
                Tab(text: 'Receipt'),
                Tab(text: 'Proforma'),
              ],
            ),
          ),
        ),
      ),
      body: BlocBuilder<BusinessProfileBloc, BusinessProfileState>(
        buildWhen: (previous, current) {
          if (previous.runtimeType != current.runtimeType) return true;
          if (previous is BusinessProfileLoaded &&
              current is BusinessProfileLoaded) {
            return previous.profile != current.profile;
          }
          return false;
        },
        builder: (context, state) {
          if (state is BusinessProfileError) {
            return Center(child: Text('Error: ${state.message}'));
          }
          if (state is! BusinessProfileLoaded) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          final profile = state.profile;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Center(child: AdBannerWidget()),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: _types.map((type) {
                    final templates = _cachedTemplates[type] ?? const [];
                    final currentDefaultId =
                        _resolveCurrentDefaultId(type, templates);

                    return _TemplateTabContent(
                      key: ValueKey(type),
                      type: type,
                      currentDefaultId: currentDefaultId,
                      templates: templates,
                      color: _getDocumentColor(type),
                      icon: _getDocumentIcon(type),
                      profile: profile,
                      isDark: isDark,
                      onPreview: (template, isDefault) => _openPreview(
                        context: context,
                        template: template,
                        type: type,
                        profile: profile,
                        isDefault: isDefault,
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _TemplateTabContent extends StatefulWidget {
  final DocumentType type;
  final String currentDefaultId;
  final List<TemplateInfo> templates;
  final Color color;
  final IconData icon;
  final BusinessProfile profile;
  final bool isDark;
  final void Function(TemplateInfo template, bool isDefault) onPreview;

  const _TemplateTabContent({
    super.key,
    required this.type,
    required this.currentDefaultId,
    required this.templates,
    required this.color,
    required this.icon,
    required this.profile,
    required this.isDark,
    required this.onPreview,
  });

  @override
  State<_TemplateTabContent> createState() => _TemplateTabContentState();
}

class _TemplateTabContentState extends State<_TemplateTabContent>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final currentTemplate = TemplateRegistry.getById(widget.currentDefaultId);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Active default banner
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: widget.isDark ? AppColors.darkSurface : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: widget.isDark
                    ? AppColors.darkBorder
                    : Colors.grey.withValues(alpha: 0.15),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.02),
                  blurRadius: 4,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: widget.color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(widget.icon, color: widget.color, size: 16),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text.rich(
                    TextSpan(
                      text: 'Active Default: ',
                      style: TextStyle(
                        fontSize: 12,
                        color: widget.isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.textSecondary,
                      ),
                      children: [
                        TextSpan(
                          text: currentTemplate.name,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: widget.color,
                          ),
                        ),
                        TextSpan(
                          text: ' • Tap any design to preview & set default',
                          style: TextStyle(
                            fontSize: 12,
                            color: widget.isDark
                                ? AppColors.darkTextMuted
                                : AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // Curated Templates in 2-column Grid
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            gridDelegate: _DefaultTemplatesScreenState._gridDelegate,
            itemCount: widget.templates.length,
            itemBuilder: (context, index) {
              final t = widget.templates[index];
              final isSelected = t.id == widget.currentDefaultId;

              return TemplateThumbnailCard(
                template: t,
                isSelected: isSelected,
                documentType: widget.type,
                onTap: () => widget.onPreview(t, isSelected),
              );
            },
          ),
        ),
      ],
    );
  }
}
