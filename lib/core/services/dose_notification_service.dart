
import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import '../../features/schedule/data/models/dose_model.dart';
import '../../features/schedule/data/repositories/dose_repository.dart';
import '../../features/add_medication/data/repositries/medication_repository.dart';
import '../../firebase_options.dart';

@pragma('vm:entry-point')
void doseNotificationBackgroundResponse(
  NotificationResponse response,
) async {
  if (response.actionId != 'dose_taken' ||
      response.payload == null) {
    return;
  }

  try {
    WidgetsFlutterBinding.ensureInitialized();

    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    }

    final parts = response.payload!.split('|');

    if (parts.length != 2) {
      throw StateError('Dose action payload is invalid.');
    }

    final user = FirebaseAuth.instance.currentUser ??
        await FirebaseAuth.instance
            .authStateChanges()
            .first
            .timeout(const Duration(seconds: 15));

    if (user == null || user.uid != parts[0]) {
      throw StateError(
        'The patient account is not available for this action.',
      );
    }

    final doseRef = FirebaseFirestore.instance
        .collection('users')
        .doc(parts[0])
        .collection('doses')
        .doc(parts[1]);

    final wasSaved =
        await FirebaseFirestore.instance.runTransaction<bool>(
      (transaction) async {
        final snapshot = await transaction.get(doseRef);
        final data = snapshot.data();

        if (data == null) return false;
        if (data['status'] == 'taken') return true;

        final now = DateTime.now();

        transaction.update(doseRef, {
          'status': 'taken',
          'takenAt': Timestamp.fromDate(now),
          'snoozedUntil': null,
          'updatedAt': Timestamp.fromDate(now),
        });

        return true;
      },
    );

    if (!wasSaved) {
      throw StateError(
        'This dose is no longer available to confirm.',
      );
    }

    final notifications = FlutterLocalNotificationsPlugin();

    await notifications.initialize(
      const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(),
      ),
    );

    await notifications.cancel(
      _doseNotificationId('${parts[1]}:due'),
    );

    await notifications.cancel(
      _doseNotificationId('${parts[1]}:late'),
    );
  } catch (error, stackTrace) {
    debugPrint(
      'Could not mark the dose as taken from its notification: $error',
    );
    debugPrintStack(stackTrace: stackTrace);
  }
}

int _doseNotificationId(String value) {
  var hash = 0x811c9dc5;

  for (final unit in value.codeUnits) {
    hash = ((hash ^ unit) * 0x01000193) & 0x7fffffff;
  }

  return 0x10000000 | (hash & 0x6fffffff);
}

class DoseNotificationService {
  DoseNotificationService._();

  static const Duration _alarmSchedulingLeadTime = Duration(seconds: 2);

  static final DoseNotificationService instance =
      DoseNotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static const MethodChannel _androidAlarmChannel =
      MethodChannel('curelink/alarm');

  bool _initialized = false;
  bool _notificationsAllowed = true;
  bool _exactAlarmsAllowed = false;

  // A dose can be updated from both the reminder screen and the schedule
  // stream. Serialize its cancel-and-reschedule work so the old alarm cannot
  // win a race and fire immediately after a snooze.
  final Map<String, Future<void>> _doseScheduleOperations = {};

  String? initialPayload;
  String? _lastOpenedPayload;
  DateTime? _lastOpenedAt;

  String? _registeredUid;
  String? _registeredToken;

  StreamSubscription<String>? _tokenSubscription;
  StreamSubscription<RemoteMessage>? _foregroundPushSubscription;

  String? takeInitialPayload() {
    final payload = initialPayload;
    initialPayload = null;

    if (payload != null) {
      _rememberOpenedPayload(payload);
    }

    return payload;
  }

  void _rememberOpenedPayload(String payload) {
    _lastOpenedPayload = payload;
    _lastOpenedAt = DateTime.now();
  }

  void _dispatchOpen(
    void Function(String) onOpen,
    String payload,
  ) {
    final lastAt = _lastOpenedAt;

    if (_lastOpenedPayload == payload &&
        lastAt != null &&
        DateTime.now().difference(lastAt) <
            const Duration(seconds: 4)) {
      return;
    }

    _rememberOpenedPayload(payload);
    onOpen(payload);
  }

  Future<Map<String, dynamic>>
      getAndroidAlarmPermissionStatus() async {
    if (defaultTargetPlatform != TargetPlatform.android) {
      return const {};
    }

    final result =
        await _androidAlarmChannel.invokeMapMethod<String, dynamic>(
      'getPermissionStatus',
    );

    return result ?? const <String, dynamic>{};
  }

  Future<void> openAndroidAlarmPermissionSettings(
    String kind,
  ) async {
    if (defaultTargetPlatform != TargetPlatform.android) return;

    await _androidAlarmChannel.invokeMethod<void>(
      'openPermissionSettings',
      {'kind': kind},
    );
  }

  Future<void> refreshAndroidPermissionState() async {
    if (defaultTargetPlatform != TargetPlatform.android) return;

    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    _notificationsAllowed =
        await android?.areNotificationsEnabled() ??
            _notificationsAllowed;

    _exactAlarmsAllowed =
        await android?.canScheduleExactNotifications() ??
            _exactAlarmsAllowed;
  }

  Future<void> registerPushToken() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null || !_supportsPush) return;

    final settings =
        await FirebaseMessaging.instance.requestPermission();

    if (settings.authorizationStatus ==
        AuthorizationStatus.denied) {
      return;
    }

    final token = await FirebaseMessaging.instance.getToken();

    if (token == null) return;

    if (_registeredUid != null &&
        _registeredUid != user.uid &&
        _registeredToken != null) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(_registeredUid)
          .set({
        'fcmTokens': FieldValue.arrayRemove([_registeredToken]),
      }, SetOptions(merge: true));
    }

    final userRef =
        FirebaseFirestore.instance.collection('users').doc(user.uid);

    await userRef.set({
      'fcmTokens': FieldValue.arrayUnion([token]),
    }, SetOptions(merge: true));

    _registeredUid = user.uid;
    _registeredToken = token;

    await _tokenSubscription?.cancel();

    _foregroundPushSubscription ??=
        FirebaseMessaging.onMessage.listen(_showForegroundPush);

    _tokenSubscription =
        FirebaseMessaging.instance.onTokenRefresh.listen(
      (newToken) async {
        final activeUser = FirebaseAuth.instance.currentUser;
        if (activeUser == null) return;

        final userRef = FirebaseFirestore.instance
            .collection('users')
            .doc(activeUser.uid);

        final previousToken =
            _registeredUid == activeUser.uid
                ? _registeredToken
                : null;

        if (previousToken != null &&
            previousToken != newToken) {
          try {
            await userRef.set({
              'fcmTokens': FieldValue.arrayRemove([previousToken]),
            }, SetOptions(merge: true));
          } catch (error) {
            debugPrint(
              'Could not remove the previous FCM token: $error',
            );
          }
        }

        await userRef.set({
          'fcmTokens': FieldValue.arrayUnion([newToken]),
        }, SetOptions(merge: true));

        _registeredUid = activeUser.uid;
        _registeredToken = newToken;
      },
    );
  }

  Future<void> _showForegroundPush(
    RemoteMessage message,
  ) async {
    final notification = message.notification;

    if (notification == null ||
        !_initialized ||
        !_notificationsAllowed) {
      return;
    }

    final notificationKey =
        message.data['notificationId'] as String? ??
            message.messageId ??
            '${notification.title}:${notification.body}';

    final isSos = message.data['type'] == 'sos';
    await _plugin.show(
      notificationKey.hashCode & 0x7fffffff,
      notification.title,
      notification.body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          isSos ? 'caregiver_sos_alarm' : 'caregiver_alerts',
          isSos ? 'Emergency SOS alarms' : 'Caregiver alerts',
          channelDescription:
              isSos
                  ? 'Urgent emergency alerts from linked patients'
                  : 'Alerts about linked patients medication doses',
          importance: Importance.max,
          priority: Priority.high,
          category: isSos
              ? AndroidNotificationCategory.alarm
              : AndroidNotificationCategory.message,
          visibility: NotificationVisibility.public,
          playSound: true,
          audioAttributesUsage: isSos
              ? AudioAttributesUsage.alarm
              : AudioAttributesUsage.notification,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentSound: true,
          interruptionLevel: isSos
              ? InterruptionLevel.timeSensitive
              : InterruptionLevel.active,
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
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .set({
        'fcmTokens': FieldValue.arrayRemove([token]),
      }, SetOptions(merge: true));
    }

    _registeredUid = null;
    _registeredToken = null;
  }

  Future<void> syncPatientSchedule(
    String patientUid, {
    bool rethrowOnFailure = false,
  }) async {
    try {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      final repository = DoseRepository();

      final medications = await MedicationRepository()
          .getMedications(patientId: patientUid);

      final end = today.add(
        const Duration(
          days: DoseRepository.scheduleHorizonDays,
        ),
      );

      final generated = [
        for (final medication in medications)
          ...repository.generateMedicationDoses(
            medication: medication,
            from: today,
            to: end,
            now: now,
          ),
      ];

      final removedDoseIds = await repository.reconcileMedicationDoses(
        patientUid: patientUid,
        medicationIds:
            medications.map((item) => item.id).toSet(),
        scheduledDoses: generated,
        from: today,
        to: end,
        now: now,
      );
      for (final doseId in removedDoseIds) {
        await cancelDoseId(doseId, stopRinging: true);
      }

      final alarms = await repository.getDoses(
        patientUid: patientUid,
        from: now.subtract(const Duration(minutes: 10)),
        to: now.add(const Duration(days: 30)),
      );

      await sync(patientUid: patientUid, doses: alarms);
    } catch (error, stackTrace) {
      debugPrint('Could not sync medication reminders: $error');
      debugPrintStack(stackTrace: stackTrace);
      if (rethrowOnFailure) rethrow;
    }
  }

  Future<void> initialize({
    required void Function(String payload) onOpen,
    bool requestPermissions = true,
  }) async {
    if (_initialized || !_supportsLocalReminders) return;

    _androidAlarmChannel.setMethodCallHandler((call) async {
      if (call.method == 'doseAlarmOpened' &&
          call.arguments is String) {
        _dispatchOpen(onOpen, call.arguments as String);
      }
    });

    tzdata.initializeTimeZones();

    try {
      final localZone = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(localZone));
    } catch (_) {
      // Keep the default timezone if the platform cannot report its zone.
    }

    await _plugin.initialize(
      const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(),
      ),
      onDidReceiveNotificationResponse: (response) {
        if (response.actionId == 'dose_taken') {
          doseNotificationBackgroundResponse(response);
          return;
        }

        final payload = response.payload;

        if (payload != null && payload.isNotEmpty) {
          _dispatchOpen(onOpen, payload);
        }
      },
      onDidReceiveBackgroundNotificationResponse:
          doseNotificationBackgroundResponse,
    );

    final launchDetails =
        await _plugin.getNotificationAppLaunchDetails();

    if (launchDetails?.didNotificationLaunchApp ?? false) {
      initialPayload =
          launchDetails?.notificationResponse?.payload;
    }

    if (defaultTargetPlatform == TargetPlatform.android) {
      try {
        initialPayload ??= await _androidAlarmChannel
            .invokeMethod<String>('takeLaunchDosePayload');
      } on PlatformException catch (error) {
        debugPrint(
          'Could not read alarm launch payload: ${error.code}',
        );
      } on MissingPluginException catch (error) {
        debugPrint(
          'Android alarm channel is unavailable: $error',
        );
      }
    }

    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    await android?.createNotificationChannel(
      const AndroidNotificationChannel(
        'caregiver_sos_alarm',
        'Emergency SOS alarms',
        description: 'Urgent emergency alerts from linked patients',
        importance: Importance.max,
        playSound: true,
        enableVibration: true,
        audioAttributesUsage: AudioAttributesUsage.alarm,
      ),
    );

    _notificationsAllowed = requestPermissions
        ? await android?.requestNotificationsPermission() ?? true
        : await android?.areNotificationsEnabled() ?? true;

    _exactAlarmsAllowed =
        await android?.canScheduleExactNotifications() ?? false;

    if (requestPermissions) {
      _notificationsAllowed =
          await _plugin.resolvePlatformSpecificImplementation<
                  IOSFlutterLocalNotificationsPlugin>()
              ?.requestPermissions(
                alert: true,
                badge: true,
                sound: true,
              ) ??
              _notificationsAllowed;
    }

    _initialized = true;
  }

  bool get _supportsLocalReminders =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);

  bool get _supportsPush => _supportsLocalReminders;

  Future<void> sync({
    required String patientUid,
    required List<DoseModel> doses,
  }) async {
    if (!_initialized) return;

    try {
      await _refreshExactAlarmPermission();
    } catch (error) {
      debugPrint(
        'Could not refresh exact-alarm permission: $error',
      );
      _exactAlarmsAllowed = false;
    }

    final now = DateTime.now();
    final end = now.add(const Duration(days: 30));
    final activeIds = <int>{};

    List<PendingNotificationRequest> pending;

    try {
      pending = await _plugin.pendingNotificationRequests();
    } catch (error, stackTrace) {
      debugPrint(
        'Could not read pending dose notifications: $error',
      );
      debugPrintStack(stackTrace: stackTrace);
      pending = const [];
    }

    for (final dose in doses) {
      final dueId = _stableId('${dose.id}:due');
      final lateId = _stableId('${dose.id}:late');

      if (dose.status == DoseStatus.taken ||
          dose.status == DoseStatus.missed) {
        try {
          await _plugin.cancel(dueId);
          await _plugin.cancel(lateId);
          await _cancelAndroidAlarm(dueId);
        } catch (error) {
          debugPrint(
            'Could not cancel inactive dose ${dose.id}: $error',
          );
        }
        continue;
      }

      activeIds
        ..add(dueId)
        ..add(lateId);

      var nativeAlarmScheduled = false;

      if (defaultTargetPlatform == TargetPlatform.android) {
        try {
          nativeAlarmScheduled = await _scheduleAndroidAlarm(
            id: dueId,
            dose: dose,
            patientUid: patientUid,
            now: now,
            end: end,
          );
        } catch (error, stackTrace) {
          debugPrint(
            'Native alarm scheduling failed for ${dose.id}: $error',
          );
          debugPrintStack(stackTrace: stackTrace);
        }

        if (nativeAlarmScheduled) {
          await _plugin.cancel(dueId);
          await _plugin.cancel(lateId);
          continue;
        }

        debugPrint(
          'Using Flutter notification fallback for dose ${dose.id}',
        );
      }

      if (_notificationsAllowed) {
        try {
          await _scheduleDose(
            dose: dose,
            patientUid: patientUid,
            dueId: dueId,
            lateId: lateId,
            payload: '$patientUid|${dose.id}',
            now: now,
            end: end,
          );
        } catch (error, stackTrace) {
          debugPrint(
            'Could not sync dose ${dose.id}: $error',
          );
          debugPrintStack(stackTrace: stackTrace);
        }
      } else {
        debugPrint(
          'Notifications are disabled; cannot schedule fallback for ${dose.id}',
        );
      }
    }

    for (final request in pending) {
      if (!_isDoseNotification(request.id)) continue;

      if (!activeIds.contains(request.id)) {
        try {
          await _plugin.cancel(request.id);
          await _cancelAndroidAlarm(request.id);
        } catch (error, stackTrace) {
          debugPrint(
            'Could not remove stale dose notification: $error',
          );
          debugPrintStack(stackTrace: stackTrace);
        }
      }
    }
  }

  Future<void> cancelDose(DoseModel dose) async {
    await cancelDoseId(dose.id, stopRinging: true);
  }

  Future<void> cancelDoseId(
    String doseId, {
    bool stopRinging = false,
  }) async {
    final dueId = _stableId('$doseId:due');
    final lateId = _stableId('$doseId:late');

    try {
      await _plugin.cancel(dueId);
      await _plugin.cancel(lateId);
    } catch (error) {
      debugPrint(
        'Could not cancel dose notification: $error',
      );
    }

    await _cancelAndroidAlarm(dueId, stopRinging: stopRinging);
  }

  Future<void> _cancelAndroidAlarm(
    int dueId, {
    bool stopRinging = false,
  }) async {
    if (defaultTargetPlatform != TargetPlatform.android) return;

    try {
      await _androidAlarmChannel.invokeMethod<void>(
        'cancel',
        {
          'id': dueId,
          'stopRinging': stopRinging,
        },
      );
    } on PlatformException catch (error) {
      debugPrint(
        'Could not cancel native alarm $dueId: ${error.code}',
      );
    } on MissingPluginException {
      debugPrint('Native alarm channel is unavailable.');
    }
  }

  Future<void> scheduleDose({
    required String patientUid,
    required DoseModel dose,
  }) async {
    final previous = _doseScheduleOperations[dose.id] ?? Future<void>.value();
    final operation = previous
        .catchError((Object _) {})
        .then((_) => _scheduleDoseNow(patientUid: patientUid, dose: dose));
    _doseScheduleOperations[dose.id] = operation;

    try {
      await operation;
    } finally {
      if (identical(_doseScheduleOperations[dose.id], operation)) {
        _doseScheduleOperations.remove(dose.id);
      }
    }
  }

  Future<void> _scheduleDoseNow({
    required String patientUid,
    required DoseModel dose,
  }) async {
    if (!_initialized) return;

    try {
      await _refreshExactAlarmPermission();
    } catch (error) {
      debugPrint(
        'Could not refresh exact-alarm permission: $error',
      );
      _exactAlarmsAllowed = false;
    }

    await cancelDose(dose);

    final now = DateTime.now();
    final end = now.add(const Duration(days: 30));

    var nativeAlarmScheduled = false;

    if (defaultTargetPlatform == TargetPlatform.android) {
      try {
        nativeAlarmScheduled = await _scheduleAndroidAlarm(
          id: _stableId('${dose.id}:due'),
          dose: dose,
          patientUid: patientUid,
          now: now,
          end: end,
        );
      } catch (error, stackTrace) {
        debugPrint('Could not schedule native alarm: $error');
        debugPrintStack(stackTrace: stackTrace);
      }
    }

    if (nativeAlarmScheduled) return;

    if (_notificationsAllowed) {
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
  }

  Future<void> _refreshExactAlarmPermission() async {
    if (defaultTargetPlatform != TargetPlatform.android) return;

    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    _exactAlarmsAllowed =
        await android?.canScheduleExactNotifications() ?? false;
  }

  /// Returns true only when a native alarm was registered successfully.
  Future<bool> _scheduleAndroidAlarm({
    required int id,
    required DoseModel dose,
    required String patientUid,
    required DateTime now,
    required DateTime end,
  }) async {
    if (defaultTargetPlatform != TargetPlatform.android ||
        dose.status == DoseStatus.taken ||
        dose.status == DoseStatus.missed) {
      return false;
    }

    final dueAt =
        dose.status == DoseStatus.snoozed &&
                dose.snoozedUntil != null
            ? dose.snoozedUntil!
            : dose.scheduledAt;

    final timeoutAt =
        dueAt.add(const Duration(minutes: 10));

    if (dueAt.isAfter(end) || !timeoutAt.isAfter(now)) {
      return false;
    }

    // AlarmManager rejects a trigger time that has passed by the time the
    // platform-channel call reaches Android. Keep a small lead for overdue
    // doses so they still ring immediately instead of being silently dropped.
    final alarmAt = dueAt.isBefore(now)
        ? now.add(_alarmSchedulingLeadTime)
        : dueAt;

    // Do not swallow errors here. The caller needs to know whether
    // native scheduling failed so it can try Flutter notifications.
    await _androidAlarmChannel.invokeMethod<void>(
      'schedule',
      {
        'id': id,
        'atMillis': alarmAt.millisecondsSinceEpoch,
        'payload': '$patientUid|${dose.id}',
      },
    );

    debugPrint(
      'Native alarm scheduled: id=$id at=${alarmAt.toIso8601String()}',
    );

    return true;
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
    if (dose.status == DoseStatus.taken ||
        dose.status == DoseStatus.missed) {
      return;
    }

    final dueAt =
        dose.status == DoseStatus.snoozed &&
                dose.snoozedUntil != null
            ? dose.snoozedUntil!
            : dose.scheduledAt;

    final timeoutAt =
        dueAt.add(const Duration(minutes: 10));

    if (dueAt.isAfter(end) || !timeoutAt.isAfter(now)) {
      return;
    }

    final notificationAt = dueAt.isBefore(now)
        ? now.add(_alarmSchedulingLeadTime)
        : dueAt;

    // Scheduling the same notification ID replaces its prior trigger time.
    // Always rebuild it so edits and reschedules cannot leave a stale alarm.
    try {
      await _schedule(
        id: dueId,
        at: notificationAt,
        title: 'Medication reminder',
        body: '${dose.medicationName} • ${dose.dosage}',
        payload: payload,
      );
    } catch (error) {
      debugPrint('Could not schedule due reminder for ${dose.id}: $error');
    }

    try {
      await _schedule(
        id: lateId,
        at: timeoutAt,
        title: 'Dose not confirmed',
        body: 'Please confirm ${dose.medicationName} in CureLink.',
        payload: payload,
      );
    } catch (error) {
      debugPrint('Could not schedule late reminder for ${dose.id}: $error');
    }
  }

  Future<void> _schedule({
    required int id,
    required DateTime at,
    required String title,
    required String body,
    required String payload,
  }) async {
    try {
      await _plugin.zonedSchedule(
        id,
        title,
        body,
        tz.TZDateTime.from(at, tz.local),
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'dose_alarms_v3',
            'Medication alarms',
            channelDescription:
                'Scheduled medication dose reminders',
            importance: Importance.max,
            priority: Priority.high,
            category: AndroidNotificationCategory.alarm,
            visibility: NotificationVisibility.public,
            enableVibration: true,
            playSound: true,
            fullScreenIntent: true,
            audioAttributesUsage: AudioAttributesUsage.alarm,
            actions: <AndroidNotificationAction>[
              AndroidNotificationAction(
                'dose_taken',
                'Taken',
                showsUserInterface: false,
                cancelNotification: false,
              ),
            ],
          ),
          iOS: DarwinNotificationDetails(
            presentSound: true,
          ),
        ),
        androidScheduleMode: _exactAlarmsAllowed
            ? AndroidScheduleMode.exactAllowWhileIdle
            : AndroidScheduleMode.inexactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        payload: payload,
      );
    } catch (error, stackTrace) {
      debugPrint(
        'Could not schedule dose notification ID=$id: $error',
      );
      debugPrintStack(stackTrace: stackTrace);
      rethrow;
    }
  }

  bool _isDoseNotification(int id) =>
      id >= 0x10000000 && id <= 0x7fffffff;

  int _stableId(String value) => _doseNotificationId(value);
}
