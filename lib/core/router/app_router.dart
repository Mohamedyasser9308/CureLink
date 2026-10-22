import 'package:curelink/core/router/routes_names.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:curelink/features/auth/forgot_password/presentation/cubit/forgot_password_cubit.dart';
import 'package:curelink/features/auth/forgot_password/presentation/forgot_password_page.dart';
import 'package:curelink/features/auth/login/cubit/login_cubit.dart';
import 'package:curelink/features/auth/login/ui/login_screen.dart';
import 'package:curelink/features/auth/signup/presentation/cubit/signup_cubit.dart';
import 'package:curelink/features/auth/signup/presentation/signup_page.dart';
import 'package:curelink/features/emergency/presentation/emergency_page.dart';
import 'package:curelink/features/medicine_details/presentation/medicine_details_page.dart';
import 'package:curelink/features/profile/presentation/pages/complete_profile_page.dart';
import 'package:curelink/features/role_selction/age_group_page.dart';
import 'package:curelink/features/role_selction/role_page.dart';
import 'package:curelink/features/role_selction/signup_args_placeholder.dart';

import 'package:curelink/core/auth/session_gate.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../features/add_medication/data/models/medication_model.dart';
import '../../features/add_medication/presentation/add_medicine_page.dart';
import '../../features/schedule/presentation/pages/medication_reminder_page.dart';

class AppRouter {
  AppRouter._();

  static final navigatorKey = GlobalKey<NavigatorState>();

  static final Map<String, WidgetBuilder> routes = {
    RoutesNames.homePage: (_) => const SessionGate(),

    RoutesNames.loginPage: (_) =>
        BlocProvider(create: (_) => LoginCubit(), child: const LoginScreen()),

    RoutesNames.signUpPage: (_) =>
        BlocProvider(create: (_) => SignupCubit(), child: const SignupPage()),

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
            BlocProvider<SignupCubit>(
              create: (_) => SignupCubit(),
              child: const SignupPage(),
            ),
            settings,
          );
        }

        return _buildRoute(AgeGroupPage(name: args), settings);

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

        return _buildRoute(RolePage(args: args), settings);

      case RoutesNames.completeProfilePage:
        final args = settings.arguments;

        if (args is SignUpArgs) {
          return _buildRoute(
            CompleteProfilePage(
              name: args.name,
              role: args.role.value,
              ageGroup: args.ageGroup.value,
            ),
            settings,
          );
        }

        if (args is Map<String, dynamic>) {
          final name = args['name'];
          final role = args['role'];
          final ageGroup = args['ageGroup'];

          if (name is String && role is String && ageGroup is String) {
            return _buildRoute(
              CompleteProfilePage(name: name, role: role, ageGroup: ageGroup),
              settings,
            );
          }
        }

        return _buildRoute(
          Scaffold(
            appBar: AppBar(title: const Text('Complete profile')),
            body: const Center(
              child: Text('Profile information is unavailable.'),
            ),
          ),
          settings,
        );

      case RoutesNames.medicineDetails:
        final medication = settings.arguments;
        final patientId = FirebaseAuth.instance.currentUser?.uid;

        if (medication is! MedicationModel || patientId == null) {
          return _buildRoute(
            Scaffold(
              appBar: AppBar(title: const Text('Medicine details')),
              body: const Center(
                child: Text('Medication details are unavailable.'),
              ),
            ),
            settings,
          );
        }

        return _buildRoute(
          MedicineDetailsPage(
            patientId: patientId,
            medicationId: medication.id,
          ),
          settings,
        );
      case RoutesNames.medicationReminder:
        final payload = settings.arguments;
        if (payload is String) {
          return _buildRoute(MedicationReminderPage(payload: payload), settings);
        }
        return _buildRoute(const Scaffold(body: Center(child: Text('Dose details are unavailable.'))), settings);
    }
    return null;
  }

  static Route<dynamic> onUnknownRoute(RouteSettings settings) {
    return _buildRoute(
      Scaffold(
        appBar: AppBar(title: const Text('Page not found')),
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
    return MaterialPageRoute<T>(builder: (_) => page, settings: settings);
  }
}
