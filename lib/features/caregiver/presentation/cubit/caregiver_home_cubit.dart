import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/caregiver_patient.dart';
import '../../domain/repositories/caregiver_repository.dart';
import 'caregiver_home_state.dart';

class CaregiverHomeCubit extends Cubit<CaregiverHomeState> {
  CaregiverHomeCubit(this._repository) : super(const CaregiverHomeState());

  final CaregiverRepository _repository;

  StreamSubscription<List<CaregiverPatient>>? _patientsSubscription;
  int _alertsRequestId = 0;

  void start(String caregiverUid) {
    _patientsSubscription?.cancel();
    emit(state.copyWith(status: CaregiverHomeStatus.loading));
    _patientsSubscription = _repository
        .watchPatients(caregiverUid)
        .listen(
          _onPatientsChanged,
          onError: (_) {
            if (!isClosed) {
              emit(state.copyWith(status: CaregiverHomeStatus.failure));
            }
          },
        );
  }

  Future<void> _onPatientsChanged(List<CaregiverPatient> patients) async {
    final requestId = ++_alertsRequestId;
    emit(
      state.copyWith(
        status: CaregiverHomeStatus.loaded,
        patients: patients,
        alerts: const [],
      ),
    );
    try {
      final alerts = await _repository.getRecentAlerts(patients);
      if (isClosed || requestId != _alertsRequestId) return;
      emit(state.copyWith(alerts: alerts));
    } catch (_) {
      // Keep the patient list available when alerts cannot be loaded.
    }
  }

  @override
  Future<void> close() async {
    await _patientsSubscription?.cancel();
    return super.close();
  }
}
