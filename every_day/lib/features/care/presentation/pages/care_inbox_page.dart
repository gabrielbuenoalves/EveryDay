import 'package:flutter/material.dart';

import '../../../../app/di/app_scope.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_avatar.dart';
import '../../../../core/widgets/proto.dart';
import '../../domain/entities/care_models.dart';
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
    final list = items == null
        ? const Center(
            child: CircularProgressIndicator(color: AppColors.ember),
          )
        : RefreshIndicator(
            color: AppColors.ember,
            onRefresh: _load,
            child: ListView(
              padding: EdgeInsets.fromLTRB(16, 8, 16, widget.asTab ? 120 : 32),
              children: [
                if (_error != null)
                  const Padding(
                    padding: EdgeInsets.only(bottom: 12),
                    child: Text(
                      'Não foi possível carregar alguns pedidos.',
                      style: TextStyle(color: AppColors.ember),
                    ),
                  ),
                if (items.isEmpty)
                  const ProtoCard(
                    child: Text(
                      'Nenhum pedido de oração em aberto.',
                      style: TextStyle(color: AppColors.slate300),
                    ),
                  ),
                for (final item in items) ...[
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
            const AppScreenHeader(
              kicker: 'Cuidado pastoral',
              title: 'Notificações',
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
      color: AppColors.slate800,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onOpen,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: item.checkin.crisis ? AppColors.ember : AppColors.slate700,
            ),
          ),
          child: Row(
            children: [
              AppAvatar(
                initials: item.member.initials,
                color: AppColors.slate800,
                foregroundColor: AppColors.slate100,
              ),
              const SizedBox(width: 12),
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
                    const SizedBox(height: 4),
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
                    const SizedBox(height: 6),
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
