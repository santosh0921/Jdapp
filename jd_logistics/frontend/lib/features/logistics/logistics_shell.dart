import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:jd_style_logistics/core/widgets/custom_bottom_nav.dart';

const _kLogisticsColor = Color(0xFF0D9488);

class LogisticsShell extends StatefulWidget {
  final StatefulNavigationShell navigationShell;
  const LogisticsShell({super.key, required this.navigationShell});

  @override
  State<LogisticsShell> createState() => _LogisticsShellState();
}

class _LogisticsShellState extends State<LogisticsShell> {
  DateTime? _lastBackPress;

  static const _items = [
    JdNavItem(icon: Icons.home_outlined, activeIcon: Icons.home_rounded, label: 'Home'),
    JdNavItem(icon: Icons.swap_horiz_outlined, activeIcon: Icons.swap_horiz_rounded, label: 'Shipments'),
    JdNavItem(icon: Icons.inventory_2_outlined, activeIcon: Icons.inventory_2_rounded, label: 'Cargo'),
    JdNavItem(icon: Icons.description_outlined, activeIcon: Icons.description_rounded, label: 'Docs'),
    JdNavItem(icon: Icons.person_outline_rounded, activeIcon: Icons.person_rounded, label: 'Profile'),
  ];

  Future<bool> _onPop() async {
    if (widget.navigationShell.currentIndex != 0) {
      widget.navigationShell.goBranch(0, initialLocation: true);
      return false;
    }
    final now = DateTime.now();
    if (_lastBackPress == null || now.difference(_lastBackPress!) > const Duration(seconds: 2)) {
      _lastBackPress = now;
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Press back again to exit'),
            duration: Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      return false;
    }
    await SystemNavigator.pop();
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (!didPop) await _onPop();
      },
      child: Scaffold(
        extendBody: true,
        body: widget.navigationShell,
        bottomNavigationBar: JdBottomNav(
          currentIndex: widget.navigationShell.currentIndex,
          items: _items,
          activeColor: _kLogisticsColor,
          onTap: (index) => widget.navigationShell.goBranch(
            index,
            initialLocation: index == widget.navigationShell.currentIndex,
          ),
        ),
      ),
    );
  }
}
