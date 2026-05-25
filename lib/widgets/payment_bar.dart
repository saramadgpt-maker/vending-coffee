import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:venidng_coffee/theme/app_theme.dart';
import 'package:venidng_coffee/utils/price_format.dart';
import 'package:venidng_coffee/widgets/glass_panel.dart';

class PaymentBar extends StatelessWidget {
  const PaymentBar({
    super.key,
    required this.totalItems,
    required this.totalPrice,
    required this.isPaying,
    required this.onPay,
  });

  final int totalItems;
  final int totalPrice;
  final bool isPaying;
  final VoidCallback onPay;

  @override
  Widget build(BuildContext context) {
    final canPay = totalItems > 0 && !isPaying;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOutCubic,
        decoration: canPay
            ? BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.accent.withValues(alpha: 0.22),
                    blurRadius: 28,
                    spreadRadius: -4,
                    offset: const Offset(0, -4),
                  ),
                ],
              )
            : null,
        child: GlassPanel(
          radius: 30,
          showShine: true,
          padding: const EdgeInsets.fromLTRB(18, 14, 14, 14),
          child: Row(
            children: [
              _CartBadge(count: totalItems, active: canPay),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 250),
                      child: Text(
                        totalItems == 0
                            ? 'سبد خالی است'
                            : '$totalItems عدد انتخاب شده',
                        key: ValueKey(totalItems == 0),
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                    const SizedBox(height: 4),
                    TweenAnimationBuilder<int>(
                      tween: IntTween(end: totalPrice),
                      duration: const Duration(milliseconds: 400),
                      curve: Curves.easeOutCubic,
                      builder: (context, value, _) {
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            GradientText(
                              formatToman(value),
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge!
                                  .copyWith(
                                    fontSize: 26,
                                    fontWeight: FontWeight.w800,
                                  ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'تومان',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(fontSize: 12),
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
              _PayButton(canPay: canPay, isPaying: isPaying, onPay: onPay),
            ],
          ),
        ),
      ),
    );
  }
}

class _CartBadge extends StatelessWidget {
  const _CartBadge({required this.count, required this.active});

  final int count;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: 54,
          height: 54,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            gradient: active
                ? LinearGradient(
                    colors: [
                      AppColors.accent.withValues(alpha: 0.25),
                      AppColors.accent.withValues(alpha: 0.08),
                    ],
                  )
                : null,
            color: active ? null : Colors.white.withValues(alpha: 0.05),
            border: Border.all(
              color: active
                  ? AppColors.accent.withValues(alpha: 0.4)
                  : Colors.white.withValues(alpha: 0.1),
            ),
          ),
          child: Icon(
            Icons.shopping_bag_rounded,
            color: active ? AppColors.accentBright : AppColors.textMuted,
            size: 26,
          ),
        ),
        if (count > 0)
          Positioned(
            top: -5,
            left: -5,
            child: TweenAnimationBuilder<double>(
              key: ValueKey(count),
              tween: Tween(begin: 0, end: 1),
              duration: const Duration(milliseconds: 450),
              curve: Curves.elasticOut,
              builder: (context, value, child) {
                return Transform.scale(scale: value, child: child);
              },
              child: Container(
              padding: const EdgeInsets.all(7),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: AppGradients.accent,
                boxShadow: [
                  BoxShadow(
                    color: Color(0x66E8B86D),
                    blurRadius: 8,
                  ),
                ],
              ),
              constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
              child: Text(
                '$count',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.background,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            ),
          ),
      ],
    );
  }
}

class _PayButton extends StatefulWidget {
  const _PayButton({
    required this.canPay,
    required this.isPaying,
    required this.onPay,
  });

  final bool canPay;
  final bool isPaying;
  final VoidCallback onPay;

  @override
  State<_PayButton> createState() => _PayButtonState();
}

class _PayButtonState extends State<_PayButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _syncPulse();
  }

  void _syncPulse() {
    if (widget.canPay && !widget.isPaying) {
      if (!_pulse.isAnimating) _pulse.repeat(reverse: true);
    } else {
      _pulse.stop();
      _pulse.value = 0;
    }
  }

  @override
  void didUpdateWidget(_PayButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncPulse();
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulse,
      builder: (context, child) {
        final glow = widget.canPay ? 0.35 + _pulse.value * 0.2 : 0.0;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 280),
          height: 56,
          width: 152,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: widget.canPay ? AppGradients.payButton : null,
            color: widget.canPay ? null : Colors.white.withValues(alpha: 0.05),
            boxShadow: widget.canPay
                ? [
                    BoxShadow(
                      color: AppColors.accent.withValues(alpha: glow),
                      blurRadius: 18 + _pulse.value * 8,
                      offset: const Offset(0, 6),
                    ),
                  ]
                : null,
          ),
          child: child,
        );
      },
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.canPay
              ? () {
                  HapticFeedback.mediumImpact();
                  widget.onPay();
                }
              : null,
          borderRadius: BorderRadius.circular(20),
          child: Center(
            child: widget.isPaying
                ? const SizedBox(
                    width: 28,
                    height: 28,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: AppColors.background,
                    ),
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.contactless_rounded,
                        size: 24,
                        color: widget.canPay
                            ? AppColors.background
                            : AppColors.textMuted,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'پرداخت',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: widget.canPay
                              ? AppColors.background
                              : AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
