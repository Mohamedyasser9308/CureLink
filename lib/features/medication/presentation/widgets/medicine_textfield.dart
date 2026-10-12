import 'package:curelink/core/theme/app_theme.dart';
import 'package:curelink/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

class MedicineTextField extends StatelessWidget {
  final String label;
  final int maxLines;
  final bool readOnly;
  final Widget? suffixIcon;
  final TextEditingController? controller;
  final String? Function(String?)? validator;

  const MedicineTextField({
    super.key,
    required this.label,
    this.maxLines = 1,
    this.readOnly = false,
    this.suffixIcon,
    this.controller,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: AppTheme.navy,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 8),

        TextFormField(
          validator: validator,
          controller: controller,
          readOnly: readOnly,
          maxLines: maxLines,
          decoration: medicineDecoration(context, suffixIcon: suffixIcon),
        ),
      ],
    );
  }
}

InputDecoration medicineDecoration(BuildContext context, {Widget? suffixIcon}) {
  final l10n = AppLocalizations.of(context)!;

  return InputDecoration(
    hintText: l10n.enterDetails,

    hintStyle: const TextStyle(color: Color(0xff587494), fontSize: 16),

    filled: true,
    fillColor: AppTheme.background,
    suffixIcon: suffixIcon,

    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 22),

    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(17),
      borderSide: BorderSide(color: AppTheme.primary),
    ),

    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(17),
      borderSide: const BorderSide(color: Color(0xff09CDCD), width: 2),
    ),

    border: OutlineInputBorder(borderRadius: BorderRadius.circular(17)),
  );
}
