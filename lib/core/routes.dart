import 'package:flutter/material.dart';
import 'package:cyberops/screens/login_screen.dart';
import 'package:cyberops/screens/dashboard_screen.dart';
import 'package:cyberops/screens/achievements_screen.dart';
import 'package:cyberops/screens/scenario_screen.dart';

/// AppRoutes
/// ------------------------------------------------------------
/// Centralized route generator for the CyberOps application.
///
/// This class:
/// - Manages navigation between screens
/// - Handles passing arguments between routes
/// - Provides a fallback for undefined routes (404)
class AppRoutes {

  /// Generates routes dynamically based on route name
  static Route<dynamic> generateRoute(RouteSettings settings) {

    switch (settings.name) {

      /// --------------------------------------------------------
      /// Login Screen (default route)
      /// --------------------------------------------------------
      case '/':
        return MaterialPageRoute(
          builder: (_) => const LoginScreen(),
        );

      /// --------------------------------------------------------
      /// Dashboard Screen
      /// Requires:
      /// - userId (int or String depending on implementation)
      /// - isGuest (bool)
      /// --------------------------------------------------------
      case '/dashboard':

        // Extract arguments safely
        final args = settings.arguments as Map<String, dynamic>?;

        final userId = args?['userId'] ?? -1;
        final isGuest = args?['isGuest'] ?? false;

        return MaterialPageRoute(
          builder: (_) => DashboardScreen(
            userId: userId,
            isGuest: isGuest,
          ),
        );

      /// --------------------------------------------------------
      /// Achievements Screen
      /// Requires:
      /// - userId
      /// --------------------------------------------------------
      case '/achievements':

        final args = settings.arguments as Map<String, dynamic>?;
        final userId = args?['userId'] ?? -1;

        return MaterialPageRoute(
          builder: (_) => AchievementsScreen(userId: userId),
        );

      /// --------------------------------------------------------
      /// Scenario Screen
      /// Requires:
      /// - userId
      /// --------------------------------------------------------
      case '/scenarios':

        final args = settings.arguments as Map<String, dynamic>?;
        final userId = args?['userId'] ?? -1;

        return MaterialPageRoute(
          builder: (_) => ScenarioScreen(userId: userId),
        );

      /// --------------------------------------------------------
      /// Fallback Route (404)
      /// Triggered when route name is not recognized
      /// --------------------------------------------------------
      default:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(
              child: Text('404 — Page not found'),
            ),
          ),
        );
    }
  }
}
