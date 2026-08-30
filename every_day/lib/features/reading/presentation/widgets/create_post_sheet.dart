import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

Future<void> showCreatePostSheet(BuildContext context, {required bool pastor}) {
  return showModalBottomSheet<void>(
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
        child: _CreatePostForm(pastor: pastor),
      );
    },
  );
}

class _CreatePostForm extends StatefulWidget {
  const _CreatePostForm({required this.pastor});

  final bool pastor;

  @override
  State<_CreatePostForm> createState() => _CreatePostFormState();
}

class _CreatePostFormState extends State<_CreatePostForm> {
  final _text = TextEditingController();
  late String _type;
  late String _audience;

  List<String> get _types => widget.pastor
      ? const ['Recado', 'Postagem', 'Novo desafio']
      : const ['Comentário', 'Postagem'];

  List<String> get _audiences => widget.pastor
      ? const ['Igreja', 'Jovens', 'Casa Graça', 'Mulheres']
      : const ['Jovens', 'Casa Graça', 'Mulheres'];

  @override
  void initState() {
    super.initState();
    _type = _types.first;
    _audience = _audiences.first;
  }

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 22, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Criar publicação',
                        style: TextStyle(
                          color: AppColors.slate100,
                          fontSize: 23,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.6,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  style: IconButton.styleFrom(
                    backgroundColor: AppColors.slate800,
                    side: const BorderSide(color: AppColors.slate700),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Icon(Icons.close, color: AppColors.slate100),
                ),
              ],
            ),
            Text(
              widget.pastor
                  ? 'Publique um recado, post ou novo desafio.'
                  : 'Compartilhe algo com o seu grupo.',
              style: const TextStyle(color: AppColors.slate400, fontSize: 12),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _type,
              dropdownColor: AppColors.slate800,
              items: [
                for (final type in _types)
                  DropdownMenuItem(value: type, child: Text(type)),
              ],
              onChanged: (value) => setState(() => _type = value ?? _type),
              decoration: const InputDecoration(labelText: 'Tipo'),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _audience,
              dropdownColor: AppColors.slate800,
              items: [
                for (final audience in _audiences)
                  DropdownMenuItem(value: audience, child: Text(audience)),
              ],
              onChanged: (value) =>
                  setState(() => _audience = value ?? _audience),
              decoration: const InputDecoration(labelText: 'Destino'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _text,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Mensagem',
                hintText: 'Escreva sua mensagem...',
              ),
            ),
            const SizedBox(height: 19),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.slate100,
                      backgroundColor: AppColors.slate800,
                      side: const BorderSide(color: AppColors.slate700),
                      minimumSize: const Size.fromHeight(48),
                    ),
                    child: const Text('Cancelar'),
                  ),
                ),
                const SizedBox(width: 9),
                Expanded(
                  child: FilledButton(
                    onPressed: () {
                      if (_text.text.trim().isEmpty) return;
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Conteúdo publicado com sucesso.'),
                        ),
                      );
                    },
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.ember,
                      foregroundColor: AppColors.slate950,
                      minimumSize: const Size.fromHeight(48),
                    ),
                    child: const Text('Publicar'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
