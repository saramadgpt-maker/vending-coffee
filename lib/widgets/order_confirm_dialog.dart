import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:venidng_coffee/models/order_line.dart';
import 'package:venidng_coffee/theme/app_decorations.dart';
import 'package:venidng_coffee/theme/app_theme.dart';
import 'package:venidng_coffee/utils/price_format.dart';

// نوع بازگشتی به یک رکورد (Record) تبدیل شد تا دو مقدار را همزمان برگرداند
Future<({bool confirmed, bool wantsCup})> showOrderConfirmDialog(
    BuildContext context, {
      required List<OrderLine> items,
      required int totalItems,
      required int totalPrice,
    }) {
  return showGeneralDialog<({bool confirmed, bool wantsCup})>(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'بستن',
    barrierColor: Colors.black.withValues(alpha: 0.75),
    transitionDuration: const Duration(milliseconds: 380),
    pageBuilder: (_, __, ___) => _OrderConfirmBody(
      items: items,
      totalItems: totalItems,
      totalPrice: totalPrice,
    ),
    transitionBuilder: (context, animation, _, child) {
      final curve = CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);
      return FadeTransition(
        opacity: curve,
        child: SlideTransition(
          position: Tween<Offset>(begin: const Offset(0, 0.06), end: Offset.zero)
              .animate(curve),
          child: child,
        ),
      );
    },
  ).then((value) => value ?? (confirmed: false, wantsCup: false));
}

class _OrderConfirmBody extends StatefulWidget {
  const _OrderConfirmBody({
    required this.items,
    required this.totalItems,
    required this.totalPrice,
  });

  final List<OrderLine> items;
  final int totalItems;
  final int totalPrice;

  @override
  State<_OrderConfirmBody> createState() => _OrderConfirmBodyState();
}

class _OrderConfirmBodyState extends State<_OrderConfirmBody> {
  // به صورت پیش‌فرض لیوان انتخاب شده است (تا کاربر افزایش قیمت را ببیند)
  bool _wantsCup = true;
  final int _cupPrice = 10000;

  @override
  Widget build(BuildContext context) {
    // محاسبه قیمت نهایی با یا بدون لیوان
    final finalPrice = widget.totalPrice + (_wantsCup ? _cupPrice : 0);

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 22),
        child: Material(
          color: Colors.transparent,
          child: Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.sizeOf(context).height * 0.8,
              maxWidth: 440,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF352618), Color(0xFF1E1510)],
              ),
              border: Border.all(color: AppColors.accent.withValues(alpha: 0.3)),
              boxShadow: [
                BoxShadow(
                  color: AppColors.accent.withValues(alpha: 0.2),
                  blurRadius: 48,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(30),
              child: Stack(
                children: [
                  const PanelTopShine(height: 100),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _DialogHeader(totalItems: widget.totalItems),
                      Flexible(
                        child: ListView.separated(
                          shrinkWrap: true,
                          padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                          itemCount: widget.items.length,
                          separatorBuilder: (_, __) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 2),
                            child: Divider(
                              height: 1,
                              color: Colors.white.withValues(alpha: 0.07),
                            ),
                          ),
                          itemBuilder: (context, index) => _OrderLineRow(
                            line: widget.items[index],
                            index: index + 1,
                          ),
                        ),
                      ),

                      // بخش انتخاب لیوان
                      _CupSelectionToggle(
                        wantsCup: _wantsCup,
                        cupPrice: _cupPrice,
                        onChanged: (val) {
                          HapticFeedback.lightImpact();
                          setState(() => _wantsCup = val);
                        },
                      ),

                      // نمایش قیمت نهایی که آپدیت می‌شود
                      _TotalSection(totalPrice: finalPrice),

                      _ActionButtons(
                        onCancel: () => Navigator.of(context).pop((confirmed: false, wantsCup: _wantsCup)),
                        onConfirm: () {
                          HapticFeedback.mediumImpact();
                          Navigator.of(context).pop((confirmed: true, wantsCup: _wantsCup));
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ویجت جدید برای سوییچ لیوان
class _CupSelectionToggle extends StatelessWidget {
  const _CupSelectionToggle({
    required this.wantsCup,
    required this.cupPrice,
    required this.onChanged,
  });

  final bool wantsCup;
  final int cupPrice;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      padding: const EdgeInsets.fromLTRB(16, 12, 12, 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: wantsCup ? AppColors.accent.withValues(alpha: 0.5) : Colors.white.withValues(alpha: 0.06),
          width: wantsCup ? 1.5 : 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: wantsCup ? AppColors.accent.withValues(alpha: 0.15) : Colors.white.withValues(alpha: 0.05),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.local_cafe_outlined, // آیکون لیوان
              color: wantsCup ? AppColors.accentBright : AppColors.textMuted,
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'لیوان کاغذی',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: wantsCup ? Colors.white : AppColors.textMuted,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '+ ${formatToman(cupPrice)} تومان',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontSize: 11,
                    color: wantsCup ? AppColors.accentBright : AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: wantsCup,
            onChanged: onChanged,
            activeColor: AppColors.background,
            activeTrackColor: AppColors.accent,
            inactiveThumbColor: AppColors.textMuted,
            inactiveTrackColor: Colors.white.withValues(alpha: 0.1),
          ),
        ],
      ),
    );
  }
}

class _DialogHeader extends StatelessWidget {
  const _DialogHeader({required this.totalItems});

  final int totalItems;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 26, 24, 14),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  AppColors.accent.withValues(alpha: 0.25),
                  AppColors.accent.withValues(alpha: 0.05),
                ],
              ),
              border: Border.all(color: AppColors.accent.withValues(alpha: 0.45)),
              boxShadow: [
                BoxShadow(
                  color: AppColors.accent.withValues(alpha: 0.2),
                  blurRadius: 16,
                ),
              ],
            ),
            child: const Icon(
              Icons.receipt_long_rounded,
              color: AppColors.accentBright,
              size: 30,
            ),
          ),
          const SizedBox(height: 16),
          GradientText(
            'تأیید سفارش',
            style: Theme.of(context).textTheme.titleLarge!.copyWith(
              fontSize: 24,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'یک نگاه آخر به سفارشت بینداز',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              gradient: AppGradients.accent,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Text(
              '$totalItems قلم در سبد خرید',
              style: const TextStyle(
                color: AppColors.background,
                fontWeight: FontWeight.w800,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OrderLineRow extends StatelessWidget {
  const _OrderLineRow({required this.line, required this.index});

  final OrderLine line;
  final int index;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white.withValues(alpha: 0.04),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Row(
        children: [
          Container(
            width: 26,
            height: 26,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.accent.withValues(alpha: 0.15),
            ),
            child: Text(
              '$index',
              style: const TextStyle(
                color: AppColors.accentBright,
                fontWeight: FontWeight.w800,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [line.gradientStart, line.gradientEnd],
              ),
              boxShadow: [
                BoxShadow(
                  color: line.gradientStart.withValues(alpha: 0.4),
                  blurRadius: 10,
                ),
              ],
            ),
            child: Icon(line.icon, color: AppColors.cream, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  line.name,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${line.quantity} × ${formatToman(line.unitPrice)} تومان',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                formatToman(line.lineTotal),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.accentBright,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                'تومان',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TotalSection extends StatelessWidget {
  const _TotalSection({required this.totalPrice});

  final int totalPrice;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 8, 20, 0),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: LinearGradient(
          colors: [
            AppColors.accent.withValues(alpha: 0.22),
            AppColors.accent.withValues(alpha: 0.06),
          ],
        ),
        border: Border.all(color: AppColors.accent.withValues(alpha: 0.35)),
      ),
      child: Row(
        children: [
          const Icon(Icons.payments_rounded, color: AppColors.accent, size: 22),
          const SizedBox(width: 10),
          Text(
            'جمع کل',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const Spacer(),
          GradientText(
            formatToman(totalPrice),
            style: Theme.of(context).textTheme.titleLarge!.copyWith(
              fontSize: 24,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(width: 4),
          Text('تومان', style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }
}

class _ActionButtons extends StatelessWidget {
  const _ActionButtons({
    required this.onCancel,
    required this.onConfirm,
  });

  final VoidCallback onCancel;
  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
      child: Row(
        children: [
          Expanded(
            child: SizedBox(
              height: 52,
              child: OutlinedButton(
                onPressed: onCancel,
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.cream,
                  side: BorderSide(color: Colors.white.withValues(alpha: 0.22)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  'انصراف',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: SizedBox(
              height: 52,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: AppGradients.payButton,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.accent.withValues(alpha: 0.4),
                      blurRadius: 14,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: onConfirm,
                    borderRadius: BorderRadius.circular(16),
                    child: const Center(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.check_circle_outline_rounded,
                            color: AppColors.background,
                            size: 22,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'تأیید و پرداخت',
                            style: TextStyle(
                              color: AppColors.background,
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}