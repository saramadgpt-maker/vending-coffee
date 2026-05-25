import 'package:flutter/material.dart';
import 'package:venidng_coffee/screens/splash_screen.dart';
import 'package:venidng_coffee/theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // متد BleManager().init() از اینجا حذف و به اسپلش‌اسکرین منتقل شد.
  runApp(const VendingCoffeeApp());
}

class VendingCoffeeApp extends StatelessWidget {
  const VendingCoffeeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Vending Coffee',
      debugShowCheckedModeBanner: false,
      theme: buildVendingTheme(),
      builder: (context, child) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: child!,
        );
      },
      home: const SplashScreen(),
    );
  }
}