import 'package:flutter/material.dart';

import '../../core/theme/color_schemes.dart';
import '../../core/theme/text_styles.dart';

class BottomNavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  const BottomNavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}

/// Bottom navigation matching the reference app — pill highlight,
/// active/inactive icon swap, optional badge.
class AppBottomNavBar extends StatelessWidget {
  final List<BottomNavItem> items;
  final int currentIndex;
  final ValueChanged<int> onChanged;
  final int badgeIndex;
  final int badgeCount;

  const AppBottomNavBar({
    super.key,
    required this.items,
    required this.currentIndex,
    required this.onChanged,
    this.badgeIndex = -1,
    this.badgeCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(
          top: BorderSide(
            color: AppColors.border.withValues(alpha: 0.7),
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              for (var i = 0; i < items.length; i++)
                Expanded(child: _buildItem(context, i, items[i])),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildItem(BuildContext context, int index, BottomNavItem item) {
    final selected = currentIndex == index;
    final showBadge = index == badgeIndex && badgeCount > 0;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => onChanged(index),
        borderRadius: BorderRadius.circular(12),
        splashColor: AppColors.primary.withValues(alpha: 0.08),
        highlightColor: Colors.transparent,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 6),
          decoration: BoxDecoration(
            color: selected
                ? AppColors.primary.withValues(alpha: 0.08)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Icon(
                    selected ? item.activeIcon : item.icon,
                    size: 22,
                    color: selected ? AppColors.primary : AppColors.ink400,
                  ),
                  if (showBadge)
                    Positioned(
                      top: -4,
                      right: -8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 4, vertical: 1),
                        constraints: const BoxConstraints(minWidth: 16),
                        decoration: BoxDecoration(
                          color: AppColors.danger,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '$badgeCount',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 3),
              Text(
                item.label,
                style: AppTextStyles.caption.copyWith(
                  fontSize: 11,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                  color: selected ? AppColors.primary : AppColors.ink400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
