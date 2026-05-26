import 'package:control_horario/features/admin/presentation/widgets/admin_sidebar.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Test harness that wraps [AdminSidebar] with a [GoRouter] ancestor.
///
/// AdminSidebar requires GoRouter context for route matching and navigation.
class AdminSidebarHarness extends StatelessWidget {
  const AdminSidebarHarness({super.key});

  @override
  Widget build(BuildContext context) {
    return const AdminSidebar(currentRoute: '/admin');
  }
}
