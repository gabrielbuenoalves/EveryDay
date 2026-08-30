import '../entities/bible_book.dart';

abstract interface class ShelfRepository {
  Future<Bookshelf> getBookshelf();
}
