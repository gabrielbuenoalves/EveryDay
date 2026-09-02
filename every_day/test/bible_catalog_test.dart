import 'package:every_day/features/shelf/domain/bible_catalog.dart';
import 'package:every_day/features/shelf/domain/entities/bible_book.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('catálogo tem os 66 livros da Bíblia', () {
    final books = completeBible();
    expect(books.length, 66);
    expect(
      books.where((book) => book.testament == BibleTestament.old).length,
      39,
    );
    expect(
      books
          .where((book) => book.testament == BibleTestament.newTestament)
          .length,
      27,
    );
    expect(books.first.name, 'Gênesis');
    expect(books.last.name, 'Apocalipse');
  });
}
