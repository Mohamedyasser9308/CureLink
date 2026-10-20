class CaregiverAlert {
  const CaregiverAlert({
    required this.patientName,
    required this.medicationName,
    required this.scheduledAt,
  });

  final String patientName;
  final String medicationName;
  final DateTime scheduledAt;
}
