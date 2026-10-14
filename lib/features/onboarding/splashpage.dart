
import 'package:curelink/core/auth/session_service.dart';
import 'package:curelink/core/router/routes_names.dart';
import 'package:curelink/core/theme/app_theme.dart';
import 'package:curelink/features/onboarding/onboardingview.dart';
import 'package:flutter/material.dart';

class Splashscreen extends StatefulWidget {
  const Splashscreen({super.key});

  @override
  State<Splashscreen> createState() => _SplashscreenState();
}

class _SplashscreenState extends State<Splashscreen> {
  final SessionService _session = SessionService();

  @override
  void initState() {
    super.initState();
    _resolveSession();
  }

  Future<void> _resolveSession() async {
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;

    final user = _session.currentUser;

    if (user == null) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => OnboardingView()),
      );
      return;
    }

    try {
      final profile = await _session.getCurrentUserProfile();

      if (!mounted) return;

      if (profile == null) {
        // The Auth account exists, but its Firestore profile is missing.
        Navigator.of(context).pushNamedAndRemoveUntil(
          RoutesNames.loginPage,
          (_) => false,
        );
        return;
      }

      if (profile['profileCompleted'] == true) {
        Navigator.of(context).pushNamedAndRemoveUntil(
          RoutesNames.homePage,
          (_) => false,
        );
        return;
      }

      final name = profile['name'] as String? ?? '';
      final role = profile['role'] as String? ?? '';
      final ageGroup = profile['ageGroup'] as String? ?? '';

      if (name.isNotEmpty && role.isNotEmpty && ageGroup.isNotEmpty) {
        Navigator.of(context).pushNamedAndRemoveUntil(
          RoutesNames.completeProfilePage,
          (_) => false,
          arguments: {
            'name': name,
            'role': role,
            'ageGroup': ageGroup,
          },
        );
        return;
      }

      // Incomplete profile without enough information to open
      // CompleteProfilePage safely.
      Navigator.of(context).pushNamedAndRemoveUntil(
        RoutesNames.loginPage,
        (_) => false,
      );
    } catch (_) {
      if (!mounted) return;

      // Do not sign out just because Firestore is temporarily unavailable.
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Could not verify your session. Please check your connection.',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/curelink.jpg'),
            const SizedBox(height: 15),
            Text(
              'Care that stays connected',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: AppTheme.navy,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
