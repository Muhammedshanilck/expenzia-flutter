import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../app_scope.dart';
import '../core/constants/app_assets.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';
import 'main_shell.dart';
import 'onboarding_screen.dart';

/// Teal gradient with the "Expenzia" wordmark. Loads the saved data from
/// SQLite while it is visible, then opens onboarding (first launch) or Home.
class SplashScreen extends StatefulWidget {
  const SplashScreen({
    super.key,
    this.minimumDuration = const Duration(milliseconds: 1500),
  });

  final Duration minimumDuration;

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _started = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_started) {
      _started = true;
      _loadAndContinue();
    }
  }

  Future<void> _loadAndContinue() async {
    final scope = AppScope.of(context);
    final results = await Future.wait([
      scope.profile.isOnboardingDone(),
      scope.expenses.loadExpenses(),
      scope.credits.loadCredits(),
      scope.profile.loadProfile(),
      Future<void>.delayed(widget.minimumDuration),
    ]);
    if (!mounted) return;

    final onboardingDone = results.first as bool;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) =>
            onboardingDone ? const MainShell() : const OnboardingScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        body: Container(
          // Figma: linear-gradient(153.16deg, #63B5AF 4.48%, #438883 102.95%)
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment(-1.083, -0.981),
              end: Alignment(1.083, 0.981),
              stops: [0.045, 1.0],
              colors: [
                AppColors.splashGradientStart,
                AppColors.splashGradientEnd,
              ],
            ),
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Grain texture at 10 % opacity.
              Opacity(
                opacity: 0.1,
                child: Image.asset(
                  AppAssets.splashTexture,
                  fit: BoxFit.cover,
                  alignment: Alignment.topLeft,
                ),
              ),
              const Center(
                child: Text('Expenzia', style: AppTextStyles.splashTitle),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
