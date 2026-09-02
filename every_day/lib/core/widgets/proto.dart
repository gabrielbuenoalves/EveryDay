import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import 'app_avatar.dart';

class ProtoCard extends StatelessWidget {
  const ProtoCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
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
        borderRadius: BorderRadius.circular(20),
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
        color: challenge ? null : const Color(0xF0202026),
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
      padding: const EdgeInsets.fromLTRB(2, 22, 2, 10),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                color: AppColors.slate100,
                fontSize: 14,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.1,
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
        color: dark ? const Color(0xD10F172A) : AppColors.ember,
        fontSize: 9,
        fontWeight: FontWeight.w900,
        letterSpacing: 1.2,
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
        minHeight: 7,
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
      height: 42,
      child: FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.ember,
          foregroundColor: AppColors.slate950,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(13),
          ),
          textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900),
        ),
        child: Text(label),
      ),
    );
    return expand ? SizedBox(width: double.infinity, child: button) : button;
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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.slate950,
        borderRadius: BorderRadius.circular(11),
        boxShadow: active
            ? const [BoxShadow(color: AppColors.ember, spreadRadius: 2)]
            : null,
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
  });

  final String kicker;
  final String title;
  final String initials;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
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
                const SizedBox(height: 2),
                Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.slate100,
                    fontSize: 21,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.6,
                  ),
                ),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.ember, width: 2),
            ),
            child: AppAvatar(
              initials: initials,
              color: AppColors.slate800,
              foregroundColor: AppColors.slate100,
              size: 38,
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
