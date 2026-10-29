
import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/sos_model.dart';
import '../../data/repositories/sos_repository.dart';
import 'sos_state.dart';

class SosCubit extends Cubit<SosState> {
  SosCubit({
    required SosRepository repository,
    FirebaseAuth? auth,
  })  : _repository = repository,
        _auth = auth ?? FirebaseAuth.instance,
        super(const SosState());

  final SosRepository _repository;
  final FirebaseAuth _auth;

  bool _isSubmitting = false;

  String? _activeRequestId;
  String? _activePatientUid;

  StreamSubscription<SosModel>? _sosSubscription;

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
      final requestId = _repository.generateRequestId();

      if (_auth.currentUser?.uid != patientUid) {
        throw StateError('User session has changed');
      }

      _activeRequestId = requestId;
      _activePatientUid = patientUid;

      await _repository.createSosRequest(
        requestId: requestId,
        patientUid: patientUid,
        caregiverUids: const [],
      );

      if (isClosed) return;

      emit(
        SosState(
          status: SosStatusType.pending,
          requestId: requestId,
        ),
      );

      await watchSosRequest(requestId);
    } catch (error) {
      if (isClosed) return;

      final message = error.toString();

      emit(
        SosState(
          status: _activeRequestId == null
              ? SosStatusType.failure
              : SosStatusType.verificationFailed,
          requestId: _activeRequestId,
          errorMessage: _activeRequestId == null
              ? 'Failed to start the emergency alert: $message'
              : 'Unable to confirm SOS request creation: $message',
        ),
      );
    } finally {
      _isSubmitting = false;
    }
  }

  Future<void> retrySos() async {
    if (isClosed || _isSubmitting) return;

    final requestId = _activeRequestId;

    if (requestId == null) {
      await activateSos();
      return;
    }

    _isSubmitting = true;

    emit(
      SosState(
        status: SosStatusType.loading,
        requestId: requestId,
      ),
    );

    try {
      final user = _auth.currentUser;
      final patientUid = _activePatientUid;

      if (user == null ||
          patientUid == null ||
          user.uid != patientUid) {
        throw StateError(
          'SOS request does not belong to the current user',
        );
      }

      final existing = await _repository.getSosRequest(requestId);

      if (isClosed) return;

      if (_auth.currentUser?.uid != patientUid) {
        throw StateError('User session has changed');
      }

      if (existing != null) {
        if (existing.patientUid != patientUid) {
          throw StateError(
            'SOS request belongs to another patient',
          );
        }
        
        switch (existing.status) {
          case SosStatus.sent:
            emit(
              SosState(
                status: SosStatusType.sent,
                requestId: requestId,
              ),
            );
            await watchSosRequest(requestId);
            return;

          case SosStatus.partiallySent:
            emit(
              SosState(
                status: SosStatusType.partiallySent,
                requestId: requestId,
              ),
            );
            await watchSosRequest(requestId);
            return;

          case SosStatus.pending:
          case SosStatus.failed:
            await _repository.requestSosRetry(
              requestId,
              patientUid: patientUid,
            );

            if (isClosed) return;

            emit(
              SosState(
                status: SosStatusType.pending,
                requestId: requestId,
              ),
            );

            await watchSosRequest(requestId);
            unawaited(_verifyRetryOutcome(requestId));
            return;
        }
      }

      // If the server confirms that the request is absent, reuse its ID.
      await _repository.createSosRequest(
        requestId: requestId,
        patientUid: patientUid,
        caregiverUids: const [],
      );

      if (isClosed) return;

      emit(
        SosState(
          status: SosStatusType.pending,
          requestId: requestId,
        ),
      );

      await watchSosRequest(requestId);
    } catch (error) {
      if (isClosed) return;

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

  Future<void> _verifyRetryOutcome(String requestId) async {
    await Future<void>.delayed(const Duration(seconds: 12));

    if (isClosed || _activeRequestId != requestId) return;

    try {
      final request = await _repository.getSosRequest(requestId);

      if (isClosed ||
          _activeRequestId != requestId ||
          request == null) {
        return;
      }

      if (request.status == SosStatus.pending) {
        emit(
          SosState(
            status: SosStatusType.verificationFailed,
            requestId: requestId,
            errorMessage:
                'The SOS request is still pending. The server has not confirmed notification sending.',
          ),
        );
      }
    } catch (error) {
      if (isClosed || _activeRequestId != requestId) return;

      emit(
        SosState(
          status: SosStatusType.verificationFailed,
          requestId: requestId,
          errorMessage: 'Could not verify the retry result: $error',
        ),
      );
    }
  }

  Future<void> watchSosRequest(String requestId) async {
    await _sosSubscription?.cancel();
    _sosSubscription = null;

    if (isClosed || _activeRequestId != requestId) return;

    _sosSubscription = _repository.watchSosRequest(requestId).listen(
      (request) {
        if (isClosed ||
            _activeRequestId != request.id ||
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
              SosState(
                status: SosStatusType.sent,
                requestId: request.id,
              ),
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
        if (isClosed || _activeRequestId != requestId) return;

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

  @override
  Future<void> close() async {
    await _sosSubscription?.cancel();
    _sosSubscription = null;
    await super.close();
  }
}
