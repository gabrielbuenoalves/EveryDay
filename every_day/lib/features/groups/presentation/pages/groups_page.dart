import 'package:flutter/material.dart';

import '../../../../app/di/app_scope.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_avatar.dart';
import '../../../../core/widgets/screen_header.dart';
import '../../domain/entities/reading_group.dart';
import '../../domain/usecases/get_groups.dart';

class GroupsPage extends StatefulWidget {
  const GroupsPage({super.key});

  @override
  State<GroupsPage> createState() => _GroupsPageState();
}

class _GroupsPageState extends State<GroupsPage> {
  List<ReadingGroup>? _groups;
  var _started = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    _load(AppScope.of(context).getGroups);
  }

  Future<void> _load(GetGroups getGroups) async {
    final groups = await getGroups();
    if (!mounted) return;
    setState(() {
      _groups = groups;
    });
  }

  @override
  Widget build(BuildContext context) {
    final groups = _groups;

    return SafeArea(
      bottom: false,
      child: Column(
        children: [
          const ScreenHeader(title: 'Grupos'),
          Expanded(
            child: groups == null
                ? const Center(
                    child: CircularProgressIndicator(color: AppColors.orange),
                  )
                : ListView(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
                    children: [
                      for (final group in groups) ...[
                        _GroupCard(group: group),
                        const SizedBox(height: 14),
                      ],
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

class _GroupCard extends StatelessWidget {
  const _GroupCard({required this.group});

  final ReadingGroup group;

  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(group.name, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 4),
          Text(group.planLabel, style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: LinearProgressIndicator(
              value: group.weekProgress,
              minHeight: 8,
              backgroundColor: AppColors.creamDark,
              color: AppColors.forest,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              SizedBox(
                width: 28.0 + ((group.members.length - 1) * 22),
                height: 32,
                child: Stack(
                  children: [
                    for (var i = 0; i < group.members.length; i++)
                      Positioned(
                        left: i * 22,
                        child: AppAvatar(
                          initials: group.members[i].initials,
                          color: Color(group.members[i].avatarColorValue),
                          size: 32,
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Text(
                '${group.memberCount} pessoas',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
