import 'package:flutter_test/flutter_test.dart';

import 'package:every_day/app/di/app_dependencies.dart';
import 'package:every_day/app/every_day_app.dart';

void main() {
  testWidgets('mostra a home e navega pelas cinco abas', (tester) async {
    await tester.pumpWidget(
      EveryDayApp(dependencies: AppDependencies.bootstrap()),
    );
    await tester.pumpAndSettle();

    expect(find.text('Boa noite, Mateus'), findsOneWidget);
    expect(find.text('VERSÍCULO DO DIA'), findsOneWidget);
    expect(find.text('Início'), findsOneWidget);
    expect(find.text('Grupos'), findsOneWidget);
    expect(find.text('Cuidado'), findsOneWidget);
    expect(find.text('Agenda'), findsOneWidget);
    expect(find.text('Perfil'), findsOneWidget);

    await tester.tap(find.text('Grupos'));
    await tester.pumpAndSettle();
    expect(find.text('Jornada em João'), findsOneWidget);

    await tester.tap(find.text('Cuidado'));
    await tester.pumpAndSettle();
    expect(find.text('Respostas'), findsOneWidget);

    await tester.tap(find.text('Perfil'));
    await tester.pumpAndSettle();
    expect(find.text('SEU RITMO'), findsOneWidget);
  });

  testWidgets('registra a leitura de hoje', (tester) async {
    await tester.pumpWidget(
      EveryDayApp(dependencies: AppDependencies.bootstrap()),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('MARCAR LEITURA DE HOJE'));
    await tester.pumpAndSettle();

    expect(find.text('LEITURA CONCLUÍDA'), findsOneWidget);
  });
}
