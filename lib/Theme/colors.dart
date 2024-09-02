import 'package:flutter/material.dart';

// Color kMainColor = const Color(0xffA66DD4);
Color kMainColor = const Color(0xfff87534);
Color k2MainColor = const Color(0xfffcdc60);
Color k4Color = const Color(0xff6863CE);
Color k5Color = const Color(0xffA66DD4);
Color kGoldColor = const Color(0xffefd027);
Color kButtonColor = const Color(0xfff87534);
Color tealColor = Colors.tealAccent;
Color greyShadeColor = Colors.blue.shade400.withOpacity(0.1);
Color kLightGreen = Colors.green;
Color kDeepGreen = Color(0XFF0D2E1C);
Color kBTextColor = Colors.white;
Color kWhiteColor = Colors.white;
Color kSubTextColor = Colors.grey;
Color kBlackColor = Colors.black;
Color kRedColor = Colors.red;
Color kDarkColor = Colors.grey.shade900;
Color kHighlightColor = Colors.grey.shade100;
Color kLoadingBackColor = Colors.white;
Color kDarkLoadingBackColor = Colors.black;

Color kScaffoldColor(BuildContext context) {
  return Theme.of(context).scaffoldBackgroundColor != Colors.black ?
  Colors.white.withOpacity(0.4) : Colors.black.withOpacity(0.6);
}

class Constants {
  static String appName = "Khwahish Partner";

  //Colors for theme
  static Color lightPrimary = const Color(0xfffcfcff);
  static Color darkPrimary = Colors.black;
  static Color? lightAccent = kMainColor;
  static Color darkAccent = Colors.white;
  static Color lightBG = Colors.grey.shade200;
  static Color darkBG = Colors.black;

  static ThemeData lightTheme = ThemeData(
    primaryColor: lightPrimary,
    hintColor: lightAccent,
    scaffoldBackgroundColor: lightBG,
    textTheme: const TextTheme(
      bodyMedium: TextStyle(fontSize: 14, color: Colors.black, fontFamily: 'Roboto'),
    ),
    appBarTheme: AppBarTheme(
      foregroundColor: Colors.black,
      backgroundColor: lightBG,
      elevation: 0,
      toolbarTextStyle: TextTheme(
        titleLarge: TextStyle(
          color: darkBG,
          fontSize: 16.0,
          fontWeight: FontWeight.w600,
          fontFamily: 'Barlow'
        ),
      ).bodyMedium,
      titleTextStyle: TextTheme(
        titleLarge: TextStyle(
          color: darkBG,
          fontSize: 16.0,
          fontWeight: FontWeight.w600,
          fontFamily: 'Barlow'
        ),
      ).titleLarge,
    ),
    useMaterial3: true,
    // colorScheme: ColorScheme(background: lightBG),
  );

  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: darkPrimary,
    hintColor: darkAccent,
    scaffoldBackgroundColor: darkBG,
    textTheme: const TextTheme(
      bodyMedium: TextStyle(fontSize: 14, fontFamily: 'Roboto'),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.black,
      foregroundColor: Colors.white,
      elevation: 0,
      toolbarTextStyle: TextTheme(
        titleLarge: TextStyle(
          color: lightBG,
          fontSize: 16.0,
          fontWeight: FontWeight.w600,
          fontFamily: 'Barlow'
        ),
      ).bodyMedium,
      titleTextStyle: TextTheme(
        titleLarge: TextStyle(
          color: lightBG,
          fontSize: 16.0,
          fontWeight: FontWeight.w600,
          fontFamily: 'Barlow'
        ),
      ).titleLarge,
    ),
    useMaterial3: true,
    // colorScheme: ColorScheme(background: darkBG),
  );
}
