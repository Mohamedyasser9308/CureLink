import '../../data/models/dose_item.dart';

abstract class HomeState {
  const HomeState();
}

class HomeInitialState extends HomeState {
  const HomeInitialState();
}

class HomeLoadingState extends HomeState {
  const HomeLoadingState();
}

class HomeSuccessState extends HomeState {
  const HomeSuccessState({
    required this.userName,
    required this.canSwitchMode,
    required this.doses,
    required this.nextDose,
  });

  final String userName;
  final bool canSwitchMode;

  /// Today's doses, sorted by time (one entry per scheduled time).
  final List<DoseItem> doses;

  /// Null when every dose for today has already passed.
  final DoseItem? nextDose;
}

class HomeEmptyState extends HomeState {
  const HomeEmptyState({required this.userName, required this.canSwitchMode});

  final String userName;
  final bool canSwitchMode;
}

enum HomeErrorType { network, unknown }

class HomeErrorState extends HomeState {
  const HomeErrorState({required this.type});

  final HomeErrorType type;
}
