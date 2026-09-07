import 'package:flutter/material.dart';

import '../../features/pastor/presentation/pages/pastor_agenda_page.dart';
import '../../features/pastor/presentation/pages/pastor_care_page.dart';
import '../../features/pastor/presentation/pages/pastor_dashboard_page.dart';
import '../../features/pastor/presentation/pages/pastor_groups_page.dart';
import '../../features/pastor/presentation/pages/pastor_profile_page.dart';
import '../../features/pastor/presentation/theme/pastor_theme.dart';
import '../../features/pastor/presentation/widgets/pastor_widgets.dart';

enum PastorTab { home, groups, care, agenda, profile }

/// Visual-only shell for the pastor experience.
///
/// Data shown in this module is demonstrative. Domain/state wiring is deferred
/// until the app's state-management boundary is agreed with the team.
class PastorShell extends StatefulWidget {
  const PastorShell({super.key});

  @override
  State<PastorShell> createState() => _PastorShellState();
}

class _PastorShellState extends State<PastorShell> {
  var _currentTab = PastorTab.home;

  void _select(PastorTab tab) {
    if (_currentTab == tab) return;
    setState(() => _currentTab = tab);
  }

  void _push(Widget page) {
    Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => page));
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: PastorTheme.data(),
      child: Scaffold(
        backgroundColor: PastorPalette.background,
        body: IndexedStack(
          index: _currentTab.index,
          children: [
            PastorDashboardPage(
              onOpenCare: () => _select(PastorTab.care),
              onCreateChallenge: () => _push(const PastorNewChallengePage()),
              onCreateNotice: () => _push(const PastorNewNoticePage()),
            ),
            const PastorGroupsPage(),
            const PastorCarePage(),
            const PastorAgendaPage(),
            const PastorProfilePage(),
          ],
        ),
        bottomNavigationBar: PastorBottomNavigation(
          currentIndex: _currentTab.index,
          onTap: (index) => _select(PastorTab.values[index]),
        ),
      ),
    );
  }
}
