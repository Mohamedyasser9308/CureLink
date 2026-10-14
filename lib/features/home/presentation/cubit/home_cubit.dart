
import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:curelink/features/medication/data/models/medication_model.dart';

import '../../data/models/dose_item.dart';
import '../../data/models/user_profile.dart';
import '../../data/services/medication_service.dart';
import 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  HomeCubit(this._service) : super(const HomeInitialState());

  final MedicationService _service;

  StreamSubscription<UserProfile>? _userSub;
  StreamSubscription<List<MedicationModel>>? _medsSub;
  Timer? _ticker;

  UserProfile? _profile;
  List<MedicationModel>? _medications;

  /// Starts listening to Firestore.
  /// Call again to retry after an error.
  void start() {
    _cancelAll();

    _profile = null;
    _medications = null;

    emit(const HomeLoadingState());

    _userSub = _service.watchUserProfile().listen(
      (profile) {
        _profile = profile;
        refresh();
      },
      onError: _onError,
    );

    _medsSub = _service.watchMedications().listen(
      (medications) {
        _medications = medications;
        refresh();
      },
      onError: _onError,
    );

    // Refresh dose statuses and the next scheduled dose.
    _ticker = Timer.periodic(
      const Duration(seconds: 30),
      (_) => refresh(),
    );
  }

  /// Recomputes today's doses and next dose.
  void refresh() {
    if (isClosed) return;

    final profile = _profile;
    final medications = _medications;

    if (profile == null || medications == null) return;

    final now = DateTime.now();

    final doses = DoseItem.buildToday(
      medications,
      now,
    );

    if (doses.isEmpty) {
      emit(
        HomeEmptyState(
          userName: profile.firstName,
          canSwitchMode: profile.canSwitchMode,
        ),
      );
      return;
    }

    emit(
      HomeSuccessState(
        userName: profile.firstName,
        canSwitchMode: profile.canSwitchMode,
        doses: doses,
        nextDose: DoseItem.nextDose(doses, now),
      ),
    );
  }

  void _onError(Object error) {
    if (isClosed) return;

    _cancelAll();

    emit(
      HomeErrorState(
        type: _classify(error),
      ),
    );
  }

  HomeErrorType _classify(Object error) {
    if (error is FirebaseException) {
      const networkCodes = {
        'unavailable',
        'deadline-exceeded',
        'network-request-failed',
      };

      if (networkCodes.contains(error.code)) {
        return HomeErrorType.network;
      }
    }

    return HomeErrorType.unknown;
  }

  void _cancelAll() {
    _userSub?.cancel();
    _medsSub?.cancel();
    _ticker?.cancel();

    _userSub = null;
    _medsSub = null;
    _ticker = null;
  }

  @override
  Future<void> close() {
    _cancelAll();
    return super.close();
  }
}
