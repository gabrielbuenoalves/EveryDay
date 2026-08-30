import '../../domain/entities/bible_book.dart';

class ShelfLocalDataSource {
  Bookshelf fetch() {
    return Bookshelf(
      books: [
        _book('gen', 'Gênesis', BibleTestament.old, 50, 50),
        _book('exo', 'Êxodo', BibleTestament.old, 40, 40),
        _book('lev', 'Levítico', BibleTestament.old, 27, 12),
        _book('num', 'Números', BibleTestament.old, 36, 0),
        _book('deu', 'Deuteronômio', BibleTestament.old, 34, 0),
        _book('jos', 'Josué', BibleTestament.old, 24, 0),
        _book('jdg', 'Juízes', BibleTestament.old, 21, 0),
        _book('rut', 'Rute', BibleTestament.old, 4, 0),
        _book('1sa', '1 Samuel', BibleTestament.old, 31, 0),
        _book('2sa', '2 Samuel', BibleTestament.old, 24, 0),
        _book('psa', 'Salmos', BibleTestament.old, 150, 27),
        _book('pro', 'Provérbios', BibleTestament.old, 31, 0),
        _book('isa', 'Isaías', BibleTestament.old, 66, 0),
        _book('mat', 'Mateus', BibleTestament.newTestament, 28, 28),
        _book('mrk', 'Marcos', BibleTestament.newTestament, 16, 16),
        _book('luk', 'Lucas', BibleTestament.newTestament, 24, 8),
        _book('jhn', 'João', BibleTestament.newTestament, 21, 21),
        _book('act', 'Atos', BibleTestament.newTestament, 28, 0),
        _book('rom', 'Romanos', BibleTestament.newTestament, 16, 0),
        _book('1co', '1 Coríntios', BibleTestament.newTestament, 16, 0),
        _book('gal', 'Gálatas', BibleTestament.newTestament, 6, 0),
        _book('eph', 'Efésios', BibleTestament.newTestament, 6, 0),
        _book('php', 'Filipenses', BibleTestament.newTestament, 4, 0),
        _book('rev', 'Apocalipse', BibleTestament.newTestament, 22, 0),
      ],
    );
  }

  BibleBook _book(
    String id,
    String name,
    BibleTestament testament,
    int chapters,
    int read,
  ) {
    return BibleBook(
      id: id,
      name: name,
      testament: testament,
      chapters: chapters,
      readChapters: read,
    );
  }
}
