import 'package:flutter/material.dart';

import 'package:venidng_coffee/data/coffee_catalog.dart';
import 'package:venidng_coffee/models/order_line.dart';
import 'package:venidng_coffee/theme/app_theme.dart';
import 'package:venidng_coffee/utils/ble_manager.dart';

import 'package:venidng_coffee/widgets/coffee_card.dart';
import 'package:venidng_coffee/widgets/menu_ambient.dart';
import 'package:venidng_coffee/widgets/order_confirm_dialog.dart';
import 'package:venidng_coffee/widgets/payment_bar.dart';
import 'package:venidng_coffee/widgets/success_dialog.dart';
import 'package:venidng_coffee/widgets/vending_background.dart';
import 'package:venidng_coffee/order_status_dialog.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen>
    with TickerProviderStateMixin {
  final Map<String, int> _quantities = {};

  bool _isPaying = false;

  late AnimationController _titleController;
  late AnimationController _hintController;

  late Animation<double> _titleFloat;
  late Animation<double> _hintPulse;

  @override
  void initState() {
    super.initState();

    _titleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    _hintController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _titleFloat = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(
      CurvedAnimation(
        parent: _titleController,
        curve: Curves.easeInOut,
      ),
    );

    _hintPulse = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(
      CurvedAnimation(
        parent: _hintController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _hintController.dispose();
    super.dispose();
  }

  int get _totalItems {
    int total = 0;

    for (final qty in _quantities.values) {
      total += qty;
    }

    return total;
  }

  int get _totalPrice {
    int total = 0;

    for (final product in coffeeCatalog) {
      final qty = _quantities[product.id] ?? 0;
      total += qty * product.price;
    }

    return total;
  }

  void _changeQty(String id, int delta) {
    setState(() {
      // اگر کاربر داره یک محصول دیگه رو اضافه می‌کنه، قبلی حذف بشه
      _quantities.clear();

      final next = (delta > 0) ? 1 : 0;

      if (next == 0) {
        _quantities.remove(id);
      } else {
        _quantities[id] = 1; // فقط 1 عدد مجاز
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

  void _showLoadingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(
        child: CircularProgressIndicator(
          color: Colors.white,
        ),
      ),
    );
  }



  void _showOrderDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return const OrderStatusDialog();
      },
    );
  }



  Future<void> _onPay() async {
    if (_totalItems == 0 || _isPaying) return;

    final lines = _buildOrderLines();

    // دیالوگ حالا دو مقدار رو برمی‌گردونه: تایید شدن و خواستن لیوان
    final result = await showOrderConfirmDialog(
      context,
      items: lines,
      totalItems: _totalItems,
      totalPrice: _totalPrice,
    );

    // اگر تایید نکرده بود، کلا خارج شو
    if (!result.confirmed) {
      return;
    }

    setState(() => _isPaying = true);

    OrderStatusDialog.update(OrderStep.preparing);
    _showOrderDialog();

    try {
      for (final entry in _quantities.entries) {
        // ارسال دیتا به همراه متغیر لیوان (result.wantsCup)
        final success = await BleManager().sendOrder(
          entry.key,
          entry.value,
          result.wantsCup, // <--- این بخش اضافه شد
        );

        if (!success) throw Exception();
        await Future.delayed(const Duration(milliseconds: 200));
      }

      final response = await BleManager().waitForResponse();

      debugPrint("FINAL RESPONSE = $response");

      if (response.trim() == "1") {
        OrderStatusDialog.update(OrderStep.success);
        setState(() => _quantities.clear());
      } else {
        OrderStatusDialog.update(OrderStep.failed);
      }
    } catch (e) {
      OrderStatusDialog.update(OrderStep.failed);
    }

    setState(() => _isPaying = false);

    await Future.delayed(const Duration(seconds: 2));

    if (mounted) Navigator.of(context).pop();
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
                      padding: const EdgeInsets.fromLTRB(
                        16,
                        0,
                        16,
                        0,
                      ),
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

                          final qty =
                              _quantities[product.id] ?? 0;

                          return CoffeeCard(
                            product: product,
                            quantity: qty,
                            index: index,
                            onIncrement: () {
                              _changeQty(product.id, 1);
                            },
                            onDecrement: () {
                              _changeQty(product.id, -1);
                            },
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
          const Icon(
            Icons.local_cafe_rounded,
            color: AppColors.accent,
          ),

          const SizedBox(width: 8),

          Text(
            'منوی نوشیدنی',
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),

          const Spacer(),

          Text(
            '$totalItems انتخاب',
            style: const TextStyle(
              color: AppColors.success,
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuHeader extends StatelessWidget {
  const _MenuHeader({
    required this.totalItems,
    required this.floatAnimation,
  });

  final int totalItems;
  final Animation<double> floatAnimation;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          color: Colors.white.withValues(alpha: 0.08),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.coffee,
              color: AppColors.accent,
              size: 32,
            ),

            const SizedBox(width: 12),

            Expanded(
              child: Text(
                'ماشین قهوه',
                style: Theme.of(context)
                    .textTheme
                    .titleLarge,
              ),
            ),

            CircleAvatar(
              backgroundColor: AppColors.accent,
              child: Text(
                '$totalItems',
                style: const TextStyle(
                  color: Colors.black,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}