import 'package:flutter/material.dart';

import '../../../../app/shell/app_nav_scope.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/proto.dart';
import '../../domain/entities/care_models.dart';

class CareNoticeTeaser extends StatelessWidget {
  const CareNoticeTeaser({super.key, required this.items, this.error});

  final List<CareInboxItem> items;
  final Object? error;

  @override
  Widget build(BuildContext context) {
    return ProtoCard(
      challenge: items.isNotEmpty,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const MiniLabel('Avisos'),
          const SizedBox(height: 6),
          Text(
            items.isEmpty
                ? 'Nenhum pedido de oração em aberto'
                : '${items.length} ${items.length == 1 ? 'ovelha precisa de cuidado' : 'ovelhas precisam de cuidado'}',
            style: const TextStyle(
              color: AppColors.slate100,
              fontSize: 15,
              fontWeight: FontWeight.w800,
            ),
          ),
          if (error != null) ...[
            const SizedBox(height: 6),
            const Text(
              'Não foi possível atualizar a fila agora.',
              style: TextStyle(color: AppColors.ember, fontSize: 11),
            ),
          ],
          const SizedBox(height: 12),
          EmberButton(
            label: 'Abrir notificações',
            onPressed: () => AppNavScope.go(context, 'notices'),
          ),
        ],
      ),
    );
  }
}
