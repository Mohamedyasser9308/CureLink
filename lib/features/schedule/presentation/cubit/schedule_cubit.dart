
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:curelink/features/medication/data/models/medication_model.dart';
import 'package:curelink/features/medication/data/repositries/medication_repository.dart';
import 'package:curelink/features/schedule/data/models/dose_model.dart';
import 'package:curelink/features/schedule/data/repositories/dose_repository.dart';
import 'package:curelink/features/schedule/presentation/cubit/schedule_state.dart';

class ScheduleCubit extends Cubit<ScheduleState> {
  final MedicationRepository medicationRepository;
  final DoseRepository doseRepository;

  String? _loadedPatientUid;

  ScheduleCubit({
    required this.medicationRepository,
    required this.doseRepository,
  }) : super(const ScheduleState());

  static const Duration missedGracePeriod = Duration(minutes: 20);
  static const Duration snoozeDuration = Duration(minutes: 10);
  static const int generationDays = 91;

  Future<void> load({String? patientUid}) async {
    if (isClosed || state.isLoading) return;

    final uid = (patientUid ??
            FirebaseAuth.instance.currentUser?.uid ??
            '')
        .trim();

    if (uid.isEmpty) {
      emit(
        state.copyWith(
          isLoading: false,
          error: 'Please log in first.',
        ),
      );
      return;
    }

    _loadedPatientUid = uid;

    emit(state.copyWith(isLoading: true, clearError: true));

    try {
      final now = DateTime.now();
      final today = _dateOnly(now);
      final yesterday = today.subtract(const Duration(days: 1));
      final rangeEnd = today.add(
        const Duration(days: generationDays),
      );

      final medications =
          await medicationRepository.getMedications(patientId: uid);

      final generatedDoses = <DoseModel>[];

      for (final medication in medications) {
        generatedDoses.addAll(
          _generateDoses(
            medication: medication,
            from: today,
            to: rangeEnd,
            now: now,
          ),
        );
      }

      await doseRepository.ensureDosesExist(
        patientUid: uid,
        doses: generatedDoses,
      );

      final savedDoses = await doseRepository.getDoses(
        patientUid: uid,
        from: yesterday,
        to: rangeEnd,
      );

      final refreshedDoses = savedDoses
          .map((dose) => _refreshDoseStatus(dose, now))
          .toList()
        ..sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));

      final changedDoses = <DoseModel>[];

      for (var i = 0; i < savedDoses.length; i++) {
        if (!_sameDoseState(savedDoses[i], refreshedDoses[i])) {
          changedDoses.add(refreshedDoses[i]);
        }
      }

      if (changedDoses.isNotEmpty) {
        await Future.wait(
          changedDoses.map(
            (dose) => doseRepository.updateDose(
              patientUid: uid,
              dose: dose,
            ),
          ),
        );
      }

      if (isClosed) return;

      emit(
        state.copyWith(
          isLoading: false,
          doses: refreshedDoses,
          clearError: true,
        ),
      );
    } catch (error, stackTrace) {
      // Keep the error details available during development.
      assert(() {
        print('ScheduleCubit.load error: $error');
        print(stackTrace);
        return true;
      }());

      if (isClosed) return;

      emit(
        state.copyWith(
          isLoading: false,
          error: 'Failed to load schedule. Please try again.',
        ),
      );
    }
  }

  List<DoseModel> _generateDoses({
    required MedicationModel medication,
    required DateTime from,
    required DateTime to,
    required DateTime now,
  }) {
    if (!medication.isActive || medication.times.isEmpty) {
      return [];
    }

    final frequency = _normalizeFrequency(medication.frequency);

    // As-needed medications must not create automatic scheduled doses.
    if (frequency == 'as needed') return [];

    final start = _dateOnly(medication.startDate);
    final duration = medication.durationDays;

    if (duration != null && duration <= 0) return [];

    // durationDays includes the first treatment day.
    final endExclusive = duration == null
        ? null
        : start.add(Duration(days: duration));

    var day = from.isAfter(start) ? from : start;

    if (endExclusive != null && !day.isBefore(endExclusive)) {
      return [];
    }

    final doses = <DoseModel>[];

    while (day.isBefore(to)) {
      if (endExclusive != null && !day.isBefore(endExclusive)) {
        break;
      }

      if (_isScheduledDay(
        medication: medication,
        frequency: frequency,
        day: day,
        start: start,
      )) {
        for (final time in medication.times) {
          final scheduledAt = _parseScheduledTime(day, time);

          if (scheduledAt == null) continue;

          final id = doseRepository.createDoseId(
            medicationId: medication.id,
            scheduledAt: scheduledAt,
          );

          doses.add(
            DoseModel(
              id: id,
              medicationId: medication.id,
              medicationName: medication.name,
              dosage: medication.dosage,
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

  bool _isScheduledDay({
    required MedicationModel medication,
    required String frequency,
    required DateTime day,
    required DateTime start,
  }) {
    switch (frequency) {
      case 'specific days':
        // DateTime.weekday: Monday = 1, Sunday = 7.
        return medication.weekdays.contains(day.weekday);

      case 'every other day':
        final daysSinceStart = _dateOnly(day)
            .difference(_dateOnly(start))
            .inDays;

        return daysSinceStart >= 0 && daysSinceStart.isEven;

      case 'as needed':
        return false;

      case 'daily':
      default:
        // Preserve the model's daily default for unrecognized values.
        return true;
    }
  }

  String _normalizeFrequency(String value) {
    return value
        .toLowerCase()
        .trim()
        .replaceAll('_', ' ')
        .replaceAll('-', ' ')
        .replaceAll(RegExp(r'\s+'), ' ');
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

    return DateTime(
      day.year,
      day.month,
      day.day,
      hour,
      minute,
    );
  }

  DateTime _dateOnly(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  DoseStatus _statusForTime(DateTime referenceTime, DateTime now) {
    if (now.isBefore(referenceTime)) {
      return DoseStatus.upcoming;
    }

    if (now.isBefore(referenceTime.add(missedGracePeriod))) {
      return DoseStatus.due;
    }

    return DoseStatus.missed;
  }

  DoseModel _refreshDoseStatus(DoseModel dose, DateTime now) {
    // Taken and missed doses remain final.
    if (dose.status == DoseStatus.taken ||
        dose.status == DoseStatus.missed) {
      return dose;
    }

    // Keep the dose snoozed until its scheduled snooze time.
    if (dose.status == DoseStatus.snoozed &&
        dose.snoozedUntil != null) {
      if (now.isBefore(dose.snoozedUntil!)) {
        return dose;
      }

      // Once snoozing expires, the grace period starts from
      // snoozedUntil instead of the original scheduled time.
      final status = _statusForTime(dose.snoozedUntil!, now);

      return dose.copyWith(
        status: status,
        clearSnoozedUntil: true,
        updatedAt: now,
      );
    }

    final newStatus = _statusForTime(dose.scheduledAt, now);

    if (dose.status == newStatus && dose.snoozedUntil == null) {
      return dose;
    }

    return dose.copyWith(
      status: newStatus,
      clearSnoozedUntil: true,
      updatedAt: now,
    );
  }

  bool _sameDoseState(DoseModel first, DoseModel second) {
    return first.status == second.status &&
        first.takenAt == second.takenAt &&
        first.snoozedUntil == second.snoozedUntil;
  }

  Future<void> refreshDoseStatuses() async {
    if (isClosed || state.isLoading || state.doses.isEmpty) {
      return;
    }

    final uid = (_loadedPatientUid ??
            FirebaseAuth.instance.currentUser?.uid ??
            '')
        .trim();

    if (uid.isEmpty) return;

    final now = DateTime.now();

    final refreshedDoses = state.doses
        .map((dose) => _refreshDoseStatus(dose, now))
        .toList()
      ..sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));

    final changedDoses = <DoseModel>[];

    for (var i = 0; i < state.doses.length; i++) {
      if (!_sameDoseState(state.doses[i], refreshedDoses[i])) {
        changedDoses.add(refreshedDoses[i]);
      }
    }

    if (changedDoses.isEmpty) return;

    try {
      await Future.wait(
        changedDoses.map(
          (dose) => doseRepository.updateDose(
            patientUid: uid,
            dose: dose,
          ),
        ),
      );

      if (isClosed) return;

      emit(
        state.copyWith(
          doses: refreshedDoses,
          clearError: true,
        ),
      );
    } catch (error, stackTrace) {
      assert(() {
        print('ScheduleCubit.refreshDoseStatuses error: $error');
        print(stackTrace);
        return true;
      }());

      if (!isClosed) {
        emit(
          state.copyWith(
            error: 'Could not refresh dose statuses.',
          ),
        );
      }
    }
  }

  void selectTab(ScheduleTab tab) {
    if (isClosed || state.selectedTab == tab) return;

    emit(state.copyWith(selectedTab: tab));
  }

  Future<void> markAsTaken(DoseModel dose) async {
    if (dose.status == DoseStatus.taken ||
        dose.status == DoseStatus.missed) {
      return;
    }

    final currentDose = _findCurrentDose(dose);

    if (currentDose == null ||
        currentDose.status == DoseStatus.taken ||
        currentDose.status == DoseStatus.missed) {
      return;
    }

    final now = DateTime.now();

    await _updateDose(
      currentDose,
      currentDose.copyWith(
        status: DoseStatus.taken,
        takenAt: now,
        clearSnoozedUntil: true,
        updatedAt: now,
      ),
    );
  }

  Future<void> snooze(DoseModel dose) async {
    if (dose.status == DoseStatus.taken ||
        dose.status == DoseStatus.missed) {
      return;
    }

    final currentDose = _findCurrentDose(dose);

    if (currentDose == null ||
        currentDose.status == DoseStatus.taken ||
        currentDose.status == DoseStatus.missed) {
      return;
    }

    final now = DateTime.now();

    await _updateDose(
      currentDose,
      currentDose.copyWith(
        status: DoseStatus.snoozed,
        snoozedUntil: now.add(snoozeDuration),
        clearTakenAt: true,
        updatedAt: now,
      ),
    );
  }

  DoseModel? _findCurrentDose(DoseModel dose) {
    for (final current in state.doses) {
      if (current.id == dose.id) return current;
    }

    return null;
  }

  Future<void> _updateDose(
    DoseModel original,
    DoseModel updated,
  ) async {
    final uid = (_loadedPatientUid ??
            FirebaseAuth.instance.currentUser?.uid ??
            '')
        .trim();

    if (uid.isEmpty) {
      if (!isClosed) {
        emit(state.copyWith(error: 'Please log in first.'));
      }
      return;
    }

    try {
      await doseRepository.updateDose(
        patientUid: uid,
        dose: updated,
      );

      if (isClosed) return;

      final updatedDoses = state.doses.map((dose) {
        return dose.id == original.id ? updated : dose;
      }).toList()
        ..sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));

      emit(
        state.copyWith(
          doses: updatedDoses,
          clearError: true,
        ),
      );
    } catch (error, stackTrace) {
      assert(() {
        print('ScheduleCubit._updateDose error: $error');
        print(stackTrace);
        return true;
      }());

      if (!isClosed) {
        emit(
          state.copyWith(
            error: 'Could not update this dose. Please try again.',
          ),
        );
      }
    }
  }
}
