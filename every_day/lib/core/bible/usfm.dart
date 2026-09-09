String? usfmBookCode(String book) {
  final key = normalizeBookName(book);
  if (key.isEmpty) return null;
  return _aliases[key] ?? _usfmIfLooksLikeCode(key);
}

/// API.Bible passage IDs are two verse IDs joined by `-`, max 200 verses.
const apiBibleMaxPassageVerses = 200;

List<String> usfmPassageIds({
  required String book,
  required int startChapter,
  required int endChapter,
  String? passageLabel,
  int maxChapters = 10,
}) {
  final fromLabel = usfmIdsFromLabel(passageLabel);
  if (fromLabel.isNotEmpty) return fromLabel;

  final code = usfmBookCode(book);
  if (code == null) return const [];
  final start = startChapter < 1 ? 1 : startChapter;
  var end = endChapter < start ? start : endChapter;
  if (end - start + 1 > maxChapters) {
    end = start + maxChapters - 1;
  }
  return [
    for (var chapter = start; chapter <= end; chapter++) '$code.$chapter',
  ];
}

List<String> usfmIdsFromLabel(String? label) {
  if (label == null || label.trim().isEmpty) return const [];
  final verse = RegExp(r'^(.+?)\s+(\d+):(\d+)(?:\s*[-–]\s*(\d+))?$')
      .firstMatch(label.trim());
  if (verse != null) {
    final code = usfmBookCode(verse.group(1)!);
    if (code == null) return const [];
    final chapter = verse.group(2)!;
    final start = int.parse(verse.group(3)!);
    final end = int.parse(verse.group(4) ?? verse.group(3)!);
    if (end < start || end - start + 1 > apiBibleMaxPassageVerses) {
      return ['$code.$chapter'];
    }
    if (start == end) return ['$code.$chapter.$start'];
    return ['$code.$chapter.$start-$code.$chapter.$end'];
  }

  final chapters = RegExp(r'^(.+?)\s+(\d+)\s*[-–]\s*(\d+)$')
      .firstMatch(label.trim());
  if (chapters != null) {
    return usfmPassageIds(
      book: chapters.group(1)!,
      startChapter: int.parse(chapters.group(2)!),
      endChapter: int.parse(chapters.group(3)!),
    );
  }
  return const [];
}

/// IDs nativos da API.Bible: capítulo `JHN.8`, versículo `JHN.3.16`,
/// trecho `JHN.3.1-JHN.3.16`.
String usfmToApiBiblePassageId(String usfm) => usfm;

List<String> apiBiblePassageIds({
  required String book,
  required int startChapter,
  required int endChapter,
  String? passageLabel,
}) {
  return usfmPassageIds(
    book: book,
    startChapter: startChapter,
    endChapter: endChapter,
    passageLabel: passageLabel,
  );
}

String normalizeBookName(String book) {
  final buffer = StringBuffer();
  for (final rune in book.trim().toLowerCase().runes) {
    final mapped = _fold[rune];
    if (mapped != null) {
      buffer.writeCharCode(mapped);
    } else if (rune == 32 || rune == 45) {
      if (buffer.isNotEmpty && buffer.toString().codeUnits.last != 32) {
        buffer.writeCharCode(32);
      }
    } else {
      buffer.writeCharCode(rune);
    }
  }
  return buffer.toString().trim();
}

String? _usfmIfLooksLikeCode(String key) {
  if (RegExp(r'^[1-3][a-z]{2}$').hasMatch(key) ||
      RegExp(r'^[a-z]{3}$').hasMatch(key)) {
    return key.toUpperCase();
  }
  return null;
}

const _fold = {
  0xE1: 0x61,
  0xE0: 0x61,
  0xE3: 0x61,
  0xE2: 0x61,
  0xE4: 0x61,
  0xE9: 0x65,
  0xE8: 0x65,
  0xEA: 0x65,
  0xEB: 0x65,
  0xED: 0x69,
  0xEC: 0x69,
  0xEE: 0x69,
  0xEF: 0x69,
  0xF3: 0x6F,
  0xF2: 0x6F,
  0xF5: 0x6F,
  0xF4: 0x6F,
  0xF6: 0x6F,
  0xFA: 0x75,
  0xF9: 0x75,
  0xFB: 0x75,
  0xFC: 0x75,
  0xE7: 0x63,
};

const _aliases = {
  'genesis': 'GEN',
  'gen': 'GEN',
  'exodo': 'EXO',
  'exo': 'EXO',
  'levitico': 'LEV',
  'lev': 'LEV',
  'numeros': 'NUM',
  'num': 'NUM',
  'deuteronomio': 'DEU',
  'deu': 'DEU',
  'josue': 'JOS',
  'jos': 'JOS',
  'juizes': 'JDG',
  'juiz': 'JDG',
  'jdg': 'JDG',
  'rute': 'RUT',
  'rut': 'RUT',
  '1 samuel': '1SA',
  '1samuel': '1SA',
  '1sa': '1SA',
  '2 samuel': '2SA',
  '2samuel': '2SA',
  '2sa': '2SA',
  'salmos': 'PSA',
  'salmo': 'PSA',
  'psa': 'PSA',
  'proverbios': 'PRO',
  'proverbio': 'PRO',
  'pro': 'PRO',
  'isaias': 'ISA',
  'isa': 'ISA',
  'mateus': 'MAT',
  'mat': 'MAT',
  'marcos': 'MRK',
  'mrk': 'MRK',
  'lucas': 'LUK',
  'luk': 'LUK',
  'joao': 'JHN',
  'jhn': 'JHN',
  'atos': 'ACT',
  'act': 'ACT',
  'romanos': 'ROM',
  'rom': 'ROM',
  '1 corintios': '1CO',
  '1corintios': '1CO',
  '1co': '1CO',
  'galatas': 'GAL',
  'gal': 'GAL',
  'efesios': 'EPH',
  'eph': 'EPH',
  'filipenses': 'PHP',
  'php': 'PHP',
  '1 reis': '1KI',
  '1reis': '1KI',
  '1ki': '1KI',
  '2 reis': '2KI',
  '2reis': '2KI',
  '2ki': '2KI',
  '1 cronicas': '1CH',
  '1cronicas': '1CH',
  '1ch': '1CH',
  '2 cronicas': '2CH',
  '2cronicas': '2CH',
  '2ch': '2CH',
  'esdras': 'EZR',
  'ezr': 'EZR',
  'neemias': 'NEH',
  'neh': 'NEH',
  'ester': 'EST',
  'est': 'EST',
  'jo': 'JOB',
  'job': 'JOB',
  'eclesiastes': 'ECC',
  'ecc': 'ECC',
  'canticos': 'SNG',
  'cantico': 'SNG',
  'sng': 'SNG',
  'jeremias': 'JER',
  'jer': 'JER',
  'lamentacoes': 'LAM',
  'lam': 'LAM',
  'ezequiel': 'EZK',
  'ezk': 'EZK',
  'daniel': 'DAN',
  'dan': 'DAN',
  'oseias': 'HOS',
  'hos': 'HOS',
  'joel': 'JOL',
  'jol': 'JOL',
  'amos': 'AMO',
  'amo': 'AMO',
  'obadias': 'OBA',
  'oba': 'OBA',
  'jonas': 'JON',
  'jon': 'JON',
  'miqueias': 'MIC',
  'mic': 'MIC',
  'naum': 'NAM',
  'nam': 'NAM',
  'habacuque': 'HAB',
  'hab': 'HAB',
  'sofonias': 'ZEP',
  'zep': 'ZEP',
  'ageu': 'HAG',
  'hag': 'HAG',
  'zacarias': 'ZEC',
  'zec': 'ZEC',
  'malaquias': 'MAL',
  'mal': 'MAL',
  '2 corintios': '2CO',
  '2corintios': '2CO',
  '2co': '2CO',
  'colossenses': 'COL',
  'col': 'COL',
  '1 tessalonicenses': '1TH',
  '1tessalonicenses': '1TH',
  '1th': '1TH',
  '2 tessalonicenses': '2TH',
  '2tessalonicenses': '2TH',
  '2th': '2TH',
  '1 timoteo': '1TI',
  '1timoteo': '1TI',
  '1ti': '1TI',
  '2 timoteo': '2TI',
  '2timoteo': '2TI',
  '2ti': '2TI',
  'tito': 'TIT',
  'tit': 'TIT',
  'filemom': 'PHM',
  'phm': 'PHM',
  'hebreus': 'HEB',
  'heb': 'HEB',
  'tiago': 'JAS',
  'jas': 'JAS',
  '1 pedro': '1PE',
  '1pedro': '1PE',
  '1pe': '1PE',
  '2 pedro': '2PE',
  '2pedro': '2PE',
  '2pe': '2PE',
  '1 joao': '1JN',
  '1joao': '1JN',
  '1jn': '1JN',
  '2 joao': '2JN',
  '2joao': '2JN',
  '2jn': '2JN',
  '3 joao': '3JN',
  '3joao': '3JN',
  '3jn': '3JN',
  'judas': 'JUD',
  'jud': 'JUD',
  'apocalipse': 'REV',
  'rev': 'REV',
};
