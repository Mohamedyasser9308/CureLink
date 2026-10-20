class CaregiverPatient {
  const CaregiverPatient({
    required this.uid,
    required this.uniqueId,
    required this.name,
    required this.takenCount,
    required this.missedCount,
    required this.pendingCount,
    required this.latestStatus,
  });

  final String uid;
  final String uniqueId;
  final String name;
  final int takenCount;
  final int missedCount;
  final int pendingCount;
  final String? latestStatus;
}
