import 'package:flutter/material.dart';
import 'dart:ui';

class GlassContainer extends StatelessWidget {
  final Widget child;

  final double borderRadius;
  final Color? color;
  final EdgeInsets? padding;
  final double blur;
  final bool showShadow;

  const GlassContainer({
    super.key,
    required this.child,
    this.borderRadius = 25,
    this.color,
    this.padding,
    this.blur = 15,
    this.showShadow = true,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    final double responsiveRadius = size.width * (borderRadius / 400);

    final double responsiveBlur = size.width * (blur / 400);

    final EdgeInsets responsivePadding =
        padding ??
        EdgeInsets.symmetric(
          horizontal: size.width * 0.04,
          vertical: size.height * 0.015,
        );

    return ClipRRect(
      borderRadius: BorderRadius.circular(responsiveRadius.clamp(15, 35)),

      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: responsiveBlur.clamp(8, 25),
          sigmaY: responsiveBlur.clamp(8, 25),
        ),

        child: Container(
          width: double.infinity,

          padding: responsivePadding,

          decoration: BoxDecoration(
            color: color ?? Colors.white.withValues(alpha: 0.20),

            borderRadius: BorderRadius.circular(responsiveRadius.clamp(15, 35)),

            border: Border.all(
              color: Colors.white.withValues(alpha: 0.25),
              width: size.width * 0.0025,
            ),

            boxShadow: showShadow
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),

                      blurRadius: size.width * 0.05,

                      offset: Offset(0, size.height * 0.012),
                    ),
                  ]
                : [],
          ),

          child: child,
        ),
      ),
    );
  }
}
