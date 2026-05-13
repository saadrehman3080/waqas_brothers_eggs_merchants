import 'package:animations/animations.dart';
import 'package:flutter/material.dart';

import '../core/constants/app_strings.dart';
import 'credit/credit_screen.dart';
import 'dashboard/dashboard_screen.dart';
import 'history/history_screen.dart';
import 'order/order_screen.dart';
import 'stock/stock_screen.dart';
import 'widgets/bottom_nav_bar.dart';
import 'widgets/no_internet_banner.dart';

/// Bottom-nav shell hosting the five main feature screens.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 3;

  static const List<BottomNavItem> _navItems = [
    BottomNavItem(
      icon: Icons.dashboard_outlined,
      activeIcon: Icons.dashboard_rounded,
      label: AppStrings.dashboard,
    ),
    BottomNavItem(
      icon: Icons.shopping_bag_outlined,
      activeIcon: Icons.shopping_bag_rounded,
      label: AppStrings.order,
    ),
    BottomNavItem(
      icon: Icons.history_outlined,
      activeIcon: Icons.history_rounded,
      label: AppStrings.history,
    ),
    BottomNavItem(
      icon: Icons.credit_card_outlined,
      activeIcon: Icons.credit_card_rounded,
      label: AppStrings.credit,
    ),
    BottomNavItem(
      icon: Icons.inventory_2_outlined,
      activeIcon: Icons.inventory_2_rounded,
      label: AppStrings.stock,
    ),
  ];

  static const List<Widget> _pages = [
    DashboardScreen(),
    OrderScreen(),
    HistoryScreen(),
    CreditScreen(),
    StockScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NoInternetBanner(
        child: SafeArea(
          bottom: false,
          child: PageTransitionSwitcher(
            duration: const Duration(milliseconds: 250),
            transitionBuilder: (child, primary, secondary) {
              return FadeThroughTransition(
                animation: primary,
                secondaryAnimation: secondary,
                child: child,
              );
            },
            child: KeyedSubtree(
              key: ValueKey(_selectedIndex),
              child: _pages[_selectedIndex],
            ),
          ),
        ),
      ),
      bottomNavigationBar: AppBottomNavBar(
        items: _navItems,
        currentIndex: _selectedIndex,
        onChanged: (i) => setState(() => _selectedIndex = i),
      ),
    );
  }
}
