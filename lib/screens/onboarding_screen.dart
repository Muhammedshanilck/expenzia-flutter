import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../app_scope.dart';
import '../core/constants/app_assets.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';
import '../widgets/blurred_shadow.dart';
import 'main_shell.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  /// Width and height of the illustration area in the Figma frame.
  static const double _designWidth = 414;
  static const double _illustrationHeight = 613;

  Future<void> _getStarted(BuildContext context) async {
    await AppScope.of(context).profile.completeOnboarding();
    if (!context.mounted) return;
    Navigator.of(
      context,
    ).pushReplacement(MaterialPageRoute(builder: (_) => const MainShell()));
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final scale = width / _designWidth;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: AppColors.white,
        body: Column(
          children: [
            // Illustration: background shape, man, coin and donut chart,
            // placed at their Figma coordinates and scaled to the screen width.
            SizedBox(
              width: width,
              height: _illustrationHeight * scale,
              child: FittedBox(
                fit: BoxFit.fill,
                child: SizedBox(
                  width: _designWidth,
                  height: _illustrationHeight,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      SvgPicture.asset(
                        AppAssets.onboardingBackground,
                        width: 414,
                        height: 600,
                      ),
                      Positioned(
                        left: 0,
                        top: 126.91,
                        width: 414,
                        height: 487,
                        child: Image.asset(AppAssets.onboardingMan),
                      ),
                      Positioned(
                        left: 58,
                        top: 118,
                        width: 128,
                        height: 124,
                        child: Image.asset(AppAssets.onboardingCoin),
                      ),
                      Positioned(
                        left: 258,
                        top: 192,
                        width: 108,
                        height: 110,
                        child: Image.asset(AppAssets.onboardingDonut),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight,
                      ),
                      child: Column(
                        children: [
                          const SizedBox(height: 30),
                          const Text(
                            'Spend Smarter\nSave More',
                            textAlign: TextAlign.center,
                            style: AppTextStyles.onboardingTitle,
                          ),
                          const SizedBox(height: 26),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 28),
                            child: _GetStartedButton(
                              onPressed: () => _getStarted(context),
                            ),
                          ),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 64 px tall gradient pill with a soft teal shadow.
/// The gradient colours and shadow are sampled from the Figma render, because
/// the exact layer properties could not be read (Figma API limit).
class _GetStartedButton extends StatelessWidget {
  const _GetStartedButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 64,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Figma "Rectangle 10": 352 x 36 shape 31 px below the button top,
          // blurred to form the shadow.
          const Positioned(
            left: 3,
            right: 3,
            top: 31,
            height: 36,
            child: BlurredShadow(
              color: AppColors.getStartedShadow,
              sigma: 20,
              borderRadius: BorderRadius.all(Radius.circular(18)),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(40),
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.getStartedGradientTop,
                  AppColors.getStartedGradientBottom,
                ],
              ),
            ),
            child: Material(
              type: MaterialType.transparency,
              child: InkWell(
                onTap: onPressed,
                borderRadius: BorderRadius.circular(40),
                child: const Center(
                  child: Text('Get Started', style: AppTextStyles.button),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
