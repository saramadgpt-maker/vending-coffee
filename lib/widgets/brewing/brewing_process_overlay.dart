import 'package:flutter/material.dart';
import 'package:venidng_coffee/theme/app_theme.dart';
import 'package:venidng_coffee/widgets/brewing/sweet_wait_cinema.dart';
import 'package:venidng_coffee/widgets/vending_background.dart';

/// سناریوی «انتظار شیرین» هنگام آماده‌سازی
Future<void> showBrewingProcessOverlay(BuildContext context) {
  return showGeneralDialog<void>(
    context: context,
    barrierDismissible: false,
    barrierColor: Colors.black.withValues(alpha: 0.94),
    transitionDuration: const Duration(milliseconds: 550),
    pageBuilder: (_, __, ___) => const _BrewingOverlayBody(),
    transitionBuilder: (context, animation, _, child) {
      return FadeTransition(
        opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
        child: child,
      );
    },
  );
}

class _BrewingOverlayBody extends StatefulWidget {
  const _BrewingOverlayBody();

  @override
  State<_BrewingOverlayBody> createState() => _BrewingOverlayBodyState();
}

class _BrewingOverlayBodyState extends State<_BrewingOverlayBody>
    with SingleTickerProviderStateMixin {
  late final AnimationController _textPulse;
  double _progress = 0;

  @override
  void initState() {
    super.initState();
    _textPulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _textPulse.dispose();
    super.dispose();
  }

  String get _phaseLabel {
    if (_progress < 10 / 38) return 'شروع';
    if (_progress < 30 / 38) return 'انتظار';
    return 'پایان';
  }

  @override
  Widget build(BuildContext context) {
    final caption = sweetWaitCaption(_progress);

    return Material(
      color: Colors.transparent,
      child: VendingBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              children: [
                _buildHeader(context),
                const SizedBox(height: 6),
                Expanded(
                  child: SweetWaitCinema(
                    onProgress: (p) => setState(() => _progress = p),
                    onFinished: () {
                      if (mounted) Navigator.of(context).pop();
                    },
                  ),
                ),
                const SizedBox(height: 14),
                _buildCaption(context, caption),
                const SizedBox(height: 12),
                _buildProgress(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.theater_comedy_rounded,
              size: 22,
              color: AppColors.accent.withValues(alpha: 0.85),
            ),
            const SizedBox(width: 8),
            GradientText(
              'انتظار شیرین',
              style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: AppColors.accent.withValues(alpha: 0.12),
            border: Border.all(color: AppColors.accent.withValues(alpha: 0.25)),
          ),
          child: Text(
            'فاز: $_phaseLabel',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.accentBright,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ),
      ],
    );
  }

  Widget _buildCaption(BuildContext context, String caption) {
    return AnimatedBuilder(
      animation: _textPulse,
      builder: (context, _) {
        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 400),
          child: Text(
            caption,
            key: ValueKey(caption),
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.cream.withValues(
                    alpha: 0.8 + _textPulse.value * 0.2,
                  ),
                  fontWeight: FontWeight.w600,
                  fontSize: 17,
                  height: 1.3,
                ),
          ),
        );
      },
    );
  }

  Widget _buildProgress(BuildContext context) {
    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: _progress,
            minHeight: 7,
            backgroundColor: Colors.white.withValues(alpha: 0.08),
            valueColor: AlwaysStoppedAnimation<Color>(
              Color.lerp(AppColors.accent, AppColors.success, _progress)!,
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          '${(_progress * 100).round()}٪  ·  ${(38 - _progress * 38).round()} ثانیه',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 11),
        ),
      ],
    );
  }
}
