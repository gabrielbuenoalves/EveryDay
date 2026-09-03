enum BibleTestament { old, newTestament }

class BibleBook {
  const BibleBook({
    required this.id,
    required this.name,
    required this.testament,
    required this.chapters,
    required this.readChapters,
  });

  final String id;
  final String name;
  final BibleTestament testament;
  final int chapters;
  final int readChapters;

  bool get isCompleted => readChapters >= chapters;
  bool get isInProgress => readChapters > 0 && isCompleted == false;
  double get progress =>
      chapters == 0 ? 0 : (readChapters / chapters).clamp(0, 1);
}

class Bookshelf {
  const Bookshelf({required this.books});

  final List<BibleBook> books;

  List<BibleBook> get oldTestament =>
      books.where((book) => book.testament == BibleTestament.old).toList();

  List<BibleBook> get newTestament => books
      .where((book) => book.testament == BibleTestament.newTestament)
      .toList();

  int get completedBooks => books.where((book) => book.isCompleted).length;
}
