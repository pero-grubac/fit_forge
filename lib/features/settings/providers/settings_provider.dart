import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppSettings {
  final double smallIncrement;
  final double largeIncrement;
  final double progressionThreshold;
  final bool isSetupDone;
  final String locale;

  const AppSettings({
    this.smallIncrement = 2.5,
    this.largeIncrement = 5.0,
    this.progressionThreshold = 0.95,
    this.isSetupDone = false,
    this.locale = 'en',
  });

  AppSettings copyWith({
    double? smallIncrement,
    double? largeIncrement,
    double? progressionThreshold,
    bool? isSetupDone,
    String? locale,
  }) {
    return AppSettings(
      smallIncrement: smallIncrement ?? this.smallIncrement,
      largeIncrement: largeIncrement ?? this.largeIncrement,
      progressionThreshold: progressionThreshold ?? this.progressionThreshold,
      isSetupDone: isSetupDone ?? this.isSetupDone,
      locale: locale ?? this.locale,
    );
  }
}

class SettingsNotifier extends AsyncNotifier<AppSettings> {
  static const _keySmall = 'small_increment';
  static const _keyLarge = 'large_increment';
  static const _keyThreshold = 'progression_threshold';
  static const _keySetup = 'is_setup_done';
  static const _keyLocale = 'locale';

  @override
  Future<AppSettings> build() async {
    final prefs = await SharedPreferences.getInstance();
    return AppSettings(
      smallIncrement: prefs.getDouble(_keySmall) ?? 2.5,
      largeIncrement: prefs.getDouble(_keyLarge) ?? 5.0,
      progressionThreshold: prefs.getDouble(_keyThreshold) ?? 0.95,
      isSetupDone: prefs.getBool(_keySetup) ?? false,
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
