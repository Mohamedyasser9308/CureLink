
import 'package:curelink/core/router/app_router.dart';
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
import 'package:curelink/core/services/fcm_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await FcmService().initialize();

  await initializeDateFormatting('ar');
  await initializeDateFormatting('en');

  runApp(
    BlocProvider(
      create: (_) => SettingsCubit()..loadSettings(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (context, settings) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
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
