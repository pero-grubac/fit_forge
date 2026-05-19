import 'package:fit_forge/core/router/route_names.dart';
import 'package:fit_forge/features/onboarding/pages/onboarding_page.dart';
import 'package:fit_forge/features/progress/pages/progress_page.dart';
import 'package:fit_forge/features/settings/pages/settings_page.dart';
import 'package:fit_forge/features/settings/providers/settings_provider.dart';
import 'package:fit_forge/features/workout_log/pages/today_workout_page.dart';
import 'package:fit_forge/features/workout_plan/pages/plan_list_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final notifier = _RouterNotifier(ref);

  return GoRouter(
    initialLocation: RouteNames.home,
    refreshListenable: notifier,
    redirect: (context, state) {
      final isSetupDone = notifier.isSetupDone;
      if (!isSetupDone && state.matchedLocation != RouteNames.onboarding) {
        return RouteNames.onboarding;
      }
      return null;
    },
    routes: [
      GoRoute(
        path: RouteNames.onboarding,
        builder: (context, state) => const OnboardingPage(),
      ),
      ShellRoute(
        builder: (context, state, child) => MainShell(child: child),
        routes: [
          GoRoute(
            path: RouteNames.home,
            builder: (context, state) => const TodayWorkoutPage(),
          ),
          GoRoute(
            path: RouteNames.progress,
            builder: (context, state) => const ProgressPage(),
          ),
          GoRoute(
            path: RouteNames.plans,
            builder: (context, state) => const PlanListPage(),
          ),
          GoRoute(
            path: RouteNames.settings,
            builder: (context, state) => const SettingsPage(),
          ),
        ],
      ),
    ],
  );
});

class _RouterNotifier extends ChangeNotifier {
  _RouterNotifier(this._ref) {
    _ref.listen(settingsProvider, (_, __) => notifyListeners());
  }

  final Ref _ref;

  bool get isSetupDone => _ref.read(settingsProvider).maybeWhen(
        data: (s) => s.isSetupDone,
        orElse: () => true,
      );
}

class MainShell extends StatelessWidget {
  const MainShell({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;

    int currentIndex = switch (location) {
      '/home' => 0,
      '/progress' => 1,
      '/plans' => 2,
      '/settings' => 3,
      _ => 0,
    };

    return Scaffold(
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (index) {
          switch (index) {
            case 0:
              context.go(RouteNames.home);
            case 1:
              context.go(RouteNames.progress);
            case 2:
              context.go(RouteNames.plans);
            case 3:
              context.go(RouteNames.settings);
          }
        },
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.home_rounded), label: 'Home'),
          BottomNavigationBarItem(
              icon: Icon(Icons.bar_chart_rounded), label: 'Progres'),
          BottomNavigationBarItem(
              icon: Icon(Icons.calendar_month), label: 'Plan'),
          BottomNavigationBarItem(
              icon: Icon(Icons.settings_rounded), label: 'Settings'),
        ],
      ),
    );
  }
}
