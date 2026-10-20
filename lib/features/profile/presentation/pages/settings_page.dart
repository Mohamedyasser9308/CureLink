
import 'package:curelink/core/settings/settings_cubit.dart';
import 'package:curelink/core/router/routes_names.dart';
import 'package:curelink/l10n/app_localizations.dart';
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
      Navigator.of(context).pushNamedAndRemoveUntil(
        RoutesNames.loginPage,
        (_) => false,
      );
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(content: Text(l10n.somethingWentWrong)),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settingsTitle),
      ),
      body: BlocBuilder<SettingsCubit, SettingsState>(
        builder: (context, settings) {
          final cubit = context.read<SettingsCubit>();

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Text(
                l10n.appearance,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),

              // Dark Mode
              Card(
                clipBehavior: Clip.antiAlias,
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 6,
                  ),
                  leading: Icon(
                    settings.isDarkMode
                        ? Icons.dark_mode_rounded
                        : Icons.light_mode_rounded,
                    color: colors.primary,
                    size: 28,
                  ),
                  title: Text(
                    l10n.darkMode,
                    style: theme.textTheme.titleMedium,
                  ),
                  subtitle: Text(
                    l10n.darkModeSubtitle,
                    style: theme.textTheme.bodySmall,
                  ),
                  trailing: Switch.adaptive(
                    value: settings.isDarkMode,
                    onChanged: (value) {
                      cubit.toggleDarkMode(value);
                    },
                  ),
                  onTap: () {
                    cubit.toggleDarkMode(!settings.isDarkMode);
                  },
                ),
              ),

              const SizedBox(height: 8),

              Align(
                alignment: AlignmentDirectional.centerStart,
                child: TextButton.icon(
                  onPressed: cubit.useSystemTheme,
                  icon: const Icon(Icons.brightness_auto_outlined),
                  label: Text(l10n.useSystemTheme),
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

              Card(
                clipBehavior: Clip.antiAlias,
                child: Column(
                  children: [
                    RadioListTile<String>(
                      value: 'en',
                      groupValue: settings.locale.languageCode,
                      secondary: Icon(
                        Icons.language_rounded,
                        color: colors.primary,
                      ),
                      title: Text(
                        l10n.english,
                        style: theme.textTheme.bodyLarge,
                      ),
                      onChanged: (value) {
                        if (value != null) {
                          cubit.setLanguage(value);
                        }
                      },
                    ),
                    Divider(
                      height: 1,
                      indent: 16,
                      endIndent: 16,
                      color: colors.outlineVariant,
                    ),
                    RadioListTile<String>(
                      value: 'ar',
                      groupValue: settings.locale.languageCode,
                      secondary: Icon(
                        Icons.translate_rounded,
                        color: colors.primary,
                      ),
                      title: Text(
                        l10n.arabic,
                        style: theme.textTheme.bodyLarge,
                      ),
                      onChanged: (value) {
                        if (value != null) {
                          cubit.setLanguage(value);
                        }
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              Card(
                clipBehavior: Clip.antiAlias,
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 6,
                  ),
                  leading: Icon(
                    Icons.logout_rounded,
                    color: colors.error,
                    size: 26,
                  ),
                  title: Text(
                    l10n.logOut,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: colors.error,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  onTap: () => _logOut(context),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
