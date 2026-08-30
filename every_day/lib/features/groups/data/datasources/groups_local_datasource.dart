import '../../../../core/domain/user_preview.dart';
import '../../domain/entities/reading_group.dart';

class GroupsLocalDataSource {
  List<ReadingGroup> fetch() {
    const marina = UserPreview(
      id: 'marina',
      displayName: 'Marina',
      initials: 'MA',
      avatarColorValue: 0xFFE07A4A,
    );
    const lucas = UserPreview(
      id: 'lucas',
      displayName: 'Lucas',
      initials: 'LC',
      avatarColorValue: 0xFFB8B0A4,
    );
    const gabriel = UserPreview(
      id: 'gabriel',
      displayName: 'Gabriel',
      initials: 'GA',
      avatarColorValue: 0xFF1A4D3A,
    );
    const ana = UserPreview(
      id: 'ana',
      displayName: 'Ana',
      initials: 'AN',
      avatarColorValue: 0xFFC45C4A,
    );

    return const [
      ReadingGroup(
        id: 'salmos-30',
        name: 'Salmos em 30 dias',
        planLabel: 'Capítulos 28–30 hoje',
        memberCount: 12,
        weekProgress: 0.72,
        members: [marina, lucas, gabriel, ana],
      ),
      ReadingGroup(
        id: 'evangelhos',
        name: 'Evangelhos juntos',
        planLabel: 'João concluído · Atos na fila',
        memberCount: 8,
        weekProgress: 0.45,
        members: [lucas, gabriel, ana],
      ),
    ];
  }
}
