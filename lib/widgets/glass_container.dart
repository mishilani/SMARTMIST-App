import 'package:flutter/material.dart';
import 'dart:ui';

class GlassContainer extends StatelessWidget {
  final Widget child;

  final double borderRadius;
  final Color? color;
  final EdgeInsets padding;
  final double blur;
  final bool showShadow;

  const GlassContainer({
    super.key,
    required this.child,
    this.borderRadius = 25,
    this.color,
    this.padding = const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
    this.blur = 15,
    this.showShadow = true,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          width: double.infinity,
          padding: padding,
          decoration: BoxDecoration(
            color: color ?? Colors.white.withValues(alpha: 0.20),
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.25),
              width: 1,
            ),

            boxShadow: showShadow
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
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
