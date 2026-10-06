import 'dart:math' as math;
import 'package:flutter/material.dart';

/// A water tank visual that:
/// - smoothly animates its fill level when [isFilled] changes
/// - has a continuously looping wave at the water surface
/// - keeps the fill correctly clipped inside the tank outline
class AnimatedWaterTank extends StatefulWidget {
  final bool isFilled;
  final double width;
  final double height;
  final Color color;

  const AnimatedWaterTank({
    super.key,
    required this.isFilled,
    required this.width,
    required this.height,
    this.color = Colors.cyanAccent,
  });

  @override
  State<AnimatedWaterTank> createState() => _AnimatedWaterTankState();
}

class _AnimatedWaterTankState extends State<AnimatedWaterTank>
    with TickerProviderStateMixin {
  // Continuous wave motion (never stops, purely decorative)
  late final AnimationController _waveController;

  // Smooth transition between "filled" and "empty" levels
  late final AnimationController _levelController;
  late Animation<double> _levelAnimation;

  static const double _filledLevel = 0.78;
  static const double _emptyLevel = 0.08;

  double get _targetLevel => widget.isFilled ? _filledLevel : _emptyLevel;

  @override
  void initState() {
    super.initState();

    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();

    _levelController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
      value: 1,
    );

    _levelAnimation = Tween<double>(begin: _targetLevel, end: _targetLevel)
        .animate(
          CurvedAnimation(parent: _levelController, curve: Curves.easeInOut),
        );
  }

  @override
  void didUpdateWidget(covariant AnimatedWaterTank oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.isFilled != widget.isFilled) {
      final currentLevel = _levelAnimation.value;

      _levelAnimation = Tween<double>(begin: currentLevel, end: _targetLevel)
          .animate(
            CurvedAnimation(parent: _levelController, curve: Curves.easeInOut),
          );

      _levelController
        ..reset()
        ..forward();
    }
  }

  @override
  void dispose() {
    _waveController.dispose();
    _levelController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(widget.width * 0.15);
    const borderWidth = 3.0;

    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          // Animated water fill, inset so it sits inside the border
          Positioned(
            left: borderWidth,
            right: borderWidth,
            top: borderWidth,
            bottom: borderWidth,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(
                (widget.width * 0.15) - borderWidth,
              ),
              child: AnimatedBuilder(
                animation: Listenable.merge([
                  _waveController,
                  _levelController,
                ]),
                builder: (context, _) {
                  return CustomPaint(
                    painter: _WavePainter(
                      level: _levelAnimation.value,
                      phase: _waveController.value * 2 * math.pi,
                      color: widget.color,
                    ),
                    size: Size(
                      widget.width - borderWidth * 2,
                      widget.height - borderWidth * 2,
                    ),
                  );
                },
              ),
            ),
          ),

          // Tank outline (drawn on top so the fill never bleeds past it)
          Container(
            width: widget.width,
            height: widget.height,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.white, width: borderWidth),
              borderRadius: borderRadius,
            ),
          ),

          // Tank cap
          Positioned(
            top: 2,
            child: Container(
              height: widget.height * 0.06,
              width: widget.width * 0.9,
              decoration: BoxDecoration(
                color: Colors.white70,
                borderRadius: BorderRadius.circular(widget.width * 0.15),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _WavePainter extends CustomPainter {
  final double level; // 0..1 fraction filled, measured from the bottom
  final double phase;
  final Color color;

  _WavePainter({required this.level, required this.phase, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color.withValues(alpha: 0.75);

    const waveHeight = 3.5;
    final baseline = size.height * (1 - level);

    final path = Path()
      ..moveTo(0, size.height)
      ..lineTo(0, baseline);

    const step = 4.0;
    for (double x = 0; x <= size.width; x += step) {
      final y =
          baseline +
          waveHeight * math.sin((x / size.width * 2 * math.pi) + phase);
      path.lineTo(x, y);
    }

    path
      ..lineTo(size.width, size.height)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _WavePainter oldDelegate) {
    return oldDelegate.level != level || oldDelegate.phase != phase;
  }
}
