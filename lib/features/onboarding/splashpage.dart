
import 'package:curelink/core/auth/session_service.dart';
import 'package:curelink/core/router/routes_names.dart';
import 'package:curelink/core/router/app_router.dart';
import 'package:curelink/core/services/dose_notification_service.dart';
import 'package:curelink/core/theme/app_theme.dart';
import 'package:curelink/l10n/app_localizations.dart';
import 'package:curelink/features/onboarding/onboardingview.dart';
import 'package:flutter/material.dart';

class Splashscreen extends StatefulWidget {
  const Splashscreen({super.key});

  @override
  State<Splashscreen> createState() => _SplashscreenState();
}

class _SplashscreenState extends State<Splashscreen> {
  final SessionService _session = SessionService();
  String? _sessionError;
  bool _isResolving = false;

  @override
  void initState() {
    super.initState();
    _resolveSession();
  }

  Future<void> _resolveSession() async {
    if (_isResolving) return;
    _isResolving = true;
    if (_sessionError != null) setState(() => _sessionError = null);
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) {
      _isResolving = false;
      return;
    }

    final user = _session.currentUser;

    if (user == null) {
      DoseNotificationService.instance.takeInitialPayload();
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => OnboardingView()),
      );
      return;
    }

    try {
      final profile = await _session.getCurrentUserProfile();

      if (!mounted) return;

      if (profile == null) {
        DoseNotificationService.instance.takeInitialPayload();
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
        _openInitialReminderAfterHome();
        return;
      }

      final name = profile['name'] as String? ?? '';
      final role = profile['role'] as String? ?? '';
      final ageGroup = profile['ageGroup'] as String? ?? '';

      if (name.isNotEmpty && role.isNotEmpty && ageGroup.isNotEmpty) {
        DoseNotificationService.instance.takeInitialPayload();
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
      DoseNotificationService.instance.takeInitialPayload();
      Navigator.of(context).pushNamedAndRemoveUntil(
        RoutesNames.loginPage,
        (_) => false,
      );
    } catch (_) {
      if (!mounted) return;
      _isResolving = false;
      setState(() => _sessionError = AppLocalizations.of(context)!.noInternetConnection);
    }
  }

  void _openInitialReminderAfterHome() {
    final payload = DoseNotificationService.instance.takeInitialPayload();
    if (payload == null || payload.isEmpty) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      AppRouter.navigatorKey.currentState?.pushNamed(
        RoutesNames.medicationReminder,
        arguments: payload,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_sessionError != null) {
      final l10n = AppLocalizations.of(context)!;
      return Scaffold(
        backgroundColor: AppTheme.background,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.cloud_off_outlined, size: 48),
                const SizedBox(height: 16),
                Text(_sessionError!, textAlign: TextAlign.center),
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: _isResolving ? null : _resolveSession,
                  icon: const Icon(Icons.refresh),
                  label: Text(l10n.retry),
                ),
              ],
            ),
          ),
        ),
      );
    }

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
