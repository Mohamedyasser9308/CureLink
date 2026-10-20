
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

  // Cloudinary image information
  final String? imageUrl;
  final String? imagePublicId;

  // Medication status
  final bool isActive;

  // Creation date
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
    this.isActive = true,
  });

  /// Convert the model into a Firestore-compatible map.
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
      'isActive': isActive,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  /// Create a model from a Firestore document map.
  factory MedicationModel.fromMap(
    Map<String, dynamic> map,
    String documentId,
  ) {
    final now = DateTime.now();

    return MedicationModel(
      id: documentId,
      name: map['name'] as String? ?? '',
      dosage: map['dosage'] as String? ?? '',
      times: (map['times'] as List<dynamic>?)
              ?.whereType<String>()
              .toList() ??
          const [],
      frequency: map['frequency'] as String? ?? 'daily',
      weekdays: (map['weekdays'] as List<dynamic>?)
              ?.whereType<num>()
              .map((day) => day.toInt())
              .toList() ??
          const [],
      durationDays: (map['durationDays'] as num?)?.toInt(),
      startDate: _dateFromFirestore(map['startDate']) ?? now,
      description: map['description'] as String?,
      instructions: map['instructions'] as String?,
      imageUrl: map['imageUrl'] as String?,
      imagePublicId: map['imagePublicId'] as String?,
      isActive: map['isActive'] as bool? ?? true,
      createdAt: _dateFromFirestore(map['createdAt']) ?? now,
    );
  }

  /// Safely parse Firestore Timestamp or DateTime values.
  static DateTime? _dateFromFirestore(dynamic value) {
    if (value is Timestamp) {
      return value.toDate();
    }

    if (value is DateTime) {
      return value;
    }

    return null;
  }

  /// Create a copy while keeping unchanged fields.
  MedicationModel copyWith({
    String? id,
    String? name,
    String? dosage,
    List<String>? times,
    String? frequency,
    List<int>? weekdays,
    int? durationDays,
    bool clearDurationDays = false,
    DateTime? startDate,
    String? description,
    bool clearDescription = false,
    String? instructions,
    bool clearInstructions = false,
    String? imageUrl,
    bool clearImageUrl = false,
    String? imagePublicId,
    bool clearImagePublicId = false,
    bool? isActive,
    DateTime? createdAt,
  }) {
    return MedicationModel(
      id: id ?? this.id,
      name: name ?? this.name,
      dosage: dosage ?? this.dosage,
      times: times ?? this.times,
      frequency: frequency ?? this.frequency,
      weekdays: weekdays ?? this.weekdays,
      durationDays: clearDurationDays
          ? null
          : durationDays ?? this.durationDays,
      startDate: startDate ?? this.startDate,
      description: clearDescription
          ? null
          : description ?? this.description,
      instructions: clearInstructions
          ? null
          : instructions ?? this.instructions,
      imageUrl: clearImageUrl ? null : imageUrl ?? this.imageUrl,
      imagePublicId: clearImagePublicId
          ? null
          : imagePublicId ?? this.imagePublicId,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
