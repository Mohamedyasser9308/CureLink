import '../../../add_medication/data/models/medication_model.dart';
import '../entities/caregiver_alert.dart';
import '../entities/caregiver_patient.dart';

abstract interface class CaregiverRepository {
  Stream<List<CaregiverPatient>> watchPatients(String caregiverUid);

  Future<List<CaregiverAlert>> getRecentAlerts(List<CaregiverPatient> patients);

  Stream<List<MedicationModel>> watchPatientMedications(String patientUid);
}
