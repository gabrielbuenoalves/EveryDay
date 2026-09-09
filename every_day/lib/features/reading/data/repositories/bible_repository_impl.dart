import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/bible/usfm.dart';
import '../../../../core/domain/daily_reading.dart';
import '../../domain/entities/bible_passage.dart';
import '../../domain/repositories/bible_repository.dart';

class BibleRepositoryImpl implements BibleRepository {
  BibleRepositoryImpl(this._client);

  final SupabaseClient _client;

  @override
  Future<BiblePassage> getPassage(DailyReading reading) async {
    final passages = apiBiblePassageIds(
      book: reading.book,
      startChapter: reading.startChapter,
      endChapter: reading.endChapter,
      passageLabel: reading.passageLabel,
    );
    if (passages.isEmpty) {
      throw StateError(
        'Não foi possível identificar o trecho ${reading.passageLabel}.',
      );
    }

    final response = await _client.functions.invoke(
      'bible-passage',
      body: {'passages': passages},
    );
    if (response.status >= 400) {
      throw StateError('Não foi possível carregar o texto bíblico.');
    }

    final data = Map<String, dynamic>.from(response.data as Map);
    final chapters = <BibleChapterText>[];
    final rawChapters = data['chapters'];
    if (rawChapters is List) {
      for (final row in rawChapters) {
        final chapter = Map<String, dynamic>.from(row as Map);
        chapters.add(
          BibleChapterText(
            passageId: chapter['id'] as String? ?? '',
            reference: chapter['reference'] as String? ?? reading.passageLabel,
            content: chapter['content'] as String? ?? '',
            verses: _verses(chapter['verses']),
          ),
        );
      }
    }

    return BiblePassage(
      abbreviation: data['abbreviation'] as String? ?? '',
      title: data['title'] as String?,
      copyright: data['copyright'] as String?,
      info: data['info'] as String?,
      chapters: chapters,
    );
  }

  List<BibleVerse> _verses(Object? raw) {
    if (raw is! List) return const [];
    return [
      for (final row in raw)
        if (row is Map)
          BibleVerse(
            number: '${row['number'] ?? ''}',
            text: '${row['text'] ?? ''}',
          ),
    ].where((verse) => verse.text.trim().isNotEmpty).toList();
  }
}
