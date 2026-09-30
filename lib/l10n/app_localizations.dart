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
  /// **'Motivation'**
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
  /// **'Notes for this session'**
  String get log_notes_label;

  /// No description provided for @log_volume.
  ///
  /// In en, this message translates to:
  /// **'Total volume'**
  String get log_volume;

  /// No description provided for @log_progression_title.
  ///
  /// In en, this message translates to:
  /// **'Progression'**
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

  /// No description provided for @muscle_forearms.
  ///
  /// In en, this message translates to:
  /// **'Forearms'**
  String get muscle_forearms;

  /// No description provided for @muscle_bodyweight.
  ///
  /// In en, this message translates to:
  /// **'Bodyweight'**
  String get muscle_bodyweight;

  /// No description provided for @exercise_search_hint.
  ///
  /// In en, this message translates to:
  /// **'Search exercises...'**
  String get exercise_search_hint;

  /// No description provided for @exercise_seconds_label.
  ///
  /// In en, this message translates to:
  /// **'Seconds'**
  String get exercise_seconds_label;

  /// No description provided for @exercise_sets_count_label.
  ///
  /// In en, this message translates to:
  /// **'Sets'**
  String get exercise_sets_count_label;

  /// No description provided for @exercise_type_weighted.
  ///
  /// In en, this message translates to:
  /// **'Weighted'**
  String get exercise_type_weighted;

  /// No description provided for @exercise_type_bodyweight.
  ///
  /// In en, this message translates to:
  /// **'Bodyweight'**
  String get exercise_type_bodyweight;

  /// No description provided for @exercise_type_timed.
  ///
  /// In en, this message translates to:
  /// **'Timed'**
  String get exercise_type_timed;

  /// No description provided for @btn_remove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get btn_remove;

  /// No description provided for @exercise_remove_title.
  ///
  /// In en, this message translates to:
  /// **'Remove from plan'**
  String get exercise_remove_title;

  /// No description provided for @exercise_remove_confirm.
  ///
  /// In en, this message translates to:
  /// **'Remove \"{name}\" from this plan? Its workout history is kept.'**
  String exercise_remove_confirm(String name);

  /// No description provided for @exercise_delete_everywhere.
  ///
  /// In en, this message translates to:
  /// **'Delete exercise and history'**
  String get exercise_delete_everywhere;

  /// No description provided for @exercise_delete_everywhere_confirm.
  ///
  /// In en, this message translates to:
  /// **'Delete \"{name}\" from all plans together with its whole workout history? This cannot be undone.'**
  String exercise_delete_everywhere_confirm(String name);

  /// No description provided for @exercise_shared_hint.
  ///
  /// In en, this message translates to:
  /// **'Used in {count} plans — changes apply to all of them.'**
  String exercise_shared_hint(int count);

  /// No description provided for @exercise_already_in_plan.
  ///
  /// In en, this message translates to:
  /// **'This exercise is already in the plan'**
  String get exercise_already_in_plan;

  /// No description provided for @exercise_in_plan.
  ///
  /// In en, this message translates to:
  /// **'Already in plan'**
  String get exercise_in_plan;

  /// No description provided for @exercise_create_custom.
  ///
  /// In en, this message translates to:
  /// **'Create \"{name}\"'**
  String exercise_create_custom(String name);

  /// No description provided for @progress_one_rep_max.
  ///
  /// In en, this message translates to:
  /// **'Est. 1RM'**
  String get progress_one_rep_max;

  /// No description provided for @settings_data_section.
  ///
  /// In en, this message translates to:
  /// **'DATA'**
  String get settings_data_section;

  /// No description provided for @settings_export.
  ///
  /// In en, this message translates to:
  /// **'Export data'**
  String get settings_export;

  /// No description provided for @settings_export_sub.
  ///
  /// In en, this message translates to:
  /// **'Save plans, exercises and history to a file'**
  String get settings_export_sub;

  /// No description provided for @settings_export_done.
  ///
  /// In en, this message translates to:
  /// **'Backup saved'**
  String get settings_export_done;

  /// No description provided for @settings_import.
  ///
  /// In en, this message translates to:
  /// **'Import data'**
  String get settings_import;

  /// No description provided for @settings_import_sub.
  ///
  /// In en, this message translates to:
  /// **'Restore from a backup file'**
  String get settings_import_sub;

  /// No description provided for @settings_import_confirm.
  ///
  /// In en, this message translates to:
  /// **'Importing replaces all your current plans, exercises and workout history with the backup. Exercise images are not part of the backup. Continue?'**
  String get settings_import_confirm;

  /// No description provided for @settings_import_btn.
  ///
  /// In en, this message translates to:
  /// **'Import'**
  String get settings_import_btn;

  /// No description provided for @settings_import_done.
  ///
  /// In en, this message translates to:
  /// **'Backup restored'**
  String get settings_import_done;

  /// No description provided for @settings_import_invalid.
  ///
  /// In en, this message translates to:
  /// **'This file is not a valid FitForge backup'**
  String get settings_import_invalid;

  /// No description provided for @rest_title.
  ///
  /// In en, this message translates to:
  /// **'Rest'**
  String get rest_title;

  /// No description provided for @rest_skip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get rest_skip;

  /// No description provided for @rest_notification_title.
  ///
  /// In en, this message translates to:
  /// **'Resting'**
  String get rest_notification_title;

  /// No description provided for @rest_done_title.
  ///
  /// In en, this message translates to:
  /// **'Rest is over'**
  String get rest_done_title;

  /// No description provided for @rest_done_body.
  ///
  /// In en, this message translates to:
  /// **'Time for your next set of {exercise}'**
  String rest_done_body(String exercise);

  /// No description provided for @settings_rest_section.
  ///
  /// In en, this message translates to:
  /// **'REST TIMER'**
  String get settings_rest_section;

  /// No description provided for @settings_rest.
  ///
  /// In en, this message translates to:
  /// **'Rest between sets'**
  String get settings_rest;

  /// No description provided for @settings_rest_sub.
  ///
  /// In en, this message translates to:
  /// **'Starts after each completed set'**
  String get settings_rest_sub;

  /// No description provided for @settings_rest_off.
  ///
  /// In en, this message translates to:
  /// **'Off'**
  String get settings_rest_off;

  /// No description provided for @nav_home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get nav_home;

  /// No description provided for @nav_progress.
  ///
  /// In en, this message translates to:
  /// **'Progress'**
  String get nav_progress;

  /// No description provided for @nav_plans.
  ///
  /// In en, this message translates to:
  /// **'Plans'**
  String get nav_plans;

  /// No description provided for @nav_settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get nav_settings;

  /// No description provided for @exercise_edit.
  ///
  /// In en, this message translates to:
  /// **'Edit exercise'**
  String get exercise_edit;

  /// No description provided for @exercise_add_description.
  ///
  /// In en, this message translates to:
  /// **'Add description'**
  String get exercise_add_description;

  /// No description provided for @log_show_more.
  ///
  /// In en, this message translates to:
  /// **'Show more'**
  String get log_show_more;

  /// No description provided for @log_show_less.
  ///
  /// In en, this message translates to:
  /// **'Show less'**
  String get log_show_less;

  /// No description provided for @log_last_note.
  ///
  /// In en, this message translates to:
  /// **'Last time ({date})'**
  String log_last_note(String date);

  /// No description provided for @plan_edit.
  ///
  /// In en, this message translates to:
  /// **'Edit plan'**
  String get plan_edit;

  /// No description provided for @settings_demo.
  ///
  /// In en, this message translates to:
  /// **'Load demo data'**
  String get settings_demo;

  /// No description provided for @settings_demo_sub.
  ///
  /// In en, this message translates to:
  /// **'Sample plans and 8 weeks of workouts to try the app'**
  String get settings_demo_sub;

  /// No description provided for @settings_demo_confirm.
  ///
  /// In en, this message translates to:
  /// **'This replaces all your plans, exercises and workout history with sample data. Export your data first if you want to keep it.'**
  String get settings_demo_confirm;

  /// No description provided for @settings_demo_btn.
  ///
  /// In en, this message translates to:
  /// **'Load'**
  String get settings_demo_btn;

  /// No description provided for @settings_demo_done.
  ///
  /// In en, this message translates to:
  /// **'Demo data loaded'**
  String get settings_demo_done;

  /// No description provided for @settings_version.
  ///
  /// In en, this message translates to:
  /// **'FitForge {version}'**
  String settings_version(String version);

  /// No description provided for @settings_dev_section.
  ///
  /// In en, this message translates to:
  /// **'DEVELOPER'**
  String get settings_dev_section;

  /// No description provided for @settings_dev_unlocked.
  ///
  /// In en, this message translates to:
  /// **'Developer options enabled'**
  String get settings_dev_unlocked;

  /// No description provided for @settings_dev_taps_left.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 more tap to enable developer options} other{{count} more taps to enable developer options}}'**
  String settings_dev_taps_left(int count);

  /// No description provided for @settings_dev_hide.
  ///
  /// In en, this message translates to:
  /// **'Hide developer options'**
  String get settings_dev_hide;

  /// No description provided for @settings_dev_hide_sub.
  ///
  /// In en, this message translates to:
  /// **'Tap the version 7 times to show them again'**
  String get settings_dev_hide_sub;

  /// No description provided for @progression_counter.
  ///
  /// In en, this message translates to:
  /// **'{done}/{total} sets at {current} — then {next}'**
  String progression_counter(int done, int total, String current, String next);

  /// No description provided for @progression_ready.
  ///
  /// In en, this message translates to:
  /// **'Next set: {next} — time to go up!'**
  String progression_ready(String next);

  /// No description provided for @progression_reps.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 rep} other{{count} reps}}'**
  String progression_reps(int count);

  /// No description provided for @settings_auto_progression.
  ///
  /// In en, this message translates to:
  /// **'Automatic increase'**
  String get settings_auto_progression;

  /// No description provided for @settings_auto_progression_sub.
  ///
  /// In en, this message translates to:
  /// **'Go up after enough good sets in a row'**
  String get settings_auto_progression_sub;

  /// No description provided for @settings_sets_to_progress.
  ///
  /// In en, this message translates to:
  /// **'Sets before increase'**
  String get settings_sets_to_progress;

  /// No description provided for @settings_sets_to_progress_sub.
  ///
  /// In en, this message translates to:
  /// **'Good sets in a row at the same weight'**
  String get settings_sets_to_progress_sub;

  /// No description provided for @settings_default_increment.
  ///
  /// In en, this message translates to:
  /// **'Default increment'**
  String get settings_default_increment;

  /// No description provided for @settings_default_increment_sub.
  ///
  /// In en, this message translates to:
  /// **'For exercises without their own'**
  String get settings_default_increment_sub;

  /// No description provided for @targets_title.
  ///
  /// In en, this message translates to:
  /// **'Targets & progression'**
  String get targets_title;

  /// No description provided for @targets_plan_section.
  ///
  /// In en, this message translates to:
  /// **'IN THIS PLAN'**
  String get targets_plan_section;

  /// No description provided for @targets_progression_section.
  ///
  /// In en, this message translates to:
  /// **'PROGRESSION (ALL PLANS)'**
  String get targets_progression_section;

  /// No description provided for @targets_sets.
  ///
  /// In en, this message translates to:
  /// **'Sets'**
  String get targets_sets;

  /// No description provided for @targets_reps.
  ///
  /// In en, this message translates to:
  /// **'Reps'**
  String get targets_reps;

  /// No description provided for @targets_seconds.
  ///
  /// In en, this message translates to:
  /// **'Seconds'**
  String get targets_seconds;

  /// No description provided for @targets_weight.
  ///
  /// In en, this message translates to:
  /// **'Weight (kg)'**
  String get targets_weight;

  /// No description provided for @targets_auto.
  ///
  /// In en, this message translates to:
  /// **'Automatic increase'**
  String get targets_auto;

  /// No description provided for @targets_increment.
  ///
  /// In en, this message translates to:
  /// **'Increment'**
  String get targets_increment;

  /// No description provided for @targets_sets_to_progress.
  ///
  /// In en, this message translates to:
  /// **'Sets before increase'**
  String get targets_sets_to_progress;

  /// No description provided for @targets_default.
  ///
  /// In en, this message translates to:
  /// **'Default ({value})'**
  String targets_default(String value);

  /// No description provided for @targets_rule_hint.
  ///
  /// In en, this message translates to:
  /// **'A missed set or a different weight starts the count again.'**
  String get targets_rule_hint;

  /// No description provided for @progression_moving.
  ///
  /// In en, this message translates to:
  /// **'Moving up to {next}: {done} of {total} sets this workout'**
  String progression_moving(String next, int done, int total);
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
