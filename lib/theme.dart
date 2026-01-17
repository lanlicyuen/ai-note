
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// --- Light Theme Colors ---
const Color pastelPink = Color(0xFFFDE4E4);
const Color creamyWhite = Color(0xFFFFF8F0);
const Color lightWarmGray = Color(0xFFEAEAEA);
const Color darkTextColor = Color(0xFF5D5D5D);
const Color accentColor = Color(0xFFF5A9A9);

// --- Dark Theme Colors ---
const Color darkBackground = Color(0xFF1A1D21);
const Color darkSurface = Color(0xFF282C34);
const Color lightTextColor = Color(0xFFEAEAEA);
const Color darkAccentColor = Color(0xFFF08A8A); // A bit brighter for better contrast

// --- Light Theme Data ---
final ThemeData lightTheme = ThemeData(
  brightness: Brightness.light,
  primaryColor: pastelPink,
  scaffoldBackgroundColor: creamyWhite,
  textTheme: GoogleFonts.latoTextTheme().apply(
    bodyColor: darkTextColor,
    displayColor: darkTextColor,
  ),
  appBarTheme: AppBarTheme(
    backgroundColor: creamyWhite,
    elevation: 0,
    iconTheme: const IconThemeData(color: darkTextColor),
    titleTextStyle: GoogleFonts.lato(
      color: darkTextColor,
      fontSize: 22,
      fontWeight: FontWeight.bold,
    ),
  ),
  cardTheme: CardThemeData(
    color: Colors.white,
    elevation: 2,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(20),
    ),
    shadowColor: lightWarmGray.withOpacity(0.5),
  ),
  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    backgroundColor: accentColor,
    foregroundColor: Colors.white,
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: accentColor,
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: Colors.white,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(20),
      borderSide: BorderSide.none,
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(20),
      borderSide: const BorderSide(color: accentColor, width: 2),
    ),
    hintStyle: const TextStyle(color: lightWarmGray),
  ),
  iconTheme: const IconThemeData(color: accentColor),
);

// --- Dark Theme Data ---
final ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  primaryColor: darkAccentColor,
  scaffoldBackgroundColor: darkBackground,
  textTheme: GoogleFonts.latoTextTheme().apply(
    bodyColor: lightTextColor,
    displayColor: lightTextColor,
  ),
  appBarTheme: AppBarTheme(
    backgroundColor: darkBackground,
    elevation: 0,
    iconTheme: const IconThemeData(color: lightTextColor),
    titleTextStyle: GoogleFonts.lato(
      color: lightTextColor,
      fontSize: 22,
      fontWeight: FontWeight.bold,
    ),
  ),
  cardTheme: CardThemeData(
    color: darkSurface,
    elevation: 4,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(20),
    ),
    shadowColor: Colors.black.withOpacity(0.5),
  ),
  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    backgroundColor: darkAccentColor,
    foregroundColor: Colors.white,
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: darkAccentColor,
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: darkSurface,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(20),
      borderSide: BorderSide.none,
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(20),
      borderSide: const BorderSide(color: darkAccentColor, width: 2),
    ),
    hintStyle: TextStyle(color: lightTextColor.withOpacity(0.5)),
  ),
  iconTheme: const IconThemeData(color: darkAccentColor),
);
