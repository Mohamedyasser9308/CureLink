
import 'package:firebase_auth/firebase_auth.dart';
import 'package:curelink/core/services/dose_notification_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:curelink/features/schedule/data/models/dose_model.dart';
import 'package:curelink/features/schedule/data/repositories/dose_repository.dart';
import 'package:curelink/features/schedule/presentation/cubit/schedule_state.dart';

import '../../../add_medication/data/repositries/medication_repository.dart';

class ScheduleCubit extends Cubit<ScheduleState> {
  final MedicationRepository medicationRepository;
  final DoseRepository doseRepository;

  String? _loadedPatientUid;
  bool _refreshingDoseStatuses = false;

  ScheduleCubit({
    required this.medicationRepository,
    required this.doseRepository,
  }) : super(const ScheduleState());

  static const Duration missedGracePeriod =
      DoseRepository.missedGracePeriod;

  static const Duration snoozeDuration = Duration(minutes: 10);

  static const int generationDays = DoseRepository.scheduleHorizonDays;

  Future<void> load({String? patientUid}) async {
    if (isClosed || state.isLoading) return;

    final uid =
        (patientUid ?? FirebaseAuth.instance.currentUser?.uid ?? '').trim();

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

      // Step 1: Load medications.
      final medications = await medicationRepository.getMedications(
        patientId: uid,
      );

      // Step 2: Generate the expected dose schedule.
      final generatedDoses = [
        for (final medication in medications)
          ...doseRepository.generateMedicationDoses(
            medication: medication,
            from: today,
            to: rangeEnd,
            now: now,
          ),
      ];

      // Keep the schedule visible even when Firestore is temporarily
      // unavailable or its reconciliation write is rejected by the network.
      try {
        final removedDoseIds = await doseRepository.reconcileMedicationDoses(
          patientUid: uid,
          medicationIds: medications.map((medication) => medication.id).toSet(),
          scheduledDoses: generatedDoses,
          from: today,
          to: rangeEnd,
          now: now,
        );
        for (final doseId in removedDoseIds) {
          await DoseNotificationService.instance.cancelDoseId(
            doseId,
            stopRinging: true,
          );
        }
      } catch (error, stackTrace) {
        debugPrint('Schedule reconciliation failed; showing generated doses: $error');
        debugPrintStack(stackTrace: stackTrace);
      }

      // Read saved statuses when possible. If the read fails, generated
      // medication times still provide a usable schedule for this session.
      List<DoseModel> savedDoses;
      try {
        savedDoses = await doseRepository.getDoses(
          patientUid: uid,
          from: yesterday,
          to: rangeEnd,
        );
        if (savedDoses.isEmpty) savedDoses = generatedDoses;
      } catch (error, stackTrace) {
        debugPrint('Could not read saved doses; showing generated doses: $error');
        debugPrintStack(stackTrace: stackTrace);
        savedDoses = generatedDoses;
      }

      // Step 5: Refresh dose statuses.
      final refreshedDoses = savedDoses
          .map((dose) => _refreshDoseStatus(dose, now))
          .toList()
        ..sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));

      // Compare by dose ID, not list index.
      final savedById = {
        for (final dose in savedDoses) dose.id: dose,
      };

      final changedDoses = <DoseModel>[];

      for (final refreshed in refreshedDoses) {
        final saved = savedById[refreshed.id];

        if (saved != null && !_sameDoseState(saved, refreshed)) {
          changedDoses.add(refreshed);
        }
      }

      // Step 6: Persist changed statuses.
      final persistedById = {
        for (final dose in refreshedDoses) dose.id: dose,
      };
      for (final dose in changedDoses) {
        try {
          persistedById[dose.id] = await doseRepository.updateDose(
            patientUid: uid,
            dose: dose,
          );
        } catch (error) {
          debugPrint('Could not persist refreshed dose ${dose.id}: $error');
        }
      }
      final persistedDoses = refreshedDoses
          .map((dose) => persistedById[dose.id] ?? dose)
          .toList();

      try {
        await DoseNotificationService.instance.sync(
          patientUid: uid,
          doses: persistedDoses,
        );
      } catch (error, stackTrace) {
        debugPrint('Could not sync local dose alarms: $error');
        debugPrintStack(stackTrace: stackTrace);
      }

      if (isClosed) return;

      emit(
        state.copyWith(
          isLoading: false,
          doses: persistedDoses,
          clearError: true,
        ),
      );
    } catch (error, stackTrace) {
      debugPrint('ScheduleCubit.load failed.');
      debugPrint('Error: $error');
      debugPrintStack(stackTrace: stackTrace);

      if (isClosed) return;

      emit(
        state.copyWith(
          isLoading: false,
          error: kDebugMode
              ? 'Failed to load schedule: $error'
              : 'Failed to load schedule. Please try again.',
        ),
      );
    }
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

    // Preserve an active snooze.
    if (dose.status == DoseStatus.snoozed &&
        dose.snoozedUntil != null) {
      if (now.isBefore(dose.snoozedUntil!)) {
        return dose;
      }

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
    if (_refreshingDoseStatuses ||
        isClosed ||
        state.isLoading ||
        state.doses.isEmpty) {
      return;
    }
    _refreshingDoseStatuses = true;

    try {
      final uid =
          (_loadedPatientUid ?? FirebaseAuth.instance.currentUser?.uid ?? '')
              .trim();

      if (uid.isEmpty) return;

      final now = DateTime.now();

      final refreshedDoses = state.doses
          .map((dose) => _refreshDoseStatus(dose, now))
          .toList()
        ..sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));

      final currentById = {
        for (final dose in state.doses) dose.id: dose,
      };

      final changedDoses = <DoseModel>[];

      for (final refreshed in refreshedDoses) {
        final current = currentById[refreshed.id];

        if (current != null && !_sameDoseState(current, refreshed)) {
          changedDoses.add(refreshed);
        }
      }

      if (changedDoses.isEmpty) return;

      try {
        final persistedById = {
          for (final dose in refreshedDoses) dose.id: dose,
        };
        for (final dose in changedDoses) {
          persistedById[dose.id] = await doseRepository.updateDose(
            patientUid: uid,
            dose: dose,
          );
        }
        final persistedDoses = refreshedDoses
            .map((dose) => persistedById[dose.id] ?? dose)
            .toList();

        if (isClosed) return;

        try {
          await DoseNotificationService.instance.sync(
            patientUid: uid,
            doses: persistedDoses,
          );
        } catch (error, stackTrace) {
          debugPrint('Could not refresh local dose alarms: $error');
          debugPrintStack(stackTrace: stackTrace);
        }

        emit(
          state.copyWith(
            doses: persistedDoses,
            clearError: true,
          ),
        );
      } catch (error, stackTrace) {
        debugPrint('ScheduleCubit.refreshDoseStatuses failed.');
        debugPrint('Error: $error');
        debugPrintStack(stackTrace: stackTrace);

        if (!isClosed) {
          emit(
            state.copyWith(
              error: kDebugMode
                  ? 'Could not refresh dose statuses: $error'
                  : 'Could not refresh dose statuses.',
            ),
          );
        }
      }
    } finally {
      _refreshingDoseStatuses = false;
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
    final uid =
        (_loadedPatientUid ?? FirebaseAuth.instance.currentUser?.uid ?? '')
            .trim();

    if (uid.isEmpty) {
      if (!isClosed) {
        emit(state.copyWith(error: 'Please log in first.'));
      }
      return;
    }

    try {
      final persistedDose = await doseRepository.updateDose(
        patientUid: uid,
        dose: updated,
      );
      if (persistedDose.status == DoseStatus.taken ||
          persistedDose.status == DoseStatus.missed) {
        await DoseNotificationService.instance.cancelDose(persistedDose);
      } else {
        await DoseNotificationService.instance.scheduleDose(
          patientUid: uid,
          dose: persistedDose,
        );
      }

      if (isClosed) return;

      final updatedDoses = state.doses.map((dose) {
        return dose.id == original.id ? persistedDose : dose;
      }).toList()
        ..sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));

      emit(
        state.copyWith(
          doses: updatedDoses,
          clearError: true,
        ),
      );
    } catch (error, stackTrace) {
      debugPrint('ScheduleCubit._updateDose failed.');
      debugPrint('Error: $error');
      debugPrintStack(stackTrace: stackTrace);

      if (!isClosed) {
        emit(
          state.copyWith(
            error: kDebugMode
                ? 'Could not update this dose: $error'
                : 'Could not update this dose. Please try again.',
          ),
        );
      }
    }
  }
}
