import 'package:every_day/app/di/app_scope.dart';
import 'package:every_day/app/every_day_app.dart';
import 'package:every_day/app/shell/app_shell.dart';
import 'package:every_day/core/domain/user_role.dart';
import 'package:every_day/features/feed/presentation/pages/feed_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/test_dependencies.dart';

void main() {
  testWidgets('mostra o feed de hoje e navega pelas abas', (tester) async {
    await tester.pumpWidget(
      EveryDayApp(dependencies: testDependencies(), skipAuth: true),
    );
    await tester.pumpAndSettle();

    expect(find.text('Do seu círculo'), findsOneWidget);
    expect(
      find.descendant(
        of: find.byType(FeedPage),
        matching: find.text('Continuar leitura'),
      ),
      findsNothing,
    );
    expect(
      find.descendant(
        of: find.byType(FeedPage),
        matching: find.textContaining('Salmos 28–30'),
      ),
      findsNothing,
    );
    expect(find.text('Home'), findsWidgets);
    expect(find.text('Planos'), findsOneWidget);
    expect(find.text('Grupos'), findsOneWidget);
    expect(find.text('Perfil'), findsOneWidget);

    await tester.tap(find.text('Planos'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Salmos 28–30'), findsWidgets);

    await tester.tap(find.text('Grupos'));
    await tester.pumpAndSettle();
    expect(find.text('Salmos em 30 dias'), findsOneWidget);

    await tester.tap(find.text('Perfil'));
    await tester.pumpAndSettle();
    expect(find.text('Você'), findsOneWidget);
  });

  testWidgets('abre o registro de leitura pelo botão central', (tester) async {
    await tester.pumpWidget(
      EveryDayApp(dependencies: testDependencies(), skipAuth: true),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Criar'));
    await tester.pumpAndSettle();

    expect(find.text('Criar publicação'), findsOneWidget);
  });

  testWidgets('abre o texto da leitura do pastor', (tester) async {
    await tester.pumpWidget(
      EveryDayApp(dependencies: testDependencies(), skipAuth: true),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Planos'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Continuar leitura'));
    await tester.pumpAndSettle();

    expect(find.textContaining('minha rocha'), findsOneWidget);
    expect(find.textContaining('NVI'), findsOneWidget);
    expect(find.text('Marcar como lida'), findsOneWidget);
    expect(find.text('Próxima'), findsOneWidget);
  });

  testWidgets('navega entre as leituras do pastor', (tester) async {
    await tester.pumpWidget(
      EveryDayApp(dependencies: testDependencies(), skipAuth: true),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Planos'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Salmos 23'), findsWidgets);
    expect(find.textContaining('João 14:1-6'), findsWidgets);

    await tester.tap(find.textContaining('João 14:1-6').first);
    await tester.pumpAndSettle();

    expect(find.text('João 14:1-6'), findsWidgets);
    expect(find.text('Anterior'), findsOneWidget);

    await tester.tap(find.text('Marcar como lida'));
    await tester.pump();

    expect(find.textContaining('conclu'), findsWidgets);
  });

  testWidgets('ao encerrar o plano pede quiz e comentário', (tester) async {
    await tester.pumpWidget(
      EveryDayApp(
        dependencies: testDependencies(planDone: true),
        skipAuth: true,
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Planos'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Encerrar plano'));
    await tester.pumpAndSettle();

    expect(find.text('Como foi essa leitura'), findsOneWidget);
    expect(find.text('Comentário para o pastor'), findsOneWidget);
    expect(find.text('O que ficou para você?'), findsOneWidget);
    expect(find.text('Quanto você entendeu o texto?'), findsOneWidget);
    expect(find.text('Como o texto te encontrou?'), findsOneWidget);
    expect(find.text('Paz'), findsOneWidget);
    expect(find.text('Ainda pesado'), findsOneWidget);
    expect(find.textContaining('Tempo aproximado'), findsOneWidget);
  });

  testWidgets('na leitura o membro vê a Bíblia completa', (tester) async {
    await tester.pumpWidget(
      EveryDayApp(dependencies: testDependencies(), skipAuth: true),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Planos'));
    await tester.pumpAndSettle();

    expect(find.text('Antigo Testamento'), findsOneWidget);
    expect(find.text('Gênesis'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'Mateus');
    await tester.pumpAndSettle();

    expect(find.text('Novo Testamento'), findsOneWidget);
    expect(find.text('Mateus'), findsWidgets);
  });

  testWidgets('mostra o perfil do membro', (tester) async {
    await tester.pumpWidget(
      EveryDayApp(dependencies: testDependencies(), skipAuth: true),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Perfil'));
    await tester.pumpAndSettle();

    expect(find.text('PERFIL DO MEMBRO'), findsOneWidget);
    expect(find.text('Editar perfil'), findsOneWidget);
    expect(find.text('4/66'), findsOneWidget);
  });

  testWidgets('mostra o perfil do líder', (tester) async {
    await tester.pumpWidget(
      EveryDayApp(
        dependencies: testDependencies(role: UserRole.leader),
        skipAuth: true,
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Perfil'));
    await tester.pumpAndSettle();

    expect(find.text('PERFIL DO LÍDER'), findsOneWidget);
    expect(find.text('Grupos que lidero'), findsOneWidget);
    expect(find.text('Editar perfil do líder'), findsOneWidget);
    expect(find.text('PERFIL DO PASTOR'), findsNothing);
    expect(find.text('PERFIL DO MEMBRO'), findsNothing);
  });

  testWidgets('mostra o perfil do pastor', (tester) async {
    await tester.pumpWidget(
      EveryDayApp(
        dependencies: testDependencies(role: UserRole.pastor),
        skipAuth: true,
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Perfil'));
    await tester.pumpAndSettle();

    expect(find.text('PERFIL DO PASTOR'), findsOneWidget);
    expect(find.text('IGREJA VINCULADA'), findsOneWidget);
    expect(find.text('Avisos'), findsOneWidget);
    expect(find.text('NOTIFICAÇÕES'), findsNothing);
    expect(find.text('IGREJA'), findsOneWidget);
    expect(find.text('PERFIL DO MEMBRO'), findsNothing);
    expect(find.text('PERFIL DO LÍDER'), findsNothing);
  });

  testWidgets('pastor abre a aba de notificações', (tester) async {
    await tester.pumpWidget(
      EveryDayApp(
        dependencies: testDependencies(role: UserRole.pastor),
        skipAuth: true,
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Avisos'));
    await tester.pumpAndSettle();

    expect(find.text('Notificações'), findsOneWidget);
    expect(find.text('Nenhum pedido de oração em aberto.'), findsOneWidget);
    expect(find.text('PERFIL DO PASTOR'), findsNothing);
  });

  testWidgets('abre o grupo e vê leituras em andamento e concluídas', (
    tester,
  ) async {
    await tester.pumpWidget(
      EveryDayApp(dependencies: testDependencies(), skipAuth: true),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Grupos'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Salmos em 30 dias'));
    await tester.pumpAndSettle();

    expect(find.text('Em andamento'), findsOneWidget);
    expect(find.text('Salmos da semana'), findsOneWidget);
    expect(find.text('Concluídas'), findsOneWidget);
    expect(find.text('João 1'), findsOneWidget);
    expect(find.textContaining('O Verbo se fez carne'), findsOneWidget);
  });

  testWidgets('membro vê o questionário de sentimento ao entrar', (
    tester,
  ) async {
    await tester.pumpWidget(
      EveryDayApp(dependencies: testDependencies(), skipAuth: true),
    );
    await tester.pumpAndSettle();
    expect(find.text('Como está se sentindo hoje?'), findsNothing);

    await tester.pumpWidget(
      AppScope(
        dependencies: testDependencies(),
        child: const MaterialApp(home: AppShell()),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Como está se sentindo hoje?'), findsOneWidget);
  });
}
