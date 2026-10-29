
import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;

import '../models/sos_model.dart';

class SosRepository {
  SosRepository({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
    http.Client? client,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance,
        _client = client ?? http.Client();

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  final http.Client _client;

  static final Uri _sosUri = Uri.parse(
    'https://curelink-dose-monitor.curelink66.workers.dev/sos',
  );

  CollectionReference<Map<String, dynamic>> get _sosRequests =>
      _firestore.collection('sos_requests');

  CollectionReference<Map<String, dynamic>> get _connections =>
      _firestore.collection('connections');

  Future<Map<String, dynamic>> _postToWorker({
    required String requestId,
    required String patientUid,
  }) async {
    final user = _auth.currentUser;

    if (user == null || user.uid != patientUid) {
      throw StateError('User is not authenticated');
    }

    final token = await user.getIdToken(true);

    if (token == null || token.isEmpty) {
      throw StateError('Unable to obtain Firebase ID token');
    }

    final response = await _client
        .post(
          _sosUri,
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: jsonEncode({'requestId': requestId}),
        )
        .timeout(const Duration(seconds: 30));

    Map<String, dynamic> body = {};

    try {
      final decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic>) {
        body = decoded;
      }
    } on FormatException {
      // Keep the HTTP error below useful if the response is not JSON.
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      final message =
          body['error']?.toString() ??
          body['message']?.toString() ??
          'HTTP ${response.statusCode}';

      throw Exception('SOS request failed: $message');
    }

    final returnedId = body['requestId']?.toString();

    if (returnedId != null && returnedId != requestId) {
      throw StateError('Unexpected SOS request ID returned by server');
    }

    return body;
  }

  Future<List<String>> getAcceptedCaregivers(String patientUid) async {
    final uid = patientUid.trim();

    if (uid.isEmpty) {
      throw ArgumentError('Patient UID cannot be empty');
    }

    final snapshot = await _connections
        .where('patientUid', isEqualTo: uid)
        .get(const GetOptions(source: Source.server));

    return snapshot.docs
        .where(
          (doc) =>
              (doc.data()['status'] as String? ?? '')
                  .trim()
                  .toLowerCase() ==
              'accepted',
        )
        .map((doc) => doc.data()['caregiverUid'])
        .whereType<String>()
        .map((value) => value.trim())
        .where((value) => value.isNotEmpty && value != uid)
        .toSet()
        .toList();
  }

  String generateRequestId() => _sosRequests.doc().id;

  Future<String> createSosRequest({
    required String requestId,
    required String patientUid,
    required List<String> caregiverUids,
  }) async {
    final id = requestId.trim();
    final uid = patientUid.trim();

    if (id.isEmpty || id.contains('/')) {
      throw ArgumentError('Invalid SOS request ID');
    }

    if (uid.isEmpty) {
      throw ArgumentError('Patient UID cannot be empty');
    }

    // The Worker verifies accepted caregivers on the server.
    await _postToWorker(requestId: id, patientUid: uid);

    return id;
  }

  Future<void> requestSosRetry(
    String requestId, {
    required String patientUid,
  }) async {
    final id = requestId.trim();
    final uid = patientUid.trim();

    if (id.isEmpty || id.contains('/')) {
      throw ArgumentError('Invalid SOS request ID');
    }

    if (uid.isEmpty) {
      throw ArgumentError('Patient UID cannot be empty');
    }

    // The Worker must support safe retries using the same request ID.
    await _postToWorker(requestId: id, patientUid: uid);
  }

  Future<SosModel?> getSosRequest(String requestId) async {
    final id = requestId.trim();

    if (id.isEmpty || id.contains('/')) {
      throw ArgumentError('Invalid SOS request ID');
    }

    final snapshot = await _sosRequests
        .doc(id)
        .get(const GetOptions(source: Source.server));

    if (!snapshot.exists) return null;

    final data = snapshot.data();

    if (data == null) {
      throw StateError('SOS request exists without data');
    }

    return SosModel.fromMap(snapshot.id, data);
  }

  Stream<SosModel> watchSosRequest(String requestId) {
    final id = requestId.trim();

    if (id.isEmpty || id.contains('/')) {
      throw ArgumentError('Invalid SOS request ID');
    }

    return _sosRequests.doc(id).snapshots().map((snapshot) {
      final data = snapshot.data();

      if (!snapshot.exists || data == null) {
        throw StateError('SOS request not found');
      }

      return SosModel.fromMap(snapshot.id, data);
    });
  }

  Future<List<Map<String, String>>> getAcceptedCaregiverDetails(
    String patientUid,
  ) async {
    final uid = patientUid.trim();

    if (uid.isEmpty) {
      throw ArgumentError('Patient UID cannot be empty');
    }

    final snapshot = await _connections
        .where('patientUid', isEqualTo: uid)
        .get();

    return _loadCaregiverDetailsFromConnections(snapshot.docs);
  }

  Stream<List<Map<String, String>>> watchAcceptedCaregiverDetails(
    String patientUid,
  ) {
    final uid = patientUid.trim();

    if (uid.isEmpty) {
      return Stream.error(
        ArgumentError('Patient UID cannot be empty'),
      );
    }

    return _connections
        .where('patientUid', isEqualTo: uid)
        .snapshots()
        .asyncMap(
          (snapshot) =>
              _loadCaregiverDetailsFromConnections(snapshot.docs),
        );
  }

  Future<List<Map<String, String>>>
      _loadCaregiverDetailsFromConnections(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> documents,
  ) async {
    final caregivers = <Map<String, String>>[];
    final seenUids = <String>{};

    for (final document in documents) {
      final connection = document.data();

      final status = (connection['status'] as String? ?? '')
          .trim()
          .toLowerCase();

      if (status != 'accepted') continue;

      final uid =
          (connection['caregiverUid'] as String? ?? '').trim();

      if (uid.isEmpty || !seenUids.add(uid)) continue;

      final connectionName =
          (connection['caregiverName'] as String? ?? '').trim();

      var name = connectionName;
      var phone =
          (connection['caregiverPhone'] as String? ?? '').trim();

      try {
        final userSnapshot =
            await _firestore.collection('users').doc(uid).get();

        final data = userSnapshot.data();

        if (data != null) {
          final userName =
              (data['name'] as String? ?? '').trim();
          final userPhone =
              (data['phone'] as String? ?? '').trim();

          if (userName.isNotEmpty) name = userName;
          if (userPhone.isNotEmpty) phone = userPhone;
        }
      } on FirebaseException {
        // Fall back to the connection document.
      }

      caregivers.add({
        'uid': uid,
        'name': name.isNotEmpty ? name : 'Caregiver',
        'phone': phone,
      });
    }

    return caregivers;
  }
}
