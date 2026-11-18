import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'main_navigation_bar.dart';

/// Application navigation owns the dock and the lifetime of the three branches.
/// Feature pages own their content and never render another primary dock.
class MainShell extends StatelessWidget {
  const MainShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  void _select(int index) {
    if (index == navigationShell.currentIndex) return;
    FocusManager.instance.primaryFocus?.unfocus();
    navigationShell.goBranch(index);
  }

  @override
  Widget build(BuildContext context) => AnnotatedRegion<SystemUiOverlayStyle>(
    value: SystemUiOverlayStyle(
      systemNavigationBarColor: Theme.of(context).colorScheme.surface,
      systemNavigationBarIconBrightness:
          Theme.of(context).brightness == Brightness.dark
          ? Brightness.light
          : Brightness.dark,
    ),
    child: PopScope(
      canPop: navigationShell.currentIndex == 0,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _select(0);
      },
      child: Scaffold(
        body: navigationShell,
        bottomNavigationBar: MainNavigationBar(
          selectedIndex: navigationShell.currentIndex,
          onSelected: _select,
        ),
      ),
    ),
  );
}
