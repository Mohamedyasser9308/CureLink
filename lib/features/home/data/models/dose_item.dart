
import 'package:curelink/features/medication/data/models/medication_model.dart';

enum DoseStatus { upcoming, dueNow, past }

class DoseItem {
  const DoseItem({
    required this.medication,
    required this.time,
  });

  final MedicationModel medication;
  final DateTime time;

  static const Duration dueWindow = Duration(minutes: 30);

  DoseStatus statusAt(DateTime now) {
    if (time.isAfter(now)) return DoseStatus.upcoming;

    if (now.difference(time) < dueWindow) {
      return DoseStatus.dueNow;
    }

    return DoseStatus.past;
  }

  static final RegExp _timeRe = RegExp(
    r'^(\d{1,2}):(\d{2})\s*([ap]m)?$',
    caseSensitive: false,
  );

  static DateTime? parseTime(String raw, DateTime day) {
    final match = _timeRe.firstMatch(raw.trim());

    if (match == null) return null;

    var hour = int.parse(match.group(1)!);
    final minute = int.parse(match.group(2)!);
    final meridiem = match.group(3)?.toLowerCase();

    if (minute > 59) return null;

    if (meridiem != null) {
      if (hour < 1 || hour > 12) return null;

      hour = hour % 12 + (meridiem == 'pm' ? 12 : 0);
    } else if (hour > 23) {
      return null;
    }

    return DateTime(
      day.year,
      day.month,
      day.day,
      hour,
      minute,
    );
  }

  static bool _isScheduledForDay(
    MedicationModel medication,
    DateTime day,
  ) {
    final frequency = medication.frequency.trim().toLowerCase();

    final start = DateTime(
      medication.startDate.year,
      medication.startDate.month,
      medication.startDate.day,
    );

    final currentDay = DateTime(day.year, day.month, day.day);

    if (currentDay.isBefore(start)) return false;

    switch (frequency) {
      case 'every day':
      case 'daily':
        return true;

      case 'every other day':
        return currentDay.difference(start).inDays % 2 == 0;

      case 'specific days':
        // DateTime.weekday: Monday = 1, Sunday = 7.
        return medication.weekdays.contains(day.weekday);

      case 'as needed':
        // PRN medications are not scheduled automatically.
        return false;

      default:
        // Unknown frequency: do not create potentially incorrect reminders.
        return false;
    }
  }

  static bool _isWithinDuration(
    MedicationModel medication,
    DateTime day,
  ) {
    final duration = medication.durationDays;

    // Null means ongoing treatment.
    if (duration == null) return true;

    if (duration <= 0) return false;

    final start = DateTime(
      medication.startDate.year,
      medication.startDate.month,
      medication.startDate.day,
    );

    final currentDay = DateTime(day.year, day.month, day.day);

    // A 7-day course includes the start date and the following 6 days.
    final end = start.add(Duration(days: duration - 1));

    return !currentDay.isBefore(start) &&
        !currentDay.isAfter(end);
  }

  static List<DoseItem> buildToday(
    List<MedicationModel> medications,
    DateTime now,
  ) {
    final today = DateTime(now.year, now.month, now.day);
    final doses = <DoseItem>[];

    for (final medication in medications) {
      if (!medication.isActive) continue;

      if (!_isWithinDuration(medication, today)) continue;

      if (!_isScheduledForDay(medication, today)) continue;

      for (final rawTime in medication.times) {
        final time = parseTime(rawTime, today);

        if (time == null) continue;

        doses.add(
          DoseItem(
            medication: medication,
            time: time,
          ),
        );
      }
    }

    doses.sort((a, b) {
      final timeComparison = a.time.compareTo(b.time);

      if (timeComparison != 0) return timeComparison;

      return a.medication.name.compareTo(b.medication.name);
    });

    return doses;
  }

  static DoseItem? nextDose(
    List<DoseItem> doses,
    DateTime now,
  ) {
    for (final dose in doses) {
      if (dose.time.isAfter(now)) return dose;
    }

    return null;
  }
}
