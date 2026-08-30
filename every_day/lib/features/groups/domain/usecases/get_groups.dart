import '../entities/reading_group.dart';
import '../repositories/groups_repository.dart';

class GetGroups {
  const GetGroups(this._repository);

  final GroupsRepository _repository;

  Future<List<ReadingGroup>> call() => _repository.getGroups();
}
