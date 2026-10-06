import 'package:flutter/material.dart';

const lightColorScheme = ColorScheme(
  brightness: Brightness.light,
  primary: Color(0xFF1E88E5),
  onPrimary: Colors.white,
  secondary: Color(0xFF00ACC1),
  onSecondary: Colors.white,
  error: Color(0xFFB00020),
  onError: Colors.white,
  surface: Color(0xFFF0F4F8),
  onSurface: Color(0xFF07111F),
);

const darkColorScheme = ColorScheme(
  brightness: Brightness.dark,
  primary: Color(0xFF1E88E5),
  onPrimary: Colors.white,
  secondary: Color(0xFF00ACC1),
  onSecondary: Colors.white,
  error: Color(0xFFCF6679),
  onError: Colors.black,
  surface: Color(0xFF07111F),
  onSurface: Colors.white,
);

ThemeData lightTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.light,
  colorScheme: lightColorScheme,
  scaffoldBackgroundColor: Color(0xFFF0F4F8),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ButtonStyle(
      backgroundColor: WidgetStateProperty.all<Color>(const Color(0xFF1E88E5)),
      foregroundColor: WidgetStateProperty.all<Color>(Colors.white),
      elevation: WidgetStateProperty.all<double>(5.0),
      padding: WidgetStateProperty.all<EdgeInsets>(
        const EdgeInsets.symmetric(vertical: 12.0, horizontal: 24.0),
      ),
      shape: WidgetStateProperty.all<RoundedRectangleBorder>(
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    ),
  ),
);

ThemeData darkTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.dark,
  colorScheme: darkColorScheme,
  scaffoldBackgroundColor: Color(0xFF07111F),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ButtonStyle(
      backgroundColor: WidgetStateProperty.all<Color>(const Color(0xFF1E88E5)),
      foregroundColor: WidgetStateProperty.all<Color>(Colors.white),
      elevation: WidgetStateProperty.all<double>(5.0),
      padding: WidgetStateProperty.all<EdgeInsets>(
        const EdgeInsets.symmetric(vertical: 12.0, horizontal: 24.0),
      ),
      shape: WidgetStateProperty.all<RoundedRectangleBorder>(
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    ),
  ),
);
