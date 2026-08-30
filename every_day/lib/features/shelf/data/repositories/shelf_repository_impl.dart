import '../../domain/entities/bible_book.dart';
import '../../domain/repositories/shelf_repository.dart';
import '../datasources/shelf_local_datasource.dart';

class ShelfRepositoryImpl implements ShelfRepository {
  const ShelfRepositoryImpl(this._local);

  final ShelfLocalDataSource _local;

  @override
  Future<Bookshelf> getBookshelf() async => _local.fetch();
}
