
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:curelink/features/schedule/data/repositories/dose_repository.dart';

import 'calendar_state.dart';

class CalendarCubit extends Cubit<CalendarState> {
  final DoseRepository doseRepository;
  final String patientUid;

  CalendarCubit({
    required this.doseRepository,
    required this.patientUid,
  }) : super(
          CalendarState(
            focusedDay: DateTime.now(),
            selectedDay: DateTime.now(),
          ),
        );

  Future<void> loadMonth(DateTime month) async {
    if (patientUid.trim().isEmpty) {
      emit(
        state.copyWith(
          status: CalendarStatus.failure,
          errorKey: 'patientUidMissing',
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        status: CalendarStatus.loading,
        focusedDay: month,
        clearError: true,
      ),
    );

    try {
      final from = DateTime(month.year, month.month, 1);
      final to = DateTime(month.year, month.month + 1, 1);

      final doses = await doseRepository.getDoses(
        patientUid: patientUid,
        from: from,
        to: to,
      );

      if (isClosed) return;

      emit(
        state.copyWith(
          status: CalendarStatus.success,
          focusedDay: month,
          doses: doses,
          clearError: true,
        ),
      );
    } catch (_) {
      if (isClosed) return;

      emit(
        state.copyWith(
          status: CalendarStatus.failure,
          errorKey: 'calendarLoadError',
        ),
      );
    }
  }

  void selectDay(DateTime selectedDay, DateTime focusedDay) {
    emit(
      state.copyWith(
        selectedDay: selectedDay,
        focusedDay: focusedDay,
      ),
    );
  }

  Future<void> refresh() => loadMonth(state.focusedDay);
}
