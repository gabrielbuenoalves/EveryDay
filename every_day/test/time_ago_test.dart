import 'package:flutter_test/flutter_test.dart';

import 'package:every_day/core/utils/time_ago.dart';

void main() {
  final now = DateTime(2026, 8, 29, 16, 0);

  test('retorna agora para menos de um minuto', () {
    expect(
      timeAgo(now.subtract(const Duration(seconds: 20)), now: now),
      'agora',
    );
  });

  test('formata minutos e horas em português', () {
    expect(
      timeAgo(now.subtract(const Duration(minutes: 12)), now: now),
      'há 12 min',
    );
    expect(timeAgo(now.subtract(const Duration(hours: 1)), now: now), 'há 1 h');
  });
}
