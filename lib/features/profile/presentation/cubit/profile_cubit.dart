
import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/user_id_generator.dart';
import '../../../../l10n/app_localizations.dart';
import '../../data/services/profile_service.dart';
import 'profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit({
    required ProfileService profileService,
  })  : _profileService = profileService,
        super(const ProfileState());

  final ProfileService _profileService;

  // =========================
  // Generate CureLink ID
  // =========================

  Future<void> generateUserId({
    required String role,
    required AppLocalizations l10n,
  }) async {
    emit(
      state.copyWith(
        status: ProfileStatus.generatingId,
        clearError: true,
      ),
    );

    try {
      final id = await UserIdGenerator.generate(
        role: role,
      );

      emit(
        state.copyWith(
          status: ProfileStatus.ready,
          userId: id,
          clearError: true,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: ProfileStatus.failure,
          errorMessage: _getGenerateIdErrorMessage(e, l10n),
        ),
      );
    }
  }

  // =========================
  // Save Profile
  // =========================

  Future<void> saveProfile({
    required String name,
    required String role,
    required String ageGroup,
    required String emergencyName,
    required String emergencyPhone,
    required AppLocalizations l10n,
    File? image,
  }) async {
    if (state.userId.isEmpty) {
      emit(
        state.copyWith(
          status: ProfileStatus.failure,
          errorMessage: l10n.pleaseWaitIdGenerated,
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        status: ProfileStatus.saving,
        clearError: true,
      ),
    );

    try {
      String? photoUrl;

      if (image != null) {
        photoUrl =
            await _profileService.uploadProfileImage(image);
      }

      await _profileService.saveProfile(
        name: name,
        role: role,
        ageGroup: ageGroup,
        uniqueId: state.userId,
        emergencyName: emergencyName,
        emergencyPhone: emergencyPhone,
        photoUrl: photoUrl,
      );

      emit(
        state.copyWith(
          status: ProfileStatus.success,
          clearError: true,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: ProfileStatus.failure,
          errorMessage: _getErrorMessage(e, l10n),
        ),
      );
    }
  }

  // =========================
  // Generate ID Error
  // =========================

  String _getGenerateIdErrorMessage(
    Object error,
    AppLocalizations l10n,
  ) {
    final message = error.toString();

    if (message.contains('permission-denied')) {
      return l10n.firebasePermissionDenied;
    }

    if (message.contains('unauthenticated')) {
      return l10n.noAuthenticatedUser;
    }

    if (message.contains('network')) {
      return l10n.networkError;
    }

    if (message.contains('Unable to generate')) {
      return l10n.unableToGenerateId;
    }

    return message;
  }

  // =========================
  // Save Profile Error
  // =========================

  String _getErrorMessage(
    Object error,
    AppLocalizations l10n,
  ) {
    final message = error.toString();

    if (message.contains('permission-denied')) {
      return l10n.profilePermissionDenied;
    }

    if (message.contains('unauthenticated')) {
      return l10n.sessionExpired;
    }

    if (message.contains('network')) {
      return l10n.networkError;
    }

    return message;
  }
}
