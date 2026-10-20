import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/widgets/mode_switcher.dart';
import '../../../../l10n/app_localizations.dart';
import '../../data/repositories/firestore_caregiver_repository.dart';
import '../../domain/repositories/caregiver_repository.dart';
import '../cubit/caregiver_home_cubit.dart';
import '../cubit/caregiver_home_state.dart';
import '../widgets/caregiver_dashboard_content.dart';

class CaregiverHomeScreen extends StatelessWidget {
  const CaregiverHomeScreen({
    super.key,
    required this.patientUid,
    required this.role,
    required this.showModeSwitcher,
    required this.onModeChanged,
  });

  final String patientUid;
  final String role;
  final bool showModeSwitcher;
  final ValueChanged<AppMode> onModeChanged;

  @override
  Widget build(BuildContext context) {
    final repository = FirestoreCaregiverRepository();
    return BlocProvider(
      create: (_) => CaregiverHomeCubit(repository)..start(patientUid),
      child: _CaregiverHomeView(
        repository: repository,
        role: role,
        showModeSwitcher: showModeSwitcher,
        onModeChanged: onModeChanged,
      ),
    );
  }
}

class _CaregiverHomeView extends StatelessWidget {
  const _CaregiverHomeView({
    required this.repository,
    required this.role,
    required this.showModeSwitcher,
    required this.onModeChanged,
  });

  final CaregiverRepository repository;
  final String role;
  final bool showModeSwitcher;
  final ValueChanged<AppMode> onModeChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(l10n.caregiverMode),
      ),
      body: SafeArea(
        child: BlocBuilder<CaregiverHomeCubit, CaregiverHomeState>(
          builder: (context, state) => switch (state.status) {
            CaregiverHomeStatus.initial || CaregiverHomeStatus.loading =>
              const Center(child: CircularProgressIndicator()),
            CaregiverHomeStatus.failure => Center(
              child: Text(l10n.connectionLoadFailed),
            ),
            CaregiverHomeStatus.loaded => CaregiverDashboardContent(
              patients: state.patients,
              alerts: state.alerts,
              repository: repository,
              role: role,
              showModeSwitcher: showModeSwitcher,
              onModeChanged: onModeChanged,
            ),
          },
        ),
      ),
    );
  }
}
