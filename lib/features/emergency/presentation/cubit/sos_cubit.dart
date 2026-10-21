import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/sos_model.dart';
import '../../data/repositories/sos_repository.dart';
import 'sos_state.dart';

class SosCubit extends Cubit<SosState> {
  SosCubit({required SosRepository repository, FirebaseAuth? auth})
    : _repository = repository,
      _auth = auth ?? FirebaseAuth.instance,
      super(const SosState());

  final SosRepository _repository;
  final FirebaseAuth _auth;

  bool _isSubmitting = false;

  String? _activeRequestId;
  String? _activePatientUid;
  List<String>? _activeCaregiverUids;

  StreamSubscription<SosModel>? _sosSubscription;

  // --------------------------------------------------
  // Activate SOS
  // --------------------------------------------------

  Future<void> activateSos() async {
    if (isClosed || _isSubmitting || _activeRequestId != null) {
      return;
    }

    _isSubmitting = true;

    emit(const SosState(status: SosStatusType.loading));

    try {
      final user = _auth.currentUser;

      if (user == null) {
        throw StateError('User is not authenticated');
      }

      final patientUid = user.uid;

      final caregivers = await _repository.getAcceptedCaregivers(patientUid);

      if (isClosed) return;

      // Prevent continuing with a different session.
      if (_auth.currentUser?.uid != patientUid) {
        throw StateError('User session has changed');
      }

      if (caregivers.isEmpty) {
        throw StateError('No accepted caregivers linked to this patient');
      }

      // Reserve one stable ID for this SOS activation.
      final requestId = _repository.generateRequestId();

      _activeRequestId = requestId;
      _activePatientUid = patientUid;
      _activeCaregiverUids = List<String>.from(caregivers);

      await _repository.createSosRequest(
        requestId: requestId,
        patientUid: patientUid,
        caregiverUids: caregivers,
      );

      if (isClosed) return;

      emit(SosState(status: SosStatusType.pending, requestId: requestId));

      await watchSosRequest(requestId);
    } catch (error) {
      if (isClosed) return;

      if (_activeRequestId != null) {
        // A write may have reached Firestore even if
        // its acknowledgment did not reach the device.
        emit(
          SosState(
            status: SosStatusType.verificationFailed,
            requestId: _activeRequestId,
            errorMessage: 'Unable to confirm SOS request creation: $error',
          ),
        );
      } else {
        // No request ID was reserved.
        emit(
          SosState(
            status: SosStatusType.failure,
            errorMessage: error.toString(),
          ),
        );
      }
    } finally {
      _isSubmitting = false;
    }
  }

  // --------------------------------------------------
  // Retry SOS
  // --------------------------------------------------

  Future<void> retrySos() async {
    if (isClosed || _isSubmitting) return;

    final requestId = _activeRequestId;

    if (requestId == null) {
      await activateSos();
      return;
    }

    _isSubmitting = true;

    try {
      final user = _auth.currentUser;

      if (user == null) {
        throw StateError('User is not authenticated');
      }

      final patientUid = _activePatientUid;

      if (patientUid == null || user.uid != patientUid) {
        throw StateError('SOS request does not belong to the current user');
      }

      // Always check the server before attempting a write.
      final existing = await _repository.getSosRequest(requestId);

      if (isClosed) return;

      if (_auth.currentUser?.uid != patientUid) {
        throw StateError('User session has changed');
      }

      if (existing != null) {
        if (existing.patientUid != patientUid) {
          throw StateError('SOS request belongs to another patient');
        }

        // Request exists: watch it, do not create it again.
        emit(SosState(status: SosStatusType.pending, requestId: requestId));

        await watchSosRequest(requestId);
        return;
      }

      // The server confirmed that this ID is absent.
      // Attempt creation with the SAME request ID.
      final caregivers = _activeCaregiverUids;

      if (caregivers == null || caregivers.isEmpty) {
        throw StateError('Cannot retry without the original caregivers');
      }

      await _repository.createSosRequest(
        requestId: requestId,
        patientUid: patientUid,
        caregiverUids: caregivers,
      );

      if (isClosed) return;

      emit(SosState(status: SosStatusType.pending, requestId: requestId));

      await watchSosRequest(requestId);
    } catch (error) {
      if (isClosed) return;

      // We do not know whether the previous write
      // or a notification succeeded.
      emit(
        SosState(
          status: SosStatusType.verificationFailed,
          requestId: requestId,
          errorMessage: 'Unable to verify or retry SOS request: $error',
        ),
      );
    } finally {
      _isSubmitting = false;
    }
  }

  // --------------------------------------------------
  // Watch SOS status
  // --------------------------------------------------

  Future<void> watchSosRequest(String requestId) async {
    await _sosSubscription?.cancel();
    _sosSubscription = null;

    if (isClosed) return;

    if (_activeRequestId != requestId) {
      return;
    }

    _sosSubscription = _repository
        .watchSosRequest(requestId)
        .listen(
          (request) {
            if (isClosed) return;

            if (_activeRequestId != request.id ||
                _auth.currentUser?.uid != request.patientUid ||
                _activePatientUid != request.patientUid) {
              return;
            }

            switch (request.status) {
              case SosStatus.pending:
                emit(
                  SosState(
                    status: SosStatusType.pending,
                    requestId: request.id,
                  ),
                );
                break;

              case SosStatus.sent:
                emit(
                  SosState(status: SosStatusType.sent, requestId: request.id),
                );
                break;

              case SosStatus.partiallySent:
                emit(
                  SosState(
                    status: SosStatusType.partiallySent,
                    requestId: request.id,
                  ),
                );
                break;

              case SosStatus.failed:
                emit(
                  SosState(
                    status: SosStatusType.failure,
                    requestId: request.id,
                    errorMessage: 'SOS notification sending failed',
                  ),
                );
                break;
            }
          },
          onError: (Object error) {
            if (isClosed || _activeRequestId != requestId) {
              return;
            }

            emit(
              SosState(
                status: SosStatusType.verificationFailed,
                requestId: requestId,
                errorMessage: 'Unable to verify SOS status: $error',
              ),
            );
          },
        );
  }

  // --------------------------------------------------
  // Dispose
  // --------------------------------------------------

  @override
  Future<void> close() async {
    await _sosSubscription?.cancel();
    _sosSubscription = null;

    await super.close();
  }
}
