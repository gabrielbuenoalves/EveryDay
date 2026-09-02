import 'package:every_day/core/bible/usfm.dart';
import 'package:every_day/core/domain/daily_reading.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('converte nomes em português para USFM', () {
    expect(usfmBookCode('Salmos'), 'PSA');
    expect(usfmBookCode('João'), 'JHN');
    expect(usfmBookCode('Gênesis'), 'GEN');
    expect(usfmBookCode('1 Samuel'), '1SA');
    expect(usfmBookCode('psa'), 'PSA');
    expect(usfmBookCode('Jó'), 'JOB');
    expect(usfmBookCode('1 Reis'), '1KI');
    expect(usfmBookCode('Apocalipse'), 'REV');
    expect(usfmBookCode('1 João'), '1JN');
  });

  test('monta ids de capítulos no formato da API.Bible', () {
    expect(usfmPassageIds(book: 'Salmos', startChapter: 28, endChapter: 30), [
      'PSA.28',
      'PSA.29',
      'PSA.30',
    ]);
    expect(apiBiblePassageIds(book: 'João', startChapter: 8, endChapter: 8), [
      'JHN.8',
    ]);
    expect(
      usfmPassageIds(
        book: 'João',
        startChapter: 3,
        endChapter: 3,
        passageLabel: 'João 3:16',
      ),
      ['JHN.3.16'],
    );
    expect(
      usfmPassageIds(
        book: 'João',
        startChapter: 3,
        endChapter: 3,
        passageLabel: 'João 3:1-16',
      ),
      ['JHN.3.1-JHN.3.16'],
    );
    expect(
      usfmPassageIds(
        book: 'Gênesis',
        startChapter: 1,
        endChapter: 1,
        passageLabel: 'Gênesis 1:1-201',
      ),
      ['GEN.1'],
    );
  });

  test('lê referência pastoral em português', () {
    final psalm = DailyReading.fromLabel('Salmos 23');
    expect(psalm.book, 'Salmos');
    expect(psalm.startChapter, 23);
    final john = DailyReading.fromLabel('João 14:1-6');
    expect(john.book, 'João');
    expect(john.startChapter, 14);
    expect(john.endChapter, 14);
  });
}
