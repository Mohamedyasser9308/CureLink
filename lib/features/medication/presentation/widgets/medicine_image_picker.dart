
import 'dart:io';

import 'package:curelink/core/theme/app_theme.dart';
import 'package:curelink/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class MedicineImagePicker extends StatefulWidget {
  final ValueChanged<File?> onImageSelected;

  const MedicineImagePicker({
    super.key,
    required this.onImageSelected,
  });

  @override
  State<MedicineImagePicker> createState() =>
      _MedicineImagePickerState();
}

class _MedicineImagePickerState extends State<MedicineImagePicker> {
  final ImagePicker picker = ImagePicker();

  File? selectedImage;

  Future<void> pickImage() async {
    try {
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
        maxWidth: 1200,
        maxHeight: 1200,
      );

      if (image == null || !mounted) return;

      final file = File(image.path);

      setState(() {
        selectedImage = file;
      });

      widget.onImageSelected(file);
    } catch (_) {
      if (!mounted) return;

      final l10n = AppLocalizations.of(context)!;

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(l10n.unableToSelectImage),
            behavior: SnackBarBehavior.floating,
          ),
        );
    }
  }

  void removeImage() {
    setState(() {
      selectedImage = null;
    });

    widget.onImageSelected(null);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.medMedicineImage,
          style: const TextStyle(
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
            height: 150,
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.background,
              borderRadius: BorderRadius.circular(17),
              border: Border.all(
                color: AppTheme.primary,
              ),
            ),
            child: selectedImage == null
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.add_photo_alternate_outlined,
                        color: AppTheme.primary,
                        size: 28,
                      ),
                      const SizedBox(width: 10),
                      Flexible(
                        child: Text(
                          l10n.medMedicineImage,
                          style: const TextStyle(
                            color: Color(0xff587494),
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ],
                  )
                : Stack(
                    children: [
                      Positioned.fill(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(
                            selectedImage!,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                      Positioned(
                        top: 4,
                        right: 4,
                        child: Material(
                          color: Colors.white,
                          shape: const CircleBorder(),
                          child: IconButton(
                            onPressed: removeImage,
                            tooltip: MaterialLocalizations.of(context)
                                .deleteButtonTooltip,
                            icon: const Icon(
                              Icons.delete_outline,
                              color: Colors.red,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ],
    );
  }
}
