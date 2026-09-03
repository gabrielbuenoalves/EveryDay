import 'package:flutter/material.dart';

import '../../../../app/shell/app_nav_scope.dart';
import '../../../../app/di/app_scope.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/time_ago.dart';
import '../../../../core/widgets/app_avatar.dart';
import '../../../../core/widgets/proto.dart';
import '../../../care/domain/entities/care_models.dart';
import '../../../care/presentation/widgets/care_notice.dart';
import '../../../groups/domain/entities/reading_group.dart';
import '../../../profile/domain/entities/user_profile.dart';
import '../../domain/entities/feed_home.dart';
import '../controllers/feed_controller.dart';

class FeedPage extends StatefulWidget {
  const FeedPage({super.key, this.pastor = false});

  final bool pastor;

  @override
  State<FeedPage> createState() => _FeedPageState();
}

class _FeedPageState extends State<FeedPage> {
  FeedController? _controller;
  List<ReadingGroup> _groups = const [];
  UserProfile? _profile;
  List<CareInboxItem> _careItems = const [];
  Object? _careError;
  var _extrasStarted = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _controller ??= FeedController(
      getFeedHome: AppScope.of(context).getFeedHome,
      reload: AppScope.of(context).feedReload,
    )..load();
    if (_extrasStarted) return;
    _extrasStarted = true;
    _loadExtras();
  }

  Future<void> _loadExtras() async {
    final deps = AppScope.of(context);
    try {
      final groups = await deps.getGroups();
      final profile = await deps.getProfile();
      if (!mounted) return;
      setState(() {
        _groups = groups;
        _profile = profile;
      });
    } catch (_) {}
    if (!widget.pastor) return;
    try {
      final care = await deps.getCareInbox();
      if (!mounted) return;
      setState(() {
        _careItems = care;
        _careError = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _careError = e);
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;
    if (controller == null) return const SizedBox.shrink();

    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final home = controller.home;
        return SafeArea(
          bottom: false,
          child: Column(
            children: [
              AppScreenHeader(
                kicker: weekdayDateKicker(),
                title: widget.pastor
                    ? 'Central da Igreja'
                    : 'Olá, ${_profile?.firstName ?? 'você'}',
                initials: _profile?.initials ?? 'ED',
              ),
              Expanded(
                child: controller.loading && home == null
                    ? const _FeedSkeleton()
                    : RefreshIndicator(
                        color: AppColors.ember,
                        onRefresh: () async {
                          await controller.load();
                          await _loadExtras();
                        },
                        child: ListView(
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
                          children: [
                            if (controller.error != null)
                              Text(
                                '${controller.error}',
                                style: const TextStyle(color: AppColors.ember),
                              ),
                            if (home != null)
                              widget.pastor
                                  ? _PastorHome(
                                      home: home,
                                      groups: _groups,
                                      careItems: _careItems,
                                      careError: _careError,
                                    )
                                  : _MemberHome(home: home, groups: _groups),
                          ],
                        ),
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _MemberHome extends StatelessWidget {
  const _MemberHome({required this.home, required this.groups});

  final FeedHome home;
  final List<ReadingGroup> groups;

  @override
  Widget build(BuildContext context) {
    final firstGroup = groups.isEmpty ? null : groups.first;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const ProtoEmptyState(
          icon: Icons.auto_stories_outlined,
          title: 'Versículo do dia indisponível',
          copy: 'Aguardando integração de dados para esta área.',
        ),
        const ProtoSection(title: 'Seu desafio atual'),
        if (firstGroup == null)
          const ProtoEmptyState(
            icon: Icons.flag_outlined,
            title: 'Nenhum desafio ativo',
            copy: 'Entre em um grupo para receber leituras direcionadas.',
          )
        else
          _ChallengeCard(group: firstGroup),
        const ProtoSection(title: 'Reflexão do pastor'),
        const _PastorReflection(),
        const ProtoSection(title: 'Do seu círculo', trailing: 'Hoje'),
        if (home.items.isEmpty)
          const ProtoCard(
            child: Text(
              'Quando alguém do seu grupo registrar uma leitura, ela aparece aqui.',
              style: TextStyle(color: AppColors.slate400, fontSize: 12),
            ),
          ),
        for (final item in home.items) ...[
          _PostCard(
            item: item,
            groupHint: groups.isEmpty ? null : groups.first.name,
          ),
          const SizedBox(height: 10),
        ],
      ],
    );
  }
}

class _PastorHome extends StatelessWidget {
  const _PastorHome({
    required this.home,
    required this.groups,
    required this.careItems,
    this.careError,
  });

  final FeedHome home;
  final List<ReadingGroup> groups;
  final List<CareInboxItem> careItems;
  final Object? careError;

  @override
  Widget build(BuildContext context) {
    final people = {
      for (final group in groups)
        for (final member in group.members) member.id,
    }.length;
    final community = people == 0 ? home.items.length + 1 : people;
    final avg = groups.isEmpty
        ? 0.0
        : groups.map((group) => group.weekProgress).reduce((a, b) => a + b) /
              groups.length;
    final interactions = home.items.fold<int>(
      0,
      (sum, item) => sum + item.highFives + item.comments,
    );
    final activeGroups = groups
        .where((group) => group.weekProgress >= 0.4)
        .length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _PastorBrief(groups: groups),
        const ProtoSection(
          title: 'Panorama da comunidade',
          trailing: 'Esta semana',
        ),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          childAspectRatio: 1.52,
          children: [
            _MetricCard('Pessoas conectadas', '$community', 'em grupos'),
            _MetricCard(
              'Grupos ativos',
              '$activeGroups',
              'de ${groups.length} grupos',
            ),
            _MetricCard('Leitura', '${(avg * 100).round()}%', 'participação'),
            _MetricCard('Interações', '$interactions', 'nos últimos dias'),
          ],
        ),
        CareNoticeTeaser(items: careItems, error: careError),
        const ProtoSection(title: 'Visão da semana', trailing: 'Participação'),
        ProtoCard(
          child: groups.isEmpty
              ? const Text(
                  'Aguardando integração de métricas semanais.',
                  style: TextStyle(color: AppColors.slate400, fontSize: 11),
                )
              : WeekBars(
                  heights: groups
                      .map((group) => group.weekProgress)
                      .take(7)
                      .toList(),
                ),
        ),
      ],
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard(this.label, this.value, this.hint);

  final String label;
  final String value;
  final String hint;

  @override
  Widget build(BuildContext context) {
    return ProtoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MiniLabel(label),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.slate100,
              fontSize: 23,
              fontWeight: FontWeight.w800,
              letterSpacing: -1,
            ),
          ),
          Text(
            hint,
            style: const TextStyle(
              color: AppColors.slate400,
              fontSize: 9,
              height: 1.1,
            ),
          ),
        ],
      ),
    );
  }
}

class _ChallengeCard extends StatelessWidget {
  const _ChallengeCard({this.group});
  final ReadingGroup? group;

  @override
  Widget build(BuildContext context) {
    final progress = group?.weekProgress;
    if (group == null || progress == null) {
      return const ProtoEmptyState(
        icon: Icons.flag_outlined,
        title: 'Nenhum desafio ativo',
        copy: 'Aguardando uma leitura direcionada pela liderança.',
      );
    }
    final currentGroup = group!;
    return ProtoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  currentGroup.planLabel,
                  style: const TextStyle(
                    color: AppColors.slate100,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Text(
                '${(progress * 100).round()}%',
                style: const TextStyle(
                  color: AppColors.ember,
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            currentGroup.name,
            style: const TextStyle(color: AppColors.slate400, fontSize: 10),
          ),
          const SizedBox(height: 13),
          EmberProgress(value: progress),
          const SizedBox(height: 13),
          EmberButton(
            label: 'MARCAR LEITURA DE HOJE',
            expand: true,
            onPressed: null,
          ),
          const SizedBox(height: 5),
          const Text(
            'Marcação diária aguarda integração de dados.',
            style: TextStyle(color: AppColors.slate500, fontSize: 9),
          ),
          TextButton(
            onPressed: () => AppNavScope.go(context, 'plans'),
            child: const Text('ABRIR LEITURA'),
          ),
        ],
      ),
    );
  }
}

class _PastorReflection extends StatelessWidget {
  const _PastorReflection();
  @override
  Widget build(BuildContext context) {
    return const ProtoEmptyState(
      icon: Icons.notes_outlined,
      title: 'Nenhuma reflexão publicada',
      copy: 'Aguardando integração de dados para reflexões pastorais.',
    );
  }
}

class _PastorBrief extends StatelessWidget {
  const _PastorBrief({required this.groups});
  final List<ReadingGroup> groups;
  @override
  Widget build(BuildContext context) {
    return ProtoCard(
      challenge: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const MiniLabel('Reflexão do dia'),
          const SizedBox(height: 5),
          const Text(
            'Reflexão do dia',
            style: TextStyle(
              color: AppColors.slate100,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 5),
          const Text(
            'Aguardando integração de conteúdo para publicação pastoral.',
            style: TextStyle(color: AppColors.slate300, fontSize: 11),
          ),
          const SizedBox(height: 12),
          EmberButton(label: 'PUBLICAÇÃO EM BREVE', onPressed: null),
        ],
      ),
    );
  }
}

class _PostCard extends StatelessWidget {
  const _PostCard({required this.item, this.groupHint});

  final FeedItem item;
  final String? groupHint;

  @override
  Widget build(BuildContext context) {
    final item = this.item;
    final body = switch (item) {
      final BookCompletedFeedItem completed =>
        completed.quote ?? 'Terminou ${completed.bookName}.',
      final ReadingProgressFeedItem progress =>
        'Leu ${progress.passageLabel} · ${progress.readingMinutes} min',
      final StreakAchievementFeedItem streak =>
        '${streak.days} dias seguidos de leitura.',
    };
    final meta = [
      groupHint,
      timeAgo(item.occurredAt),
    ].whereType<String>().join(' · ');

    return ProtoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              AppAvatar(
                initials: item.author.initials,
                color: AppColors.slate800,
                foregroundColor: AppColors.slate100,
                size: 31,
              ),
              const SizedBox(width: 9),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.author.displayName,
                      style: const TextStyle(
                        color: AppColors.slate100,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      meta,
                      style: const TextStyle(
                        color: AppColors.slate400,
                        fontSize: 9,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            body,
            style: const TextStyle(
              color: AppColors.slate300,
              fontSize: 11,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.favorite_border,
                    color: AppColors.slate400,
                    size: 14,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    'Apoios ${item.highFives}',
                    style: const TextStyle(
                      color: AppColors.slate300,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 14),
              Text(
                '${item.comments} comentários',
                style: const TextStyle(color: AppColors.slate300, fontSize: 10),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FeedSkeleton extends StatelessWidget {
  const _FeedSkeleton();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
      children: const [
        _SkeletonBlock(height: 94),
        SizedBox(height: 18),
        _SkeletonBlock(height: 160),
        SizedBox(height: 10),
        _SkeletonBlock(height: 136),
      ],
    );
  }
}

class _SkeletonBlock extends StatelessWidget {
  const _SkeletonBlock({required this.height});

  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: AppColors.slate800,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.slate700),
      ),
      child: const Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _ShimmerLine(width: 88, height: 10),
            SizedBox(height: 16),
            _ShimmerLine(width: double.infinity, height: 12),
            SizedBox(height: 9),
            _ShimmerLine(width: 150, height: 12),
          ],
        ),
      ),
    );
  }
}

class _ShimmerLine extends StatelessWidget {
  const _ShimmerLine({required this.width, required this.height});

  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.slate700,
        borderRadius: BorderRadius.circular(99),
      ),
    );
  }
}
