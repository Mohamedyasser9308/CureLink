import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:curelink/features/emergency/data/repositories/sos_repository.dart';
import 'package:curelink/features/emergency/data/models/sos_model.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late FakeFirebaseFirestore fakeFirestore;
  late SosRepository repository;

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
    repository = SosRepository(firestore: fakeFirestore);
  });

  group('SOS Repository Tests', () {
    test('Returns only accepted caregivers for the correct patient', () async {
      await fakeFirestore.collection('connections').doc('1').set({
        'patientUid': 'patient123',
        'caregiverUid': 'caregiver1',
        'status': 'accepted',
      });

      await fakeFirestore.collection('connections').doc('2').set({
        'patientUid': 'patient123',
        'caregiverUid': 'caregiver2',
        'status': 'accepted',
      });

      await fakeFirestore.collection('connections').doc('3').set({
        'patientUid': 'patient123',
        'caregiverUid': 'caregiver3',
        'status': 'pending',
      });

      await fakeFirestore.collection('connections').doc('4').set({
        'patientUid': 'anotherPatient',
        'caregiverUid': 'caregiver4',
        'status': 'accepted',
      });

      final caregivers = await repository.getAcceptedCaregivers('patient123');

      expect(caregivers, containsAll(['caregiver1', 'caregiver2']));
      expect(caregivers.length, 2);
    });

    test('Returns empty list when no accepted caregiver exists', () async {
      final caregivers = await repository.getAcceptedCaregivers('patient123');

      expect(caregivers, isEmpty);
    });

    test('Does not return duplicate caregivers', () async {
      await fakeFirestore.collection('connections').doc('1').set({
        'patientUid': 'patient123',
        'caregiverUid': 'caregiver1',
        'status': 'accepted',
      });

      await fakeFirestore.collection('connections').doc('2').set({
        'patientUid': 'patient123',
        'caregiverUid': 'caregiver1',
        'status': 'accepted',
      });

      final caregivers = await repository.getAcceptedCaregivers('patient123');

      expect(caregivers, ['caregiver1']);
    });

    test('Creates SOS request with pending status', () async {
      final requestId = repository.generateRequestId();

      await repository.createSosRequest(
        requestId: requestId,
        patientUid: 'patient123',
        caregiverUids: ['caregiver1', 'caregiver2'],
      );

      final snapshot = await fakeFirestore
          .collection('sos_requests')
          .doc(requestId)
          .get();

      expect(snapshot.exists, true);
      expect(snapshot.data()?['patientUid'], 'patient123');
      expect(snapshot.data()?['caregiverUids'], ['caregiver1', 'caregiver2']);
      expect(snapshot.data()?['status'], 'pending');
    });

    test('Does not create duplicate request with same ID', () async {
      const requestId = 'same-request-id';

      await repository.createSosRequest(
        requestId: requestId,
        patientUid: 'patient123',
        caregiverUids: ['caregiver1'],
      );

      await repository.createSosRequest(
        requestId: requestId,
        patientUid: 'patient123',
        caregiverUids: ['caregiver1'],
      );

      final snapshot = await fakeFirestore.collection('sos_requests').get();

      expect(snapshot.docs.length, 1);
    });

    test('Rejects SOS request without caregivers', () async {
      expect(
        () => repository.createSosRequest(
          requestId: 'request123',
          patientUid: 'patient123',
          caregiverUids: [],
        ),
        throwsA(isA<StateError>()),
      );
    });

    test('Reads saved SOS request correctly', () async {
      await repository.createSosRequest(
        requestId: 'request123',
        patientUid: 'patient123',
        caregiverUids: ['caregiver1'],
      );

      final request = await repository.getSosRequest('request123');

      expect(request, isNotNull);
      expect(request!.patientUid, 'patient123');
      expect(request.status, SosStatus.pending);
    });

    test('Returns null for nonexistent request', () async {
      final request = await repository.getSosRequest('missing');

      expect(request, isNull);
    });

    test('Rejects reusing request ID for another patient', () async {
      await repository.createSosRequest(
        requestId: 'request123',
        patientUid: 'patient123',
        caregiverUids: ['caregiver1'],
      );

      await expectLater(
        repository.createSosRequest(
          requestId: 'request123',
          patientUid: 'anotherPatient',
          caregiverUids: ['caregiver2'],
        ),
        throwsA(isA<StateError>()),
      );
    });
  });
}
