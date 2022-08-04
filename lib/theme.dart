import 'package:flutter/material.dart';

ThemeData theme = ThemeData.light().copyWith(
  splashColor: CustomColors.secondary,
  colorScheme: const ColorScheme.light(
    primary: CustomColors.primary,
    secondary: CustomColors.primary,
  ),
  buttonTheme: const ButtonThemeData().copyWith(
    colorScheme: const ColorScheme.light(
      primary: CustomColors.primary,
      secondary: CustomColors.primary,
    ),
  ),
);

class CustomColors {
  static const primary = Color.fromRGBO(255,56,56, 1.0);
  static const secondary = Color.fromRGBO(255,85,85, 1);
  static const white = Color.fromRGBO(250, 250, 250, 1);
  static const grey1 = Color(0xfff6f6f6);
  static const grey2 = Color(0xffe8e8e8);
  static const grey3 = Color(0xffBDBDBD);
  static const grey4 = Color(0xff666666);
  static const black = Colors.black87;
  static const danger = Color(0xffD40000);
  static const pureWhite = Colors.white;
  static const pureBlack = Colors.black;
}

class CustomFontSize {
  static const primary = 20.0;
  static const secondary = 15.0;
  static const large = 30.0;
  static const big = 25.0;
}