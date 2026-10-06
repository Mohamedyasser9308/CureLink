import 'package:curelink/core/theme/app_theme.dart';
import 'package:curelink/features/onboarding/presentation/onboardingview.dart';
import 'package:flutter/material.dart';

class Splashscreen extends StatefulWidget {
  @override
  State<Splashscreen> createState() => _SplashscreenState();
}

class _SplashscreenState extends State<Splashscreen> {
  @override
  void initState() {
    super.initState();
    goToOnboarding();
  }

  Future<void> goToOnboarding() async {
    await Future.delayed(const Duration(seconds: 3));

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => Onboardingview()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset('assets/curelink.jpg'),
          SizedBox(height: 15),
          Text(
            'Care that stays connected',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: AppTheme.navy,
            ),
          ),
        ],
      ),
    );
  }
}
