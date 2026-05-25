import 'package:flutter/material.dart';
import 'package:venidng_coffee/theme/app_decorations.dart';
import 'package:venidng_coffee/theme/app_theme.dart';

Future<void> showPaymentSuccessDialog(BuildContext context) {
  return showGeneralDialog<void>(
    context: context,
    barrierDismissible: false,
    barrierColor: Colors.black.withValues(alpha: 0.7),
    transitionDuration: const Duration(milliseconds: 450),
    pageBuilder: (_, __, ___) => const _SuccessDialogBody(),
    transitionBuilder: (context, animation, _, child) {
      final curve = CurvedAnimation(parent: animation, curve: Curves.easeOutBack);
      return FadeTransition(
        opacity: animation,
        child: ScaleTransition(scale: curve, child: child),
      );
    },
  );
}

class _SuccessDialogBody extends StatefulWidget {
  const _SuccessDialogBody();

  @override
  State<_SuccessDialogBody> createState() => _SuccessDialogBodyState();
}

class _SuccessDialogBodyState extends State<_SuccessDialogBody>
    with SingleTickerProviderStateMixin {
  late final AnimationController _checkController;
  late final Animation<double> _checkScale;
  late final Animation<double> _ringExpand;

  @override
  void initState() {
    super.initState();
    _checkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _checkScale = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _checkController,
        curve: const Interval(0.2, 0.7, curve: Curves.elasticOut),
      ),
    );
    _ringExpand = Tween<double>(begin: 0.6, end: 1.4).animate(
      CurvedAnimation(parent: _checkController, curve: Curves.easeOut),
    );
    _checkController.forward();
  }

  @override
  void dispose() {
    _checkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.fromLTRB(28, 36, 28, 26),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(32),
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF2A3D28), Color(0xFF1E1510)],
              ),
              border: Border.all(
                color: AppColors.success.withValues(alpha: 0.4),
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.success.withValues(alpha: 0.25),
                  blurRadius: 48,
                  spreadRadius: 4,
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(32),
              child: Stack(
                children: [
                  const PanelTopShine(height: 90),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AnimatedBuilder(
                        animation: _checkController,
                        builder: (context, child) {
                          return Stack(
                            alignment: Alignment.center,
                            children: [
                              Transform.scale(
                                scale: _ringExpand.value,
                                child: Container(
                                  width: 100,
                                  height: 100,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: AppColors.success.withValues(
                                        alpha: 0.3 * (1.4 - _ringExpand.value),
                                      ),
                                      width: 2,
                                    ),
                                  ),
                                ),
                              ),
                              ScaleTransition(scale: _checkScale, child: child),
                            ],
                          );
                        },
                        child: Container(
                          width: 88,
                          height: 88,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [
                                AppColors.success.withValues(alpha: 0.35),
                                AppColors.success.withValues(alpha: 0.1),
                              ],
                            ),
                            border: Border.all(
                              color: AppColors.success.withValues(alpha: 0.6),
                              width: 2.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.success.withValues(alpha: 0.35),
                                blurRadius: 24,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.check_rounded,
                            color: AppColors.success,
                            size: 50,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      GradientText(
                        'پرداخت موفق!',
                        style: Theme.of(context).textTheme.titleLarge!.copyWith(
                              fontSize: 26,
                              fontWeight: FontWeight.w800,
                            ),
                        gradient: const LinearGradient(
                          colors: [AppColors.success, Color(0xFF8FD99A)],
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'نوشیدنی شما در حال آماده‌سازی است',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'لطفاً چند لحظه صبر کنید ☕',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              height: 1.5,
                            ),
                      ),
                      const SizedBox(height: 28),
                      SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(18),
                            gradient: AppGradients.payButton,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.accent.withValues(alpha: 0.35),
                                blurRadius: 14,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () => Navigator.of(context).pop(),
                              borderRadius: BorderRadius.circular(18),
                              child: const Center(
                                child: Text(
                                  'عالیه!',
                                  style: TextStyle(
                                    color: AppColors.background,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
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
