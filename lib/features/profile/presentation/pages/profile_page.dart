
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:curelink/core/theme/app_theme.dart';
import 'package:curelink/l10n/app_localizations.dart';
import 'settings_page.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  Future<void> _switchMode(String mode) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .update({'activeMode': mode});
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    if (user == null) {
      return Scaffold(
        body: Center(child: Text(l10n.profileSignInAgain)),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.profileTitle),
        actions: [
          IconButton(
            tooltip: l10n.settingsTitle,
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const SettingsPage(),
              ),
            ),
          ),
        ],
      ),
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  l10n.profileLoadError,
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snapshot.data!.data() ?? {};
          final name = data['name'] as String? ??
              user.displayName ??
              '';
          final email = data['email'] as String? ?? user.email ?? '';
          final phone = data['phone'] as String? ?? '';
          final role = (data['role'] as String? ?? '').toLowerCase();
          final activeMode =
              (data['activeMode'] as String? ?? 'patient').toLowerCase();

          final photoUrl =
              (data['profileImageUrl'] as String?) ??
              (data['photoUrl'] as String?) ??
              user.photoURL;

          final uniqueId = data['uniqueId'] as String? ?? '';

          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.primary,
                      AppTheme.primary.withValues(alpha: 0.78),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 43,
                      backgroundColor: Colors.white,
                      backgroundImage:
                          photoUrl != null && photoUrl.isNotEmpty
                              ? NetworkImage(photoUrl)
                              : null,
                      child: photoUrl == null || photoUrl.isEmpty
                          ? const Icon(
                              Icons.person_outline,
                              size: 46,
                              color: AppTheme.primary,
                            )
                          : null,
                    ),
                    const SizedBox(height: 14),
                    Text(
                      name.isEmpty ? l10n.profileDefaultName : name,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      email,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                    ),
                    if (uniqueId.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 7,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.16),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Text(
                          '${l10n.profileId}: $uniqueId',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Text(
                l10n.profilePersonalInfo,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Card(
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.email_outlined),
                      title: Text(l10n.profileEmail),
                      subtitle: Text(
                        email.isEmpty ? l10n.profileNotSet : email,
                      ),
                    ),
                    const Divider(height: 1, indent: 16, endIndent: 16),
                    ListTile(
                      leading: const Icon(Icons.phone_outlined),
                      title: Text(l10n.profilePhone),
                      subtitle: Text(
                        phone.isEmpty ? l10n.profileNotSet : phone,
                      ),
                    ),
                    const Divider(height: 1, indent: 16, endIndent: 16),
                    ListTile(
                      leading: const Icon(Icons.badge_outlined),
                      title: Text(l10n.profileRole),
                      subtitle: Text(
                        role.isEmpty ? l10n.profileNotSet : role,
                      ),
                    ),
                  ],
                ),
              ),
              if (role == 'both') ...[
                const SizedBox(height: 24),
                Text(
                  l10n.profileActiveMode,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                SegmentedButton<String>(
                  segments: [
                    ButtonSegment(
                      value: 'patient',
                      label: Text(l10n.profilePatient),
                      icon: const Icon(Icons.person_outline),
                    ),
                    ButtonSegment(
                      value: 'caregiver',
                      label: Text(l10n.profileCaregiver),
                      icon: const Icon(Icons.health_and_safety_outlined),
                    ),
                  ],
                  selected: {
                    activeMode == 'caregiver' ? 'caregiver' : 'patient',
                  },
                  onSelectionChanged: (selection) async {
                    try {
                      await _switchMode(selection.first);
                      if (!context.mounted) return;

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(l10n.profileModeUpdated),
                        ),
                      );
                    } catch (_) {
                      if (!context.mounted) return;

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(l10n.profileModeUpdateError),
                        ),
                      );
                    }
                  },
                ),
              ],
              const SizedBox(height: 24),
              Text(
                l10n.appPreferences,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.tune_rounded),
                  title: Text(l10n.settingsTitle),
                  subtitle: Text(l10n.profileSettingsSubtitle),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const SettingsPage(),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
