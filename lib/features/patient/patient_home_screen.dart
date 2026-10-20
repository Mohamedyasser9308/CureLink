import 'package:curelink/core/router/app_navigation.dart';
import 'package:curelink/core/router/routes_names.dart';
import 'package:curelink/core/widgets/app_empty_state.dart';
import 'package:curelink/core/widgets/app_error.dart';
import 'package:curelink/core/widgets/app_loading.dart';
import 'package:curelink/core/widgets/app_scaffold.dart';
import 'package:curelink/core/widgets/mode_switcher.dart';
import 'package:curelink/features/medicine_details/presentation/medicine_details_page.dart';
import 'package:curelink/features/patient/data/services/medication_service.dart';
import 'package:curelink/features/patient/presentation/cubit/home_cubit.dart';
import 'package:curelink/features/patient/presentation/cubit/home_state.dart';
import 'package:curelink/features/patient/presentation/widgets/home_header.dart';
import 'package:curelink/features/patient/presentation/widgets/medication_card.dart';
import 'package:curelink/features/patient/presentation/widgets/next_dose_card.dart';
import 'package:curelink/features/patient/presentation/widgets/progress_card.dart';
import 'package:curelink/features/patient/presentation/widgets/sos_button.dart';
import 'package:curelink/l10n/app_localizations.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PatientHomeScreen extends StatelessWidget {
  const PatientHomeScreen({
    super.key,
    required this.mode,
    required this.showModeSwitcher,
    required this.onModeChanged,
  });

  final AppMode mode;
  final bool showModeSwitcher;
  final ValueChanged<AppMode> onModeChanged;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => HomeCubit(MedicationService())..start(),
      child: _PatientHomeView(
        mode: mode,
        showModeSwitcher: showModeSwitcher,
        onModeChanged: onModeChanged,
      ),
    );
  }
}

class _PatientHomeView extends StatelessWidget {
  const _PatientHomeView({
    required this.mode,
    required this.showModeSwitcher,
    required this.onModeChanged,
  });

  final AppMode mode;
  final bool showModeSwitcher;
  final ValueChanged<AppMode> onModeChanged;

  void _openAddMedicine(BuildContext context) {
    AppNavigator.push(context, RoutesNames.addMedicine);
  }

  void _openEmergency(BuildContext context) {
    AppNavigator.push(context, RoutesNames.emergency);
  }

  void _openMedicineDetails(BuildContext context, String medicationId) {
    final patientId = FirebaseAuth.instance.currentUser?.uid;

    if (patientId == null || patientId.trim().isEmpty) {
      final l10n = AppLocalizations.of(context)!;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.somethingWentWrong)));
      return;
    }

    Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => MedicineDetailsPage(
          patientId: patientId,
          medicationId: medicationId,
        ),
      ),
    ).then((deleted) {
      if (deleted == true && context.mounted) {
        context.read<HomeCubit>().refresh();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return AppScaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(l10n.patientMode),
      ),
      body: BlocBuilder<HomeCubit, HomeState>(
        builder: (context, state) {
          if (state is HomeSuccessState) {
            return _SuccessBody(
              state: state,
              onAdd: () => _openAddMedicine(context),
              onSos: () => _openEmergency(context),
              mode: mode,
              showModeSwitcher: showModeSwitcher,
              onModeChanged: onModeChanged,
              onMedicineTap: (medicationId) {
                _openMedicineDetails(context, medicationId);
              },
            );
          }

          if (state is HomeEmptyState) {
            return _EmptyBody(
              state: state,
              onAdd: () => _openAddMedicine(context),
              onSos: () => _openEmergency(context),
              mode: mode,
              showModeSwitcher: showModeSwitcher,
              onModeChanged: onModeChanged,
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

/// يظهر اختيار الوضع فقط لحساب Both، ويبلغ الـshell بالوضع المختار.
Widget _modeToggle(
  AppMode mode,
  bool showModeSwitcher,
  ValueChanged<AppMode> onModeChanged,
) {
  if (!showModeSwitcher) {
    return const SizedBox.shrink();
  }

  return Padding(
    padding: const EdgeInsets.only(bottom: 16),
    child: ModeSwitcher(mode: mode, onChanged: onModeChanged),
  );
}

class _SuccessBody extends StatelessWidget {
  const _SuccessBody({
    required this.state,
    required this.onAdd,
    required this.onSos,
    required this.onMedicineTap,
    required this.mode,
    required this.showModeSwitcher,
    required this.onModeChanged,
  });

  final HomeSuccessState state;
  final VoidCallback onAdd;
  final VoidCallback onSos;
  final ValueChanged<String> onMedicineTap;
  final AppMode mode;
  final bool showModeSwitcher;
  final ValueChanged<AppMode> onModeChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return ListView(
      children: [
        _modeToggle(mode, showModeSwitcher, onModeChanged),

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
              '${dose.medication.id}-'
              '${dose.time.toIso8601String()}',
            ),
            padding: const EdgeInsets.only(bottom: 12),
            child: MedicationCard(
              dose: dose,
              onTap: () {
                onMedicineTap(dose.medication.id);
              },
            ),
          ),

        const SizedBox(height: 8),

        // سيتم ربط عدد الجرعات المكتملة بسجل تناول الدواء لاحقًا.
        ProgressCard(done: state.takenCount, total: state.doses.length),

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
    required this.mode,
    required this.showModeSwitcher,
    required this.onModeChanged,
  });

  final HomeEmptyState state;
  final VoidCallback onAdd;
  final VoidCallback onSos;
  final AppMode mode;
  final bool showModeSwitcher;
  final ValueChanged<AppMode> onModeChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _modeToggle(mode, showModeSwitcher, onModeChanged),

          const Spacer(),

          AppEmptyState(
            icon: Icons.medication_outlined,
            title: l10n.emptyMedicationsTitle,
            message: l10n.emptyMedicationsMessage,
            actionLabel: l10n.addMedicine,
            onAction: onAdd,
          ),

          const Spacer(),

          SosButton(onPressed: onSos),

          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
