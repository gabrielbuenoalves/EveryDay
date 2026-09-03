import 'package:flutter/material.dart';

import '../../../../app/di/app_scope.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/screen_header.dart';
import '../../domain/entities/bible_book.dart';
import '../../domain/usecases/get_bookshelf.dart';

class ShelfPage extends StatefulWidget {
  const ShelfPage({super.key});

  @override
  State<ShelfPage> createState() => _ShelfPageState();
}

class _ShelfPageState extends State<ShelfPage> {
  Bookshelf? _shelf;
  var _started = false;
  Object? _error;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    _load(AppScope.of(context).getBookshelf);
  }

  Future<void> _load(GetBookshelf getBookshelf) async {
    Bookshelf? shelf;
    try {
      shelf = await getBookshelf();
    } catch (error) {
      if (mounted) setState(() => _error = error);
      return;
    }
    if (!mounted) return;
    setState(() {
      _shelf = shelf;
      _error = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final shelf = _shelf;

    return SafeArea(
      bottom: false,
      child: Column(
        children: [
          const ScreenHeader(title: 'Estante'),
          Expanded(
            child: _error != null
                ? _ShelfError(
                    onRetry: () => _load(AppScope.of(context).getBookshelf),
                  )
                : shelf == null
                ? const _ShelfLoading()
                : ListView(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
                    children: [
                      _ShelfSummary(shelf: shelf),
                      const SizedBox(height: 22),
                      _TestamentSection(
                        title: 'Antigo Testamento',
                        books: shelf.oldTestament,
                      ),
                      const SizedBox(height: 22),
                      _TestamentSection(
                        title: 'Novo Testamento',
                        books: shelf.newTestament,
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

class _ShelfSummary extends StatelessWidget {
  const _ShelfSummary({required this.shelf});

  final Bookshelf shelf;

  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      color: AppColors.charcoal,
      padding: const EdgeInsets.fromLTRB(20, 20, 16, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'SUA BÍBLIA',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: const Color(0xFFC8C2B8),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${shelf.completedBooks} livros concluídos',
                      style: const TextStyle(
                        color: AppColors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.4,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '${shelf.books.length}',
                style: const TextStyle(
                  color: Color(0xFFC8C2B8),
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              minHeight: 8,
              value: shelf.books.isEmpty
                  ? 0
                  : shelf.completedBooks / shelf.books.length,
              backgroundColor: AppColors.slate700,
              color: AppColors.ember,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${shelf.completedBooks} de ${shelf.books.length} livros lidos',
            style: const TextStyle(color: AppColors.slate400, fontSize: 11),
          ),
        ],
      ),
    );
  }
}

class _ShelfLoading extends StatelessWidget {
  const _ShelfLoading();
  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
    children: [
      for (final height in [116.0, 18.0, 190.0, 18.0, 190.0])
        Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Container(
            height: height,
            decoration: BoxDecoration(
              color: AppColors.slate800,
              borderRadius: BorderRadius.circular(18),
            ),
          ),
        ),
    ],
  );
}

class _ShelfError extends StatelessWidget {
  const _ShelfError({required this.onRetry});
  final VoidCallback onRetry;
  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.cloud_off_rounded, color: AppColors.ember, size: 32),
          const SizedBox(height: 12),
          const Text(
            'Não foi possível carregar sua estante.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.slate300, fontSize: 14),
          ),
          const SizedBox(height: 16),
          FilledButton(onPressed: onRetry, child: const Text('Tentar de novo')),
        ],
      ),
    ),
  );
}

class _TestamentSection extends StatelessWidget {
  const _TestamentSection({required this.title, required this.books});

  final String title;
  final List<BibleBook> books;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title.toUpperCase(),
          style: Theme.of(context).textTheme.labelSmall,
        ),
        const SizedBox(height: 12),
        SurfaceCard(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Column(
            children: [
              for (var i = 0; i < books.length; i++) ...[
                _BookRow(book: books[i]),
                if (i < books.length - 1)
                  const Divider(height: 1, color: AppColors.divider),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _BookRow extends StatelessWidget {
  const _BookRow({required this.book});

  final BibleBook book;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(book.name, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 4),
                Text(
                  book.isCompleted
                      ? '${book.chapters} capítulos · concluído'
                      : book.isInProgress
                      ? '${book.readChapters} de ${book.chapters} capítulos'
                      : '${book.chapters} capítulos',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 72,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(99),
              child: LinearProgressIndicator(
                value: book.progress,
                minHeight: 8,
                backgroundColor: AppColors.creamDark,
                color: book.isCompleted
                    ? AppColors.checkGreen
                    : AppColors.forest,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
