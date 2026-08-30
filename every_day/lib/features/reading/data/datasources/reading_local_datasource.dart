import '../../domain/entities/reading_log.dart';

class ReadingLocalDataSource {
  final List<ReadingLog> logs = [];

  void save(ReadingLog log) {
    logs.insert(0, log);
  }
}
