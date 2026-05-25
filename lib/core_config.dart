import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// --- MODELS ---
class CoffeeProduct {
  const CoffeeProduct({
    required this.id,
    required this.name,
    required this.price,
    required this.icon,
    required this.color,
    required this.gradientStart,
    required this.gradientEnd,
  });

  final String id;
  final String name;
  final int price;
  final IconData icon;
  final Color color;
  final Color gradientStart;
  final Color gradientEnd;

  LinearGradient get cardGradient => LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [gradientStart, gradientEnd],
      );
}

class OrderLine {
  final String name;
  final int quantity;
  final int unitPrice;
  final IconData icon;
  final Color gradientStart;
  final Color gradientEnd;

  OrderLine({
    required this.name,
    required this.quantity,
    required this.unitPrice,
    required this.icon,
    required this.gradientStart,
    required this.gradientEnd,
  });

  int get totalPrice => quantity * unitPrice;
}

// --- COLORS & THEME ---
class AppColors {
  static const background = Color(0xFF0F0A07);
  static const surface = Color(0xFF241A12);
  static const accent = Color(0xFFE8B86D);
  static const accentBright = Color(0xFFF5D08A);
  static const accentDark = Color(0xFFC89446);
  static const cream = Color(0xFFFFF8F0);
  static const textMuted = Color(0xFF9E8B7A);
  static const success = Color(0xFF6BCB77);
}

class AppGradients {
  static const background = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1F140C), AppColors.background, Color(0xFF0A0604)],
  );
  static const accent = LinearGradient(
    colors: [AppColors.accentBright, AppColors.accent, AppColors.accentDark],
  );
  static const goldText = LinearGradient(
    colors: [AppColors.accentBright, AppColors.accent],
  );
}

ThemeData buildVendingTheme() {
  final base = GoogleFonts.vazirmatnTextTheme(ThemeData.dark().textTheme);
  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.background,
    colorScheme: const ColorScheme.dark(primary: AppColors.accent, surface: AppColors.surface),
    textTheme: base.copyWith(
      headlineMedium: base.headlineMedium?.copyWith(color: AppColors.cream, fontWeight: FontWeight.w800, fontSize: 28),
      titleLarge: base.titleLarge?.copyWith(color: AppColors.cream, fontWeight: FontWeight.w700, fontSize: 20),
      titleMedium: base.titleMedium?.copyWith(color: AppColors.cream, fontWeight: FontWeight.w600, fontSize: 16),
      bodyLarge: base.bodyLarge?.copyWith(color: AppColors.cream, fontSize: 15),
      bodyMedium: base.bodyMedium?.copyWith(color: AppColors.textMuted, fontSize: 13),
    ),
  );
}

class GradientText extends StatelessWidget {
  const GradientText(this.text, {super.key, required this.style, this.gradient = AppGradients.goldText});
  final String text;
  final TextStyle style;
  final Gradient gradient;

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      blendMode: BlendMode.srcIn,
      shaderCallback: (bounds) => gradient.createShader(bounds),
      child: Text(text, style: style.copyWith(color: Colors.white)),
    );
  }
}

// --- DATA ---
const List<CoffeeProduct> coffeeCatalog = [
  CoffeeProduct(id: '1', name: 'اسپرسو', price: 45000, icon: Icons.coffee_rounded, color: Color(0xFF5D4037), gradientStart: Color(0xFF4E342E), gradientEnd: Color(0xFF8D6E63)),
  CoffeeProduct(id: '2', name: 'کاپوچینو', price: 65000, icon: Icons.local_cafe_rounded, color: Color(0xFF6D4C41), gradientStart: Color(0xFF5D4037), gradientEnd: Color(0xFFA1887F)),
  CoffeeProduct(id: '3', name: 'لاته', price: 70000, icon: Icons.coffee_outlined, color: Color(0xFF8D6E63), gradientStart: Color(0xFF6D4C41), gradientEnd: Color(0xFFD7CCC8)),
  CoffeeProduct(id: '4', name: 'آمریکانو', price: 55000, icon: Icons.water_drop_rounded, color: Color(0xFF4E342E), gradientStart: Color(0xFF3E2723), gradientEnd: Color(0xFF795548)),
  CoffeeProduct(id: '5', name: 'موکا', price: 75000, icon: Icons.emoji_food_beverage_rounded, color: Color(0xFF3E2723), gradientStart: Color(0xFF3E2723), gradientEnd: Color(0xFF5D4037)),
  CoffeeProduct(id: '6', name: 'هات‌چاکلت', price: 60000, icon: Icons.cake_rounded, color: Color(0xFF795548), gradientStart: Color(0xFF4E342E), gradientEnd: Color(0xFF8D6E63)),
];
