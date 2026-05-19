// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Serbian (`sr`).
class AppLocalizationsSr extends AppLocalizations {
  AppLocalizationsSr([String locale = 'sr']) : super(locale);

  @override
  String get appName => 'Fit Forge';

  @override
  String get appSlogan => 'Zašto ne ti?';

  @override
  String get navHome => 'Početna';

  @override
  String get navProgress => 'Napredak';

  @override
  String get navPlan => 'Plan';

  @override
  String get navSettings => 'Podešavanja';

  @override
  String get greeting_morning => 'Dobro jutro';

  @override
  String get greeting_afternoon => 'Dobar dan';

  @override
  String get greeting_evening => 'Dobro veče';

  @override
  String get motivationTitle => 'Motivacija dana';

  @override
  String get days_monday => 'Ponedjeljak';

  @override
  String get days_tuesday => 'Utorak';

  @override
  String get days_wednesday => 'Srijeda';

  @override
  String get days_thursday => 'Četvrtak';

  @override
  String get days_friday => 'Petak';

  @override
  String get days_saturday => 'Subota';

  @override
  String get days_sunday => 'Nedjelja';

  @override
  String get home_noplan => 'Nemaš plan za danas';

  @override
  String get home_noplan_sub => 'Kreiraj plan u Plan editoru';

  @override
  String home_sets(int completed, int total) {
    return '$completed/$total seta';
  }

  @override
  String get status_done => 'Gotovo';

  @override
  String get status_active => 'Aktivno';

  @override
  String get status_waiting => 'Čeka';

  @override
  String get plan_editor_title => 'Plan editor';

  @override
  String get plan_new => 'Novi plan';

  @override
  String get plan_no_plans => 'Nemaš nijedan plan';

  @override
  String get plan_no_plans_sub => 'Kreiraj prvi workout plan';

  @override
  String get plan_create => 'Kreiraj plan';

  @override
  String get plan_name_hint => 'npr. Push Day A';

  @override
  String get plan_name_label => 'Naziv plana';

  @override
  String get plan_day_label => 'Dan sedmice';

  @override
  String get plan_delete_title => 'Obriši plan';

  @override
  String plan_delete_confirm(String name) {
    return 'Jesi siguran da želiš obrisati \"$name\"?';
  }

  @override
  String get exercise_add => 'Dodaj vježbu';

  @override
  String get exercise_new => 'Nova vježba';

  @override
  String get exercise_name_hint => 'npr. Bench Press';

  @override
  String get exercise_name_label => 'Naziv vježbe';

  @override
  String get exercise_muscle_label => 'Mišićna grupa';

  @override
  String get exercise_sets_label => 'Setovi';

  @override
  String get exercise_reps_label => 'Repovi';

  @override
  String get exercise_weight_label => 'Početna težina (kg)';

  @override
  String get exercise_increment_label => 'Inkrement (kg)';

  @override
  String get exercise_save => 'Spremi vježbu';

  @override
  String get exercise_delete_title => 'Obriši vježbu';

  @override
  String exercise_delete_confirm(String name) {
    return 'Jesi siguran da želiš obrisati \"$name\"?';
  }

  @override
  String get exercise_no_exercises => 'Nema vježbi u planu';

  @override
  String get exercise_no_exercises_sub => 'Dodaj prvu vježbu';

  @override
  String get exercise_tap_image => 'Tapni za dodavanje slike';

  @override
  String get exercise_change_image => 'Promijeni sliku';

  @override
  String get log_save => 'Spremi trening';

  @override
  String get log_add_set => 'Dodaj set';

  @override
  String get log_notes_hint => 'Npr. dobra pumpa, povećaj sljedeći put...';

  @override
  String get log_notes_label => 'Bilješka (opciono)';

  @override
  String get log_volume => 'Ukupni volumen';

  @override
  String get log_progression_title => 'Prijedlog progresije';

  @override
  String get progress_title => 'Napredak';

  @override
  String get progress_no_data => 'Nema podataka za odabrani period';

  @override
  String get progress_no_workouts => 'Nemaš još nijedan trening';

  @override
  String get progress_no_workouts_sub => 'Pokreni trening na početnoj stranici';

  @override
  String get progress_max_weight => 'Max težina';

  @override
  String get progress_sessions => 'Treninga';

  @override
  String get progress_growth => 'Rast snage';

  @override
  String get progress_chart_weight => 'Max težina po treningu';

  @override
  String get progress_chart_volume => 'Volumen po treningu';

  @override
  String get progress_personal_record => 'Osobni rekord';

  @override
  String get progress_period_all => 'Sve';

  @override
  String get settings_title => 'Podešavanja';

  @override
  String get settings_progression_section => 'PRAVILA PROGRESIJE';

  @override
  String get settings_small_increment => 'Mali inkrement';

  @override
  String get settings_small_increment_sub => 'Za težine do 100 kg';

  @override
  String get settings_large_increment => 'Veliki inkrement';

  @override
  String get settings_large_increment_sub => 'Za težine iznad 100 kg';

  @override
  String get settings_threshold => 'Prag napretka';

  @override
  String get settings_threshold_sub =>
      'Min. completion rate za povećanje težine';

  @override
  String get settings_general_section => 'OPŠTE';

  @override
  String get settings_reset => 'Resetuj sve podatke';

  @override
  String get settings_reset_sub => 'Briše sve planove, vježbe i treninge';

  @override
  String get settings_reset_title => 'Resetuj sve podatke';

  @override
  String get settings_reset_confirm =>
      'Ovo će obrisati sve planove, vježbe i istoriju treninga. Ova akcija se ne može poništiti.';

  @override
  String get settings_quotes_section => 'MOTIVACIONE PORUKE';

  @override
  String get settings_quotes_add => 'Dodaj poruku';

  @override
  String get settings_quotes_add_sub => 'Kreiraj vlastitu motivacionu poruku';

  @override
  String get settings_quotes_empty =>
      'Nema korisničkih poruka — koriste se ugrađene.';

  @override
  String get settings_quote_new => 'Nova poruka';

  @override
  String get settings_quote_hint => 'Upiši svoju motivacionu poruku...';

  @override
  String get settings_quote_add_btn => 'Dodaj poruku';

  @override
  String get settings_language_section => 'Jezik';

  @override
  String get onboarding_welcome_title => 'Dobrodošao u\nFit Forge';

  @override
  String get onboarding_welcome_sub =>
      'Tvoj osobni fitness trener u džepu.\nPrati napredak, osvajaj ciljeve.';

  @override
  String get onboarding_how_title => 'Kako radi?';

  @override
  String get onboarding_step1_title => 'Kreiraj plan';

  @override
  String get onboarding_step1_sub =>
      'Dodaj vježbe, setove i težine za svaki dan';

  @override
  String get onboarding_step2_title => 'Odradite trening';

  @override
  String get onboarding_step2_sub => 'Loguj setove u realnom vremenu';

  @override
  String get onboarding_step3_title => 'Prati napredak';

  @override
  String get onboarding_step3_sub => 'Grafovi težine i volumena kroz vrijeme';

  @override
  String get onboarding_getstarted_title => 'Spreman si!';

  @override
  String get onboarding_getstarted_sub =>
      'Kreiraj svoj prvi plan treninga\ni počni graditi snagu danas.';

  @override
  String get onboarding_tip =>
      'Savjet: Počni s manjim težinama i fokusiraj se na tehniku.';

  @override
  String get onboarding_skip => 'Preskoči';

  @override
  String get onboarding_next => 'Dalje';

  @override
  String get onboarding_start => 'Počni';

  @override
  String get btn_cancel => 'Odustani';

  @override
  String get btn_delete => 'Obriši';

  @override
  String get btn_save => 'Spremi';

  @override
  String get btn_confirm => 'Potvrdi';

  @override
  String get btn_retry => 'Pokušaj ponovo';

  @override
  String get error_generic => 'Došlo je do greške. Pokušaj ponovo.';

  @override
  String get muscle_chest => 'Prsa';

  @override
  String get muscle_back => 'Leđa';

  @override
  String get muscle_shoulders => 'Ramena';

  @override
  String get muscle_biceps => 'Bicepsi';

  @override
  String get muscle_triceps => 'Tricepsi';

  @override
  String get muscle_legs => 'Noge';

  @override
  String get muscle_core => 'Trbuh';

  @override
  String get motivation_1 => 'Svaki kilogram koji digneš je dokaz tvoje snage.';

  @override
  String get motivation_2 => 'Ne pitaj se kako ćeš — pitaj se zašto nećeš.';

  @override
  String get motivation_3 =>
      'Snaga se ne gradi za jedan dan. Gradi se trening po trening.';

  @override
  String get motivation_4 => 'Težina ne laže. Niti ti.';

  @override
  String get motivation_5 => 'Svaki trening je investicija u sebe.';

  @override
  String get log_session_title => 'Trening';
}

/// The translations for Serbian, using the Cyrillic script (`sr_Cyrl`).
class AppLocalizationsSrCyrl extends AppLocalizationsSr {
  AppLocalizationsSrCyrl() : super('sr_Cyrl');

  @override
  String get appName => 'Fit Forge';

  @override
  String get appSlogan => 'Зашто не ти?';

  @override
  String get navHome => 'Почетна';

  @override
  String get navProgress => 'Напредак';

  @override
  String get navPlan => 'План';

  @override
  String get navSettings => 'Подешавања';

  @override
  String get greeting_morning => 'Добро јутро';

  @override
  String get greeting_afternoon => 'Добар дан';

  @override
  String get greeting_evening => 'Добро вече';

  @override
  String get motivationTitle => 'Мотивација дана';

  @override
  String get days_monday => 'Понедјељак';

  @override
  String get days_tuesday => 'Уторак';

  @override
  String get days_wednesday => 'Сриједа';

  @override
  String get days_thursday => 'Четвртак';

  @override
  String get days_friday => 'Петак';

  @override
  String get days_saturday => 'Субота';

  @override
  String get days_sunday => 'Недјеља';

  @override
  String get home_noplan => 'Немаш план за данас';

  @override
  String get home_noplan_sub => 'Креирај план у План едитору';

  @override
  String home_sets(int completed, int total) {
    return '$completed/$total сета';
  }

  @override
  String get status_done => 'Готово';

  @override
  String get status_active => 'Активно';

  @override
  String get status_waiting => 'Чека';

  @override
  String get plan_editor_title => 'План едитор';

  @override
  String get plan_new => 'Нови план';

  @override
  String get plan_no_plans => 'Немаш ниједан план';

  @override
  String get plan_no_plans_sub => 'Креирај први воркоут план';

  @override
  String get plan_create => 'Креирај план';

  @override
  String get plan_name_hint => 'нпр. Push Day A';

  @override
  String get plan_name_label => 'Назив плана';

  @override
  String get plan_day_label => 'Дан седмице';

  @override
  String get plan_delete_title => 'Обриши план';

  @override
  String plan_delete_confirm(String name) {
    return 'Јеси сигуран да желиш обрисати \"$name\"?';
  }

  @override
  String get exercise_add => 'Додај вјежбу';

  @override
  String get exercise_new => 'Нова вјежба';

  @override
  String get exercise_name_hint => 'нпр. Bench Press';

  @override
  String get exercise_name_label => 'Назив вјежбе';

  @override
  String get exercise_muscle_label => 'Мишићна група';

  @override
  String get exercise_sets_label => 'Сетови';

  @override
  String get exercise_reps_label => 'Репови';

  @override
  String get exercise_weight_label => 'Почетна тежина (kg)';

  @override
  String get exercise_increment_label => 'Инкремент (kg)';

  @override
  String get exercise_save => 'Спреми вјежбу';

  @override
  String get exercise_delete_title => 'Обриши вјежбу';

  @override
  String exercise_delete_confirm(String name) {
    return 'Јеси сигуран да желиш обрисати \"$name\"?';
  }

  @override
  String get exercise_no_exercises => 'Нема вјежби у плану';

  @override
  String get exercise_no_exercises_sub => 'Додај прву вјежбу';

  @override
  String get exercise_tap_image => 'Тапни за додавање слике';

  @override
  String get exercise_change_image => 'Промијени слику';

  @override
  String get log_save => 'Спреми тренинг';

  @override
  String get log_add_set => 'Додај сет';

  @override
  String get log_notes_hint => 'Нпр. добра пумпа, повећај сљедећи пут...';

  @override
  String get log_notes_label => 'Биљешка (опционо)';

  @override
  String get log_volume => 'Укупни волумен';

  @override
  String get log_progression_title => 'Приједлог прогресије';

  @override
  String get progress_title => 'Напредак';

  @override
  String get progress_no_data => 'Нема података за одабрани период';

  @override
  String get progress_no_workouts => 'Немаш још ниједан тренинг';

  @override
  String get progress_no_workouts_sub => 'Покрени тренинг на почетној страници';

  @override
  String get progress_max_weight => 'Макс тежина';

  @override
  String get progress_sessions => 'Тренинга';

  @override
  String get progress_growth => 'Раст снаге';

  @override
  String get progress_chart_weight => 'Макс тежина по тренингу';

  @override
  String get progress_chart_volume => 'Волумен по тренингу';

  @override
  String get progress_personal_record => 'Лични рекорд';

  @override
  String get progress_period_all => 'Све';

  @override
  String get settings_title => 'Подешавања';

  @override
  String get settings_progression_section => 'ПРАВИЛА ПРОГРЕСИЈЕ';

  @override
  String get settings_small_increment => 'Мали инкремент';

  @override
  String get settings_small_increment_sub => 'За тежине до 100 kg';

  @override
  String get settings_large_increment => 'Велики инкремент';

  @override
  String get settings_large_increment_sub => 'За тежине изнад 100 kg';

  @override
  String get settings_threshold => 'Праг напретка';

  @override
  String get settings_threshold_sub =>
      'Мин. completion rate за повећање тежине';

  @override
  String get settings_general_section => 'ОПШТЕ';

  @override
  String get settings_reset => 'Ресетуј све податке';

  @override
  String get settings_reset_sub => 'Брише све планове, вјежбе и тренинге';

  @override
  String get settings_reset_title => 'Ресетуј све податке';

  @override
  String get settings_reset_confirm =>
      'Ово ће обрисати све планове, вјежбе и историју тренинга. Ова акција се не може поништити.';

  @override
  String get settings_quotes_section => 'МОТИВАЦИОНЕ ПОРУКЕ';

  @override
  String get settings_quotes_add => 'Додај поруку';

  @override
  String get settings_quotes_add_sub => 'Креирај властиту мотивациону поруку';

  @override
  String get settings_quotes_empty =>
      'Нема корисничких порука — користе се уграђене.';

  @override
  String get settings_quote_new => 'Нова порука';

  @override
  String get settings_quote_hint => 'Упиши своју мотивациону поруку...';

  @override
  String get settings_quote_add_btn => 'Додај поруку';

  @override
  String get settings_language_section => 'Језик';

  @override
  String get onboarding_welcome_title => 'Добродошао у\nFit Forge';

  @override
  String get onboarding_welcome_sub =>
      'Твој особни фитнес тренер у џепу.\nПрати напредак, осваjај циљеве.';

  @override
  String get onboarding_how_title => 'Како ради?';

  @override
  String get onboarding_step1_title => 'Креирај план';

  @override
  String get onboarding_step1_sub =>
      'Додај вјежбе, сетове и тежине за сваки дан';

  @override
  String get onboarding_step2_title => 'Одрадите тренинг';

  @override
  String get onboarding_step2_sub => 'Логуј сетове у реалном времену';

  @override
  String get onboarding_step3_title => 'Прати напредак';

  @override
  String get onboarding_step3_sub => 'Графови тежине и волумена кроз вријеме';

  @override
  String get onboarding_getstarted_title => 'Спреман си!';

  @override
  String get onboarding_getstarted_sub =>
      'Креирај свој prvi план тренинга\nИ почни градити снагу данас.';

  @override
  String get onboarding_tip =>
      'Савјет: Почни с мањим тежинама и фокусирај се на технику.';

  @override
  String get onboarding_skip => 'Прескочи';

  @override
  String get onboarding_next => 'Даље';

  @override
  String get onboarding_start => 'Почни';

  @override
  String get btn_cancel => 'Одустани';

  @override
  String get btn_delete => 'Обриши';

  @override
  String get btn_save => 'Спреми';

  @override
  String get btn_confirm => 'Потврди';

  @override
  String get btn_retry => 'Покушај поново';

  @override
  String get error_generic => 'Дошло је до грешке. Покушај поново.';

  @override
  String get muscle_chest => 'Прса';

  @override
  String get muscle_back => 'Леђа';

  @override
  String get muscle_shoulders => 'Рамена';

  @override
  String get muscle_biceps => 'Бицепси';

  @override
  String get muscle_triceps => 'Трицепси';

  @override
  String get muscle_legs => 'Ноге';

  @override
  String get muscle_core => 'Трбух';

  @override
  String get motivation_1 => 'Сваки килограм који дигнеш је доказ твоје снаге.';

  @override
  String get motivation_2 => 'Не питај се како ћеш — питај се зашто нећеш.';

  @override
  String get motivation_3 =>
      'Снага се не гради за један дан. Гради се тренинг по тренинг.';

  @override
  String get motivation_4 => 'Тежина не лаже. Нити ти.';

  @override
  String get motivation_5 => 'Сваки тренинг је инвестиција у себе.';

  @override
  String get log_session_title => 'Тренинг';
}
