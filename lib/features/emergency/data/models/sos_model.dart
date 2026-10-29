import 'package:cloud_firestore/cloud_firestore.dart';

enum SosStatus { pending, sent, partiallySent, failed }

class SosModel {
  final String id;
  final String patientUid;
  final List<String> caregiverUids;
  final DateTime createdAt;
  final SosStatus status;

  const SosModel({
    required this.id,
    required this.patientUid,
    required this.caregiverUids,
    required this.createdAt,
    required this.status,
  });

  Map<String, dynamic> toMap() {
    return {
      'patientUid': patientUid,
      'caregiverUids': caregiverUids,
      'createdAt': Timestamp.fromDate(createdAt),
      'status': status.name,
    };
  }

  factory SosModel.fromMap(String id, Map<String, dynamic> data) {
    final patientUid = data['patientUid'];
    final caregivers = data['caregiverUids'];
    final timestamp = data['createdAt'];
    final statusValue = data['status'];

    if (id.trim().isEmpty) {
      throw const FormatException('SOS request ID is missing');
    }

    if (patientUid is! String || patientUid.trim().isEmpty) {
      throw const FormatException('Invalid SOS patient UID');
    }

    if (caregivers is! List) {
      throw const FormatException('Invalid SOS caregivers list');
    }

    if (caregivers.isEmpty ||
        caregivers.any((uid) => uid is! String || uid.trim().isEmpty)) {
      throw const FormatException(
        'SOS caregivers list contains invalid values',
      );
    }

    if (timestamp is! Timestamp) {
      throw const FormatException('Invalid SOS creation timestamp');
    }

    if (statusValue is! String) {
      throw const FormatException('Invalid SOS status');
    }

    final parsedStatus = switch (statusValue) {
      'pending' => SosStatus.pending,
      'sent' => SosStatus.sent,
      'partiallySent' => SosStatus.partiallySent,
      'failed' => SosStatus.failed,
      _ => throw FormatException('Unknown SOS status: $statusValue'),
    };

    final uniqueCaregivers = caregivers
        .cast<String>()
        .map((uid) => uid.trim())
        .toSet()
        .toList();

    return SosModel(
      id: id,
      patientUid: patientUid.trim(),
      caregiverUids: uniqueCaregivers,
      createdAt: timestamp.toDate(),
      status: parsedStatus,
    );
  }
}
