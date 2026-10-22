import 'package:curelink/features/add_medication/data/models/medication_model.dart';
import 'package:curelink/features/patient/data/models/dose_item.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final monday = DateTime(2025, 2, 3);

  MedicationModel medication({
    String frequency = 'Every day',
    List<String> times = const ['08:00', '20:00'],
    List<int> weekdays = const [],
    int? durationDays,
  }) => MedicationModel(
    id: 'med-1',
    name: 'Medication',
    dosage: '1 tablet',
    times: times,
    frequency: frequency,
    weekdays: weekdays,
    durationDays: durationDays,
    startDate: monday,
    createdAt: monday,
  );

  group('DoseItem', () {
    test('parses 24-hour and AM/PM times', () {
      expect(DoseItem.parseTime('08:05', monday), DateTime(2025, 2, 3, 8, 5));
      expect(DoseItem.parseTime('8:05 PM', monday), DateTime(2025, 2, 3, 20, 5));
      expect(DoseItem.parseTime('13:75', monday), isNull);
    });

    test('builds sorted daily doses within the treatment duration', () {
      final doses = DoseItem.buildToday(
        [medication(durationDays: 2)],
        DateTime(2025, 2, 4, 7),
      );

      expect(doses.map((dose) => dose.time.hour), [8, 20]);
      expect(
        DoseItem.buildToday([medication(durationDays: 2)], DateTime(2025, 2, 5)),
        isEmpty,
      );
    });

    test('honors selected weekdays and excludes as-needed medication', () {
      expect(
        DoseItem.buildToday(
          [medication(frequency: 'Specific days', weekdays: const [1])],
          DateTime(2025, 2, 3, 7),
        ),
        hasLength(2),
      );
      expect(
        DoseItem.buildToday(
          [medication(frequency: 'Specific days', weekdays: const [2])],
          DateTime(2025, 2, 3, 7),
        ),
        isEmpty,
      );
      expect(
        DoseItem.buildToday(
          [medication(frequency: 'As needed')],
          DateTime(2025, 2, 3, 7),
        ),
        isEmpty,
      );
    });

    test('marks a dose missed after the same ten-minute grace period', () {
      final dose = DoseItem(
        medication: medication(times: const ['08:00']),
        time: DateTime(2025, 2, 3, 8),
      );

      expect(dose.statusAt(DateTime(2025, 2, 3, 8, 9)), DoseStatus.dueNow);
      expect(dose.statusAt(DateTime(2025, 2, 3, 8, 10)), DoseStatus.past);
    });

    test('selects the next future dose and ignores times already passed', () {
      final doses = DoseItem.buildToday(
        [medication()],
        DateTime(2025, 2, 3, 9),
      );

      expect(DoseItem.nextDose(doses, DateTime(2025, 2, 3, 9))?.time.hour, 20);
      expect(DoseItem.nextDose(doses, DateTime(2025, 2, 3, 21)), isNull);
    });
  });
}
