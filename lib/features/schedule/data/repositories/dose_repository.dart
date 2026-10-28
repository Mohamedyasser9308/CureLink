import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:curelink/features/schedule/data/models/dose_model.dart';

import '../../../add_medication/data/models/medication_model.dart';

class DoseRepository {
  static const int scheduleHorizonDays = 91;
  static const Duration missedGracePeriod = Duration(minutes: 10);

  final FirebaseFirestore firestore;

  DoseRepository({FirebaseFirestore? firestore})
    : firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> dosesRef(String patientUid) {
    final uid = patientUid.trim();

    if (uid.isEmpty) {
      throw ArgumentError('Patient UID cannot be empty.');
    }

    return firestore.collection('users').doc(uid).collection('doses');
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

    return '${safeMedicationId}_$year$month${day}_$hour$minute';
  }

  Stream<List<DoseModel>> watchDoses({
    required String patientUid,
    required DateTime from,
    required DateTime to,
  }) {
    if (!from.isBefore(to)) return Stream.value(const []);

    return dosesRef(patientUid)
        .where('scheduledAt', isGreaterThanOrEqualTo: Timestamp.fromDate(from))
        .where('scheduledAt', isLessThan: Timestamp.fromDate(to))
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => DoseModel.fromMap(doc.data(), doc.id))
              .toList(),
        );
  }

  List<DoseModel> generateMedicationDoses({
    required MedicationModel medication,
    required DateTime from,
    required DateTime to,
    required DateTime now,
  }) {
    if (!medication.isActive || medication.times.isEmpty) return [];

    final frequency = _normalizeFrequency(medication.frequency);
    if (frequency == 'as needed') return [];

    final start = _dateOnly(medication.startDate);
    final duration = medication.durationDays;
    if (duration != null && duration <= 0) return [];

    final endExclusive = duration == null
        ? null
        : start.add(Duration(days: duration));
    var day = from.isAfter(start) ? from : start;
    if (endExclusive != null && !day.isBefore(endExclusive)) return [];

    final doses = <DoseModel>[];
    while (day.isBefore(to)) {
      if (endExclusive != null && !day.isBefore(endExclusive)) break;

      if (_isScheduledDay(
        medication: medication,
        frequency: frequency,
        day: day,
        start: start,
      )) {
        for (final time in medication.times) {
          final scheduledAt = _parseScheduledTime(day, time);
          if (scheduledAt == null) continue;

          doses.add(
            DoseModel(
              id: createDoseId(
                medicationId: medication.id,
                scheduledAt: scheduledAt,
              ),
              medicationId: medication.id,
              medicationName: medication.name,
              dosage: medication.dosage,
              imageUrl: medication.imageUrl,
              scheduledAt: scheduledAt,
              status: _statusForTime(scheduledAt, now),
              createdAt: now,
              updatedAt: now,
            ),
          );
        }
      }

      day = day.add(const Duration(days: 1));
    }

    return doses;
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

        batch.set(ref.doc(chunk[i].id), chunk[i].toMap());
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
        .where('scheduledAt', isGreaterThanOrEqualTo: Timestamp.fromDate(from))
        .where('scheduledAt', isLessThan: Timestamp.fromDate(to))
        .orderBy('scheduledAt')
        .get();

    return snapshot.docs
        .map((doc) => DoseModel.fromMap(doc.data(), doc.id))
        .toList();
  }

  /// Updates a dose document.
  ///
  /// The document must already exist. Errors are propagated to the caller.
  Future<DoseModel> updateDose({
    required String patientUid,
    required DoseModel dose,
  }) async {
    final ref = dosesRef(patientUid).doc(dose.id);
    return firestore.runTransaction<DoseModel>((transaction) async {
      final snapshot = await transaction.get(ref);
      final data = snapshot.data();
      if (data == null) {
        throw StateError('Dose ${dose.id} no longer exists.');
      }
      final current = DoseModel.fromMap(data, snapshot.id);
      final currentStatus = DoseModel.statusFromString(
        data['status'] as String?,
      );

      // A stale schedule refresh must never overwrite a user's confirmation
      // or a missed state written by the server.
      if ((currentStatus == DoseStatus.taken ||
              currentStatus == DoseStatus.missed) &&
          dose.status != currentStatus) {
        return current;
      }

      transaction.update(ref, dose.toMap());
      return dose;
    });
  }

  /// Removes only pending future doses when a medication is deleted.
  /// Taken and missed records remain available as adherence history.
  Future<List<String>> deletePendingDosesForMedication({
    required String patientUid,
    required String medicationId,
  }) async {
    final snapshot = await dosesRef(
      patientUid,
    ).where('medicationId', isEqualTo: medicationId).get();
    final deletable = snapshot.docs.where((doc) {
      final dose = DoseModel.fromMap(doc.data(), doc.id);
      return dose.status == DoseStatus.upcoming ||
          dose.status == DoseStatus.due ||
          dose.status == DoseStatus.snoozed;
    }).toList();

    for (var start = 0; start < deletable.length; start += 400) {
      final batch = firestore.batch();
      for (final doc in deletable.skip(start).take(400)) {
        batch.delete(doc.reference);
      }
      await batch.commit();
    }
    return deletable.map((doc) => doc.id).toList(growable: false);
  }

  /// Reconciles future dose records with the medication's current schedule.
  ///
  /// Matching doses keep their current status. Obsolete upcoming doses are
  /// removed, while taken and missed records remain as history. New schedule
  /// times are inserted using the same deterministic IDs as normal generation.
  Future<List<String>> reconcileMedicationDoses({
    required String patientUid,
    required Set<String> medicationIds,
    required List<DoseModel> scheduledDoses,
    required DateTime from,
    required DateTime to,
    required DateTime now,
  }) async {
    if (medicationIds.isEmpty) return const [];

    final ref = dosesRef(patientUid);
    final snapshot = await ref
        .where('scheduledAt', isGreaterThanOrEqualTo: Timestamp.fromDate(from))
        .where('scheduledAt', isLessThan: Timestamp.fromDate(to))
        .orderBy('scheduledAt')
        .get();

    final existingById = {
      for (final doc in snapshot.docs)
        if (medicationIds.contains(doc.data()['medicationId'])) doc.id: doc,
    };
    final desiredById = {
      for (final dose in scheduledDoses)
        if (medicationIds.contains(dose.medicationId)) dose.id: dose,
    };
    final writes = <void Function(WriteBatch)>[];
    final removedDoseIds = <String>[];

    for (final dose in desiredById.values) {
      final existingDoc = existingById.remove(dose.id);
      if (existingDoc == null) {
        writes.add((batch) => batch.set(ref.doc(dose.id), dose.toMap()));
        continue;
      }

      final existing = DoseModel.fromMap(existingDoc.data(), existingDoc.id);
      if (existing.status == DoseStatus.taken ||
          existing.status == DoseStatus.missed) {
        continue;
      }

      final updates = <String, dynamic>{};
      if (existing.medicationName != dose.medicationName) {
        updates['medicationName'] = dose.medicationName;
      }
      if (existing.dosage != dose.dosage) {
        updates['dosage'] = dose.dosage;
      }
      if (existing.imageUrl != dose.imageUrl) {
        updates['imageUrl'] = dose.imageUrl;
      }
      if (updates.isNotEmpty) {
        updates['updatedAt'] = Timestamp.fromDate(now);
        writes.add((batch) => batch.update(existingDoc.reference, updates));
      }
    }

    for (final doc in existingById.values) {
      final dose = DoseModel.fromMap(doc.data(), doc.id);
      final isFutureUpcoming =
          dose.status == DoseStatus.upcoming && dose.scheduledAt.isAfter(now);
      final isActiveSnooze =
          dose.status == DoseStatus.snoozed &&
          dose.snoozedUntil != null &&
          dose.snoozedUntil!.isAfter(now);
      if (isFutureUpcoming || isActiveSnooze) {
        removedDoseIds.add(doc.id);
        writes.add((batch) => batch.delete(doc.reference));
      }
    }

    const batchLimit = 400;
    for (var start = 0; start < writes.length; start += batchLimit) {
      final batch = firestore.batch();
      for (final write in writes.skip(start).take(batchLimit)) {
        write(batch);
      }
      await batch.commit();
    }
    return removedDoseIds;
  }

  String _normalizeFrequency(String value) => value
      .toLowerCase()
      .trim()
      .replaceAll('_', ' ')
      .replaceAll('-', ' ')
      .replaceAll(RegExp(r'\s+'), ' ');

  bool _isScheduledDay({
    required MedicationModel medication,
    required String frequency,
    required DateTime day,
    required DateTime start,
  }) {
    switch (frequency) {
      case 'specific days':
        return medication.weekdays.contains(day.weekday);
      case 'every other day':
        final daysSinceStart = _dateOnly(day).difference(start).inDays;
        return daysSinceStart >= 0 && daysSinceStart.isEven;
      case 'as needed':
        return false;
      case 'daily':
      default:
        return true;
    }
  }

  DateTime? _parseScheduledTime(DateTime day, String value) {
    final parts = value.trim().split(':');
    if (parts.length != 2) return null;

    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);
    if (hour == null ||
        minute == null ||
        hour < 0 ||
        hour > 23 ||
        minute < 0 ||
        minute > 59) {
      return null;
    }

    return DateTime(day.year, day.month, day.day, hour, minute);
  }

  DateTime _dateOnly(DateTime date) =>
      DateTime(date.year, date.month, date.day);

  DoseStatus _statusForTime(DateTime referenceTime, DateTime now) {
    if (now.isBefore(referenceTime)) return DoseStatus.upcoming;
    if (now.isBefore(referenceTime.add(missedGracePeriod))) {
      return DoseStatus.due;
    }
    return DoseStatus.missed;
  }
}
