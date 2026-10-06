import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

enum AppButtonType { primary, outlined, text, destructive }

class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.type = AppButtonType.primary,
    this.icon,
    this.isLoading = false,
    this.isExpanded = true,
  });

  const AppButton.outlined({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.isLoading = false,
    this.isExpanded = true,
  }) : type = AppButtonType.outlined;

  const AppButton.text({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.isLoading = false,
    this.isExpanded = false,
  }) : type = AppButtonType.text;

  const AppButton.destructive({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.isLoading = false,
    this.isExpanded = true,
  }) : type = AppButtonType.destructive;

  final String label;
  final VoidCallback? onPressed;
  final AppButtonType type;
  final IconData? icon;
  final bool isLoading;
  final bool isExpanded;

  bool get _enabled => onPressed != null && !isLoading;

  @override
  Widget build(BuildContext context) {
    final filled =
        type == AppButtonType.primary || type == AppButtonType.destructive;

    final child = isLoading
        ? SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: filled ? Colors.white : null,
            ),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 20),
                const SizedBox(width: 8),
              ],
              Flexible(child: Text(label, overflow: TextOverflow.ellipsis)),
            ],
          );

    final size = Size(isExpanded ? double.infinity : 0, AppTheme.buttonHeight);

    switch (type) {
      case AppButtonType.primary:
        return ElevatedButton(
          onPressed: _enabled ? onPressed : null,
          style: ElevatedButton.styleFrom(
            minimumSize: size,
            disabledBackgroundColor: AppTheme.primary,
            disabledForegroundColor: AppTheme.darkTextPrimary,
          ),
          child: child,
        );
      case AppButtonType.destructive:
        return ElevatedButton(
          onPressed: _enabled ? onPressed : null,
          style: ElevatedButton.styleFrom(
            minimumSize: size,
            backgroundColor: AppTheme.destructive,
            foregroundColor: Colors.white,
            disabledBackgroundColor: AppTheme.disabled,
            disabledForegroundColor: AppTheme.lightTextSecondary,
          ),
          child: child,
        );
      case AppButtonType.outlined:
        return OutlinedButton(
          onPressed: _enabled ? onPressed : null,
          style: OutlinedButton.styleFrom(
            minimumSize: size,
            disabledForegroundColor: AppTheme.primary,
            side: _enabled
                ? null
                : const BorderSide(color: AppTheme.disabled, width: 1),
          ),
          child: child,
        );
      case AppButtonType.text:
        return TextButton(
          onPressed: _enabled ? onPressed : null,
          style: TextButton.styleFrom(
            minimumSize: Size(isExpanded ? double.infinity : 0, 44),
            disabledForegroundColor: AppTheme.lightTextSecondary,
          ),
          child: child,
        );
    }
  }
}
