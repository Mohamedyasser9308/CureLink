import 'package:curelink/core/router/routes_names.dart';
import 'package:curelink/core/widgets/app_scaffold.dart';
import 'package:curelink/features/onboarding/presentation/onboardingpage1.dart';
import 'package:curelink/features/onboarding/presentation/onboardingpage2.dart';
import 'package:curelink/features/onboarding/presentation/onboardingpage3.dart';
import 'package:curelink/l10n/app_localizations.dart';
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
  void dispose() {
    pagecontroller.dispose();
    super.dispose();
  }

  void _skip() {
    Navigator.pushReplacementNamed(
      context,
      RoutesNames.loginPage,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return AppScaffold(
      showAppBar: false,
      padding: EdgeInsets.zero,
      body: Stack(
        children: [
          PageView(
            controller: pagecontroller,
            onPageChanged: (value) {
              setState(() {
                currentpage = value;
              });
            },
            children: [
              Onboardingpage1(
                controller: pagecontroller,
                currentpage: currentpage,
              ),
              Onboardingpage2(
                controller: pagecontroller,
                currentpage: currentpage,
              ),
              Onboardingpage3(
                controller: pagecontroller,
                currentpage: currentpage,
              ),
            ],
          ),

          // Skip Button
          Positioned(
            top: 12,
            left: 24,
            right: 24,
            child: Align(
              alignment: Directionality.of(context) == TextDirection.rtl
                  ? Alignment.centerLeft
                  : Alignment.centerRight,
              child: TextButton(
                onPressed: _skip,
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  foregroundColor: theme.colorScheme.primary,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  l10n.skip,
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}