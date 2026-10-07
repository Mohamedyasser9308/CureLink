import 'package:curelink/core/theme/app_theme.dart';
import 'package:curelink/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class CustomOnboardingpage extends StatelessWidget {
  const CustomOnboardingpage({
    super.key,
    required this.controller,
    required this.currentpage,
    required this.title,
    required this.icon,
    required this.description,
  });

  final PageController controller;
  final int currentpage;
  final String title;
  final String description;
  final FaIcon icon;

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
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Illustration
            Container(
              width: double.infinity,
              height: MediaQuery.sizeOf(context).height * 0.38,
              constraints: const BoxConstraints(maxHeight: 380, minHeight: 260),
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
                      child: Center(child: icon),
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Step
            Text(
              l10n.stepOfTotal(currentpage + 1, 3),
              style: theme.textTheme.labelLarge?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w700,
              ),
            ),

            const SizedBox(height: 10),

            // Title
            Text(
              title,
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
              description,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurface.withAlpha(155),
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
