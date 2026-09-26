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
  String get motivationTitle => 'Motivacija';

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
  String get exercise_description_label => 'Opis';

  @override
  String get exercise_description_hint => 'npr. Drži leđa ravno...';

  @override
  String get exercise_youtube_label => 'YouTube link (opciono)';

  @override
  String get exercise_watch_youtube => 'Pogledaj na YouTube';

  @override
  String get log_save => 'Spremi trening';

  @override
  String get log_add_set => 'Dodaj set';

  @override
  String get log_notes_hint => 'Npr. dobra pumpa, povećaj sljedeći put...';

  @override
  String get log_notes_label => 'Bilješka za ovaj trening';

  @override
  String get log_volume => 'Ukupni volumen';

  @override
  String get log_progression_title => 'Prijedlog progresije';

  @override
  String log_progression_increase(String increment) {
    return 'Odlično! Povećavamo za $increment kg';
  }

  @override
  String get log_progression_hold => 'Zadrži težinu — skoro si spreman';

  @override
  String get log_progression_reduce =>
      'Fokusiraj se na tehniku — malo smanjujemo težinu';

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

  @override
  String get muscle_forearms => 'Podlaktice';

  @override
  String get muscle_bodyweight => 'Tjelesna težina';

  @override
  String get exercise_search_hint => 'Pretraži vježbe...';

  @override
  String get exercise_seconds_label => 'Sekunde';

  @override
  String get exercise_sets_count_label => 'Setovi';

  @override
  String get exercise_type_weighted => 'Sa težinom';

  @override
  String get exercise_type_bodyweight => 'Tjelesna težina';

  @override
  String get exercise_type_timed => 'Vremenski';

  @override
  String get btn_remove => 'Ukloni';

  @override
  String get exercise_remove_title => 'Ukloni iz plana';

  @override
  String exercise_remove_confirm(String name) {
    return 'Ukloniti \"$name\" iz ovog plana? Istorija treninga ostaje sačuvana.';
  }

  @override
  String get exercise_delete_everywhere => 'Obriši vježbu i istoriju';

  @override
  String exercise_delete_everywhere_confirm(String name) {
    return 'Obrisati \"$name\" iz svih planova zajedno sa cijelom istorijom treninga? Ovo se ne može poništiti.';
  }

  @override
  String exercise_shared_hint(int count) {
    return 'Koristi se u $count plana — izmjene važe za sve.';
  }

  @override
  String get exercise_already_in_plan => 'Ova vježba je već u planu';

  @override
  String get exercise_in_plan => 'Već u planu';

  @override
  String exercise_create_custom(String name) {
    return 'Napravi \"$name\"';
  }

  @override
  String get progress_one_rep_max => 'Proc. 1RM';

  @override
  String log_progression_increase_reps(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Odlično! Dodajemo $count ponavljanja po setu',
      one: 'Odlično! Dodajemo 1 ponavljanje po setu',
    );
    return '$_temp0';
  }

  @override
  String log_progression_increase_seconds(int count) {
    return 'Odlično! Dodajemo $count s po setu';
  }

  @override
  String get log_progression_hold_reps =>
      'Zadrži iste ciljeve — skoro si spreman';

  @override
  String get log_progression_reduce_reps =>
      'Fokusiraj se na tehniku — malo smanjujemo';

  @override
  String get settings_data_section => 'PODACI';

  @override
  String get settings_export => 'Izvezi podatke';

  @override
  String get settings_export_sub => 'Sačuvaj planove, vježbe i istoriju u fajl';

  @override
  String get settings_export_done => 'Rezervna kopija sačuvana';

  @override
  String get settings_import => 'Uvezi podatke';

  @override
  String get settings_import_sub => 'Vrati podatke iz rezervne kopije';

  @override
  String get settings_import_confirm =>
      'Uvoz zamjenjuje sve trenutne planove, vježbe i istoriju treninga podacima iz kopije. Slike vježbi nisu dio kopije. Nastaviti?';

  @override
  String get settings_import_btn => 'Uvezi';

  @override
  String get settings_import_done => 'Podaci vraćeni';

  @override
  String get settings_import_invalid =>
      'Ovaj fajl nije ispravna FitForge rezervna kopija';

  @override
  String get rest_title => 'Odmor';

  @override
  String get rest_skip => 'Preskoči';

  @override
  String get rest_notification_title => 'Odmor';

  @override
  String get rest_done_title => 'Odmor je gotov';

  @override
  String rest_done_body(String exercise) {
    return 'Vrijeme je za sljedeći set: $exercise';
  }

  @override
  String get settings_rest_section => 'TAJMER ODMORA';

  @override
  String get settings_rest => 'Odmor između setova';

  @override
  String get settings_rest_sub => 'Počinje nakon svakog završenog seta';

  @override
  String get settings_rest_off => 'Isklj.';

  @override
  String get nav_home => 'Početna';

  @override
  String get nav_progress => 'Napredak';

  @override
  String get nav_plans => 'Planovi';

  @override
  String get nav_settings => 'Podešavanja';

  @override
  String get exercise_edit => 'Uredi vježbu';

  @override
  String get exercise_add_description => 'Dodaj opis';

  @override
  String get log_show_more => 'Prikaži više';

  @override
  String get log_show_less => 'Prikaži manje';

  @override
  String log_last_note(String date) {
    return 'Prošli put ($date)';
  }

  @override
  String get plan_edit => 'Uredi plan';

  @override
  String get settings_demo => 'Učitaj demo podatke';

  @override
  String get settings_demo_sub =>
      'Primjer planova i 8 sedmica treninga za isprobavanje';

  @override
  String get settings_demo_confirm =>
      'Ovo zamjenjuje sve tvoje planove, vježbe i istoriju treninga primjerima. Prvo izvezi podatke ako želiš da ih sačuvaš.';

  @override
  String get settings_demo_btn => 'Učitaj';

  @override
  String get settings_demo_done => 'Demo podaci učitani';

  @override
  String settings_version(String version) {
    return 'FitForge $version';
  }

  @override
  String get settings_dev_section => 'RAZVOJ';

  @override
  String get settings_dev_unlocked => 'Opcije za razvoj uključene';

  @override
  String settings_dev_taps_left(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Još $count dodira do opcija za razvoj',
      one: 'Još 1 dodir do opcija za razvoj',
    );
    return '$_temp0';
  }

  @override
  String get settings_dev_hide => 'Sakrij opcije za razvoj';

  @override
  String get settings_dev_hide_sub =>
      'Dodirni verziju 7 puta da ih ponovo prikažeš';
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
  String get motivationTitle => 'Мотивација';

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
  String get exercise_description_label => 'Опис';

  @override
  String get exercise_description_hint => 'нпр. Држи леђа равно...';

  @override
  String get exercise_youtube_label => 'YouTube линк (опционо)';

  @override
  String get exercise_watch_youtube => 'Погледај на YouTube';

  @override
  String get log_save => 'Спреми тренинг';

  @override
  String get log_add_set => 'Додај сет';

  @override
  String get log_notes_hint => 'Нпр. добра пумпа, повећај сљедећи пут...';

  @override
  String get log_notes_label => 'Биљешка за овај тренинг';

  @override
  String get log_volume => 'Укупни волумен';

  @override
  String get log_progression_title => 'Приједлог прогресије';

  @override
  String log_progression_increase(String increment) {
    return 'Одлично! Повећавамо за $increment kg';
  }

  @override
  String get log_progression_hold => 'Задржи тежину — скоро си спреман';

  @override
  String get log_progression_reduce =>
      'Фокусирај се на технику — мало смањујемо тежину';

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

  @override
  String get muscle_forearms => 'Подлактице';

  @override
  String get muscle_bodyweight => 'Тјелесна тежина';

  @override
  String get exercise_search_hint => 'Претражи вјежбе...';

  @override
  String get exercise_seconds_label => 'Секунде';

  @override
  String get exercise_sets_count_label => 'Сетови';

  @override
  String get exercise_type_weighted => 'Са тежином';

  @override
  String get exercise_type_bodyweight => 'Тјелесна тежина';

  @override
  String get exercise_type_timed => 'Временски';

  @override
  String get btn_remove => 'Уклони';

  @override
  String get exercise_remove_title => 'Уклони из плана';

  @override
  String exercise_remove_confirm(String name) {
    return 'Уклонити \"$name\" из овог плана? Историја тренинга остаје сачувана.';
  }

  @override
  String get exercise_delete_everywhere => 'Обриши вјежбу и историју';

  @override
  String exercise_delete_everywhere_confirm(String name) {
    return 'Обрисати \"$name\" из свих планова заједно са цијелом историјом тренинга? Ово се не може поништити.';
  }

  @override
  String exercise_shared_hint(int count) {
    return 'Користи се у $count плана — измјене важе за све.';
  }

  @override
  String get exercise_already_in_plan => 'Ова вјежба је већ у плану';

  @override
  String get exercise_in_plan => 'Већ у плану';

  @override
  String exercise_create_custom(String name) {
    return 'Направи \"$name\"';
  }

  @override
  String get progress_one_rep_max => 'Проц. 1RM';

  @override
  String log_progression_increase_reps(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Одлично! Додајемо $count понављања по сету',
      one: 'Одлично! Додајемо 1 понављање по сету',
    );
    return '$_temp0';
  }

  @override
  String log_progression_increase_seconds(int count) {
    return 'Одлично! Додајемо $count s по сету';
  }

  @override
  String get log_progression_hold_reps =>
      'Задржи исте циљеве — скоро си спреман';

  @override
  String get log_progression_reduce_reps =>
      'Фокусирај се на технику — мало смањујемо';

  @override
  String get settings_data_section => 'ПОДАЦИ';

  @override
  String get settings_export => 'Извези податке';

  @override
  String get settings_export_sub => 'Сачувај планове, вјежбе и историју у фајл';

  @override
  String get settings_export_done => 'Резервна копија сачувана';

  @override
  String get settings_import => 'Увези податке';

  @override
  String get settings_import_sub => 'Врати податке из резервне копије';

  @override
  String get settings_import_confirm =>
      'Увоз замјењује све тренутне планове, вјежбе и историју тренинга подацима из копије. Слике вјежби нису дио копије. Наставити?';

  @override
  String get settings_import_btn => 'Увези';

  @override
  String get settings_import_done => 'Подаци враћени';

  @override
  String get settings_import_invalid =>
      'Овај фајл није исправна FitForge резервна копија';

  @override
  String get rest_title => 'Одмор';

  @override
  String get rest_skip => 'Прескочи';

  @override
  String get rest_notification_title => 'Одмор';

  @override
  String get rest_done_title => 'Одмор је готов';

  @override
  String rest_done_body(String exercise) {
    return 'Вријеме је за сљедећи сет: $exercise';
  }

  @override
  String get settings_rest_section => 'ТАЈМЕР ОДМОРА';

  @override
  String get settings_rest => 'Одмор између сетова';

  @override
  String get settings_rest_sub => 'Почиње након сваког завршеног сета';

  @override
  String get settings_rest_off => 'Искљ.';

  @override
  String get nav_home => 'Почетна';

  @override
  String get nav_progress => 'Напредак';

  @override
  String get nav_plans => 'Планови';

  @override
  String get nav_settings => 'Подешавања';

  @override
  String get exercise_edit => 'Уреди вјежбу';

  @override
  String get exercise_add_description => 'Додај опис';

  @override
  String get log_show_more => 'Прикажи више';

  @override
  String get log_show_less => 'Прикажи мање';

  @override
  String log_last_note(String date) {
    return 'Прошли пут ($date)';
  }

  @override
  String get plan_edit => 'Уреди план';

  @override
  String get settings_demo => 'Учитај демо податке';

  @override
  String get settings_demo_sub =>
      'Примјер планова и 8 седмица тренинга за испробавање';

  @override
  String get settings_demo_confirm =>
      'Ово замјењује све твоје планове, вјежбе и историју тренинга примјерима. Прво извези податке ако желиш да их сачуваш.';

  @override
  String get settings_demo_btn => 'Учитај';

  @override
  String get settings_demo_done => 'Демо подаци учитани';

  @override
  String settings_version(String version) {
    return 'FitForge $version';
  }

  @override
  String get settings_dev_section => 'РАЗВОЈ';

  @override
  String get settings_dev_unlocked => 'Опције за развој укључене';

  @override
  String settings_dev_taps_left(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Још $count додира до опција за развој',
      one: 'Још 1 додир до опција за развој',
    );
    return '$_temp0';
  }

  @override
  String get settings_dev_hide => 'Сакриј опције за развој';

  @override
  String get settings_dev_hide_sub =>
      'Додирни верзију 7 пута да их поново прикажеш';
}
