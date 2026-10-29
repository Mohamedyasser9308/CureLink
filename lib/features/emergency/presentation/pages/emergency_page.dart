
import 'package:curelink/core/theme/app_theme.dart';
import 'package:curelink/core/widgets/app_scaffold.dart';
import 'package:curelink/features/emergency/data/repositories/sos_repository.dart';
import 'package:curelink/features/emergency/presentation/cubit/sos_cubit.dart';
import 'package:curelink/features/emergency/presentation/cubit/sos_state.dart';
import 'package:curelink/features/emergency/presentation/widgets/emergency_button.dart';
import 'package:curelink/l10n/app_localizations.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class EmergencyPage extends StatelessWidget {
  const EmergencyPage({super.key, this.sosAvailable = true});

  final bool sosAvailable;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => SosCubit(repository: SosRepository()),
      child: _EmergencyView(sosAvailable: sosAvailable),
    );
  }
}

class _EmergencyView extends StatefulWidget {
  const _EmergencyView({required this.sosAvailable});

  final bool sosAvailable;

  @override
  State<_EmergencyView> createState() => _EmergencyViewState();
}

class _EmergencyViewState extends State<_EmergencyView> {
  SosVisualState _visualState = SosVisualState.idle;
  String _instruction(BuildContext context, SosState state) {
    final l10n = AppLocalizations.of(context)!;

    if (!widget.sosAvailable) {
      return l10n.sosUnavailable;
    }

    switch (state.status) {
      case SosStatusType.initial:
        return l10n.sosPressAndHold;
      case SosStatusType.loading:
        return 'Activating emergency SOS...';
      case SosStatusType.pending:
        return 'SOS request recorded. Waiting for the notification service to respond...';
      case SosStatusType.sent:
        return 'The notification service accepted the SOS alert for the connected caregivers.';
      case SosStatusType.partiallySent:
        return 'The notification service accepted the alert for some caregivers only.';
      case SosStatusType.failure:
        return state.errorMessage ?? 'Failed to send SOS. Please retry.';
      case SosStatusType.verificationFailed:
        return state.errorMessage ??
            'SOS status could not be confirmed. Please retry.';
    }
  }

  Future<void> _retry() async {
    await context.read<SosCubit>().retrySos();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final textColor =
        isDark ? AppTheme.darkTextPrimary : AppTheme.navy;
    final mutedTextColor =
        isDark ? AppTheme.darkTextSecondary : const Color(0xFF647A98);

    return BlocBuilder<SosCubit, SosState>(
      builder: (context, state) {
        final isBusy =
            state.status == SosStatusType.loading ||
            state.status == SosStatusType.pending;

        final showRetry =
            state.status == SosStatusType.failure ||
            state.status == SosStatusType.verificationFailed;

        final resultColor = switch (state.status) {
          SosStatusType.sent => Colors.green.shade700,
          SosStatusType.partiallySent => Colors.orange.shade800,
          SosStatusType.failure ||
          SosStatusType.verificationFailed => AppTheme.destructive,
          _ => textColor,
        };

        final resultIcon = switch (state.status) {
          SosStatusType.sent => Icons.check_circle_outline_rounded,
          SosStatusType.partiallySent => Icons.warning_amber_rounded,
          SosStatusType.failure ||
          SosStatusType.verificationFailed => Icons.error_outline_rounded,
          SosStatusType.pending ||
          SosStatusType.loading => Icons.sync_rounded,
          SosStatusType.initial => Icons.info_outline_rounded,
        };

        return AppScaffold(
          title: l10n.emergencySos,
          scrollable: true,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          body: Padding(
            padding: const EdgeInsets.only(top: 12, bottom: 24),
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
                        onVisualStateChanged: (value) {
                          if (!mounted || _visualState == value) return;

                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            if (!mounted || _visualState == value) return;
                            setState(() => _visualState = value);
                          });
                        },
                        onHoldCompleted: () {
                          context.read<SosCubit>().activateSos();
                        },
                      );
                    },
                  ),
                ),
                const SizedBox(height: 14),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: resultColor.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: resultColor.withValues(alpha: 0.25),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(resultIcon, color: resultColor, size: 24),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          _instruction(context, state),
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: resultColor,
                            fontSize: 15,
                            height: 1.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (isBusy) ...[
                  const SizedBox(height: 16),
                  const Center(child: CircularProgressIndicator()),
                ],
                if (showRetry) ...[
                  const SizedBox(height: 16),
                  Center(
                    child: OutlinedButton.icon(
                      onPressed: _retry,
                      icon: const Icon(Icons.refresh_rounded),
                      label: Text(l10n.retry),
                    ),
                  ),
                ],
                const SizedBox(height: 28),
                _SectionHeading(title: l10n.connectedCaregivers),
                const SizedBox(height: 12),
                _ConnectedCaregivers(
                  mutedTextColor: mutedTextColor,
                  theme: theme,
                ),
                const SizedBox(height: 20),
                _SectionHeading(title: l10n.emergencyContact),
                const SizedBox(height: 12),
                _EmergencyContact(
                  mutedTextColor: mutedTextColor,
                  theme: theme,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ConnectedCaregivers extends StatelessWidget {
  const _ConnectedCaregivers({
    required this.mutedTextColor,
    required this.theme,
  });

  final Color mutedTextColor;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Text(
        'Sign in to view connected caregivers.',
        style: theme.textTheme.bodyMedium?.copyWith(color: mutedTextColor),
      );
    }

    return StreamBuilder<List<Map<String, String>>>(
      stream: SosRepository().watchAcceptedCaregiverDetails(user.uid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting &&
            !snapshot.hasData) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(8),
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (snapshot.hasError) {
          return Text(
            'Unable to load connected caregivers.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppTheme.destructive,
            ),
          );
        }

        final caregivers = snapshot.data ?? [];

        if (caregivers.isEmpty) {
          return Text(
            'No connected caregivers yet.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: mutedTextColor,
              height: 1.5,
            ),
          );
        }

        return Column(
          children: caregivers.map((caregiver) {
            final name = caregiver['name'] ?? 'Caregiver';
            final phone = caregiver['phone'] ?? '';

            return Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                // Use CureLink's warm ivory instead of a pure-white card.
                color: AppTheme.background,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: mutedTextColor.withValues(alpha: 0.20),
                ),
              ),
              child: Row(
                children: [
                  const CircleAvatar(
                    backgroundColor: Color(0xFFEDE5F2),
                    child: Icon(
                      Icons.person_outline_rounded,
                      color: AppTheme.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: AppTheme.navy,
                          ),
                        ),
                        if (phone.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            phone,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: mutedTextColor,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        );
      },
    );
  }
}

class _EmergencyContact extends StatelessWidget {
  const _EmergencyContact({
    required this.mutedTextColor,
    required this.theme,
  });

  final Color mutedTextColor;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Text(
        'Sign in to view emergency contact information.',
        style: theme.textTheme.bodyMedium?.copyWith(color: mutedTextColor),
      );
    }

    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting &&
            !snapshot.hasData) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Center(
              child: SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          );
        }

        if (snapshot.hasError) {
          return Text(
            'Unable to load emergency contact details.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppTheme.destructive,
            ),
          );
        }

        final data = snapshot.data?.data();
        final nestedContact = data?['emergencyContact'];
        final contactMap = nestedContact is Map<String, dynamic>
            ? nestedContact
            : <String, dynamic>{};
        // ProfileService saves the contact as a nested map; keep flat-field
        // fallbacks for profiles created by older app versions.
        final contactName =
            ((contactMap['name'] as String?) ??
                    (data?['emergencyContactName'] as String?) ??
                    '')
                .trim();
        final contactPhone =
            ((contactMap['phone'] as String?) ??
                    (data?['emergencyContactPhone'] as String?) ??
                    '')
                .trim();

        if (contactName.isEmpty || contactPhone.isEmpty) {
          return Text(
            'No emergency contact added yet.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: mutedTextColor,
              height: 1.5,
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              contactName,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: AppTheme.navy,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              contactPhone,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: mutedTextColor,
              ),
            ),
          ],
        );
      },
    );
  }
}

class _SectionHeading extends StatelessWidget {
  const _SectionHeading({required this.title});

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
      ),
    );
  }
}
