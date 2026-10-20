
import 'dart:io';

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

    widget.onImageSelected(null);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    final imageUrl = widget.initialImageUrl?.trim() ?? '';
    final hasLocalImage = selectedImage != null;
    final hasRemoteImage = imageUrl.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.medMedicineImage,
          style: TextStyle(
            color: colors.onSurface,
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
              color: colors.surface,
              borderRadius: BorderRadius.circular(17),
              border: Border.all(color: colors.outline),
            ),
            child: Stack(
              children: [
                Positioned.fill(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: _buildImage(
                      hasLocalImage: hasLocalImage,
                      hasRemoteImage: hasRemoteImage,
                      imageUrl: imageUrl,
                      l10n: l10n,
                    ),
                  ),
                ),
                if (hasLocalImage)
                  Positioned(
                    top: 0,
                    right: 0,
                    child: Material(
                      color: colors.surface,
                      shape: const CircleBorder(),
                      child: IconButton(
                        onPressed: removeImage,
                        tooltip: MaterialLocalizations.of(context)
                            .deleteButtonTooltip,
                        icon: Icon(
                          Icons.delete_outline,
                          color: colors.error,
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
                        color: colors.surface.withValues(
                          alpha: theme.brightness == Brightness.dark
                              ? 0.95
                              : 0.9,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.edit_outlined,
                        color: colors.primary,
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

  Widget _buildImage({
    required bool hasLocalImage,
    required bool hasRemoteImage,
    required String imageUrl,
    required AppLocalizations l10n,
  }) {
    final colors = Theme.of(context).colorScheme;

    if (hasLocalImage) {
      return Image.file(
        selectedImage!,
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) => _buildImageError(),
      );
    }

    if (hasRemoteImage) {
      return Image.network(
        imageUrl,
        fit: BoxFit.contain,
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;

          return Center(
            child: CircularProgressIndicator(
              value: progress.expectedTotalBytes != null
                  ? progress.cumulativeBytesLoaded /
                      progress.expectedTotalBytes!
                  : null,
            ),
          );
        },
        errorBuilder: (_, __, ___) => _buildImageError(),
      );
    }

    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.add_photo_alternate_outlined,
            color: colors.primary,
            size: 28,
          ),
          const SizedBox(width: 10),
          Flexible(
            child: Text(
              l10n.medMedicineImage,
              style: TextStyle(
                color: colors.onSurfaceVariant,
                fontSize: 15,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageError() {
    final colors = Theme.of(context).colorScheme;

    return Center(
      child: Icon(
        Icons.broken_image_outlined,
        color: colors.primary,
        size: 36,
      ),
    );
  }
}
