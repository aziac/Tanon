import 'package:flutter/material.dart';

class Win95Theme {
  // Classic Windows 95 colors
  static const Color buttonFace = Color(0xFFC0C0C0);
  static const Color buttonHighlight = Color(0xFFFFFFFF);
  static const Color buttonShadow = Color(0xFF808080);
  static const Color buttonDarkShadow = Color(0xFF000000);
  static const Color buttonText = Color(0xFF000000);
  static const Color windowFrame = Color(0xFF000080);
  static const Color activeTitle = Color(0xFF000080);
  static const Color activeTitleText = Color(0xFFFFFFFF);
  static const Color inactiveTitle = Color(0xFF808080);
  static const Color inactiveTitleText = Color(0xFFC0C0C0);
  static const Color windowBackground = Color(0xFFC0C0C0);
  static const Color menuText = Color(0xFF000000);
  static const Color desktop = Color(0xFF008080);

  static ThemeData get themeData {
    return ThemeData(
      scaffoldBackgroundColor: desktop,
      primaryColor: activeTitle,
      fontFamily: 'MS Sans Serif',
      textTheme: const TextTheme(
        bodyLarge: TextStyle(
          fontFamily: 'Courier New',
          fontSize: 14,
          color: buttonText,
        ),
        bodyMedium: TextStyle(
          fontFamily: 'Courier New',
          fontSize: 13,
          color: buttonText,
        ),
        titleLarge: TextStyle(
          fontFamily: 'MS Sans Serif',
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: activeTitleText,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: buttonFace,
          foregroundColor: buttonText,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.zero,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return buttonFace;
          }
          return Colors.white;
        }),
        checkColor: MaterialStateProperty.all(buttonText),
        side: const BorderSide(color: buttonDarkShadow, width: 1),
      ),
    );
  }
}

// Win95 raised border decoration
BoxDecoration win95Raised() {
  return const BoxDecoration(
    color: Win95Theme.buttonFace,
    border: Border(
      top: BorderSide(color: Win95Theme.buttonHighlight, width: 2),
      left: BorderSide(color: Win95Theme.buttonHighlight, width: 2),
      right: BorderSide(color: Win95Theme.buttonDarkShadow, width: 2),
      bottom: BorderSide(color: Win95Theme.buttonDarkShadow, width: 2),
    ),
  );
}

// Win95 inset border decoration
BoxDecoration win95Inset() {
  return const BoxDecoration(
    color: Colors.white,
    border: Border(
      top: BorderSide(color: Win95Theme.buttonDarkShadow, width: 2),
      left: BorderSide(color: Win95Theme.buttonDarkShadow, width: 2),
      right: BorderSide(color: Win95Theme.buttonHighlight, width: 2),
      bottom: BorderSide(color: Win95Theme.buttonHighlight, width: 2),
    ),
  );
}
