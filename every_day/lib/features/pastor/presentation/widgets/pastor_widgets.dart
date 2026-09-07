import 'package:flutter/material.dart';

import '../theme/pastor_theme.dart';

class PastorScreen extends StatelessWidget {
  const PastorScreen({
    super.key,
    required this.children,
    this.padding = const EdgeInsets.fromLTRB(20, 24, 20, 32),
    this.controller,
  });

  final List<Widget> children;
  final EdgeInsets padding;
  final ScrollController? controller;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: PastorPalette.background,
      child: SafeArea(
        bottom: false,
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 430),
            child: ListView(
              controller: controller,
              padding: padding,
              children: children,
            ),
          ),
        ),
      ),
    );
  }
}

class PastorHeader extends StatelessWidget {
  const PastorHeader({
    super.key,
    required this.title,
    this.eyebrow,
    this.action,
    this.centered = false,
  });

  final String title;
  final String? eyebrow;
  final Widget? action;
  final bool centered;

  @override
  Widget build(BuildContext context) {
    final titleBlock = Column(
      crossAxisAlignment: centered
          ? CrossAxisAlignment.center
          : CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (eyebrow != null) ...[
          Text(eyebrow!, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 3),
        ],
        Text(title, style: Theme.of(context).textTheme.displaySmall),
      ],
    );

    return Row(
      children: [
        if (centered) const SizedBox(width: 48),
        Expanded(child: centered ? Center(child: titleBlock) : titleBlock),
        action ?? const SizedBox(width: 48),
      ],
    );
  }
}

class PastorCircleButton extends StatelessWidget {
  const PastorCircleButton({
    super.key,
    required this.icon,
    this.onTap,
    this.filled = false,
    this.semanticLabel,
  });

  final IconData icon;
  final VoidCallback? onTap;
  final bool filled;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final button = Material(
      color: filled ? PastorPalette.orange : PastorPalette.surfaceStrong,
      borderRadius: BorderRadius.circular(17),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(17),
        child: SizedBox(
          width: 48,
          height: 48,
          child: Icon(
            icon,
            size: 23,
            color: filled ? PastorPalette.onPrimary : PastorPalette.textMuted,
          ),
        ),
      ),
    );

    return Semantics(
      button: true,
      label: semanticLabel,
      child: semanticLabel == null
          ? button
          : Tooltip(message: semanticLabel!, child: button),
    );
  }
}

class PastorSurfaceCard extends StatelessWidget {
  const PastorSurfaceCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(18),
    this.borderColor,
    this.gradient,
    this.onTap,
    this.radius = 16,
  });

  final Widget child;
  final EdgeInsets padding;
  final Color? borderColor;
  final Gradient? gradient;
  final VoidCallback? onTap;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final decoration = BoxDecoration(
      color: gradient == null ? PastorPalette.surface : null,
      gradient:
          gradient ??
          const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [PastorPalette.surface, PastorPalette.surfaceSoft],
          ),
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: borderColor ?? PastorPalette.border),
    );

    final content = Container(
      width: double.infinity,
      padding: padding,
      decoration: decoration,
      child: child,
    );
    if (onTap == null) return content;
    return Semantics(
      button: true,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(radius),
          child: content,
        ),
      ),
    );
  }
}

class PastorIconTile extends StatelessWidget {
  const PastorIconTile({
    super.key,
    required this.icon,
    this.color = PastorPalette.orange,
    this.background,
    this.size = 44,
  });

  final IconData icon;
  final Color color;
  final Color? background;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: background ?? PastorPalette.orangeSoft,
        borderRadius: BorderRadius.circular(size * .3),
      ),
      child: Icon(icon, size: size * .48, color: color),
    );
  }
}

class PastorMetricCard extends StatelessWidget {
  const PastorMetricCard({
    super.key,
    required this.value,
    required this.label,
    required this.icon,
    this.accent = false,
    this.onTap,
  });

  final String value;
  final String label;
  final IconData icon;
  final bool accent;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return PastorSurfaceCard(
      onTap: onTap,
      padding: const EdgeInsets.all(17),
      borderColor: accent ? PastorPalette.orangeBorder : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PastorIconTile(icon: icon, size: 36),
          const Spacer(),
          Text(
            value,
            style: Theme.of(context).textTheme.displaySmall
                ?.copyWith(fontSize: 23, height: 1),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall
                ?.copyWith(fontSize: 11, height: 1.2),
          ),
        ],
      ),
    );
  }
}

class PastorStatTile extends StatelessWidget {
  const PastorStatTile({
    super.key,
    required this.value,
    required this.label,
    this.accent = false,
  });

  final String value;
  final String label;
  final bool accent;

  @override
  Widget build(BuildContext context) {
    return PastorSurfaceCard(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 18),
      borderColor: accent ? PastorPalette.orangeBorder : null,
      radius: 17,
      child: Column(
        children: [
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: accent ? PastorPalette.orange : PastorPalette.white,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

class PastorSectionTitle extends StatelessWidget {
  const PastorSectionTitle(this.title, {super.key, this.trailing});

  final String title;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(title, style: Theme.of(context).textTheme.titleLarge),
        ),
        ?trailing,
      ],
    );
  }
}

class PastorFilterBar extends StatelessWidget {
  const PastorFilterBar({
    super.key,
    required this.labels,
    required this.selectedIndex,
    required this.onSelected,
  });

  final List<String> labels;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      clipBehavior: Clip.none,
      child: Row(
        children: [
          for (var index = 0; index < labels.length; index++) ...[
            PastorChoiceChip(
              label: labels[index],
              selected: selectedIndex == index,
              onTap: () => onSelected(index),
            ),
            if (index != labels.length - 1) const SizedBox(width: 9),
          ],
        ],
      ),
    );
  }
}

class PastorChoiceChip extends StatelessWidget {
  const PastorChoiceChip({
    super.key,
    required this.label,
    required this.selected,
    this.onTap,
    this.icon,
  });

  final String label;
  final bool selected;
  final VoidCallback? onTap;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      child: Material(
        color: selected ? PastorPalette.orange : PastorPalette.surfaceStrong,
        borderRadius: BorderRadius.circular(999),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(999),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 40),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 17, vertical: 10),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[
                    Icon(
                      icon,
                      size: 16,
                      color: selected
                          ? PastorPalette.onPrimary
                          : PastorPalette.textMuted,
                    ),
                    const SizedBox(width: 6),
                  ],
                  Text(
                    label,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: selected
                          ? PastorPalette.onPrimary
                          : PastorPalette.textMuted,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class PastorStatusPill extends StatelessWidget {
  const PastorStatusPill({
    super.key,
    required this.label,
    this.tone = PastorStatusTone.orange,
    this.icon,
  });

  final String label;
  final PastorStatusTone tone;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final (background, foreground) = switch (tone) {
      PastorStatusTone.orange => (
        PastorPalette.orangeSoft,
        PastorPalette.orange,
      ),
      PastorStatusTone.green => (
        PastorPalette.successSurface,
        PastorPalette.success,
      ),
      PastorStatusTone.blue => (
        PastorPalette.orange,
        PastorPalette.secondaryButton,
      ),
      PastorStatusTone.neutral => (
        PastorPalette.secondaryButton,
        PastorPalette.textMuted,
      ),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 13, color: foreground),
            const SizedBox(width: 5),
          ],
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium
                ?.copyWith(color: foreground, fontSize: 11),
          ),
        ],
      ),
    );
  }
}

enum PastorStatusTone { orange, green, blue, neutral }

class PastorActionButton extends StatelessWidget {
  const PastorActionButton({
    super.key,
    required this.label,
    this.onPressed,
    this.primary = true,
    this.icon,
    this.expand = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool primary;
  final IconData? icon;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final style = FilledButton.styleFrom(
      backgroundColor: primary
          ? PastorPalette.orange
          : PastorPalette.secondaryButton,
      foregroundColor: primary
          ? PastorPalette.onPrimary
          : PastorPalette.white,
      disabledBackgroundColor: primary
          ? PastorPalette.orange
          : PastorPalette.secondaryButton,
      disabledForegroundColor: primary
          ? PastorPalette.onPrimary
          : PastorPalette.white,
      elevation: 0,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      textStyle: Theme.of(context).textTheme.labelLarge,
    );
    final button = SizedBox(
      height: 50,
      child: icon == null
          ? FilledButton(
              onPressed: onPressed,
              style: style,
              child: Text(label, textAlign: TextAlign.center),
            )
          : FilledButton.icon(
              onPressed: onPressed,
              icon: Icon(icon, size: 18),
              label: Text(label, textAlign: TextAlign.center),
              style: style,
            ),
    );
    return expand ? SizedBox(width: double.infinity, child: button) : button;
  }
}

class PastorAvatar extends StatelessWidget {
  const PastorAvatar({
    super.key,
    required this.initials,
    this.size = 48,
    this.color = PastorPalette.orangeSoft,
    this.highlight = false,
  });

  final String initials;
  final double size;
  final Color color;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    final darkContrast = _contrast(color, PastorPalette.white);
    final lightContrast = _contrast(color, PastorPalette.onPrimary);
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        border: Border.all(
          color: highlight ? PastorPalette.orange : PastorPalette.border,
          width: highlight ? 2 : 1,
        ),
      ),
      child: Text(
        initials,
        style: TextStyle(
          color: darkContrast >= lightContrast
              ? PastorPalette.white
              : PastorPalette.onPrimary,
          fontSize: size * .31,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  static double _contrast(Color first, Color second) {
    final firstLuminance = first.computeLuminance();
    final secondLuminance = second.computeLuminance();
    final lighter = firstLuminance > secondLuminance
        ? firstLuminance
        : secondLuminance;
    final darker = firstLuminance < secondLuminance
        ? firstLuminance
        : secondLuminance;
    return (lighter + .05) / (darker + .05);
  }
}

class PastorMemberListItem extends StatelessWidget {
  const PastorMemberListItem({
    super.key,
    required this.name,
    required this.subtitle,
    required this.initials,
    this.needsAttention = false,
    this.trailing,
    this.onTap,
  });

  final String name;
  final String subtitle;
  final String initials;
  final bool needsAttention;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return PastorSurfaceCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      borderColor: needsAttention ? PastorPalette.orangeBorder : null,
      radius: 17,
      child: Row(
        children: [
          PastorAvatar(initials: initials, size: 46, highlight: needsAttention),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: needsAttention
                        ? PastorPalette.orange
                        : PastorPalette.textMuted,
                  ),
                ),
              ],
            ),
          ),
          if (trailing != null) ...[const SizedBox(width: 10), trailing!],
        ],
      ),
    );
  }
}

class PastorProgressBar extends StatelessWidget {
  const PastorProgressBar({
    super.key,
    required this.value,
    this.height = 8,
    this.color = PastorPalette.orange,
  });

  final double value;
  final double height;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Progresso ${(value.clamp(0, 1) * 100).round()}%',
      child: ClipRRect(
        borderRadius: BorderRadius.circular(999),
        child: LinearProgressIndicator(
          minHeight: height,
          value: value.clamp(0, 1),
          color: color,
          backgroundColor: PastorPalette.secondaryButton,
        ),
      ),
    );
  }
}

class PastorFieldLabel extends StatelessWidget {
  const PastorFieldLabel(this.label, {super.key});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: Text(label, style: Theme.of(context).textTheme.labelMedium),
    );
  }
}

class PastorBottomNavigation extends StatelessWidget {
  const PastorBottomNavigation({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  static const _items = <(String, IconData)>[
    ('Início', Icons.home_rounded),
    ('Grupos', Icons.groups_rounded),
    ('Cuidado', Icons.volunteer_activism_rounded),
    ('Agenda', Icons.calendar_month_rounded),
    ('Perfil', Icons.person_rounded),
  ];

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: PastorPalette.background,
      child: SafeArea(
        top: false,
        child: Align(
          heightFactor: 1,
          alignment: Alignment.bottomCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 430),
            child: Container(
              height: 74,
              decoration: const BoxDecoration(
                color: PastorPalette.navigation,
                border: Border(top: BorderSide(color: PastorPalette.border)),
              ),
              child: Row(
                children: [
                  for (var index = 0; index < _items.length; index++)
                    Expanded(
                      child: _PastorNavItem(
                        label: _items[index].$1,
                        icon: _items[index].$2,
                        selected: currentIndex == index,
                        onTap: () => onTap(index),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PastorNavItem extends StatelessWidget {
  const _PastorNavItem({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? PastorPalette.orange : PastorPalette.textMuted;
    return Semantics(
      selected: selected,
      button: true,
      label: label,
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 23),
            const SizedBox(height: 5),
            Text(
              label,
              style: Theme.of(context).textTheme.labelMedium
                  ?.copyWith(color: color, fontSize: 10),
            ),
          ],
        ),
      ),
    );
  }
}
