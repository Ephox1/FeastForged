import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.child});

  final Widget child;

  static const _tabs = [
    ('/app/dashboard', 'Dashboard', Icons.dashboard_outlined),
    ('/app/planner', 'Planner', Icons.calendar_month_outlined),
    ('/app/recipes', 'Recipes', Icons.menu_book_outlined),
    ('/app/profile', 'Profile', Icons.person_outline),
  ];

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    final currentIndex = _tabs.indexWhere(
      (tab) => location.startsWith(tab.$1),
    );

    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex < 0 ? 0 : currentIndex,
        onDestinationSelected: (index) => context.go(_tabs[index].$1),
        destinations: _tabs
            .map(
              (tab) => NavigationDestination(
                icon: Icon(tab.$3),
                label: tab.$2,
              ),
            )
            .toList(),
      ),
    );
  }
}
