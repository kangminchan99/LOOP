import 'package:flutter/material.dart';
import 'package:loop/l10n/app_localizations.dart';
import 'package:loop/src/core/layout/responsive_layout.dart';

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
    return ResponsiveLayout(
      mobile: _MobileShell(
        currentPageIndex: currentPageIndex,
        onDestinationSelected: onDestinationSelected,
        child: child,
      ),
      tablet: _RailShell(
        currentPageIndex: currentPageIndex,
        onDestinationSelected: onDestinationSelected,
        child: child,
      ),
    );
  }
}

class _MobileShell extends StatelessWidget {
  const _MobileShell({
    required this.child,
    required this.currentPageIndex,
    required this.onDestinationSelected,
  });

  final Widget child;
  final int currentPageIndex;
  final ValueChanged<int> onDestinationSelected;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentPageIndex,
        onDestinationSelected: onDestinationSelected,
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.home_outlined),
            selectedIcon: const Icon(Icons.home),
            label: l10n.appShellHome,
          ),
          NavigationDestination(
            icon: const Icon(Icons.settings_outlined),
            selectedIcon: const Icon(Icons.settings),
            label: l10n.appShellMyPage,
          ),
        ],
      ),
    );
  }
}

class _RailShell extends StatelessWidget {
  const _RailShell({
    required this.child,
    required this.currentPageIndex,
    required this.onDestinationSelected,
  });

  final Widget child;
  final int currentPageIndex;
  final ValueChanged<int> onDestinationSelected;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: currentPageIndex,
            onDestinationSelected: onDestinationSelected,
            labelType: NavigationRailLabelType.all,
            destinations: [
              NavigationRailDestination(
                icon: const Icon(Icons.home_outlined),
                selectedIcon: const Icon(Icons.home),
                label: Text(l10n.appShellHome),
              ),
              NavigationRailDestination(
                icon: const Icon(Icons.settings_outlined),
                selectedIcon: const Icon(Icons.settings),
                label: Text(l10n.appShellMyPage),
              ),
            ],
          ),
          const VerticalDivider(width: 1),
          Expanded(child: child),
        ],
      ),
    );
  }
}
