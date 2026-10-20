import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../add_medication/data/models/medication_model.dart';
import '../../../schedule/data/models/dose_model.dart' as schedule;
import '../../../schedule/data/repositories/dose_repository.dart';
import '../../data/models/dose_item.dart';
import '../../data/models/user_profile.dart';
import '../../data/services/medication_service.dart';
import 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  HomeCubit(this._service, {DoseRepository? doseRepository})
    : _doseRepository = doseRepository ?? DoseRepository(),
      super(const HomeInitialState());

  final MedicationService _service;
  final DoseRepository _doseRepository;

  StreamSubscription<UserProfile>? _userSub;
  StreamSubscription<List<MedicationModel>>? _medsSub;
  StreamSubscription<List<schedule.DoseModel>>? _dosesSub;
  Timer? _ticker;

  UserProfile? _profile;
  List<MedicationModel>? _medications;
  List<schedule.DoseModel> _todayDoseLogs = const [];
  DateTime? _watchedDoseDate;

  /// Starts listening to Firestore.
  /// Call again to retry after an error.
  void start() {
    _cancelAll();

    _profile = null;
    _medications = null;
    _todayDoseLogs = const [];
    _watchedDoseDate = null;

    emit(const HomeLoadingState());

    _userSub = _service.watchUserProfile().listen((profile) {
      _profile = profile;
      refresh();
    }, onError: _onError);

    _medsSub = _service.watchMedications().listen((medications) {
      _medications = medications;
      refresh();
    }, onError: _onError);

    _watchTodayDoses(DateTime.now());

    // Refresh dose statuses and the next scheduled dose.
    _ticker = Timer.periodic(const Duration(seconds: 30), (_) {
      final now = DateTime.now();
      if (!_isSameDay(_watchedDoseDate, now)) {
        _watchTodayDoses(now);
      }
      refresh();
    });
  }

  /// Recomputes today's doses and next dose.
  void refresh() {
    if (isClosed) return;

    final profile = _profile;
    final medications = _medications;

    if (profile == null || medications == null) return;

    final now = DateTime.now();

    final doses = DoseItem.buildToday(medications, now);

    final scheduledKeys = doses.map(_doseKey).toSet();
    final takenKeys = _todayDoseLogs
        .where((dose) => dose.status == schedule.DoseStatus.taken)
        .map((dose) => _doseKeyFor(dose.medicationId, dose.scheduledAt))
        .where(scheduledKeys.contains)
        .toSet();

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
        takenCount: takenKeys.length,
      ),
    );
  }

  void _watchTodayDoses(DateTime date) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null || uid.isEmpty) return;

    final from = DateTime(date.year, date.month, date.day);
    if (_isSameDay(_watchedDoseDate, from)) return;

    _dosesSub?.cancel();
    _watchedDoseDate = from;
    _todayDoseLogs = const [];
    _dosesSub = _doseRepository
        .watchDoses(
          patientUid: uid,
          from: from,
          to: from.add(const Duration(days: 1)),
        )
        .listen((doses) {
          _todayDoseLogs = doses;
          refresh();
        }, onError: _onError);
  }

  String _doseKey(DoseItem dose) => _doseKeyFor(dose.medication.id, dose.time);

  String _doseKeyFor(String medicationId, DateTime scheduledAt) =>
      '$medicationId:${scheduledAt.toLocal().millisecondsSinceEpoch}';

  bool _isSameDay(DateTime? first, DateTime second) =>
      first != null &&
      first.year == second.year &&
      first.month == second.month &&
      first.day == second.day;

  void _onError(Object error) {
    if (isClosed) return;

    _cancelAll();

    emit(HomeErrorState(type: _classify(error)));
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
    _dosesSub?.cancel();
    _ticker?.cancel();

    _userSub = null;
    _medsSub = null;
    _dosesSub = null;
    _ticker = null;
  }

  @override
  Future<void> close() {
    _cancelAll();
    return super.close();
  }
}
