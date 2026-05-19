import 'package:fit_forge/core/router/route_names.dart';
import 'package:fit_forge/core/theme/app_colors.dart';
import 'package:fit_forge/core/utils/l10n_extension.dart';
import 'package:fit_forge/features/settings/providers/settings_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class OnboardingPage extends ConsumerStatefulWidget {
  const OnboardingPage({super.key});

  @override
  ConsumerState<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends ConsumerState<OnboardingPage> {
  final _controller = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _next() {
    if (_currentPage < 2) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _finish() async {
    await ref.read(settingsProvider.notifier).markSetupDone();
    if (mounted) context.go(RouteNames.plans);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            // Skip dugme
            if (_currentPage < 2)
              Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(0, 12, 16, 0),
                  child: TextButton(
                    onPressed: _finish,
                    child: Text(context.l10n.onboarding_skip,
                        style: const TextStyle(
                            color: AppColors.text2, fontSize: 14)),
                  ),
                ),
              )
            else
              const SizedBox(height: 48),

            // PageView
            Expanded(
              child: PageView(
                controller: _controller,
                onPageChanged: (i) => setState(() => _currentPage = i),
                children: const [
                  _WelcomePage(),
                  _HowItWorksPage(),
                  _GetStartedPage(),
                ],
              ),
            ),

            // Dots i dugme
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
              child: Column(
                children: [
                  // Dots
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                        3,
                        (i) => AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              width: _currentPage == i ? 24 : 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: _currentPage == i
                                    ? AppColors.accent
                                    : AppColors.bg4,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            )),
                  ),
                  const SizedBox(height: 24),

                  // Dugme
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _currentPage < 2 ? _next : _finish,
                      child: Text(
                        _currentPage < 2
                            ? context.l10n.onboarding_next
                            : context.l10n.onboarding_start,
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Ekran 1 — Dobrodošlica ────────────────────────────────────────────────────

class _WelcomePage extends StatelessWidget {
  const _WelcomePage();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Logo
          Image.asset(
            'assets/images/logo.png',
            width: 200,
            height: 200,
          ),
          const SizedBox(height: 32),
          Text(
            context.l10n.onboarding_welcome_title,
            textAlign: TextAlign.center,
            style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w800,
                color: AppColors.text1,
                height: 1.2),
          ),
          const SizedBox(height: 16),
          Text(
            context.l10n.appSlogan,
            style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: AppColors.accent),
          ),
          const SizedBox(height: 16),
          Text(
            context.l10n.onboarding_welcome_sub,
            textAlign: TextAlign.center,
            style: const TextStyle(
                fontSize: 15, color: AppColors.text2, height: 1.6),
          ),
        ],
      ),
    );
  }
}

// ── Ekran 2 — Kako radi ───────────────────────────────────────────────────────

class _HowItWorksPage extends StatelessWidget {
  const _HowItWorksPage();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            context.l10n.onboarding_how_title,
            style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: AppColors.text1),
          ),
          const SizedBox(height: 48),
          _Step(
            number: '1',
            title: context.l10n.onboarding_step1_title,
            subtitle: context.l10n.onboarding_step1_sub,
            color: AppColors.accent,
          ),
          const SizedBox(height: 8),
          _Arrow(),
          const SizedBox(height: 8),
          _Step(
            number: '2',
            title: context.l10n.onboarding_step2_title,
            subtitle: context.l10n.onboarding_step2_sub,
            color: AppColors.green,
          ),
          const SizedBox(height: 8),
          _Arrow(),
          const SizedBox(height: 8),
          _Step(
            number: '3',
            title: context.l10n.onboarding_step3_title,
            subtitle: context.l10n.onboarding_step3_sub,
            color: AppColors.amber,
          ),
        ],
      ),
    );
  }
}

class _Step extends StatelessWidget {
  const _Step({
    required this.number,
    required this.title,
    required this.subtitle,
    required this.color,
  });

  final String number;
  final String title;
  final String subtitle;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(number,
                  style: TextStyle(
                      fontSize: 18, fontWeight: FontWeight.w800, color: color)),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.text1)),
                const SizedBox(height: 2),
                Text(subtitle,
                    style:
                        const TextStyle(fontSize: 13, color: AppColors.text2)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Arrow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Icon(
      Icons.keyboard_arrow_down_rounded,
      color: AppColors.text3,
      size: 24,
    );
  }
}

// ── Ekran 3 — Počni ───────────────────────────────────────────────────────────

class _GetStartedPage extends StatelessWidget {
  const _GetStartedPage();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: AppColors.accent.withOpacity(0.15),
              borderRadius: BorderRadius.circular(28),
            ),
            child: const Icon(
              Icons.fitness_center_rounded,
              size: 50,
              color: AppColors.accent,
            ),
          ),
          const SizedBox(height: 32),
          Text(
            context.l10n.onboarding_getstarted_title,
            style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w800,
                color: AppColors.text1),
          ),
          const SizedBox(height: 16),
          Text(
            context.l10n.onboarding_getstarted_sub,
            textAlign: TextAlign.center,
            style: const TextStyle(
                fontSize: 15, color: AppColors.text2, height: 1.6),
          ),
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                const Icon(Icons.lightbulb_outline,
                    color: AppColors.amber, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    context.l10n.onboarding_tip,
                    style:
                        const TextStyle(fontSize: 13, color: AppColors.text2),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
