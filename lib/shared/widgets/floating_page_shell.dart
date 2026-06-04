import 'package:flutter/material.dart';
import '../../core/theme/app_spacing.dart';
import 'floating_page_header.dart';

class FloatingPageShell extends StatelessWidget {
  final Widget header;
  final Widget child;
  final double headerTopOffset;

  const FloatingPageShell({
    super.key,
    required this.header,
    required this.child,
    this.headerTopOffset = FloatingPageHeader.desktopTopOffset,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.xxxl,
            FloatingPageHeader.desktopReservedHeight,
            AppSpacing.xxxl,
            AppSpacing.xxxl,
          ),
          child: child,
        ),
        Positioned(
          top: headerTopOffset,
          left: AppSpacing.xxxl,
          right: AppSpacing.xxxl,
          child: header,
        ),
      ],
    );
  }
}
