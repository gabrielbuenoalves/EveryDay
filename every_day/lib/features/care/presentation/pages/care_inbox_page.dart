import 'package:flutter/material.dart';

import '../../../../app/di/app_scope.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_avatar.dart';
import '../../../../core/widgets/proto.dart';
import '../../domain/entities/care_models.dart';
import '../../../members/presentation/pages/members_page.dart';
import 'care_report_page.dart';

class CareInboxPage extends StatefulWidget {
  const CareInboxPage({super.key, this.asTab = false});

  final bool asTab;

  @override
  State<CareInboxPage> createState() => _CareInboxPageState();
}

class _CareInboxPageState extends State<CareInboxPage> {
  List<CareInboxItem>? _items;
  Object? _error;
  var _filter = 0;
  Listenable? _reload;
  var _listening = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final reload = AppScope.of(context).feedReload;
    if (_reload != reload) {
      _reload?.removeListener(_load);
      _reload = reload;
      _reload!.addListener(_load);
    }
    if (_listening) return;
    _listening = true;
    _load();
  }

  @override
  void dispose() {
    _reload?.removeListener(_load);
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final items = await AppScope.of(context).getCareInbox();
      if (!mounted) return;
      setState(() {
        _items = items;
        _error = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e;
        _items ??= const [];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final items = _items;
    final filtered = items?.where((item) {
      if (_filter == 1) return item.checkin.crisis;
      if (_filter == 2) return item.checkin.score <= 2;
      return true;
    }).toList();
    final visible = filtered ?? const <CareInboxItem>[];
    final list = items == null
        ? const Center(child: CircularProgressIndicator(color: AppColors.ember))
        : RefreshIndicator(
            color: AppColors.ember,
            onRefresh: _load,
            child: ListView(
              padding: EdgeInsets.fromLTRB(16, 5, 16, widget.asTab ? 104 : 28),
              children: [
                const ProtoSection(title: 'Fila de cuidado', trailing: 'Hoje'),
                ProtoFilterBar(
                  labels: const ['Todos', 'Urgente', 'Oração', 'Respondidos'],
                  selected: _filter,
                  onSelected: (value) => setState(() => _filter = value),
                  disabledIndices: const <int>{3},
                ),
                const SizedBox(height: 5),
                const Text(
                  'Respostas pastorais aguardam integração de dados.',
                  style: TextStyle(color: AppColors.slate500, fontSize: 9),
                ),
                const SizedBox(height: 12),
                if (_error != null)
                  Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0x332E2521),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.emberDark),
                    ),
                    child: const Row(
                      children: [
                        Icon(
                          Icons.cloud_off_rounded,
                          color: AppColors.ember,
                          size: 19,
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Não foi possível carregar alguns pedidos.',
                            style: TextStyle(
                              color: AppColors.slate300,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                if (visible.isEmpty)
                  const ProtoEmptyState(
                    icon: Icons.check_circle_outline_rounded,
                    title: 'Tudo em dia por aqui',
                    copy: 'Quando alguém pedir cuidado, o relato aparece nesta fila.',
                  ),
                for (final item in visible) ...[
                  _InboxCard(item: item, onOpen: () => _open(item)),
                  const SizedBox(height: 10),
                ],
              ],
            ),
          );

    if (widget.asTab) {
      return SafeArea(
        bottom: false,
        child: Column(
          children: [
            AppScreenHeader(
              kicker: 'Cuidado pastoral',
              title: 'Cuidado',
              action: IconButton(
                tooltip: 'Membros',
                onPressed: () {
                  Navigator.of(context).push<void>(
                    MaterialPageRoute(builder: (_) => const MembersPage()),
                  );
                },
                icon: const Icon(Icons.people_outline, color: AppColors.ember),
              ),
            ),
            Expanded(child: list),
          ],
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.slate900,
      appBar: AppBar(title: const Text('Notificações')),
      body: list,
    );
  }

  Future<void> _open(CareInboxItem item) async {
    final deps = AppScope.of(context);
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => CareReportPage(
          item: item,
          approvePlan: deps.approveCarePlan,
          scheduleContact: deps.scheduleCareContact,
        ),
      ),
    );
    await _load();
  }
}

class _InboxCard extends StatelessWidget {
  const _InboxCard({required this.item, required this.onOpen});

  final CareInboxItem item;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final urgency = item.report?.urgency;
    return Material(
      color: AppColors.slate850,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onOpen,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(13),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: item.checkin.crisis ? AppColors.ember : AppColors.slate700,
              width: item.checkin.crisis ? 1.4 : 1,
            ),
          ),
          child: Row(
            children: [
              AppAvatar(
                initials: item.member.initials,
                color: AppColors.slate800,
                foregroundColor: AppColors.slate100,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.member.displayName,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        color: AppColors.slate100,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      [
                        'Auditar leitura da IA',
                        'Nota ${item.checkin.score}',
                        if (urgency != null) urgency.label,
                        if (item.checkin.crisis) 'Crise',
                      ].join(' · '),
                      style: const TextStyle(
                        color: AppColors.slate400,
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      item.preview,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.slate300,
                        fontSize: 12,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
