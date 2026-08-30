import '../entities/reading_log.dart';
import '../repositories/reading_repository.dart';

class LogReading {
  const LogReading(this._repository);

  final ReadingRepository _repository;

  Future<void> call(ReadingLog log) => _repository.logReading(log);
}
