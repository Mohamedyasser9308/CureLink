import 'dart:io';

import 'package:curelink/core/theme/app_theme.dart';
import 'package:curelink/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
class MedicineImagePicker extends StatefulWidget {
  final ValueChanged<File?> onImageSelected;
  final String? initialImageUrl;

  const MedicineImagePicker({
    super.key,
    required this.onImageSelected,
    this.initialImageUrl,
  });
  
  @override
  State<MedicineImagePicker> createState() => _MedicineImagePickerState();
}

class _MedicineImagePickerState extends State<MedicineImagePicker> {
  final ImagePicker picker = ImagePicker();

  File? selectedImage;

  Future<void> pickImage() async {
    try {
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      if (image == null || !mounted) return;

      final file = File(image.path);

      setState(() {
        selectedImage = file;
      });

      widget.onImageSelected(file);
    } catch (e) {
      if (!mounted) return;

      final l10n = AppLocalizations.of(context)!;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.unableToSelectImage)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.medMedicineImage,
          style: TextStyle(
            color: AppTheme.navy,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 8),

        InkWell(
          onTap: pickImage,
          borderRadius: BorderRadius.circular(17),
          child: Container(
            height: 124,
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.background,
              borderRadius: BorderRadius.circular(17),
              border: Border.all(color: AppTheme.primary),
            ),
            child: selectedImage != null
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(selectedImage!, fit: BoxFit.contain),
                )
              : (widget.initialImageUrl != null &&
                      widget.initialImageUrl!.isNotEmpty)
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    widget.initialImageUrl!,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(
                        Icons.broken_image_outlined,
                        color: Color(0xff86449F),
                        size: 25,
                      );
                    },
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      l10n.enterDetails,
                      style: const TextStyle(
                        color: Color(0xff587494),
                        fontSize: 16,
                      ),
                    ),
                    const Icon(
                      Icons.add_photo_alternate_outlined,
                      color: Color(0xff86449F),
                      size: 25,
                    ),
                  ],
                ),
          ),
        ),
      ],
    );
  }
}
