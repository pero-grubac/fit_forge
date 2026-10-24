// Walks through the app for the README demo video. Not part of the normal
// test run; used with screen recording:
//   flutter test integration_test/demo_recording_test.dart -d <emulator>
// It prints DEMO_START / DEMO_END so a script can start and stop recording.
import 'package:fit_forge/core/services/rest_alerts.dart';
import 'package:fit_forge/data/local/database_helper.dart';
import 'package:fit_forge/data/providers.dart';
import 'package:fit_forge/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// No system notifications (and no permission dialog) in the recording.
class _SilentRestAlerts implements RestAlerts {
  @override
  Future<void> start(DateTime endsAt, RestAlertTexts texts) async {}

  @override
  Future<void> cancel() async {}
}

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  binding.framePolicy = LiveTestWidgetsFlutterBindingFramePolicy.fullyLive;

  testWidgets('demo walkthrough', (tester) async {
    Future<void> wait(int ms) async {
      await Future<void>.delayed(Duration(milliseconds: ms));
      await tester.pump();
    }

    Future<void> tap(Finder finder, {int after = 1200}) async {
      await tester.tap(finder.first);
      await wait(after);
    }

    /// Smoothly scrolls [finder] into view, like a person would.
    Future<void> scrollTo(Finder finder, {double alignment = 0.4}) async {
      await Scrollable.ensureVisible(
        tester.element(finder.first),
        alignment: alignment,
        duration: const Duration(milliseconds: 700),
        curve: Curves.easeInOut,
      );
      await wait(900);
    }

    // Fresh demo data and settings, then start the app.
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    await prefs.setBool('is_setup_done', true);
    await prefs.setString('locale', 'en');
    await prefs.setInt('rest_seconds', 60);

    await DatabaseHelper.instance.initialize();
    final container = ProviderContainer();
    await container.read(demoDataProvider).load();
    container.dispose();

    await tester.pumpWidget(ProviderScope(
      overrides: [restAlertsProvider.overrideWithValue(_SilentRestAlerts())],
      child: const FitForgeApp(),
    ));
    await wait(2500);

    // ignore: avoid_print
    print('DEMO_START');
    await wait(2500); // recording starts

    // Home: today's plan and a motivational quote.
    await wait(2500);

    // Log a workout: description, progression banner, sets, rest timer.
    await tap(find.text('Bench Press'), after: 2500);
    await scrollTo(find.byKey(const Key('set_toggle_1')), alignment: 0.6);
    await tap(find.byKey(const Key('set_toggle_1')), after: 2500);
    await tap(find.text('+15 s'), after: 1500);
    await tap(find.text('Skip'), after: 1000);
    await tap(find.byKey(const Key('set_toggle_2')), after: 1200);
    await tap(find.text('Skip'), after: 800);
    await tap(find.byKey(const Key('set_toggle_3')), after: 1500);
    await tap(find.text('Save workout'), after: 2500);

    // Progress: chart with estimated 1RM and records.
    await tap(find.byIcon(Icons.bar_chart_rounded), after: 1500);
    await tap(find.byType(DropdownButton<String>), after: 1200);
    await tap(find.text('Squat').last, after: 2500);
    await scrollTo(find.text('Personal record'), alignment: 0.8);
    await wait(1500);

    // Plans: a plan's exercises and the targets & progression sheet.
    await tap(find.byIcon(Icons.calendar_month).last, after: 1500);
    await tap(find.text('Push'), after: 2000);
    await tap(find.byKey(const Key('targets_Bench Press')), after: 3500);
    await tester.tapAt(const Offset(200, 120)); // close the sheet
    await wait(1200);
    await tester.pageBack();
    await wait(1200);

    // Settings: progression, rest timer, backup.
    await tap(find.byIcon(Icons.settings_rounded), after: 1500);
    await scrollTo(find.text('Automatic increase'), alignment: 0.2);
    await wait(2000);
    await scrollTo(find.text('Export data'), alignment: 0.3);
    await wait(2000);

    // Back home.
    await tap(find.byIcon(Icons.home_rounded), after: 2500);

    // ignore: avoid_print
    print('DEMO_END');
    await wait(1000);
  });
}
