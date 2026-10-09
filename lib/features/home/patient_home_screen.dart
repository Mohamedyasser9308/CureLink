import 'package:curelink/core/widgets/app_empty_state.dart';
import 'package:curelink/core/widgets/app_error.dart';
import 'package:curelink/core/widgets/app_loading.dart';
import 'package:curelink/core/widgets/app_scaffold.dart';
import 'package:curelink/core/widgets/mode_switcher.dart';
import 'package:curelink/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/router/app_navigation.dart';
import '../../core/router/routes_names.dart';
import 'data/services/medication_service.dart';
import 'presentation/cubit/home_cubit.dart';
import 'presentation/cubit/home_state.dart';
import 'presentation/widgets/home_header.dart';
import 'presentation/widgets/medication_card.dart';
import 'presentation/widgets/next_dose_card.dart';
import 'presentation/widgets/progress_card.dart';
import 'presentation/widgets/sos_button.dart';

class PatientHomeScreen extends StatelessWidget {
  const PatientHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => HomeCubit(MedicationService())..start(),
      child: const _PatientHomeView(),
    );
  }
}

class _PatientHomeView extends StatelessWidget {
  const _PatientHomeView();

  void _openAddMedicine(BuildContext context) =>
      AppNavigator.push(context, RoutesNames.addMedicine);

  void _openEmergency(BuildContext context) =>
      AppNavigator.push(context, RoutesNames.emergency);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return AppScaffold(
      appBar: AppBar(title: Text(l10n.appTitle)),
      body: BlocBuilder<HomeCubit, HomeState>(
        builder: (context, state) {
          if (state is HomeSuccessState) {
            return _SuccessBody(
              state: state,
              onAdd: () => _openAddMedicine(context),
              onSos: () => _openEmergency(context),
            );
          }
          if (state is HomeEmptyState) {
            return _EmptyBody(
              state: state,
              onAdd: () => _openAddMedicine(context),
              onSos: () => _openEmergency(context),
            );
          }
          if (state is HomeErrorState) {
            return AppError(
              title: l10n.somethingWentWrong,
              message: state.type == HomeErrorType.network
                  ? l10n.noInternetConnection
                  : null,
              retryLabel: l10n.retry,
              onRetry: () => context.read<HomeCubit>().start(),
            );
          }
          return const AppLoading();
        },
      ),
    );
  }
}

/// Mode toggle shown only for users whose role is "Both".
Widget _modeToggle(bool canSwitch) {
  if (!canSwitch) return const SizedBox.shrink();
  return Padding(
    padding: const EdgeInsets.only(bottom: 16),
    child: ModeSwitcher(
      mode: AppMode.patient,
      // TODO: navigate to the caregiver home once it exists.
      onChanged: (_) {},
    ),
  );
}

class _SuccessBody extends StatelessWidget {
  const _SuccessBody({
    required this.state,
    required this.onAdd,
    required this.onSos,
  });

  final HomeSuccessState state;
  final VoidCallback onAdd;
  final VoidCallback onSos;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return ListView(
      padding: const EdgeInsets.only(top: 16, bottom: 24),
      children: [
        _modeToggle(state.canSwitchMode),
        HomeHeader(userName: state.userName),
        const SizedBox(height: 20),
        NextDoseCard(
          dose: state.nextDose,
          onElapsed: () => context.read<HomeCubit>().refresh(),
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              child: Text(
                l10n.todaysMedications,
                style: theme.textTheme.titleMedium,
              ),
            ),
            TextButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add_rounded, size: 20),
              label: Text(l10n.addMedicine),
            ),
          ],
        ),
        const SizedBox(height: 4),
        for (final dose in state.doses)
          Padding(
            key: ValueKey(
              '${dose.medication.id}-${dose.time.toIso8601String()}',
            ),
            padding: const EdgeInsets.only(bottom: 12),
            child: MedicationCard(
              dose: dose,
              onTap: () => AppNavigator.push(
                context,
                RoutesNames.medicineDetails,
                arguments: dose.medication,
              ),
            ),
          ),
        const SizedBox(height: 8),
        // Placeholder: "done" stays 0 until dose logs are added.
        ProgressCard(done: 0, total: state.doses.length),
        const SizedBox(height: 12),
        SosButton(onPressed: onSos),
      ],
    );
  }
}

class _EmptyBody extends StatelessWidget {
  const _EmptyBody({
    required this.state,
    required this.onAdd,
    required this.onSos,
  });

  final HomeEmptyState state;
  final VoidCallback onAdd;
  final VoidCallback onSos;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Padding(
      padding: EdgeInsetsGeometry.only(top: 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          _modeToggle(state.canSwitchMode),
          Spacer(),
          AppEmptyState(
            icon: Icons.medication_outlined,
            title: l10n.emptyMedicationsTitle,
            message: l10n.emptyMedicationsMessage,
            actionLabel: l10n.addMedicine,
            onAction: onAdd,
          ),
          Spacer(),
          SosButton(onPressed: onSos),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
