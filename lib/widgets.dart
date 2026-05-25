import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:venidng_coffee/core_config.dart';

// --- BACKGROUNDS & DECORATIONS ---
class VendingBackground extends StatelessWidget {
  final Widget child;
  const VendingBackground({super.key, required this.child});
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(gradient: AppGradients.background),
      child: Stack(
        children: [
          Positioned(
            top: -100,
            left: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.accent.withOpacity(0.05),
              ),
            ),
          ),
          child,
        ],
      ),
    );
  }
}

class PanelTopShine extends StatelessWidget {
  const PanelTopShine({super.key, required this.height});
  final double height;
  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      height: height,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.white.withOpacity(0.08), Colors.transparent],
          ),
        ),
      ),
    );
  }
}

// --- COFFEE CARD ---
class CoffeeCard extends StatefulWidget {
  const CoffeeCard({
    super.key,
    required this.product,
    required this.quantity,
    required this.onIncrement,
    required this.onDecrement,
  });

  final CoffeeProduct product;
  final int quantity;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  @override
  State<CoffeeCard> createState() => _CoffeeCardState();
}

class _CoffeeCardState extends State<CoffeeCard> {
  @override
  Widget build(BuildContext context) {
    final isSelected = widget.quantity > 0;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        color: isSelected ? AppColors.surface : Colors.white.withOpacity(0.05),
        border: Border.all(
          color: isSelected ? AppColors.accent : Colors.white.withOpacity(0.1),
          width: isSelected ? 2 : 1,
        ),
      ),
      child: InkWell(
        onTap: widget.onIncrement,
        borderRadius: BorderRadius.circular(22),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(widget.product.icon, size: 40, color: isSelected ? AppColors.accent : AppColors.cream),
              const SizedBox(height: 8),
              Text(widget.product.name, style: Theme.of(context).textTheme.titleMedium),
              Text('${widget.product.price} تومان', style: Theme.of(context).textTheme.bodySmall),
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(onPressed: widget.onDecrement, icon: const Icon(Icons.remove_circle_outline)),
                  Text('${widget.quantity}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  IconButton(onPressed: widget.onIncrement, icon: const Icon(Icons.add_circle_outline)),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}

// --- PAYMENT BAR ---
class PaymentBar extends StatelessWidget {
  const PaymentBar({
    super.key,
    required this.totalItems,
    required this.totalPrice,
    required this.onPay,
  });

  final int totalItems;
  final int totalPrice;
  final VoidCallback onPay;

  @override
  Widget build(BuildContext context) {
    if (totalItems == 0) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 10)],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('جمع کل:', style: TextStyle(color: AppColors.textMuted)),
                Text('$totalPrice تومان', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.accentBright)),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: onPay,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accent,
              foregroundColor: AppColors.background,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: const Text('پرداخت و دریافت', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
