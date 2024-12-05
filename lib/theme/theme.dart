import 'package:flutter/material.dart';

class PizzaHubTheme {
  static ThemeData lightTheme = ThemeData(
    primaryColor: const Color(0xFFE53935),
    scaffoldBackgroundColor: const Color(0xFFFFF8E1),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Color(0xFF424242)),
      headlineLarge: TextStyle(
          color: Color(0xFFE53935), fontWeight: FontWeight.bold, fontSize: 20),
    ),
    buttonTheme: const ButtonThemeData(
      buttonColor: Color(0xFF43A047),
      textTheme: ButtonTextTheme.primary,
    ),
    colorScheme: const ColorScheme.light(
      primary: Color(0xFFE53935),
      secondary: Color(0xFF43A047),
      surface: Color(0xFFFFF8E1),
    ),
    useMaterial3: true,
  );

  static ThemeData darkTheme = ThemeData(
    primaryColor: const Color(0xFFE53935),
    scaffoldBackgroundColor: const Color(0xFF303030),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Colors.white),
      headlineLarge: TextStyle(
          color: Color(0xFFE53935), fontWeight: FontWeight.bold, fontSize: 20),
    ),
    buttonTheme: const ButtonThemeData(
      buttonColor: Color(0xFF43A047),
      textTheme: ButtonTextTheme.primary,
    ),
    colorScheme: const ColorScheme.dark(
      primary: Color(0xFFE53935),
      secondary: Color(0xFF43A047),
      surface: Color(0xFF303030),
    ),
    useMaterial3: true,
  );
}
