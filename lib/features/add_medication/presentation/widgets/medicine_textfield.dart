
import 'package:curelink/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

class MedicineTextField extends StatelessWidget {
  final String label;
  final String? hintText;
  final int maxLines;
  final bool readOnly;
  final Widget? suffixIcon;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final ValueChanged<String>? onChanged;
  final FocusNode? focusNode;

  const MedicineTextField({
    super.key,
    required this.label,
    this.hintText,
    this.maxLines = 1,
    this.readOnly = false,
    this.suffixIcon,
    this.controller,
    this.validator,
    this.keyboardType,
    this.onChanged,
    this.focusNode,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: colors.onSurface,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          validator: validator,
          readOnly: readOnly,
          maxLines: maxLines,
          keyboardType: keyboardType,
          onChanged: onChanged,
          focusNode: focusNode,
          style: TextStyle(
            color: colors.onSurface,
            fontSize: 16,
          ),
          decoration: medicineDecoration(
            context,
            hintText: hintText,
            suffixIcon: suffixIcon,
          ),
        ),
      ],
    );
  }
}

InputDecoration medicineDecoration(
  BuildContext context, {
  String? hintText,
  Widget? suffixIcon,
}) {
  final l10n = AppLocalizations.of(context)!;
  final colors = Theme.of(context).colorScheme;

  return InputDecoration(
    hintText: hintText ?? l10n.enterDetails,
    hintStyle: TextStyle(
      color: colors.onSurfaceVariant,
      fontSize: 16,
    ),
    filled: true,
    fillColor: colors.surface,
    suffixIcon: suffixIcon,
    contentPadding: const EdgeInsets.symmetric(
      horizontal: 16,
      vertical: 22,
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(17),
      borderSide: BorderSide(color: colors.outline),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(17),
      borderSide: BorderSide(
        color: colors.tertiary,
        width: 2,
      ),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(17),
      borderSide: BorderSide(color: colors.error),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(17),
      borderSide: BorderSide(
        color: colors.error,
        width: 2,
      ),
    ),
    disabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(17),
      borderSide: BorderSide(color: colors.outlineVariant),
    ),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(17),
    ),
  );
}
