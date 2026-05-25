import 'package:flutter/material.dart';
import 'package:venidng_coffee/theme/app_theme.dart';

class AppDecorations {
  static BoxDecoration glass({
    double radius = 24,
    double borderOpacity = 0.12,
    List<Color>? gradientColors,
  }) {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(radius),
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: gradientColors ??
            [
              Colors.white.withValues(alpha: 0.14),
              Colors.white.withValues(alpha: 0.04),
            ],
      ),
      border: Border.all(color: Colors.white.withValues(alpha: borderOpacity)),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.35),
          blurRadius: 20,
          offset: const Offset(0, 8),
        ),
      ],
    );
  }

  static BoxDecoration glowCard({
    required bool active,
    required Color glowColor,
    double radius = 24,
  }) {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(
        color: active
            ? AppColors.accent.withValues(alpha: 0.8)
            : Colors.white.withValues(alpha: 0.08),
        width: active ? 2 : 1,
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.3),
          blurRadius: 14,
          offset: const Offset(0, 6),
        ),
        if (active)
          BoxShadow(
            color: glowColor.withValues(alpha: 0.45),
            blurRadius: 24,
            spreadRadius: -2,
            offset: const Offset(0, 10),
          ),
      ],
    );
  }
}

/// نوار درخشان بالای پنل‌ها
class PanelTopShine extends StatelessWidget {
  const PanelTopShine({super.key, this.height = 80});

  final double height;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      height: height,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.white.withValues(alpha: 0.1),
              Colors.transparent,
            ],
          ),
        ),
      ),
    );
  }
}
