import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MandarinaAppTheme {
  static const primaryColor = Color.fromRGBO(232, 141, 103, 1);
  static const primarySoftColor = Color.fromRGBO(249, 227, 219, 1);
  static const secondaryColor = Color.fromRGBO(255, 206, 153, 1);//Color.fromRGBO(241, 191, 152, 1);
  static const accentColor = Color.fromRGBO(243, 119, 72, 1);
  static const primaryOrangeColor = Color(0xFFE07A5F);
  //static const loginTFColor = Color.fromRGBO(241, 191, 152, 0.3);

  static const backgroundSettingsColor = Color.fromRGBO(240, 182, 158, 1);
  //static const profileAppBarColor = Color.fromRGBO(0, 105, 137, 1);
  static const blueColor = Color.fromRGBO(0, 105, 137, 1);
  static const blueBisColor = Color.fromRGBO(0, 92, 120, 1);
  static const whiteColor = Color.fromRGBO(243, 247, 236, 1);
  static const whiteBisColor = Color(0xfff9e3c3);
  static const darkBlueColor = Color.fromRGBO(44, 64, 82, 1);

  static const profilePrimaryColor = Color.fromRGBO(0, 92, 120, 1);
  static const profileSecondaryColor = Color.fromRGBO(243, 247, 236, 1);
  static const profileAccentColor = Color.fromRGBO(44, 64, 82, 1);

  static const fontBlueColor = Color.fromRGBO(67,124,144,1);

    static const TextTheme mandarinaTextTheme = TextTheme(
    headlineLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: primaryColor),
    bodyLarge: TextStyle(
      fontSize: 16, 
      fontWeight: FontWeight.w600,
      color: accentColor),
  );

  ThemeData mandarinaTheme = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      fontFamily: GoogleFonts.quicksand().fontFamily,
      textTheme:  GoogleFonts.quicksandTextTheme(MandarinaAppTheme.mandarinaTextTheme),

      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        primary: primaryColor,
        onPrimary: profileSecondaryColor,
        secondary: secondaryColor,
        onSecondary: primaryColor,
        surface: profileSecondaryColor,
        onSurface: profileAccentColor,
        tertiary: accentColor,
        onTertiary: profileSecondaryColor
      ),

      appBarTheme: const AppBarTheme(
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
    
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0.5,
          backgroundColor: primaryColor,
          foregroundColor: profileSecondaryColor,
          textStyle: GoogleFonts.quicksand(
            fontWeight: FontWeight.w500, // <--- Esto le dará más fuerza
            fontSize: 18,
          ),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: whiteColor,
        hintStyle: TextStyle(
          color: blueColor.withValues(alpha: 0.5),
          fontWeight: FontWeight.normal,
        ),
        
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: secondaryColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        errorStyle: TextStyle(
          color: blueColor,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: blueColor,width: 3),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: blueColor, width: 3),
        ),
      )
  );
}

TextStyle mandarinaTextStyle({
  double? fontSize,
  FontWeight? fontWeight,
  Color? color,
  double? letterSpacing,
  double? height,
}) {
  return GoogleFonts.quicksand(
    fontSize: fontSize,
    fontWeight: fontWeight,
    color: color,
    letterSpacing: letterSpacing,
    height: height,
  );
}

MandarinaAppTheme mandarinaAppTheme = MandarinaAppTheme();