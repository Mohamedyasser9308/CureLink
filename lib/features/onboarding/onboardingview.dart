import 'package:curelink/core/router/routes_names.dart';
import 'package:curelink/core/widgets/app_scaffold.dart';
import 'package:curelink/features/onboarding/presentation/model/onboarding_page_modle.dart';
import 'package:curelink/features/onboarding/presentation/widgets/custom_onboarding_page.dart';
import 'package:curelink/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../core/theme/app_theme.dart';
import 'presentation/widgets/onboardingindicator.dart';

class OnboardingView extends StatefulWidget {
  const OnboardingView({super.key});

  @override
  State<OnboardingView> createState() => _OnboardingViewState();
}

class _OnboardingViewState extends State<OnboardingView> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  static const int _pagesCount = 3;
  bool get _isLastPage => _currentPage == _pagesCount - 1;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goToLogin() {
    Navigator.pushReplacementNamed(context, RoutesNames.loginPage);
  }

  void _next() {
    if (_isLastPage) {
      _goToLogin();
    } else {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    final pages = <OnboardingData>[
      OnboardingData(
        title: l10n.onboardingTitle1,
        description: l10n.onboardingSubtitle1,
        icon: FaIcon(
          FontAwesomeIcons.alarmClock,
          size: 58,
          color: AppTheme.primary,
        ),
      ),
      OnboardingData(
        title: l10n.onboardingTitle2,
        description: l10n.onboardingSubtitle2,
        icon: FaIcon(
          FontAwesomeIcons.capsules,
          size: 58,
          color: AppTheme.primary,
        ),
      ),
      OnboardingData(
        title: l10n.onboardingTitle3,
        description: l10n.onboardingSubtitle3,
        icon: FaIcon(FontAwesomeIcons.link, size: 58, color: AppTheme.primary),
      ),
    ];

    return AppScaffold(
      showAppBar: false,
      padding: EdgeInsets.zero,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: pages.length,
                    onPageChanged: (value) =>
                        setState(() => _currentPage = value),
                    itemBuilder: (context, index) {
                      final page = pages[index];
                      return CustomOnboardingpage(
                        controller: _pageController,
                        currentpage: _currentPage,
                        title: page.title,
                        description: page.description,
                        icon: page.icon,
                      );
                    },
                  ),
                ),

                // Indicator
                OnboardingIndicator(
                  count: pages.length,
                  currentIndex: _currentPage,
                  activeColor: theme.colorScheme.primary,
                  inactiveColor: theme.colorScheme.primary.withValues(
                    alpha: 0.2,
                  ),
                ),
                const SizedBox(height: 32),

                // Next / Get started button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: FilledButton(
                      onPressed: _next,
                      style: FilledButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 200),
                            child: Text(
                              _isLastPage ? l10n.getStarted : l10n.next,
                              key: ValueKey(_isLastPage),
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: theme.colorScheme.onPrimary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(Icons.arrow_forward_rounded),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),

            // Skip button (hidden on last page)
            PositionedDirectional(
              top: 12,
              end: 24,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 200),
                opacity: _isLastPage ? 0 : 1,
                child: IgnorePointer(
                  ignoring: _isLastPage,
                  child: TextButton(
                    onPressed: _goToLogin,
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
            ),
          ],
        ),
      ),
    );
  }
}
