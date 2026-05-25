import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:venidng_coffee/theme/app_theme.dart';

class VendingBackground extends StatefulWidget {
  const VendingBackground({super.key, this.child});

  final Widget? child;

  @override
  State<VendingBackground> createState() => _VendingBackgroundState();
}

class _VendingBackgroundState extends State<VendingBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _drift;

  @override
  void initState() {
    super.initState();
    _drift = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _drift.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        const DecoratedBox(decoration: BoxDecoration(gradient: AppGradients.background)),
        AnimatedBuilder(
          animation: _drift,
          builder: (context, _) => _AmbientLayer(t: _drift.value),
        ),
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.center,
                radius: 1.1,
                colors: [
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.45),
                ],
                stops: const [0.55, 1],
              ),
            ),
          ),
        ),
        if (widget.child != null) widget.child!,
      ],
    );
  }
}

class _AmbientLayer extends StatelessWidget {
  const _AmbientLayer({required this.t});

  final double t;

  @override
  Widget build(BuildContext context) {
    final wave = math.sin(t * math.pi);
    return IgnorePointer(
      child: Stack(
        children: [
          _orb(
            top: -70 + wave * 12,
            right: -50 + wave * 8,
            size: 240,
            color: AppColors.accent.withValues(alpha: 0.14 + wave * 0.04),
          ),
          _orb(
            bottom: 100 - wave * 10,
            left: -90,
            size: 280,
            color: const Color(0xFF6B3A2A).withValues(alpha: 0.18),
          ),
          _orb(
            top: 320 + wave * 6,
            left: 30,
            size: 160,
            color: AppColors.accentBright.withValues(alpha: 0.07),
          ),
          Positioned.fill(child: CustomPaint(painter: _MeshPainter(t: t))),
          Positioned.fill(child: CustomPaint(painter: _DotPatternPainter())),
        ],
      ),
    );
  }

  Widget _orb({
    double? top,
    double? bottom,
    double? left,
    double? right,
    required double size,
    required Color color,
  }) {
    return Positioned(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      child: ImageFiltered(
        imageFilter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(shape: BoxShape.circle, color: color),
        ),
      ),
    );
  }
}

class _MeshPainter extends CustomPainter {
  _MeshPainter({required this.t});

  final double t;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment(-1 + t, -1),
        end: Alignment(1 - t, 1),
        colors: [
          AppColors.accent.withValues(alpha: 0.03),
          Colors.transparent,
          AppColors.accentDark.withValues(alpha: 0.04),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);
  }

  @override
  bool shouldRepaint(_MeshPainter old) => old.t != t;
}

class _DotPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.03)
      ..style = PaintingStyle.fill;

    const spacing = 28.0;
    for (var x = 0.0; x < size.width; x += spacing) {
      for (var y = 0.0; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), 1, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class GlowRing extends StatelessWidget {
  const GlowRing({super.key, required this.size, required this.pulse});

  final double size;
  final double pulse;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Transform.scale(
          scale: 1 + pulse * 0.12,
          child: Container(
            width: size + 24,
            height: size + 24,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.accent.withValues(alpha: 0.12),
                width: 1,
              ),
            ),
          ),
        ),
        Transform.scale(
          scale: 1 + pulse * 0.06,
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.accent.withValues(alpha: 0.35 + pulse * 0.25),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.accent.withValues(alpha: 0.2 + pulse * 0.2),
                  blurRadius: 48,
                  spreadRadius: pulse * 10,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class SteamParticles extends StatelessWidget {
  const SteamParticles({super.key, required this.animation});

  final Animation<double> animation;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, _) {
        return SizedBox(
          width: 140,
          height: 90,
          child: Stack(
            alignment: Alignment.bottomCenter,
            children: List.generate(6, (i) {
              final phase = (animation.value + i * 0.15) % 1.0;
              final x = math.sin(phase * math.pi * 2 + i * 1.2) * 22;
              return Positioned(
                bottom: 16 + phase * 58,
                left: 70 + x - 10,
                child: Opacity(
                  opacity: (1 - phase).clamp(0.0, 0.55),
                  child: Container(
                    width: 8 + i * 2.5,
                    height: 8 + i * 2.5,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.white.withValues(alpha: 0.08),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        );
      },
    );
  }
}

/// ذرات شناور برای اسپلش
class FloatingParticles extends StatelessWidget {
  const FloatingParticles({super.key, required this.animation});

  final Animation<double> animation;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, _) {
        return SizedBox.expand(
          child: Stack(
            children: List.generate(12, (i) {
              final phase = (animation.value + i * 0.08) % 1.0;
              final left = (i * 73.0) % 300 + 20;
              final top = 80 + phase * 400 + (i % 3) * 40.0;
              return Positioned(
                left: left % 320,
                top: top % 500,
                child: Opacity(
                  opacity: 0.15 + (1 - phase) * 0.2,
                  child: Icon(
                    Icons.circle,
                    size: 3 + (i % 3),
                    color: i.isEven ? AppColors.accent : AppColors.cream,
                  ),
                ),
              );
            }),
          ),
        );
      },
    );
  }
}
