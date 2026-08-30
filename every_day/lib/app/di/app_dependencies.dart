import '../../features/feed/data/datasources/feed_local_datasource.dart';
import '../../features/feed/data/repositories/feed_repository_impl.dart';
import '../../features/feed/domain/usecases/get_feed_home.dart';
import '../../features/groups/data/datasources/groups_local_datasource.dart';
import '../../features/groups/data/repositories/groups_repository_impl.dart';
import '../../features/groups/domain/usecases/get_groups.dart';
import '../../features/profile/data/datasources/profile_local_datasource.dart';
import '../../features/profile/data/repositories/profile_repository_impl.dart';
import '../../features/profile/domain/usecases/get_profile.dart';
import '../../features/reading/data/datasources/reading_local_datasource.dart';
import '../../features/reading/data/repositories/reading_repository_impl.dart';
import '../../features/reading/domain/usecases/log_reading.dart';
import '../../features/shelf/data/datasources/shelf_local_datasource.dart';
import '../../features/shelf/data/repositories/shelf_repository_impl.dart';
import '../../features/shelf/domain/usecases/get_bookshelf.dart';

class AppDependencies {
  const AppDependencies({
    required this.getFeedHome,
    required this.getBookshelf,
    required this.getGroups,
    required this.getProfile,
    required this.logReading,
  });

  final GetFeedHome getFeedHome;
  final GetBookshelf getBookshelf;
  final GetGroups getGroups;
  final GetProfile getProfile;
  final LogReading logReading;

  factory AppDependencies.bootstrap() {
    final feedRepository = FeedRepositoryImpl(FeedLocalDataSource());
    final shelfRepository = ShelfRepositoryImpl(ShelfLocalDataSource());
    final groupsRepository = GroupsRepositoryImpl(GroupsLocalDataSource());
    final profileRepository = ProfileRepositoryImpl(ProfileLocalDataSource());
    final readingRepository = ReadingRepositoryImpl(ReadingLocalDataSource());

    return AppDependencies(
      getFeedHome: GetFeedHome(feedRepository),
      getBookshelf: GetBookshelf(shelfRepository),
      getGroups: GetGroups(groupsRepository),
      getProfile: GetProfile(profileRepository),
      logReading: LogReading(readingRepository),
    );
  }
}
