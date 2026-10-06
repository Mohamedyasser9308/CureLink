import 'package:curelink/core/theme/app_theme.dart';
import 'package:curelink/features/onboarding/onboardingindicator.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class Onboardingpage3 extends StatelessWidget {
  final PageController controller;
  final int currentpage;
  Onboardingpage3({required this.controller, required this.currentpage});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          SizedBox(height: 30),
          Container(
            width: 400,
            height: 400,
            child: Center(
              child: CircleAvatar(
                child: FaIcon(
                  FontAwesomeIcons.link,
                  color: AppTheme.primary,
                  size: 80,
                ),
                radius: 80,
                backgroundColor: AppTheme.cyan,
              ),
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              color: AppTheme.mint,
            ),
          ),
          SizedBox(height: 15),
          Text(
            'Step 3 of 3',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.cyan,
            ),
          ),
          SizedBox(height: 10),
          Text(
            textAlign: TextAlign.center,
            'Stay connected with caregivers',
            style: TextStyle(height: 1.1, color: AppTheme.navy, fontSize: 28),
          ),
          SizedBox(height: 10),
          Text(
            'Share only what you apprrove',
            style: TextStyle(fontSize: 18, color: AppTheme.lightTextSecondary),
          ),
          SizedBox(height: 10),
          OnboardingIndicator(currentPage: currentpage),
          SizedBox(height: 15),
          GestureDetector(
            onTap: () {
              Navigator.pushNamed(context, '/login');
            },
            child: Container(
              width: double.infinity,
              height: 60,
              decoration: BoxDecoration(
                color: AppTheme.primary,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.arrow_forward, color: Colors.white),
                  SizedBox(width: 10),
                  Text(
                    'Get started',
                    style: TextStyle(color: Colors.white, fontSize: 24),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
