import 'package:flutter/material.dart';

/// cyberOpsTheme
/// ------------------------------------------------------------
/// Global theme configuration for the CyberOps application.
///
/// This theme:
/// - Defines the app's color scheme and visual identity
/// - Ensures consistent UI styling across all screens
/// - Customizes components like AppBar, text, and buttons
final ThemeData cyberOpsTheme = ThemeData(

  /// Primary color palette used throughout the app
  primarySwatch: Colors.blueGrey,

  /// Default background color for all screens
  scaffoldBackgroundColor: const Color(0xFF263238),

  /// AppBar styling
  appBarTheme: const AppBarTheme(

    // Background color of AppBar
    backgroundColor: Color(0xFF37474F),

    // Title text style
    titleTextStyle: TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.bold,
    ),
  ),

  /// Default text styles
  textTheme: const TextTheme(

    // Main body text color
    bodyMedium: TextStyle(color: Colors.white),
  ),

  /// ElevatedButton global styling
  elevatedButtonTheme: ElevatedButtonThemeData(

    style: ElevatedButton.styleFrom(

      // Button background color
      backgroundColor: Colors.blueGrey,

      // Text/icon color
      foregroundColor: Colors.white,

      // Padding inside buttons
      padding: const EdgeInsets.symmetric(
        vertical: 12,
        horizontal: 24,
      ),

      // Rounded corners for modern UI
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
    ),
  ),
);
