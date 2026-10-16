
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import 'package:curelink/core/theme/app_theme.dart';
import 'package:curelink/features/medication/data/repositries/medication_repository.dart';
import 'package:curelink/features/schedule/data/models/dose_model.dart';
import 'package:curelink/features/schedule/data/repositories/dose_repository.dart';
import 'package:curelink/features/schedule/presentation/cubit/schedule_cubit.dart';
import 'package:curelink/features/schedule/presentation/cubit/schedule_state.dart';
import 'package:curelink/l10n/app_localizations.dart';

class SchedulePage extends StatelessWidget {
  const SchedulePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ScheduleCubit(
        medicationRepository: MedicationRepository(),
        doseRepository: DoseRepository(),
      )..load(),
      child: const _ScheduleView(),
    );
  }
}

class _ScheduleView extends StatefulWidget {
  const _ScheduleView();

  @override
  State<_ScheduleView> createState() => _ScheduleViewState();
}

class _ScheduleViewState extends State<_ScheduleView> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();

    _timer = Timer.periodic(
      const Duration(minutes: 1),
      (_) {
        if (mounted) {
          context.read<ScheduleCubit>().refreshDoseStatuses();
        }
      },
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isArabic =
        Localizations.localeOf(context).languageCode == 'ar';

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(l10n.scheduleTitle),
      ),
      body: SafeArea(
        child: BlocConsumer<ScheduleCubit, ScheduleState>(
          listenWhen: (previous, current) =>
              previous.error != current.error &&
              current.error != null,
          listener: (context, state) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.error!)),
            );
          },
          builder: (context, state) {
            if (state.isLoading && state.doses.isEmpty) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            if (state.error != null && state.doses.isEmpty) {
              return _ErrorView(
                message: l10n.scheduleLoadError,
                retryLabel: l10n.scheduleRetry,
                onRetry: () => context.read<ScheduleCubit>().load(),
              );
            }

            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      _ScheduleTab(
                        tab: ScheduleTab.yesterday,
                        selected: state.selectedTab,
                        label: l10n.scheduleYesterday,
                      ),
                      const SizedBox(width: 8),
                      _ScheduleTab(
                        tab: ScheduleTab.today,
                        selected: state.selectedTab,
                        label: l10n.scheduleToday,
                      ),
                      const SizedBox(width: 8),
                      _ScheduleTab(
                        tab: ScheduleTab.all,
                        selected: state.selectedTab,
                        label: l10n.scheduleAll,
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () => context.read<ScheduleCubit>().load(),
                    child: _DoseList(
                      doses: state.doses,
                      selectedTab: state.selectedTab,
                      isArabic: isArabic,
                      l10n: l10n,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _ScheduleTab extends StatelessWidget {
  const _ScheduleTab({
    required this.tab,
    required this.selected,
    required this.label,
  });

  final ScheduleTab tab;
  final ScheduleTab selected;
  final String label;

  @override
  Widget build(BuildContext context) {
    final isSelected = tab == selected;
    final theme = Theme.of(context);

    return Expanded(
      child: OutlinedButton(
        onPressed: () => context.read<ScheduleCubit>().selectTab(tab),
        style: OutlinedButton.styleFrom(
          backgroundColor:
              isSelected ? AppTheme.primary : theme.colorScheme.surface,
          foregroundColor:
              isSelected ? Colors.white : theme.colorScheme.onSurface,
          side: BorderSide(
            color: isSelected ? AppTheme.primary : theme.dividerColor,
          ),
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({
    required this.message,
    required this.retryLabel,
    required this.onRetry,
  });

  final String message;
  final String retryLabel;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: onRetry,
              child: Text(retryLabel),
            ),
          ],
        ),
      ),
    );
  }
}

class _DoseList extends StatelessWidget {
  const _DoseList({
    required this.doses,
    required this.selectedTab,
    required this.isArabic,
    required this.l10n,
  });

  final List<DoseModel> doses;
  final ScheduleTab selectedTab;
  final bool isArabic;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final today = DateUtils.dateOnly(DateTime.now());
    final yesterday = today.subtract(const Duration(days: 1));

    final filtered = doses.where((dose) {
      final day = DateUtils.dateOnly(dose.scheduledAt);

      return switch (selectedTab) {
        ScheduleTab.yesterday => day == yesterday,
        ScheduleTab.today => day == today,
        ScheduleTab.all => true,
      };
    }).toList()
      ..sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));

    if (filtered.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          const SizedBox(height: 100),
          Icon(
            Icons.event_available_outlined,
            size: 64,
            color: Theme.of(context).colorScheme.outline,
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              l10n.scheduleEmpty,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
        ],
      );
    }

    final groups = <DateTime, List<DoseModel>>{};

    for (final dose in filtered) {
      final day = DateUtils.dateOnly(dose.scheduledAt);
      groups.putIfAbsent(day, () => []).add(dose);
    }

    final days = groups.keys.toList()..sort();

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      children: [
        for (final day in days) ...[
          Padding(
            padding: const EdgeInsets.only(top: 12, bottom: 8),
            child: Text(
              DateFormat(
                'EEEE, d MMMM yyyy',
                isArabic ? 'ar' : 'en',
              ).format(day),
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
          for (final dose in groups[day]!)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _DoseCard(
                dose: dose,
                isArabic: isArabic,
                l10n: l10n,
              ),
            ),
        ],
      ],
    );
  }
}

class _DoseCard extends StatelessWidget {
  const _DoseCard({
    required this.dose,
    required this.isArabic,
    required this.l10n,
  });

  final DoseModel dose;
  final bool isArabic;
  final AppLocalizations l10n;

  String _statusLabel() => switch (dose.status) {
        DoseStatus.upcoming => l10n.scheduleUpcoming,
        DoseStatus.due => l10n.scheduleDue,
        DoseStatus.taken => l10n.scheduleTaken,
        DoseStatus.snoozed => l10n.scheduleSnoozed,
        DoseStatus.missed => l10n.scheduleMissed,
      };

  Color _statusColor(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;

    return switch (dose.status) {
      DoseStatus.upcoming =>
        dark ? Colors.blue.shade200 : Colors.blue.shade700,
      DoseStatus.due =>
        dark ? Colors.orange.shade300 : Colors.orange.shade800,
      DoseStatus.taken =>
        dark ? Colors.green.shade300 : Colors.green.shade700,
      DoseStatus.snoozed =>
        dark ? Colors.purple.shade200 : AppTheme.primary,
      DoseStatus.missed =>
        dark ? Colors.red.shade300 : Colors.red.shade700,
    };
  }

  String _formatTime(DateTime date) => DateFormat(
        'h:mm a',
        isArabic ? 'ar' : 'en',
      ).format(date);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = _statusColor(context);

    final canAct = {
      DoseStatus.upcoming,
      DoseStatus.due,
      DoseStatus.snoozed,
    }.contains(dose.status);

    return Card(
      elevation: 0,
      color: theme.colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: theme.dividerColor),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withValues(
                      alpha: theme.brightness == Brightness.dark ? 0.22 : 0.10,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.medication_outlined,
                    color: AppTheme.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        dose.medicationName,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(dose.dosage),
                      const SizedBox(height: 6),
                      Text(
                        _formatTime(dose.scheduledAt),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 9,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      _statusLabel(),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: color,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            if (canAct) ...[
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: FilledButton.icon(
                      onPressed: () {
                        context.read<ScheduleCubit>().markAsTaken(dose);
                      },
                      icon: const Icon(
                        Icons.check_circle_outline,
                        size: 18,
                      ),
                      label: Text(
                        l10n.scheduleMarkTaken,
                        textAlign: TextAlign.center,
                      ),
                      style: FilledButton.styleFrom(
                        backgroundColor: AppTheme.primary,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(0, 48),
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 2,
                    child: OutlinedButton(
                      onPressed: () {
                        context.read<ScheduleCubit>().snooze(dose);
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: theme.colorScheme.primary,
                        minimumSize: const Size(0, 48),
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                      ),
                      child: Text(
                        l10n.scheduleSnooze,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ],
              ),
            ],
            if (dose.status == DoseStatus.taken && dose.takenAt != null)
              _DoseNote(
                text: l10n.scheduleTakenAt(_formatTime(dose.takenAt!)),
              ),
            if (dose.status == DoseStatus.snoozed &&
                dose.snoozedUntil != null)
              _DoseNote(
                text: l10n.scheduleSnoozedUntil(
                  _formatTime(dose.snoozedUntil!),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _DoseNote extends StatelessWidget {
  const _DoseNote({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Text(
        text,
        style: Theme.of(context).textTheme.bodySmall,
      ),
    );
  }
}
