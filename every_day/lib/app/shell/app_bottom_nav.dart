import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/widgets/nav_icons.dart';
import 'app_tab.dart';

class AppBottomNav extends StatelessWidget {
  const AppBottomNav({
    super.key,
    required this.current,
    required this.onSelect,
  });

  final AppTab current;
  final ValueChanged<AppTab> onSelect;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: AppColors.white,
        border: Border(top: BorderSide(color: AppColors.divider)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 72,
          child: Row(
            children: [
              _Item(
                tab: AppTab.feed,
                selected: current == AppTab.feed,
                onSelect: onSelect,
              ),
              _Item(
                tab: AppTab.shelf,
                selected: current == AppTab.shelf,
                onSelect: onSelect,
              ),
              const SizedBox(width: 72),
              _Item(
                tab: AppTab.groups,
                selected: current == AppTab.groups,
                onSelect: onSelect,
              ),
              _Item(
                tab: AppTab.profile,
                selected: current == AppTab.profile,
                onSelect: onSelect,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Item extends StatelessWidget {
  const _Item({
    required this.tab,
    required this.selected,
    required this.onSelect,
  });

  final AppTab tab;
  final bool selected;
  final ValueChanged<AppTab> onSelect;

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.charcoal : AppColors.navInactive;

    return Expanded(
      child: InkWell(
        onTap: () => onSelect(tab),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _icon(color),
            const SizedBox(height: 6),
            Text(
              tab.label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _icon(Color color) {
    return switch (tab) {
      AppTab.feed => FeedNavIcon(color: color),
      AppTab.shelf => ShelfNavIcon(color: color),
      AppTab.groups => GroupsNavIcon(color: color),
      AppTab.profile => ProfileNavIcon(color: color),
    };
  }
}
