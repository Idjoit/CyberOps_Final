import 'package:flutter/material.dart';

final ThemeData cyberOpsTheme = ThemeData(
  primarySwatch: Colors.blueGrey,
  scaffoldBackgroundColor: const Color(0xFF263238),
  appBarTheme: const AppBarTheme(
    backgroundColor: Color(0xFF37474F),
    titleTextStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
  ),
  textTheme: const TextTheme(
    bodyMedium: TextStyle(color: Colors.white),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.blueGrey,
      foregroundColor: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
    ),
  ),
);
