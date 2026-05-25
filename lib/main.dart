import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart'; // ۱. اضافه کردن پکیج
import 'package:venidng_coffee/screens/splash_screen.dart';
import 'package:venidng_coffee/theme/app_theme.dart';
import 'package:venidng_coffee/utils/ble_manager.dart';

void main() async {
  // مطمئن می‌شویم که بایندینگ فلاتر آماده است
  WidgetsFlutterBinding.ensureInitialized();

  // ۲. درخواست دسترسی‌های بلوتوث پیش از ران شدن متد BleManager
  await _requestBluetoothPermissions();

  // ۳. مقداردهی اولیه بلوتوث
  BleManager().init();

  runApp(const VendingCoffeeApp());
}

// متد اختصاصی برای گرفتن مجوزها
Future<void> _requestBluetoothPermissions() async {
  // در اندروید ۱۲ به بالا نیاز به SCAN و CONNECT داریم. موقعیت مکانی (Location) هم برای اسکن حیاتی است.
  Map<Permission, PermissionStatus> statuses = await [
    Permission.bluetoothScan,
    Permission.bluetoothConnect,
    Permission.location, // برای پیدا کردن دستگاه‌های BLE معمولاً اجباری است
  ].request();

  // چک کردن اینکه آیا دسترسی‌ها داده شده‌اند یا خیر (اختیاری برای لاگ یا مدیریت خطا)
  if (statuses[Permission.bluetoothConnect]?.isGranted ?? false) {
    debugPrint("دسترسی بلوتوث تایید شد.");
  } else {
    debugPrint("کاربر دسترسی بلوتوث را رد کرد.");
  }
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