import 'package:flutter/material.dart';

import '../../../../app/di/app_scope.dart';
import '../../../../core/domain/daily_reading.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_avatar.dart';
import '../../../../core/widgets/proto.dart';
import '../../../care/presentation/pages/plan_reflection_page.dart';
import '../../../plans/domain/repositories/plans_repository.dart';
import '../../domain/entities/bible_passage.dart';
import '../../domain/entities/reading_log.dart';
import '../../domain/usecases/get_bible_passage.dart';

class ReadingPage extends StatefulWidget {
  const ReadingPage({
    super.key,
    required this.reading,
    this.embedded = false,
    this.daily = true,
    this.playlist = const [],
    this.initialIndex = 0,
    this.completedLabels = const {},
    this.planId,
    this.planTitle,
    this.groupId,
    this.readingPlanId,
    this.allowArchive = true,
  });

  final DailyReading reading;
  final bool embedded;
  final bool daily;
  final List<DailyReading> playlist;
  final int initialIndex;
  final Set<String> completedLabels;
  final String? planId;
  final String? planTitle;
  final String? groupId;
  final String? readingPlanId;
  final bool allowArchive;

  static Future<bool> open(
    BuildContext context, {
    required DailyReading reading,
    List<DailyReading> playlist = const [],
    int index = 0,
    Set<String> completedLabels = const {},
    bool daily = false,
    String? planId,
    String? planTitle,
    String? groupId,
    String? readingPlanId,
    bool allowArchive = true,
  }) async {
    final changed = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => ReadingPage(
          reading: reading,
          playlist: playlist,
          initialIndex: index,
          completedLabels: completedLabels,
          daily: daily,
          planId: planId,
          planTitle: planTitle,
          groupId: groupId,
          readingPlanId: readingPlanId,
          allowArchive: allowArchive,
        ),
      ),
    );
    return changed ?? false;
  }

  @override
  State<ReadingPage> createState() => _ReadingPageState();
}

class _ReadingPageState extends State<ReadingPage> {
  GetBiblePassage? _getPassage;
  BiblePassage? _passage;
  Object? _error;
  var _loading = true;
  var _started = false;
  var _completing = false;
  var _changed = false;
  var _sendingComment = false;
  late int _index;
  late Set<String> _done;
  late DateTime _segmentAt;
  var _loggedMinutes = 0;
  final _commentCtrl = TextEditingController();
  List<PassageComment> _comments = const [];

  List<DailyReading> get _playlist {
    if (widget.playlist.length > 1) return widget.playlist;
    return [widget.reading];
  }

  DailyReading get _current {
    final list = _playlist;
    if (_index < 0 || _index >= list.length) return widget.reading;
    return list[_index];
  }

  bool get _isDone => _done.contains(_current.passageLabel.toLowerCase());

  int get _segmentMinutes {
    final seconds = DateTime.now().difference(_segmentAt).inSeconds;
    if (seconds < 20) return 1;
    return (seconds / 60).ceil().clamp(1, 180);
  }

  int get _sessionMinutes {
    if (_loggedMinutes > 0) return _loggedMinutes.clamp(1, 180);
    return _segmentMinutes;
  }

  bool get _isDirected =>
      widget.allowArchive &&
      (widget.planId != null ||
          (widget.groupId != null && widget.readingPlanId != null));

  bool get _allPlanDone =>
      _isDirected &&
      _playlist.every((item) => _done.contains(item.passageLabel.toLowerCase()));

  Future<void> _archivePlan() async {
    if (!_isDirected || _completing) return;
    setState(() => _completing = true);
    final deps = AppScope.of(context);
    final archived = await showPlanReflectionSheet(
      context,
      planTitle: widget.planTitle ?? 'Leitura',
      minutes: _sessionMinutes,
      commentTitle: widget.planId != null
          ? 'Comentário para o pastor'
          : 'Comentário',
      onSubmit: (reflection) async {
        if (widget.planId != null) {
          await deps.completeCarePlan(
            planId: widget.planId!,
            reflection: reflection,
          );
        } else {
          await deps.completeGroupPlan(
            groupId: widget.groupId!,
            planId: widget.readingPlanId!,
            reflection: reflection,
          );
        }
      },
    );
    if (!mounted) return;
    setState(() => _completing = false);
    if (archived) {
      deps.feedReload.ping();
      Navigator.of(context).pop(true);
    }
  }

  @override
  void dispose() {
    _commentCtrl.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _index = widget.initialIndex.clamp(0, 999);
    _done = {
      for (final label in widget.completedLabels) label.toLowerCase(),
    };
    _segmentAt = DateTime.now();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _getPassage ??= AppScope.of(context).getBiblePassage;
    if (_started) return;
    _started = true;
    if (_index >= _playlist.length) _index = 0;
    _load();
  }

  Future<void> _load() async {
    final getPassage = _getPassage;
    if (getPassage == null) return;
    setState(() {
      _loading = true;
      _error = null;
      _passage = null;
    });
    try {
      final passage = await getPassage(_current);
      if (!mounted) return;
      setState(() {
        _passage = passage;
        _loading = false;
      });
      await _loadComments();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e;
        _loading = false;
      });
    }
  }

  Future<void> _loadComments() async {
    final groupId = widget.groupId;
    if (groupId == null || !mounted) return;
    try {
      final comments = await AppScope.of(
        context,
      ).listPlanComments(groupId: groupId, passageLabel: _current.passageLabel);
      if (!mounted) return;
      setState(() => _comments = comments);
    } catch (_) {
      if (!mounted) return;
      setState(() => _comments = const []);
    }
  }

  Future<void> _sendComment() async {
    final groupId = widget.groupId;
    final body = _commentCtrl.text.trim();
    if (groupId == null || body.isEmpty || _sendingComment) return;
    setState(() => _sendingComment = true);
    try {
      await AppScope.of(context).addPlanComment(
        groupId: groupId,
        planId: widget.readingPlanId,
        passageLabel: _current.passageLabel,
        body: body,
      );
      if (!mounted) return;
      _commentCtrl.clear();
      setState(() => _sendingComment = false);
      await _loadComments();
    } catch (e) {
      if (!mounted) return;
      setState(() => _sendingComment = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
    }
  }

  void _select(int index) {
    if (index < 0 || index >= _playlist.length || index == _index) return;
    setState(() => _index = index);
    _load();
  }

  Future<void> _complete() async {
    if (_isDone || _completing) return;
    setState(() => _completing = true);
    try {
      final mins = _segmentMinutes;
      await AppScope.of(context).logReading(
        ReadingLog(
          passageLabel: _current.passageLabel,
          minutes: mins,
        ),
      );
      if (!mounted) return;
      setState(() {
        _done.add(_current.passageLabel.toLowerCase());
        _loggedMinutes += mins;
        _segmentAt = DateTime.now();
        _changed = true;
        _completing = false;
      });
      AppScope.of(context).feedReload.ping();
      final next = _playlist.indexWhere(
        (item) => !_done.contains(item.passageLabel.toLowerCase()),
      );
      if (next >= 0 && next != _index) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${_current.passageLabel} concluída')),
        );
        _select(next);
        return;
      }
      if (_allPlanDone) {
        await _archivePlan();
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Leitura marcada como concluída')),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _completing = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final body = _content();
    if (widget.embedded) return body;
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        Navigator.of(context).pop(_changed);
      },
      child: Scaffold(
        backgroundColor: AppColors.slate900,
        appBar: AppBar(title: Text(_current.passageLabel)),
        body: body,
        bottomNavigationBar: _bottomBar(),
      ),
    );
  }

  Widget? _bottomBar() {
    final list = _playlist;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (list.length > 1)
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _index == 0 ? null : () => _select(_index - 1),
                      child: const Text('Anterior'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _index >= list.length - 1
                          ? null
                          : () => _select(_index + 1),
                      child: const Text('Próxima'),
                    ),
                  ),
                ],
              ),
            if (list.length > 1) const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              height: 44,
              child: FilledButton(
                onPressed: _completing
                    ? null
                    : _allPlanDone
                    ? _archivePlan
                    : _isDone
                    ? null
                    : _complete,
                style: FilledButton.styleFrom(
                  backgroundColor: _allPlanDone
                      ? AppColors.ember
                      : _isDone
                      ? const Color(0xFF166534)
                      : AppColors.ember,
                  foregroundColor: _allPlanDone || !_isDone
                      ? AppColors.slate950
                      : Colors.white,
                ),
                child: Text(
                  _completing
                      ? 'Salvando…'
                      : _allPlanDone
                      ? 'Encerrar plano'
                      : _isDone
                      ? 'Leitura concluída'
                      : 'Marcar como lida',
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _content() {
    final passage = _passage;
    final list = _playlist;
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(18, 20, 18, 18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.emberDark, AppColors.ember],
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              MiniLabel(
                [
                  list.length > 1
                      ? 'Leitura ${_index + 1} de ${list.length}'
                      : (widget.daily ? 'Leitura do pastor' : 'Bíblia'),
                  if (passage != null && passage.abbreviation.isNotEmpty)
                    passage.abbreviation,
                ].join(' · '),
                dark: true,
              ),
              const SizedBox(height: 4),
              Text(
                passage?.chapters.firstOrNull?.reference ??
                    _current.passageLabel,
                style: const TextStyle(
                  color: AppColors.slate950,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                passage?.title ?? _current.book,
                style: const TextStyle(
                  color: AppColors.slate950,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        if (list.length > 1) ...[
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (var i = 0; i < list.length; i++)
                _PassageChip(
                  label: list[i].passageLabel,
                  selected: i == _index,
                  done: _done.contains(list[i].passageLabel.toLowerCase()),
                  onTap: () => _select(i),
                ),
            ],
          ),
        ],
        const SizedBox(height: 8),
        if (_loading)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 48),
            child: Center(
              child: CircularProgressIndicator(color: AppColors.ember),
            ),
          )
        else ...[
          _scripture(passage),
          if (widget.groupId != null) _groupComments(),
        ],
      ],
    );
  }

  Widget _groupComments() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const ProtoSection(title: 'Comentários do grupo'),
        if (_comments.isEmpty)
          const Padding(
            padding: EdgeInsets.only(bottom: 12),
            child: Text(
              'Ninguém comentou este trecho ainda. O que o grupo está vendo aqui fica só entre vocês.',
              style: TextStyle(
                color: AppColors.slate400,
                fontSize: 12,
                height: 1.4,
              ),
            ),
          )
        else
          for (final comment in _comments)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppAvatar(
                    initials: comment.author.initials,
                    color: Color(comment.author.avatarColorValue),
                    size: 32,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          comment.author.displayName,
                          style: const TextStyle(
                            color: AppColors.slate100,
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          comment.body,
                          style: const TextStyle(
                            color: AppColors.slate300,
                            fontSize: 13,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
        TextField(
          controller: _commentCtrl,
          minLines: 2,
          maxLines: 4,
          decoration: const InputDecoration(
            hintText: 'Escreva um comentário para o grupo',
          ),
        ),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerRight,
          child: EmberButton(
            label: _sendingComment ? 'Enviando…' : 'Comentar',
            onPressed: _sendingComment ? null : _sendComment,
          ),
        ),
      ],
    );
  }

  Widget _scripture(BiblePassage? passage) {
    if (passage != null && !passage.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final chapter in passage.chapters) ...[
            if (passage.chapters.length > 1) ...[
              Padding(
                padding: const EdgeInsets.only(top: 8, bottom: 12),
                child: Text(
                  chapter.reference,
                  style: const TextStyle(
                    color: AppColors.ember,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
            if (chapter.verses.isNotEmpty)
              for (final verse in chapter.verses)
                Padding(
                  padding: const EdgeInsets.only(bottom: 13),
                  child: Text.rich(
                    TextSpan(
                      children: [
                        if (verse.number.isNotEmpty)
                          TextSpan(
                            text: '${verse.number}  ',
                            style: const TextStyle(
                              color: AppColors.ember,
                              fontWeight: FontWeight.w900,
                              fontFamily: 'Georgia',
                              fontSize: 13,
                            ),
                          ),
                        TextSpan(text: verse.text),
                      ],
                    ),
                    style: const TextStyle(
                      fontFamily: 'Georgia',
                      color: AppColors.slate300,
                      fontSize: 17,
                      height: 1.85,
                    ),
                  ),
                )
            else
              Text(
                chapter.content,
                style: const TextStyle(
                  fontFamily: 'Georgia',
                  color: AppColors.slate300,
                  fontSize: 17,
                  height: 1.85,
                ),
              ),
          ],
          if (passage.copyright != null && passage.copyright!.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(
              passage.copyright!,
              style: const TextStyle(
                color: AppColors.slate500,
                fontSize: 11,
                height: 1.4,
              ),
            ),
          ],
        ],
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Não foi possível carregar o texto da Bíblia agora.',
          style: const TextStyle(
            fontFamily: 'Georgia',
            color: AppColors.slate300,
            fontSize: 16,
            height: 1.8,
          ),
        ),
        if (_error != null) ...[
          const SizedBox(height: 12),
          Text(
            '$_error',
            style: const TextStyle(color: AppColors.ember, fontSize: 12),
          ),
        ],
        const SizedBox(height: 16),
        EmberButton(label: 'Tentar de novo', onPressed: _load),
      ],
    );
  }
}

class _PassageChip extends StatelessWidget {
  const _PassageChip({
    required this.label,
    required this.selected,
    required this.done,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final bool done;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: BoxDecoration(
          color: selected ? AppColors.ember : AppColors.slate800,
          borderRadius: BorderRadius.circular(99),
          border: Border.all(
            color: selected
                ? AppColors.ember
                : done
                ? const Color(0xFF4ADE80)
                : AppColors.slate700,
          ),
        ),
        child: Text(
          done ? '✓ $label' : label,
          style: TextStyle(
            color: selected ? AppColors.slate950 : AppColors.slate100,
            fontSize: 11,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}
