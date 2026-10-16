
import 'package:cloud_firestore/cloud_firestore.dart';

enum DoseStatus {
  upcoming,
  due,
  taken,
  snoozed,
  missed,
}

class DoseModel {
  final String id;
  final String medicationId;
  final String medicationName;
  final String dosage;
  final DateTime scheduledAt;
  final DoseStatus status;
  final DateTime? takenAt;
  final DateTime? snoozedUntil;
  final DateTime createdAt;
  final DateTime updatedAt;

  const DoseModel({
    required this.id,
    required this.medicationId,
    required this.medicationName,
    required this.dosage,
    required this.scheduledAt,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.takenAt,
    this.snoozedUntil,
  });

  static DoseStatus statusFromString(String? value) {
    return DoseStatus.values.firstWhere(
      (status) => status.name == value,
      orElse: () => DoseStatus.upcoming,
    );
  }

  factory DoseModel.fromMap(
    Map<String, dynamic> map,
    String documentId,
  ) {
    DateTime readDate(dynamic value) {
      if (value is Timestamp) return value.toDate();
      if (value is DateTime) return value;
      return DateTime.now();
    }

    DateTime? readOptionalDate(dynamic value) {
      if (value is Timestamp) return value.toDate();
      if (value is DateTime) return value;
      return null;
    }

    return DoseModel(
      id: documentId,
      medicationId: map['medicationId'] as String? ?? '',
      medicationName: map['medicationName'] as String? ?? '',
      dosage: map['dosage'] as String? ?? '',
      scheduledAt: readDate(map['scheduledAt']),
      status: statusFromString(map['status'] as String?),
      takenAt: readOptionalDate(map['takenAt']),
      snoozedUntil: readOptionalDate(map['snoozedUntil']),
      createdAt: readDate(map['createdAt']),
      updatedAt: readDate(map['updatedAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'medicationId': medicationId,
      'medicationName': medicationName,
      'dosage': dosage,
      'scheduledAt': Timestamp.fromDate(scheduledAt),
      'status': status.name,
      'takenAt': takenAt == null
          ? null
          : Timestamp.fromDate(takenAt!),
      'snoozedUntil': snoozedUntil == null
          ? null
          : Timestamp.fromDate(snoozedUntil!),
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  DoseModel copyWith({
    DoseStatus? status,
    DateTime? takenAt,
    bool clearTakenAt = false,
    DateTime? snoozedUntil,
    bool clearSnoozedUntil = false,
    DateTime? updatedAt,
  }) {
    return DoseModel(
      id: id,
      medicationId: medicationId,
      medicationName: medicationName,
      dosage: dosage,
      scheduledAt: scheduledAt,
      status: status ?? this.status,
      takenAt: clearTakenAt ? null : takenAt ?? this.takenAt,
      snoozedUntil: clearSnoozedUntil
          ? null
          : snoozedUntil ?? this.snoozedUntil,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
