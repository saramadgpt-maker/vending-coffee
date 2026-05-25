import 'dart:async';
import 'package:flutter/material.dart';
import 'package:venidng_coffee/screens/menu_screen.dart';
import 'package:venidng_coffee/utils/ble_manager.dart'; // اضافه کردن بلیم منجر
import 'package:venidng_coffee/widgets/logo_widget.dart';
import 'package:venidng_coffee/widgets/vending_background.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    // ۱. درخواست دسترسی‌های بلوتوث از کاربر
    bool hasPermissions = await BleManager().requestPermissions();

    if (hasPermissions) {
      // ۲. اگر دسترسی داده شد، بلوتوث ران می‌شود
      BleManager().init();

      // ۳. هدایت کاربر به صفحه اصلی بعد از یک تاخیر کوتاه (مثلا ۲ ثانیه برای نمایش اسپلش)
      Timer(const Duration(seconds: 2), () {
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const MenuScreen()),
          );
        }
      });
    } else {
      // اگر کاربر دسترسی نداد، می‌توانید یک دیالوگ راهنما نمایش دهید یا برنامه را متوقف کنید
      if (mounted) {
        _showPermissionDeniedDialog();
      }
    }
  }

  void _showPermissionDeniedDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('خطا در دسترسی'),
        content: const Text('این اپلیکیشن برای ارتباط با دستگاه قهوه‌ساز حتماً به دسترسی بلوتوث و موقعیت مکانی نیاز دارد.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _initializeApp(); // تلاش مجدد
            },
            child: const Text('تلاش مجدد'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: VendingBackground(
        child: Center(
          child: LogoWidget(),
        ),
      ),
    );
  }
}