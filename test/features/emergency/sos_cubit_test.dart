import 'package:curelink/features/emergency/data/repositories/sos_repository.dart';
import 'package:curelink/features/emergency/presentation/cubit/sos_cubit.dart';
import 'package:curelink/features/emergency/presentation/cubit/sos_state.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late FakeFirebaseFirestore firestore;
  late SosRepository repository;

  setUp(() {
    firestore = FakeFirebaseFirestore();
    repository = SosRepository(firestore: firestore);
  });

  MockFirebaseAuth patientAuth() {
    return MockFirebaseAuth(
      mockUser: MockUser(uid: 'patient123'),
      signedIn: true,
    );
  }

  Future<void> addConnection({
    required String id,
    required String patientUid,
    required String caregiverUid,
    String status = 'accepted',
  }) async {
    await firestore.collection('connections').doc(id).set({
      'patientUid': patientUid,
      'caregiverUid': caregiverUid,
      'status': status,
    });
  }

  group('SOS Cubit Tests', () {
    test('Unauthenticated user returns failure', () async {
      final cubit = SosCubit(
        repository: repository,
        auth: MockFirebaseAuth(signedIn: false),
      );

      await cubit.activateSos();

      expect(cubit.state.status, SosStatusType.failure);
      expect(cubit.state.requestId, isNull);

      await cubit.close();
    });

    test('No accepted caregiver returns failure', () async {
      final cubit = SosCubit(repository: repository, auth: patientAuth());

      await cubit.activateSos();

      expect(cubit.state.status, SosStatusType.failure);

      final requests = await firestore.collection('sos_requests').get();

      expect(requests.docs, isEmpty);

      await cubit.close();
    });

    test('Multiple caregivers create one SOS request', () async {
      await addConnection(
        id: 'connection1',
        patientUid: 'patient123',
        caregiverUid: 'caregiver1',
      );

      await addConnection(
        id: 'connection2',
        patientUid: 'patient123',
        caregiverUid: 'caregiver2',
      );

      final cubit = SosCubit(repository: repository, auth: patientAuth());

      await cubit.activateSos();

      expect(cubit.state.status, SosStatusType.pending);
      expect(cubit.state.requestId, isNotNull);

      final requests = await firestore.collection('sos_requests').get();

      expect(requests.docs.length, 1);

      expect(
        requests.docs.first.data()['caregiverUids'],
        containsAll(['caregiver1', 'caregiver2']),
      );

      await cubit.close();
    });

    test('Repeated activation does not create duplicates', () async {
      await addConnection(
        id: 'connection1',
        patientUid: 'patient123',
        caregiverUid: 'caregiver1',
      );

      final cubit = SosCubit(repository: repository, auth: patientAuth());

      await Future.wait([
        cubit.activateSos(),
        cubit.activateSos(),
        cubit.activateSos(),
      ]);

      final requests = await firestore.collection('sos_requests').get();

      expect(requests.docs.length, 1);

      await cubit.close();
    });

    test('Firestore status change updates Cubit state', () async {
      await addConnection(
        id: 'connection1',
        patientUid: 'patient123',
        caregiverUid: 'caregiver1',
      );

      final cubit = SosCubit(repository: repository, auth: patientAuth());

      await cubit.activateSos();

      final requestId = cubit.state.requestId!;

      await firestore.collection('sos_requests').doc(requestId).update({
        'status': 'sent',
      });

      await Future<void>.delayed(const Duration(milliseconds: 100));

      expect(cubit.state.status, SosStatusType.sent);

      await cubit.close();
    });

    test('Retry does not create another SOS request', () async {
      await addConnection(
        id: 'connection1',
        patientUid: 'patient123',
        caregiverUid: 'caregiver1',
      );

      final cubit = SosCubit(repository: repository, auth: patientAuth());

      await cubit.activateSos();

      final originalId = cubit.state.requestId;

      await cubit.retrySos();

      final requests = await firestore.collection('sos_requests').get();

      expect(requests.docs.length, 1);
      expect(cubit.state.requestId, originalId);

      await cubit.close();
    });
  });
}
