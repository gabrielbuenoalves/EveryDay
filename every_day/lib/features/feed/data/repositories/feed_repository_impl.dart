import '../../domain/entities/feed_home.dart';
import '../../domain/repositories/feed_repository.dart';
import '../datasources/feed_local_datasource.dart';

class FeedRepositoryImpl implements FeedRepository {
  const FeedRepositoryImpl(this._local);

  final FeedLocalDataSource _local;

  @override
  Future<FeedHome> getHome() async => _local.fetchHome();
}
