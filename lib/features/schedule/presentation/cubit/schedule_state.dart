
import 'package:curelink/features/schedule/data/models/dose_model.dart';

enum ScheduleTab {
  yesterday,
  today,
  all,
}

class ScheduleState {
  final bool isLoading;
  final String? error;
  final List<DoseModel> doses;
  final ScheduleTab selectedTab;

  const ScheduleState({
    this.isLoading = false,
    this.error,
    this.doses = const [],
    this.selectedTab = ScheduleTab.today,
  });

  ScheduleState copyWith({
    bool? isLoading,
    String? error,
    bool clearError = false,
    List<DoseModel>? doses,
    ScheduleTab? selectedTab,
  }) {
    return ScheduleState(
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : error ?? this.error,
      doses: doses ?? this.doses,
      selectedTab: selectedTab ?? this.selectedTab,
    );
  }
}
