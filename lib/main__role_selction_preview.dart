// Preview-only entry point for the sign-up screens.
// No Firebase, no AppRouter, no home page.
//
// Run with:  flutter run -t lib/main_preview.dart

import 'package:curelink/core/router/routes_names.dart';
import 'package:curelink/core/theme/dark_theme.dart';
import 'package:curelink/core/theme/light_theme.dart';
import 'package:curelink/features/role_selction/age_group.dart';
import 'package:curelink/features/role_selction/age_group_page.dart';
import 'package:curelink/features/role_selction/role_page.dart';
import 'package:curelink/features/role_selction/signup_args_placeholder.dart';
import 'package:curelink/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

// Change these and hot restart to preview other modes.
const _locale = Locale('en'); // Locale('ar') for RTL
const _themeMode = ThemeMode.light; // ThemeMode.dark

void main() => runApp(const PreviewApp());

class PreviewApp extends StatelessWidget {
  const PreviewApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: LightTheme.theme,
      darkTheme: DarkTheme.theme,
      themeMode: _themeMode,
      locale: _locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      onGenerateRoute: (settings) {
        final Widget page = switch (settings.name) {
          RoutesNames.rolePage => RolePage(
              ageGroup: settings.arguments as AgeGroup,
            ),
          RoutesNames.profilePage => _ProfileStub(
              args: settings.arguments as SignUpArgs,
            ),
          _ => const AgeGroupPage(),
        };
        return MaterialPageRoute(builder: (_) => page, settings: settings);
      },
    );
  }
}

/// Stands in for the real profile page (which needs Firebase).
class _ProfileStub extends StatelessWidget {
  const _ProfileStub({required this.args});

  final SignUpArgs args;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile (stub)')),
      body: Center(
        child: Text(
          'ageGroup = ${args.ageGroup.value}\nrole = ${args.role.value}',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleLarge,
        ),
      ),
    );
  }
}