import 'dart:async';

import 'package:curelink/features/emergency/data/models/sos_model.dart';
import 'package:curelink/features/emergency/data/repositories/sos_repository.dart';
import 'package:curelink/features/emergency/presentation/cubit/sos_cubit.dart';
import 'package:curelink/features/emergency/presentation/cubit/sos_state.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter_test/flutter_test.dart';

class TestSosRepository extends SosRepository {
  TestSosRepository({required FakeFirebaseFirestore firestore})
    : super(firestore: firestore);

  bool failBeforeWriteOnce = false;
  bool failAfterWriteOnce = false;
  bool failWatching = false;

  int createAttempts = 0;
  final List<String> attemptedRequestIds = [];

  @override
  Future<String> createSosRequest({
    required String requestId,
    required String patientUid,
    required List<String> caregiverUids,
  }) async {
    createAttempts++;
    attemptedRequestIds.add(requestId);

    if (failBeforeWriteOnce) {
      failBeforeWriteOnce = false;

      throw StateError('Simulated network failure before writing');
    }

    final result = await super.createSosRequest(
      requestId: requestId,
      patientUid: patientUid,
      caregiverUids: caregiverUids,
    );

    if (failAfterWriteOnce) {
      failAfterWriteOnce = false;

      throw StateError('Simulated lost acknowledgment after writing');
    }

    return result;
  }

  @override
  Stream<SosModel> watchSosRequest(String requestId) {
    if (failWatching) {
      return Stream<SosModel>.error(
        StateError('Simulated status verification failure'),
      );
    }

    return super.watchSosRequest(requestId);
  }
}

void main() {
  late FakeFirebaseFirestore firestore;
  late TestSosRepository repository;

  setUp(() {
    firestore = FakeFirebaseFirestore();
    repository = TestSosRepository(firestore: firestore);
  });

  MockFirebaseAuth patientAuth() {
    return MockFirebaseAuth(
      mockUser: MockUser(uid: 'patient123'),
      signedIn: true,
    );
  }

  Future<void> addAcceptedCaregiver() async {
    await firestore.collection('connections').doc('connection1').set({
      'patientUid': 'patient123',
      'caregiverUid': 'caregiver123',
      'status': 'accepted',
    });
  }

  Future<int> requestCount() async {
    final snapshot = await firestore.collection('sos_requests').get();

    return snapshot.docs.length;
  }

  group('SOS Cubit Edge Cases', () {
    test('Retry after failed creation uses the same request ID', () async {
      await addAcceptedCaregiver();

      repository.failBeforeWriteOnce = true;

      final cubit = SosCubit(repository: repository, auth: patientAuth());

      try {
        await cubit.activateSos();

        expect(cubit.state.status, SosStatusType.verificationFailed);

        final originalId = cubit.state.requestId;

        expect(originalId, isNotNull);
        expect(await requestCount(), 0);

        await cubit.retrySos();

        expect(cubit.state.status, SosStatusType.pending);

        expect(cubit.state.requestId, originalId);
        expect(await requestCount(), 1);

        expect(repository.createAttempts, 2);

        expect(repository.attemptedRequestIds, [originalId, originalId]);
      } finally {
        await cubit.close();
      }
    });

    test(
      'Retry after lost acknowledgment does not duplicate request',
      () async {
        await addAcceptedCaregiver();

        repository.failAfterWriteOnce = true;

        final cubit = SosCubit(repository: repository, auth: patientAuth());

        try {
          await cubit.activateSos();

          expect(cubit.state.status, SosStatusType.verificationFailed);

          final originalId = cubit.state.requestId;

          expect(originalId, isNotNull);

          // The request reached Firestore,
          // but the Cubit did not receive confirmation.
          expect(await requestCount(), 1);

          await cubit.retrySos();

          expect(cubit.state.requestId, originalId);

          expect(cubit.state.status, SosStatusType.pending);

          expect(await requestCount(), 1);

          // No second write should be attempted.
          expect(repository.createAttempts, 1);
        } finally {
          await cubit.close();
        }
      },
    );

    test('Watch error returns verificationFailed instead of sent', () async {
      await addAcceptedCaregiver();

      repository.failWatching = true;

      final cubit = SosCubit(repository: repository, auth: patientAuth());

      try {
        await cubit.activateSos();

        // Allow the stream error event to be delivered.
        await Future<void>.delayed(const Duration(milliseconds: 50));

        expect(cubit.state.status, SosStatusType.verificationFailed);

        expect(cubit.state.requestId, isNotNull);

        expect(cubit.state.status, isNot(SosStatusType.sent));

        expect(await requestCount(), 1);
      } finally {
        await cubit.close();
      }
    });

    test('Confirmed notification failure returns failure', () async {
      await addAcceptedCaregiver();

      final cubit = SosCubit(repository: repository, auth: patientAuth());

      try {
        await cubit.activateSos();

        final requestId = cubit.state.requestId;

        expect(requestId, isNotNull);

        await firestore.collection('sos_requests').doc(requestId!).update({
          'status': 'failed',
        });

        // Allow the Firestore stream to update the Cubit.
        await Future<void>.delayed(const Duration(milliseconds: 50));

        expect(cubit.state.status, SosStatusType.failure);

        expect(cubit.state.requestId, requestId);

        expect(cubit.state.errorMessage, isNotNull);
      } finally {
        await cubit.close();
      }
    });
  });
}
