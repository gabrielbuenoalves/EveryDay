import '../../../../core/domain/daily_reading.dart';
import '../entities/bible_passage.dart';

abstract interface class BibleRepository {
  Future<BiblePassage> getPassage(DailyReading reading);
}
