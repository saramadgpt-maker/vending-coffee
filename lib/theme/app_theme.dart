import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const background = Color(0xFF0F0A07);
  static const backgroundMid = Color(0xFF1A1009);
  static const surface = Color(0xFF241A12);
  static const card = Color(0xFF322418);
  static const glass = Color(0x33FFFFFF);
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
    stops: [0, 0.5, 1],
  );

  static const accent = LinearGradient(
    colors: [AppColors.accentBright, AppColors.accent, AppColors.accentDark],
  );

  static const goldText = LinearGradient(
    colors: [AppColors.accentBright, AppColors.accent],
  );

  static const payButton = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFF5D08A), Color(0xFFE8B86D), Color(0xFFC89446)],
  );
}

ThemeData buildVendingTheme() {
  final base = GoogleFonts.vazirmatnTextTheme(
    ThemeData.dark().textTheme,
  );

  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.background,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.accent,
      secondary: AppColors.accentDark,
      surface: AppColors.surface,
    ),
    textTheme: base.copyWith(
      headlineMedium: base.headlineMedium?.copyWith(
        color: AppColors.cream,
        fontWeight: FontWeight.w800,
        fontSize: 28,
        height: 1.2,
      ),
      titleLarge: base.titleLarge?.copyWith(
        color: AppColors.cream,
        fontWeight: FontWeight.w700,
        fontSize: 20,
      ),
      titleMedium: base.titleMedium?.copyWith(
        color: AppColors.cream,
        fontWeight: FontWeight.w600,
        fontSize: 16,
      ),
      bodyLarge: base.bodyLarge?.copyWith(
        color: AppColors.cream,
        fontSize: 15,
      ),
      bodyMedium: base.bodyMedium?.copyWith(
        color: AppColors.textMuted,
        fontSize: 13,
      ),
      labelLarge: base.labelLarge?.copyWith(
        fontWeight: FontWeight.w800,
        letterSpacing: 0.5,
      ),
    ),
  );
}

class GradientText extends StatelessWidget {
  const GradientText(
    this.text, {
    super.key,
    required this.style,
    this.gradient = AppGradients.goldText,
  });

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
