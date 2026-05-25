import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:venidng_coffee/theme/app_theme.dart';

/// ذرات قهوه شناور پشت گرید — فقط تزئین
class MenuAmbientLayer extends StatefulWidget {
  const MenuAmbientLayer({super.key});

  @override
  State<MenuAmbientLayer> createState() => _MenuAmbientLayerState();
}

class _MenuAmbientLayerState extends State<MenuAmbientLayer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          return Stack(
            children: List.generate(8, (i) {
              final t = (_controller.value + i * 0.11) % 1.0;
              final x = 30 + (i * 47.0) % (MediaQuery.sizeOf(context).width - 60);
              final y = 120 + math.sin(t * math.pi * 2) * 28 + i * 55;
              return Positioned(
                left: x,
                top: y,
                child: Opacity(
                  opacity: 0.06 + math.sin(t * math.pi) * 0.06,
                  child: Transform.rotate(
                    angle: t * math.pi * 0.5,
                    child: Icon(
                      i.isEven ? Icons.coffee_rounded : Icons.local_cafe_rounded,
                      size: 20 + (i % 3) * 6,
                      color: i.isEven ? AppColors.accent : AppColors.cream,
                    ),
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
