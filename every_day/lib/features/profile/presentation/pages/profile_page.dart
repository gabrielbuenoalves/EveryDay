import 'package:flutter/material.dart';

import '../../../../app/di/app_scope.dart';
import '../../../../core/domain/user_role.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_avatar.dart';
import '../../../../core/widgets/proto.dart';
import '../../../groups/domain/entities/reading_group.dart';
import '../../../shelf/domain/entities/bible_book.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/usecases/get_profile.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  UserProfile? _profile;
  List<ReadingGroup> _groups = const [];
  BibleBook? _currentBook;
  var _started = false;

  late String _name;
  late String _username;
  late String _bio;
  late String _favoriteBook;
  late String _favoriteCharacter;
  late List<String> _specialties;
  late String _churchBio;
  late String _churchCity;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    _load(AppScope.of(context).getProfile);
  }

  Future<void> _load(GetProfile getProfile) async {
    final deps = AppScope.of(context);
    final profile = await getProfile();
    List<ReadingGroup> groups = const [];
    BibleBook? currentBook;
    try {
      groups = await deps.getGroups();
    } catch (_) {}
    try {
      final shelf = await deps.getBookshelf();
      final inProgress = shelf.books.where((book) => book.isInProgress);
      if (inProgress.isNotEmpty) {
        currentBook = inProgress.first;
      } else if (shelf.books.isNotEmpty) {
        currentBook = shelf.books.first;
      }
    } catch (_) {}
    if (!mounted) return;
    setState(() {
      _profile = profile;
      _groups = groups;
      _currentBook = currentBook;
      _name = profile.displayName;
      _username = profile.username;
      _bio = switch (profile.role) {
        UserRole.pastor =>
          'Pastor responsável · ${profile.churchName ?? 'sua igreja'}',
        UserRole.leader =>
          'Líder de grupo · acompanho a leitura da célula no dia a dia.',
        UserRole.member => 'Leio um pouco todo dia, mesmo nos corridos.',
      };
      _favoriteBook = currentBook?.name ?? profile.currentPlan;
      _favoriteCharacter = 'Davi';
      _specialties = groups.take(3).map((group) => group.name).toList();
      if (_specialties.isEmpty) {
        _specialties = const ['Leitura', 'Comunidade'];
      }
      _churchBio =
          'Existimos para acolher pessoas, fortalecer a fé no dia a dia e servir nossa cidade com graça, presença e propósito.';
      _churchCity = 'Cidade';
    });
  }

  int get _friends {
    final ids = {
      for (final group in _groups)
        for (final member in group.members) member.id,
    };
    return ids.length;
  }

  @override
  Widget build(BuildContext context) {
    final profile = _profile;
    return SafeArea(
      bottom: false,
      child: profile == null
          ? const Center(child: CircularProgressIndicator(color: AppColors.ember))
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
              children: [
                AppScreenHeader(
                  kicker: profile.role.label,
                  title: 'Perfil',
                  initials: profile.initials,
                ),
                if (profile.role.isPastor)
                  ..._pastorBody(profile)
                else if (profile.role.isLeader)
                  ..._leaderBody(profile)
                else
                  ..._memberBody(profile),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () => AppScope.of(context).auth.signOut(),
                  child: const Text(
                    'Sair',
                    style: TextStyle(color: AppColors.slate400),
                  ),
                ),
              ],
            ),
    );
  }

  List<Widget> _memberBody(UserProfile profile) {
    final book = _currentBook;
    final progress = book?.progress ?? 0.18;
    return [
      ProtoCard(
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.ember, width: 2),
              ),
              child: AppAvatar(
                initials: profile.initials,
                color: AppColors.slate800,
                foregroundColor: AppColors.slate100,
                size: 64,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              _name,
              style: const TextStyle(
                color: AppColors.slate100,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            Text(
              '$_username · $_friends amigos',
              style: const TextStyle(color: AppColors.slate400, fontSize: 12),
            ),
            const SizedBox(height: 8),
            const MiniLabel('Perfil do membro'),
            const SizedBox(height: 12),
            EmberButton(
              label: 'Editar perfil',
              onPressed: _editMember,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _HeroStat('${profile.streakDays}', 'dias seguidos'),
                _HeroStat('${profile.stats.chaptersThisWeek}', 'capítulos'),
                _HeroStat('${profile.stats.booksCompleted}/66', 'livros'),
              ],
            ),
          ],
        ),
      ),
      Row(
        children: [
          const Expanded(
            child: Text(
              'Sobre',
              style: TextStyle(
                color: AppColors.slate100,
                fontSize: 13,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          TextButton(
            onPressed: _editMember,
            style: TextButton.styleFrom(
              foregroundColor: AppColors.slate100,
              backgroundColor: AppColors.slate800,
              side: const BorderSide(color: AppColors.slate700),
              minimumSize: const Size(0, 36),
              padding: const EdgeInsets.symmetric(horizontal: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Editar', style: TextStyle(fontWeight: FontWeight.w800)),
          ),
        ],
      ),
      const SizedBox(height: 8),
      ProtoCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _bio,
              style: const TextStyle(color: AppColors.slate300, fontSize: 13),
            ),
            const SizedBox(height: 12),
            const Text(
              'Igreja',
              style: TextStyle(
                color: AppColors.slate100,
                fontWeight: FontWeight.w800,
                fontSize: 13,
              ),
            ),
            Text(
              '${profile.churchName ?? 'sem igreja'}${_churchCity.isEmpty ? '' : ' · $_churchCity'}',
              style: const TextStyle(color: AppColors.slate400, fontSize: 13),
            ),
            const SizedBox(height: 12),
            const Text(
              'Livro favorito',
              style: TextStyle(
                color: AppColors.slate100,
                fontWeight: FontWeight.w800,
                fontSize: 13,
              ),
            ),
            Text(
              _favoriteBook,
              style: const TextStyle(color: AppColors.slate400, fontSize: 13),
            ),
            const SizedBox(height: 12),
            const Text(
              'Personagem favorito',
              style: TextStyle(
                color: AppColors.slate100,
                fontWeight: FontWeight.w800,
                fontSize: 13,
              ),
            ),
            Text(
              _favoriteCharacter,
              style: const TextStyle(color: AppColors.slate400, fontSize: 13),
            ),
            const SizedBox(height: 12),
            const MiniLabel('Especialidades'),
            const SizedBox(height: 9),
            Wrap(
              spacing: 7,
              runSpacing: 7,
              children: [
                for (var i = 0; i < _specialties.length; i++)
                  SpecialtyChip(_specialties[i], active: i == 0),
              ],
            ),
          ],
        ),
      ),
      const ProtoSection(title: 'Consistência · 8 semanas', trailing: '86%'),
      const ProtoCard(
        child: WeekBars(
          heights: [0.34, 0.68, 0.48, 0.88, 0.58, 0.75, 0.92, 0.86],
        ),
      ),
      ProtoSection(
        title: 'Lendo agora',
        trailing: '${(progress * 100).round()}%',
      ),
      ProtoCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const MiniLabel('Livro atual'),
            const SizedBox(height: 6),
            Text(
              book?.name ?? profile.currentPlan,
              style: const TextStyle(
                color: AppColors.slate100,
                fontSize: 15,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              book == null
                  ? profile.currentPlan
                  : '${book.readChapters} de ${book.chapters} capítulos',
              style: const TextStyle(color: AppColors.slate300, fontSize: 11),
            ),
            const SizedBox(height: 13),
            EmberProgress(value: progress == 0 ? 0.18 : progress),
          ],
        ),
      ),
    ];
  }

  List<Widget> _leaderBody(UserProfile profile) {
    final people = {
      for (final group in _groups)
        for (final member in group.members) member.id,
    }.length;
    final avg = _groups.isEmpty
        ? 0.0
        : _groups.map((group) => group.weekProgress).reduce((a, b) => a + b) /
            _groups.length;
    final attention = _groups.where((group) => group.weekProgress < 0.5).length;
    final book = _currentBook;
    final progress = book?.progress ?? 0.18;

    return [
      ProtoCard(
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.ember, width: 2),
              ),
              child: AppAvatar(
                initials: profile.initials,
                color: AppColors.slate800,
                foregroundColor: AppColors.slate100,
                size: 64,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              _name,
              style: const TextStyle(
                color: AppColors.slate100,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            Text(
              'Líder de grupo · ${profile.churchName ?? 'sua igreja'}',
              style: const TextStyle(color: AppColors.slate400, fontSize: 12),
            ),
            const SizedBox(height: 8),
            const MiniLabel('Perfil do líder'),
            const SizedBox(height: 12),
            EmberButton(
              label: 'Editar perfil do líder',
              onPressed: _editMember,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _HeroStat('${_groups.length}', 'grupos'),
                _HeroStat('$people', 'membros'),
                _HeroStat('${(avg * 100).round()}%', 'leitura'),
              ],
            ),
          ],
        ),
      ),
      const SizedBox(height: 10),
      ProtoCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const MiniLabel('Sobre o líder'),
            const SizedBox(height: 6),
            Text(
              _bio,
              style: const TextStyle(color: AppColors.slate300, fontSize: 13, height: 1.4),
            ),
            const SizedBox(height: 12),
            const Text(
              'Igreja',
              style: TextStyle(
                color: AppColors.slate100,
                fontWeight: FontWeight.w800,
                fontSize: 13,
              ),
            ),
            Text(
              profile.churchName ?? 'sem igreja',
              style: const TextStyle(color: AppColors.slate400, fontSize: 13),
            ),
          ],
        ),
      ),
      ProtoSection(
        title: 'Grupos que lidero',
        trailing: _groups.isEmpty
            ? 'nenhum'
            : '$attention ${attention == 1 ? 'precisa de atenção' : 'precisam de atenção'}',
      ),
      if (_groups.isEmpty)
        const ProtoCard(
          child: Text(
            'Você ainda não tem um grupo. Peça o código ao pastor ou crie um na aba Grupos.',
            style: TextStyle(color: AppColors.slate300),
          ),
        )
      else
        for (final group in _groups) ...[
          ProtoCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                MiniLabel(participationLabel(group.weekProgress)),
                const SizedBox(height: 6),
                Text(
                  group.name,
                  style: const TextStyle(
                    color: AppColors.slate100,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${group.memberCount} membros · ${(group.weekProgress * 100).round()}% leram nesta semana',
                  style: const TextStyle(color: AppColors.slate300, fontSize: 11),
                ),
                const SizedBox(height: 13),
                EmberProgress(value: group.weekProgress == 0 ? 0.12 : group.weekProgress),
                if (group.inviteCode != null && group.inviteCode!.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  const MiniLabel('Código do grupo'),
                  const SizedBox(height: 4),
                  Text(
                    group.inviteCode!,
                    style: const TextStyle(
                      color: AppColors.slate100,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 2,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 10),
        ],
      ProtoSection(
        title: 'Minha leitura',
        trailing: '${(progress * 100).round()}%',
      ),
      ProtoCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const MiniLabel('Livro atual'),
            const SizedBox(height: 6),
            Text(
              book?.name ?? profile.currentPlan,
              style: const TextStyle(
                color: AppColors.slate100,
                fontSize: 15,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${profile.streakDays} dias seguidos · ${profile.stats.chaptersThisWeek} capítulos',
              style: const TextStyle(color: AppColors.slate300, fontSize: 11),
            ),
            const SizedBox(height: 13),
            EmberProgress(value: progress == 0 ? 0.18 : progress),
          ],
        ),
      ),
    ];
  }

  List<Widget> _pastorBody(UserProfile profile) {
    final members = {
      for (final group in _groups)
        for (final member in group.members) member.id,
    }.length;
    return [
      ProtoCard(
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.ember, width: 2),
              ),
              child: AppAvatar(
                initials: profile.initials,
                color: AppColors.slate800,
                foregroundColor: AppColors.slate100,
                size: 64,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              _name,
              style: const TextStyle(
                color: AppColors.slate100,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            Text(
              'Pastor responsável · ${profile.churchName ?? 'sua igreja'}',
              style: const TextStyle(color: AppColors.slate400, fontSize: 12),
            ),
            const SizedBox(height: 8),
            const MiniLabel('Perfil do pastor'),
          ],
        ),
      ),
      const SizedBox(height: 10),
      ProtoCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const MiniLabel('Igreja vinculada'),
            const SizedBox(height: 6),
            Text(
              profile.churchName ?? 'Igreja',
              style: const TextStyle(
                color: AppColors.slate100,
                fontSize: 15,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '$_churchCity · $members membros · ${_groups.length} grupos',
              style: const TextStyle(color: AppColors.slate300, fontSize: 11),
            ),
            const SizedBox(height: 10),
            Text(
              _churchBio,
              style: const TextStyle(color: AppColors.slate300, fontSize: 12, height: 1.45),
            ),
            if (profile.inviteCode != null) ...[
              const SizedBox(height: 12),
              const MiniLabel('Código de convite'),
              const SizedBox(height: 4),
              Text(
                profile.inviteCode!,
                style: const TextStyle(
                  color: AppColors.slate100,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 2,
                ),
              ),
            ],
            const SizedBox(height: 12),
            EmberButton(
              label: 'Editar perfil da igreja',
              onPressed: _editChurch,
            ),
          ],
        ),
      ),
      const SizedBox(height: 10),
      ProtoCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const MiniLabel('Dados pessoais'),
            const SizedBox(height: 6),
            const Text(
              'Seu perfil pastoral',
              style: TextStyle(
                color: AppColors.slate100,
                fontSize: 15,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Atualize sua foto, nome, apresentação e preferências da conta.',
              style: TextStyle(color: AppColors.slate300, fontSize: 11),
            ),
            const SizedBox(height: 12),
            EmberButton(
              label: 'Editar perfil do pastor',
              onPressed: _editMember,
            ),
          ],
        ),
      ),
    ];
  }

  Future<void> _editMember() async {
    final name = TextEditingController(text: _name);
    final username = TextEditingController(text: _username);
    final bio = TextEditingController(text: _bio);
    final book = TextEditingController(text: _favoriteBook);
    final character = TextEditingController(text: _favoriteCharacter);
    final specialties = TextEditingController(text: _specialties.join(', '));
    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.slate900,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.viewInsetsOf(context).bottom,
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 22, 24, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Editar perfil',
                  style: TextStyle(
                    color: AppColors.slate100,
                    fontSize: 23,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.6,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Atualize as informações da sua jornada.',
                  style: TextStyle(color: AppColors.slate400, fontSize: 12),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: name,
                  decoration: const InputDecoration(labelText: 'Nome'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: username,
                  decoration: const InputDecoration(labelText: 'Nome de usuário'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: bio,
                  maxLines: 3,
                  maxLength: 220,
                  decoration: const InputDecoration(labelText: 'Sobre'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: book,
                  decoration: const InputDecoration(labelText: 'Livro favorito'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: character,
                  decoration: const InputDecoration(labelText: 'Personagem favorito'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: specialties,
                  decoration: const InputDecoration(
                    labelText: 'Especialidades',
                    helperText: 'Separe as especialidades por vírgulas.',
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Cancelar'),
                      ),
                    ),
                    const SizedBox(width: 9),
                    Expanded(
                      child: FilledButton(
                        onPressed: () => Navigator.pop(context, true),
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.ember,
                          foregroundColor: AppColors.slate950,
                        ),
                        child: const Text('Salvar alterações'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
    if (saved == true && mounted) {
      setState(() {
        _name = name.text.trim().isEmpty ? _name : name.text.trim();
        final user = username.text.trim();
        _username = user.startsWith('@') ? user : '@$user';
        _bio = bio.text.trim();
        _favoriteBook = book.text.trim().isEmpty ? 'Não informado' : book.text.trim();
        _favoriteCharacter =
            character.text.trim().isEmpty ? 'Não informado' : character.text.trim();
        _specialties = specialties.text
            .split(',')
            .map((item) => item.trim())
            .where((item) => item.isNotEmpty)
            .toList();
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Perfil atualizado com sucesso.')),
        );
      }
    }
    name.dispose();
    username.dispose();
    bio.dispose();
    book.dispose();
    character.dispose();
    specialties.dispose();
  }

  Future<void> _editChurch() async {
    final profile = _profile;
    final churchName = TextEditingController(text: profile?.churchName ?? '');
    final bio = TextEditingController(text: _churchBio);
    final city = TextEditingController(text: _churchCity);
    final members = TextEditingController(text: '${_friends == 0 ? 1 : _friends}');
    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.slate900,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.viewInsetsOf(context).bottom,
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 22, 24, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Cadastrar igreja',
                  style: TextStyle(
                    color: AppColors.slate100,
                    fontSize: 23,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.6,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Prepare a comunidade em poucos passos.',
                  style: TextStyle(color: AppColors.slate400, fontSize: 12),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: churchName,
                  decoration: const InputDecoration(labelText: 'Nome da igreja'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: bio,
                  maxLines: 4,
                  maxLength: 280,
                  decoration: const InputDecoration(
                    labelText: 'Bio da igreja',
                    helperText:
                        'Esta apresentação ficará visível no perfil da igreja · até 280 caracteres.',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: members,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Quantidade de membros'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: city,
                  decoration: const InputDecoration(labelText: 'Cidade'),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Cancelar'),
                      ),
                    ),
                    const SizedBox(width: 9),
                    Expanded(
                      child: FilledButton(
                        onPressed: () => Navigator.pop(context, true),
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.ember,
                          foregroundColor: AppColors.slate950,
                        ),
                        child: const Text('Continuar'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
    if (saved == true && mounted) {
      setState(() {
        _churchBio = bio.text.trim();
        _churchCity = city.text.trim();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Perfil da igreja atualizado com sucesso.')),
      );
    }
    churchName.dispose();
    bio.dispose();
    city.dispose();
    members.dispose();
  }
}

class _HeroStat extends StatelessWidget {
  const _HeroStat(this.value, this.label);

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 5),
        decoration: BoxDecoration(
          color: AppColors.slate950,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: const TextStyle(
                color: AppColors.ember,
                fontSize: 17,
                fontWeight: FontWeight.w800,
              ),
            ),
            Text(
              label.toUpperCase(),
              style: const TextStyle(
                color: AppColors.slate400,
                fontSize: 8,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
