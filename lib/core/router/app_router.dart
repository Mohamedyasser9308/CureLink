import 'package:curelink/features/auth/presentation/signup_page.dart';
import 'package:flutter/material.dart';

import '../../features/emergency/presentation/emergency_page.dart';
import '../../features/forgot_password/presentation/forgot_password_page.dart';
import '../../features/home/data/models/medication_model.dart';
import '../../features/login/ui/login_screen.dart';
import '../../features/medication/presentation/add_medicine_page.dart';
import '../../features/medication/presentation/medicine_details_page.dart';
import '../../features/profile/presentation/pages/complete_profile_page.dart';
import '../../features/role_selction/age_group_page.dart';
import '../../features/role_selction/role_page.dart';
import '../../features/role_selction/signup_args_placeholder.dart';
import '../../features/shell/presentation/main_shell.dart';
import 'routes_names.dart';

class AppRouter {
  AppRouter._();

  static final Map<String, WidgetBuilder> routes = {
    RoutesNames.homePage: (_) => const MainShell(),
    RoutesNames.loginPage: (_) => const LoginScreen(),
    RoutesNames.signUpPage: (_) => const SignupPage(),
    RoutesNames.forgotPasswordPage: (_) => const ForgotPasswordPage(),
    RoutesNames.addMedicine: (_) => const AddMedicinePage(),
    RoutesNames.emergency: (_) => const EmergencyPage(),
  };

  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case RoutesNames.ageGroupPage:
        final name = settings.arguments;

        if (name is! String) {
          return _buildRoute(const SignupPage(), settings);
        }

        return _buildRoute(AgeGroupPage(name: name), settings);

      case RoutesNames.rolePage:
        final args = settings.arguments;

        if (args is! SignUpArgs) {
          return _buildRoute(const SignupPage(), settings);
        }

        return _buildRoute(RolePage(args: args), settings);

      case RoutesNames.completeProfilePage:
        final args = settings.arguments;

        if (args is! SignUpArgs) {
          return _buildRoute(const SignupPage(), settings);
        }

        return _buildRoute(
          CompleteProfilePage(
            name: args.name,
            role: args.role.value,
            ageGroup: args.ageGroup.value,
          ),
          settings,
        );

      case RoutesNames.medicineDetails:
        final medication = settings.arguments;

        // Falls through to onUnknownRoute if no medication was passed.
        if (medication is! MedicationModel) return null;

        return _buildRoute(
          MedicineDetailsPage(medication: medication),
          settings,
        );

      default:
        return null;
    }
  }

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
