import 'package:flutter/material.dart';
import '../utils/constants.dart';
import '../providers/theme_provider.dart'; // Correct import for ThemeProvider

class AppTheme {
  static ThemeData lightTheme(
    BuildContext context,
    ThemeProvider themeProvider,
  ) {
    final isHighContrast = themeProvider.highContrast;
    return ThemeData(
      brightness: Brightness.light,
      primaryColor: isHighContrast ? Colors.black : themeProvider.accentColor,
      colorScheme: ColorScheme.light(
        primary: isHighContrast ? Colors.black : themeProvider.accentColor,
        secondary: isHighContrast ? Colors.yellow : themeProvider.accentColor,
        surface: isHighContrast ? Colors.white : Colors.white,
        onPrimary: isHighContrast ? Colors.white : Colors.black,
        onSecondary: isHighContrast ? Colors.black : Colors.white,
      ),
      textTheme: _buildTextTheme(context, themeProvider),
      useMaterial3: true,
      fontFamily: 'Open Sans',
      appBarTheme: const AppBarTheme(
        elevation: 0,
        centerTitle: true,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black87,
      ),
      cardTheme: CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              AppConstants.buttonBorderRadius,
            ),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.buttonBorderRadius),
        ),
        filled: true,
      ),
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
    );
  }

  static ThemeData darkTheme(
    BuildContext context,
    ThemeProvider themeProvider,
  ) {
    final isHighContrast = themeProvider.highContrast;
    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: isHighContrast ? Colors.white : themeProvider.accentColor,
      colorScheme: ColorScheme.dark(
        primary: isHighContrast ? Colors.white : themeProvider.accentColor,
        secondary: isHighContrast ? Colors.yellow : themeProvider.accentColor,
        surface: isHighContrast ? Colors.black : Colors.black,
        onPrimary: isHighContrast ? Colors.black : Colors.white,
        onSecondary: isHighContrast ? Colors.black : Colors.white,
      ),
      textTheme: _buildTextTheme(context, themeProvider),
      useMaterial3: true,
      fontFamily: 'Open Sans',
      scaffoldBackgroundColor: const Color(0xFF1A1A1A),
      appBarTheme: const AppBarTheme(
        elevation: 0,
        centerTitle: true,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
      ),
      cardTheme: CardThemeData(
        elevation: 4,
        color: const Color(0xFF2A2A2A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 2,
          backgroundColor: AppConstants.primaryColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              AppConstants.buttonBorderRadius,
            ),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.buttonBorderRadius),
        ),
        filled: true,
        fillColor: const Color(0xFF2A2A2A),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: const Color(0xFF3A3A3A),
        labelStyle: const TextStyle(color: Colors.white),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      dividerTheme: const DividerThemeData(
        color: Color(0xFF3A3A3A),
        thickness: 1,
      ),
      iconTheme: const IconThemeData(color: Colors.white70),
    );
  }

  static TextTheme _buildTextTheme(
    BuildContext context,
    ThemeProvider themeProvider,
  ) {
    final base = Theme.of(context).textTheme;
    return base.copyWith(
      headlineLarge: base.headlineLarge?.copyWith(
        fontSize: themeProvider.fontSize + 8,
      ),
      headlineMedium: base.headlineMedium?.copyWith(
        fontSize: themeProvider.fontSize + 4,
      ),
      headlineSmall: base.headlineSmall?.copyWith(
        fontSize: themeProvider.fontSize + 2,
      ),
      bodyLarge: base.bodyLarge?.copyWith(fontSize: themeProvider.fontSize),
      bodyMedium: base.bodyMedium?.copyWith(
        fontSize: themeProvider.fontSize - 2,
      ),
      bodySmall: base.bodySmall?.copyWith(fontSize: themeProvider.fontSize - 4),
    );
  }

  static Color getStatusColor(String status) {
    return AppConstants.statusColors[status] ?? Colors.grey;
  }

  static TextStyle getHeadlineStyle(BuildContext context) {
    return Theme.of(context).textTheme.headlineMedium?.copyWith(
          fontFamily: 'Roboto Slab',
          fontWeight: FontWeight.bold,
        ) ??
        const TextStyle(
          fontFamily: 'Roboto Slab',
          fontWeight: FontWeight.bold,
          fontSize: 24,
        );
  }

  static TextStyle getBodyStyle(BuildContext context) {
    return Theme.of(
          context,
        ).textTheme.bodyMedium?.copyWith(fontFamily: 'Open Sans') ??
        const TextStyle(fontFamily: 'Open Sans', fontSize: 14);
  }

  static BoxDecoration getCardDecoration(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return BoxDecoration(
      color: isDark ? const Color(0xFF2A2A2A) : Colors.white,
      borderRadius: BorderRadius.circular(AppConstants.cardBorderRadius),
      boxShadow: [
        BoxShadow(
          color: isDark ? Colors.black26 : Colors.black12,
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ],
    );
  }

  static BoxDecoration getGradientDecoration() {
    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          AppConstants.primaryColor,
          AppConstants.primaryColor.withValues(alpha: 0.8),
        ],
      ),
      borderRadius: BorderRadius.circular(AppConstants.cardBorderRadius),
    );
  }
}
