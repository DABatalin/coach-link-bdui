import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'routes.dart';

class ShellScaffold extends StatelessWidget {
  const ShellScaffold({
    super.key,
    required this.currentLocation,
    required this.role,
    required this.child,
  });

  final String currentLocation;
  final String role;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final tabs = role == 'coach' ? _coachTabs : _athleteTabs;
    final currentIndex = _currentIndex(tabs);

    return Scaffold(
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (index) => context.go(tabs[index].route),
        items: tabs
            .map((tab) => BottomNavigationBarItem(
                  icon: Icon(tab.icon),
                  activeIcon: Icon(tab.activeIcon),
                  label: tab.label,
                ))
            .toList(),
      ),
    );
  }

  int _currentIndex(List<_TabItem> tabs) {
    for (int i = 0; i < tabs.length; i++) {
      if (currentLocation.startsWith(tabs[i].route)) return i;
    }
    return 0;
  }
}

class _TabItem {
  const _TabItem({
    required this.route,
    required this.icon,
    required this.activeIcon,
    required this.label,
  });

  final String route;
  final IconData icon;
  final IconData activeIcon;
  final String label;
}

const _coachTabs = [
  _TabItem(
    route: AppRoutes.coachDashboard,
    icon: Icons.home_outlined,
    activeIcon: Icons.home,
    label: 'Главная',
  ),
  _TabItem(
    route: AppRoutes.coachAssignments,
    icon: Icons.assignment_outlined,
    activeIcon: Icons.assignment,
    label: 'Задания',
  ),
  _TabItem(
    route: AppRoutes.coachGroups,
    icon: Icons.groups_outlined,
    activeIcon: Icons.groups,
    label: 'Группы',
  ),
  _TabItem(
    route: AppRoutes.coachProfile,
    icon: Icons.person_outline,
    activeIcon: Icons.person,
    label: 'Профиль',
  ),
];

const _athleteTabs = [
  _TabItem(
    route: AppRoutes.athleteDashboard,
    icon: Icons.home_outlined,
    activeIcon: Icons.home,
    label: 'Главная',
  ),
  _TabItem(
    route: AppRoutes.athleteAssignments,
    icon: Icons.assignment_outlined,
    activeIcon: Icons.assignment,
    label: 'Задания',
  ),
  _TabItem(
    route: AppRoutes.athleteGroups,
    icon: Icons.groups_outlined,
    activeIcon: Icons.groups,
    label: 'Группы',
  ),
  _TabItem(
    route: AppRoutes.athleteProfile,
    icon: Icons.person_outline,
    activeIcon: Icons.person,
    label: 'Профиль',
  ),
];
