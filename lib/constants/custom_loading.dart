// lib/widgets/custom_loading.dart
import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'app_theme.dart';


// Pulsing Dots Loader
class PulsingDotsLoader extends StatefulWidget {
  final double size;
  final Color? color;

  const PulsingDotsLoader({
    super.key,
    this.size = 60,
    this.color,
  });

  @override
  State<PulsingDotsLoader> createState() => _PulsingDotsLoaderState();
}

class _PulsingDotsLoaderState extends State<PulsingDotsLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.color ?? AppTheme.accentGold;

    return SizedBox(
      width: widget.size,
      height: widget.size * 0.3,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(3, (index) {
          return AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              final delay = index * 0.2;
              final value = (_controller.value - delay) % 1.0;
              final scale = 0.5 + (math.sin(value * math.pi * 2) * 0.5);

              return Transform.scale(
                scale: scale,
                child: Container(
                  width: widget.size * 0.2,
                  height: widget.size * 0.2,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: color.withOpacity(0.5),
                        blurRadius: 8,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        }),
      ),
    );
  }
}

// 3. Circular Progress Loader
class CircularProgressLoader extends StatefulWidget {
  final double size;
  final Color? color;
  final double strokeWidth;

  const CircularProgressLoader({
    super.key,
    this.size = 60,
    this.color,
    this.strokeWidth = 4,
  });

  @override
  State<CircularProgressLoader> createState() => _CircularProgressLoaderState();
}

class _CircularProgressLoaderState extends State<CircularProgressLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.rotate(
            angle: _controller.value * 2 * math.pi,
            child: CustomPaint(
              painter: _CircularProgressPainter(
                color: widget.color ?? AppTheme.primaryGreen,
                strokeWidth: widget.strokeWidth,
                progress: _controller.value,
              ),
            ),
          );
        },
      ),
    );
  }
}

class _CircularProgressPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double progress;

  _CircularProgressPainter({
    required this.color,
    required this.strokeWidth,
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // Background circle
    final bgPaint = Paint()
      ..color = color.withOpacity(0.2)
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    canvas.drawCircle(center, radius, bgPaint);

    // Progress arc
    const startAngle = -math.pi / 2;
    final sweepAngle = 2 * math.pi * 0.75;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// Bouncing Balls Loader
class BouncingBallsLoader extends StatefulWidget {
  final double size;

  const BouncingBallsLoader({super.key, this.size = 60});

  @override
  State<BouncingBallsLoader> createState() => _BouncingBallsLoaderState();
}

class _BouncingBallsLoaderState extends State<BouncingBallsLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: List.generate(3, (index) {
          return AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              final delay = index * 0.15;
              final adjustedValue = (_controller.value - delay).clamp(0.0, 1.0);
              final bounce = math.sin(adjustedValue * math.pi);

              return Transform.translate(
                offset: Offset(0, -bounce * widget.size * 0.3),
                child: Container(
                  width: widget.size * 0.25,
                  height: widget.size * 0.25,
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      colors: [
                        AppTheme.accentGold,
                        AppTheme.primaryGreen,
                      ],
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primaryGreen.withOpacity(0.4),
                        blurRadius: 8,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        }),
      ),
    );
  }
}

// Ripple Loader
class RippleLoader extends StatefulWidget {
  final double size;
  final Color? color;

  const RippleLoader({
    super.key,
    this.size = 60,
    this.color,
  });

  @override
  State<RippleLoader> createState() => _RippleLoaderState();
}

class _RippleLoaderState extends State<RippleLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.color ?? AppTheme.accentGold;

    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Stack(
            alignment: Alignment.center,
            children: [
              _buildRipple(color, _controller.value, 0),
              _buildRipple(color, _controller.value, 0.33),
              _buildRipple(color, _controller.value, 0.66),
            ],
          );
        },
      ),
    );
  }

  Widget _buildRipple(Color color, double value, double delay) {
    final adjustedValue = ((value + delay) % 1.0);
    final scale = adjustedValue;
    final opacity = 1.0 - adjustedValue;

    return Transform.scale(
      scale: scale,
      child: Container(
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: color.withOpacity(opacity * 0.6),
            width: 3,
          ),
        ),
      ),
    );
  }
}

// Spinning Leaves Loader
class SpinningLeavesLoader extends StatefulWidget {
  final double size;

  const SpinningLeavesLoader({super.key, this.size = 60});

  @override
  State<SpinningLeavesLoader> createState() => _SpinningLeavesLoaderState();
}

class _SpinningLeavesLoaderState extends State<SpinningLeavesLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Stack(
            alignment: Alignment.center,
            children: List.generate(4, (index) {
              final angle = (2 * math.pi * index / 4) +
                  (_controller.value * 2 * math.pi);
              final radius = widget.size * 0.35;
              final x = radius * math.cos(angle);
              final y = radius * math.sin(angle);

              return Transform.translate(
                offset: Offset(x, y),
                child: Transform.rotate(
                  angle: _controller.value * 2 * math.pi,
                  child: Icon(
                    Icons.eco,
                    color: [
                      AppTheme.primaryGreen,
                      AppTheme.accentGold,
                      AppTheme.lightGreen,
                      AppTheme.neutralWhite,
                    ][index],
                    size: widget.size * 0.25,
                  ),
                ),
              );
            }),
          );
        },
      ),
    );
  }
}

// Wave Loader
class WaveLoader extends StatefulWidget {
  final double size;
  final Color? color;

  const WaveLoader({
    super.key,
    this.size = 60,
    this.color,
  });

  @override
  State<WaveLoader> createState() => _WaveLoaderState();
}

class _WaveLoaderState extends State<WaveLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.color ?? AppTheme.primaryGreen;

    return SizedBox(
      width: widget.size,
      height: widget.size * 0.5,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(5, (index) {
          return AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              final delay = index * 0.1;
              final value = (_controller.value - delay) % 1.0;
              final height = (math.sin(value * math.pi * 2) * 0.5 + 0.5) *
                  widget.size * 0.5;

              return Container(
                width: widget.size * 0.12,
                height: height,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(4),
                  boxShadow: [
                    BoxShadow(
                      color: color.withOpacity(0.5),
                      blurRadius: 4,
                    ),
                  ],
                ),
              );
            },
          );
        }),
      ),
    );
  }
}


// Rotating Earth Loader Widget
class RotatingEarthLoader extends StatefulWidget {
  final double size;

  const RotatingEarthLoader({super.key, this.size = 60});

  @override
  State<RotatingEarthLoader> createState() => _RotatingEarthLoaderState();
}

class _RotatingEarthLoaderState extends State<RotatingEarthLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.rotate(
          angle: _controller.value * 2 * math.pi,
          child: Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  AppTheme.primaryGreen,
                  AppTheme.lightGreen,
                  AppTheme.accentGold.withOpacity(0.3),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryGreen.withOpacity(0.5),
                  blurRadius: 15,
                  spreadRadius: 3,
                ),
              ],
            ),
            child: Icon(
              Icons.public,
              color: Colors.white,
              size: widget.size * 0.7,
            ),
          ),
        );
      },
    );
  }
}

