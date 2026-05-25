import 'package:flutter/material.dart';

enum OrderStep {
  paymentSuccess,
  preparing,
  success,
  failed,
}

class OrderStatusDialog extends StatefulWidget {
  const OrderStatusDialog({
    super.key,
  });

  static final ValueNotifier<OrderStep> notifier =
  ValueNotifier(
    OrderStep.paymentSuccess,
  );

  static void update(OrderStep step) {
    notifier.value = step;
  }

  @override
  State<OrderStatusDialog> createState() =>
      _OrderStatusDialogState();
}

class _OrderStatusDialogState
    extends State<OrderStatusDialog> {

  @override
  Widget build(BuildContext context) {

    return ValueListenableBuilder<OrderStep>(
      valueListenable: OrderStatusDialog.notifier,
      builder: (context, step, _) {

        String title = "";
        String message = "";
        IconData icon = Icons.hourglass_top;
        Color color = Colors.orange;

        switch (step) {

          case OrderStep.paymentSuccess:
            title = "پرداخت موفق";
            message =
            "پرداخت با موفقیت انجام شد";
            icon = Icons.payment_rounded;
            color = Colors.green;
            break;

          case OrderStep.preparing:
            title = "در حال آماده سازی";
            message = "لطفاً منتظر بمانید...";
            icon = Icons.coffee_rounded;
            color = Colors.orange;
            break;

          case OrderStep.success:
            title = "سفارش آماده شد";
            message = "نوش جان ☕";
            icon = Icons.check_circle_rounded;
            color = Colors.green;
            break;

          case OrderStep.failed:
            title = "خطا";
            message =
            "فرآیند با شکست مواجه شد";
            icon = Icons.error_rounded;
            color = Colors.red;
            break;
        }

        return AlertDialog(
          backgroundColor:
          const Color(0xFF1E1510),

          shape: RoundedRectangleBorder(
            borderRadius:
            BorderRadius.circular(24),
          ),

          content: SizedBox(
            height: 220,

            child: Column(
              mainAxisAlignment:
              MainAxisAlignment.center,

              children: [

                if (step ==
                    OrderStep.preparing)

                  CircularProgressIndicator(
                    color: color,
                  )

                else

                  Icon(
                    icon,
                    color: color,
                    size: 72,
                  ),

                const SizedBox(height: 24),

                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight:
                    FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 12),

                Text(
                  message,
                  textAlign:
                  TextAlign.center,

                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}