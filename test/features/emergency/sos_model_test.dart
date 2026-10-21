import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:curelink/features/emergency/data/models/sos_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SosModel Tests', () {
    final createdAt = DateTime.utc(2026, 10, 21, 12);

    test('Converts SOS model to Firestore map', () {
      final model = SosModel(
        id: 'request123',
        patientUid: 'patient123',
        caregiverUids: ['caregiver1', 'caregiver2'],
        createdAt: createdAt,
        status: SosStatus.pending,
      );

      final data = model.toMap();

      expect(data['patientUid'], 'patient123');
      expect(data['caregiverUids'], ['caregiver1', 'caregiver2']);
      expect(data['createdAt'], isA<Timestamp>());
      expect((data['createdAt'] as Timestamp).toDate().toUtc(), createdAt);
      expect(data['status'], 'pending');
    });

    test('Creates SOS model from Firestore map', () {
      final data = {
        'patientUid': 'patient123',
        'caregiverUids': ['caregiver1', 'caregiver2'],
        'createdAt': Timestamp.fromDate(createdAt),
        'status': 'sent',
      };

      final model = SosModel.fromMap('request123', data);

      expect(model.id, 'request123');
      expect(model.patientUid, 'patient123');
      expect(model.caregiverUids, ['caregiver1', 'caregiver2']);
      expect(model.createdAt.toUtc(), createdAt);
      expect(model.status, SosStatus.sent);
    });

    test('Unknown status throws FormatException', () {
      final data = {
        'patientUid': 'patient123',
        'caregiverUids': ['caregiver1'],
        'createdAt': Timestamp.fromDate(createdAt),
        'status': 'unknown',
      };

      expect(
        () => SosModel.fromMap('request123', data),
        throwsA(isA<FormatException>()),
      );
    });

    test('Missing patient UID throws FormatException', () {
      final data = {
        'caregiverUids': ['caregiver1'],
        'createdAt': Timestamp.fromDate(createdAt),
        'status': 'pending',
      };

      expect(
        () => SosModel.fromMap('request123', data),
        throwsA(isA<FormatException>()),
      );
    });

    test('Invalid caregivers list throws FormatException', () {
      final data = {
        'patientUid': 'patient123',
        'caregiverUids': ['caregiver1', ''],
        'createdAt': Timestamp.fromDate(createdAt),
        'status': 'pending',
      };

      expect(
        () => SosModel.fromMap('request123', data),
        throwsA(isA<FormatException>()),
      );
    });

    test('Missing timestamp throws FormatException', () {
      final data = {
        'patientUid': 'patient123',
        'caregiverUids': ['caregiver1'],
        'status': 'pending',
      };

      expect(
        () => SosModel.fromMap('request123', data),
        throwsA(isA<FormatException>()),
      );
    });
  });
}
