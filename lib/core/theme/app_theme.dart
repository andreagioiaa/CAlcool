import 'package:flutter/material.dart';

class AppTheme {
  // Light Mode Colors
  static const Color lightBackground = Color(0xFFE0E5EC);
  static const Color lightShadow = Color(0xFFFFFFFF);
  static const Color darkShadow = Color(0xFFA3B1C6);
  static const Color lightText = Color(0xFF333333);
  static const Color primaryColor = Color(0xFFD97706);
  static const Color dangerColor = Color(0xFFD32F2F);

  // Dark Mode Colors
  static const Color darkBackground = Color(0xFF292D32);
  static const Color darkShadowDark = Color(0xFF1C1F22);
  static const Color darkShadowLight = Color(0xFF363B42);
  static const Color darkText = Color(0xFFE0E5EC);

  static ThemeData get lightTheme {
    return ThemeData(
      scaffoldBackgroundColor: lightBackground,
      primaryColor: primaryColor,
      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: lightText),
        bodyMedium: TextStyle(color: lightText),
      ),
      colorScheme: ColorScheme.light(
        primary: primaryColor,
        surface: lightBackground,
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      scaffoldBackgroundColor: darkBackground,
      primaryColor: primaryColor,
      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: darkText),
        bodyMedium: TextStyle(color: darkText),
      ),
      colorScheme: ColorScheme.dark(
        primary: primaryColor,
        surface: darkBackground,
      ),
    );
  }

  // Helper for Neumorphic Box Decoration
  static BoxDecoration neumorphicBox(BuildContext context, {double radius = 15, bool isPressed = false}) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final bg = isDarkMode ? darkBackground : lightBackground;
    final s1 = isDarkMode ? darkShadowDark : darkShadow;
    final s2 = isDarkMode ? darkShadowLight : lightShadow;

    if (isPressed) {
      return BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(radius),
        boxShadow: [
          BoxShadow(
            color: s1,
            offset: const Offset(inset, inset), // Note: inset shadow is hard to do with standard BoxShadow
            blurRadius: 5,
            spreadRadius: 1,
          ),
          BoxShadow(
            color: s2,
            offset: const Offset(-inset, -inset),
            blurRadius: 5,
            spreadRadius: 1,
          ),
        ],
      );
    }
    // Standard convex neumorphic
    return BoxDecoration(
      color: bg,
      borderRadius: BorderRadius.circular(radius),
      boxShadow: [
        BoxShadow(
          color: s1,
          offset: const Offset(4, 4),
          blurRadius: 8,
          spreadRadius: 1,
        ),
        BoxShadow(
          color: s2,
          offset: const Offset(-4, -4),
          blurRadius: 8,
          spreadRadius: 1,
        ),
      ],
    );
  }
  static const double inset = 2; // For pressed effect we will just invert standard or skip it for simplicity
}
