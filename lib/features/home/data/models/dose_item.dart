import 'medication_model.dart';

enum DoseStatus { upcoming, dueNow, past }

class DoseItem {
  const DoseItem({required this.medication, required this.time});

  final MedicationModel medication;
  final DateTime time;

  static const Duration dueWindow = Duration(minutes: 30);

  DoseStatus statusAt(DateTime now) {
    if (time.isAfter(now)) return DoseStatus.upcoming;
    if (now.difference(time) < dueWindow) return DoseStatus.dueNow;
    return DoseStatus.past;
  }

  static final RegExp _timeRe = RegExp(
    r'^(\d{1,2}):(\d{2})\s*([ap]m)?$',
    caseSensitive: false,
  );

  static DateTime? parseTime(String raw, DateTime day) {
    final m = _timeRe.firstMatch(raw.trim());
    if (m == null) return null;

    var hour = int.parse(m.group(1)!);
    final minute = int.parse(m.group(2)!);
    final meridiem = m.group(3)?.toLowerCase();

    if (minute > 59) return null;
    if (meridiem != null) {
      if (hour < 1 || hour > 12) return null;
      hour = hour % 12 + (meridiem == 'pm' ? 12 : 0);
    } else if (hour > 23) {
      return null;
    }
    return DateTime(day.year, day.month, day.day, hour, minute);
  }

  static List<DoseItem> buildToday(
    List<MedicationModel> medications,
    DateTime now,
  ) {
    final today = DateTime(now.year, now.month, now.day);
    final doses = <DoseItem>[];

    for (final med in medications) {
      if (!med.isActive) continue;

      final start = DateTime(
        med.startDate.year,
        med.startDate.month,
        med.startDate.day,
      );
      final end = DateTime(
        med.endDate.year,
        med.endDate.month,
        med.endDate.day,
      );
      if (today.isBefore(start) || today.isAfter(end)) continue;

      for (final raw in med.times) {
        final time = parseTime(raw, today);
        if (time == null) continue;
        doses.add(DoseItem(medication: med, time: time));
      }
    }

    doses.sort((a, b) {
      final byTime = a.time.compareTo(b.time);
      return byTime != 0
          ? byTime
          : a.medication.name.compareTo(b.medication.name);
    });
    return doses;
  }

  static DoseItem? nextDose(List<DoseItem> doses, DateTime now) {
    for (final d in doses) {
      if (d.time.isAfter(now)) return d;
    }
    return null;
  }
}
