import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../features/feed/presentation/pages/feed_page.dart';
import '../../features/groups/presentation/pages/groups_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../../features/reading/presentation/widgets/log_reading_sheet.dart';
import '../../features/shelf/presentation/pages/shelf_page.dart';
import '../di/app_scope.dart';
import 'app_bottom_nav.dart';
import 'app_tab.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  AppTab _tab = AppTab.feed;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      body: IndexedStack(
        index: _tab.index,
        children: const [
          FeedPage(),
          ShelfPage(),
          GroupsPage(),
          ProfilePage(),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(top: 18),
        child: SizedBox(
          width: 64,
          height: 64,
          child: FloatingActionButton(
            onPressed: _openLogSheet,
            elevation: 3,
            backgroundColor: AppColors.orange,
            foregroundColor: AppColors.white,
            shape: const CircleBorder(),
            child: const Icon(Icons.add_rounded, size: 34),
          ),
        ),
      ),
      bottomNavigationBar: AppBottomNav(
        current: _tab,
        onSelect: (tab) => setState(() => _tab = tab),
      ),
    );
  }

  Future<void> _openLogSheet() async {
    final logged = await showLogReadingSheet(
      context,
      logReading: AppScope.of(context).logReading,
    );
    if (!logged || !mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Leitura registrada')),
    );
  }
}
