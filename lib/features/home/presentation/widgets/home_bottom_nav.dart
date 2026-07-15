import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../../core/widgets/auth_shared_widgets.dart';

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
    final items = <_NavItem>[
      _NavItem(icon: Icons.home_outlined, labelKey: 'home.nav_home'),
      _NavItem(icon: Icons.access_time_outlined, labelKey: 'home.nav_activity'),
      _NavItem(
        icon: Icons.person_outline_rounded,
        labelKey: 'home.nav_profile',
      ),
    ];

    return Container(
      color: Colors.transparent,
      padding: const EdgeInsets.only(left: 24, right: 24, bottom: 20),
      child: Container(
        height: 64,
        decoration: BoxDecoration(
          color: kAuthBlue,
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            BoxShadow(
              color: kAuthBlue.withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(32),
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
    const activeColor = Color(0xFFFFD700);
    const inactiveColor = Colors.white;
    final color = isSelected ? activeColor : inactiveColor;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        height: 64,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(item.icon, size: 24, color: color),
                const SizedBox(height: 3),
                Text(
                  item.labelKey.tr(),
                  style: TextStyle(
                    fontFamily: 'Inter',
                    color: color,
                    fontSize: 10,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
            if (isSelected)
              Positioned(
                bottom: 0,
                child: Container(
                  width: 24,
                  height: 4,
                  decoration: const BoxDecoration(
                    color: activeColor,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(4),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
