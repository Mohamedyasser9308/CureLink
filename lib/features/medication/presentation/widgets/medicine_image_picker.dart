
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

    // null means no new local image is selected.
    // The existing Cloudinary image remains saved unless
    // the Cubit explicitly supports removing it.
    widget.onImageSelected(null);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final hasLocalImage = selectedImage != null;
    final hasRemoteImage =
        widget.initialImageUrl != null &&
        widget.initialImageUrl!.trim().isNotEmpty;

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
            height: 170,
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.background,
              borderRadius: BorderRadius.circular(17),
              border: Border.all(color: AppTheme.primary),
            ),
            child: Stack(
              children: [
                Positioned.fill(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: hasLocalImage
                        ? Image.file(
                            selectedImage!,
                            fit: BoxFit.contain,
                          )
                        : hasRemoteImage
                            ? Image.network(
                                widget.initialImageUrl!,
                                fit: BoxFit.contain,
                                loadingBuilder:
                                    (context, child, progress) {
                                  if (progress == null) {
                                    return child;
                                  }

                                  return const Center(
                                    child: CircularProgressIndicator(),
                                  );
                                },
                                errorBuilder:
                                    (context, error, stackTrace) {
                                  return const Center(
                                    child: Icon(
                                      Icons.broken_image_outlined,
                                      color: AppTheme.primary,
                                      size: 36,
                                    ),
                                  );
                                },
                              )
                            : Center(
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.center,
                                  children: [
                                    const Icon(
                                      Icons.add_photo_alternate_outlined,
                                      color: AppTheme.primary,
                                      size: 28,
                                    ),
                                    const SizedBox(width: 10),
                                    Flexible(
                                      child: Text(
                                        l10n.enterDetails,
                                        style: const TextStyle(
                                          color: Color(0xff587494),
                                          fontSize: 15,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                  ),
                ),
                if (hasLocalImage)
                  Positioned(
                    top: 0,
                    right: 0,
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
                if (hasRemoteImage && !hasLocalImage)
                  Positioned(
                    bottom: 4,
                    right: 4,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.edit_outlined,
                        color: AppTheme.primary,
                        size: 20,
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
