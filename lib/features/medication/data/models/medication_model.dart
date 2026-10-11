import 'package:cloud_firestore/cloud_firestore.dart';

class MedicationModel {
  final String id;
  final String name;
  final String dosage;
  final List<String> times;
  final String frequency;
  final List<int> weekdays;
  final int? durationDays;
  final DateTime startDate;
  final String? description;
  final String? instructions;
  final String? imageUrl;
  final String? imagePublicId;
  final DateTime createdAt;

  const MedicationModel({
    required this.id,
    required this.name,
    required this.dosage,
    required this.times,
    required this.frequency,
    required this.startDate,
    required this.createdAt,
    this.weekdays = const [],
    this.durationDays,
    this.description,
    this.instructions,
    this.imageUrl,
    this.imagePublicId,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'dosage': dosage,
      'times': times,
      'frequency': frequency,
      'weekdays': weekdays,
      'durationDays': durationDays,
      'startDate': Timestamp.fromDate(startDate),
      'description': description,
      'instructions': instructions,
      'imageUrl': imageUrl,
      'imagePublicId': imagePublicId,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory MedicationModel.fromMap(Map<String, dynamic> map, String id) {
    return MedicationModel(
      id: id,
      name: map['name'] as String,
      dosage: map['dosage'] as String,
      times: List<String>.from(map['times'] ?? []),
      frequency: map['frequency'] as String,
      weekdays: List<int>.from(map['weekdays'] ?? []),
      durationDays: (map['durationDays'] as num?)?.toInt(),
      startDate: (map['startDate'] as Timestamp).toDate(),
      description: map['description'] as String?,
      instructions: map['instructions'] as String?,
      imageUrl: map['imageUrl'] as String?,
      imagePublicId: map['imagePublicId'] as String?,
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }
}
