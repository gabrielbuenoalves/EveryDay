import 'package:every_day/core/care/crisis_keywords.dart';
import 'package:every_day/core/domain/user_preview.dart';
import 'package:every_day/core/domain/user_role.dart';
import 'package:every_day/features/care/domain/entities/care_models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('detecta linguagem de crise em português', () {
    expect(containsCrisisLanguage('Não aguento mais viver assim'), isTrue);
    expect(containsCrisisLanguage('Quero me matar'), isTrue);
    expect(containsCrisisLanguage('Tive um dia cansado no trabalho'), isFalse);
    expect(containsCrisisLanguage(null), isFalse);
  });

  test('só o pastor vê a fila de cuidado', () {
    expect(UserRole.pastor.allows(AppPermission.viewCareInbox), isTrue);
    expect(UserRole.pastor.allows(AppPermission.actOnCareReport), isTrue);
    expect(UserRole.leader.allows(AppPermission.viewCareInbox), isFalse);
    expect(UserRole.leader.allows(AppPermission.actOnCareReport), isFalse);
    expect(UserRole.member.allows(AppPermission.viewCareInbox), isFalse);
  });

  test(
    'relatório pastoral usa o relato do membro quando a IA ainda não rodou',
    () {
      final item = CareInboxItem(
        checkin: MoodCheckin(
          id: '1',
          score: 2,
          day: DateTime(2026, 8, 30),
          status: CareStatus.needsCare,
          crisis: false,
          body: 'Sentimento: Triste\nPedido de oração: estou cansado',
        ),
        member: const UserPreview(
          id: 'm',
          displayName: 'Ana',
          initials: 'AN',
          avatarColorValue: 1,
        ),
      );
      expect(item.preview, contains('Triste'));
      expect(item.pastoralBriefing, contains('estou cansado'));
      expect(item.hasAiReport, isFalse);
    },
  );

  test('sugere próxima leitura a partir da compreensão e do olhar', () {
    final heavy = CarePlanInsight(
      id: '1',
      planId: 'p',
      userId: 'u',
      memberName: 'Ana',
      planTitle: 'Cuidado',
      understanding: 2,
      reception: 'ainda_pesado',
      minutes: 12,
      completedAt: DateTime(2026, 8, 30),
    );
    expect(heavy.nextReadingHint, contains('acolhimento'));

    final clear = CarePlanInsight(
      id: '2',
      planId: 'p',
      userId: 'u',
      memberName: 'Ana',
      planTitle: 'Cuidado',
      understanding: 5,
      reception: 'desafio',
      minutes: 18,
      completedAt: DateTime(2026, 8, 30),
    );
    expect(clear.nextReadingHint, contains('aprofund'));
  });
}
