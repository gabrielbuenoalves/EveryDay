
import 'package:every_day/app/every_day_app.dart';
import 'package:every_day/app/shell/app_shell.dart';
import 'package:every_day/app/shell/pastor_shell.dart';
import 'package:every_day/core/domain/user_role.dart';
import 'package:every_day/features/pastor/presentation/pages/pastor_agenda_page.dart';
import 'package:every_day/features/pastor/presentation/pages/pastor_care_page.dart';
import 'package:every_day/features/pastor/presentation/pages/pastor_groups_page.dart';
import 'package:every_day/features/pastor/presentation/pages/pastor_profile_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/test_dependencies.dart';

void main() {
  testWidgets('mantém membro no shell e na navegação existentes', (
    tester,
  ) async {
    await tester.pumpWidget(
      EveryDayApp(dependencies: testDependencies(), skipAuth: true),
    );
    await tester.pumpAndSettle();

    expect(find.byType(AppShell), findsOneWidget);
    expect(find.byType(PastorShell), findsNothing);
    expect(find.text('Início'), findsWidgets);
    expect(find.text('Ler'), findsOneWidget);
    expect(find.text('Grupos'), findsOneWidget);
    expect(find.text('Agenda'), findsOneWidget);
    expect(find.text('Perfil'), findsOneWidget);
    expect(find.text('Cuidado'), findsNothing);
  });

  testWidgets('pastor recebe somente o novo shell pastoral', (tester) async {
    await tester.pumpWidget(
      EveryDayApp(
        dependencies: testDependencies(role: UserRole.pastor),
        skipAuth: true,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(PastorShell), findsOneWidget);
    expect(find.text('Pr. Eduardo'), findsOneWidget);
    expect(find.text('Reflexão do dia'), findsOneWidget);
    expect(find.text('Pessoas conectadas'), findsOneWidget);
    expect(find.text('Planos'), findsNothing);
  });

  testWidgets('navega pelas cinco áreas pastorais', (tester) async {
    await tester.pumpWidget(
      EveryDayApp(
        dependencies: testDependencies(role: UserRole.pastor),
        skipAuth: true,
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Grupos').last);
    await tester.pumpAndSettle();
    expect(find.byType(PastorGroupsPage), findsOneWidget);
    expect(find.text('Criar novo desafio'), findsOneWidget);

    await tester.tap(find.text('Cuidado'));
    await tester.pumpAndSettle();
    expect(find.byType(PastorCarePage), findsOneWidget);
    expect(find.text('Urgentes (3)'), findsOneWidget);

    await tester.tap(find.text('Agenda'));
    await tester.pumpAndSettle();
    expect(find.byType(PastorAgendaPage), findsOneWidget);
    expect(find.text('Novo aviso ou evento'), findsOneWidget);

    await tester.tap(find.text('Perfil'));
    await tester.pumpAndSettle();
    expect(find.byType(PastorProfilePage), findsOneWidget);
    expect(find.text('Editar dados pessoais'), findsNothing);
    expect(find.byTooltip('Editar dados pessoais'), findsOneWidget);
  });

  testWidgets('resposta pastoral fecha o relato visualmente', (tester) async {
    tester.view.physicalSize = const Size(430, 932);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      EveryDayApp(
        dependencies: testDependencies(role: UserRole.pastor),
        skipAuth: true,
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Cuidado'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Responder').first);
    await tester.tap(find.text('Responder').first);
    await tester.pumpAndSettle();

    expect(find.byType(PastorCareDetailPage), findsOneWidget);
    expect(find.text('Análise da IA'), findsOneWidget);
    expect(find.text('Leituras recomendadas'), findsOneWidget);
    expect(find.byTooltip('Editar análise'), findsOneWidget);

    await tester.drag(find.byType(ListView).last, const Offset(0, -1200));
    await tester.pumpAndSettle();

    expect(find.text('Agendar ligação'), findsOneWidget);
    expect(find.text('Visita pastoral'), findsOneWidget);

    await tester.ensureVisible(find.text('Enviar resposta'));
    await tester.tap(find.text('Enviar resposta'));
    await tester.pumpAndSettle();

    expect(find.byType(PastorCareDetailPage), findsNothing);
    expect(find.byType(PastorCarePage), findsOneWidget);
  });
}
