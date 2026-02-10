import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';

class HomeScreen extends ConsumerWidget {
  final Widget child;

  const HomeScreen({super.key, required this.child});

  static final _tabs = [
    const _TabItem(icon: Icons.dashboard_rounded, label: 'Accueil', path: '/'),
    const _TabItem(icon: Icons.checklist_rounded, label: 'Tâches', path: '/checklist'),
    const _TabItem(icon: Icons.account_balance_wallet_rounded, label: 'Budget', path: '/budget'),
    const _TabItem(icon: Icons.people_rounded, label: 'Invités', path: '/guests'),
    const _TabItem(icon: Icons.calendar_month_rounded, label: 'Planning', path: '/timeline'),
  ];

  int _currentIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    for (int i = _tabs.length - 1; i >= 0; i--) {
      if (location.startsWith(_tabs[i].path) && 
          (_tabs[i].path == '/' ? location == '/' : true)) {
        return i;
      }
    }
    return 0;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final index = _currentIndex(context);

    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (i) => context.go(_tabs[i].path),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 1,
        indicatorColor: AppTheme.primary.withOpacity(0.1),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        height: 65,
        destinations: _tabs.map((tab) {
          return NavigationDestination(
            icon: Icon(tab.icon, color: Colors.grey.shade500),
            selectedIcon: Icon(tab.icon, color: AppTheme.primary),
            label: tab.label,
          );
        }).toList(),
      ),
    );
  }
}

class _TabItem {
  final IconData icon;
  final String label;
  final String path;

  const _TabItem({required this.icon, required this.label, required this.path});
}
