import '../../domain/entities/reading_group.dart';
import '../../domain/repositories/groups_repository.dart';
import '../datasources/groups_local_datasource.dart';

class GroupsRepositoryImpl implements GroupsRepository {
  const GroupsRepositoryImpl(this._local);

  final GroupsLocalDataSource _local;

  @override
  Future<List<ReadingGroup>> getGroups() async => _local.fetch();
}
