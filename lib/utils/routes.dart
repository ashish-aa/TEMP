import 'package:flutter/material.dart';

/// 🎨 COLORS
class AppColors {
  static const primary = Color(0xFF2563EB);
  static const primaryLight = Color(0xFF3B82F6);

  static const background = Color(0xFFF8FAFC);
  static const cardBg = Colors.white;

  static const textPrimary = Color(0xFF1E293B);
  static const textSecondary = Color(0xFF64748B);

  static const border = Color(0xFFE2E8F0);

  static const success = Color(0xFF16A34A);
  static const successBg = Color(0xFFDCFCE7);

  static const error = Color(0xFFDC2626);

  /// DARK MODE
  static const darkBg = Color(0xFF0F172A);
  static const darkCard = Color(0xFF1E293B);
}

/// 📏 SPACING
class AppSpacing {
  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 16.0;
  static const lg = 24.0;
  static const xl = 32.0;
}

/// 🔲 RADIUS
class AppRadius {
  static const small = 8.0;
  static const medium = 12.0;
  static const large = 16.0;
  static const xLarge = 24.0;
}

/// 🔤 TEXT STYLES (VERY IMPORTANT 🔥)
class AppTextStyles {
  static const heading = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );

  static const subHeading = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static const body = TextStyle(fontSize: 14, color: AppColors.textSecondary);

  static const button = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  );
}

/// 🌑 SHADOWS
class AppShadows {
  static final card = BoxShadow(
    color: Colors.black.withOpacity(0.05),
    blurRadius: 10,
    offset: const Offset(0, 4),
  );
}

/// 🎨 THEME (USE IN main.dart 🔥)
class AppTheme {
  static ThemeData lightTheme = ThemeData(
    scaffoldBackgroundColor: AppColors.background,
    primaryColor: AppColors.primary,

    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      elevation: 0,
      foregroundColor: AppColors.textPrimary,
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.medium),
        ),
      ),
    ),
  );

  static ThemeData darkTheme = ThemeData(
    scaffoldBackgroundColor: AppColors.darkBg,
    brightness: Brightness.dark,
  );
}
