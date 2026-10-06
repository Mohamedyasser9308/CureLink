import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_scaffold.dart';


class ChoiceOption<T> {
  const ChoiceOption({
    required this.value,
    required this.icon,
    required this.title,
    this.subtitle,
  });

  final T value;
  final IconData icon;
  final String title;
  final String? subtitle;
}

/// "Pick one card, then Continue" screen shared by the role and age group steps.
class ChoiceScreen<T> extends StatefulWidget {
  const ChoiceScreen({
    super.key,
    required this.topTitle,
    required this.heading,
    required this.description,
    required this.options,
    required this.initialValue,
    required this.onContinue,
    this.eyebrow = 'PERSONA FIRST',
  });

  final String topTitle;
  final String eyebrow;
  final String heading;
  final String description;
  final List<ChoiceOption<T>> options;
  final T initialValue;
  final ValueChanged<T> onContinue;

  @override
  State<ChoiceScreen<T>> createState() => _ChoiceScreenState<T>();
}

class _ChoiceScreenState<T> extends State<ChoiceScreen<T>> {
  late T _selected = widget.initialValue;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colors = theme.colorScheme;

    // Navy in light mode; onSurface in dark mode so it stays readable.
    final headingColor =
        theme.brightness == Brightness.light ? AppTheme.navy : colors.onSurface;

    return AppScaffold(
      showAppBar: false,
      scrollable: true,
      body: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.topTitle,
                  style: textTheme.bodyLarge?.copyWith(color: headingColor),
                ),
                const SizedBox(height: 20),
                Text(
                  widget.eyebrow,
                  style: textTheme.labelSmall?.copyWith(
                    color: colors.tertiary,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.6,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  widget.heading,
                  style: textTheme.displaySmall?.copyWith(
                    color: headingColor,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  widget.description,
                  style: textTheme.bodyMedium?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 16),
                for (final option in widget.options) ...[
                  _ChoiceCard(
                    icon: option.icon,
                    title: option.title,
                    subtitle: option.subtitle,
                    selected: option.value == _selected,
                    headingColor: headingColor,
                    onTap: () => setState(() => _selected = option.value),
                  ),
                  const SizedBox(height: 12),
                ],
                const SizedBox(height: 4),
                AppButton(
                  label: 'Continue',
                  onPressed: () => widget.onContinue(_selected),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ChoiceCard extends StatelessWidget {
  const _ChoiceCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.headingColor,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final bool selected;
  final Color headingColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colors = theme.colorScheme;

    final backgroundColor = selected
        ? colors.primary.withValues(alpha: 0.12)
        : (theme.cardTheme.color ?? colors.surface);
    final borderRadius = BorderRadius.circular(AppTheme.radiusLarge);

    return Semantics(
      button: true,
      selected: selected,
      label: subtitle == null ? title : '$title. $subtitle',
      child: Material(
        color: backgroundColor,
        borderRadius: borderRadius,
        child: InkWell(
          borderRadius: borderRadius,
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Icon(icon, color: colors.primary, size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: textTheme.bodyMedium?.copyWith(
                          color: headingColor,
                        ),
                      ),
                      if (subtitle != null)
                        Text(
                          subtitle!,
                          style: textTheme.bodySmall?.copyWith(
                            color: colors.onSurfaceVariant,
                            fontSize: 11,
                          ),
                        ),
                    ],
                  ),
                ),
                if (selected)
                  Icon(Icons.check_circle_outline,
                      color: colors.primary, size: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}