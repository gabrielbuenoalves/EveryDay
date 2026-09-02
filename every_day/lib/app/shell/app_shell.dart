import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../features/community/presentation/community_pages.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _index = 0;

  static const _pages = <Widget>[
    HomePage(),
    GroupsHubPage(),
    CarePage(),
    AgendaPage(),
    ProfileHubPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: IndexedStack(index: _index, children: _pages),
      bottomNavigationBar: _NavigationBar(
        index: _index,
        onTap: (value) => setState(() => _index = value),
      ),
    );
  }
}

class _NavigationBar extends StatelessWidget {
  const _NavigationBar({required this.index, required this.onTap});

  final int index;
  final ValueChanged<int> onTap;

  static const labels = ['Início', 'Grupos', 'Cuidado', 'Agenda', 'Perfil'];
  static const icons = [
    Icons.home_rounded,
    Icons.groups_rounded,
    Icons.favorite_rounded,
    Icons.calendar_month_rounded,
    Icons.person_rounded,
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.divider)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 76,
          child: Row(
            children: List.generate(
              labels.length,
              (item) => Expanded(
                child: InkWell(
                  onTap: () => onTap(item),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        icons[item],
                        color: item == index
                            ? AppColors.orange
                            : AppColors.muted,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        labels[item],
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: item == index
                              ? AppColors.white
                              : AppColors.muted,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
