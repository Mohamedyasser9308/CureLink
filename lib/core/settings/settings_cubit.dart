
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsState {
  final ThemeMode themeMode;
  final Locale locale;

  const SettingsState({
    this.themeMode = ThemeMode.system,
    this.locale = const Locale('en'),
  });

  bool get isDarkMode => themeMode == ThemeMode.dark;

  SettingsState copyWith({
    ThemeMode? themeMode,
    Locale? locale,
  }) {
    return SettingsState(
      themeMode: themeMode ?? this.themeMode,
      locale: locale ?? this.locale,
    );
  }
}

class SettingsCubit extends Cubit<SettingsState> {
  SettingsCubit() : super(const SettingsState());

  Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();

    final savedTheme = prefs.getString('themeMode');
    final savedLanguage = prefs.getString('languageCode');

    final themeMode = switch (savedTheme) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };

    final languageCode = savedLanguage == 'ar' ? 'ar' : 'en';

    emit(
      state.copyWith(
        themeMode: themeMode,
        locale: Locale(languageCode),
      ),
    );
  }

  Future<void> toggleDarkMode(bool enabled) async {
    final themeMode = enabled ? ThemeMode.dark : ThemeMode.light;

    emit(state.copyWith(themeMode: themeMode));

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      'themeMode',
      enabled ? 'dark' : 'light',
    );
  }

  Future<void> setLanguage(String languageCode) async {
    if (languageCode != 'ar' && languageCode != 'en') return;

    emit(state.copyWith(locale: Locale(languageCode)));

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('languageCode', languageCode);
  }

  Future<void> useSystemTheme() async {
    emit(state.copyWith(themeMode: ThemeMode.system));

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('themeMode', 'system');
  }
}
