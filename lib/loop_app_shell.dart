import 'package:flutter/material.dart';

class LoopAppShell extends StatelessWidget {
  final Widget child;
  final int currentPageIndex;
  final ValueChanged<int> onDestinationSelected;
  const LoopAppShell({
    super.key,
    required this.child,
    required this.currentPageIndex,
    required this.onDestinationSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        onDestinationSelected: onDestinationSelected,
        selectedIndex: currentPageIndex,
        destinations: [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: '홈',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: '마이페이지',
          ),
        ],
      ),
    );
  }
}
