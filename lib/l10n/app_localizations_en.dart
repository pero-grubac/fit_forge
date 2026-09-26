// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Fit Forge';

  @override
  String get appSlogan => 'Why not you?';

  @override
  String get navHome => 'Home';

  @override
  String get navProgress => 'Progress';

  @override
  String get navPlan => 'Plan';

  @override
  String get navSettings => 'Settings';

  @override
  String get greeting_morning => 'Good morning';

  @override
  String get greeting_afternoon => 'Good afternoon';

  @override
  String get greeting_evening => 'Good evening';

  @override
  String get motivationTitle => 'Motivation';

  @override
  String get days_monday => 'Monday';

  @override
  String get days_tuesday => 'Tuesday';

  @override
  String get days_wednesday => 'Wednesday';

  @override
  String get days_thursday => 'Thursday';

  @override
  String get days_friday => 'Friday';

  @override
  String get days_saturday => 'Saturday';

  @override
  String get days_sunday => 'Sunday';

  @override
  String get home_noplan => 'No plan for today';

  @override
  String get home_noplan_sub => 'Create a plan in Plan editor';

  @override
  String home_sets(int completed, int total) {
    return '$completed/$total sets';
  }

  @override
  String get status_done => 'Done';

  @override
  String get status_active => 'Active';

  @override
  String get status_waiting => 'Waiting';

  @override
  String get plan_editor_title => 'Plan editor';

  @override
  String get plan_new => 'New plan';

  @override
  String get plan_no_plans => 'You have no plans';

  @override
  String get plan_no_plans_sub => 'Create your first workout plan';

  @override
  String get plan_create => 'Create plan';

  @override
  String get plan_name_hint => 'e.g. Push Day A';

  @override
  String get plan_name_label => 'Plan name';

  @override
  String get plan_day_label => 'Day of week';

  @override
  String get plan_delete_title => 'Delete plan';

  @override
  String plan_delete_confirm(String name) {
    return 'Are you sure you want to delete \"$name\"?';
  }

  @override
  String get exercise_add => 'Add exercise';

  @override
  String get exercise_new => 'New exercise';

  @override
  String get exercise_name_hint => 'e.g. Bench Press';

  @override
  String get exercise_name_label => 'Exercise name';

  @override
  String get exercise_muscle_label => 'Muscle group';

  @override
  String get exercise_sets_label => 'Sets';

  @override
  String get exercise_reps_label => 'Reps';

  @override
  String get exercise_weight_label => 'Starting weight (kg)';

  @override
  String get exercise_increment_label => 'Increment (kg)';

  @override
  String get exercise_save => 'Save exercise';

  @override
  String get exercise_delete_title => 'Delete exercise';

  @override
  String exercise_delete_confirm(String name) {
    return 'Are you sure you want to delete \"$name\"?';
  }

  @override
  String get exercise_no_exercises => 'No exercises in plan';

  @override
  String get exercise_no_exercises_sub => 'Add your first exercise';

  @override
  String get exercise_tap_image => 'Tap to add image';

  @override
  String get exercise_change_image => 'Change image';

  @override
  String get exercise_description_label => 'Description';

  @override
  String get exercise_description_hint => 'e.g. Keep your back flat...';

  @override
  String get exercise_youtube_label => 'YouTube link (optional)';

  @override
  String get exercise_watch_youtube => 'Watch on YouTube';

  @override
  String get log_save => 'Save workout';

  @override
  String get log_add_set => 'Add set';

  @override
  String get log_notes_hint => 'e.g. good pump, increase next time...';

  @override
  String get log_notes_label => 'Notes for this session';

  @override
  String get log_volume => 'Total volume';

  @override
  String get log_progression_title => 'Progression suggestion';

  @override
  String log_progression_increase(String increment) {
    return 'Great work! Increasing by $increment kg';
  }

  @override
  String get log_progression_hold => 'Hold the weight — you are almost there';

  @override
  String get log_progression_reduce =>
      'Focus on technique — reducing the weight slightly';

  @override
  String get progress_title => 'Progress';

  @override
  String get progress_no_data => 'No data for selected period';

  @override
  String get progress_no_workouts => 'You have no workouts yet';

  @override
  String get progress_no_workouts_sub => 'Start a workout on the Home screen';

  @override
  String get progress_max_weight => 'Max weight';

  @override
  String get progress_sessions => 'Sessions';

  @override
  String get progress_growth => 'Strength growth';

  @override
  String get progress_chart_weight => 'Max weight per session';

  @override
  String get progress_chart_volume => 'Volume per session';

  @override
  String get progress_personal_record => 'Personal record';

  @override
  String get progress_period_all => 'All';

  @override
  String get settings_title => 'Settings';

  @override
  String get settings_progression_section => 'PROGRESSION RULES';

  @override
  String get settings_small_increment => 'Small increment';

  @override
  String get settings_small_increment_sub => 'For weights up to 100 kg';

  @override
  String get settings_large_increment => 'Large increment';

  @override
  String get settings_large_increment_sub => 'For weights above 100 kg';

  @override
  String get settings_threshold => 'Progress threshold';

  @override
  String get settings_threshold_sub =>
      'Min. completion rate to increase weight';

  @override
  String get settings_general_section => 'GENERAL';

  @override
  String get settings_reset => 'Reset all data';

  @override
  String get settings_reset_sub => 'Deletes all plans, exercises and workouts';

  @override
  String get settings_reset_title => 'Reset all data';

  @override
  String get settings_reset_confirm =>
      'This will delete all plans, exercises and workout history. This action cannot be undone.';

  @override
  String get settings_quotes_section => 'MOTIVATIONAL QUOTES';

  @override
  String get settings_quotes_add => 'Add quote';

  @override
  String get settings_quotes_add_sub => 'Create your own motivational quote';

  @override
  String get settings_quotes_empty => 'No custom quotes — using built-in ones.';

  @override
  String get settings_quote_new => 'New quote';

  @override
  String get settings_quote_hint => 'Write your motivational quote...';

  @override
  String get settings_quote_add_btn => 'Add quote';

  @override
  String get settings_language_section => 'Language';

  @override
  String get onboarding_welcome_title => 'Welcome to\nFit Forge';

  @override
  String get onboarding_welcome_sub =>
      'Your personal fitness trainer in your pocket.\nTrack progress, conquer goals.';

  @override
  String get onboarding_how_title => 'How it works?';

  @override
  String get onboarding_step1_title => 'Create a plan';

  @override
  String get onboarding_step1_sub =>
      'Add exercises, sets and weights for each day';

  @override
  String get onboarding_step2_title => 'Do your workout';

  @override
  String get onboarding_step2_sub => 'Log sets in real time';

  @override
  String get onboarding_step3_title => 'Track progress';

  @override
  String get onboarding_step3_sub => 'Weight and volume graphs over time';

  @override
  String get onboarding_getstarted_title => 'You\'re ready!';

  @override
  String get onboarding_getstarted_sub =>
      'Create your first training plan\nand start building strength today.';

  @override
  String get onboarding_tip =>
      'Tip: Start with lighter weights and focus on technique.';

  @override
  String get onboarding_skip => 'Skip';

  @override
  String get onboarding_next => 'Next';

  @override
  String get onboarding_start => 'Start';

  @override
  String get btn_cancel => 'Cancel';

  @override
  String get btn_delete => 'Delete';

  @override
  String get btn_save => 'Save';

  @override
  String get btn_confirm => 'Confirm';

  @override
  String get btn_retry => 'Try again';

  @override
  String get error_generic => 'Something went wrong. Please try again.';

  @override
  String get muscle_chest => 'Chest';

  @override
  String get muscle_back => 'Back';

  @override
  String get muscle_shoulders => 'Shoulders';

  @override
  String get muscle_biceps => 'Biceps';

  @override
  String get muscle_triceps => 'Triceps';

  @override
  String get muscle_legs => 'Legs';

  @override
  String get muscle_core => 'Core';

  @override
  String get motivation_1 =>
      'Every kilogram you lift is proof of your strength.';

  @override
  String get motivation_2 => 'Don\'t ask yourself how — ask yourself why not.';

  @override
  String get motivation_3 =>
      'Strength isn\'t built in one day. It\'s built workout by workout.';

  @override
  String get motivation_4 => 'The weight doesn\'t lie. Neither do you.';

  @override
  String get motivation_5 => 'Every workout is an investment in yourself.';

  @override
  String get log_session_title => 'Workout';

  @override
  String get muscle_forearms => 'Forearms';

  @override
  String get muscle_bodyweight => 'Bodyweight';

  @override
  String get exercise_search_hint => 'Search exercises...';

  @override
  String get exercise_seconds_label => 'Seconds';

  @override
  String get exercise_sets_count_label => 'Sets';

  @override
  String get exercise_type_weighted => 'Weighted';

  @override
  String get exercise_type_bodyweight => 'Bodyweight';

  @override
  String get exercise_type_timed => 'Timed';

  @override
  String get btn_remove => 'Remove';

  @override
  String get exercise_remove_title => 'Remove from plan';

  @override
  String exercise_remove_confirm(String name) {
    return 'Remove \"$name\" from this plan? Its workout history is kept.';
  }

  @override
  String get exercise_delete_everywhere => 'Delete exercise and history';

  @override
  String exercise_delete_everywhere_confirm(String name) {
    return 'Delete \"$name\" from all plans together with its whole workout history? This cannot be undone.';
  }

  @override
  String exercise_shared_hint(int count) {
    return 'Used in $count plans — changes apply to all of them.';
  }

  @override
  String get exercise_already_in_plan => 'This exercise is already in the plan';

  @override
  String get exercise_in_plan => 'Already in plan';

  @override
  String exercise_create_custom(String name) {
    return 'Create \"$name\"';
  }

  @override
  String get progress_one_rep_max => 'Est. 1RM';

  @override
  String log_progression_increase_reps(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Great work! Adding $count reps per set',
      one: 'Great work! Adding 1 rep per set',
    );
    return '$_temp0';
  }

  @override
  String log_progression_increase_seconds(int count) {
    return 'Great work! Adding $count s per set';
  }

  @override
  String get log_progression_hold_reps =>
      'Keep the same targets — you\'re almost there';

  @override
  String get log_progression_reduce_reps =>
      'Focus on technique — easing off a little';

  @override
  String get settings_data_section => 'DATA';

  @override
  String get settings_export => 'Export data';

  @override
  String get settings_export_sub =>
      'Save plans, exercises and history to a file';

  @override
  String get settings_export_done => 'Backup saved';

  @override
  String get settings_import => 'Import data';

  @override
  String get settings_import_sub => 'Restore from a backup file';

  @override
  String get settings_import_confirm =>
      'Importing replaces all your current plans, exercises and workout history with the backup. Exercise images are not part of the backup. Continue?';

  @override
  String get settings_import_btn => 'Import';

  @override
  String get settings_import_done => 'Backup restored';

  @override
  String get settings_import_invalid =>
      'This file is not a valid FitForge backup';

  @override
  String get rest_title => 'Rest';

  @override
  String get rest_skip => 'Skip';

  @override
  String get rest_notification_title => 'Resting';

  @override
  String get rest_done_title => 'Rest is over';

  @override
  String rest_done_body(String exercise) {
    return 'Time for your next set of $exercise';
  }

  @override
  String get settings_rest_section => 'REST TIMER';

  @override
  String get settings_rest => 'Rest between sets';

  @override
  String get settings_rest_sub => 'Starts after each completed set';

  @override
  String get settings_rest_off => 'Off';

  @override
  String get nav_home => 'Home';

  @override
  String get nav_progress => 'Progress';

  @override
  String get nav_plans => 'Plans';

  @override
  String get nav_settings => 'Settings';

  @override
  String get exercise_edit => 'Edit exercise';

  @override
  String get exercise_add_description => 'Add description';

  @override
  String get log_show_more => 'Show more';

  @override
  String get log_show_less => 'Show less';

  @override
  String log_last_note(String date) {
    return 'Last time ($date)';
  }

  @override
  String get plan_edit => 'Edit plan';

  @override
  String get settings_demo => 'Load demo data';

  @override
  String get settings_demo_sub =>
      'Sample plans and 8 weeks of workouts to try the app';

  @override
  String get settings_demo_confirm =>
      'This replaces all your plans, exercises and workout history with sample data. Export your data first if you want to keep it.';

  @override
  String get settings_demo_btn => 'Load';

  @override
  String get settings_demo_done => 'Demo data loaded';

  @override
  String settings_version(String version) {
    return 'FitForge $version';
  }

  @override
  String get settings_dev_section => 'DEVELOPER';

  @override
  String get settings_dev_unlocked => 'Developer options enabled';

  @override
  String settings_dev_taps_left(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count more taps to enable developer options',
      one: '1 more tap to enable developer options',
    );
    return '$_temp0';
  }

  @override
  String get settings_dev_hide => 'Hide developer options';

  @override
  String get settings_dev_hide_sub =>
      'Tap the version 7 times to show them again';
}
