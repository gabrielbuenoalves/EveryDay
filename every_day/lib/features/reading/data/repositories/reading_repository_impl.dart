import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/entities/reading_log.dart';
import '../../domain/repositories/reading_repository.dart';

class ReadingRepositoryImpl implements ReadingRepository {
  ReadingRepositoryImpl(this._client);

  final SupabaseClient _client;

  @override
  Future<void> logReading(ReadingLog log) async {
    await _client.rpc(
      'log_reading',
      params: {
        'p_passage': log.passageLabel,
        'p_minutes': log.minutes,
        'p_note': log.note ?? '',
      },
    );
  }
}
