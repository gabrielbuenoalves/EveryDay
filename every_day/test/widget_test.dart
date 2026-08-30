import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:every_day/app/di/app_dependencies.dart';
import 'package:every_day/app/every_day_app.dart';

void main() {
  testWidgets('mostra o feed de hoje e navega pelas abas', (tester) async {
    await tester.pumpWidget(
      EveryDayApp(dependencies: AppDependencies.bootstrap()),
    );
    await tester.pumpAndSettle();

    expect(find.text('Hoje'), findsOneWidget);
    expect(find.text('Salmos 28–30'), findsWidgets);
    expect(find.text('Feed'), findsOneWidget);
    expect(find.text('Estante'), findsOneWidget);
    expect(find.text('Grupos'), findsOneWidget);
    expect(find.text('Perfil'), findsOneWidget);

    await tester.tap(find.text('Estante'));
    await tester.pumpAndSettle();
    expect(find.text('ANTIGO TESTAMENTO'), findsOneWidget);

    await tester.tap(find.text('Grupos'));
    await tester.pumpAndSettle();
    expect(find.text('Salmos em 30 dias'), findsOneWidget);

    await tester.tap(find.text('Perfil'));
    await tester.pumpAndSettle();
    expect(find.text('nesta semana'), findsWidgets);
  });

  testWidgets('abre o registro de leitura pelo botão central', (tester) async {
    await tester.pumpWidget(
      EveryDayApp(dependencies: AppDependencies.bootstrap()),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    expect(find.text('Registrar leitura'), findsOneWidget);
  });
}
