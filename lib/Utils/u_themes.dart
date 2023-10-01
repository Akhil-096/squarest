import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class IconSizes {
  static const double scale = 1;
  static const double med = 24;
}

/// Font Sizes
/// You can use these directly if you need, but usually there should be a predefined style in TextStyles.
class FontSizes {
  /// Provides the ability to nudge the app-wide font scale in either direction
  static double get scale => 1;
  static double get s10 => 10 * scale;
  static double get s11 => 11 * scale;
  static double get s12 => 12 * scale;
  static double get s14 => 14 * scale;
  static double get s16 => 16 * scale;
  static double get s24 => 24 * scale;
  static double get s48 => 48 * scale;
}

/// Fonts - A list of Font Families, this is uses by the TextStyles class to create concrete styles.
class Fonts {
  static const String roboto = "Roboto";
}

/// TextStyles - All the core text styles for the app should be declared here.
/// Don't try and create every variant in existence here, just the high level ones.
/// More specific variants can be created on the fly using `style.copyWith()`
/// `newStyle = TextStyles.body1.copyWith(lineHeight: 2, color: Colors.red)`
class TextStyles {
  /// Declare a base style for each Family
  static const TextStyle roboto = TextStyle(
      fontFamily: Fonts.roboto, fontWeight: FontWeight.w400, height: 1);

  static TextStyle get h1 => roboto.copyWith(
      fontWeight: FontWeight.w600,
      fontSize: FontSizes.s48,
      letterSpacing: -1,
      height: 1.17);
  static TextStyle get h2 =>
      h1.copyWith(fontSize: FontSizes.s24, letterSpacing: -.5, height: 1.16);
  static TextStyle get h3 =>
      h1.copyWith(fontSize: FontSizes.s14, letterSpacing: -.05, height: 1.29);
  static TextStyle get title1 => roboto.copyWith(
      fontWeight: FontWeight.bold, fontSize: FontSizes.s16, height: 1.31);
  static TextStyle get title2 => title1.copyWith(
      fontWeight: FontWeight.w500, fontSize: FontSizes.s14, height: 1.36);
  static TextStyle get body1 => roboto.copyWith(
      fontWeight: FontWeight.normal, fontSize: FontSizes.s14, height: 1.71);
  static TextStyle get body2 =>
      body1.copyWith(fontSize: FontSizes.s12, height: 1.5, letterSpacing: .2);
  static TextStyle get body3 => body1.copyWith(
      fontSize: FontSizes.s12, height: 1.5, fontWeight: FontWeight.bold);
  static TextStyle get callOut1 => roboto.copyWith(
      fontWeight: FontWeight.w800,
      fontSize: FontSizes.s12,
      height: 1.17,
      letterSpacing: .5);
  static TextStyle get callOut2 =>
      callOut1.copyWith(fontSize: FontSizes.s10, height: 1, letterSpacing: .25);
  static TextStyle get caption => roboto.copyWith(
      fontWeight: FontWeight.w500, fontSize: FontSizes.s11, height: 1.36);
}

class AppThemeData {
  final darkTheme = ThemeData(
    useMaterial3: Platform.isAndroid ? true : false,
    appBarTheme: AppBarTheme(
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: Colors.grey[900],
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
    ),
    primarySwatch: Colors.grey,
    primaryColor: Platform.isAndroid ? Colors.black : CupertinoColors.black,
    brightness: Brightness.dark,
    // backgroundColor: const Color(0xFF212121),
    dividerColor: Platform.isAndroid ? Colors.grey : CupertinoColors.separator,
  );
  final lightTheme = ThemeData(
    useMaterial3: Platform.isAndroid ? true : false,
    appBarTheme: AppBarTheme(
        systemOverlayStyle: SystemUiOverlayStyle(
      statusBarColor: Platform.isAndroid ? Colors.white : CupertinoColors.white,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
    ),
    ),
    primarySwatch: Colors.grey,
    primaryColor: Platform.isAndroid ? Colors.white : CupertinoColors.white,
    brightness: Brightness.light,
    // backgroundColor: const Color(0xFFE5E5E5),
    dividerColor: Platform.isAndroid ? Colors.grey : CupertinoColors.systemGrey,
  );
}
