
import 'package:curelink/features/schedule/data/models/dose_model.dart';

enum CalendarStatus {
  initial,
  loading,
  success,
  failure,
}

class CalendarState {
  final CalendarStatus status;
  final DateTime focusedDay;
  final DateTime selectedDay;
  final List<DoseModel> doses;
  final String? errorKey;

  const CalendarState({
    this.status = CalendarStatus.initial,
    required this.focusedDay,
    required this.selectedDay,
    this.doses = const [],
    this.errorKey,
  });

  List<DoseModel> get selectedDayDoses {
    final result = doses.where((dose) {
      return _sameDay(dose.scheduledAt, selectedDay);
    }).toList();

    result.sort(
      (a, b) => a.scheduledAt.compareTo(b.scheduledAt),
    );

    return result;
  }

  List<DoseModel> dosesForDay(DateTime day) {
    final result = doses.where((dose) {
      return _sameDay(dose.scheduledAt, day);
    }).toList();

    result.sort(
      (a, b) => a.scheduledAt.compareTo(b.scheduledAt),
    );

    return result;
  }

  static bool _sameDay(DateTime first, DateTime second) {
    return first.year == second.year &&
        first.month == second.month &&
        first.day == second.day;
  }

  CalendarState copyWith({
    CalendarStatus? status,
    DateTime? focusedDay,
    DateTime? selectedDay,
    List<DoseModel>? doses,
    String? errorKey,
    bool clearError = false,
  }) {
    return CalendarState(
      status: status ?? this.status,
      focusedDay: focusedDay ?? this.focusedDay,
      selectedDay: selectedDay ?? this.selectedDay,
      doses: doses ?? this.doses,
      errorKey: clearError ? null : errorKey ?? this.errorKey,
    );
  }
}
