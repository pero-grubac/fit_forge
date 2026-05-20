import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_sr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('sr'),
    Locale.fromSubtags(languageCode: 'sr', scriptCode: 'Cyrl')
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'Fit Forge'**
  String get appName;

  /// No description provided for @appSlogan.
  ///
  /// In en, this message translates to:
  /// **'Why not you?'**
  String get appSlogan;

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navProgress.
  ///
  /// In en, this message translates to:
  /// **'Progress'**
  String get navProgress;

  /// No description provided for @navPlan.
  ///
  /// In en, this message translates to:
  /// **'Plan'**
  String get navPlan;

  /// No description provided for @navSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get navSettings;

  /// No description provided for @greeting_morning.
  ///
  /// In en, this message translates to:
  /// **'Good morning'**
  String get greeting_morning;

  /// No description provided for @greeting_afternoon.
  ///
  /// In en, this message translates to:
  /// **'Good afternoon'**
  String get greeting_afternoon;

  /// No description provided for @greeting_evening.
  ///
  /// In en, this message translates to:
  /// **'Good evening'**
  String get greeting_evening;

  /// No description provided for @motivationTitle.
  ///
  /// In en, this message translates to:
  /// **'Motivation of the day'**
  String get motivationTitle;

  /// No description provided for @days_monday.
  ///
  /// In en, this message translates to:
  /// **'Monday'**
  String get days_monday;

  /// No description provided for @days_tuesday.
  ///
  /// In en, this message translates to:
  /// **'Tuesday'**
  String get days_tuesday;

  /// No description provided for @days_wednesday.
  ///
  /// In en, this message translates to:
  /// **'Wednesday'**
  String get days_wednesday;

  /// No description provided for @days_thursday.
  ///
  /// In en, this message translates to:
  /// **'Thursday'**
  String get days_thursday;

  /// No description provided for @days_friday.
  ///
  /// In en, this message translates to:
  /// **'Friday'**
  String get days_friday;

  /// No description provided for @days_saturday.
  ///
  /// In en, this message translates to:
  /// **'Saturday'**
  String get days_saturday;

  /// No description provided for @days_sunday.
  ///
  /// In en, this message translates to:
  /// **'Sunday'**
  String get days_sunday;

  /// No description provided for @home_noplan.
  ///
  /// In en, this message translates to:
  /// **'No plan for today'**
  String get home_noplan;

  /// No description provided for @home_noplan_sub.
  ///
  /// In en, this message translates to:
  /// **'Create a plan in Plan editor'**
  String get home_noplan_sub;

  /// No description provided for @home_sets.
  ///
  /// In en, this message translates to:
  /// **'{completed}/{total} sets'**
  String home_sets(int completed, int total);

  /// No description provided for @status_done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get status_done;

  /// No description provided for @status_active.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get status_active;

  /// No description provided for @status_waiting.
  ///
  /// In en, this message translates to:
  /// **'Waiting'**
  String get status_waiting;

  /// No description provided for @plan_editor_title.
  ///
  /// In en, this message translates to:
  /// **'Plan editor'**
  String get plan_editor_title;

  /// No description provided for @plan_new.
  ///
  /// In en, this message translates to:
  /// **'New plan'**
  String get plan_new;

  /// No description provided for @plan_no_plans.
  ///
  /// In en, this message translates to:
  /// **'You have no plans'**
  String get plan_no_plans;

  /// No description provided for @plan_no_plans_sub.
  ///
  /// In en, this message translates to:
  /// **'Create your first workout plan'**
  String get plan_no_plans_sub;

  /// No description provided for @plan_create.
  ///
  /// In en, this message translates to:
  /// **'Create plan'**
  String get plan_create;

  /// No description provided for @plan_name_hint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Push Day A'**
  String get plan_name_hint;

  /// No description provided for @plan_name_label.
  ///
  /// In en, this message translates to:
  /// **'Plan name'**
  String get plan_name_label;

  /// No description provided for @plan_day_label.
  ///
  /// In en, this message translates to:
  /// **'Day of week'**
  String get plan_day_label;

  /// No description provided for @plan_delete_title.
  ///
  /// In en, this message translates to:
  /// **'Delete plan'**
  String get plan_delete_title;

  /// No description provided for @plan_delete_confirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete \"{name}\"?'**
  String plan_delete_confirm(String name);

  /// No description provided for @exercise_add.
  ///
  /// In en, this message translates to:
  /// **'Add exercise'**
  String get exercise_add;

  /// No description provided for @exercise_new.
  ///
  /// In en, this message translates to:
  /// **'New exercise'**
  String get exercise_new;

  /// No description provided for @exercise_name_hint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Bench Press'**
  String get exercise_name_hint;

  /// No description provided for @exercise_name_label.
  ///
  /// In en, this message translates to:
  /// **'Exercise name'**
  String get exercise_name_label;

  /// No description provided for @exercise_muscle_label.
  ///
  /// In en, this message translates to:
  /// **'Muscle group'**
  String get exercise_muscle_label;

  /// No description provided for @exercise_sets_label.
  ///
  /// In en, this message translates to:
  /// **'Sets'**
  String get exercise_sets_label;

  /// No description provided for @exercise_reps_label.
  ///
  /// In en, this message translates to:
  /// **'Reps'**
  String get exercise_reps_label;

  /// No description provided for @exercise_weight_label.
  ///
  /// In en, this message translates to:
  /// **'Starting weight (kg)'**
  String get exercise_weight_label;

  /// No description provided for @exercise_increment_label.
  ///
  /// In en, this message translates to:
  /// **'Increment (kg)'**
  String get exercise_increment_label;

  /// No description provided for @exercise_save.
  ///
  /// In en, this message translates to:
  /// **'Save exercise'**
  String get exercise_save;

  /// No description provided for @exercise_delete_title.
  ///
  /// In en, this message translates to:
  /// **'Delete exercise'**
  String get exercise_delete_title;

  /// No description provided for @exercise_delete_confirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete \"{name}\"?'**
  String exercise_delete_confirm(String name);

  /// No description provided for @exercise_no_exercises.
  ///
  /// In en, this message translates to:
  /// **'No exercises in plan'**
  String get exercise_no_exercises;

  /// No description provided for @exercise_no_exercises_sub.
  ///
  /// In en, this message translates to:
  /// **'Add your first exercise'**
  String get exercise_no_exercises_sub;

  /// No description provided for @exercise_tap_image.
  ///
  /// In en, this message translates to:
  /// **'Tap to add image'**
  String get exercise_tap_image;

  /// No description provided for @exercise_change_image.
  ///
  /// In en, this message translates to:
  /// **'Change image'**
  String get exercise_change_image;

  /// No description provided for @exercise_description_label.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get exercise_description_label;

  /// No description provided for @exercise_description_hint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Keep your back flat...'**
  String get exercise_description_hint;

  /// No description provided for @exercise_youtube_label.
  ///
  /// In en, this message translates to:
  /// **'YouTube link (optional)'**
  String get exercise_youtube_label;

  /// No description provided for @exercise_watch_youtube.
  ///
  /// In en, this message translates to:
  /// **'Watch on YouTube'**
  String get exercise_watch_youtube;

  /// No description provided for @log_save.
  ///
  /// In en, this message translates to:
  /// **'Save workout'**
  String get log_save;

  /// No description provided for @log_add_set.
  ///
  /// In en, this message translates to:
  /// **'Add set'**
  String get log_add_set;

  /// No description provided for @log_notes_hint.
  ///
  /// In en, this message translates to:
  /// **'e.g. good pump, increase next time...'**
  String get log_notes_hint;

  /// No description provided for @log_notes_label.
  ///
  /// In en, this message translates to:
  /// **'Note (optional)'**
  String get log_notes_label;

  /// No description provided for @log_volume.
  ///
  /// In en, this message translates to:
  /// **'Total volume'**
  String get log_volume;

  /// No description provided for @log_progression_title.
  ///
  /// In en, this message translates to:
  /// **'Progression suggestion'**
  String get log_progression_title;

  /// No description provided for @progress_title.
  ///
  /// In en, this message translates to:
  /// **'Progress'**
  String get progress_title;

  /// No description provided for @progress_no_data.
  ///
  /// In en, this message translates to:
  /// **'No data for selected period'**
  String get progress_no_data;

  /// No description provided for @progress_no_workouts.
  ///
  /// In en, this message translates to:
  /// **'You have no workouts yet'**
  String get progress_no_workouts;

  /// No description provided for @progress_no_workouts_sub.
  ///
  /// In en, this message translates to:
  /// **'Start a workout on the Home screen'**
  String get progress_no_workouts_sub;

  /// No description provided for @progress_max_weight.
  ///
  /// In en, this message translates to:
  /// **'Max weight'**
  String get progress_max_weight;

  /// No description provided for @progress_sessions.
  ///
  /// In en, this message translates to:
  /// **'Sessions'**
  String get progress_sessions;

  /// No description provided for @progress_growth.
  ///
  /// In en, this message translates to:
  /// **'Strength growth'**
  String get progress_growth;

  /// No description provided for @progress_chart_weight.
  ///
  /// In en, this message translates to:
  /// **'Max weight per session'**
  String get progress_chart_weight;

  /// No description provided for @progress_chart_volume.
  ///
  /// In en, this message translates to:
  /// **'Volume per session'**
  String get progress_chart_volume;

  /// No description provided for @progress_personal_record.
  ///
  /// In en, this message translates to:
  /// **'Personal record'**
  String get progress_personal_record;

  /// No description provided for @progress_period_all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get progress_period_all;

  /// No description provided for @settings_title.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings_title;

  /// No description provided for @settings_progression_section.
  ///
  /// In en, this message translates to:
  /// **'PROGRESSION RULES'**
  String get settings_progression_section;

  /// No description provided for @settings_small_increment.
  ///
  /// In en, this message translates to:
  /// **'Small increment'**
  String get settings_small_increment;

  /// No description provided for @settings_small_increment_sub.
  ///
  /// In en, this message translates to:
  /// **'For weights up to 100 kg'**
  String get settings_small_increment_sub;

  /// No description provided for @settings_large_increment.
  ///
  /// In en, this message translates to:
  /// **'Large increment'**
  String get settings_large_increment;

  /// No description provided for @settings_large_increment_sub.
  ///
  /// In en, this message translates to:
  /// **'For weights above 100 kg'**
  String get settings_large_increment_sub;

  /// No description provided for @settings_threshold.
  ///
  /// In en, this message translates to:
  /// **'Progress threshold'**
  String get settings_threshold;

  /// No description provided for @settings_threshold_sub.
  ///
  /// In en, this message translates to:
  /// **'Min. completion rate to increase weight'**
  String get settings_threshold_sub;

  /// No description provided for @settings_general_section.
  ///
  /// In en, this message translates to:
  /// **'GENERAL'**
  String get settings_general_section;

  /// No description provided for @settings_reset.
  ///
  /// In en, this message translates to:
  /// **'Reset all data'**
  String get settings_reset;

  /// No description provided for @settings_reset_sub.
  ///
  /// In en, this message translates to:
  /// **'Deletes all plans, exercises and workouts'**
  String get settings_reset_sub;

  /// No description provided for @settings_reset_title.
  ///
  /// In en, this message translates to:
  /// **'Reset all data'**
  String get settings_reset_title;

  /// No description provided for @settings_reset_confirm.
  ///
  /// In en, this message translates to:
  /// **'This will delete all plans, exercises and workout history. This action cannot be undone.'**
  String get settings_reset_confirm;

  /// No description provided for @settings_quotes_section.
  ///
  /// In en, this message translates to:
  /// **'MOTIVATIONAL QUOTES'**
  String get settings_quotes_section;

  /// No description provided for @settings_quotes_add.
  ///
  /// In en, this message translates to:
  /// **'Add quote'**
  String get settings_quotes_add;

  /// No description provided for @settings_quotes_add_sub.
  ///
  /// In en, this message translates to:
  /// **'Create your own motivational quote'**
  String get settings_quotes_add_sub;

  /// No description provided for @settings_quotes_empty.
  ///
  /// In en, this message translates to:
  /// **'No custom quotes — using built-in ones.'**
  String get settings_quotes_empty;

  /// No description provided for @settings_quote_new.
  ///
  /// In en, this message translates to:
  /// **'New quote'**
  String get settings_quote_new;

  /// No description provided for @settings_quote_hint.
  ///
  /// In en, this message translates to:
  /// **'Write your motivational quote...'**
  String get settings_quote_hint;

  /// No description provided for @settings_quote_add_btn.
  ///
  /// In en, this message translates to:
  /// **'Add quote'**
  String get settings_quote_add_btn;

  /// No description provided for @settings_language_section.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settings_language_section;

  /// No description provided for @onboarding_welcome_title.
  ///
  /// In en, this message translates to:
  /// **'Welcome to\nFit Forge'**
  String get onboarding_welcome_title;

  /// No description provided for @onboarding_welcome_sub.
  ///
  /// In en, this message translates to:
  /// **'Your personal fitness trainer in your pocket.\nTrack progress, conquer goals.'**
  String get onboarding_welcome_sub;

  /// No description provided for @onboarding_how_title.
  ///
  /// In en, this message translates to:
  /// **'How it works?'**
  String get onboarding_how_title;

  /// No description provided for @onboarding_step1_title.
  ///
  /// In en, this message translates to:
  /// **'Create a plan'**
  String get onboarding_step1_title;

  /// No description provided for @onboarding_step1_sub.
  ///
  /// In en, this message translates to:
  /// **'Add exercises, sets and weights for each day'**
  String get onboarding_step1_sub;

  /// No description provided for @onboarding_step2_title.
  ///
  /// In en, this message translates to:
  /// **'Do your workout'**
  String get onboarding_step2_title;

  /// No description provided for @onboarding_step2_sub.
  ///
  /// In en, this message translates to:
  /// **'Log sets in real time'**
  String get onboarding_step2_sub;

  /// No description provided for @onboarding_step3_title.
  ///
  /// In en, this message translates to:
  /// **'Track progress'**
  String get onboarding_step3_title;

  /// No description provided for @onboarding_step3_sub.
  ///
  /// In en, this message translates to:
  /// **'Weight and volume graphs over time'**
  String get onboarding_step3_sub;

  /// No description provided for @onboarding_getstarted_title.
  ///
  /// In en, this message translates to:
  /// **'You\'re ready!'**
  String get onboarding_getstarted_title;

  /// No description provided for @onboarding_getstarted_sub.
  ///
  /// In en, this message translates to:
  /// **'Create your first training plan\nand start building strength today.'**
  String get onboarding_getstarted_sub;

  /// No description provided for @onboarding_tip.
  ///
  /// In en, this message translates to:
  /// **'Tip: Start with lighter weights and focus on technique.'**
  String get onboarding_tip;

  /// No description provided for @onboarding_skip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get onboarding_skip;

  /// No description provided for @onboarding_next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get onboarding_next;

  /// No description provided for @onboarding_start.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get onboarding_start;

  /// No description provided for @btn_cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get btn_cancel;

  /// No description provided for @btn_delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get btn_delete;

  /// No description provided for @btn_save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get btn_save;

  /// No description provided for @btn_confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get btn_confirm;

  /// No description provided for @btn_retry.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get btn_retry;

  /// No description provided for @error_generic.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get error_generic;

  /// No description provided for @muscle_chest.
  ///
  /// In en, this message translates to:
  /// **'Chest'**
  String get muscle_chest;

  /// No description provided for @muscle_back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get muscle_back;

  /// No description provided for @muscle_shoulders.
  ///
  /// In en, this message translates to:
  /// **'Shoulders'**
  String get muscle_shoulders;

  /// No description provided for @muscle_biceps.
  ///
  /// In en, this message translates to:
  /// **'Biceps'**
  String get muscle_biceps;

  /// No description provided for @muscle_triceps.
  ///
  /// In en, this message translates to:
  /// **'Triceps'**
  String get muscle_triceps;

  /// No description provided for @muscle_legs.
  ///
  /// In en, this message translates to:
  /// **'Legs'**
  String get muscle_legs;

  /// No description provided for @muscle_core.
  ///
  /// In en, this message translates to:
  /// **'Core'**
  String get muscle_core;

  /// No description provided for @motivation_1.
  ///
  /// In en, this message translates to:
  /// **'Every kilogram you lift is proof of your strength.'**
  String get motivation_1;

  /// No description provided for @motivation_2.
  ///
  /// In en, this message translates to:
  /// **'Don\'t ask yourself how — ask yourself why not.'**
  String get motivation_2;

  /// No description provided for @motivation_3.
  ///
  /// In en, this message translates to:
  /// **'Strength isn\'t built in one day. It\'s built workout by workout.'**
  String get motivation_3;

  /// No description provided for @motivation_4.
  ///
  /// In en, this message translates to:
  /// **'The weight doesn\'t lie. Neither do you.'**
  String get motivation_4;

  /// No description provided for @motivation_5.
  ///
  /// In en, this message translates to:
  /// **'Every workout is an investment in yourself.'**
  String get motivation_5;

  /// No description provided for @log_session_title.
  ///
  /// In en, this message translates to:
  /// **'Workout'**
  String get log_session_title;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'sr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when language+script codes are specified.
  switch (locale.languageCode) {
    case 'sr':
      {
        switch (locale.scriptCode) {
          case 'Cyrl':
            return AppLocalizationsSrCyrl();
        }
        break;
      }
  }

  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'sr':
      return AppLocalizationsSr();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
