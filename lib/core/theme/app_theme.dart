import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vbox/core/theme/app_colors.dart';

class AppText {
  static const String family = 'Poppins';

  static TextStyle get heading => const TextStyle(
        fontFamily: family,
        fontSize: 26,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
        height: 1.2,
      );

  static TextStyle get title => const TextStyle(
        fontFamily: family,
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      );

  static TextStyle get body => const TextStyle(
        fontFamily: family,
        fontSize: 15,
        fontWeight: FontWeight.w400,
        color: AppColors.textPrimary,
      );

  static TextStyle get caption => const TextStyle(
        fontFamily: family,
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: AppColors.textSecondary,
      );
}

class AppTheme {
  static ThemeData get dark {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      fontFamily: AppText.family,
      scaffoldBackgroundColor: AppColors.bg,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.copper,
        secondary: AppColors.connected,
        surface: AppColors.surface,
        error: AppColors.danger,
        onPrimary: AppColors.bg,
        onSurface: AppColors.cream,
      ),
    );

    final text = base.textTheme.apply(
      fontFamily: AppText.family,
      bodyColor: AppColors.textPrimary,
      displayColor: AppColors.textPrimary,
    );

    return base.copyWith(
      textTheme: text,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        foregroundColor: AppColors.textPrimary,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        titleTextStyle: TextStyle(
          fontFamily: AppText.family,
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        iconTheme: IconThemeData(color: AppColors.textSecondary),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.surfaceHigh,
        contentTextStyle: const TextStyle(
          fontFamily: AppText.family,
          color: AppColors.textPrimary,
          fontSize: 14,
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
      dividerColor: AppColors.divider,
      dividerTheme: const DividerThemeData(color: AppColors.divider, space: 1),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        hintStyle: const TextStyle(
          fontFamily: AppText.family,
          color: AppColors.textSecondary,
          fontSize: 14,
        ),
        labelStyle: const TextStyle(
          fontFamily: AppText.family,
          color: AppColors.textSecondary,
          fontSize: 14,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: AppColors.divider),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: AppColors.divider),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.4),
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.surface,
        modalBackgroundColor: AppColors.surface,
      ),
      tabBarTheme: const TabBarThemeData(
        indicatorColor: AppColors.primary,
        labelColor: AppColors.primarySoft,
        unselectedLabelColor: AppColors.textSecondary,
        labelStyle: TextStyle(
          fontFamily: AppText.family,
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
        unselectedLabelStyle: TextStyle(
          fontFamily: AppText.family,
          fontSize: 14,
        ),
      ),
    );
  }
}
