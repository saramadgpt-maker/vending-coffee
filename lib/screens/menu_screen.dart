import 'package:flutter/material.dart';
import 'package:venidng_coffee/data/coffee_catalog.dart';
import 'package:venidng_coffee/models/order_line.dart';
import 'package:venidng_coffee/theme/app_theme.dart';
import 'package:venidng_coffee/utils/ble_manager.dart';
import 'package:venidng_coffee/widgets/coffee_card.dart';

import 'package:venidng_coffee/widgets/menu_ambient.dart';
import 'package:venidng_coffee/widgets/order_confirm_dialog.dart';
import 'package:venidng_coffee/widgets/payment_bar.dart';
import 'package:venidng_coffee/widgets/brewing/brewing_process_overlay.dart';
import 'package:venidng_coffee/widgets/success_dialog.dart';
import 'package:venidng_coffee/widgets/vending_background.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> with TickerProviderStateMixin {
  final Map<String, int> _quantities = {};
  bool _isPaying = false;

  late final AnimationController _hintPulse;
  late final AnimationController _titleFloat;

  int get _totalItems => _quantities.values.fold(0, (sum, q) => sum + q);

  int get _totalPrice {
    var total = 0;
    for (final product in coffeeCatalog) {
      total += product.price * (_quantities[product.id] ?? 0);
    }
    return total;
  }

  @override
  void initState() {
    super.initState();
    _hintPulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
    _titleFloat = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _hintPulse.dispose();
    _titleFloat.dispose();
    super.dispose();
  }

  void _changeQty(String id, int delta) {
    setState(() {
      final current = _quantities[id] ?? 0;
      final next = (current + delta).clamp(0, 99);
      if (next == 0) {
        _quantities.remove(id);
      } else {
        _quantities[id] = next;
      }
    });
  }

  List<OrderLine> _buildOrderLines() {
    final lines = <OrderLine>[];
    for (final product in coffeeCatalog) {
      final qty = _quantities[product.id] ?? 0;
      if (qty == 0) continue;
      lines.add(
        OrderLine(
          name: product.name,
          quantity: qty,
          unitPrice: product.price,
          icon: product.icon,
          gradientStart: product.gradientStart,
          gradientEnd: product.gradientEnd,
        ),
      );
    }
    return lines;
  }

  Future<void> _onPay() async {
    if (_totalItems == 0 || _isPaying) return;

    final confirmed = await showOrderConfirmDialog(
      context,
      items: _buildOrderLines(),
      totalItems: _totalItems,
      totalPrice: _totalPrice,
    );
    if (!confirmed || !mounted) return;

    setState(() => _isPaying = true);

    await showBrewingProcessOverlay(context);

    if (!mounted) return;

    // ارسال دیتا به ESP32 بعد از پرداخت موفق
    for (var entry in _quantities.entries) {
      if (entry.value > 0) {
        await BleManager().sendOrder(entry.key, entry.value);
        // یه تاخیر کوتاه بین ارسال‌ها اگر چندتا محصول بود
        await Future.delayed(const Duration(milliseconds: 500));
      }
    }

    setState(() {

      _isPaying = false;
      _quantities.clear();
    });

    await showPaymentSuccessDialog(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: VendingBackground(
        child: SafeArea(
          child: Stack(
            children: [
              const MenuAmbientLayer(),
              Column(
                children: [
                  _MenuHeader(
                    totalItems: _totalItems,
                    floatAnimation: _titleFloat,
                  ),
                  _SectionTitle(
                    totalItems: _totalItems,
                    hintPulse: _hintPulse,
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                      child: GridView.builder(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.only(bottom: 8),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                          childAspectRatio: 0.84,
                        ),
                        itemCount: coffeeCatalog.length,
                        itemBuilder: (context, index) {
                          final product = coffeeCatalog[index];
                          final qty = _quantities[product.id] ?? 0;
                          return CoffeeCard(
                            product: product,
                            quantity: qty,
                            index: index,
                            onIncrement: () => _changeQty(product.id, 1),
                            onDecrement: () => _changeQty(product.id, -1),
                          );
                        },
                      ),
                    ),
                  ),
                  PaymentBar(
                    totalItems: _totalItems,
                    totalPrice: _totalPrice,
                    isPaying: _isPaying,
                    onPay: _onPay,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({
    required this.totalItems,
    required this.hintPulse,
  });

  final int totalItems;
  final Animation<double> hintPulse;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
      child: Row(
        children: [
          _WiggleCoffeeIcon(animation: hintPulse),
          const SizedBox(width: 8),
          GradientText(
            'منوی نوشیدنی',
            style: Theme.of(context).textTheme.titleMedium!.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
          const Spacer(),
          if (totalItems == 0)
            FadeTransition(
              opacity: Tween<double>(begin: 0.45, end: 1).animate(hintPulse),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: AppColors.accent.withValues(alpha: 0.25),
                  ),
                  color: AppColors.accent.withValues(alpha: 0.08),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.touch_app_rounded,
                      size: 14,
                      color: AppColors.accent.withValues(
                        alpha: 0.7 + hintPulse.value * 0.3,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'روی کارت بزنید',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontSize: 11,
                            color: AppColors.accentBright,
                          ),
                    ),
                  ],
                ),
              ),
            )
          else
            TweenAnimationBuilder<int>(
              tween: IntTween(end: totalItems),
              duration: const Duration(milliseconds: 400),
              curve: Curves.elasticOut,
              builder: (context, value, _) {
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.check_circle_outline_rounded,
                      size: 16,
                      color: AppColors.success.withValues(alpha: 0.9),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '$value انتخاب',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.success,
                            fontWeight: FontWeight.w600,
                            fontSize: 11,
                          ),
                    ),
                  ],
                );
              },
            ),
        ],
      ),
    );
  }
}

class _WiggleCoffeeIcon extends StatelessWidget {
  const _WiggleCoffeeIcon({required this.animation});

  final Animation<double> animation;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Transform.rotate(
          angle: (animation.value - 0.5) * 0.15,
          child: Transform.scale(
            scale: 1 + (animation.value - 0.5) * 0.08,
            child: child,
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.accent.withValues(alpha: 0.12),
          border: Border.all(color: AppColors.accent.withValues(alpha: 0.25)),
        ),
        child: const Icon(
          Icons.local_cafe_rounded,
          size: 16,
          color: AppColors.accent,
        ),
      ),
    );
  }
}

class _MenuHeader extends StatefulWidget {
  const _MenuHeader({
    required this.totalItems,
    required this.floatAnimation,
  });

  final int totalItems;
  final Animation<double> floatAnimation;

  @override
  State<_MenuHeader> createState() => _MenuHeaderState();
}

class _MenuHeaderState extends State<_MenuHeader> {
  @override
  Widget build(BuildContext context) {
    final float = (widget.floatAnimation.value - 0.5) * 6;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: AnimatedBuilder(
        animation: widget.floatAnimation,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, float),
            child: child,
          );
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: LinearGradient(
              colors: [
                Colors.white.withValues(alpha: 0.12),
                Colors.white.withValues(alpha: 0.03),
              ],
            ),
            border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
            boxShadow: [
              BoxShadow(
                color: AppColors.accent.withValues(alpha: 0.08),
                blurRadius: 20,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            children: [
              _FloatingLogo(animation: widget.floatAnimation),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GradientText(
                      'ماشین قهوه',
                      style: Theme.of(context).textTheme.titleLarge!.copyWith(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'لحظه‌ای تا یک فنجان عالی',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontSize: 12,
                          ),
                    ),
                  ],
                ),
              ),
              _CartBadgeAnimated(count: widget.totalItems),
            ],
          ),
        ),
      ),
    );
  }
}

class _FloatingLogo extends StatelessWidget {
  const _FloatingLogo({required this.animation});

  final Animation<double> animation;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, (animation.value - 0.5) * -4),
          child: Transform.rotate(
            angle: (animation.value - 0.5) * 0.04,
            child: child,
          ),
        );
      },
      child: const _HeaderLogo(),
    );
  }
}

class _HeaderLogo extends StatelessWidget {
  const _HeaderLogo();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 54,
      height: 54,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          colors: [Color(0xFF4A3528), Color(0xFF1A1008)],
        ),
        border: Border.all(color: AppColors.accent.withValues(alpha: 0.45)),
        boxShadow: [
          BoxShadow(
            color: AppColors.accent.withValues(alpha: 0.25),
            blurRadius: 14,
          ),
        ],
      ),
      child: const Icon(
        Icons.coffee_rounded,
        color: AppColors.accentBright,
        size: 28,
      ),
    );
  }
}

class _CartBadgeAnimated extends StatelessWidget {
  const _CartBadgeAnimated({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 400),
      switchInCurve: Curves.elasticOut,
      switchOutCurve: Curves.easeIn,
      transitionBuilder: (child, anim) {
        return ScaleTransition(
          scale: anim,
          child: RotationTransition(
            turns: Tween<double>(begin: 0.2, end: 0).animate(anim),
            child: child,
          ),
        );
      },
      child: count > 0
          ? Container(
              key: ValueKey(count),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                gradient: AppGradients.accent,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.accent.withValues(alpha: 0.45),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.shopping_cart_rounded,
                    size: 16,
                    color: AppColors.background,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '$count',
                    style: const TextStyle(
                      color: AppColors.background,
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            )
          : const SizedBox(key: ValueKey('empty'), width: 8),
    );
  }
}
