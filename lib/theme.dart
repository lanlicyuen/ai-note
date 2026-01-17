
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

const Color pastelPink = Color(0xFFFDE4E4);
const Color creamyWhite = Color(0xFFFFF8F0);
const Color lightWarmGray = Color(0xFFEAEAEA);
const Color darkTextColor = Color(0xFF5D5D5D);
const Color accentColor = Color(0xFFF5A9A9);

final ThemeData appTheme = ThemeData(
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
