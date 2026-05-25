import 'dart:async';

import 'package:flutter/material.dart';
import 'package:venidng_coffee/screens/menu_screen.dart';
import 'package:venidng_coffee/theme/app_theme.dart';
import 'package:venidng_coffee/widgets/logo_widget.dart';
import 'package:venidng_coffee/widgets/vending_background.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _enterController;
  late final AnimationController _pulseController;
  late final Animation<double> _fade;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _enterController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    );
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: true);

    _fade = CurvedAnimation(parent: _enterController, curve: Curves.easeOut);
    _scale = Tween<double>(begin: 0.65, end: 1).animate(
      CurvedAnimation(parent: _enterController, curve: Curves.easeOutBack),
    );
    _enterController.forward();

    Timer(const Duration(milliseconds: 2600), () {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => const MenuScreen(),
          transitionsBuilder: (_, animation, __, child) {
            return FadeTransition(
              opacity: CurvedAnimation(parent: animation, curve: Curves.easeInOut),
              child: child,
            );
          },
          transitionDuration: const Duration(milliseconds: 700),
        ),
      );
    });
  }

  @override
  void dispose() {
    _enterController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: VendingBackground(
        child: Stack(
          children: [
            FloatingParticles(animation: _pulseController),
            FadeTransition(
              opacity: _fade,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AnimatedBuilder(
                      animation: _pulseController,
                      builder: (context, child) {
                        return Stack(
                          alignment: Alignment.center,
                          children: [
                            GlowRing(
                              size: 175,
                              pulse: _pulseController.value,
                            ),
                            ScaleTransition(scale: _scale, child: child),
                          ],
                        );
                      },
                      child: const LogoWidget(size: 132, showRing: false),
                    ),
                    SteamParticles(animation: _pulseController),
                    const SizedBox(height: 40),
                    GradientText(
                      'قهوه‌ات رو انتخاب کن',
                      style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                            fontSize: 28,
                            letterSpacing: -0.5,
                          ),
                    ),
                    const SizedBox(height: 14),
                    _TaglineRow(),
                    const SizedBox(height: 48),
                    _SplashLoader(animation: _pulseController),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TaglineRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    const tags = ['تازه', 'داغ', 'خوش‌طعم'];
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: tags.map((tag) {
        final isLast = tag == tags.last;
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.accent.withValues(alpha: 0.2)),
              ),
              child: Text(
                tag,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.accentBright,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
              ),
            ),
            if (!isLast)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: Icon(
                  Icons.circle,
                  size: 4,
                  color: AppColors.textMuted.withValues(alpha: 0.6),
                ),
              ),
          ],
        );
      }).toList(),
    );
  }
}

class _SplashLoader extends StatelessWidget {
  const _SplashLoader({required this.animation});

  final Animation<double> animation;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, _) {
        return Column(
          children: [
            SizedBox(
              width: 160,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  minHeight: 4,
                  value: 0.35 + animation.value * 0.45,
                  backgroundColor: Colors.white.withValues(alpha: 0.06),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Color.lerp(
                      AppColors.accent,
                      AppColors.accentBright,
                      animation.value,
                    )!,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'در حال آماده‌سازی...',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontSize: 11,
                    letterSpacing: 1,
                  ),
            ),
          ],
        );
      },
    );
  }
}
