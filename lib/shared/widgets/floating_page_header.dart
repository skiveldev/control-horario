import 'package:flutter/material.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import 'floating_card.dart';

class FloatingPageHeader extends StatelessWidget {
  static const double desktopHeight = 64.0;
  static const double desktopTopOffset = 0.0;
  static const double desktopReservedHeight =
      desktopHeight + AppSpacing.xxxl + desktopTopOffset;

  final String title;
  final IconData icon;
  final BuildContext scaffoldContext;
  final bool isMobile;

  const FloatingPageHeader({
    super.key,
    required this.title,
    required this.icon,
    required this.scaffoldContext,
    required this.isMobile,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final canGoBack = Navigator.of(scaffoldContext).canPop();

    final row = Row(
      children: [
        if (isMobile) ...[
          IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(scaffoldContext).openDrawer(),
            tooltip: 'Abrir menú',
          ),
          AppSpacing.horizontalSpaceMd,
        ],
        if (canGoBack) ...[
          IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(scaffoldContext).pop(),
            tooltip: 'Volver',
          ),
          AppSpacing.horizontalSpaceMd,
        ],
        Icon(icon, size: 24, color: cs.primary),
        AppSpacing.horizontalSpaceMd,
        Flexible(
          child: Text(
            title,
            style: AppTextStyles.h4,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );

    if (!isMobile) {
      return SizedBox(
        height: desktopHeight,
        child: FloatingCard(
          child: Padding(
            padding: AppSpacing.horizontalLg,
            child: row,
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: cs.surface,
        border: Border(
          bottom: BorderSide(color: Theme.of(context).dividerColor, width: 1),
        ),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.lg,
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 48),
            child: row,
          ),
        ),
      ),
    );
  }
}
