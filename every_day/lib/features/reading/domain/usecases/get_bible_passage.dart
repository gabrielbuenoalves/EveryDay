import '../../../../core/domain/daily_reading.dart';
import '../entities/bible_passage.dart';
import '../repositories/bible_repository.dart';

class GetBiblePassage {
  const GetBiblePassage(this._repository);

  final BibleRepository _repository;

  Future<BiblePassage> call(DailyReading reading) =>
      _repository.getPassage(reading);
}
