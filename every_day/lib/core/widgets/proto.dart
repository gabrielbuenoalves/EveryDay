import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import 'app_avatar.dart';

class ProtoCard extends StatelessWidget {
  const ProtoCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(14),
    this.challenge = false,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final bool challenge;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      clipBehavior: Clip.hardEdge,
      padding: padding,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: challenge ? const Color(0x99FF5A16) : AppColors.slate700,
        ),
        gradient: challenge
            ? const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.slate800, Color(0x55D94308)],
              )
            : null,
        color: challenge ? null : AppColors.slate800,
      ),
      child: challenge
          ? Stack(
              children: [
                child,
                const Positioned(
                  right: -10,
                  bottom: -28,
                  child: IgnorePointer(
                    child: Text(
                      'ED',
                      style: TextStyle(
                        color: Color(0x1FFF5A16),
                        fontSize: 72,
                        fontWeight: FontWeight.w900,
                        height: 1,
                      ),
                    ),
                  ),
                ),
              ],
            )
          : child,
    );
  }
}

class ProtoSection extends StatelessWidget {
  const ProtoSection({super.key, required this.title, this.trailing});

  final String title;
  final String? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(1, 19, 1, 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                color: AppColors.slate100,
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: .15,
              ),
            ),
          ),
          if (trailing != null)
            Text(
              trailing!,
              style: const TextStyle(
                color: AppColors.ember,
                fontSize: 10,
                fontWeight: FontWeight.w800,
              ),
            ),
        ],
      ),
    );
  }
}

class MiniLabel extends StatelessWidget {
  const MiniLabel(this.text, {super.key, this.dark = false});

  final String text;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: TextStyle(
        color: dark ? const Color(0xD10F172A) : AppColors.slate400,
        fontSize: 8,
        fontWeight: FontWeight.w900,
        letterSpacing: 1.05,
      ),
    );
  }
}

class EmberProgress extends StatelessWidget {
  const EmberProgress({super.key, required this.value});

  final double value;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: LinearProgressIndicator(
        value: value.clamp(0, 1),
        minHeight: 6,
        backgroundColor: AppColors.slate700,
        color: AppColors.ember,
      ),
    );
  }
}

class EmberButton extends StatelessWidget {
  const EmberButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.expand = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final button = SizedBox(
      height: 40,
      child: FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.ember,
          foregroundColor: AppColors.slate950,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(11),
          ),
          textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900),
        ),
        child: Text(label),
      ),
    );
    return expand ? SizedBox(width: double.infinity, child: button) : button;
  }
}

class ProtoFilterBar extends StatelessWidget {
  const ProtoFilterBar({
    super.key,
    required this.labels,
    required this.selected,
    required this.onSelected,
    this.disabledIndices = const <int>{},
    this.disabledHint = 'Aguardando integração de dados',
  });

  final List<String> labels;
  final int selected;
  final ValueChanged<int> onSelected;
  final Set<int> disabledIndices;
  final String disabledHint;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(labels.length, (index) {
          final active = index == selected;
          final disabled = disabledIndices.contains(index);
          final filter = Material(
            color: active ? AppColors.ember : AppColors.slate850,
            borderRadius: BorderRadius.circular(9),
            child: InkWell(
              onTap: disabled ? null : () => onSelected(index),
              borderRadius: BorderRadius.circular(9),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(9),
                  border: Border.all(
                    color: active ? AppColors.ember : AppColors.slate700,
                  ),
                ),
                child: Text(
                  labels[index],
                  style: TextStyle(
                    color: active
                        ? AppColors.slate950
                        : disabled
                        ? AppColors.slate500
                        : AppColors.slate400,
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
          );
          return Padding(
            padding: EdgeInsets.only(right: index == labels.length - 1 ? 0 : 7),
            child: Semantics(
              enabled: !disabled,
              button: true,
              child: disabled
                  ? Tooltip(message: disabledHint, child: filter)
                  : filter,
            ),
          );
        }),
      ),
    );
  }
}

class ProtoEmptyState extends StatelessWidget {
  const ProtoEmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.copy,
  });

  final IconData icon;
  final String title;
  final String copy;

  @override
  Widget build(BuildContext context) {
    return ProtoCard(
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 25),
      child: Column(
        children: [
          Container(
            width: 42,
            height: 42,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: const Color(0x18FF5C16),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: AppColors.ember, size: 21),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.slate100,
              fontSize: 13,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            copy,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.slate400,
              fontSize: 11,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }
}

class WeekBars extends StatelessWidget {
  const WeekBars({super.key, required this.heights});

  final List<double> heights;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          for (var i = 0; i < heights.length; i++) ...[
            if (i > 0) const SizedBox(width: 6),
            Expanded(
              child: Container(
                height: (52 * heights[i].clamp(0.12, 1)).toDouble(),
                decoration: BoxDecoration(
                  color: i.isOdd ? AppColors.emberDark : AppColors.ember,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(4),
                    bottom: Radius.circular(2),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class GroupChip extends StatelessWidget {
  const GroupChip({super.key, required this.name, required this.memberCount});

  final String name;
  final int memberCount;

  @override
  Widget build(BuildContext context) {
    final icon = name.trim().isEmpty
        ? 'G'
        : name
              .trim()
              .split(RegExp(r'\s+'))
              .take(2)
              .map((part) => part[0].toUpperCase())
              .join();
    return Container(
      width: 104,
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        color: AppColors.slate800,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.slate700),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: const Color(0x33E3703A),
              borderRadius: BorderRadius.circular(9),
            ),
            child: Text(
              icon,
              style: const TextStyle(
                color: AppColors.ember,
                fontSize: 11,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.slate100,
              fontSize: 10,
              fontWeight: FontWeight.w800,
            ),
          ),
          Text(
            '$memberCount pessoas',
            style: const TextStyle(color: AppColors.slate400, fontSize: 9),
          ),
        ],
      ),
    );
  }
}

class SpecialtyChip extends StatelessWidget {
  const SpecialtyChip(this.label, {super.key, this.active = false});

  final String label;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.slate950,
        borderRadius: BorderRadius.circular(11),
        border: Border.all(
          color: active ? AppColors.ember : AppColors.slate700,
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: active ? AppColors.slate100 : AppColors.slate300,
          fontSize: 12,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class OrDivider extends StatelessWidget {
  const OrDivider({super.key, this.label = 'OU'});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 18),
      child: Row(
        children: [
          const Expanded(child: Divider(color: AppColors.slate700, height: 1)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Text(
              label,
              style: const TextStyle(
                color: AppColors.slate400,
                fontSize: 10,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const Expanded(child: Divider(color: AppColors.slate700, height: 1)),
        ],
      ),
    );
  }
}

class AppScreenHeader extends StatelessWidget {
  const AppScreenHeader({
    super.key,
    required this.kicker,
    required this.title,
    this.initials = 'ED',
    this.action,
  });

  final String kicker;
  final String title;
  final String initials;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(17, 10, 17, 7),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  kicker.toUpperCase(),
                  style: const TextStyle(
                    color: AppColors.slate400,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.4,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.slate100,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.6,
                  ),
                ),
              ],
            ),
          ),
          ?action,
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.slate700),
            ),
            child: AppAvatar(
              initials: initials,
              color: AppColors.slate800,
              foregroundColor: AppColors.slate100,
              size: 34,
            ),
          ),
        ],
      ),
    );
  }
}

String weekdayDateKicker([DateTime? now]) {
  const months = [
    'janeiro',
    'fevereiro',
    'março',
    'abril',
    'maio',
    'junho',
    'julho',
    'agosto',
    'setembro',
    'outubro',
    'novembro',
    'dezembro',
  ];
  const days = [
    'segunda',
    'terça',
    'quarta',
    'quinta',
    'sexta',
    'sábado',
    'domingo',
  ];
  final date = now ?? DateTime.now();
  return '${days[date.weekday - 1]}, ${date.day} de ${months[date.month - 1]}';
}

String participationLabel(double progress) {
  if (progress >= 0.85) return 'Alta participação';
  if (progress >= 0.55) return 'Acompanhamento regular';
  return 'Precisa de atenção';
}
