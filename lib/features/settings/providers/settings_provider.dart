import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppSettings {
  /// Raise the weight (or reps/seconds) automatically after enough
  /// successful sets in a row.
  final bool autoProgression;

  /// Default for exercises without their own "sets before increase".
  final int setsToProgress;

  /// Default kg step for weighted exercises without their own increment.
  final double defaultIncrement;

  /// Rest between sets in seconds; 0 turns the rest timer off.
  final int restSeconds;
  final bool isSetupDone;

  /// Unlocked by tapping the app version 7 times in Settings.
  final bool devMode;
  final String locale;

  const AppSettings({
    this.autoProgression = true,
    this.setsToProgress = 8,
    this.defaultIncrement = 2.5,
    this.restSeconds = 90,
    this.isSetupDone = false,
    this.devMode = false,
    this.locale = 'en',
  });

  AppSettings copyWith({
    bool? autoProgression,
    int? setsToProgress,
    double? defaultIncrement,
    int? restSeconds,
    bool? isSetupDone,
    bool? devMode,
    String? locale,
  }) {
    return AppSettings(
      autoProgression: autoProgression ?? this.autoProgression,
      setsToProgress: setsToProgress ?? this.setsToProgress,
      defaultIncrement: defaultIncrement ?? this.defaultIncrement,
      restSeconds: restSeconds ?? this.restSeconds,
      isSetupDone: isSetupDone ?? this.isSetupDone,
      devMode: devMode ?? this.devMode,
      locale: locale ?? this.locale,
    );
  }
}

class SettingsNotifier extends AsyncNotifier<AppSettings> {
  static const _keyAuto = 'auto_progression';
  static const _keySetsToProgress = 'sets_to_progress';
  static const _keyIncrement = 'default_increment';

  /// Before v1.4 the small increment was the usual step; keep the user's value.
  static const _keyLegacySmall = 'small_increment';
  static const _keyRest = 'rest_seconds';
  static const _keySetup = 'is_setup_done';
  static const _keyDevMode = 'dev_mode';
  static const _keyLocale = 'locale';

  @override
  Future<AppSettings> build() async {
    final prefs = await SharedPreferences.getInstance();
    return AppSettings(
      autoProgression: prefs.getBool(_keyAuto) ?? true,
      setsToProgress: prefs.getInt(_keySetsToProgress) ?? 8,
      defaultIncrement: prefs.getDouble(_keyIncrement) ??
          prefs.getDouble(_keyLegacySmall) ??
          2.5,
      restSeconds: prefs.getInt(_keyRest) ?? 90,
      isSetupDone: prefs.getBool(_keySetup) ?? false,
      devMode: prefs.getBool(_keyDevMode) ?? false,
      locale: prefs.getString(_keyLocale) ?? 'en',
    );
  }

  Future<void> setAutoProgression(bool v) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyAuto, v);
    state = AsyncData(state.value!.copyWith(autoProgression: v));
  }

  Future<void> setSetsToProgress(int v) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keySetsToProgress, v);
    state = AsyncData(state.value!.copyWith(setsToProgress: v));
  }

  Future<void> setDefaultIncrement(double v) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_keyIncrement, v);
    state = AsyncData(state.value!.copyWith(defaultIncrement: v));
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
