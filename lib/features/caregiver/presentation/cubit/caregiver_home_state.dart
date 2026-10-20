import '../../domain/entities/caregiver_alert.dart';
import '../../domain/entities/caregiver_patient.dart';

enum CaregiverHomeStatus { initial, loading, loaded, failure }

class CaregiverHomeState {
  const CaregiverHomeState({
    this.status = CaregiverHomeStatus.initial,
    this.patients = const [],
    this.alerts = const [],
  });

  final CaregiverHomeStatus status;
  final List<CaregiverPatient> patients;
  final List<CaregiverAlert> alerts;

  CaregiverHomeState copyWith({
    CaregiverHomeStatus? status,
    List<CaregiverPatient>? patients,
    List<CaregiverAlert>? alerts,
  }) => CaregiverHomeState(
    status: status ?? this.status,
    patients: patients ?? this.patients,
    alerts: alerts ?? this.alerts,
  );
}
