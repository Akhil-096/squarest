import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CustomFonts {
  static const String raleWay = "Raleway";
  static const String abrilFatface = "AbrilFatface";
  static const String tenor = "Tenor";
  static const String poppins = "Poppins";
  static const String roboto = "Roboto";
  static const String poppinsBold = "PoppinsBold";
}

class CustomTextStyles {


  static TextStyle getBody(List<Shadow>? shadow, Color? colors, double? fontSize){
    TextStyle body = TextStyle(
      fontFamily: CustomFonts.roboto, fontSize: fontSize, shadows: shadow, color: colors);
    return body;
  }

  static TextStyle getNormalPoppins(List<Shadow>? shadow, Color? colors, double? fontSize){
    TextStyle body = TextStyle(
        fontFamily: CustomFonts.poppins, fontSize: fontSize, shadows: shadow, color: colors);
    return body;
  }

  static TextStyle getTitle(List<Shadow>? shadow, Color? colors, TextDecoration? textDecoration, double? fontSize){
    TextStyle title = TextStyle(
        fontFamily: CustomFonts.poppinsBold, fontSize: fontSize, shadows: shadow, color: colors, decoration: textDecoration);
    return title;
  }

  static TextStyle getH4(List<Shadow>? shadow, Color? colors, TextDecoration? textDecoration, double? fontSize) {
    TextStyle h4 = TextStyle(
        fontFamily: CustomFonts.roboto, fontWeight: FontWeight.w600, fontSize: fontSize, shadows: shadow, color: colors, decoration: textDecoration);
    return h4;
  }

  static TextStyle getBodySmall(List<Shadow>? shadow, Color? colors, FontWeight? fontWeight, double? fontSize){
    TextStyle bodySmall = TextStyle(
        fontFamily: CustomFonts.roboto, fontSize: fontSize, shadows: shadow, color: colors, fontWeight: fontWeight);
    return bodySmall;
  }

  static TextStyle getProjectNameFont(List<Shadow>? shadow, Color? colors, double? fontSize){
    TextStyle bodyBold = TextStyle(
        fontFamily: CustomFonts.poppinsBold, fontSize: fontSize,
        shadows: shadow, color: colors);
    return bodyBold;
  }

  static TextStyle getBodyBold(List<Shadow>? shadow, Color? colors, double? fontSize){
     TextStyle bodyBold = TextStyle(
       fontFamily: CustomFonts.roboto, fontWeight: FontWeight.w600, fontSize: fontSize,
         shadows: shadow, color: colors);
     return bodyBold;
   }


}

class CustomShadows {
  static final textSoft = [
    Shadow(color: Platform.isAndroid ? Colors.black.withOpacity(.25) : CupertinoColors.black.withOpacity(.25), offset: const Offset(0, 2), blurRadius: 4),
  ];
  static final textNormal = [
    Shadow(color: Platform.isAndroid ? Colors.black.withOpacity(.6) : CupertinoColors.black.withOpacity(.6), offset: const Offset(0, 2), blurRadius: 2),
  ];
  static final textStrong = [
    Shadow(color: Platform.isAndroid ? Colors.black.withOpacity(.6) : CupertinoColors.black.withOpacity(.6), offset: const Offset(0, 4), blurRadius: 6),
  ];
}