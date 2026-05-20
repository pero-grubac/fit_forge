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
  String get motivationTitle => 'Motivation of the day';

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
  String get log_notes_label => 'Note (optional)';

  @override
  String get log_volume => 'Total volume';

  @override
  String get log_progression_title => 'Progression suggestion';

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
}
