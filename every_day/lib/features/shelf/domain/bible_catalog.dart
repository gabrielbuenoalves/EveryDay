import 'entities/bible_book.dart';

class BibleCatalogEntry {
  const BibleCatalogEntry({
    required this.id,
    required this.name,
    required this.testament,
    required this.chapters,
  });

  final String id;
  final String name;
  final BibleTestament testament;
  final int chapters;

  BibleBook toBook({int readChapters = 0}) {
    return BibleBook(
      id: id,
      name: name,
      testament: testament,
      chapters: chapters,
      readChapters: readChapters,
    );
  }
}

const bibleCatalog = <BibleCatalogEntry>[
  BibleCatalogEntry(
    id: 'gen',
    name: 'Gênesis',
    testament: BibleTestament.old,
    chapters: 50,
  ),
  BibleCatalogEntry(
    id: 'exo',
    name: 'Êxodo',
    testament: BibleTestament.old,
    chapters: 40,
  ),
  BibleCatalogEntry(
    id: 'lev',
    name: 'Levítico',
    testament: BibleTestament.old,
    chapters: 27,
  ),
  BibleCatalogEntry(
    id: 'num',
    name: 'Números',
    testament: BibleTestament.old,
    chapters: 36,
  ),
  BibleCatalogEntry(
    id: 'deu',
    name: 'Deuteronômio',
    testament: BibleTestament.old,
    chapters: 34,
  ),
  BibleCatalogEntry(
    id: 'jos',
    name: 'Josué',
    testament: BibleTestament.old,
    chapters: 24,
  ),
  BibleCatalogEntry(
    id: 'jdg',
    name: 'Juízes',
    testament: BibleTestament.old,
    chapters: 21,
  ),
  BibleCatalogEntry(
    id: 'rut',
    name: 'Rute',
    testament: BibleTestament.old,
    chapters: 4,
  ),
  BibleCatalogEntry(
    id: '1sa',
    name: '1 Samuel',
    testament: BibleTestament.old,
    chapters: 31,
  ),
  BibleCatalogEntry(
    id: '2sa',
    name: '2 Samuel',
    testament: BibleTestament.old,
    chapters: 24,
  ),
  BibleCatalogEntry(
    id: '1ki',
    name: '1 Reis',
    testament: BibleTestament.old,
    chapters: 22,
  ),
  BibleCatalogEntry(
    id: '2ki',
    name: '2 Reis',
    testament: BibleTestament.old,
    chapters: 25,
  ),
  BibleCatalogEntry(
    id: '1ch',
    name: '1 Crônicas',
    testament: BibleTestament.old,
    chapters: 29,
  ),
  BibleCatalogEntry(
    id: '2ch',
    name: '2 Crônicas',
    testament: BibleTestament.old,
    chapters: 36,
  ),
  BibleCatalogEntry(
    id: 'ezr',
    name: 'Esdras',
    testament: BibleTestament.old,
    chapters: 10,
  ),
  BibleCatalogEntry(
    id: 'neh',
    name: 'Neemias',
    testament: BibleTestament.old,
    chapters: 13,
  ),
  BibleCatalogEntry(
    id: 'est',
    name: 'Ester',
    testament: BibleTestament.old,
    chapters: 10,
  ),
  BibleCatalogEntry(
    id: 'job',
    name: 'Jó',
    testament: BibleTestament.old,
    chapters: 42,
  ),
  BibleCatalogEntry(
    id: 'psa',
    name: 'Salmos',
    testament: BibleTestament.old,
    chapters: 150,
  ),
  BibleCatalogEntry(
    id: 'pro',
    name: 'Provérbios',
    testament: BibleTestament.old,
    chapters: 31,
  ),
  BibleCatalogEntry(
    id: 'ecc',
    name: 'Eclesiastes',
    testament: BibleTestament.old,
    chapters: 12,
  ),
  BibleCatalogEntry(
    id: 'sng',
    name: 'Cânticos',
    testament: BibleTestament.old,
    chapters: 8,
  ),
  BibleCatalogEntry(
    id: 'isa',
    name: 'Isaías',
    testament: BibleTestament.old,
    chapters: 66,
  ),
  BibleCatalogEntry(
    id: 'jer',
    name: 'Jeremias',
    testament: BibleTestament.old,
    chapters: 52,
  ),
  BibleCatalogEntry(
    id: 'lam',
    name: 'Lamentações',
    testament: BibleTestament.old,
    chapters: 5,
  ),
  BibleCatalogEntry(
    id: 'ezk',
    name: 'Ezequiel',
    testament: BibleTestament.old,
    chapters: 48,
  ),
  BibleCatalogEntry(
    id: 'dan',
    name: 'Daniel',
    testament: BibleTestament.old,
    chapters: 12,
  ),
  BibleCatalogEntry(
    id: 'hos',
    name: 'Oséias',
    testament: BibleTestament.old,
    chapters: 14,
  ),
  BibleCatalogEntry(
    id: 'jol',
    name: 'Joel',
    testament: BibleTestament.old,
    chapters: 3,
  ),
  BibleCatalogEntry(
    id: 'amo',
    name: 'Amós',
    testament: BibleTestament.old,
    chapters: 9,
  ),
  BibleCatalogEntry(
    id: 'oba',
    name: 'Obadias',
    testament: BibleTestament.old,
    chapters: 1,
  ),
  BibleCatalogEntry(
    id: 'jon',
    name: 'Jonas',
    testament: BibleTestament.old,
    chapters: 4,
  ),
  BibleCatalogEntry(
    id: 'mic',
    name: 'Miqueias',
    testament: BibleTestament.old,
    chapters: 7,
  ),
  BibleCatalogEntry(
    id: 'nam',
    name: 'Naum',
    testament: BibleTestament.old,
    chapters: 3,
  ),
  BibleCatalogEntry(
    id: 'hab',
    name: 'Habacuque',
    testament: BibleTestament.old,
    chapters: 3,
  ),
  BibleCatalogEntry(
    id: 'zep',
    name: 'Sofonias',
    testament: BibleTestament.old,
    chapters: 3,
  ),
  BibleCatalogEntry(
    id: 'hag',
    name: 'Ageu',
    testament: BibleTestament.old,
    chapters: 2,
  ),
  BibleCatalogEntry(
    id: 'zec',
    name: 'Zacarias',
    testament: BibleTestament.old,
    chapters: 14,
  ),
  BibleCatalogEntry(
    id: 'mal',
    name: 'Malaquias',
    testament: BibleTestament.old,
    chapters: 4,
  ),
  BibleCatalogEntry(
    id: 'mat',
    name: 'Mateus',
    testament: BibleTestament.newTestament,
    chapters: 28,
  ),
  BibleCatalogEntry(
    id: 'mrk',
    name: 'Marcos',
    testament: BibleTestament.newTestament,
    chapters: 16,
  ),
  BibleCatalogEntry(
    id: 'luk',
    name: 'Lucas',
    testament: BibleTestament.newTestament,
    chapters: 24,
  ),
  BibleCatalogEntry(
    id: 'jhn',
    name: 'João',
    testament: BibleTestament.newTestament,
    chapters: 21,
  ),
  BibleCatalogEntry(
    id: 'act',
    name: 'Atos',
    testament: BibleTestament.newTestament,
    chapters: 28,
  ),
  BibleCatalogEntry(
    id: 'rom',
    name: 'Romanos',
    testament: BibleTestament.newTestament,
    chapters: 16,
  ),
  BibleCatalogEntry(
    id: '1co',
    name: '1 Coríntios',
    testament: BibleTestament.newTestament,
    chapters: 16,
  ),
  BibleCatalogEntry(
    id: '2co',
    name: '2 Coríntios',
    testament: BibleTestament.newTestament,
    chapters: 13,
  ),
  BibleCatalogEntry(
    id: 'gal',
    name: 'Gálatas',
    testament: BibleTestament.newTestament,
    chapters: 6,
  ),
  BibleCatalogEntry(
    id: 'eph',
    name: 'Efésios',
    testament: BibleTestament.newTestament,
    chapters: 6,
  ),
  BibleCatalogEntry(
    id: 'php',
    name: 'Filipenses',
    testament: BibleTestament.newTestament,
    chapters: 4,
  ),
  BibleCatalogEntry(
    id: 'col',
    name: 'Colossenses',
    testament: BibleTestament.newTestament,
    chapters: 4,
  ),
  BibleCatalogEntry(
    id: '1th',
    name: '1 Tessalonicenses',
    testament: BibleTestament.newTestament,
    chapters: 5,
  ),
  BibleCatalogEntry(
    id: '2th',
    name: '2 Tessalonicenses',
    testament: BibleTestament.newTestament,
    chapters: 3,
  ),
  BibleCatalogEntry(
    id: '1ti',
    name: '1 Timóteo',
    testament: BibleTestament.newTestament,
    chapters: 6,
  ),
  BibleCatalogEntry(
    id: '2ti',
    name: '2 Timóteo',
    testament: BibleTestament.newTestament,
    chapters: 4,
  ),
  BibleCatalogEntry(
    id: 'tit',
    name: 'Tito',
    testament: BibleTestament.newTestament,
    chapters: 3,
  ),
  BibleCatalogEntry(
    id: 'phm',
    name: 'Filemom',
    testament: BibleTestament.newTestament,
    chapters: 1,
  ),
  BibleCatalogEntry(
    id: 'heb',
    name: 'Hebreus',
    testament: BibleTestament.newTestament,
    chapters: 13,
  ),
  BibleCatalogEntry(
    id: 'jas',
    name: 'Tiago',
    testament: BibleTestament.newTestament,
    chapters: 5,
  ),
  BibleCatalogEntry(
    id: '1pe',
    name: '1 Pedro',
    testament: BibleTestament.newTestament,
    chapters: 5,
  ),
  BibleCatalogEntry(
    id: '2pe',
    name: '2 Pedro',
    testament: BibleTestament.newTestament,
    chapters: 3,
  ),
  BibleCatalogEntry(
    id: '1jn',
    name: '1 João',
    testament: BibleTestament.newTestament,
    chapters: 5,
  ),
  BibleCatalogEntry(
    id: '2jn',
    name: '2 João',
    testament: BibleTestament.newTestament,
    chapters: 1,
  ),
  BibleCatalogEntry(
    id: '3jn',
    name: '3 João',
    testament: BibleTestament.newTestament,
    chapters: 1,
  ),
  BibleCatalogEntry(
    id: 'jud',
    name: 'Judas',
    testament: BibleTestament.newTestament,
    chapters: 1,
  ),
  BibleCatalogEntry(
    id: 'rev',
    name: 'Apocalipse',
    testament: BibleTestament.newTestament,
    chapters: 22,
  ),
];

List<BibleBook> completeBible({Map<String, int> progress = const {}}) {
  return [
    for (final entry in bibleCatalog)
      entry.toBook(readChapters: progress[entry.id] ?? 0),
  ];
}
