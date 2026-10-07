import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

import '../../../../core/theming/app_text_styles.dart';

class HomeBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const HomeBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Register this widget as a localization dependent so persistent shells
    // rebuild immediately when EasyLocalization changes locale.
    context.locale;

    final bottomSafePadding = MediaQuery.viewPaddingOf(context).bottom;
    final items = <_NavItem>[
      _NavItem(icon: Icons.home_outlined, labelKey: 'home.nav_home'),
      _NavItem(icon: Icons.credit_card_outlined, labelKey: 'home.nav_ecard'),
      _NavItem(icon: Icons.receipt_long_outlined, labelKey: 'home.nav_invoices'),
      _NavItem(
        icon: Icons.person_outline_rounded,
        labelKey: 'home.nav_profile',
      ),
    ];

    return Container(
      color: Colors.transparent,
      padding: EdgeInsets.only(bottom: bottomSafePadding),
      child: Container(
        height: 74,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
          border: Border.all(color: const Color(0xFFD9DDE5)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
          child: Row(
            children: List.generate(items.length, (i) {
              return Expanded(
                child: _NavColumn(
                  item: items[i],
                  isSelected: currentIndex == i,
                  onTap: () => onTap(i),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final String labelKey;
  const _NavItem({required this.icon, required this.labelKey});
}

class _NavColumn extends StatelessWidget {
  final _NavItem item;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavColumn({
    required this.item,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const activeColor = Color(0xFF3976B7);
    const inactiveColor = Color(0xFF6C6C6C);
    final color = isSelected ? activeColor : inactiveColor;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        height: 74,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(item.icon, size: 24, color: color),
            const SizedBox(height: 7),
            Text(
              item.labelKey.tr(context: context),
              style: AppTextStyles.of(
                color: color,
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
