import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/bible_catalog.dart';
import '../../domain/entities/bible_book.dart';
import '../../domain/repositories/shelf_repository.dart';

class ShelfRepositoryImpl implements ShelfRepository {
  ShelfRepositoryImpl(this._client);

  final SupabaseClient _client;

  @override
  Future<Bookshelf> getBookshelf() async {
    final uid = _client.auth.currentUser?.id;
    if (uid == null) throw StateError('not authenticated');

    final progress = <String, int>{};
    try {
      final rows = await _client
          .from('book_progress')
          .select('read_chapters, book_id, bible_books(id, name, testament, chapters)')
          .eq('user_id', uid);
      for (final row in rows) {
        final bookId = row['book_id'] as String? ??
            (row['bible_books'] is Map
                ? (row['bible_books'] as Map)['id'] as String?
                : null);
        if (bookId != null) {
          progress[bookId] = row['read_chapters'] as int? ?? 0;
        }
      }
    } catch (_) {}

    return Bookshelf(books: completeBible(progress: progress));
  }
}
