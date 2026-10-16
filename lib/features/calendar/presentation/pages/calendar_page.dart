
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

import 'package:curelink/l10n/app_localizations.dart';
import 'package:curelink/features/schedule/data/models/dose_model.dart';
import 'package:curelink/features/schedule/data/repositories/dose_repository.dart';

import '../cubit/calendar_cubit.dart';
import '../cubit/calendar_state.dart';

class CalendarPage extends StatelessWidget {
  final String patientUid;

  const CalendarPage({
    super.key,
    required this.patientUid,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CalendarCubit(
        doseRepository: DoseRepository(),
        patientUid: patientUid,
      )..loadMonth(DateTime.now()),
      child: const _CalendarView(),
    );
  }
}

class _CalendarView extends StatelessWidget {
  const _CalendarView();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = Theme.of(context).colorScheme;
    final locale = l10n.localeName;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.calendarTitle),
        centerTitle: true,
      ),
      body: BlocBuilder<CalendarCubit, CalendarState>(
        builder: (context, state) {
          final cubit = context.read<CalendarCubit>();

          if (state.status == CalendarStatus.initial ||
              (state.status == CalendarStatus.loading &&
                  state.doses.isEmpty)) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (state.status == CalendarStatus.failure &&
              state.doses.isEmpty) {
            return _CalendarErrorView(
              message: _errorMessage(l10n, state.errorKey),
              onRetry: cubit.refresh,
            );
          }

          final selectedDoses = state.selectedDayDoses;

          return Column(
            children: [
              if (state.status == CalendarStatus.loading)
                const LinearProgressIndicator(),

              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    Card(
                      clipBehavior: Clip.antiAlias,
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: TableCalendar<DoseModel>(
                          locale: locale,
                          firstDay: DateTime(2020, 1, 1),
                          lastDay: DateTime(2035, 12, 31),
                          focusedDay: state.focusedDay,
                          selectedDayPredicate: (day) =>
                              isSameDay(state.selectedDay, day),
                          eventLoader: state.dosesForDay,
                          onDaySelected: (selectedDay, focusedDay) {
                            cubit.selectDay(
                              selectedDay,
                              focusedDay,
                            );

                            if (selectedDay.year !=
                                    state.focusedDay.year ||
                                selectedDay.month !=
                                    state.focusedDay.month) {
                              cubit.loadMonth(focusedDay);
                            }
                          },
                          onPageChanged: (focusedDay) {
                            cubit.selectDay(
                              DateTime(
                                focusedDay.year,
                                focusedDay.month,
                                1,
                              ),
                              focusedDay,
                            );

                            cubit.loadMonth(focusedDay);
                          },
                          calendarStyle: CalendarStyle(
                            todayDecoration: BoxDecoration(
                              color: colors.primary.withValues(alpha: 0.4),
                              shape: BoxShape.circle,
                            ),
                            selectedDecoration: BoxDecoration(
                              color: colors.primary,
                              shape: BoxShape.circle,
                            ),
                            markerDecoration: BoxDecoration(
                              color: colors.primary,
                              shape: BoxShape.circle,
                            ),
                            markersMaxCount: 3,
                            outsideDaysVisible: false,
                            defaultTextStyle: TextStyle(
                              color: colors.onSurface,
                            ),
                            weekendTextStyle: TextStyle(
                              color: colors.onSurface,
                            ),
                            disabledTextStyle: TextStyle(
                              color: colors.onSurface.withValues(
                                alpha: 0.35,
                              ),
                            ),
                          ),
                          headerStyle: const HeaderStyle(
                            formatButtonVisible: false,
                            titleCentered: true,
                          ),
                          daysOfWeekStyle: DaysOfWeekStyle(
                            weekdayStyle: TextStyle(
                              color: colors.onSurfaceVariant,
                              fontWeight: FontWeight.w600,
                            ),
                            weekendStyle: TextStyle(
                              color: colors.onSurfaceVariant,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    Card(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.event_note,
                              color: colors.primary,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                '${DateFormat.yMMMd(locale).format(state.selectedDay)} — ${l10n.calendarDayDetails}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            IconButton(
                              tooltip: l10n.calendarDoseHistory,
                              onPressed: () {
                                Navigator.pushNamed(
                                  context,
                                  '/doseHistory',
                                );
                              },
                              icon: const Icon(Icons.history),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 8),

                    if (selectedDoses.isEmpty)
                      const _EmptyDosesView()
                    else
                      ...selectedDoses.map(
                        (dose) => _DoseCalendarCard(dose: dose),
                      ),

                    if (state.status == CalendarStatus.failure) ...[
                      const SizedBox(height: 8),
                      Text(
                        _errorMessage(l10n, state.errorKey),
                        textAlign: TextAlign.center,
                        style: TextStyle(color: colors.error),
                      ),
                      TextButton.icon(
                        onPressed: cubit.refresh,
                        icon: const Icon(Icons.refresh),
                        label: Text(l10n.calendarRetry),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  String _errorMessage(AppLocalizations l10n, String? key) {
    switch (key) {
      case 'patientUidMissing':
        return l10n.calendarPatientUidMissing;
      case 'calendarLoadError':
      default:
        return l10n.calendarLoadError;
    }
  }
}

class _DoseCalendarCard extends StatelessWidget {
  final DoseModel dose;

  const _DoseCalendarCard({required this.dose});

  String _formatTime(BuildContext context) {
    final locale = AppLocalizations.of(context)!.localeName;
    return DateFormat.jm(locale).format(dose.scheduledAt);
  }

  String _statusLabel(AppLocalizations l10n, DoseStatus status) {
    switch (status) {
      case DoseStatus.upcoming:
        return l10n.calendarStatusUpcoming;
      case DoseStatus.due:
        return l10n.calendarStatusDue;
      case DoseStatus.taken:
        return l10n.calendarStatusTaken;
      case DoseStatus.snoozed:
        return l10n.calendarStatusSnoozed;
      case DoseStatus.missed:
        return l10n.calendarStatusMissed;
    }
  }

  Color _statusColor(BuildContext context, DoseStatus status) {
    final colors = Theme.of(context).colorScheme;

    switch (status) {
      case DoseStatus.upcoming:
        return colors.primary;
      case DoseStatus.due:
        return Colors.orange;
      case DoseStatus.taken:
        return Colors.green;
      case DoseStatus.snoozed:
        return Colors.purple;
      case DoseStatus.missed:
        return colors.error;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = Theme.of(context).colorScheme;
    final color = _statusColor(context, dose.status);

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.12),
          child: Icon(
            Icons.medication_outlined,
            color: color,
          ),
        ),
        title: Text(
          dose.medicationName,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 5),
          child: Text(
            '${dose.dosage} • ${_formatTime(context)}',
            style: TextStyle(color: colors.onSurfaceVariant),
          ),
        ),
        trailing: Container(
          constraints: const BoxConstraints(maxWidth: 115),
          padding: const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 7,
          ),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            _statusLabel(l10n, dose.status),
            textAlign: TextAlign.center,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

class _EmptyDosesView extends StatelessWidget {
  const _EmptyDosesView();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = Theme.of(context).colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Icon(
              Icons.medication_outlined,
              size: 48,
              color: colors.onSurfaceVariant,
            ),
            const SizedBox(height: 12),
            Text(
              l10n.calendarNoDoses,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _CalendarErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _CalendarErrorView({
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.cloud_off_outlined,
              size: 52,
              color: colors.onSurfaceVariant,
            ),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: Text(l10n.calendarRetry),
            ),
          ],
        ),
      ),
    );
  }
}
