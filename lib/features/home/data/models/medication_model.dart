import 'package:cloud_firestore/cloud_firestore.dart';

class MedicationModel {
  final String id;
  final String name;
  final String dosage;
  final String instructions;
  final bool isActive;
  final List<String> times;
  final DateTime startDate;
  final DateTime endDate;

  MedicationModel({
    required this.id,
    required this.name,
    required this.dosage,
    required this.instructions,
    required this.isActive,
    required this.times,
    required this.startDate,
    required this.endDate,
  });

  factory MedicationModel.fromMap(Map<String, dynamic> map, String documentId) {
    return MedicationModel(
      id: documentId,
      name: map['name'] ?? '',
      dosage: map['dosage'] ?? '',
      instructions: map['instructions'] ?? '',
      isActive: map['isActive'] ?? true,
      times: List<String>.from(map['times'] ?? []),
      startDate: (map['startDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      endDate: (map['endDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'dosage': dosage,
      'instructions': instructions,
      'isActive': isActive,
      'times': times,
      'startDate': Timestamp.fromDate(startDate),
      'endDate': Timestamp.fromDate(endDate),
    };
  }
}
