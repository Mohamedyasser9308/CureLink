
import 'package:curelink/core/theme/app_theme.dart';
import 'package:curelink/core/widgets/app_scaffold.dart';
import 'package:curelink/features/emergency/presentation/widgets/emergency_button.dart';
import 'package:curelink/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

/// SOS presentation only. Request handling and caregiver data are integrated separately.
class EmergencyPage extends StatefulWidget {
  const EmergencyPage({
    super.key,
    this.sosAvailable = true,
  });

  /// Temporary presentation flag; do not connect to backend until its contract is ready.
  final bool sosAvailable;

  @override
  State<EmergencyPage> createState() => _EmergencyPageState();
}

class _EmergencyPageState extends State<EmergencyPage> {
  late SosVisualState _visualState;

  @override
  void initState() {
    super.initState();

    _visualState = widget.sosAvailable
        ? SosVisualState.idle
        : SosVisualState.unavailable;
  }

  String _instruction(AppLocalizations l10n) {
    switch (_visualState) {
      case SosVisualState.idle:
        return l10n.sosPressAndHold;

      case SosVisualState.holding:
        return l10n.sosPressAndHold;

      case SosVisualState.result:
        return l10n.sosConceptualResult;

      case SosVisualState.unavailable:
        return l10n.sosUnavailable;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final textColor =
        isDark ? AppTheme.darkTextPrimary : AppTheme.navy;

    final mutedTextColor = isDark
        ? AppTheme.darkTextSecondary
        : const Color(0xFF647A98);

    return AppScaffold(
      title: l10n.emergencySos,
      scrollable: true,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      body: Padding(
        padding: const EdgeInsets.only(
          top: 12,
          bottom: 24,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFFFCE9EC),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Text(
                l10n.emergencyWarning,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppTheme.navy,
                  fontSize: 14,
                  height: 1.5,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),

            const SizedBox(height: 24),

            Center(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final buttonSize =
                      (constraints.maxWidth * 0.60)
                          .clamp(150.0, 168.0)
                          .toDouble();

                  return SosButton(
                    size: buttonSize,
                    available: widget.sosAvailable,
                    onVisualStateChanged: (state) {
                      if (_visualState != state) {
                        setState(() => _visualState = state);
                      }
                    },
                  );
                },
              ),
            ),

            const SizedBox(height: 14),

            SizedBox(
              width: double.infinity,
              child: Text(
                _instruction(l10n),
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: textColor,
                  fontSize: 16,
                  height: 1.5,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),

            const SizedBox(height: 28),

            _SectionHeading(
              title: l10n.connectedCaregivers,
            ),

            const SizedBox(height: 12),

            Text(
              l10n.caregiverNameStatusPlaceholder,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: mutedTextColor,
                fontSize: 14,
                height: 1.5,
                fontWeight: FontWeight.w400,
              ),
            ),

            const SizedBox(height: 20),

            _SectionHeading(
              title: l10n.emergencyContact,
            ),

            const SizedBox(height: 12),

            Text(
              l10n.emergencyContactPlaceholder,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: mutedTextColor,
                fontSize: 14,
                height: 1.5,
                fontWeight: FontWeight.w400,
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _SectionHeading extends StatelessWidget {
  const _SectionHeading({
    required this.title,
  });

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title.toUpperCase(),
      style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: AppTheme.primary,
            fontSize: 13,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.4,
            height: 1.3,
          ),
    );
  }
}
