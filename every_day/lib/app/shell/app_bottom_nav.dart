import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import 'app_tab.dart';

class AppBottomNav extends StatelessWidget {
  const AppBottomNav({
    super.key,
    required this.items,
    required this.currentId,
    required this.onSelect,
  });

  final List<NavDestination> items;
  final String currentId;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: const Color(0xFC1A1B24),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.slate700),
            boxShadow: const [
              BoxShadow(
                color: Color(0xA6000000),
                blurRadius: 22,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: SizedBox(
            height: 58,
            child: Row(
              children: [
                for (final item in items)
                  Expanded(
                    child: _NavItem(
                      item: item,
                      selected: !item.create && item.id == currentId,
                      onTap: () => onSelect(item.id),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  final NavDestination item;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    if (item.create) {
      return InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 36,
              height: 36,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.ember,
                borderRadius: BorderRadius.circular(11),
              ),
              child: const Text(
                '+',
                style: TextStyle(
                  color: AppColors.slate950,
                  fontSize: 23,
                  height: 1,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      );
    }

    final color = selected ? AppColors.ember : AppColors.slate400;
    return Material(
      color: selected ? const Color(0x24FF5A16) : Colors.transparent,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _iconWithBadge,
            const SizedBox(height: 1),
            Text(
              item.label,
              style: TextStyle(
                color: color,
                fontSize: 7,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget get _iconWithBadge {
    final icon = Icon(
      _icon,
      color: selected ? AppColors.ember : AppColors.slate400,
      size: 18,
    );
    if (item.badge <= 0) return icon;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        icon,
        Positioned(
          right: -8,
          top: -4,
          child: Container(
            constraints: const BoxConstraints(minWidth: 14, minHeight: 14),
            padding: const EdgeInsets.symmetric(horizontal: 3),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.ember,
              borderRadius: BorderRadius.circular(99),
            ),
            child: Text(
              item.badge > 9 ? '9+' : '${item.badge}',
              style: const TextStyle(
                color: AppColors.slate950,
                fontSize: 8,
                fontWeight: FontWeight.w900,
                height: 1,
              ),
            ),
          ),
        ),
      ],
    );
  }

  IconData get _icon => switch (item.id) {
    'home' => Icons.home_outlined,
    'plans' => Icons.auto_stories_outlined,
    'agenda' => Icons.calendar_month_outlined,
    'groups' => Icons.groups_outlined,
    'notices' => Icons.notifications_outlined,
    'members' => Icons.people_outline,
    'profile' => Icons.person_outline,
    _ => Icons.circle_outlined,
  };
}
