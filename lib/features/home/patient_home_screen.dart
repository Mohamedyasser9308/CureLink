
import 'package:curelink/core/router/app_navigation.dart';
import 'package:curelink/core/router/routes_names.dart';
import 'package:curelink/core/widgets/app_empty_state.dart';
import 'package:curelink/core/widgets/app_error.dart';
import 'package:curelink/core/widgets/app_loading.dart';
import 'package:curelink/core/widgets/app_scaffold.dart';
import 'package:curelink/core/widgets/mode_switcher.dart';
import 'package:curelink/features/medicine_details/presentation/medicine_details_page.dart';
import 'package:curelink/features/home/data/services/medication_service.dart';
import 'package:curelink/features/home/presentation/cubit/home_cubit.dart';
import 'package:curelink/features/home/presentation/cubit/home_state.dart';
import 'package:curelink/features/home/presentation/widgets/home_header.dart';
import 'package:curelink/features/home/presentation/widgets/medication_card.dart';
import 'package:curelink/features/home/presentation/widgets/next_dose_card.dart';
import 'package:curelink/features/home/presentation/widgets/progress_card.dart';
import 'package:curelink/features/home/presentation/widgets/sos_button.dart';
import 'package:curelink/l10n/app_localizations.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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

  void _openAddMedicine(BuildContext context) {
    AppNavigator.push(context, RoutesNames.addMedicine);
  }

  void _openEmergency(BuildContext context) {
    AppNavigator.push(context, RoutesNames.emergency);
  }

  void _openMedicineDetails(
    BuildContext context,
    String medicationId,
  ) {
    final patientId = FirebaseAuth.instance.currentUser?.uid;

    if (patientId == null || patientId.trim().isEmpty) {
      final l10n = AppLocalizations.of(context)!;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.somethingWentWrong),
        ),
      );
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
        title: Text(l10n.appTitle),
      ),
      body: BlocBuilder<HomeCubit, HomeState>(
        builder: (context, state) {
          if (state is HomeSuccessState) {
            return _SuccessBody(
              state: state,
              onAdd: () => _openAddMedicine(context),
              onSos: () => _openEmergency(context),
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

/// يظهر اختيار الوضع فقط للمستخدم الذي دوره Both.
/// سيتم تفعيل التبديل عند إنشاء شاشة مقدم الرعاية.
Widget _modeToggle(bool canSwitch) {
  if (!canSwitch) {
    return const SizedBox.shrink();
  }

  return Padding(
    padding: const EdgeInsets.only(bottom: 16),
    child: ModeSwitcher(
      mode: AppMode.patient,
      onChanged: (_) {
        // TODO: إضافة التنقل إلى CaregiverHomeScreen لاحقًا.
      },
    ),
  );
}

class _SuccessBody extends StatelessWidget {
  const _SuccessBody({
    required this.state,
    required this.onAdd,
    required this.onSos,
    required this.onMedicineTap,
  });

  final HomeSuccessState state;
  final VoidCallback onAdd;
  final VoidCallback onSos;
  final ValueChanged<String> onMedicineTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return ListView(
      padding: const EdgeInsets.only(
        top: 16,
        bottom: 24,
      ),
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
              icon: const Icon(
                Icons.add_rounded,
                size: 20,
              ),
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
        ProgressCard(
          done: 0,
          total: state.doses.length,
        ),

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
      padding: const EdgeInsets.only(top: 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),

          _modeToggle(state.canSwitchMode),

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
