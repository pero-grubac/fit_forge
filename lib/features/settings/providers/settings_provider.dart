import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppSettings {
  final double smallIncrement;
  final double largeIncrement;
  final double progressionThreshold;

  /// Rest between sets in seconds; 0 turns the rest timer off.
  final int restSeconds;
  final bool isSetupDone;

  /// Unlocked by tapping the app version 7 times in Settings.
  final bool devMode;
  final String locale;

  const AppSettings({
    this.smallIncrement = 2.5,
    this.largeIncrement = 5.0,
    this.progressionThreshold = 0.95,
    this.restSeconds = 90,
    this.isSetupDone = false,
    this.devMode = false,
    this.locale = 'en',
  });

  AppSettings copyWith({
    double? smallIncrement,
    double? largeIncrement,
    double? progressionThreshold,
    int? restSeconds,
    bool? isSetupDone,
    bool? devMode,
    String? locale,
  }) {
    return AppSettings(
      smallIncrement: smallIncrement ?? this.smallIncrement,
      largeIncrement: largeIncrement ?? this.largeIncrement,
      progressionThreshold: progressionThreshold ?? this.progressionThreshold,
      restSeconds: restSeconds ?? this.restSeconds,
      isSetupDone: isSetupDone ?? this.isSetupDone,
      devMode: devMode ?? this.devMode,
      locale: locale ?? this.locale,
    );
  }
}

class SettingsNotifier extends AsyncNotifier<AppSettings> {
  static const _keySmall = 'small_increment';
  static const _keyLarge = 'large_increment';
  static const _keyThreshold = 'progression_threshold';
  static const _keyRest = 'rest_seconds';
  static const _keySetup = 'is_setup_done';
  static const _keyDevMode = 'dev_mode';
  static const _keyLocale = 'locale';

  @override
  Future<AppSettings> build() async {
    final prefs = await SharedPreferences.getInstance();
    return AppSettings(
      smallIncrement: prefs.getDouble(_keySmall) ?? 2.5,
      largeIncrement: prefs.getDouble(_keyLarge) ?? 5.0,
      progressionThreshold: prefs.getDouble(_keyThreshold) ?? 0.95,
      restSeconds: prefs.getInt(_keyRest) ?? 90,
      isSetupDone: prefs.getBool(_keySetup) ?? false,
      devMode: prefs.getBool(_keyDevMode) ?? false,
      locale: prefs.getString(_keyLocale) ?? 'en',
    );
  }

  Future<void> setSmallIncrement(double v) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_keySmall, v);
    state = AsyncData(state.value!.copyWith(smallIncrement: v));
  }

  Future<void> setLargeIncrement(double v) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_keyLarge, v);
    state = AsyncData(state.value!.copyWith(largeIncrement: v));
  }

  Future<void> setProgressionThreshold(double v) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_keyThreshold, v);
    state = AsyncData(state.value!.copyWith(progressionThreshold: v));
  }

  Future<void> setRestSeconds(int v) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyRest, v);
    state = AsyncData(state.value!.copyWith(restSeconds: v));
  }

  Future<void> setDevMode(bool v) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyDevMode, v);
    state = AsyncData(state.value!.copyWith(devMode: v));
  }

  Future<void> markSetupDone() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keySetup, true);
    state = AsyncData(state.value!.copyWith(isSetupDone: true));
  }

  Future<void> resetAllData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    state = const AsyncData(AppSettings());
  }

  Future<void> setLocale(String locale) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyLocale, locale);
    state = AsyncData(state.value!.copyWith(locale: locale));
  }
}

final settingsProvider =
    AsyncNotifierProvider<SettingsNotifier, AppSettings>(SettingsNotifier.new);

final localeProvider = Provider<Locale>((ref) {
  final settings = ref.watch(settingsProvider);
  return settings.maybeWhen(
    data: (s) => switch (s.locale) {
      'sr_Cyrl' =>
        const Locale.fromSubtags(languageCode: 'sr', scriptCode: 'Cyrl'),
      'sr' => const Locale('sr'),
      _ => const Locale('en'),
    },
    orElse: () => const Locale('en'),
  );
});
