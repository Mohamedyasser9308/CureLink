import 'package:flutter/material.dart';
import '../../features/auth/presentation/firebase_test_page.dart';
//import '../../features/auth/presentation/profile_page.dart';
import '../../features/home/presentation/home_page.dart';
import '../../features/role_selction/age_group.dart';
import '../../features/role_selction/age_group_page.dart';
import '../../features/role_selction/role_page.dart';

import 'routes_names.dart';

class AppRouter {
  AppRouter._();

  /// Simple routes (no arguments)
  static final Map<String, WidgetBuilder> routes = {
    RoutesNames.homePage: (_) => const HomePage(),
    RoutesNames.ageGroupPage: (_) => const AgeGroupPage(), // sign-up entry
    FirebaseTestPage.routeName: (_) => const FirebaseTestPage(),
  };

  /// Routes that need arguments or custom transitions.
  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      // AgeGroupPage -> RolePage(ageGroup)
      case RoutesNames.rolePage:
        final ageGroup = settings.arguments;
        if (ageGroup is! AgeGroup) {
          return _buildRoute(const AgeGroupPage(), settings);
        }
        return _buildRoute(RolePage(ageGroup: ageGroup), settings);

      // RolePage -> the home screen of that persona (ageGroup + role)
      // case RoutesNames.personaHome:
      //   final args = settings.arguments;
      //   if (args is! SignUpArgs) {
      //     return _buildRoute(const AgeGroupPage(), settings);
      //   }
      //   return _buildRoute(_personaHome(args), settings);

      // RolePage -> ProfileDetailsPage(SignUpArgs)
      // TODO: enable when the profile page exists.
      //case RoutesNames.profilePage:
      //  final args = settings.arguments as SignUpArgs;
      //  return _buildRoute(ProfileDetailsPage(args: args), settings);

      default:
        return null;
    }
  }

  /// Which home screen does each persona get?
  ///
  /// | Age group   | Role      | Screen                       |
  /// |-------------|-----------|------------------------------|
  /// | Child       | Patient   | ChildPatientHomePage         |
  /// | Teen/Adult  | Patient   | TeenPatientHomePage          |
  /// | Teen/Adult  | Caregiver | TeenCaregiverHomePage        |
  /// | Teen/Adult  | Both      | TeenPatientHomePage (starts in patient mode) |
  /// | Older Adult | Patient   | OlderAdultPatientHomePage    |
  // static Widget _personaHome(SignUpArgs args) =>
  //     switch ((args.ageGroup, args.role.startingMode)) {
  //       (AgeGroup.child, _) => const ChildPatientHomePage(),
  //       (AgeGroup.olderAdult, _) => const OlderAdultPatientHomePage(),
  //       (AgeGroup.teenager, UserRole.caregiver) =>
  //         const TeenCaregiverHomePage(),
  //       (AgeGroup.teenager, _) => const TeenPatientHomePage(),
  //     };

  /// Shown when a route name isn't registered.
  static Route<dynamic> onUnknownRoute(RouteSettings settings) {
    return _buildRoute(
      Scaffold(
        appBar: AppBar(title: const Text('Page not found')),
        body: Center(child: Text('No route defined for ${settings.name}')),
      ),
      settings,
    );
  }

  static MaterialPageRoute<T> _buildRoute<T>(
    Widget page,
    RouteSettings settings,
  ) {
    return MaterialPageRoute<T>(builder: (_) => page, settings: settings);
  }
}