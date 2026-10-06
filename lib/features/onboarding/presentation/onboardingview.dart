import 'package:curelink/core/theme/app_theme.dart';
import 'package:curelink/features/onboarding/presentation/onboardingpage1.dart';
import 'package:curelink/features/onboarding/presentation/onboardingpage2.dart';
import 'package:curelink/features/onboarding/presentation/onboardingpage3.dart';
import 'package:flutter/material.dart';

class Onboardingview extends StatefulWidget {
  const Onboardingview({super.key});

  @override
  State<Onboardingview> createState() => _OnboardingviewState();
}

class _OnboardingviewState extends State<Onboardingview> {
  final PageController pagecontroller = PageController();
  int currentpage = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, '/login');
              },
              child: Text(
                'Skip',
                style: TextStyle(
                  fontSize: 20,
                  color: AppTheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
      backgroundColor: AppTheme.background,
      body: PageView(
        onPageChanged: (value) {
          setState(() {
            currentpage = value;
          });
        },
        controller: pagecontroller,
        children: [
          Onboardingpage1(controller: pagecontroller, currentpage: currentpage),
          Onboardingpage2(controller: pagecontroller, currentpage: currentpage),
          Onboardingpage3(controller: pagecontroller, currentpage: currentpage),
        ],
      ),
    );
  }
}
