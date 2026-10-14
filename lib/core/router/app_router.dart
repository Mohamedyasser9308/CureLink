
import 'package:curelink/core/router/routes_names.dart';
import 'package:curelink/features/auth/forgot_password/presentation/cubit/forgot_password_cubit.dart';
import 'package:curelink/features/auth/forgot_password/presentation/forgot_password_page.dart';
import 'package:curelink/features/auth/login/cubit/login_cubit.dart';
import 'package:curelink/features/auth/login/ui/login_screen.dart';
import 'package:curelink/features/auth/signup/presentation/cubit/signup_cubit.dart';
import 'package:curelink/features/auth/signup/presentation/signup_page.dart';
import 'package:curelink/features/emergency/presentation/emergency_page.dart';
import 'package:curelink/features/medication/data/models/medication_model.dart';
import 'package:curelink/features/medication/presentation/add_medicine_page.dart';
import 'package:curelink/features/medication/presentation/medicine_details_page.dart';
import 'package:curelink/features/profile/presentation/pages/complete_profile_page.dart';
import 'package:curelink/features/role_selction/age_group_page.dart';
import 'package:curelink/features/role_selction/role_page.dart';
import 'package:curelink/features/role_selction/signup_args_placeholder.dart';
import 'package:curelink/features/shell/presentation/main_shell.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AppRouter {
  AppRouter._();

  static final Map<String, WidgetBuilder> routes = {
    RoutesNames.homePage: (_) => const MainShell(),

    RoutesNames.loginPage: (_) => BlocProvider(
          create: (_) => LoginCubit(),
          child: const LoginScreen(),
        ),

    RoutesNames.signUpPage: (_) => BlocProvider(
          create: (_) => SignupCubit(),
          child: const SignupPage(),
        ),

    RoutesNames.forgotPasswordPage: (_) => BlocProvider(
          create: (_) => ForgotPasswordCubit(),
          child: const ForgotPasswordPage(),
        ),

    // Add Medicine
    RoutesNames.addMedicine: (_) => const AddMedicinePage(),

    RoutesNames.emergency: (_) => const EmergencyPage(),
  };

  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case RoutesNames.ageGroupPage:
        final args = settings.arguments;

        if (args is! String) {
          return _buildRoute(
            BlocProvider(
              create: (_) => SignupCubit(),
              child: const SignupPage(),
            ),
            settings,
          );
        }

        return _buildRoute(
          AgeGroupPage(name: args),
          settings,
        );

      case RoutesNames.rolePage:
        final args = settings.arguments;

        if (args is! SignUpArgs) {
          return _buildRoute(
            BlocProvider(
              create: (_) => SignupCubit(),
              child: const SignupPage(),
            ),
            settings,
          );
        }

        return _buildRoute(
          RolePage(args: args),
          settings,
        );

      case RoutesNames.completeProfilePage:
        final args = settings.arguments;

        if (args is! SignUpArgs) {
          return _buildRoute(
            BlocProvider(
              create: (_) => SignupCubit(),
              child: const SignupPage(),
            ),
            settings,
          );
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

        if (medication is! MedicationModel) {
          return _buildRoute(
            Scaffold(
              appBar: AppBar(
                title: const Text('Medicine details'),
              ),
              body: const Center(
                child: Text('Medication details are unavailable.'),
              ),
            ),
            settings,
          );
        }

        return _buildRoute(
          MedicineDetailsPage(
            medication: medication,
          ),
          settings,
        );

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
            textAlign: TextAlign.center,
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
