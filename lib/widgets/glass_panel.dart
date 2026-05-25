import 'package:flutter/material.dart';
import 'package:venidng_coffee/theme/app_decorations.dart';

class GlassPanel extends StatelessWidget {
  const GlassPanel({
    super.key,
    required this.child,
    this.padding,
    this.radius = 24,
    this.showShine = false,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double radius;
  final bool showShine;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: AppDecorations.glass(radius: radius),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: Stack(
          children: [
            if (showShine) PanelTopShine(height: radius * 2.5),
            Padding(padding: padding ?? EdgeInsets.zero, child: child),
          ],
        ),
      ),
    );
  }
}
