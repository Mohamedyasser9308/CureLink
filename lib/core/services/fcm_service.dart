import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';


class FcmService {
  FcmService({
    FirebaseMessaging? messaging,
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  }) : _messaging = messaging ?? FirebaseMessaging.instance,
       _firestore = firestore ?? FirebaseFirestore.instance,
       _auth = auth ?? FirebaseAuth.instance;

  final FirebaseMessaging _messaging;
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  StreamSubscription<User?>? _authSubscription;
  StreamSubscription<String>? _tokenSubscription;
  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;

    await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    
    _authSubscription = _auth.authStateChanges().listen((user) async {
      if (user == null) return;
      await _registerCurrentToken(user.uid);
    });


    _tokenSubscription = _messaging.onTokenRefresh.listen((token) async {
      final user = _auth.currentUser;
      if (user == null || token.trim().isEmpty) return;
      await _saveToken(uid: user.uid, token: token.trim());
    });
  }

  Future<void> _registerCurrentToken(String uid) async {
    final token = await _messaging.getToken();
    if (token == null || token.trim().isEmpty) return;
    await _saveToken(uid: uid, token: token.trim());
  }

  Future<void> _saveToken({required String uid, required String token}) async {
    await _firestore.collection('users').doc(uid).set(
      {
        'fcmToken': token,
        'fcmTokens': FieldValue.arrayUnion([token]),
        'fcmTokenUpdatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }

  Future<void> dispose() async {
    await _authSubscription?.cancel();
    await _tokenSubscription?.cancel();
    _authSubscription = null;
    _tokenSubscription = null;
    _initialized = false;
  }
}
