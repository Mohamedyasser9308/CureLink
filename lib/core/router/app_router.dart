
import 'package:curelink/features/auth/presentation/signup_page.dart';
import 'package:flutter/material.dart';

import '../../features/home/presentation/home_page.dart';
import '../../features/login/ui/login_screen.dart';
import 'routes_names.dart';

class AppRouter {
  AppRouter._();

  static final Map<String, WidgetBuilder> routes = {
    RoutesNames.homePage: (_) => const HomePage(),
    RoutesNames.loginPage: (_) => const LoginScreen(),
    RoutesNames.signUpPage: (_) => const SignupPage(),
  };

  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      default:
        return null;
    }
  }

  static Route<dynamic> onUnknownRoute(RouteSettings settings) {
    return _buildRoute(
      Scaffold(
        appBar: AppBar(
          title: const Text('Page not found'),
        ),
        body: Center(
          child: Text(
            'No route defined for ${settings.name}',
          ),
        ),
      ),
      settings,
    );
  }

  static MaterialPageRoute<T> _buildRoute<T>(
    Widget page,
    RouteSettings settings,
  ) {
    return MaterialPageRoute<T>(
      builder: (_) => page,
      settings: settings,
    );
  }
}
