import 'package:flutter/material.dart';

import '../../core/domain/user_role.dart';
import '../../core/theme/app_colors.dart';
import '../../features/agenda/presentation/pages/agenda_page.dart';
import '../../features/care/presentation/pages/care_inbox_page.dart';
import '../../features/care/presentation/widgets/mood_checkin_sheet.dart';
import '../../features/feed/presentation/pages/feed_page.dart';
import '../../features/groups/presentation/pages/groups_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../../features/reading/presentation/pages/reading_tab.dart';
import '../di/app_scope.dart';
import 'app_bottom_nav.dart';
import 'app_nav_scope.dart';
import 'app_tab.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key, this.askFeeling = true});

  final bool askFeeling;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  var _currentId = 'home';
  UserRole _role = UserRole.member;
  var _started = false;
  var _carePending = 0;

  bool get _pastor => _role.isPastor;

  List<NavDestination> get _items =>
      navForPastor(_pastor, careBadge: _carePending);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    _boot();
  }

  Future<void> _boot() async {
    await _loadRole();
    if (!mounted) return;
    if (_role == UserRole.member && widget.askFeeling) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _maybeAskFeeling();
      });
    }
    if (_role.isPastor) {
      await _loadCareBadge();
    }
  }

  Future<void> _loadRole() async {
    try {
      final profile = await AppScope.of(context).getProfile();
      if (!mounted) return;
      setState(() => _role = profile.role);
    } catch (_) {}
  }

  Future<void> _loadCareBadge() async {
    try {
      final items = await AppScope.of(context).getCareInbox();
      if (!mounted) return;
      setState(() => _carePending = items.length);
    } catch (_) {}
  }

  Future<void> _maybeAskFeeling() async {
    if (!mounted || _role != UserRole.member || !widget.askFeeling) return;
    try {
      final deps = AppScope.of(context);
      if (!mounted) return;
      await showDailyFeelingDialog(
        context,
        submit: deps.submitMoodCheckin,
        analyze: deps.analyzeCheckin,
      );
      deps.feedReload.ping();
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return AppNavScope(
      select: _onSelect,
      child: Scaffold(
        backgroundColor: AppColors.slate900,
        body: DecoratedBox(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [AppColors.slate950, AppColors.slate900],
            ),
          ),
          child: IndexedStack(
            index: _pageIndex,
            children: [
              FeedPage(pastor: _pastor),
              GroupsPage(pastor: _pastor, canDirect: _role.canLead),
              if (_pastor) const CareInboxPage(asTab: true),
              if (!_pastor) const ReadingTab(),
              AgendaPage(role: _role),
              const ProfilePage(),
            ],
          ),
        ),
        bottomNavigationBar: AppBottomNav(
          items: _items,
          currentId: _currentId,
          onSelect: _onSelect,
        ),
      ),
    );
  }

  int get _pageIndex {
    if (_pastor) {
      return switch (_currentId) {
        'groups' => 1,
        'care' => 2,
        'agenda' => 3,
        'profile' => 4,
        _ => 0,
      };
    }
    return switch (_currentId) {
      'groups' => 1,
      'plans' => 2,
      'agenda' => 3,
      'profile' => 4,
      _ => 0,
    };
  }

  void _onSelect(String id) {
    setState(() => _currentId = id);
    if (_pastor &&
        (id == 'notices' || id == 'care' || id == 'profile' || id == 'home')) {
      _loadCareBadge();
      if (id == 'care' && mounted) {
        AppScope.of(context).feedReload.ping();
      }
    }
  }
}
