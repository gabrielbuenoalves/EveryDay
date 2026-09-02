import 'package:every_day/core/widgets/app_logo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('usa a arte oficial da logo', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: AppLogo(size: 48))),
    );

    expect(find.byType(AppLogo), findsOneWidget);
    expect(find.byType(Image), findsOneWidget);
    expect(find.text('E'), findsNothing);
  });

  testWidgets('wordmark mostra EveryDay e o slogan', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: AppWordmark())),
    );

    expect(find.text('EveryDay'), findsOneWidget);
    expect(find.text(everydayTagline), findsOneWidget);
  });
}
