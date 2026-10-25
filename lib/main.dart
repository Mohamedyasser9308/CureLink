
import 'dart:async';

import 'package:curelink/core/router/app_router.dart';
import 'package:curelink/core/router/routes_names.dart';
import 'package:curelink/core/services/dose_notification_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:curelink/core/settings/settings_cubit.dart';
import 'package:curelink/core/theme/dark_theme.dart';
import 'package:curelink/core/theme/light_theme.dart';
import 'package:curelink/features/onboarding/splashpage.dart';
import 'package:curelink/firebase_options.dart';
import 'package:curelink/l10n/app_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:workmanager/workmanager.dart';

const _doseScheduleRefreshTask = 'curelink-dose-schedule-refresh';

@pragma('vm:entry-point')
void doseScheduleCallbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    if (task != _doseScheduleRefreshTask) return true;
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return true;
    await DoseNotificationService.instance.initialize(
      onOpen: (_) {},
      requestPermissions: false,
    );
    await DoseNotificationService.instance.syncPatientSchedule(user.uid);
    return true;
  });
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await Workmanager().initialize(doseScheduleCallbackDispatcher);
  await Workmanager().registerPeriodicTask(
    _doseScheduleRefreshTask,
    _doseScheduleRefreshTask,
    frequency: const Duration(minutes: 15),
    existingWorkPolicy: ExistingPeriodicWorkPolicy.keep,
    constraints: Constraints(networkType: NetworkType.connected),
  );

  await initializeDateFormatting('ar');
  await initializeDateFormatting('en');

  await DoseNotificationService.instance.initialize(onOpen: (payload) {
    AppRouter.navigatorKey.currentState?.pushNamed(
      RoutesNames.medicationReminder, arguments: payload,
    );
  });
  FirebaseAuth.instance.authStateChanges().listen((user) {
    unawaited(_handleAuthChange(user));
  });

  runApp(
    BlocProvider(
      create: (_) => SettingsCubit()..loadSettings(),
      child: const MyApp(),
    ),
  );
}

Future<void> _handleAuthChange(User? user) async {
  try {
    if (user == null) {
      await DoseNotificationService.instance.unregisterPushToken();
      return;
    }
    try {
      await DoseNotificationService.instance.registerPushToken();
    } catch (error, stackTrace) {
      // Push token access must not prevent local medication alarms from being
      // registered on this device.
      debugPrint('Could not register the FCM token: $error');
      debugPrintStack(stackTrace: stackTrace);
    }
    await DoseNotificationService.instance.syncPatientSchedule(user.uid);
  } catch (error, stackTrace) {
    debugPrint('Could not initialize user notifications: $error');
    debugPrintStack(stackTrace: stackTrace);
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (context, settings) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          navigatorKey: AppRouter.navigatorKey,
          title: 'CureLink',

          theme: LightTheme.theme,
          darkTheme: DarkTheme.theme,
          themeMode: settings.themeMode,
          locale: settings.locale,

          home: const Splashscreen(),

          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],

          supportedLocales: AppLocalizations.supportedLocales,

          routes: AppRouter.routes,
          onGenerateRoute: AppRouter.onGenerateRoute,
          onUnknownRoute: AppRouter.onUnknownRoute,
        );
      },
    );
  }
}
