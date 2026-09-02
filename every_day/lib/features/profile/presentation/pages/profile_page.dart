import 'package:flutter/material.dart';

import '../../../../app/di/app_scope.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_avatar.dart';
import '../../../../core/widgets/streak_badge.dart';
import '../../../../core/widgets/screen_header.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/usecases/get_profile.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  UserProfile? _profile;
  var _started = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    _load(AppScope.of(context).getProfile);
  }

  Future<void> _load(GetProfile getProfile) async {
    final profile = await getProfile();
    if (!mounted) return;
    setState(() {
      _profile = profile;
    });
  }

  @override
  Widget build(BuildContext context) {
    final profile = _profile;

    return SafeArea(
      bottom: false,
      child: Column(
        children: [
          ScreenHeader(
            title: 'Perfil',
            trailing: profile == null
                ? null
                : StreakBadge(days: profile.streakDays),
          ),
          Expanded(
            child: profile == null
                ? const Center(
                    child: CircularProgressIndicator(color: AppColors.orange),
                  )
                : ListView(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
                    children: [
                      SurfaceCard(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            AppAvatar(
                              initials: profile.initials,
                              color: Color(profile.avatarColorValue),
                              size: 84,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              profile.displayName,
                              style: Theme.of(context).textTheme.headlineMedium,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Lendo ${profile.currentPlan}',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: _StatCard(
                              label: 'Capítulos',
                              value: '${profile.stats.chaptersThisWeek}',
                              hint: 'nesta semana',
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _StatCard(
                              label: 'Livros',
                              value: '${profile.stats.booksCompleted}',
                              hint: 'concluídos',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _StatCard(
                              label: 'Minutos',
                              value: '${profile.stats.minutesThisWeek}',
                              hint: 'nesta semana',
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _StatCard(
                              label: 'Recorde',
                              value: '${profile.longestStreak}',
                              hint: 'dias seguidos',
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.hint,
  });

  final String label;
  final String value;
  final String hint;

  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: Theme.of(context).textTheme.labelSmall,
          ),
          const SizedBox(height: 8),
          Text(value, style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 4),
          Text(hint, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }
}
