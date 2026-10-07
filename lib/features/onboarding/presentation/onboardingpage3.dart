import 'package:curelink/core/router/routes_names.dart';
import 'package:curelink/core/theme/app_theme.dart';
import 'package:curelink/core/widgets/app_button.dart';
import 'package:curelink/features/onboarding/onboardingindicator.dart';
import 'package:curelink/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class Onboardingpage3 extends StatelessWidget {
  const Onboardingpage3({
    super.key,
    required this.controller,
    required this.currentpage,
  });

  final PageController controller;
  final int currentpage;

  void _getStarted(BuildContext context) {
    Navigator.pushReplacementNamed(
      context,
      RoutesNames.loginPage,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    final titleColor = theme.brightness == Brightness.light
        ? AppTheme.navy
        : theme.colorScheme.onSurface;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
        child: Column(
          children: [
            const Spacer(),

            // Illustration
            Container(
              width: double.infinity,
              height: MediaQuery.sizeOf(context).height * 0.38,
              constraints: const BoxConstraints(
                maxHeight: 380,
                minHeight: 260,
              ),
              decoration: BoxDecoration(
                color: AppTheme.mint.withAlpha(
                  theme.brightness == Brightness.light ? 255 : 35,
                ),
                borderRadius: BorderRadius.circular(32),
              ),
              child: Center(
                child: Container(
                  width: 170,
                  height: 170,
                  decoration: BoxDecoration(
                    color: AppTheme.cyan.withAlpha(45),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Container(
                      width: 135,
                      height: 135,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            blurRadius: 30,
                            spreadRadius: 2,
                            color: AppTheme.primary.withAlpha(30),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: FaIcon(
                          FontAwesomeIcons.link,
                          size: 58,
                          color: AppTheme.primary,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Step
            Text(
              l10n.stepOfTotal(3, 3),
              style: theme.textTheme.labelLarge?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w700,
              ),
            ),

            const SizedBox(height: 10),

            // Title
            Text(
              l10n.onboardingTitle3,
              textAlign: TextAlign.center,
              style: theme.textTheme.headlineMedium?.copyWith(
                color: titleColor,
                fontWeight: FontWeight.w800,
                height: 1.15,
                letterSpacing: -0.5,
              ),
            ),

            const SizedBox(height: 10),

            // Description
            Text(
              l10n.onboardingSubtitle3,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurface.withAlpha(155),
                height: 1.5,
              ),
            ),

            const SizedBox(height: 20),

            // Indicator
            OnboardingIndicator(
              currentPage: currentpage,
            ),

            const Spacer(),

            // Get Started Button
            SizedBox(
              width: double.infinity,
              child: AppButton(
                label: l10n.getStarted,
                icon: Directionality.of(context) == TextDirection.rtl
                    ? Icons.arrow_back_rounded
                    : Icons.arrow_forward_rounded,
                onPressed: () => _getStarted(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}