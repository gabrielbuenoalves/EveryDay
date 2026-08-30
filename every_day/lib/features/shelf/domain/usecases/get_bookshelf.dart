import '../entities/bible_book.dart';
import '../repositories/shelf_repository.dart';

class GetBookshelf {
  const GetBookshelf(this._repository);

  final ShelfRepository _repository;

  Future<Bookshelf> call() => _repository.getBookshelf();
}
