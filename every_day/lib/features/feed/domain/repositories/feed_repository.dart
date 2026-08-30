import '../entities/feed_home.dart';

abstract interface class FeedRepository {
  Future<FeedHome> getHome();
}
