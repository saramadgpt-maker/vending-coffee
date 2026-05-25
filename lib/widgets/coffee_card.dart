import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:venidng_coffee/models/coffee_product.dart';
import 'package:venidng_coffee/theme/app_decorations.dart';
import 'package:venidng_coffee/theme/app_theme.dart';
import 'package:venidng_coffee/utils/price_format.dart';

class CoffeeCard extends StatefulWidget {
  const CoffeeCard({
    super.key,
    required this.product,
    required this.quantity,
    required this.index,
    required this.onIncrement,
    required this.onDecrement,
  });

  final CoffeeProduct product;
  final int quantity;
  final int index;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  @override
  State<CoffeeCard> createState() => _CoffeeCardState();
}

class _CoffeeCardState extends State<CoffeeCard>
    with TickerProviderStateMixin {
  late final AnimationController _enterController;
  late final AnimationController _bounceController;
  late final AnimationController _glowController;
  late final Animation<double> _enterAnim;

  @override
  void initState() {
    super.initState();
    _enterController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 550),
    );
    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
    );
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );
    _enterAnim = CurvedAnimation(
      parent: _enterController,
      curve: Interval(
        (widget.index * 0.07).clamp(0.0, 0.45),
        1,
        curve: Curves.easeOutCubic,
      ),
    );
    _enterController.forward();
    _syncGlow();
  }

  void _syncGlow() {
    if (widget.quantity > 0) {
      if (!_glowController.isAnimating) _glowController.repeat(reverse: true);
    } else {
      _glowController.stop();
      _glowController.value = 0;
    }
  }

  @override
  void didUpdateWidget(CoffeeCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.quantity > oldWidget.quantity) {
      _bounceController.forward(from: 0);
    }
    if (widget.quantity > 0 != oldWidget.quantity > 0) {
      _syncGlow();
    }
  }

  @override
  void dispose() {
    _enterController.dispose();
    _bounceController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    final quantity = widget.quantity;
    final isSelected = quantity > 0;

    return FadeTransition(
      opacity: _enterAnim,
      child: SlideTransition(
        position: Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero)
            .animate(_enterAnim),
        child: AnimatedBuilder(
          animation: _glowController,
          builder: (context, child) {
            final glow = isSelected ? _glowController.value : 0.0;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 280),
              curve: Curves.easeOutCubic,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(22),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isSelected
                      ? [
                          product.gradientStart.withValues(alpha: 0.55 + glow * 0.1),
                          product.gradientEnd.withValues(alpha: 0.35),
                          AppColors.surface.withValues(alpha: 0.92),
                        ]
                      : [
                          Colors.white.withValues(alpha: 0.08),
                          Colors.white.withValues(alpha: 0.02),
                        ],
                ),
                border: Border.all(
                  color: isSelected
                      ? Color.lerp(
                          AppColors.accent.withValues(alpha: 0.5),
                          AppColors.accentBright,
                          glow,
                        )!
                      : Colors.white.withValues(alpha: 0.08),
                  width: isSelected ? 1.5 : 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.28),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                  if (isSelected)
                    BoxShadow(
                      color: product.color.withValues(alpha: 0.25 + glow * 0.2),
                      blurRadius: 16,
                      spreadRadius: -4,
                    ),
                ],
              ),
              child: child,
            );
          },
          child: ClipRRect(
            borderRadius: BorderRadius.circular(22),
            child: Stack(
              clipBehavior: Clip.hardEdge,
              children: [
                const PanelTopShine(height: 56),
                if (isSelected) _ShimmerSweep(animation: _glowController),
                Positioned(
                  top: -18,
                  right: -18,
                  child: Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: product.color.withValues(alpha: 0.1),
                    ),
                  ),
                ),
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      widget.onIncrement();
                    },
                    borderRadius: BorderRadius.circular(22),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          SizedBox(
                            height: 22,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 280),
                                  transitionBuilder: (child, anim) =>
                                      SlideTransition(
                                    position: Tween<Offset>(
                                      begin: const Offset(-0.3, 0),
                                      end: Offset.zero,
                                    ).animate(anim),
                                    child: FadeTransition(
                                      opacity: anim,
                                      child: child,
                                    ),
                                  ),
                                  child: isSelected
                                      ? _QtyChip(
                                          key: ValueKey(quantity),
                                          count: quantity,
                                        )
                                      : _HintChip(key: const ValueKey('hint')),
                                ),
                                AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 300),
                                  switchInCurve: Curves.elasticOut,
                                  transitionBuilder: (child, anim) =>
                                      ScaleTransition(scale: anim, child: child),
                                  child: isSelected
                                      ? Icon(
                                          key: const ValueKey('check'),
                                          Icons.check_circle_rounded,
                                          size: 18,
                                          color: AppColors.accentBright,
                                        )
                                      : const SizedBox(
                                          key: ValueKey('no-check'),
                                          width: 18,
                                          height: 18,
                                        ),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Center(
                              child: SizedBox(
                                width: 62,
                                height: 62,
                                child: ClipOval(
                                  child: ScaleTransition(
                                    scale: Tween<double>(begin: 1, end: 1.06)
                                        .animate(
                                      CurvedAnimation(
                                        parent: _bounceController,
                                        curve: Curves.easeOutBack,
                                      ),
                                    ),
                                    child: _DrinkIcon(
                                      product: product,
                                      glowing: isSelected,
                                      glowT: isSelected
                                          ? _glowController.value
                                          : 0,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Text(
                            product.name,
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${formatToman(product.price)} تومان',
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  fontSize: 11,
                                  color: isSelected
                                      ? AppColors.accentBright
                                      : AppColors.textMuted,
                                  fontWeight: isSelected
                                      ? FontWeight.w600
                                      : FontWeight.normal,
                                ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _QtyButton(
                                icon: Icons.remove_rounded,
                                filled: false,
                                enabled: quantity > 0,
                                onPressed: quantity > 0
                                    ? widget.onDecrement
                                    : null,
                              ),
                              AnimatedSwitcher(
                                duration: const Duration(milliseconds: 220),
                                transitionBuilder: (child, anim) {
                                  return SlideTransition(
                                    position: Tween<Offset>(
                                      begin: const Offset(0, 0.4),
                                      end: Offset.zero,
                                    ).animate(anim),
                                    child: FadeTransition(
                                      opacity: anim,
                                      child: ScaleTransition(
                                        scale: anim,
                                        child: child,
                                      ),
                                    ),
                                  );
                                },
                                child: SizedBox(
                                  key: ValueKey(quantity),
                                  width: 36,
                                  child: Text(
                                    '$quantity',
                                    textAlign: TextAlign.center,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleLarge
                                        ?.copyWith(
                                          fontSize: 22,
                                          fontWeight: FontWeight.w800,
                                          color: isSelected
                                              ? AppColors.accentBright
                                              : AppColors.cream,
                                        ),
                                  ),
                                ),
                              ),
                              _QtyButton(
                                icon: Icons.add_rounded,
                                filled: true,
                                enabled: true,
                                onPressed: widget.onIncrement,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
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

class _ShimmerSweep extends StatelessWidget {
  const _ShimmerSweep({required this.animation});

  final Animation<double> animation;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, _) {
        return Positioned.fill(
          child: Transform.translate(
            offset: Offset(-120 + animation.value * 280, 0),
            child: Container(
              width: 60,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.transparent,
                    Colors.white.withValues(alpha: 0.06),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _DrinkIcon extends StatelessWidget {
  const _DrinkIcon({
    required this.product,
    required this.glowing,
    required this.glowT,
  });

  final CoffeeProduct product;
  final bool glowing;
  final double glowT;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 62,
      height: 62,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: product.cardGradient,
        boxShadow: [
          BoxShadow(
            color: product.color.withValues(alpha: glowing ? 0.5 : 0.3),
            blurRadius: glowing ? 14 : 10,
            offset: const Offset(0, 5),
          ),
          if (glowing)
            BoxShadow(
              color: AppColors.accent.withValues(alpha: 0.15 + glowT * 0.15),
              blurRadius: 14,
            ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.hardEdge,
        children: [
          Positioned(
            top: 10,
            left: 14,
            child: Container(
              width: 18,
              height: 8,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Colors.white.withValues(alpha: 0.2),
              ),
            ),
          ),
          Icon(product.icon, size: 32, color: AppColors.cream),
        ],
      ),
    );
  }
}

class _QtyChip extends StatelessWidget {
  const _QtyChip({super.key, required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        gradient: AppGradients.accent,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        '$count×',
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: AppColors.background,
              fontSize: 11,
            ),
      ),
    );
  }
}

class _HintChip extends StatelessWidget {
  const _HintChip({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
      ),
      child: Text(
        'لمس کنید',
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontSize: 9,
              color: AppColors.textMuted,
            ),
      ),
    );
  }
}

class _QtyButton extends StatefulWidget {
  const _QtyButton({
    required this.icon,
    required this.filled,
    required this.enabled,
    this.onPressed,
  });

  final IconData icon;
  final bool filled;
  final bool enabled;
  final VoidCallback? onPressed;

  @override
  State<_QtyButton> createState() => _QtyButtonState();
}

class _QtyButtonState extends State<_QtyButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _press;

  @override
  void initState() {
    super.initState();
    _press = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
    );
  }

  @override
  void dispose() {
    _press.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: widget.enabled ? (_) => _press.forward() : null,
      onTapUp: widget.enabled ? (_) => _press.reverse() : null,
      onTapCancel: widget.enabled ? () => _press.reverse() : null,
      onTap: widget.enabled
          ? () {
              HapticFeedback.lightImpact();
              widget.onPressed?.call();
            }
          : null,
      child: ScaleTransition(
        scale: Tween<double>(begin: 1, end: 0.9).animate(
          CurvedAnimation(parent: _press, curve: Curves.easeInOut),
        ),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: widget.filled && widget.enabled ? AppGradients.accent : null,
            color: widget.filled
                ? null
                : (widget.enabled
                    ? Colors.white.withValues(alpha: 0.09)
                    : Colors.white.withValues(alpha: 0.03)),
            border: widget.filled
                ? null
                : Border.all(
                    color: widget.enabled
                        ? Colors.white.withValues(alpha: 0.15)
                        : Colors.white.withValues(alpha: 0.06),
                  ),
          ),
          child: Icon(
            widget.icon,
            size: 22,
            color: widget.enabled
                ? (widget.filled ? AppColors.background : AppColors.cream)
                : AppColors.textMuted.withValues(alpha: 0.45),
          ),
        ),
      ),
    );
  }
}
