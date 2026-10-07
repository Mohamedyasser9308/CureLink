import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/router/routes_names.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_scaffold.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../l10n/app_localizations.dart';
import '../../data/services/profile_service.dart';
import '../cubit/profile_cubit.dart';
import '../cubit/profile_state.dart';

class CompleteProfilePage extends StatelessWidget {
  const CompleteProfilePage({
    super.key,
    required this.name,
    required this.role,
    required this.ageGroup,
  });

  final String name;
  final String role;
  final String ageGroup;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocProvider(
      create: (_) => ProfileCubit(
        profileService: ProfileService(),
      )..generateUserId(
          role: role,
          l10n: l10n,
        ),
      child: _CompleteProfileView(
        name: name,
        role: role,
        ageGroup: ageGroup,
      ),
    );
  }
}

class _CompleteProfileView extends StatefulWidget {
  const _CompleteProfileView({
    required this.name,
    required this.role,
    required this.ageGroup,
  });

  final String name;
  final String role;
  final String ageGroup;

  @override
  State<_CompleteProfileView> createState() => _CompleteProfileViewState();
}

class _CompleteProfileViewState extends State<_CompleteProfileView> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _emergencyNameController = TextEditingController();
  final _emergencyPhoneController = TextEditingController();

  final ImagePicker _picker = ImagePicker();

  File? _pickedImage;

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.name;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emergencyNameController.dispose();
    _emergencyPhoneController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final l10n = AppLocalizations.of(context)!;

    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library_outlined),
                title: Text(l10n.chooseFromGallery),
                subtitle: Text(l10n.selectPhotoFromDevice),
                onTap: () {
                  Navigator.pop(context, ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt_outlined),
                title: Text(l10n.useCamera),
                subtitle: Text(l10n.takeNewProfilePhoto),
                onTap: () {
                  Navigator.pop(context, ImageSource.camera);
                },
              ),
            ],
          ),
        );
      },
    );

    if (source == null) return;

    try {
      final image = await _picker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 900,
        maxHeight: 900,
      );

      if (image == null) return;

      setState(() {
        _pickedImage = File(image.path);
      });
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.unableToSelectImage),
        ),
      );
    }
  }

  Future<void> _saveProfile() async {
    FocusScope.of(context).unfocus();

    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    final l10n = AppLocalizations.of(context)!;
    final state = context.read<ProfileCubit>().state;

    if (state.userId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.pleaseWaitIdGenerated),
        ),
      );
      return;
    }

    context.read<ProfileCubit>().saveProfile(
          name: _nameController.text.trim(),
          role: widget.role,
          ageGroup: widget.ageGroup,
          emergencyName: _emergencyNameController.text.trim(),
          emergencyPhone: _emergencyPhoneController.text.trim(),
          image: _pickedImage,
          l10n: l10n,
        );
  }

  void _showSuccessDialog(String userId) {
    final l10n = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: Text(l10n.profileCompleted),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.check_circle_outline,
                size: 64,
                color: AppTheme.primary,
              ),
              const SizedBox(height: 16),
              Text(
                l10n.profileCreatedSuccessfully,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                l10n.yourCureLinkId,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              SelectableText(
                userId,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);

                Navigator.pushReplacementNamed(
                  context,
                  RoutesNames.homePage,
                );
              },
              child: Text(l10n.continueButton),
            ),
          ],
        );
      },
    );
  }

  Widget _sectionTitle(
    BuildContext context,
    String title,
  ) {
    final theme = Theme.of(context);

    return Text(
      title,
      style: theme.textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.w700,
        color: theme.brightness == Brightness.light
            ? AppTheme.navy
            : theme.colorScheme.onSurface,
      ),
    );
  }

  Widget _infoCard({
    required IconData icon,
    required String title,
    required String value,
  }) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outline.withAlpha(40),
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withAlpha(150),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _userIdCard(
    BuildContext context,
    ProfileState state,
  ) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    final hasId = state.userId.isNotEmpty;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withAlpha(12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.primary.withAlpha(50),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withAlpha(20),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.badge_outlined,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.cureLinkId,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withAlpha(150),
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  hasId ? state.userId : l10n.idNotAvailable,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    letterSpacing: hasId ? 1.2 : 0,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  l10n.generatedAfterSetup,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withAlpha(140),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _profileImage(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Center(
      child: Column(
        children: [
          GestureDetector(
            onTap: _pickImage,
            child: Container(
              width: 110,
              height: 110,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: theme.colorScheme.primary.withAlpha(15),
                border: Border.all(
                  color: theme.colorScheme.primary.withAlpha(50),
                  width: 2,
                ),
              ),
              child: ClipOval(
                child: _pickedImage != null
                    ? Image.file(
                        _pickedImage!,
                        fit: BoxFit.cover,
                      )
                    : Icon(
                        Icons.person_outline,
                        size: 48,
                        color: theme.colorScheme.primary,
                      ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            l10n.tapToAddPhoto,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    final titleColor = theme.brightness == Brightness.light
        ? AppTheme.navy
        : theme.colorScheme.onSurface;

    return AppScaffold(
      title: l10n.completeProfile,
      scrollable: true,
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
      body: BlocListener<ProfileCubit, ProfileState>(
        listener: (context, state) {
          if (state.status == ProfileStatus.failure &&
              state.errorMessage != null) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                SnackBar(
                  content: Text(state.errorMessage!),
                ),
              );
          }

          if (state.status == ProfileStatus.success) {
            _showSuccessDialog(state.userId);
          }
        },
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.enterDetails,
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: titleColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                l10n.completeProfileSubtitle,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withAlpha(160),
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 28),
              _profileImage(context),
              const SizedBox(height: 30),
              _sectionTitle(
                context,
                l10n.personalInformation,
              ),
              const SizedBox(height: 12),
              AppTextField(
                controller: _nameController,
                hint: l10n.enterFullName,
                textInputAction: TextInputAction.next,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return l10n.pleaseEnterName;
                  }

                  if (value.trim().length < 2) {
                    return l10n.nameMinLength;
                  }

                  return null;
                },
              ),
              const SizedBox(height: 14),
              _infoCard(
                icon: Icons.person_outline,
                title: l10n.selectedRole,
                value: widget.role,
              ),
              const SizedBox(height: 12),
              _infoCard(
                icon: Icons.cake_outlined,
                title: l10n.ageGroup,
                value: widget.ageGroup,
              ),
              const SizedBox(height: 14),
              BlocBuilder<ProfileCubit, ProfileState>(
                builder: (context, state) {
                  return _userIdCard(
                    context,
                    state,
                  );
                },
              ),
              const SizedBox(height: 28),
              _sectionTitle(
                context,
                l10n.emergencyContact,
              ),
              const SizedBox(height: 8),
              Text(
                l10n.emergencyContactHint,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withAlpha(150),
                ),
              ),
              const SizedBox(height: 12),
              AppTextField(
                controller: _emergencyNameController,
                hint: l10n.enterFullName,
                textInputAction: TextInputAction.next,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return l10n.pleaseEnterEmergencyContactName;
                  }

                  return null;
                },
              ),
              const SizedBox(height: 14),
              AppTextField(
                controller: _emergencyPhoneController,
                hint: l10n.enterPhoneNumber,
                keyboardType: TextInputType.phone,
                textInputAction: TextInputAction.done,
                validator: (value) {
                  final phone = value?.trim() ?? '';

                  if (phone.isEmpty) {
                    return l10n.pleaseEnterEmergencyPhone;
                  }

                  if (!RegExp(r'^\+?\d{10,15}$').hasMatch(phone)) {
                    return l10n.validPhoneNumber;
                  }

                  return null;
                },
              ),
              const SizedBox(height: 28),
              BlocBuilder<ProfileCubit, ProfileState>(
                builder: (context, state) {
                  return SizedBox(
                    width: double.infinity,
                    child: AppButton(
                      label: l10n.saveProfile,
                      isLoading: state.status == ProfileStatus.saving,
                      onPressed: state.status == ProfileStatus.saving
                          ? null
                          : _saveProfile,
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
              BlocBuilder<ProfileCubit, ProfileState>(
                builder: (context, state) {
                  if (state.status != ProfileStatus.generatingId) {
                    return const SizedBox.shrink();
                  }

                  return Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          l10n.pleaseWaitGeneratingId,
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}