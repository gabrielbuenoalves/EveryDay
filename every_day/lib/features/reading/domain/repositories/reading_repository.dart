import '../entities/reading_log.dart';

abstract interface class ReadingRepository {
  Future<void> logReading(ReadingLog log);
}
