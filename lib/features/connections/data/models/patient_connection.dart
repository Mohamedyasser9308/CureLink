class PatientConnection {
  const PatientConnection({
    required this.id,
    required this.patientUid,
    required this.patientUniqueId,
    required this.caregiverUid,
    required this.caregiverName,
    required this.status,
  });

  final String id;
  final String patientUid;
  final String patientUniqueId;
  final String caregiverUid;
  final String caregiverName;
  final String status;

  factory PatientConnection.fromMap(
    Map<String, dynamic> data,
    String documentId,
  ) {
    return PatientConnection(
      id: documentId,
      patientUid: data['patientUid'] as String? ?? '',
      patientUniqueId: data['patientUniqueId'] as String? ?? '',
      caregiverUid: data['caregiverUid'] as String? ?? '',
      caregiverName: data['caregiverName'] as String? ?? '',
      status: data['status'] as String? ?? 'pending',
    );
  }
}

class ConnectionException implements Exception {
  const ConnectionException(this.code);

  final String code;

  @override
  String toString() => code;
}
