import 'package:flutter/material.dart';

import '../../../../core/domain/daily_reading.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/proto.dart';
import '../../../shelf/domain/entities/bible_book.dart';
import 'reading_page.dart';

class BibleChaptersPage extends StatelessWidget {
  const BibleChaptersPage({super.key, required this.book});

  final BibleBook book;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.slate900,
      appBar: AppBar(title: Text(book.name)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          ProtoCard(
            challenge: book.isInProgress,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                MiniLabel(
                  book.testament == BibleTestament.old
                      ? 'Antigo Testamento'
                      : 'Novo Testamento',
                ),
                const SizedBox(height: 6),
                Text(
                  book.name,
                  style: const TextStyle(
                    color: AppColors.slate100,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  '${book.chapters} capítulos',
                  style: const TextStyle(
                    color: AppColors.slate400,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          ProtoSection(
            title: 'Capítulos',
            trailing: book.isInProgress
                ? '${book.readChapters}/${book.chapters} lidos'
                : 'Escolha um capítulo',
          ),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: book.chapters,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 5,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              childAspectRatio: 1.15,
            ),
            itemBuilder: (context, index) {
              final chapter = index + 1;
              return Material(
                color: chapter <= book.readChapters
                    ? const Color(0x18FF5C16)
                    : AppColors.slate800,
                borderRadius: BorderRadius.circular(12),
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => ReadingPage(
                          reading: DailyReading(
                            passageLabel: '${book.name} $chapter',
                            book: book.name,
                            startChapter: chapter,
                            endChapter: chapter,
                          ),
                          daily: false,
                        ),
                      ),
                    );
                  },
                  child: Container(
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: chapter <= book.readChapters
                            ? AppColors.ember
                            : AppColors.slate700,
                      ),
                    ),
                    child: Text(
                      '$chapter',
                      style: TextStyle(
                        color: chapter <= book.readChapters
                            ? AppColors.ember
                            : AppColors.slate100,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
