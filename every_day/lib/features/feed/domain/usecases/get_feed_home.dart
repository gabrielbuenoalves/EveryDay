import '../entities/feed_home.dart';
import '../repositories/feed_repository.dart';

class GetFeedHome {
  const GetFeedHome(this._repository);

  final FeedRepository _repository;

  Future<FeedHome> call() => _repository.getHome();
}
