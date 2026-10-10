import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../core/constants/app_assets.dart';
import '../core/theme/app_colors.dart';
import 'blurred_shadow.dart';

/// The curved bottom bar with the raised "+" button.
/// All positions are the Figma values measured from the top of the
/// add button (y = 753 on the 414 x 896 frame) and scaled to the screen width.
class AppBottomNav extends StatelessWidget {
  const AppBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTabSelected,
    required this.onAddPressed,
  });

  final int currentIndex;
  final ValueChanged<int> onTabSelected;
  final VoidCallback onAddPressed;

  static const double designWidth = 414;
  static const double height = 143;

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return LayoutBuilder(
      builder: (context, constraints) {
        final scale = constraints.maxWidth / designWidth;

        Widget tab({
          required int index,
          required double left,
          required double top,
          required double width,
          required double height,
          required String icon,
          required String activeIcon,
          required String label,
        }) {
          final isActive = currentIndex == index;
          return Positioned(
            left: left * scale - 10,
            top: top - 10,
            child: Semantics(
              label: label,
              button: true,
              selected: isActive,
              child: InkResponse(
                onTap: () => onTabSelected(index),
                radius: 28,
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: SvgPicture.asset(
                    isActive ? activeIcon : icon,
                    width: width,
                    height: height,
                  ),
                ),
              ),
            ),
          );
        }

        return SizedBox(
          height: height + bottomInset,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // Curved teal bar with the notch for the add button.
              Positioned(
                left: 0,
                right: 0,
                top: 63,
                height: 80,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Figma drop shadow: y -2, blur 12.5, black 6 %.
                    Transform.translate(
                      offset: const Offset(0, -2),
                      child: ImageFiltered(
                        imageFilter: ImageFilter.blur(
                          sigmaX: 12.5,
                          sigmaY: 12.5,
                          tileMode: TileMode.decal,
                        ),
                        child: CustomPaint(
                          painter: _NavBarPainter(
                            scale: scale,
                            color: const Color(0x0F000000),
                          ),
                        ),
                      ),
                    ),
                    CustomPaint(
                      painter: _NavBarPainter(
                        scale: scale,
                        color: AppColors.green,
                      ),
                    ),
                  ],
                ),
              ),
              // Fills the area below the bar on phones with a home indicator.
              if (bottomInset > 0)
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  height: bottomInset,
                  child: const ColoredBox(color: AppColors.green),
                ),
              tab(
                index: 0,
                left: 35,
                top: 92,
                width: 31,
                height: 30,
                icon: AppAssets.navHome,
                activeIcon: AppAssets.navHomeActive,
                label: 'Home',
              ),
              tab(
                index: 1,
                left: 109,
                top: 92,
                width: 30,
                height: 30,
                icon: AppAssets.navHistory,
                activeIcon: AppAssets.navHistoryActive,
                label: 'Transaction history',
              ),
              tab(
                index: 2,
                left: 271.16,
                top: 91.15,
                width: 31.5875,
                height: 27.6875,
                icon: AppAssets.navWallet,
                activeIcon: AppAssets.navWalletActive,
                label: 'Credit',
              ),
              tab(
                index: 3,
                left: 349,
                top: 91,
                width: 29.4133,
                height: 28.0002,
                icon: AppAssets.navProfile,
                activeIcon: AppAssets.navProfileActive,
                label: 'Profile',
              ),
              // Blurred dark circle under the add button
              // (Figma "Ellipse 15": #1F615C, 80 % opacity, blur 24).
              Positioned(
                left: (169.5 + 37.5) * scale - 37.5 + 11.25,
                top: 22.5 + 25.4,
                width: 53.44,
                height: 53.44,
                child: const BlurredShadow(
                  color: Color(0xCC1F615C),
                  sigma: 24,
                  shape: BoxShape.circle,
                ),
              ),
              // Raised add button: 75 px teal circle with a white "+".
              Positioned(
                left: (169.5 + 37.5) * scale - 37.5,
                top: 22.5,
                child: Semantics(
                  label: 'Add transaction',
                  button: true,
                  child: Material(
                    color: AppColors.green,
                    shape: const CircleBorder(),
                    clipBehavior: Clip.antiAlias,
                    child: InkWell(
                      onTap: onAddPressed,
                      child: const SizedBox(
                        width: 75,
                        height: 75,
                        child: _PlusIcon(),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// White "+" from the Figma add-outline icon: 21 px lines, 3 px wide.
class _PlusIcon extends StatelessWidget {
  const _PlusIcon();

  @override
  Widget build(BuildContext context) {
    Widget line(double width, double height) => Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(1.5),
      ),
    );
    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: [line(24.1, 3), line(3, 24.1)],
      ),
    );
  }
}

/// Draws the bar shape from the Figma "Subtract" layer: a 414 x 80 rectangle
/// with a round notch for the add button.
class _NavBarPainter extends CustomPainter {
  _NavBarPainter({required this.scale, required this.color});

  final double scale;
  final Color color;

  Path _path(Size size) {
    double x(double value) => value * scale;
    return Path()
      ..moveTo(0, 0)
      ..lineTo(x(162.102), 0)
      ..cubicTo(x(163.645), 23.454, x(183.155), 42, x(207), 42)
      ..cubicTo(x(230.845), 42, x(250.355), 23.454, x(251.898), 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
  }

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawPath(_path(size), Paint()..color = color);
  }

  @override
  bool shouldRepaint(_NavBarPainter oldDelegate) =>
      oldDelegate.scale != scale || oldDelegate.color != color;
}
