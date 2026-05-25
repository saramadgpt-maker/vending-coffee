import 'package:flutter/material.dart';
import 'package:venidng_coffee/theme/app_theme.dart';

/// لوگوی اپ — فایل `assets/images/logo.png` را جایگزین کنید.
class LogoWidget extends StatelessWidget {
  const LogoWidget({
    super.key,
    this.size = 80,
    this.showRing = true,
    this.pulse = 0,
  });

  final double size;
  final bool showRing;
  final double pulse;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size + (showRing ? 20 : 0),
      height: size + (showRing ? 20 : 0),
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (showRing)
            Container(
              width: size + 16,
              height: size + 16,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.accent.withValues(alpha: 0.4 + pulse * 0.15),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF4A3528), Color(0xFF1A1008)],
              ),
              border: Border.all(
                color: AppColors.accent.withValues(alpha: 0.55),
                width: 2.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.accent.withValues(alpha: 0.35),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.4),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipOval(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(
                    'assets/images/logo.png',
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            AppColors.accent.withValues(alpha: 0.25),
                            AppColors.card,
                          ],
                        ),
                      ),
                      child: Icon(
                        Icons.coffee_rounded,
                        size: size * 0.5,
                        color: AppColors.accentBright,
                      ),
                    ),
                  ),
                  Positioned(
                    top: 8,
                    left: 12,
                    right: 12,
                    child: Container(
                      height: size * 0.2,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        gradient: LinearGradient(
                          colors: [
                            Colors.white.withValues(alpha: 0.2),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
