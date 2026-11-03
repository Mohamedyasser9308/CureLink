import 'package:curelink/core/settings/settings_cubit.dart';
import 'package:curelink/core/router/routes_names.dart';
import 'package:curelink/l10n/app_localizations.dart';
import 'alarm_permissions_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  Future<void> _logOut(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;

    try {
      await FirebaseAuth.instance.signOut();
      if (!context.mounted) return;
      Navigator.of(
        context,
      ).pushNamedAndRemoveUntil(RoutesNames.loginPage, (_) => false);
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(l10n.somethingWentWrong)));
    }
  }

  Future<void> _confirmLogOut(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;

    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),

          icon: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: colorScheme.error.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.logout_rounded,
              size: 28,
              color: colorScheme.error,
            ),
          ),

          title: Text(
            l10n.logOutConfirmTitle,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),

          content: Text(
            l10n.logOutConfirmMessage,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: colorScheme.onSurfaceVariant,
              height: 1.5,
            ),
          ),

          actionsAlignment: MainAxisAlignment.center,
          actionsPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),

          actions: [
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.of(dialogContext).pop(false);
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(l10n.cancel),
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: FilledButton(
                    onPressed: () {
                      Navigator.of(dialogContext).pop(true);
                    },
                    style: FilledButton.styleFrom(
                      backgroundColor: colorScheme.error,
                      foregroundColor: colorScheme.onError,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(l10n.logOut),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );

    if (confirmed == true && context.mounted) {
      await _logOut(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsTitle)),
      body: BlocBuilder<SettingsCubit, SettingsState>(
        builder: (context, settings) {
          final cubit = context.read<SettingsCubit>();

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Card(
                clipBehavior: Clip.antiAlias,
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 6,
                  ),
                  leading: Icon(Icons.alarm, color: colors.primary, size: 28),
                  title: Text(
                    settings.locale.languageCode == 'ar'
                        ? 'صلاحيات المنبه'
                        : 'Alarm permissions',
                    style: theme.textTheme.titleMedium,
                  ),
                  subtitle: Text(
                    settings.locale.languageCode == 'ar'
                        ? 'افحص الإشعارات والمنبه الدقيق وشاشة القفل.'
                        : 'Check notifications, exact alarms, and lock-screen access.',
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const AlarmPermissionsPage(),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                l10n.appearance,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),

              // Dark Mode
              SizedBox(
                width: double.infinity,
                child: SegmentedButton<ThemeMode>(
                  showSelectedIcon: false,
                  segments: [
                    ButtonSegment(
                      value: ThemeMode.light,
                      icon: const Icon(Icons.light_mode_rounded),
                      label: Text(l10n.lightMode),
                    ),
                    ButtonSegment(
                      value: ThemeMode.dark,
                      icon: const Icon(Icons.dark_mode_rounded),
                      label: Text(l10n.darkMode),
                    ),
                    ButtonSegment(
                      value: ThemeMode.system,
                      icon: const Icon(Icons.brightness_auto_outlined),
                      label: Text(l10n.systemMode),
                    ),
                  ],
                  selected: {settings.themeMode},
                  onSelectionChanged: (s) => cubit.setThemeMode(s.first),
                ),
              ),

              const SizedBox(height: 24),

              // Language
              Text(
                l10n.language,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),

              RadioGroup<String>(
                groupValue: settings.locale.languageCode,
                onChanged: (value) {
                  if (value != null) cubit.setLanguage(value);
                },
                child: Column(
                  children: [
                    RadioListTile<String>(
                      value: 'en',
                      secondary: Icon(
                        Icons.language_rounded,
                        color: colors.primary,
                      ),
                      title: Text(
                        l10n.english,
                        style: theme.textTheme.bodyLarge,
                      ),
                    ),
                    SizedBox(height: 8),
                    RadioListTile<String>(
                      value: 'ar',
                      secondary: Icon(
                        Icons.translate_rounded,
                        color: colors.primary,
                      ),
                      title: Text(
                        l10n.arabic,
                        style: theme.textTheme.bodyLarge,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: colors.error,
                  foregroundColor: colors.onError,
                ),
                onPressed: () => _confirmLogOut(context),
                child: Text(l10n.logOut),
              ),
            ],
          );
        },
      ),
    );
  }
}
