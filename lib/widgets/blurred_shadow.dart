import 'dart:ui';

import 'package:flutter/widgets.dart';

/// A soft shadow made by blurring a shape, like a Figma layer blur.
/// Put it in a [Stack] behind the widget that casts the shadow.
class BlurredShadow extends StatelessWidget {
  const BlurredShadow({
    super.key,
    required this.color,
    required this.sigma,
    this.borderRadius,
    this.shape = BoxShape.rectangle,
  });

  final Color color;

  /// Figma "blur" / CSS blur(px) value, i.e. the standard deviation.
  final double sigma;
  final BorderRadius? borderRadius;
  final BoxShape shape;

  @override
  Widget build(BuildContext context) {
    return ImageFiltered(
      imageFilter: ImageFilter.blur(
        sigmaX: sigma,
        sigmaY: sigma,
        tileMode: TileMode.decal,
      ),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: color,
          borderRadius: borderRadius,
          shape: shape,
        ),
      ),
    );
  }
}
