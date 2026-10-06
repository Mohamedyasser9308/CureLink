import 'package:flutter/material.dart';
import '../../features/auth/presentation/firebase_test_page.dart';
import '../../features/home/presentation/home_page.dart';
import 'routes_names.dart';

class AppRouter {
  AppRouter._();

  /// Simple routes (no arguments)
  static final Map<String, WidgetBuilder> routes = {
    RoutesNames.homePage: (_) => const HomePage(),
    FirebaseTestPage.routeName: (_) => const FirebaseTestPage(),
  };

  /// Routes that need arguments or custom transitions.
  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      // Example with arguments:
      // case DoctorDetailsPage.routeName:
      //   final args = settings.arguments as DoctorDetailsArgs;
      //   return _buildRoute(DoctorDetailsPage(args: args), settings);

      default:
        return null; 
    }
  }

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