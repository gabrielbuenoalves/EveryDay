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
        const _VerseOfDay(),
        const ProtoSection(
          title: 'Seu desafio atual',
          trailing: 'Ver detalhes',
        ),
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
          child: WeekBars(
            heights: const [0.48, 0.70, 0.56, 0.82, 0.67, 0.91, 0.76],
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

class _VerseOfDay extends StatelessWidget {
  const _VerseOfDay();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 132,
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF3B2920), Color(0xFF1B1B23), Color(0xFF111218)],
        ),
        border: Border.all(color: const Color(0xFF463329)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.ember,
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Text(
              'VERSÍCULO DO DIA',
              style: TextStyle(
                color: AppColors.slate950,
                fontSize: 8,
                fontWeight: FontWeight.w900,
                letterSpacing: .6,
              ),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            '“A minha graça te basta.”',
            style: TextStyle(
              color: AppColors.slate100,
              fontSize: 15,
              fontWeight: FontWeight.w700,
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: 3),
          const Text(
            '2 CORÍNTIOS 12:9',
            style: TextStyle(
              color: AppColors.slate400,
              fontSize: 8,
              fontWeight: FontWeight.w800,
              letterSpacing: 1,
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
    final progress = group?.weekProgress ?? .18;
    return ProtoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  group?.planLabel ?? 'Sua leitura de hoje',
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
            group?.name ?? 'Escolha um plano para começar.',
            style: const TextStyle(color: AppColors.slate400, fontSize: 10),
          ),
          const SizedBox(height: 13),
          EmberProgress(value: progress),
          const SizedBox(height: 13),
          EmberButton(
            label: 'MARCAR LEITURA DE HOJE',
            expand: true,
            onPressed: () => AppNavScope.go(context, 'plans'),
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
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: AppColors.violet,
        borderRadius: BorderRadius.circular(15),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'REFLEXÃO NOVA',
            style: TextStyle(
              color: Color(0xFFD6B8FF),
              fontSize: 8,
              fontWeight: FontWeight.w900,
              letterSpacing: 1,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Uma pausa para lembrar onde a esperança começa.',
            style: TextStyle(
              color: AppColors.slate100,
              fontSize: 13,
              fontWeight: FontWeight.w700,
              height: 1.3,
            ),
          ),
          SizedBox(height: 9),
          Text(
            'LER REFLEXÃO',
            style: TextStyle(
              color: AppColors.slate100,
              fontSize: 9,
              fontWeight: FontWeight.w900,
              letterSpacing: .7,
            ),
          ),
        ],
      ),
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
            'Uma palavra para conduzir a semana.',
            style: TextStyle(
              color: AppColors.slate100,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            '${groups.length} grupos aguardam sua direção.',
            style: const TextStyle(color: AppColors.slate300, fontSize: 11),
          ),
          const SizedBox(height: 12),
          EmberButton(
            label: 'PUBLICAR REFLEXÃO',
            onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Publique sua reflexão pela agenda de avisos.'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PostCard extends StatefulWidget {
  const _PostCard({required this.item, this.groupHint});

  final FeedItem item;
  final String? groupHint;

  @override
  State<_PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<_PostCard> {
  var _liked = false;

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final body = switch (item) {
      final BookCompletedFeedItem completed =>
        completed.quote ?? 'Terminou ${completed.bookName}.',
      final ReadingProgressFeedItem progress =>
        'Leu ${progress.passageLabel} · ${progress.readingMinutes} min',
      final StreakAchievementFeedItem streak =>
        '${streak.days} dias seguidos de leitura.',
    };
    final likes = item.highFives + (_liked ? 1 : 0);
    final meta = [
      if (widget.groupHint != null) widget.groupHint!,
      timeAgo(item.occurredAt),
    ].join(' · ');

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
              InkWell(
                onTap: () => setState(() => _liked = !_liked),
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 2,
                    vertical: 3,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _liked ? Icons.favorite : Icons.favorite_border,
                        color: _liked ? AppColors.ember : AppColors.slate300,
                        size: 14,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        'Apoiar $likes',
                        style: TextStyle(
                          color: _liked ? AppColors.ember : AppColors.slate300,
                          fontSize: 10,
                          fontWeight: _liked
                              ? FontWeight.w800
                              : FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 14),
              const Text(
                'Comentar',
                style: TextStyle(color: AppColors.slate300, fontSize: 10),
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
