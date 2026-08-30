import 'package:flutter/material.dart';

import '../../core/domain/user_role.dart';
import '../../core/theme/app_colors.dart';
import '../../features/care/presentation/pages/care_inbox_page.dart';
import '../../features/care/presentation/widgets/mood_checkin_sheet.dart';
import '../../features/feed/presentation/pages/feed_page.dart';
import '../../features/groups/presentation/pages/groups_page.dart';
import '../../features/members/presentation/pages/members_page.dart';
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
            gradient: RadialGradient(
              center: Alignment.topRight,
              radius: 1.1,
              colors: [Color(0x1FE3703A), AppColors.slate900],
            ),
          ),
          child: IndexedStack(
            index: _pageIndex,
            children: [
              FeedPage(pastor: _pastor),
              if (!_pastor) const ReadingTab(),
              GroupsPage(pastor: _pastor, canDirect: _role.canLead),
              if (_pastor) const CareInboxPage(asTab: true),
              if (_pastor) const MembersPage(),
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
        'notices' => 2,
        'members' => 3,
        'profile' => 4,
        _ => 0,
      };
    }
    return switch (_currentId) {
      'plans' => 1,
      'groups' => 2,
      'profile' => 3,
      _ => 0,
    };
  }

  void _onSelect(String id) {
    setState(() => _currentId = id);
    if (_pastor &&
        (id == 'notices' ||
            id == 'members' ||
            id == 'profile' ||
            id == 'home')) {
      _loadCareBadge();
      if (id == 'notices' && mounted) {
        AppScope.of(context).feedReload.ping();
      }
    }
  }
}
