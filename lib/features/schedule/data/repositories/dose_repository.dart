
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:curelink/features/schedule/data/models/dose_model.dart';

class DoseRepository {
  final FirebaseFirestore firestore;

  DoseRepository({FirebaseFirestore? firestore})
      : firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> dosesRef(
    String patientUid,
  ) {
    final uid = patientUid.trim();

    if (uid.isEmpty) {
      throw ArgumentError('Patient UID cannot be empty.');
    }

    return firestore
        .collection('users')
        .doc(uid)
        .collection('doses');
  }

  String createDoseId({
    required String medicationId,
    required DateTime scheduledAt,
  }) {
    final date = scheduledAt.toLocal();

    final year = date.year.toString().padLeft(4, '0');
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');

    // Keep the medication ID safe for use in a Firestore document ID.
    final safeMedicationId = medicationId.replaceAll('/', '_');

    return '${safeMedicationId}_${year}${month}${day}_'
        '${hour}${minute}';
  }

  /// Creates missing dose documents without overwriting existing records.
  ///
  /// Existing dose statuses, takenAt, and snoozedUntil are preserved.
  /// Batches are kept below Firestore's 500-write limit.
  Future<void> ensureDosesExist({
    required String patientUid,
    required List<DoseModel> doses,
  }) async {
    if (doses.isEmpty) return;

    final ref = dosesRef(patientUid);

    // Deduplicate the incoming list by document ID.
    final uniqueDoses = <String, DoseModel>{};

    for (final dose in doses) {
      uniqueDoses.putIfAbsent(dose.id, () => dose);
    }

    final doseList = uniqueDoses.values.toList();

    for (var start = 0; start < doseList.length; start += 400) {
      final chunk = doseList.skip(start).take(400).toList();

      final snapshots = await Future.wait(
        chunk.map((dose) => ref.doc(dose.id).get()),
      );

      final batch = firestore.batch();
      var writes = 0;

      for (var i = 0; i < chunk.length; i++) {
        // Never overwrite an existing dose's status or timestamps.
        if (snapshots[i].exists) continue;

        batch.set(
          ref.doc(chunk[i].id),
          chunk[i].toMap(),
        );
        writes++;
      }

      if (writes > 0) {
        await batch.commit();
      }
    }
  }

  /// Returns doses in the half-open interval [from, to).
  Future<List<DoseModel>> getDoses({
    required String patientUid,
    required DateTime from,
    required DateTime to,
  }) async {
    if (!from.isBefore(to)) {
      return [];
    }

    final snapshot = await dosesRef(patientUid)
        .where(
          'scheduledAt',
          isGreaterThanOrEqualTo: Timestamp.fromDate(from),
        )
        .where(
          'scheduledAt',
          isLessThan: Timestamp.fromDate(to),
        )
        .orderBy('scheduledAt')
        .get();

    return snapshot.docs
        .map((doc) => DoseModel.fromMap(doc.data(), doc.id))
        .toList();
  }

  /// Updates a dose document.
  ///
  /// The document must already exist. Errors are propagated to the caller.
  Future<void> updateDose({
    required String patientUid,
    required DoseModel dose,
  }) async {
    await dosesRef(patientUid)
        .doc(dose.id)
        .update(dose.toMap());
  }

  /// Synchronizes the medication details on existing future doses.
  ///
  /// Only upcoming, due, and snoozed doses are eligible.
  /// Taken and missed records are preserved as historical records.
  ///
  /// This method does not delete doses or change their scheduled times.
  Future<void> syncFutureDoseDetails({
    required String patientUid,
    required String medicationId,
    required String medicationName,
    required String dosage,
    required DateTime from,
  }) async {
    final snapshot = await dosesRef(patientUid)
        .where('medicationId', isEqualTo: medicationId)
        .where(
          'scheduledAt',
          isGreaterThanOrEqualTo: Timestamp.fromDate(from),
        )
        .orderBy('scheduledAt')
        .get();

    final eligibleStatuses = <String>{
      DoseStatus.upcoming.name,
      DoseStatus.due.name,
      DoseStatus.snoozed.name,
    };

    final batchLimit = 400;
    var batch = firestore.batch();
    var writes = 0;

    for (final doc in snapshot.docs) {
      final dose = DoseModel.fromMap(doc.data(), doc.id);

      if (!eligibleStatuses.contains(dose.status.name)) {
        continue;
      }

      if (dose.medicationName == medicationName &&
          dose.dosage == dosage) {
        continue;
      }

      final updated = dose.copyWith(
        updatedAt: DateTime.now(),
      );

      // Update only the medication details and updatedAt.
      // Do not replace the complete dose map, because that could
      // accidentally clear takenAt or snoozedUntil.
      batch.update(doc.reference, {
        'medicationName': medicationName,
        'dosage': dosage,
        'updatedAt': Timestamp.fromDate(updated.updatedAt),
      });

      writes++;

      if (writes >= batchLimit) {
        await batch.commit();
        batch = firestore.batch();
        writes = 0;
      }
    }

    if (writes > 0) {
      await batch.commit();
    }
  }
}
