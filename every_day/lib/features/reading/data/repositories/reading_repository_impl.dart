import '../../domain/entities/reading_log.dart';
import '../../domain/repositories/reading_repository.dart';
import '../datasources/reading_local_datasource.dart';

class ReadingRepositoryImpl implements ReadingRepository {
  const ReadingRepositoryImpl(this._local);

  final ReadingLocalDataSource _local;

  @override
  Future<void> logReading(ReadingLog log) async => _local.save(log);
}
