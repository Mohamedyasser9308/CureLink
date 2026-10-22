import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import '../../features/schedule/data/models/dose_model.dart';
import '../../features/schedule/data/repositories/dose_repository.dart';
import '../../features/add_medication/data/repositries/medication_repository.dart';

class DoseNotificationService {
  DoseNotificationService._();

  static final DoseNotificationService instance = DoseNotificationService._();
  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  static const MethodChannel _androidAlarmChannel = MethodChannel('curelink/alarm');
  bool _initialized = false;
  bool _notificationsAllowed = true;
  bool _exactAlarmsAllowed = false;
  String? initialPayload;
  String? _registeredUid;
  String? _registeredToken;
  StreamSubscription<String>? _tokenSubscription;
  StreamSubscription<RemoteMessage>? _foregroundPushSubscription;

  String? takeInitialPayload() {
    final payload = initialPayload;
    initialPayload = null;
    return payload;
  }

  Future<void> registerPushToken() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || !_supportsPush) return;
    final settings = await FirebaseMessaging.instance.requestPermission();
    if (settings.authorizationStatus == AuthorizationStatus.denied) return;
    final token = await FirebaseMessaging.instance.getToken();
    if (token == null) return;
    if (_registeredUid != null && _registeredUid != user.uid && _registeredToken != null) {
      await FirebaseFirestore.instance.collection('users').doc(_registeredUid).set({
        'fcmTokens': FieldValue.arrayRemove([_registeredToken]),
      }, SetOptions(merge: true));
    }
    final userRef = FirebaseFirestore.instance.collection('users').doc(user.uid);
    await userRef.set({'fcmTokens': FieldValue.arrayUnion([token])}, SetOptions(merge: true));
    _registeredUid = user.uid;
    _registeredToken = token;
    await _tokenSubscription?.cancel();
    _foregroundPushSubscription ??= FirebaseMessaging.onMessage.listen(
      _showForegroundPush,
    );
    _tokenSubscription = FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
      final activeUser = FirebaseAuth.instance.currentUser;
      if (activeUser == null) return;
      await FirebaseFirestore.instance.collection('users').doc(activeUser.uid).set({
        'fcmTokens': FieldValue.arrayUnion([newToken]),
      }, SetOptions(merge: true));
      _registeredUid = activeUser.uid;
      _registeredToken = newToken;
    });
  }

  Future<void> _showForegroundPush(RemoteMessage message) async {
    final notification = message.notification;
    if (notification == null || !_initialized || !_notificationsAllowed) return;
    final notificationKey = message.data['notificationId'] as String? ??
        message.messageId ??
        '${notification.title}:${notification.body}';
    await _plugin.show(
      notificationKey.hashCode & 0x7fffffff,
      notification.title,
      notification.body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'caregiver_alerts',
          'Caregiver alerts',
          channelDescription: 'Alerts about linked patients\' medication doses',
          importance: Importance.max,
          priority: Priority.high,
          category: AndroidNotificationCategory.alarm,
          visibility: NotificationVisibility.public,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentSound: true,
        ),
      ),
    );
  }

  Future<void> unregisterPushToken() async {
    final uid = _registeredUid;
    final token = _registeredToken;
    await _tokenSubscription?.cancel();
    _tokenSubscription = null;
    if (uid != null && token != null) {
      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'fcmTokens': FieldValue.arrayRemove([token]),
      }, SetOptions(merge: true));
    }
    _registeredUid = null;
    _registeredToken = null;
  }

  Future<void> syncPatientSchedule(String patientUid) async {
    try {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final repository = DoseRepository();
      final medications = await MedicationRepository().getMedications(patientId: patientUid);
      final end = today.add(const Duration(days: DoseRepository.scheduleHorizonDays));
      final generated = [
        for (final medication in medications)
          ...repository.generateMedicationDoses(
            medication: medication, from: today, to: end, now: now,
          ),
      ];
      await repository.reconcileMedicationDoses(
        patientUid: patientUid,
        medicationIds: medications.map((item) => item.id).toSet(),
        scheduledDoses: generated,
        from: today,
        to: end,
        now: now,
      );
      final alarms = await repository.getDoses(
        patientUid: patientUid,
        from: now.subtract(const Duration(minutes: 10)),
        to: now.add(const Duration(days: 30)),
      );
      await sync(patientUid: patientUid, doses: alarms);
    } catch (error, stackTrace) {
      debugPrint('Could not sync medication reminders: $error');
      debugPrintStack(stackTrace: stackTrace);
    }
  }

  Future<void> initialize({required void Function(String payload) onOpen}) async {
    if (_initialized) return;
    if (!_supportsLocalReminders) return;
    tzdata.initializeTimeZones();
    try {
      final localZone = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(localZone));
    } catch (_) {
      // Keep timezone's default when the platform cannot report its zone.
    }
    await _plugin.initialize(
      const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(),
      ),
      onDidReceiveNotificationResponse: (response) {
        final payload = response.payload;
        if (payload != null && payload.isNotEmpty) onOpen(payload);
      },
    );
    final launchDetails = await _plugin.getNotificationAppLaunchDetails();
    if (launchDetails?.didNotificationLaunchApp ?? false) {
      initialPayload = launchDetails?.notificationResponse?.payload;
    }
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    _notificationsAllowed = await android?.requestNotificationsPermission() ?? true;
    await android?.requestExactAlarmsPermission();
    await android?.requestFullScreenIntentPermission();
    _exactAlarmsAllowed = await android?.canScheduleExactNotifications() ?? false;
    _notificationsAllowed = await _plugin.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>()?.requestPermissions(
      alert: true,
      badge: true,
      sound: true,
    ) ?? _notificationsAllowed;
    _initialized = true;
  }

  bool get _supportsLocalReminders => !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);

  bool get _supportsPush => _supportsLocalReminders;

  Future<void> sync({required String patientUid, required List<DoseModel> doses}) async {
    if (!_initialized || !_notificationsAllowed) return;
    await _refreshExactAlarmPermission();
    // Android limits the number of outstanding alarms. The rolling 30-day
    // window is replenished whenever the schedule screen is loaded.
    final now = DateTime.now();
    final end = now.add(const Duration(days: 30));
    final activeIds = <int>{};
    List<PendingNotificationRequest> pending;
    try {
      pending = await _plugin.pendingNotificationRequests();
    } catch (error, stackTrace) {
      // Notification state is a device-side convenience; it must not prevent
      // medication data from being saved or refreshed in Firestore.
      debugPrint('Could not read pending dose notifications: $error');
      debugPrintStack(stackTrace: stackTrace);
      pending = const [];
    }
    final pendingIds = pending.map((request) => request.id).toSet();
    for (final dose in doses) {
      if (dose.status == DoseStatus.taken || dose.status == DoseStatus.missed) {
        continue;
      }
      final dueId = _stableId('${dose.id}:due');
      final lateId = _stableId('${dose.id}:late');
      activeIds..add(dueId)..add(lateId);
      await _scheduleAndroidAlarm(
        id: dueId,
        dose: dose,
        now: now,
        end: end,
      );
      // Keep existing Android alarms in place. Re-registering every alarm
      // whenever the schedule refreshes can overwhelm the notification
      // manager on devices with many medications.
      if (pendingIds.contains(dueId) || pendingIds.contains(lateId)) continue;
      final payload = '$patientUid|${dose.id}';
      await _scheduleDose(
        dose: dose,
        patientUid: patientUid,
        dueId: dueId,
        lateId: lateId,
        payload: payload,
        now: now,
        end: end,
      );
    }
    for (final request in pending) {
      if (!_isDoseNotification(request.id)) continue;
      if (!activeIds.contains(request.id)) await _plugin.cancel(request.id);
    }
  }

  Future<void> cancelDose(DoseModel dose) async {
    final dueId = _stableId('${dose.id}:due');
    for (final id in [dueId, _stableId('${dose.id}:late')]) {
      try {
        await _plugin.cancel(id);
      } catch (error) {
        debugPrint('Could not cancel dose notification $id: $error');
      }
    }
    if (defaultTargetPlatform == TargetPlatform.android) {
      try {
        await _androidAlarmChannel.invokeMethod<void>('cancel', {'id': dueId});
      } on PlatformException catch (error) {
        debugPrint('Could not stop dose alarm audio: ${error.code}');
      }
    }
  }

  /// Replaces only this dose's alarms. It never cancels another medication's
  /// pending reminders, which is important for a one-dose snooze action.
  Future<void> scheduleDose({
    required String patientUid,
    required DoseModel dose,
  }) async {
    if (!_initialized || !_notificationsAllowed) return;
    await _refreshExactAlarmPermission();
    await cancelDose(dose);
    final now = DateTime.now();
    final end = now.add(const Duration(days: 30));
    await _scheduleAndroidAlarm(
      id: _stableId('${dose.id}:due'),
      dose: dose,
      now: now,
      end: end,
    );
    await _scheduleDose(
      dose: dose,
      patientUid: patientUid,
      dueId: _stableId('${dose.id}:due'),
      lateId: _stableId('${dose.id}:late'),
      payload: '$patientUid|${dose.id}',
      now: now,
      end: end,
    );
  }

  Future<void> _refreshExactAlarmPermission() async {
    if (defaultTargetPlatform != TargetPlatform.android) return;
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    _exactAlarmsAllowed =
        await android?.canScheduleExactNotifications() ?? false;
  }

  Future<void> _scheduleAndroidAlarm({
    required int id,
    required DoseModel dose,
    required DateTime now,
    required DateTime end,
  }) async {
    if (defaultTargetPlatform != TargetPlatform.android ||
        dose.status == DoseStatus.taken ||
        dose.status == DoseStatus.missed) {
      return;
    }
    final dueAt = dose.status == DoseStatus.snoozed && dose.snoozedUntil != null
        ? dose.snoozedUntil!
        : dose.scheduledAt;
    final timeoutAt = dueAt.add(const Duration(minutes: 10));
    if (dueAt.isAfter(end) || !timeoutAt.isAfter(now)) return;
    final alarmAt = dueAt.isBefore(now) ? now : dueAt;
    try {
      await _androidAlarmChannel.invokeMethod<void>('schedule', {
        'id': id,
        'atMillis': alarmAt.millisecondsSinceEpoch,
        'exact': _exactAlarmsAllowed,
      });
    } on PlatformException catch (error) {
      debugPrint('Could not schedule alarm audio: ${error.code}');
    }
  }

  Future<void> _scheduleDose({
    required DoseModel dose,
    required String patientUid,
    required int dueId,
    required int lateId,
    required String payload,
    required DateTime now,
    required DateTime end,
  }) async {
    if (dose.status == DoseStatus.taken || dose.status == DoseStatus.missed) {
      return;
    }
    final dueAt = dose.status == DoseStatus.snoozed && dose.snoozedUntil != null
        ? dose.snoozedUntil!
        : dose.scheduledAt;
    final timeoutAt = dueAt.add(const Duration(minutes: 10));
    if (dueAt.isAfter(end) || !timeoutAt.isAfter(now)) return;
    final notificationAt = dueAt.isBefore(now) ? now : dueAt;
    await _schedule(
      id: dueId,
      at: notificationAt,
      title: 'Medication reminder',
      body: '${dose.medicationName} • ${dose.dosage}',
      payload: payload,
    );
    await _schedule(
      id: lateId,
      at: timeoutAt,
      title: 'Dose not confirmed',
      body: 'Please confirm ${dose.medicationName} in CureLink.',
      payload: payload,
    );
  }

  Future<void> _schedule({required int id, required DateTime at,
    required String title, required String body, required String payload}) async {
    try {
      await _plugin.zonedSchedule(
        id,
        title,
        body,
        tz.TZDateTime.from(at, tz.local),
        const NotificationDetails(
          android: AndroidNotificationDetails(
            // Android locks channel sound settings after the channel is made.
            'dose_alarms_v3', 'Medication alarms',
            channelDescription: 'Scheduled medication dose reminders',
            importance: Importance.max,
            priority: Priority.high,
            category: AndroidNotificationCategory.alarm,
            visibility: NotificationVisibility.public,
            enableVibration: true,
            playSound: true,
            fullScreenIntent: true,
            audioAttributesUsage: AudioAttributesUsage.alarm,
          ),
          iOS: DarwinNotificationDetails(presentSound: true),
        ),
        androidScheduleMode: _exactAlarmsAllowed
            ? AndroidScheduleMode.exactAllowWhileIdle
            : AndroidScheduleMode.inexactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        payload: payload,
      );
    } catch (error, stackTrace) {
      debugPrint('Could not schedule dose notification: $error');
      debugPrintStack(stackTrace: stackTrace);
    }
  }

  bool _isDoseNotification(int id) => id >= 0x10000000 && id <= 0x7fffffff;

  int _stableId(String value) {
    var hash = 0x811c9dc5;
    for (final unit in value.codeUnits) {
      hash = ((hash ^ unit) * 0x01000193) & 0x7fffffff;
    }
    return 0x10000000 | (hash & 0x6fffffff);
  }
}

