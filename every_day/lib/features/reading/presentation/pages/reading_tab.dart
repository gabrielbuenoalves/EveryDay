import 'package:flutter/material.dart';

import '../../../../app/di/app_scope.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/proto.dart';
import '../../../care/presentation/pages/plan_reflection_page.dart';
import '../../../feed/domain/entities/feed_home.dart';
import '../../../feed/presentation/widgets/care_plan_card.dart';
import '../../../shelf/domain/bible_catalog.dart';
import '../../../shelf/domain/entities/bible_book.dart';
import 'bible_chapters_page.dart';
import 'reading_page.dart';

class ReadingTab extends StatefulWidget {
  const ReadingTab({super.key});

  @override
  State<ReadingTab> createState() => _ReadingTabState();
}

class _ReadingTabState extends State<ReadingTab> {
  var _loading = true;
  var _started = false;
  String _initials = 'ED';
  String _query = '';
  List<BibleBook> _books = completeBible();
  List<MemberCarePlan> _plans = const [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    _load();
  }

  Future<void> _load() async {
    final deps = AppScope.of(context);
    var initials = 'ED';
    var plans = <MemberCarePlan>[];
    final progress = <String, int>{};
    try {
      plans = await deps.getMyPlans();
    } catch (_) {}
    try {
      initials = (await deps.getProfile()).initials;
    } catch (_) {}
    try {
      for (final book in (await deps.getBookshelf()).books) {
        progress[book.id] = book.readChapters;
      }
    } catch (_) {}
    if (!mounted) return;
    setState(() {
      _loading = false;
      _initials = initials;
      _plans = plans;
      _books = completeBible(progress: progress);
    });
  }

  List<BibleBook> get _filtered {
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) return _books;
    return _books.where((book) => book.name.toLowerCase().contains(q)).toList();
  }

  Future<void> _openPlan(MemberCarePlan plan, int index) async {
    final changed = await ReadingPage.open(
      context,
      reading: plan.readings[index].reading,
      playlist: plan.playlist,
      index: index,
      completedLabels: plan.completedLabels,
      daily: plan.pastoral,
      planId: plan.pastoral ? plan.id : null,
      planTitle: plan.title,
      groupId: plan.groupId,
      readingPlanId: plan.readingPlanId,
      allowArchive: !plan.archived,
    );
    if (changed && mounted) await _load();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.ember),
      );
    }
    final books = _filtered;
    final old = books
        .where((book) => book.testament == BibleTestament.old)
        .toList();
    final nt = books
        .where((book) => book.testament == BibleTestament.newTestament)
        .toList();

    return SafeArea(
      bottom: false,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppScreenHeader(
              kicker: weekdayDateKicker(),
              title: 'Planos',
              initials: _initials,
            ),
            if (_plans.isEmpty)
              const ProtoCard(
                child: Text(
                  'Quando seu pastor ou um grupo enviar uma leitura, ela aparece aqui.',
                  style: TextStyle(color: AppColors.slate300),
                ),
              )
            else
              for (final plan in _plans) ...[
                CarePlanCard(
                  plan: plan,
                  onOpen: (index) => _openPlan(plan, index),
                  onFinish: plan.isComplete && !plan.archived
                      ? () async {
                          final archived = await finishDirectedPlan(
                            context,
                            plan: plan,
                          );
                          if (archived && mounted) await _load();
                        }
                      : null,
                ),
                const SizedBox(height: 8),
              ],
            ProtoSection(title: 'Bíblia', trailing: '${_books.length} livros'),
            const Text(
              'Buscar livro',
              style: TextStyle(
                color: AppColors.slate300,
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 7),
            TextField(
              onChanged: (value) => setState(() => _query = value),
              decoration: const InputDecoration(
                hintText: 'Gênesis, Salmos, João…',
              ),
            ),
            ProtoSection(
              title: 'Antigo Testamento',
              trailing: '${old.length} livros',
            ),
            for (final book in old)
              _BookTile(book: book, onOpen: () => _openBook(book)),
            ProtoSection(
              title: 'Novo Testamento',
              trailing: '${nt.length} livros',
            ),
            for (final book in nt)
              _BookTile(book: book, onOpen: () => _openBook(book)),
          ],
        ),
      ),
    );
  }

  void _openBook(BibleBook book) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => BibleChaptersPage(book: book)),
    );
  }
}

class _BookTile extends StatelessWidget {
  const _BookTile({required this.book, required this.onOpen});

  final BibleBook book;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: AppColors.slate800,
        borderRadius: BorderRadius.circular(13),
        child: InkWell(
          borderRadius: BorderRadius.circular(13),
          onTap: onOpen,
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(13),
              border: Border.all(color: AppColors.slate700),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        book.name,
                        style: const TextStyle(
                          color: AppColors.slate100,
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Text(
                        book.isInProgress
                            ? '${book.readChapters} de ${book.chapters} capítulos'
                            : '${book.chapters} capítulos',
                        style: const TextStyle(
                          color: AppColors.slate400,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.chevron_right,
                  color: AppColors.slate400,
                  size: 18,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
