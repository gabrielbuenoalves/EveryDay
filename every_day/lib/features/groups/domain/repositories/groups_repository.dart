import '../entities/reading_group.dart';

abstract interface class GroupsRepository {
  Future<List<ReadingGroup>> getGroups();
}
