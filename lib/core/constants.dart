import 'package:flutter/material.dart';

class AppConstants {
  // Database
  static const String dbName = 'cyberops.db';

  // Colors
  static const Color primaryColor = Colors.blueGrey;
  static const Color accentColor = Color(0xFF607D8B);
  static const Color bgColor = Color(0xFF263238);

  // Padding
  static const double defaultPadding = 16.0;

  // Default user starting values
  static const int defaultStatValue = 50;

  // Game limits
  static const int maxStat = 100;
  static const int minStat = 0;

  // App info
  static const String appName = 'CyberOps';
  static const String version = '1.0.0';
}
