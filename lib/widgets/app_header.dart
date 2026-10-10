import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../core/constants/app_assets.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';

/// Teal header used on every inner screen.
/// In Figma it is 134 px tall including the 44 px status bar,
/// with the title and back arrow centred 95 px from the top.
class AppHeader extends StatelessWidget {
  const AppHeader({super.key, required this.title, this.onBack});

  final String title;

  /// Shows the back chevron when not null.
  final VoidCallback? onBack;

  static const double contentHeight = 90;

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.paddingOf(context).top;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Container(
        color: AppColors.primary,
        padding: EdgeInsets.only(top: topPadding),
        height: topPadding + contentHeight,
        child: Stack(
          children: [
            Positioned(
              left: 0,
              right: 0,
              top: 41,
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: AppTextStyles.headerTitle,
              ),
            ),
            if (onBack != null)
              Positioned(
                left: 14,
                top: 27,
                child: IconButton(
                  onPressed: onBack,
                  tooltip: 'Back',
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints.tightFor(
                    width: 48,
                    height: 48,
                  ),
                  icon: SvgPicture.asset(
                    AppAssets.chevronLeft,
                    width: 28,
                    height: 28,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
