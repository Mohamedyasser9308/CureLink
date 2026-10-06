import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

/// "PERSONA FIRST" overline + big headline + description block.
class PersonaHeader extends StatelessWidget {
  const PersonaHeader({
    super.key,
    required this.overline,
    required this.headline,
    required this.description,
  });

  final String overline;
  final String headline;
  final String description;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final strong = isDark ? scheme.onSurface : AppTheme.navy;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          overline.toUpperCase(),
          style: theme.textTheme.labelSmall?.copyWith(
            color: AppTheme.cyan,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          headline,
          style: theme.textTheme.displayMedium?.copyWith(color: strong),
        ),
        const SizedBox(height: 4),
        Text(
          description,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: scheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}